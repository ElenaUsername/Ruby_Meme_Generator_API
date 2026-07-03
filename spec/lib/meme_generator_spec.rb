require './lib/meme_generator'

def test_generate_meme(input_image_path, input_text, output_generated_path)
  generator = MemeGenerator.new(input_image_path)
  generator.generate(input_text, output_generated_path)
end

context "MemeGenerator" do
  let(:input_image_path) { "spec/fixtures/meme1.jpg" }
  let(:input_text) { "CODING IN RUBY!" }
  let(:output_generated_path) { "spec/fixtures/meme1_generated.jpg" }

  after(:each) { File.delete(output_generated_path) if File.exist?(output_generated_path) }

  it "creates an output file when image and text are valid" do
    test_generate_meme(input_image_path, input_text, output_generated_path)
  end

  it "returns nil when image path is nil" do
    test_generate_meme(nil, input_text, nil)
  end

  it "returns nil when text is nil" do
    test_generate_meme(input_image_path, nil, nil)
  end
end