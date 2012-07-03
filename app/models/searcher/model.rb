class Searcher::Model
  attr_accessor :methods

  def initialize
    self.methods = Module.new
    self.extend self.methods
  end

  def attributes=(params={})
    params.each do |field, value|
      self.send "#{field}=", value
    end
  end

  def create_field(name)
    methods.class_eval do
      define_method "#{name}" do
        instance_variable_get("@#{name}")
      end
      define_method "#{name}=" do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  end
end
