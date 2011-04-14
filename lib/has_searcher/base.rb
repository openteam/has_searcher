class HasSearcher::Base < ::ApplicationController
  def self.has_searcher(base)
    base.class_eval do
      include HasSearcher::Helpers
      helper_method :searcher_for
    end

  end
  has_searcher(self)
end
