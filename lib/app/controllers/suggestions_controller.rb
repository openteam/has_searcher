class SuggestionsController < CrudController

  def index
    render :text => suggestions.to_json
  end


  protected

    def suggestions
      collection.map do | suggest |
        { :id => suggest.id, :value => suggest.term }
      end
    end

    def resource_instance_name
      @resource_instance_name ||= params.delete(:model)
    end


end
