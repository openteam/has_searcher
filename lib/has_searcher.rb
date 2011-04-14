module HasSearcher
  autoload :Base,               'has_searcher/base'
  autoload :Helpers,            'has_searcher/helpers'
end

class ActionController::Base
  def self.has_searcher
    HasSearcher::Base.has_searcher(self)
  end
end

require 'has_searcher/formtastic' rescue nil

%w{ models controllers }.each do |dir|
    path = File.join(File.dirname(__FILE__), 'app', dir)
    $LOAD_PATH << path
    ActiveSupport::Dependencies.autoload_paths << path
    ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end
