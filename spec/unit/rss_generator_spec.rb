# encoding: utf-8
require 'minitest/autorun'
require 'ostruct'
require 'fileutils'
require_relative '../../lib/feeder/rss_generator'

include Feeder

describe RSSGenerator do
  describe '#initialize' do
    it 'accepts an optional configuration argument' do
      RSSGenerator.new(configuration).configuration.must_equal configuration
    end
  end

  describe '#call' do
    it 'generates a RSS feed' do
      filepath = temporary_filepath
      touch(filepath)

      RSSGenerator.new(configuration).call
      File.unlink(filepath)
    end
  end

  describe '#add_item' do
    it 'adds an article to the feed' do
      article = OpenStruct.new(url: '', title: '', updated_at: Time.now)

      RSS::Maker.make('2.0') do |maker| 
        maker.channel.author = ''
        maker.channel.title = ''
        maker.channel.link = ''
        maker.channel.description = ''

        maker.items.must_be_empty
        RSSGenerator.new(configuration).add_item(maker, article)
        maker.items.wont_be_empty
      end
    end
  end

  describe '#articles' do
    it 'gets the collection of articles' do
      filepath = temporary_filepath
      touch(filepath)

      RSSGenerator.new(configuration).articles.wont_be_empty

      File.unlink(filepath)
      RSSGenerator.new(configuration).articles.must_be_empty
    end
  end

  def temporary_filepath
    File.join(File.dirname(__FILE__), '..', 'tmp', "foo_#{Time.now.to_f}")
  end

  def touch(filepath, title=nil)
    File.open(filepath, 'w') { |file|
      file << "<article><h1>#{title}</h1></article>"
    }
  end

  def configuration
    Configuration.new(
      "author"        => "Aldous Huxley",
      "title"         => "A Brave New Blog",
      "base_url"      => "http://www.abravenewblog.com",
      "base_path"     => "blog",
      "feed_path"     => "feed.rss",
      "description"   => "My description",
      "content_dir"   => "#{File.dirname(__FILE__)}/../tmp",
      "title_tag"     => "h1"
    )
  end
end # RSSGenerator

