module HasSearcher

end

class ActionController::Base
  def self.has_searcher
    HasSearcher::Base.has_searcher(self)
  end
end

require 'has_searcher/formtastic' rescue nil
