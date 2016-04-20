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
        errors:    {},
        diffs:     {},
        deletions: {},
        data:      {}
      }
    end


    [:errors, :diffs, :data].each do |key|
      define_method("add_to_#{key}") do |object, attrs|
        table_name = object.class.to_s.tableize.to_sym
        attrs[:remote_id] = object.id rescue nil
        @data[key][table_name] = [] unless @data[key][table_name].present?
        @data[key][table_name] << object.attributes.symbolize_keys.merge(attrs)
      end
    end


    def add_to_deletions(table_name, ids)
      ids = [ids] unless ids.is_a? Array

      unless @data[:deletions][table_name].present?
        @data[:deletions][table_name] = []
      end

      @data[:deletions][table_name].concat ids
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
      self.class.models.each do |table_name|
        model = get_model_from table_name
        belongs_to_user = belongs_to_user? model

        ActiveRecord::Base.transaction do
          @params[table_name][:objects].each do |attrs|
            attrs[:user_id] = @current_user.id if belongs_to_user
            process model, attrs.symbolize_keys!
          end
        end

        process_remote_ids_for model, @params[table_name][:remote_ids]
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
        return @output.add_to_deletions object, attrs
      end

      if attrs[:deleted_at].present?
        return destroy object, attrs
      end

      if updated_at.to_datetime >= object.updated_at
        return update object, attrs.except(:remote_id, :id, :updated_at)
      else
        return @output.add_to_diffs object, attrs
      end
    end


    def process_remote_ids_for(model, remote_ids)
      unmatched_ids = remote_ids - model.where(id: remote_ids).pluck(:id)
      @ouput.add_to_deletions unmatched_ids
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
        @output.add_to_data object, attrs.except(:remote_id, :id)
      else
        @output.add_to_errors object, object.errors.full_messages
      end
    end


    def destroy(object, attrs)
      object.destroy!
      @output.add_to_deletions object, attrs
    end


    def update(object, attrs)
      if object.update_attributes attrs
        @output.add_to_data object, attrs
      else
        @output.add_to_errors object, object.errors.full_messages
      end
    end

  end
end
