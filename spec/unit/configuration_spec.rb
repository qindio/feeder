# encoding: utf-8
require 'minitest/autorun'
require_relative '../../lib/feeder/configuration'

include Feeder

describe Configuration do
  describe 'Configuration.parse' do
    it 'creates a configuration object from a configuration file in JSON' do
      filepath = temporary_filepath
      File.open(filepath, 'w') { |file| file << { "foo" => "bar" }.to_json }
      Configuration.parse(filepath).foo.must_equal 'bar'
      File.unlink(filepath)
    end
  end

  describe '#initialize' do
    it 'takes an optional hash with configuration options' do
      Configuration.new('foo' => 'bar').to_hash.fetch('foo').must_equal('bar')
    end
  end

  describe '#==' do
    it 'returns true if both objects have the same attributes' do
      (Configuration.new('foo' => 'bar') == Configuration.new('foo' => 'bar'))
        .must_equal true
    end
  end

  describe '#method_missing' do
    it 'will fetch a key from attributes with the name of the called method' do
      Configuration.new("foo" => "bar").foo.must_equal 'bar'
    end
    
    it 'will raise if key does not exist' do
      lambda { Configuration.new.non_existent }.must_raise NoMethodError
    end
  end

  describe '#respond_to?' do
    it 'returns true if the attributes include a key with the called method' do
      Configuration.new("foo" => "bar").respond_to?(:foo).must_equal true
    end

    it 'returns false otherwise' do
      Configuration.new.respond_to?(:foo).must_equal false
    end
  end

  def temporary_filepath
    File.join(File.dirname(__FILE__), '..', 'tmp', "foo_#{Time.now.to_f}")
  end
end # Configuration

