# frozen_string_literal: true

require 'open-uri'
require 'fileutils'

FileUtils.mkdir_p('tmp')

class ImageProcessing
  def save_imagine(path)
    image_url = path
    id_image = rand(1..1000)
    local_destination = "tmp/downloaded_meme#{id_image}.jpg"

    image_data = URI.open(image_url).read
    File.open(local_destination, 'wb') { |f| f.write(image_data) }
    local_destination
  rescue StandardError
    nil
  end
end
