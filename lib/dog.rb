require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

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
        new_dog = Dog.new
        new_dog.id = row[0]
        new_dog.name = row[1]
        new_dog.breed = row[2]
        new_dog
    end

    def find_by_name(name)
        query = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        doghunt = DB[:conn].execute(query, name).flatten
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

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end    
end
    # query =<<-SQL
    # SELECT * FROM dogs
    # SQL
