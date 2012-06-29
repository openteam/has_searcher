Rails.application.routes.draw do

  mount HasSearcher::Engine => "/has_searcher"
end
