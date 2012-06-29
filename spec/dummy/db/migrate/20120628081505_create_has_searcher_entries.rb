class CreateHasSearcherEntries < ActiveRecord::Migration
  def change
    create_table :has_searcher_entries do |t|
      t.string :name
      t.text :text

      t.timestamps
    end
  end
end
