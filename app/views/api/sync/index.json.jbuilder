json.posts do
  json.array!(@posts) do |post|
    json.set! :remote_id,  post.id
    json.set! :title,      post.title
    json.set! :content,    post.content
    json.set! :categories, post.categories
    json.set! :created_at, post.created_at.to_i * 1000
    json.set! :updated_at, post.updated_at.to_i * 1000
  end
end
