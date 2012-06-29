class Entry < ActiveRecord::Base
  attr_accessible :name, :text

  searchable do
    text :name
    text :string
    string :state
  end
end
