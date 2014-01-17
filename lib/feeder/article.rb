# encoding: utf-8
require 'nokogiri'
require_relative './configuration'

module Feeder
  class Article
    PATH_ERROR  = 'Path must exist on filesystem'
    DOTFILE_RE  = /\A\..*\Z/

    attr_reader :path, :configuration

    def self.all(configuration=Configuration.parse)
      content_dir = configuration.content_dir
      Dir.open(content_dir).entries
        .reject { |entry| entry =~ DOTFILE_RE }
        .map    { |entry| new(File.join(content_dir, entry), configuration) }
    end

    def initialize(path, configuration=Configuration.parse)
      raise(ArgumentError, PATH_ERROR) unless File.exists?(path)

      @path = path
      @configuration = configuration
    end

    def url
      [
        configuration.base_url,
        configuration.base_path,
        File.basename(path)
      ].join('/')
    end

    def title(title_tag=configuration.title_tag)
      Nokogiri::HTML.fragment(File.read(path))
        .css(title_tag).first.content
    end

    def updated_at
      File.mtime(path)
    end
  end # Article
end # Feeder

