class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end
  
  def self.create_table 
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table 
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end
  
  def save 
    if !self.id 
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)   
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first 
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.create(row)
    dog = Dog.new(name: row[:name], breed: row[:breed])
  end
end