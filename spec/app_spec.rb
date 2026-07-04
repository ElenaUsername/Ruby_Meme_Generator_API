# frozen_string_literal: true

require './app'

RSpec.describe 'App' do
  let(:image_url) { 'http://example.com/image.jpg' }
  let(:text_meme) { 'Test meme' }
  let(:downloaded_path) { 'tmp/downloaded.jpg' }

  before do
    allow_any_instance_of(ImageProcessing).to receive(:save_imagine).and_return(downloaded_path)
    allow_any_instance_of(MemeGenerator).to receive(:generate).and_return('ok')
    allow(FileUtils).to receive(:rm_f)
  end

  it 'returns a successful redirect response' do
    post '/generate', image_url: image_url, text_meme: text_meme
    expect(last_response.status).to eq(302)
  end

  it 'returns 422 if image download fails' do
    allow_any_instance_of(ImageProcessing).to receive(:save_imagine).and_return(nil)
    post '/generate', image_url: image_url, text_meme: text_meme
    expect(last_response.status).to eq(422)
  end

  it 'redirects to the generated meme path' do
    post '/generate', image_url: image_url, text_meme: text_meme
    expect(last_response.headers['Location']).to match(%r{/memes/meme_\d+_\d+\.jpg})
  end
end
