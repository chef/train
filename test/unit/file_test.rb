require 'helper'
require 'train/transports/mock'

describe Train::File do
  let(:cls) { Train::File }
  let(:new_cls) { cls.new(nil, '/temp/file', false) }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ name: 'linux', family: 'unix' })
    backend
  }

  def mockup(stubs)
    Class.new(cls) do
      stubs.each do |k,v|
        define_method k.to_sym do
          v
        end
      end
    end.new(nil, nil, false)
  end

  it 'has the default type of unknown' do
    new_cls.type.must_equal :unknown
  end

  it 'calculates md5sum from content' do
    content = '5eb63bbbe01eeed093cb22bb8f5acdc3'
    backend.mock_command('md5sum /md5_checksum_path', content)
    cls.new(backend, '/md5_checksum_path').md5sum.must_equal content
  end

  it 'sets md5sum of nil content to nil' do
    content = nil
    backend.mock_command('md5sum /md5_checksum_path', content)
    assert_nil cls.new(backend, '/md5_checksum_path').md5sum
  end

  it 'calculates sha256sum from content' do
    content = 'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9'
    backend.mock_command('sha256sum /sha256sum_checksum_path', content)
    cls.new(backend, '/sha256sum_checksum_path').sha256sum.must_equal content
  end

  it 'sets sha256sum of nil content to nil' do
    content = nil
    backend.mock_command('sha256sum /sha256sum_checksum_path', content)
    assert_nil cls.new(backend, '/sha256sum_checksum_path').sha256sum
  end

  it 'throws Not implemented error for exist?' do
    # proc { Train.validate_backend({ host: rand }) }.must_raise Train::UserError
    proc { new_cls.exist?}.must_raise NotImplementedError
  end

  it 'throws Not implemented error for mode' do
    proc { new_cls.mode }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for owner' do
    proc { new_cls.owner }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for group' do
    proc { new_cls.group }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for uid' do
    proc { new_cls.uid }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for gid' do
    proc { new_cls.gid }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for content' do
    proc { new_cls.content }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for mtime' do
    proc { new_cls.mtime }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for size' do
    proc { new_cls.size }.must_raise NotImplementedError
  end

  it 'throws Not implemented error for selinux_label' do
    proc { new_cls.selinux_label }.must_raise NotImplementedError
  end

  it 'return path of file' do
    new_cls.path.must_equal('/temp/file')
  end

  it 'set product_version to nil' do
    new_cls.product_version.must_be_nil
  end  

  it 'set product_version to nil' do
    new_cls.file_version.must_be_nil
  end


  describe 'type' do
    it 'recognized type == file' do
      fc = mockup(type: :file)
      fc.file?.must_equal true
    end

    it 'recognized type == block_device' do
      fc = mockup(type: :block_device)
      fc.block_device?.must_equal true
    end

    it 'recognized type == character_device' do
      fc = mockup(type: :character_device)
      fc.character_device?.must_equal true
    end

    it 'recognized type == socket' do
      fc = mockup(type: :socket)
      fc.socket?.must_equal true
    end

    it 'recognized type == directory' do
      fc = mockup(type: :directory)
      fc.directory?.must_equal true
    end

    it 'recognized type == pipe' do
      fc = mockup(type: :pipe)
      fc.pipe?.must_equal true
    end

    it 'recognized type == symlink' do
      fc = mockup(type: :symlink)
      fc.symlink?.must_equal true
    end
  end

  describe 'version' do
    it 'recognized wrong version' do
      fc = mockup(product_version: rand, file_version: rand)
      fc.version?(rand).must_equal false
    end

    it 'recognized product_version' do
      x = rand
      fc = mockup(product_version: x, file_version: rand)
      fc.version?(x).must_equal true
    end

    it 'recognized file_version' do
      x = rand
      fc = mockup(product_version: rand, file_version: x)
      fc.version?(x).must_equal true
    end
  end
end  