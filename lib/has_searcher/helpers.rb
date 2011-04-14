module HasSearcher::Helpers

  protected

    def searcher_for(name)
      instance_variable_get("@#{searcher_name(name)}") ||
          instance_variable_set("@#{searcher_name(name)}", create_searcher(searcher_name(name)))
    end

  private

    def searcher_name(name)
      "#{name}_search"
    end

    def create_searcher(searcher_name)
      begin
        searcher_clazz = searcher_name.classify.constantize
        searcher_clazz.new(params[searcher_name]) do | searcher |
          searcher_clazz.column_names.each do | column_name |
            searcher[column_name] ||= params[column_name]
          end
        end
      rescue NameError
      end
    end

end
