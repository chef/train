# encoding: utf-8

# rubocop:disable Style/Next
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity

module Train::Platforms::Detect::Specifications
  class OS
    def self.load
      plat = Train::Platforms

      # master family
      plat.family("os").detect { true }

      plat.family("windows").in_family("os")
        .detect do
            # Can't return from a `proc` thus the `is_windows` shenanigans
          is_windows = false
          is_windows = true if winrm?

          if @backend.class.to_s == "Train::Transports::Local::Connection"
            is_windows = true if ruby_host_os(/mswin|mingw32|windows/)
          end

            # Try to detect windows even for ssh transport
          if !is_windows && detect_windows == true
            is_windows = true
          end

          is_windows
        end
      # windows platform
      plat.name("windows").in_family("windows")
        .detect do
          true if detect_windows == true
        end

      # unix master family
      plat.family("unix").in_family("os")
        .detect do
            # we want to catch a special case here where cisco commands
            # don't return an exit status and still print to stdout
          if unix_uname_s =~ /./ && !unix_uname_s.start_with?("Line has invalid autocommand ") && !unix_uname_s.start_with?("The command you have entered")
            @platform[:arch] = unix_uname_m
            true
          end
        end

      # linux master family
      plat.family("linux").in_family("unix")
        .detect do
          true if unix_uname_s =~ /linux/i
        end

      # debian family
      plat.family("debian").in_family("linux")
        .detect do
          true unless unix_file_contents("/etc/debian_version").nil?
        end
      plat.name("ubuntu").title("Ubuntu Linux").in_family("debian")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /ubuntu/i
            @platform[:release] = lsb[:release]
            true
          end
        end
      plat.name("linuxmint").title("LinuxMint").in_family("debian")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /linuxmint/i
            @platform[:release] = lsb[:release]
            true
          end
        end
      plat.name("raspbian").title("Raspbian Linux").in_family("debian")
        .detect do
          if (linux_os_release && linux_os_release["NAME"] =~ /raspbian/i) || \
              unix_file_exist?("/usr/bin/raspi-config")
            @platform[:release] = unix_file_contents("/etc/debian_version").chomp
            true
          end
        end
      plat.name("debian").title("Debian Linux").in_family("debian")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /debian/i
            @platform[:release] = lsb[:release]
            true
          end

            # if we get this far we have to be some type of debian
          @platform[:release] = unix_file_contents("/etc/debian_version").chomp
          true
        end

      # fedora family
      plat.family("fedora").in_family("linux")
        .detect do
          true if linux_os_release && linux_os_release["NAME"] =~ /fedora/i
        end
      plat.name("fedora").title("Fedora").in_family("fedora")
        .detect do
          @platform[:release] = linux_os_release["VERSION_ID"]
          true
        end

      # arista_eos family
      # this checks for the arista bash shell
      # must come before redhat as it uses fedora under the hood
      plat.family("arista_eos").title("Arista EOS Family").in_family("linux")
        .detect do
          true
        end
      plat.name("arista_eos_bash").title("Arista EOS Bash Shell").in_family("arista_eos")
        .detect do
          if unix_file_exist?("/usr/bin/FastCli")
            cmd = @backend.run_command('FastCli -p 15 -c "show version | json"')
            if cmd.exit_status == 0 && !cmd.stdout.empty?
              require "json"
              begin
                eos_ver = JSON.parse(cmd.stdout)
                @platform[:release] = eos_ver["version"]
                @platform[:arch] = eos_ver["architecture"]
                true
              rescue JSON::ParserError
                nil
              end
            end
          end
        end

      # redhat family
      plat.family("redhat").in_family("linux")
        .detect do
            # I am not sure this returns true for all redhats in this family
            # for now we are going to just try each platform
            # return true unless unix_file_contents('/etc/redhat-release').nil?

          true
        end
      plat.name("centos").title("Centos Linux").in_family("redhat")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /centos/i
            @platform[:release] = lsb[:release]
            true
          elsif linux_os_release && linux_os_release["NAME"] =~ /centos/i
            @platform[:release] = redhatish_version(unix_file_contents("/etc/redhat-release"))
            true
          end
        end
      plat.name("oracle").title("Oracle Linux").in_family("redhat")
        .detect do
          if !(raw = unix_file_contents("/etc/oracle-release")).nil?
            @platform[:release] = redhatish_version(raw)
            true
          elsif !(raw = unix_file_contents("/etc/enterprise-release")).nil?
            @platform[:release] = redhatish_version(raw)
            true
          end
        end
      plat.name("scientific").title("Scientific Linux").in_family("redhat")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /scientific/i
            @platform[:release] = lsb[:release]
            true
          end
        end
      plat.name("xenserver").title("Xenserer Linux").in_family("redhat")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /xenserver/i
            @platform[:release] = lsb[:release]
            true
          end
        end
      plat.name("parallels-release").title("Parallels Linux").in_family("redhat")
        .detect do
          unless (raw = unix_file_contents("/etc/parallels-release")).nil?
            @platform[:name] = redhatish_platform(raw)
            @platform[:release] = raw[/(\d\.\d\.\d)/, 1]
            true
          end
        end
      plat.name("wrlinux").title("Wind River Linux").in_family("redhat")
        .detect do
          if linux_os_release && linux_os_release["ID_LIKE"] =~ /wrlinux/i
            @platform[:release] = linux_os_release["VERSION"]
            true
          end
        end
      plat.name("amazon").title("Amazon Linux").in_family("redhat")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /amazon/i
            @platform[:release] = lsb[:release]
            true
          elsif (raw = unix_file_contents("/etc/system-release")) =~ /amazon/i
            @platform[:name] = redhatish_platform(raw)
            @platform[:release] = redhatish_version(raw)
            true
          end
        end
      plat.name("cloudlinux").title("CloudLinux").in_family("redhat")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /cloudlinux/i
            @platform[:release] = lsb[:release]
            true
          elsif (raw = unix_file_contents("/etc/redhat-release")) =~ /cloudlinux/i
            @platform[:name] = redhatish_platform(raw)
            @platform[:release] = redhatish_version(raw)
            true
          end
        end
      # keep redhat at the end as a fallback for anything with a redhat-release
      plat.name("redhat").title("Red Hat Linux").in_family("redhat")
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ /redhat/i
            @platform[:release] = lsb[:release]
            true
          elsif !(raw = unix_file_contents("/etc/redhat-release")).nil?
            # must be some type of redhat
            @platform[:name] = redhatish_platform(raw)
            @platform[:release] = redhatish_version(raw)
            true
          end
        end

      # suse family
      plat.family("suse").in_family("linux")
        .detect do
          if linux_os_release && linux_os_release["ID_LIKE"] =~ /suse/i
            @platform[:release] = linux_os_release["VERSION"]
            true
          elsif !(suse = unix_file_contents("/etc/SuSE-release")).nil?
            # https://rubular.com/r/UKaYWolCYFMfp1
            version = suse.scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join(".")
            # https://rubular.com/r/b5PN3hZDxa5amV
            version = suse[/VERSION\s?=\s?"?([\d\.]{2,})"?/, 1] if version == ""
            @platform[:release] = version
            true
          end
        end
      plat.name("opensuse").title("OpenSUSE Linux").in_family("suse")
        .detect do
          true if (linux_os_release && linux_os_release["NAME"] =~ /^opensuse/i) ||
            unix_file_contents("/etc/SuSE-release") =~ /^opensuse/i
        end
      plat.name("suse").title("Suse Linux").in_family("suse")
        .detect do
          true if (linux_os_release && linux_os_release["NAME"] =~ /^sles/i) ||
            unix_file_contents("/etc/SuSE-release") =~ /suse/i
        end

      # arch
      plat.name("arch").title("Arch Linux").in_family("linux")
        .detect do
          unless unix_file_contents("/etc/arch-release").nil?
            # Because this is a rolling release distribution,
            # use the kernel release, ex. 4.1.6-1-ARCH
            @platform[:release] = unix_uname_r
            true
          end
        end

      # slackware
      plat.name("slackware").title("Slackware Linux").in_family("linux")
        .detect do
          unless (raw = unix_file_contents("/etc/slackware-version")).nil?
            @platform[:release] = raw.scan(/(\d+|\.+)/).join
            true
          end
        end

      # gentoo
      plat.name("gentoo").title("Gentoo Linux").in_family("linux")
        .detect do
          unless (raw = unix_file_contents("/etc/gentoo-release")).nil?
            @platform[:release] = raw.scan(/(\d+|\.+)/).join
            true
          end
        end

      # exherbo
      plat.name("exherbo").title("Exherbo Linux").in_family("linux")
        .detect do
          unless unix_file_contents("/etc/exherbo-release").nil?
            # Because this is a rolling release distribution,
            # use the kernel release, ex. 4.1.6
            @platform[:release] = unix_uname_r
            true
          end
        end

      # alpine
      plat.name("alpine").title("Alpine Linux").in_family("linux")
        .detect do
          unless (raw = unix_file_contents("/etc/alpine-release")).nil?
            @platform[:release] = raw.strip
            true
          end
        end

      # coreos
      plat.name("coreos").title("CoreOS Linux").in_family("linux")
        .detect do
          unless unix_file_contents("/etc/coreos/update.conf").nil?
            lsb = read_linux_lsb
            @platform[:release] = lsb[:release]
            true
          end
        end

      # brocade family detected here if device responds to 'uname' command,
      # happens when logging in as root
      plat.family("brocade").title("Brocade Family").in_family("linux")
        .detect do
          !brocade_version.nil?
        end

      # genaric linux
      # this should always be last in the linux family list
      plat.name("linux").title("Genaric Linux").in_family("linux")
        .detect do
          true
        end

      # openvms
      plat.name("openvms").title("OpenVMS").in_family("unix")
        .detect do
          if unix_uname_s =~ /unrecognized command verb/i
            cmd = @backend.run_command("show system/noprocess")
            unless cmd.exit_status != 0 || cmd.stdout.empty?
              @platform[:name] = cmd.stdout.downcase.split(" ")[0]
              cmd = @backend.run_command('write sys$output f$getsyi("VERSION")')
              @platform[:release] = cmd.stdout.downcase.split("\n")[1][1..-1]
              cmd = @backend.run_command('write sys$output f$getsyi("ARCH_NAME")')
              @platform[:arch] = cmd.stdout.downcase.split("\n")[1]
              true
            end
          end
        end

      # aix
      plat.family("aix").in_family("unix")
        .detect do
          true if unix_uname_s =~ /aix/i
        end
      plat.name("aix").title("Aix").in_family("aix")
        .detect do
          out = @backend.run_command("uname -rvp").stdout
          m = out.match(/(\d+)\s+(\d+)\s+(.*)/)
          unless m.nil?
            @platform[:release] = "#{m[2]}.#{m[1]}"
            @platform[:arch] = m[3].to_s
          end
          true
        end

      # solaris family
      plat.family("solaris").in_family("unix")
        .detect do
          if unix_uname_s =~ /sunos/i
            unless (version = /^5\.(?<release>\d+)$/.match(unix_uname_r)).nil?
              @platform[:release] = version["release"]
            end

            arch = @backend.run_command("uname -p")
            @platform[:arch] = arch.stdout.chomp if arch.exit_status == 0
            true
          end
        end
      plat.name("smartos").title("SmartOS").in_family("solaris")
        .detect do
          rel = unix_file_contents("/etc/release")
          if /^.*(SmartOS).*$/ =~ rel
            true
          end
        end
      plat.name("omnios").title("Omnios").in_family("solaris")
        .detect do
          rel = unix_file_contents("/etc/release")
          unless (m = /^\s*(OmniOS).*r(\d+).*$/.match(rel)).nil?
            @platform[:release] = m[2]
            true
          end
        end
      plat.name("openindiana").title("Openindiana").in_family("solaris")
        .detect do
          rel = unix_file_contents("/etc/release")
          unless (m = /^\s*(OpenIndiana).*oi_(\d+).*$/.match(rel)).nil?
            @platform[:release] = m[2]
            true
          end
        end
      plat.name("opensolaris").title("Open Solaris").in_family("solaris")
        .detect do
          rel = unix_file_contents("/etc/release")
          unless (m = /^\s*(OpenSolaris).*snv_(\d+).*$/.match(rel)).nil?
            @platform[:release] = m[2]
            true
          end
        end
      plat.name("nexentacore").title("Nexentacore").in_family("solaris")
        .detect do
          rel = unix_file_contents("/etc/release")
          if /^\s*(NexentaCore)\s.*$/ =~ rel
            true
          end
        end
      plat.name("solaris").title("Solaris").in_family("solaris")
        .detect do
          rel = unix_file_contents("/etc/release")
          if !(m = /Oracle Solaris (\d+)/.match(rel)).nil?
            # TODO: should be string!
            @platform[:release] = m[1]
            true
          elsif /^\s*(Solaris)\s.*$/ =~ rel
            true
          end

            # must be some unknown solaris
          true
        end

      # hpux
      plat.family("hpux").in_family("unix")
        .detect do
          true if unix_uname_s =~ /hp-ux/i
        end
      plat.name("hpux").title("Hpux").in_family("hpux")
        .detect do
          @platform[:release] = unix_uname_r.lines[0].chomp
          true
        end

      # qnx
      plat.family("qnx").in_family("unix")
        .detect do
          true if unix_uname_s =~ /qnx/i
        end
      plat.name("qnx").title("QNX").in_family("qnx")
        .detect do
          @platform[:name] = unix_uname_s.lines[0].chomp.downcase
          @platform[:release] = unix_uname_r.lines[0].chomp
          @platform[:arch] = unix_uname_m
          true
        end

      # bsd family
      plat.family("bsd").in_family("unix")
        .detect do
            # we need a better way to determin this family
            # for now we are going to just try each platform
          true
        end
      plat.family("darwin").in_family("bsd")
        .detect do
          if unix_uname_s =~ /darwin/i
            cmd = unix_file_contents("/usr/bin/sw_vers")
            unless cmd.nil?
              m = cmd.match(/^ProductVersion:\s+(.+)$/)
              @platform[:release] = m.nil? ? nil : m[1]
              m = cmd.match(/^BuildVersion:\s+(.+)$/)
              @platform[:build] = m.nil? ? nil : m[1]
            end
            @platform[:release] = unix_uname_r.lines[0].chomp if @platform[:release].nil?
            @platform[:arch] = unix_uname_m
            true
          end
        end
      plat.name("mac_os_x").title("macOS X").in_family("darwin")
        .detect do
          cmd = unix_file_contents("/System/Library/CoreServices/SystemVersion.plist")
          @platform[:uuid_command] = "system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }'"
          true if cmd =~ /Mac OS X/i
        end
      plat.name("darwin").title("Darwin").in_family("darwin")
        .detect do
            # must be some other type of darwin
          @platform[:name] = unix_uname_s.lines[0].chomp
          true
        end
      plat.name("freebsd").title("Freebsd").in_family("bsd")
        .detect do
          if unix_uname_s =~ /freebsd/i
            @platform[:name] = unix_uname_s.lines[0].chomp
            @platform[:release] = unix_uname_r.lines[0].chomp
            true
          end
        end
      plat.name("openbsd").title("Openbsd").in_family("bsd")
        .detect do
          if unix_uname_s =~ /openbsd/i
            @platform[:name] = unix_uname_s.lines[0].chomp
            @platform[:release] = unix_uname_r.lines[0].chomp
            true
          end
        end
      plat.name("netbsd").title("Netbsd").in_family("bsd")
        .detect do
          if unix_uname_s =~ /netbsd/i
            @platform[:name] = unix_uname_s.lines[0].chomp
            @platform[:release] = unix_uname_r.lines[0].chomp
            true
          end
        end

      # arista_eos family
      plat.family("arista_eos").title("Arista EOS Family").in_family("os")
        .detect do
          true
        end
      plat.name("arista_eos").title("Arista EOS").in_family("arista_eos")
        .detect do
          cmd = @backend.run_command("show version | json")
          if cmd.exit_status == 0 && !cmd.stdout.empty?
            require "json"
            begin
              eos_ver = JSON.parse(cmd.stdout)
              @platform[:release] = eos_ver["version"]
              @platform[:arch] = eos_ver["architecture"]
              true
            rescue JSON::ParserError
              nil
            end
          end
        end

      # esx
      plat.family("esx").title("ESXi Family").in_family("os")
        .detect do
          true if unix_uname_s =~ /vmkernel/i
        end
      plat.name("vmkernel").in_family("esx")
        .detect do
          @platform[:name] = unix_uname_s.lines[0].chomp
          @platform[:release] = unix_uname_r.lines[0].chomp
          true
        end

      # cisco_ios family
      plat.family("cisco").title("Cisco Family").in_family("os")
        .detect do
          !cisco_show_version.nil?
        end
      plat.name("cisco_ios").title("Cisco IOS").in_family("cisco")
        .detect do
          v = cisco_show_version
          next unless v[:type] == "ios"

          @platform[:release] = v[:version]
          @platform[:arch] = nil
          true
        end
      plat.name("cisco_ios_xe").title("Cisco IOS XE").in_family("cisco")
        .detect do
          v = cisco_show_version
          next unless v[:type] == "ios-xe"

          @platform[:release] = v[:version]
          @platform[:arch] = nil
          true
        end
      plat.name("cisco_nexus").title("Cisco Nexus").in_family("cisco")
        .detect do
          v = cisco_show_version
          next unless v[:type] == "nexus"

          @platform[:release] = v[:version]
          @platform[:arch] = nil
          @platform[:uuid_command] = "show version | include Processor"
          true
        end
      plat.name("cisco_asa").title("Cisco ASA OS").in_family("cisco")
        .detect do
          v = cisco_show_version
          next unless v[:type] == "asa"

          @platform[:release] = v[:version]
          @platform[:arch] = nil
          true
        end

      # brocade family
      plat.family("brocade").title("Brocade Family").in_family("os")
        .detect do
          !brocade_version.nil?
        end

      plat.name("brocade_fos").title("Brocade FOS").in_family("brocade")
        .detect do
          v = brocade_version
          next unless v[:type] == "fos"

          @platform[:release] = v[:version]
          @platform[:arch] = nil
          true
        end
    end
  end
end
