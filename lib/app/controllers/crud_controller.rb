# encoding: utf-8

class SearchController < ApplicationController
  inherit_resources

  helper_method :search_object_for

  protected

    def collection
      get_collection_ivar || set_collection_ivar(search_and_paginate_collection)
    end

    def search_and_paginate_collection
      if params[:utf8]
        search_object = search_object_for(resource_instance_name)
        search_object.pagination = paginate_options
        search_object.results
      else
        end_of_association_chain.paginate(paginate_options)
      end
    end

    def paginate_options(options={})
      {
        :page       => params[:page],
        :per_page   => per_page
      }.merge(options)
    end

    def per_page
      20
    end

    def render_new_button?
      respond_to? :new
    end

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

