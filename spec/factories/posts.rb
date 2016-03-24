FactoryGirl.define do
  user { FactoryGirl.build(:user) }
  title { Faker::Name.title }
  content { Faker::Lorem.paragraph }
  category { Faker::Lorem.sentence }
end
