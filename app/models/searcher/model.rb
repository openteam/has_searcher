class Searcher::Model
  attr_accessor :methods, :searcher

  def initialize(searcher)
    self.searcher = searcher
    self.methods = Module.new
    self.extend self.methods
  end

  def attributes=(params=nil)
    params ||= {}
    params.each do |field, value|
      self.send "#{field}=", value if respond_to? "#{field}="
    end
  end

  def create_field(name, options)
    methods.class_eval do
      define_method name do
        instance_variable_get("@#{name}") ||
          (options[:default].call if options[:default] && options[:default].respond_to?(:call))
      end
      define_method "#{name}=" do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  end
end
