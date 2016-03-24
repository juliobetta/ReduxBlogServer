FactoryGirl.define do
  factory :user do
    name { Faker::Name::name }
    email { Faker::Internet.email }
    password 'my_awesome_password'
    password_confirmation 'my_awesome_password'
  end
end
