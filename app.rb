# frozen_string_literal: true

require 'sinatra'
require 'mini_magick'
require 'open-uri'
require 'fileutils'
require 'rack'
require 'securerandom'

require_relative './lib/meme_generator'
require_relative './lib/image_processing'
require_relative './lib/data_base'

enable :sessions
raw_secret = ENV['SESSION_SECRET']
if raw_secret.nil? || raw_secret.bytesize < 64
  raw_secret = SecureRandom.hex(64)
end
set :session_secret, raw_secret

FileUtils.mkdir_p('tmp')
FileUtils.mkdir_p('public/memes')

get '/' do
  <<~HTML
    <h2>Login / Sign Up</h2>
    <form action="/auth" method="post">
      <input type="text" name="name" placeholder="Name" required>
      <input type="password" name="password" placeholder="Password" required>
      <button type="submit" name="action" value="login">Login</button>
      <button type="submit" name="action" value="signup">Sign Up</button>
    </form>
    <p>Or go to the <a href="/generate">meme generator</a>.</p>
  HTML
end

post '/auth' do
  name = params[:name].to_s.strip
  password = params[:password].to_s
  action = params[:action]
  
  if name.empty? || password.empty?
    status 400
    return 'Name and password cannot be blank'
  end

  if action == 'signup'
    if DataBase.verify_user_exist(name)
      status 409
      return 'User already exists'
    end

    success = DataBase.sign_up(name, password)
    if success
      session[:name] = name
      redirect '/generate', 307
    else
      status 500
      'Sign up failed'
    end
  elsif action == 'login'
    if DataBase.login(name, password)
      session[:name] = name
      redirect '/generate', 307
    else
      status 401
      'Login failed: invalid name or password'
    end
  else
    status 400
    'Unknown action'
  end
end

get '/generate' do
  unless session[:name]
    redirect '/'
  end

  <<~HTML
    <h2>Meme Generator</h2>
    <form action="/generate" method="post">
      <input type="text" name="image_url" placeholder="Image URL" required>
      <input type="text" name="text_meme" placeholder="Meme text" required>
      <button type="submit">Generate</button>
    </form>
    <p>Signed in as #{Rack::Utils.escape_html(session[:name])} — <a href="/logout">Logout</a></p>
  HTML
end

get '/logout' do
  session.clear
  redirect '/'
end

post '/generate' do
  unless session[:name]
    redirect '/'
  end
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
