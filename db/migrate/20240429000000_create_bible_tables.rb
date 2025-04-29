class CreateBibleTables < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.integer :number, null: false
      t.timestamps
    end

    add_index :books, :abbreviation, unique: true
    add_index :books, :number, unique: true

    create_table :chapters do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :number, null: false
      t.timestamps
    end

    add_index :chapters, [:book_id, :number], unique: true

    create_table :verses do |t|
      t.references :chapter, null: false, foreign_key: true
      t.integer :number, null: false
      t.text :text, null: false
      t.timestamps
    end

    add_index :verses, [:chapter_id, :number], unique: true
  end
end 