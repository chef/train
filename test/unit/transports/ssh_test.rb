# encoding: utf-8

require 'helper'
require 'train/transports/ssh'

describe 'ssh transport' do
  let(:cls) do
      plat = Train::Platforms.name('mock').in_family('linux')
      plat.add_platform_methods
      Train::Platforms::Detect.stubs(:scan).returns(plat)
      Train::Transports::SSH
  end
  let(:conf) {{
    host: rand.to_s,
    password: rand.to_s,
    key_files: rand.to_s,
  }}
  let(:cls_agent) { cls.new({ host: rand.to_s }) }

  describe 'default options' do
    let(:ssh) { cls.new({ host: 'dummy' }) }

    it 'can be instantiated (with valid config)' do
      ssh.wont_be_nil
    end

    it 'configures the host' do
      ssh.options[:host].must_equal 'dummy'
    end

    it 'has default port' do
      ssh.options[:port].must_equal 22
    end

    it 'has default user' do
      ssh.options[:user].must_equal 'root'
    end

    it 'by default does not request a pty' do
      ssh.options[:pty].must_equal false
    end
  end

  describe 'connection options' do
    let(:ssh) { cls.new({ host: 'dummy' }) }
    let(:connection_options) { ssh.send(:connection_options, {}) }

    it 'does not set a paranoid option - deprecated in net-ssh 4.2' do
      connection_options.key?(:paranoid).must_equal false
    end

    it 'sets a verify_host_key option, replacement for paranoid' do
      connection_options[:verify_host_key].must_equal false
    end
  end

  describe 'opening a connection' do
    let(:ssh) { cls.new(conf) }
    let(:connection) { ssh.connection }

    it 'provides a run_command_via_connection method' do
      methods = connection.class.instance_methods(false)
      methods.include?(:run_command_via_connection).must_equal true
    end

    it 'provides a file_via_connection method' do
      methods = connection.class.instance_methods(false)
      methods.include?(:file_via_connection).must_equal true
    end

    it 'gets the connection' do
      connection.must_be_kind_of Train::Transports::SSH::Connection
    end

    it 'provides a uri' do
      connection.uri.must_equal "ssh://root@#{conf[:host]}:22"
    end

    it 'must respond to wait_until_ready' do
      connection.must_respond_to :wait_until_ready
    end

    it 'can be closed' do
      connection.close.must_be_nil
    end

    it 'has a login command == ssh' do
      connection.login_command.command.must_equal 'ssh'
    end

    it 'has login command arguments' do
      connection.login_command.arguments.must_equal([
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "StrictHostKeyChecking=no",
        "-o", "IdentitiesOnly=yes",
        "-o", "LogLevel=VERBOSE",
        "-o", "ForwardAgent=no",
        "-i", conf[:key_files],
        "-p", "22",
        "root@#{conf[:host]}",
      ])
    end

    it 'sets the right auth_methods when password is specified' do
      conf[:key_files] = nil
      cls.new(conf).connection.method(:options).call[:auth_methods].must_equal ["none", "password", "keyboard-interactive"]
    end

    it 'sets the right auth_methods when keys are specified' do
      conf[:password] = nil
      cls.new(conf).connection.method(:options).call[:auth_methods].must_equal ["none", "publickey"]
    end

    it 'sets the right auth_methods for agent auth' do
      cls_agent.stubs(:ssh_known_identities).returns({:some => 'rsa_key'})
      cls_agent.connection.method(:options).call[:auth_methods].must_equal ['none', 'publickey']
    end

    it 'works with ssh agent auth' do
      cls_agent.stubs(:ssh_known_identities).returns({:some => 'rsa_key'})
      cls_agent.connection
    end
  end

  describe 'converting connection to string for logging' do
   it 'masks passwords' do
      assert_output(/.*:password=>"<hidden>".*/) do
        connection = cls.new(conf).connection
        puts "#{connection}"
      end
    end
  end

  describe 'failed configuration' do
    it 'works with a minimum valid config' do
      cls.new(conf).connection
    end

    it 'does not like host == nil' do
      conf.delete(:host)
      proc { cls.new(conf).connection }.must_raise Train::ClientError
    end

    it 'reverts to root on user == nil' do
      conf[:user] = nil
      cls.new(conf).connection.method(:options).call[:user] == 'root'
    end

    it 'does not like key and password == nil' do
      cls_agent.stubs(:ssh_known_identities).returns({})
      proc { cls_agent.connection }.must_raise Train::ClientError
    end

    it 'wont connect if it is not possible' do
      conf[:host] = 'localhost'
      conf[:port] = 1
      conn = cls.new(conf).connection
      proc { conn.run_command('uname') }.must_raise Train::Transports::SSHFailed
    end
  end
end
