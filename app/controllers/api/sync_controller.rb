class API::SyncController < ApplicationController
  before_action :authenticate_user_from_token!

  def index
    # TODO get all posts with updated_at > params[:updated_at]
    @posts = Post.all
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
    belongs_to_user = subject.column_names.include? 'user_id'

    sync_params[field.to_s].each do |attrs|
      attrs['user_id'] = current_user.id if belongs_to_user

      if attrs['remote_id'].present?
        object = subject.find_by! attrs['remote_id']

        if attrs['deleted_at'].present?
          object.destroy!
        else
          object.update_attributes! send("valid_#{field}_attrs_from", attrs)
        end
      else
        object = subject.create! send("valid_#{field}_attrs_from", attrs)
        attrs['remote_id'] = object.id
      end

      objects << object.attributes.merge(attrs) if object.persisted?
    end

    objects
  end
end
