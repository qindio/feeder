# encoding: utf-8
require 'json'

module Feeder
  class Configuration
    attr_reader :attributes
    alias_method :to_hash, :attributes

    def self.parse(configuration_path='./configuration.json')
      @configuration ||= new(JSON.parse(File.read(configuration_path)))
    end

    def initialize(attributes={})
      @attributes = attributes
      freeze
    end

    def ==(other)
      to_hash == other.to_hash
    end

    def method_missing(method, *args, &block)
      @attributes.fetch(method.to_s)
    rescue KeyError => exception
      raise(NoMethodError, method)
    end

    def respond_to?(method)
      @attributes.has_key?(method.to_s)
    end
  end # Configuration
end # Feeder

