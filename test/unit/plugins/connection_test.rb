# encoding: utf-8
require 'helper'

describe 'v1 Connection Plugin' do
  describe 'empty v1 connection plugin' do
    let(:cls) { Train::Plugins::Transport::BaseConnection }
    let(:connection) { cls.new({}) }

    it 'provides a close method' do
      connection.close # wont raise
    end

    it 'raises an exception for run_command' do
      proc { connection.run_command('') }.must_raise NotImplementedError
    end

    it 'raises an exception for run_command_via_connection' do
      proc { connection.run_command_via_connection('') }.must_raise NotImplementedError
    end

    it 'raises an exception for os method' do
      proc { connection.os }.must_raise NotImplementedError
    end

    it 'raises an exception for file method' do
      proc { connection.file('') }.must_raise NotImplementedError
    end

    it 'raises an exception for file_via_connection method' do
      proc { connection.file_via_connection('') }.must_raise NotImplementedError
    end

    it 'raises an exception for login command method' do
      proc { connection.login_command }.must_raise NotImplementedError
    end

    it 'can wait until ready' do
      connection.wait_until_ready # wont raise
    end

    it 'provides a default logger' do
      connection.method(:logger).call
                .must_be_instance_of(Logger)
    end

    it 'must use the user-provided logger' do
      l = rand
      cls.new({logger: l})
         .method(:logger).call.must_equal(l)
    end

    describe 'create cache connection' do
      it 'default connection cache settings' do
        connection.cache_enabled?(:file).must_equal true
        connection.cache_enabled?(:command).must_equal false
      end
    end

    describe 'disable/enable caching' do
      it 'disable file cache via connection' do
        connection.disable_cache(:file)
        connection.cache_enabled?(:file).must_equal false
      end

      it 'enable command cache via cache_connection' do
        connection.enable_cache(:command)
        connection.cache_enabled?(:command).must_equal true
      end
    end

    describe 'cache enable check' do
      it 'returns true when cache is enabled' do
        cache_enabled = connection.instance_variable_get(:@cache_enabled)
        cache_enabled[:test] = true
        connection.cache_enabled?(:test).must_equal true
      end

      it 'returns false when cache is disabled' do
        cache_enabled = connection.instance_variable_get(:@cache_enabled)
        cache_enabled[:test] = false
        connection.cache_enabled?(:test).must_equal false
      end
    end

    describe 'clear cache' do
      it 'clear file cache' do
        cache = connection.instance_variable_get(:@cache)
        cache[:file]['/tmp'] = 'test'
        connection.send(:clear_cache, :file)
        cache = connection.instance_variable_get(:@cache)
        cache[:file].must_equal({})
      end
    end

    describe 'load file' do
      it 'with caching' do
        connection.enable_cache(:file)
        connection.expects(:file_via_connection).once.returns('test_file')
        connection.file('/tmp/test').must_equal('test_file')
        connection.file('/tmp/test').must_equal('test_file')
        assert = { '/tmp/test' => 'test_file' }
        cache = connection.instance_variable_get(:@cache)
        cache[:file].must_equal(assert)
      end

      it 'without caching' do
        connection.disable_cache(:file)
        connection.expects(:file_via_connection).twice.returns('test_file')
        connection.file('/tmp/test').must_equal('test_file')
        connection.file('/tmp/test').must_equal('test_file')
        cache = connection.instance_variable_get(:@cache)
        cache[:file].must_equal({})
      end
    end

    describe 'run command' do
      it 'with caching' do
        connection.enable_cache(:command)
        connection.expects(:run_command_via_connection).once.returns('test_user')
        connection.run_command('whoami').must_equal('test_user')
        connection.run_command('whoami').must_equal('test_user')
        assert = { 'whoami' => 'test_user' }
        cache = connection.instance_variable_get(:@cache)
        cache[:command].must_equal(assert)
      end

      it 'without caching' do
        connection.disable_cache(:command)
        connection.expects(:run_command_via_connection).twice.returns('test_user')
        connection.run_command('whoami').must_equal('test_user')
        connection.run_command('whoami').must_equal('test_user')
        cache = connection.instance_variable_get(:@cache)
        cache[:command].must_equal({})
      end
    end
  end
end
