class Searcher::Model
  def attributes=(params={})
    params.each do |field, value|
      self.send "#{field}=", value
    end
  end
end
