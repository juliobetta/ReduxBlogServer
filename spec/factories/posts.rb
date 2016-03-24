FactoryGirl.define do
  factory :post do
    user { FactoryGirl.build(:user) }
    title 'Post Title'
    content 'Post Content'
    categories 'Post Category'
  end
end
