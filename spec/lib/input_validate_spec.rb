require './lib/input_validator'

RSpec.describe InputValidator do
  context 'validate_text' do
    it 'returns false for nil text' do
      expect(InputValidator.validate_text(nil)).to be false
    end

    it 'returns false for empty text' do
      expect(InputValidator.validate_text('')).to be false
    end

    it 'returns false for text longer than 20 characters' do
      long_text = 'a' * 21
      expect(InputValidator.validate_text(long_text)).to be false
    end

    it 'returns true for valid text' do
      expect(InputValidator.validate_text('Valid meme text')).to be true
    end
  end
  
  context 'validate_image_url' do
    it 'returns false for nil URL' do
      expect(InputValidator.validate_image_url(nil)).to be false
    end

    it 'returns false for empty URL' do
      expect(InputValidator.validate_image_url('')).to be false
    end

    it 'returns false for invalid URL' do
      expect(InputValidator.validate_image_url('invalid-url')).to be false
    end

    it 'returns true for valid image URL' do
      valid_url = 'https://example.com/image.jpg'
      allow(URI).to receive(:open).with(valid_url).and_return(double(read: 'image_data'))
      expect(InputValidator.validate_image_url(valid_url)).to be true
    end

    it 'returns false for image larger than 5 MB' do
      large_image_url = 'https://example.com/large_image.jpg'
      allow(URI).to receive(:open).with(large_image_url).and_return(double(read: 'a' * (5 * 1024 * 1024 + 1)))
      expect(InputValidator.validate_image_url(large_image_url)).to be false
    end
  end
end
