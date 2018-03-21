# encoding: utf-8

module Train::Platforms::Detect::Helpers
  module Windows
    def detect_windows
      res = @backend.run_command('cmd /c ver')
      return false if res.exit_status != 0 or res.stdout.empty?

      # if the ver contains `Windows`, we know its a Windows system
      version = res.stdout.strip
      return false unless version.downcase =~ /windows/
      @platform[:family] = 'windows'

      # try to extract release from eg. `Microsoft Windows [Version 6.3.9600]`
      release = /\[(?<name>.*)\]/.match(version)
      unless release[:name].nil?
        # release is 6.3.9600 now
        @platform[:release] = release[:name].downcase.gsub('version', '').strip
        # fallback, if we are not able to extract the name from wmic later
        @platform[:name] = "Windows #{@platform[:release]}"
      end

      # try to use wmic, but lets keep it optional
      read_wmic

      true
    end

    # reads os name and version from wmic
    # @see https://msdn.microsoft.com/en-us/library/bb742610.aspx#EEAA
    # Thanks to Matt Wrock (https://github.com/mwrock) for this hint
    def read_wmic
      res = @backend.run_command('wmic os get * /format:list')
      if res.exit_status == 0
        sys_info = {}
        res.stdout.lines.each { |line|
          m = /^\s*([^=]*?)\s*=\s*(.*?)\s*$/.match(line)
          sys_info[m[1].to_sym] = m[2] unless m.nil? || m[1].nil?
        }

        @platform[:release] = sys_info[:Version]
        # additional info on windows
        @platform[:build] = sys_info[:BuildNumber]
        @platform[:name] = sys_info[:Caption]
        @platform[:name] = @platform[:name].gsub('Microsoft', '').strip unless @platform[:name].empty?
        @platform[:arch] = read_wmic_cpu
      end
    end

    # `OSArchitecture` from `read_wmic` does not match a normal standard
    # For example, `x86_64` shows as `64-bit`
    def read_wmic_cpu
      res = @backend.run_command('wmic cpu get architecture /format:list')
      if res.exit_status == 0
        sys_info = {}
        res.stdout.lines.each { |line|
          m = /^\s*([^=]*?)\s*=\s*(.*?)\s*$/.match(line)
          sys_info[m[1].to_sym] = m[2] unless m.nil? || m[1].nil?
        }
      end

      # This converts `wmic os get architecture` output to a normal standard
      # https://msdn.microsoft.com/en-us/library/aa394373(VS.85).aspx
      arch_map = {
        0 => 'i386',
        1 => 'mips',
        2 => 'alpha',
        3 => 'powerpc',
        5 => 'arm',
        6 => 'ia64',
        9 => 'x86_64',
      }

      # The value of `wmic cpu get architecture` is always a number between 0-9
      arch_number = sys_info[:Architecture].to_i
      arch_map[arch_number]
    end

    # This method scans the target os for a unique uuid to use
    def windows_uuid
      uuid = windows_uuid_from_chef
      uuid = windows_uuid_from_machine_file if uuid.nil?
      uuid = windows_uuid_from_wmic if uuid.nil?
      uuid = windows_uuid_from_registry if uuid.nil?
      uuid = windows_write_uuid if uuid.nil?
      uuid
    end

    def windows_uuid_from_machine_file
      %W(
        #{ENV['SYSTEMDRIVE']}\\chef\\chef_guid
        #{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}\\.chef\\chef_guid
        #{ENV['SYSTEMROOT']}\\machine-uuid
        #{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}\\.system\\machine-uuid
      ).each do |path|
        file = @backend.file(path)
        return file.content.chomp if file.exist? && !file.size.zero?
      end
      nil
    end

    def windows_uuid_from_chef
      file = @backend.file("#{ENV['SYSTEMDRIVE']}\\chef\\cache\\data_collector_metadata.json")
      return if !file.exist? || file.size.zero?
      json = JSON.parse(file.content)
      json['node_uuid'] if json['node_uuid']
    end

    def windows_uuid_from_wmic
      result = @backend.run_command('wmic csproduct get UUID')
      return unless result.exit_status.zero?
      result.stdout.split("\r\n")[-1].strip
    end

    def windows_uuid_from_registry
      cmd = '(Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid")."MachineGuid"'
      result = @backend.run_command(cmd)
      return unless result.exit_status.zero?
      result.stdout.chomp
    end

    def windows_write_uuid
      uuid = SecureRandom.uuid
      result = @backend.run_command("'#{uuid}' | Out-File -encoding ASCII #{ENV['SYSTEMROOT']}\\machine-uuid")
      unless result.exit_status.zero?
        # fallback to user location
        local_uuid_path = "#{ENV['HOMEDRIVE']}#{ENV['HOMEPATH']}\\.system\\machine-uuid"
        warn "Cannot write uuid to `#{ENV['SYSTEMROOT']}\\machine-uuid`, falling back to `#{local_uuid_path}` instead."
        result = @backend.run_command("new-item -force -path #{local_uuid_path} -value '#{uuid}' -type file")
        raise "Cannot write uuid to `#{local_uuid_path}\\machine-uuid`." unless result.exit_status.zero?
      end
      uuid
    end
  end
end
