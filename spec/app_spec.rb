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
    DataBase.sign_up('tester', 'password') unless DataBase.verify_user_exist('tester')
  end

  context 'POST /generate' do
    it 'returns a successful redirect response' do
      token = DataBase.take_the_user_token('tester')
      post '/generate', { image_url: image_url, text_meme: text_meme }, { 'rack.session' => { token: token } }
      expect(last_response.status).to eq(302)
    end

    it 'returns 422 if image download fails' do
      allow_any_instance_of(ImageProcessing).to receive(:save_imagine).and_return(nil)
      token = DataBase.take_the_user_token('tester')
      post '/generate', { image_url: image_url, text_meme: text_meme }, { 'rack.session' => { token: token } }
      expect(last_response.status).to eq(422)
    end

    it 'redirects to the generated meme path' do
      token = DataBase.take_the_user_token('tester')
      post '/generate', { image_url: image_url, text_meme: text_meme }, { 'rack.session' => { token: token } }
      expect(last_response.headers['Location']).to match(%r{/memes/meme_\d+_\d+\.jpg})
    end
  end

  context 'Authentication' do
    it 'redirects to /generate on successful signup' do
      allow(DataBase).to receive(:verify_user_exist).and_return(false)
      allow(DataBase).to receive(:sign_up).and_return(true)
      post '/sign_up', name: 'alice', password: 'secret'
      expect(last_response.status).to eq(307)
      expect(last_response.headers['Location']).to end_with('/generate')
    end

    it 'returns 409 when signup fails due to duplicate username' do
      allow(DataBase).to receive(:verify_user_exist).and_return(true)
      post '/sign_up', name: 'bob', password: 'secret'
      expect(last_response.status).to eq(409)
    end

    it 'returns 400 when signup fields are blank' do
      post '/sign_up', name: '', password: ''
      expect(last_response.status).to eq(400)
    end

    it 'redirects to /generate on successful login' do
      allow(DataBase).to receive(:login).and_return(true)
      post '/log_in', name: 'charlie', password: 'secret'
      expect(last_response.status).to eq(307)
      expect(last_response.headers['Location']).to end_with('/generate')
    end

    it 'returns 401 on failed login' do
      allow(DataBase).to receive(:login).and_return(false)
      post '/log_in', name: 'dave', password: 'wrong'
      expect(last_response.status).to eq(401)
    end

    it 'returns 400 when login fields are blank' do
      post '/log_in', name: '', password: ''
      expect(last_response.status).to eq(400)
    end

    it 'requires login to access /generate' do
      get '/generate'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to end_with('/')
    end
  end
end
