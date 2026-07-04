# frozen_string_literal: true

class InputValidator
  def self.validate_text(text)
    return false if text.nil? || text.empty?
    return false if text.length > 20

    true
  end

  def self.validate_image_url(url)
    return false if url.nil? || url.empty?

    begin
      image_data = URI.open(url).read
      image_size = image_data.size
      return false if image_size > 5 * 1024 * 1024 # 5 MB limit
    rescue StandardError
      return false
    end
    true
  end
end
