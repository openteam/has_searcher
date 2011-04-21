class Search < ActiveRecord::Base

  attr_accessor :pagination

  class << self
    def columns
      @columns ||= [];
    end

    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
        sql_type.to_s, null)
    end
  end

  delegate :results, :to => :search

  def result_ids
    search.hits.map(&:primary_key)
  end

  protected

    def search
      klass.search do | search |
        search.keywords keywords if search_columns.delete("keywords")
        search_columns.each do | column |
          if column_for_attribute(column).type == :text
            search.keywords normalize(column), :fields => column
          else
            search.with column, normalize(column)
          end
        end
        search.paginate pagination if pagination.try(:any?)
      end
    end

    def save(validate = true)
      validate ? valid? : true
    end

    def search_columns
      @search_columns ||= self.class.column_names.select{ |column| normalize(column).present? }
    end

    def normalize(column)
      if respond_to?("normalize_#{column}")
        send "normalize_#{column}"
      elsif self.class.serialized_attributes[column] == Array
        [*self.send("#{column}_before_type_cast")].select(&:present?)
      elsif column_for_attribute(column).type == :integer
        self[column].try(:zero?) ? nil : self[column]
      elsif column_for_attribute(column).type == :text && column =~ /term$/
        normalize_term_column(self[column])
      else
        self[column]
      end
    end

    def normalize_term_column(text)
      text.gsub(/[^[:alnum:]]+/, ' ') if text
    end

    def klass
      self.class.model_name.classify.gsub(/Search$/, '').constantize
    end

end
