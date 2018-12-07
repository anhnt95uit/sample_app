class User < ApplicationRecord
  before_save{email.downcase!}
  validates :name, presence: true,
    length: {maximum: Settings[:users][:name][:max_length]}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
    length: {maximum: Settings[:users][:email][:max_length]},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true,
    length: {minimum: Settings[:users][:password][:min_length]}
end
