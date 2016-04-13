class API::SyncController < ApplicationController
  before_action :authenticate_user_from_token!

  def index
    @posts = Post.updated_starting_from(params[:updated_at] || nil)
                 .where(user: current_user)
  end


  def update
    ActiveRecord::Base.transaction do
      @posts = sync(:posts, Post)
    end
  end



  private

  def valid_posts_attrs_from(attrs)
    attrs.slice(*%W(title categories content user_id))
  end


  def sync_params
    params.require(:data).permit(
      posts: [:id, :remote_id, :deleted_at, :title, :categories, :content]
    )
  end


  def sync(field, subject)
    objects = []
    return objects unless sync_params[field.to_s].present?

    belongs_to_user = subject.column_names.include? 'user_id'

    sync_params[field.to_s].each do |attrs|
      attrs['user_id'] = current_user.id if belongs_to_user

      if attrs['remote_id'].present?
        object = subject.find_by id: attrs['remote_id']

        if object.nil?
          objects << attrs.merge({ 'deleted_at' => Time.now.to_i })
          next
        end

        if attrs['deleted_at'].present?
          object.destroy!
        else
          object.update_attributes! send("valid_#{field}_attrs_from", attrs)
        end
      else
        object = subject.create! send("valid_#{field}_attrs_from", attrs)
      end

      attrs['remote_id'] = object.id
      objects << object.attributes.merge(attrs)
    end

    objects
  end
end
