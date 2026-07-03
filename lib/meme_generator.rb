# frozen_string_literal: true

require 'mini_magick'

class MemeGenerator
  def initialize(image_path)
    @image_path = image_path
  end

  def generate(text_meme, output_path)
    return nil if text_meme.nil? || @image_path.nil?

    image = MiniMagick::Image.open(@image_path)

    width = image.width
    image.height

    image.combine_options do |config|
      config.font 'Arial'
      config.pointsize(width * 0.08)
      config.gravity 'Center'
      config.fill 'white'
      config.stroke 'black'
      config.strokewidth 2
      config.draw "text 0,0 '#{text_meme}'"
    end

    image.write(output_path)
    output_path
  end
end
