# encoding: utf-8
require 'minitest/autorun'
require_relative '../../lib/feeder/article'

include Feeder

describe Article do
  describe 'Article.all' do
    it 'returns a collection of articles' do
      filepath = temporary_filepath
      touch(filepath)

      Article.all(configuration).wont_be_empty

      File.unlink(filepath)
      Article.all(configuration).must_be_empty
    end

    it 'does not include dotfiles or dot-directories' do
      Article.all(configuration).map(&:path).select { |path|
        File.basename(path) =~ Article::DOTFILE_RE
      }.must_be_empty
    end
  end

  describe '#initialize' do
    it 'requires a path to the article' do
      lambda { Article.new }.must_raise ArgumentError
    end

    it 'requires a path that actually exists on disk' do
      lambda { Article.new('/foo/bar', configuration) }
        .must_raise ArgumentError
    end
  end

  describe '#path' do
    it 'returns the path to the article as initialized' do
      filepath = temporary_filepath
      touch(filepath)

      Article.new(filepath, configuration).path.must_equal filepath

      File.unlink(filepath)
    end
  end
  
  describe '#configuration' do
    it 'returns the path to the article as initialized' do
      configuration = { foo: 'bar' }
      filepath = temporary_filepath
      touch(filepath)

      Article.new(filepath, configuration).configuration
        .must_equal configuration

      File.unlink(filepath)
    end
  end

  describe '#url' do
    it 'returns the url for the article' do
      filepath = temporary_filepath
      touch(filepath)

      url = Article.new(filepath, configuration).url
      url.must_match /#{configuration.base_url}/
      url.must_match /#{configuration.base_path}/
      url.must_match /#{File.basename(filepath)}/
      
      File.unlink(filepath)
    end
  end

  describe '#title' do
    it "returns the title from the article's contents" do
      title     = 'Sample Title'
      filepath = temporary_filepath
      touch(filepath, title)

      Article.new(filepath, configuration).title.must_equal title
      File.unlink(filepath)
    end
  end

  describe '#updated_at' do
    it "returns the last change date based on the file's mtime" do
      filepath = temporary_filepath
      touch(filepath)

      Article.new(filepath, configuration).updated_at
        .must_equal File.mtime(filepath)
      File.unlink(filepath)
    end
  end

  def touch(filepath, title=nil)
    File.open(filepath, 'w') { |file|
      file << "<article><h1>#{title}</h1></article>"
    }
  end

  def temporary_filepath
    File.join(File.dirname(__FILE__), '..', 'tmp', "foo_#{Time.now.to_f}")
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
end # Article
