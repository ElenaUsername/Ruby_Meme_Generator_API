require "sqlite3"
require "bcrypt"

class DataBase
  DB_FILE = File.expand_path("../spec/data_base/data.db", __dir__)

  def self.setup_db
    db = SQLite3::Database.open(DB_FILE)
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        password_digest TEXT NOT NULL
      )
    SQL
    db.close
  end

  def self.sign_up(name, password)
    setup_db

    if verify_user_exist(name)
      puts "User '#{name}' already exists."
      return false
    end

    digest = hash_theuser_name(name, password)

    db = SQLite3::Database.open(DB_FILE)
    db.execute("INSERT INTO users (name, password_digest) VALUES (?, ?)", [name, digest])
    db.close

    true
  end

  def self.login(name, password)
    setup_db
    db = SQLite3::Database.open(DB_FILE)
    row = db.get_first_row("SELECT password_digest FROM users WHERE name = ?", [name])
    db.close

    return false if row.nil?

    stored_digest = row[0]
    BCrypt::Password.new(stored_digest) == password
  end

  def self.hash_theuser_name(name, password)
    BCrypt::Password.create(password)
  end

  def self.verify_user_exist(name, password = nil)
    setup_db
    db = SQLite3::Database.open(DB_FILE)
    result = db.get_first_row("SELECT id FROM users WHERE name = ?", [name])
    db.close
    !result.nil?
  end
end

if __FILE__ == $0
  DataBase.sign_up("alice", "s3cret-pass")

  puts DataBase.login("alice", "s3cret-pass")   # => true
  puts DataBase.login("alice", "wrong-pass")    # => false
  puts DataBase.verify_user_exist("alice")      # => true
  puts DataBase.verify_user_exist("bob")        # => false
end