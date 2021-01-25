require 'pry'

class Dog
    attr_accessor :name, :breed, :id
    

    def initialize(id: nil, name: name, breed: breed)
        #OR initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        query =<<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL
        DB[:conn].execute(query)
    end

    def self.drop_table
        query =<<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(query)
    end

    def self.new_from_db(row)
        # binding.pry
        new_dog = Dog.new
        new_dog.id = row[0]
        new_dog.name = row[1]
        new_dog.breed = row[2]
        new_dog
    end

    def self.find_by_name(name)
        query = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        doghunt = DB[:conn].execute(query, name).flatten
        id, name, breed = doghunt
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        query = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        doghunt = DB[:conn].execute(query, id).flatten
        id, name, breed = doghunt
        self.new(id: id, name: name, breed: breed)
    end

    def update
        query =<<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(query, self.name, self.breed, self.id)
    end

    def save
        if self.id
            self.update
        else
            query=<<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL
            DB[:conn].execute(query, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:) ##attr_accessor :id
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end    
            ##???
    def self.find_or_create_by(name:, breed:)
        
        query = <<-SQL
        SELECT * FROM dogs 
        WHERE name = ? AND breed = ?
        LIMIT 1
        SQL
        dog = DB[:conn].execute(query, name, breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else             ###^^^^
            dog = self.create(name: name, breed: breed)
        end
        dog
    end
end
    # query =<<-SQL
    # SELECT * FROM dogs
    # SQL
