module Synchronizable

  BASE_ATTRS = [:remote_id, :id, :deleted_at]

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
        attrs[:remote_id] = object.id
        @data[key][field] = [] unless @data[key][field].present?
        @data[key][field] << attrs
      end
    end
  end


  module Helpers
    extend self

    def timestamp_from_javascript timestamp
      return 0 unless timestamp
      timestamp.to_i / 1000
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
      def self.has_fields(fields)
        @fields = fields
      end
    end


    def belongs_to_user? model
      model.column_names.includes? 'user_id'
    end


    def process_fields params
      Sync.fields.each do |field|
        model = field.to_s.classify.constantize
        belongs_to_user = belongs_to_user? model

        field.each do |attrs|
          attrs[:user_id] = @current_user.id if belongs_to_user
          process model, attrs.symbolize_keys!
        end
      end

      @output.data
    end


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

      updated_at = Helpers.timestamp_from_javascript(params[:updated_at])

      if updated_at >= object.updated_at.to_i
        return update object, attrs
      else
        return @output.set_diffs object, attrs
      end
    end


    def create(model, attrs)
      if object = model.create(attrs)
        @output.set_data object, attrs
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
