require "helper"
require "train/transports/ssh"

describe "ssh transport" do
  let(:cls) do
    plat = Train::Platforms.name("mock").in_family("linux")
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    Train::Transports::SSH
  end

  let(:conf) do
    {
      host: rand.to_s,
      password: rand.to_s,
      key_files: rand.to_s,
      proxy_command: "ssh root@127.0.0.1 -W %h:%p",
    }
  end

  let(:cls_agent) { cls.new({ host: rand.to_s }) }

  describe "default options" do
    let(:ssh) { cls.new({ host: "dummy" }) }

    it "can be instantiated (with valid config)" do
      _(ssh).wont_be_nil
    end

    it "configures the host" do
      _(ssh.options[:host]).must_equal "dummy"
    end

    it "has default port" do
      _(ssh.options[:port]).must_equal 22
    end

    it "has default user" do
      _(ssh.options[:user]).must_equal "root"
    end

    it "by default does not request a pty" do
      _(ssh.options[:pty]).must_equal false
    end

    it "does not forward the ssh agent" do
      _(ssh.options[:forward_agent]).must_equal false
    end
  end

  describe "connection options" do
    let(:ssh) { cls.new({ host: "dummy" }) }
    let(:opts) { {} }
    let(:connection_options) { ssh.send(:connection_options, opts) }

    it "does not set a paranoid option - deprecated in net-ssh 4.2" do
      _(connection_options.key?(:paranoid)).must_equal false
    end

    it "set key_files to nil if its []" do
      opts = { key_files: [] }
      seen_opts = ssh.send(:connection_options, opts)
      assert_nil(seen_opts[:keys])
    end

    describe "various values are mapped appropriately for verify_host_key" do
      # This would be better:
      # Net::SSH::Version.stub_const(:CURRENT, Net::SSH::Version[5,0,1])
      current_version = Net::SSH::Version::CURRENT
      threshold_version = Net::SSH::Version[5, 0, 0]
      if current_version < threshold_version
        it "maps correctly when net-ssh < 5.0" do
          {
            "true" => true,
            "false" => false,
            nil => false,
          }.each do |given, expected|
            opts = { verify_host_key: given }
            seen_opts = ssh.send(:connection_options, opts)
            _(seen_opts[:verify_host_key]).must_equal expected
          end
        end
        it "defaults verify_host_key option to false" do
          _(connection_options[:verify_host_key]).must_equal false
        end
      else
        it "maps correctly when net-ssh > 5.0" do
          {
            "true" => :always,
            "false" => :never,
            true => :always,
            false => :never,
            "always" => :always,
            "never" => :never,
            nil => :never,
          }.each do |given, expected|
            opts = { verify_host_key: given }
            seen_opts = ssh.send(:connection_options, opts)
            _(seen_opts[:verify_host_key]).must_equal expected
          end
        end

        it "defaults verify_host_key option to :never" do
          _(connection_options[:verify_host_key]).must_equal :never
        end
      end
    end
  end

  describe "ssh options" do
    let(:ssh) { cls.new(conf) }
    let(:connection) { ssh.connection }
    it "includes BatchMode when :non_interactive is set" do
      conf[:non_interactive] = true
      _(connection.ssh_opts.include?("BatchMode=yes")).must_equal true
    end
    it "excludes BatchMode when :non_interactive is not set" do
      _(connection.ssh_opts.include?("BatchMode=yes")).must_equal false
    end

    it "includes IdentitiesOnly when keys are specified" do
      _(connection.ssh_opts.include?("IdentitiesOnly=yes")).must_equal true
    end
    it "excludes IdentitiesOnly when keys are empty" do
      conf[:key_files] = []
      _(connection.ssh_opts.include?("IdentitiesOnly=yes")).must_equal false
    end
    it "excludes IdentitiesOnly when keys are nil" do
      conf[:key_files] = nil
      _(connection.ssh_opts.include?("IdentitiesOnly=yes")).must_equal false
    end
  end

  describe "opening a connection" do
    let(:ssh) { cls.new(conf) }
    let(:connection) { ssh.connection }

    it "provides a run_command_via_connection method" do
      methods = connection.class.private_instance_methods(false)
      _(methods.include?(:run_command_via_connection)).must_equal true
    end

    it "provides a file_via_connection method" do
      methods = connection.class.private_instance_methods(false)
      _(methods.include?(:file_via_connection)).must_equal true
    end

    it "gets the connection" do
      _(connection).must_be_kind_of Train::Transports::SSH::Connection
    end

    it "provides a uri" do
      _(connection.uri).must_equal "ssh://root@#{conf[:host]}:22"
    end

    it "must respond to wait_until_ready" do
      _(connection).must_respond_to :wait_until_ready
    end

    it "can be closed" do
      _(connection.close).must_be_nil
    end

    it "has a login command == ssh" do
      _(connection.login_command.command).must_equal "ssh"
    end

    it "has login command arguments" do
      _(connection.login_command.arguments).must_equal([
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "StrictHostKeyChecking=no",
        "-o", "LogLevel=ERROR",
        "-o", "ForwardAgent=no",
        "-o", "IdentitiesOnly=yes",
        "-i", conf[:key_files],
        "-o", "ProxyCommand='ssh root@127.0.0.1 -W %h:%p'",
        "-p", "22",
        "root@#{conf[:host]}"
      ])
    end

    it "sets the right auth_methods when password is specified" do
      conf[:key_files] = nil
      _(cls.new(conf).connection.method(:options).call[:auth_methods]).must_equal %w{none password keyboard-interactive}
    end

    it "sets the right auth_methods when keys are specified" do
      conf[:password] = nil
      _(cls.new(conf).connection.method(:options).call[:auth_methods]).must_equal %w{none publickey}
    end

    it "sets the right auth_methods for agent auth" do
      cls_agent.stubs(:ssh_known_identities).returns({ some: "rsa_key" })
      _(cls_agent.connection.method(:options).call[:auth_methods]).must_equal %w{none publickey}
    end

    it "works with ssh agent auth" do
      cls_agent.stubs(:ssh_known_identities).returns({ some: "rsa_key" })
      cls_agent.connection
    end

    it "sets up a proxy when ssh proxy command is specified" do
      mock = MiniTest::Mock.new
      mock.expect(:call, true) do |hostname, username, options|
        options[:proxy].is_a?(Net::SSH::Proxy::Command) &&
          "ssh root@127.0.0.1 -W %h:%p" == options[:proxy].command_line_template
      end
      connection.stubs(:run_command)
      Net::SSH.stub(:start, mock) do
        connection.wait_until_ready
      end
      mock.verify
    end
  end

  describe "obscured_options" do
    it "masks passwords" do
      connection = cls.new(conf).connection

      assert_equal "<hidden>", connection.obscured_options[:password]
    end
  end

  describe "failed configuration" do
    it "works with a minimum valid config" do
      cls.new(conf).connection
    end

    it "does not like host == nil" do
      conf.delete(:host)
      _ { cls.new(conf).connection }.must_raise Train::ClientError
    end

    it "reverts to root on user == nil" do
      conf[:user] = nil
      cls.new(conf).connection.method(:options).call[:user] == "root"
    end

    it "does not like key and password == nil" do
      cls_agent.stubs(:ssh_known_identities).returns({})
      _ { cls_agent.connection }.must_raise Train::ClientError
    end

    it "wont connect if it is not possible" do
      conf[:connection_timeout] = 1
      conf[:connection_retries] = 1
      conf[:host] = "localhost"
      conf[:port] = 1
      conf.delete :proxy_command
      conn = cls.new(conf).connection
      _ { conn.run_command("uname") }.must_raise Train::Transports::SSHFailed
    end
  end
