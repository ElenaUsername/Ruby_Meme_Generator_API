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
  
  describe 'POST /generate' do
    it 'returns a successful redirect response' do
      post '/generate', { image_url: image_url, text_meme: text_meme }, { 'rack.session' => { name: 'tester' } }
      expect(last_response.status).to eq(302)
    end

    it 'returns 422 if image download fails' do
      allow_any_instance_of(ImageProcessing).to receive(:save_imagine).and_return(nil)
      post '/generate', { image_url: image_url, text_meme: text_meme }, { 'rack.session' => { name: 'tester' } }
      expect(last_response.status).to eq(422)
    end

    it 'redirects to the generated meme path' do
      post '/generate', { image_url: image_url, text_meme: text_meme }, { 'rack.session' => { name: 'tester' } }
      expect(last_response.headers['Location']).to match(%r{/memes/meme_\d+_\d+\.jpg})
    end
  end

  describe 'Authentication' do
    it 'redirects to /generate on successful signup' do
      allow(DataBase).to receive(:verify_user_exist).and_return(false)
      allow(DataBase).to receive(:sign_up).and_return(true)
      post '/auth', name: 'alice', password: 'secret', action: 'signup'
      expect(last_response.status).to eq(307)
      expect(last_response.headers['Location']).to end_with('/generate')
    end

    it 'returns 409 when signup fails due to duplicate username' do
      allow(DataBase).to receive(:verify_user_exist).and_return(true)
      post '/auth', name: 'bob', password: 'secret', action: 'signup'
      expect(last_response.status).to eq(409)
    end

    it 'returns 400 when signup fields are blank' do
      post '/auth', name: '', password: '', action: 'signup'
      expect(last_response.status).to eq(400)
    end

    it 'redirects to /generate on successful login' do
      allow(DataBase).to receive(:login).and_return(true)
      post '/auth', name: 'charlie', password: 'secret', action: 'login'
      expect(last_response.status).to eq(307)
      expect(last_response.headers['Location']).to end_with('/generate')
    end

    it 'returns 401 on failed login' do
      allow(DataBase).to receive(:login).and_return(false)
      post '/auth', name: 'dave', password: 'wrong', action: 'login'
      expect(last_response.status).to eq(401)
    end

    it 'returns 400 when login fields are blank' do
      post '/auth', name: '', password: '', action: 'login'
      expect(last_response.status).to eq(400)
    end

    it 'requires login to access /generate' do
      get '/generate'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to end_with('/')
    end
  end
end
