class Entry < ActiveRecord::Base
  attr_accessible :name, :text

  searchable do
    text :name
    text :string
    string :state
    date :published_at
    string :categories, :multiple => true
    string :entry_id_str
  end
end
