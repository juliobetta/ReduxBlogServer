json.posts do
  json.array!(@posts) do |post|
    json.set! :id,         post['id']
    json.set! :deleted_at, post['deleted_at'] || nil
    json.set! :remote_id,  post['remote_id']
    json.set! :title,      post['title']
    json.set! :categories, post['categories']
    json.set! :content,    post['content']
    json.set! :created_at, post['created_at'].to_f * 1000
    json.set! :updated_at, post['updated_at'].to_f * 1000
  end
end
