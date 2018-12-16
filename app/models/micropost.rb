class Micropost < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.microposts.maximum}
  validate  :picture_size
  scope :feed, -> following_ids, id {where("user_id IN (:following_ids) OR user_id = :user_id",
    following_ids: following_ids, user_id: id)}
  scope :newest, -> {order created_at: :desc}

  private

  # Validates the size of an uploaded picture.
  def picture_size
    if(picture.size > Settings.picture.default.megabytes)
      errors.add(:picture, Settings.picture.errors)
    end
  end
end
