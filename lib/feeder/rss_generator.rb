# encoding: utf-8
require 'rss'
require_relative 'configuration'
require_relative 'article'

module Feeder
  class RSSGenerator
    RSS_VERSION = '2.0'
    attr_reader :configuration

    def initialize(configuration=Configuration.parse)
      @configuration = configuration
    end

    def call
      RSS::Maker.make(RSS_VERSION) do |maker|
        maker.channel.author      = configuration.author
        maker.channel.title       = configuration.title
        maker.channel.updated     = Time.now.to_s
        maker.channel.about       = [
                                      configuration.base_url,
                                      configuration.feed_path
                                    ].join('/')
        maker.channel.description = configuration.description
        maker.channel.link        = configuration.base_url

        articles.each { |article| add_item(maker, article) }
      end
    end

    def add_item(maker, article)
      maker.items.new_item do |item|
        item.link     = article.url
        item.title    = article.title
        item.updated  = article.updated_at
      end
    end

    def articles
      Article.all(configuration)
    end
  end # RSSGenerator
end # Feeder

