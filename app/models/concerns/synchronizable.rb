module Synchronizable
  @attrs = {
    remote_id_key:  :remote_id,
    local_id_key:   :id,
    deleted_at_key: :deleted_at,
    last_sync_key:  :last_sync
  }


  class Output
    attr_accessor :data

    def initialize
      @data = {
        errors: {},
        diffs:  {},
        data:   {}
      }
    end


    [:errors, :diffs, :data].each do |key|
      define_method("set_#{key}") do |object, attrs|
        table_name = object.class.to_s.tableize.to_sym
        attrs[:remote_id] = object.id rescue nil
        @data[key][table_name] = [] unless @data[key][table_name].present?
        @data[key][table_name] << object.attributes.symbolize_keys.merge(attrs)
      end
    end
  end


  module Base
    extend ActiveSupport::Concern

    def initialize(current_user, params)
      @current_user = current_user
      @params       = params

      @output = Output.new
    end


    included do
    end


    module ClassMethods
      attr_accessor :models

      def with_many(*args)
        self.models = args
      end
    end


    def execute
      ActiveRecord::Base.transaction do
        self.class.models.each do |table_name|
          model = get_model_from table_name
          belongs_to_user = belongs_to_user? model

          @params[table_name].each do |attrs|
            attrs[:user_id] = @current_user.id if belongs_to_user
            process model, attrs.symbolize_keys!
          end
        end
      end

      @output
    end



    private

    def process(model, attrs)
      unless attrs[:remote_id].present?
        return create model, attrs
      end

      object = model.find_by id: attrs[:remote_id]

      if object.nil?
        return @output.set_data object, attrs.merge(deleted_at: Time.now.to_i)
      end

      if attrs[:deleted_at].present?
        return destroy object, attrs
      end

      if updated_at.to_datetime >= object.updated_at
        return update object, attrs.except(:remote_id, :id, :updated_at)
      else
        return @output.set_diffs object, attrs
      end
    end


    def get_model_from table_name
      table_name.to_s.classify.constantize
    end


    def belongs_to_user? model
      model.column_names.include? 'user_id'
    end


    def all
      updated_at = @params[:last_sync].to_datetime
      results = {}

      self.class.models.each do |table_name|
        model = get_model_from table_name

        results[table_name] = {} unless results[table_name].present?
        results[table_name] << model.where('updated_at >= ?', updated_at)
      end

      results
    end


    def create(model, attrs)
      if object = model.create(attrs)
        @output.set_data object, attrs.except(:remote_id, :id)
      else
        @output.set_errors object, object.errors.full_messages
      end
    end


    def destroy(object, attrs)
      object.destroy!
      @output.set_data object, attrs
    end


    def update(object, attrs)
      if object.update_attributes attrs
        @output.set_data object, attrs
      else
        @output.set_errors object, object.errors.full_messages
      end
    end

  end
end
