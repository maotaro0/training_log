class Profile < ApplicationRecord
  belongs_to :user
  attr_accessor :remove_avatar

  validates :name, length: { maximum: 50 }
  validates :monthly_goal, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validate :valid_avatar_upload
  before_validation :clear_avatar, if: -> { ActiveModel::Type::Boolean.new.cast(remove_avatar) }

  def avatar=(upload)
    return if upload.blank?
    @avatar_error = nil
    if upload.size > 1.megabyte
      @avatar_error = "は1MB以下の画像を選んでください。"
      return
    end
    bytes = upload.read
    upload.rewind
    type = if bytes.start_with?("\x89PNG\r\n\x1a\n".b)
      "image/png"
    elsif bytes.start_with?("\xff\xd8\xff".b)
      "image/jpeg"
    elsif bytes.start_with?("RIFF") && bytes.byteslice(8, 4) == "WEBP"
      "image/webp"
    end
    unless type
      @avatar_error = "はJPEG・PNG・WebP形式で選んでください。"
      return
    end
    self.avatar_data = bytes
    self.avatar_content_type = type
  end

  def avatar?
    avatar_data.present?
  end

  private

  def valid_avatar_upload
    errors.add(:avatar, @avatar_error) if @avatar_error
  end

  def clear_avatar
    self.avatar_data = nil
    self.avatar_content_type = nil
    @avatar_error = nil
  end
end
