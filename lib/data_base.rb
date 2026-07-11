# frozen_string_literal: true

require 'sqlite3'
require 'bcrypt'

class DataBase
  def self.db(data_file = nil)
    data_file = File.expand_path('../spec/data_base/data.db', __dir__) if data_file.nil?
    @db ||= begin
      connection = SQLite3::Database.open(data_file)
      connection.execute <<-SQL
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER NOT NULL PRIMARY KEY,
          name TEXT UNIQUE NOT NULL,
          password_digest TEXT NOT NULL,
          token TEXT
        )
      SQL
      connection
    end
  end

  def self.close_db
    @db&.close
    @db = nil
  end

  def self.sign_up(name, password)
    if verify_user_exist(name)
      puts "User '#{name}' already exists."
      return false
    end

    digest = hash_password(password)
    token_user = SecureRandom.hex(16)
    db.execute('INSERT INTO users (name, password_digest,token) VALUES (?, ?, ?)', [name, digest, token_user])
    true
  end

  def self.take_the_user_token(name)
    row = db.get_first_row('SELECT token FROM users WHERE name = ?', [name])
    return nil if row.nil?

    row[0]
  end

  def self.login(name, password)
    row = db.get_first_row('SELECT password_digest FROM users WHERE name = ?', [name])
    return false if row.nil?

    stored_digest = row[0]
    BCrypt::Password.new(stored_digest) == password
  end

  def self.hash_password(password)
    BCrypt::Password.create(password)
  end

  def self.verify_user_exist(name, _password = nil)
    result = db.get_first_row('SELECT id FROM users WHERE name = ?', [name])
    !result.nil?
  end
end
