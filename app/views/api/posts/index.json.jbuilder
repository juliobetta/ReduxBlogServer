json.array!(@posts) do |post|
  json.extract! post, :id, :user_id, :title, :categories
end