end

describe "ssh transport with bastion" do
  let(:cls) do
    plat = Train::Platforms.name("mock").in_family("linux")
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    Train::Transports::SSH
  end

  let(:conf) do
    {
   host: rand.to_s,
   password: rand.to_s,
   key_files: rand.to_s,
   bastion_host: "bastion_dummy",
    }
  end
  let(:cls_agent) { cls.new({ host: rand.to_s }) }

  describe "bastion" do
    describe "default options" do
      let(:ssh) { cls.new({ bastion_host: "bastion_dummy" }) }

      it "configures the host" do
        _(ssh.options[:bastion_host]).must_equal "bastion_dummy"
      end

      it "has default port" do
        _(ssh.options[:bastion_port]).must_equal 22
      end

      it "has default user" do
        _(ssh.options[:bastion_user]).must_equal "root"
      end
    end

    describe "opening a connection" do
      let(:ssh) { cls.new(conf) }
      let(:connection) { ssh.connection }

      it "provides a run_command_via_connection method" do
        methods = connection.class.private_instance_methods(false)
        _(methods.include?(:run_command_via_connection)).must_equal true
      end

      it "provides a file_via_connection method" do
        methods = connection.class.private_instance_methods(false)
        _(methods.include?(:file_via_connection)).must_equal true
      end

      it "gets the connection" do
        _(connection).must_be_kind_of Train::Transports::SSH::Connection
      end

      it "provides a uri" do
        _(connection.uri).must_equal "ssh://root@#{conf[:host]}:22"
      end

      it "must respond to wait_until_ready" do
        _(connection).must_respond_to :wait_until_ready
      end

      it "can be closed" do
        _(connection.close).must_be_nil
      end

      it "has a login command == ssh" do
        _(connection.login_command.command).must_equal "ssh"
      end

      make_my_diffs_pretty!

      it "has login command arguments" do
        _(connection.login_command.arguments).must_equal([
          "-o", "UserKnownHostsFile=/dev/null",
          "-o", "StrictHostKeyChecking=no",
          "-o", "LogLevel=ERROR",
          "-o", "ForwardAgent=no",
          "-o", "IdentitiesOnly=yes",
          "-i", conf[:key_files],
          "-o", "ProxyCommand='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR -o ForwardAgent=no -o IdentitiesOnly=yes -i #{conf[:key_files]} root@bastion_dummy -p 22 -W %h:%p'",
          "-p", "22",
          "root@#{conf[:host]}"
        ])
      end

      it "sets the right auth_methods when password is specified" do
        conf[:key_files] = nil
        _(cls.new(conf).connection.method(:options).call[:auth_methods]).must_equal %w{none password keyboard-interactive}
      end

      it "sets the right auth_methods when keys are specified" do
        conf[:password] = nil
        _(cls.new(conf).connection.method(:options).call[:auth_methods]).must_equal %w{none publickey}
      end

      it "sets the right auth_methods for agent auth" do
        cls_agent.stubs(:ssh_known_identities).returns({ some: "rsa_key" })
        _(cls_agent.connection.method(:options).call[:auth_methods]).must_equal %w{none publickey}
      end

      it "works with ssh agent auth" do
        cls_agent.stubs(:ssh_known_identities).returns({ some: "rsa_key" })
        cls_agent.connection
      end

      it "sets up a proxy when ssh proxy command is specified" do
        mock = MiniTest::Mock.new
        mock.expect(:call, true) do |hostname, username, options|
          options[:proxy].is_a?(Net::SSH::Proxy::Command) &&
            "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR -o ForwardAgent=no -o IdentitiesOnly=yes -i #{conf[:key_files]} root@bastion_dummy -p 22 -W %h:%p" == options[:proxy].command_line_template
        end
        connection.stubs(:run_command)
        Net::SSH.stub(:start, mock) do
          connection.wait_until_ready
        end
        mock.verify
      end
    end
  end
end

describe "ssh transport with bastion and proxy" do
  let(:cls) do
    plat = Train::Platforms.name("mock").in_family("linux")
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    Train::Transports::SSH
  end

  let(:conf) do
    {
   host: rand.to_s,
   password: rand.to_s,
   key_files: rand.to_s,
   bastion_host: "bastion_dummy",
   proxy_command: "dummy",
    }
  end
  let(:cls_agent) { cls.new({ host: rand.to_s }) }

  describe "bastion and proxy" do
    it "will throw an exception when both proxy_command and bastion_host is specified" do
      _ { cls.new(conf).connection }.must_raise Train::ClientError
    end
  end
end
