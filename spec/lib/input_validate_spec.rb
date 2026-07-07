# frozen_string_literal: true

require './lib/input_validator'

def test_validate_text(text, return_value)
  expect(InputValidator.validate_text(text)).to be return_value
end

def test_validate_image_url(url, return_value)
  expect(InputValidator.validate_image_url(url)).to be return_value
end

RSpec.describe InputValidator do
  context 'validate_text' do
    it 'returns false for nil text' do
      test_validate_text(nil, false)
    end

    it 'returns false for empty text' do
      test_validate_text('', false)
    end

    it 'returns false for text longer than 20 characters' do
      long_text = 'a' * 21
      test_validate_text(long_text, false)
    end

    it 'returns true for valid text' do
      test_validate_text('Valid meme text', true)
    end
  end

  context 'validate_image_url' do
    it 'returns false for nil URL' do
      test_validate_image_url(nil, false)
    end

    it 'returns false for empty URL' do
      test_validate_image_url('', false)
    end

    it 'returns false for invalid URL' do
      test_validate_image_url('invalid-url', false)
    end

    it 'returns true for valid image URL' do
      valid_url = 'https://example.com/image.jpg'
      allow(URI).to receive(:open).with(valid_url).and_return(double(read: 'image_data'))
      test_validate_image_url(valid_url, true)
    end

    it 'returns false for image larger than 5 MB' do
      large_image_url = 'https://example.com/large_image.jpg'
      allow(URI).to receive(:open).with(large_image_url).and_return(double(read: 'a' * (5 * 1024 * 1024 + 1)))
      test_validate_image_url(large_image_url, false)
    end
  end
end
