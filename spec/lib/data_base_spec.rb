# frozen_string_literal: true

require './lib/data_base'

def test_sign_up(name, password, result_expected)
  expect(DataBase.sign_up(name, password)).to be result_expected
end

def test_login(name, password, result_expected)
  expect(DataBase.login(name, password)).to be result_expected
end

RSpec.describe DataBase do
  before(:each) do
    DataBase.setup_db
    db = SQLite3::Database.open(DataBase::DB_FILE)
    db.execute('DELETE FROM users')
    db.close
  end

  let(:name) { 'test_user' }
  let(:password) { 'secure_password' }
  let(:wrong_name) { 'wrong_user' }
  let(:wrong_password) { 'wrong_password' }

  describe 'sign_up' do
    it 'creates a new user with a hashed password' do
      test_sign_up(name, password, true)
    end

    it 'does not allow duplicate usernames' do
      DataBase.sign_up(name, password)
      test_sign_up(name, 'password2', false)
    end
  end

  describe 'login' do
    it 'authenticates a user with correct credentials' do
      DataBase.sign_up(name, password)
      test_login(name, password, true)
    end

    it 'fails to authenticate with incorrect name' do
      DataBase.sign_up(name, password)
      test_login(wrong_name, password, false)
    end

    it 'fails to authenticate with incorrect password' do
      DataBase.sign_up(name, password)
      test_login(name, wrong_password, false)
    end
  end

  describe 'verify_user_exist' do
    it 'returns true for existing user' do
      DataBase.sign_up(name, password)
      expect(DataBase.verify_user_exist(name)).to be true
    end

    it 'returns false for non-existing user' do
      expect(DataBase.verify_user_exist(wrong_name)).to be false
    end
  end

  describe 'hash_theuser_name' do
    it 'returns a hashed password' do
      hashed_password = DataBase.hash_theuser_name(name, password)
      expect(BCrypt::Password.new(hashed_password)).to eq(password)
    end
  end
end
