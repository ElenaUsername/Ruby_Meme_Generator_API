# frozen_string_literal: true

require 'sinatra'
require 'mini_magick'
require 'open-uri'
require 'fileutils'

require_relative './lib/meme_generator'
require_relative './lib/image_processing'

FileUtils.mkdir_p('tmp')
FileUtils.mkdir_p('public/memes')

get '/' do
  <<~HTML
    <form action="/generate" method="post">
      <input type="text" name="image_url" placeholder="Image URL" required>
      <input type="text" name="text_meme" placeholder="Meme text" required>
      <button type="submit">Generate</button>
    </form>
  HTML
end

post '/generate' do
  image_url = params[:image_url]
  text_meme = params[:text_meme]

  processor = ImageProcessing.new
  downloaded_path = processor.save_imagine(image_url)
  halt 422, 'Could not download image' if downloaded_path.nil?

  output_filename = "meme_#{Time.now.to_i}_#{rand(1..100_000)}.jpg"
  output_path = File.join('public/memes', output_filename)

  generator = MemeGenerator.new(downloaded_path)
  result = generator.generate(text_meme, output_path)
  halt 422, 'Could not generate meme' if result.nil?

  FileUtils.rm_f(downloaded_path)

  redirect "/memes/#{output_filename}"
end
