json.posts do
  json.array!(@posts) do |post|
    json.set! :id,         post['id']
    json.set! :remote_id,  post['remote_id']
    json.set! :title,      post['title']
    json.set! :categories, post['categories']
    json.set! :content,    post['content']
    json.set! :created_at, post['created_at'].to_i
    json.set! :updated_at, post['updated_at'].to_i
  end
end
