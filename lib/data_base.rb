# frozen_string_literal: true

require 'sqlite3'
require 'bcrypt'

class DataBase

  def self.db(data_file = nil)
    if data_file.nil?
      data_file = File.expand_path('../spec/data_base/data.db', __dir__)
    end
    @db ||= begin
      connection = SQLite3::Database.open(data_file)
      connection.execute <<-SQL
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER NOT NULL PRIMARY KEY,
          name TEXT UNIQUE NOT NULL,
          password_digest TEXT NOT NULL
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
    db.execute('INSERT INTO users (name, password_digest) VALUES (?, ?)', [name, digest])
    true
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

# if __FILE__ == $0
#   DataBase.sign_up("alice", "s3cret-pass")

#   puts DataBase.login("alice", "s3cret-pass")   # => true
#   puts DataBase.login("alice", "wrong-pass")    # => false
#   puts DataBase.verify_user_exist("alice")      # => true
#   puts DataBase.verify_user_exist("bob")        # => false

#   DataBase.close_db
# end