module HasSearcher::Helpers

  protected

    def searcher
      @searcher ||= searcher_for(resource_instance_name)
    end

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
      rescue NameError
        return
      end
      searcher_clazz.new(params[searcher_name]) do | searcher |
        searcher_clazz.column_names.each do | column_name |
          searcher.send("#{column_name}=", params[column_name]) if searcher.send(column_name).blank?
        end
      end
   end

end
