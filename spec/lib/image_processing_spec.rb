require './lib/image_processing'

def test_save_imagine(image_url)
  processor = ImageProcessing.new
  processor.save_imagine(image_url)
end

context "ImagineProcessing" do
  describe "save_imagine" do
    let(:valid_image_url) { "https://media.newyorker.com/photos/665f65409ad64d9e7a494208/16:9/w_1280,c_limit/Chayka-screenshot-06-05-24.jpg" }
    let(:invalid_image_url) { "https://invalid" }

    it "saves an image from a valid URL" do
      expect(test_save_imagine(valid_image_url)).to include("downloaded_meme")
    end

    it "returns nil for an invalid URL" do
      expect(test_save_imagine(invalid_image_url)).to be_nil
    end
  end
end