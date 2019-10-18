require "helper"
require "train/transports/local"
require "train/file/remote/qnx"
require "train/transports/mock"

describe Train::File::Remote::Qnx do
  let(:cls) { Train::File::Remote::Qnx }
  let(:backend) do
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: "qnx" })
    backend
  end

  it "returns file contents when the file exists" do
    out = rand.to_s
    backend.mock_command("cat path", out)
    file = cls.new(backend, "path")
    file.stubs(:exist?).returns(true)
    _(file.content).must_equal out
  end

  it "returns nil contents when the file does not exist" do
    file = cls.new(backend, "path")
    file.stubs(:exist?).returns(false)
    _(file.content).must_be_nil
  end

  it "returns a file type" do
    backend.mock_command("file path", "blah directory blah")
    _(cls.new(backend, "path").type).must_equal :directory
  end

  it "returns a directory type" do
    backend.mock_command("file path", "blah regular file blah")
    _(cls.new(backend, "path").type).must_equal :file
  end

  it "raises exception for unimplemented methods" do
    file = cls.new(backend, "path")
    %w{mode owner group uid gid mtime size selinux_label link_path mounted stat}.each do |m|
      _ { file.send(m) }.must_raise NotImplementedError
    end
  end

  describe "#md5sum" do
    let(:md5_checksum) { "17404a596cbd0d1e6c7d23fcd845ab82" }

    let(:ruby_md5_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns("")
      checksum_mock.expects(:hexdigest).returns(md5_checksum)
      checksum_mock
    end

    it "defaults to a Ruby based checksum if other methods fail" do
      backend.mock_command("md5sum /tmp/testfile", "", "", 1)
      Digest::MD5.expects(:new).returns(ruby_md5_mock)
      _(cls.new(backend, "/tmp/testfile").md5sum).must_equal md5_checksum
    end
  end

  describe "#sha256sum" do
    let(:sha256_checksum) do
      "ec864fe99b539704b8872ac591067ef22d836a8d942087f2dba274b301ebe6e5"
    end

    let(:ruby_sha256_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns("")
      checksum_mock.expects(:hexdigest).returns(sha256_checksum)
      checksum_mock
    end

    it "defaults to a Ruby based checksum if other methods fail" do
      backend.mock_command("sha256sum /tmp/testfile", "", "", 1)
      Digest::SHA256.expects(:new).returns(ruby_sha256_mock)
      _(cls.new(backend, "/tmp/testfile").sha256sum).must_equal sha256_checksum
    end
  end
end
