require 'formtastic'

module Formtastic
  module Helpers
    module FormHelper
      def semantic_search_form_for(name, *args, &proc)
        options = args.extract_options!
        options.reverse_merge! :html => {:method => :get}
        url = params[:controller].sub(/\/\w+$/, '').split("/").map(&:underscore)
        options[:url] ||= url.push name.to_s.pluralize
        semantic_form_for searcher_for(name), *(args << options), &proc
      end
    end
  end

  class SemanticFormBuilder
    def search_button(options={})
      commit_button I18n.t('search'), options.merge(button_html:  {name: nil},
                                                    wrapper_html: {class: 'button'})
    end

    def default_input_type_with_text_as_string_on_search(method, options={})
      if object.is_a?(Search) && object.class.respond_to?(:has_enum?) && !object.class.has_enum?(method) && object.column_for_attribute(method).try(:type) == :text
        :string
      else
        default_input_type_without_text_as_string_on_search(method, options)
      end
    end

    alias_method_chain :default_input_type, :text_as_string_on_search

    def inputs_with_search(*args, &block)
      if args.empty? && object.is_a?(Search)
        args = object.class.column_names.collect do | column |
          if belongs_to? column
            column = column.gsub /_id$/, ''
          end
          column
        end.map(&:to_sym)
        args -= [:term, :order_by, :per_page]
      end
      inputs_without_search(*args, &block)
    end

    alias_method_chain :inputs, :search

    def buttons_with_search(*args, &block)
      args = :search if args.empty? && object.is_a?(Search)
      buttons_without_search(*args, &block)
    end

    alias_method_chain :buttons, :search

    protected

      def belongs_to?(method)
        method = method.to_s
        method =~ /_id$/ &&
          (reflect = object.class.reflect_on_association(method.gsub(/_id$/, '').to_sym)) &&
          reflect.macro == :belongs_to
      end
  end
end

