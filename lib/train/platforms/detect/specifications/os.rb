# encoding: utf-8

# rubocop:disable Style/ParenthesesAroundCondition
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity

module Train::Platforms::Detect::Specifications
  class OS
    def self.plat
      Train::Platforms
    end

    def self.load
      # master family
      plat.family("os").detect { true }

      load_windows
      load_unix
      load_other
    end

    def self.load_windows
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
    end

    def self.load_unix
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

      load_linux
      load_other_unix
      load_bsd
    end

    def self.load_linux
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

      register_lsb("ubuntu", "Ubuntu Linux", "debian", /ubuntu/i)

      register_lsb("linuxmint", "LinuxMint", "debian", /linuxmint/i)

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
            json_cmd('FastCli -p 15 -c "show version | json"')
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

      register_lsb("scientific", "Scientific Linux", "redhat", /scientific/i)

      register_lsb("xenserver", "Xenserer Linux", "redhat", /xenserver/i)

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

      register_lsb_or_content("amazon", "Amazon Linux", "redhat", "/etc/system-release", /amazon/i)
      register_lsb_or_content("cloudlinux", "CloudLinux", "redhat", "/etc/redhat-release", /cloudlinux/i)

      # keep redhat at the end as a fallback for anything with a redhat-release
      register_lsb_or_content("redhat", "Red Hat Linux", "redhat", "/etc/redhat-release", /redhat/i, /./)

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

      register_os_or_file("opensuse", "OpenSUSE Linux", "suse",
                          "/etc/SuSE-release", /^opensuse/i)
      register_os_or_file("suse",     "Suse Linux",     "suse",
                          "/etc/SuSE-release", /^sles/i, /suse/i)

      register_path_and_uname("arch", "Arch Linux", "linux", "/etc/arch-release")

      register_file_content("slackware", "Slackware Linux", "linux", "/etc/slackware-version")

      register_file_content("gentoo", "Gentoo Linux", "linux", "/etc/gentoo-release")

      register_path_and_uname("exherbo", "Exherbo Linux", "linux", "/etc/exherbo-release")

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

      plat.family("yocto").in_family("linux")
        .detect do
          # /etc/issue isn't specific to yocto, but it's the only way to detect
          # the platform because there are no other identifying files
          issue = unix_file_contents("/etc/issue")

          issue && issue.match?(/Poky|balenaOS/)
        end

      plat.name("yocto").title("Yocto Project Linux").in_family("yocto")
        .detect do
          issue = unix_file_contents("/etc/issue")
          if issue.match?("Poky")
            # assuming the Poky version is preferred over the /etc/version build
            @platform[:release] = issue[/\d+(\.\d+)+/]
            true
          end
        end

      plat.name("balenaos").title("balenaOS Linux").in_family("yocto")
        .detect do
          # balenaOS does have the /etc/os-release file
          issue = unix_file_contents("/etc/issue")
          if issue.match?("balenaOS") && linux_os_release["NAME"] =~ /balenaos/i
            @platform[:release] = linux_os_release["META_BALENA_VERSION"]
            true
          end
        end

      # brocade family detected here if device responds to 'uname' command,
      # happens when logging in as root
      plat.family("brocade").title("Brocade Family").in_family("linux")
        .detect do
          !brocade_version.nil?
        end

      # generic linux
      # this should always be last in the linux family list
      plat.name("linux").title("Generic Linux").in_family("linux")
        .detect do
          true
        end
    end

    def self.register_path(name, title, family, path, regexp)
      plat.name(name).title(title).in_family(family)
        .detect do
          rel = unix_file_contents(path)
          if m = regexp.match(rel)
            @platform[:release] = m[1]
            true
          end
        end
    end

    def self.load_other_unix
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

      def self.register_path_regexp(name, title, family, path, regexp)
        plat.name(name).title(title).in_family(family)
          .detect do
            regexp =~ unix_file_contents(path)
          end
      end

      # TODO: these regexps are probably needlessly wasteful
      register_path_regexp("smartos", "SmartOS", "solaris", "/etc/release", /^.*(SmartOS).*$/)

      register_path("omnios", "Omnios", "solaris", "/etc/release", /^\s*OmniOS.*r(\d+).*$/)
      register_path("openindiana", "Openindiana", "solaris", "/etc/release", /^\s*OpenIndiana.*oi_(\d+).*$/)

      register_path("opensolaris", "Open Solaris", "solaris", "/etc/release", /^\s*OpenSolaris.*snv_(\d+).*$/)

      # TODO: these regexps are probably needlessly wasteful
      register_path_regexp("nexentacore", "Nexentacore", "solaris", "/etc/release", /^\s*(NexentaCore)\s.*$/)

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
    end

    def self.load_bsd
      # bsd family
      plat.family("bsd").in_family("unix")
        .detect do
          # we need a better way to determine this family
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

      register_bsd("freebsd", "Freebsd", "bsd", /freebsd/i)
      register_bsd("openbsd", "Openbsd", "bsd", /openbsd/i)
      register_bsd("netbsd", "Netbsd", "bsd", /netbsd/i)
    end

    def self.load_other
      # arista_eos family
      plat.family("arista_eos").title("Arista EOS Family").in_family("os")
        .detect do
          true
        end
      plat.name("arista_eos").title("Arista EOS").in_family("arista_eos")
        .detect do
          json_cmd("show version | json")
        end

      # esx
      plat.family("esx").title("ESXi Family").in_family("os")
        .detect do
          true if unix_uname_s =~ /vmkernel/i
        end
      plat.name("vmkernel").in_family("esx")
        .detect do
          set_from_uname
        end

      # cisco_ios family
      plat.family("cisco").title("Cisco Family").in_family("os")
        .detect do
          !cisco_show_version.nil?
        end

      register_cisco("cisco_ios", "Cisco IOS", "cisco", :cisco_show_version, "ios")
      register_cisco("cisco_ios_xe", "Cisco IOS XE", "cisco", :cisco_show_version, "ios-xe")
      register_cisco("cisco_nexus", "Cisco Nexus", "cisco", :cisco_show_version, "nexus", "show version | include Processor")

      # brocade family
      plat.family("brocade").title("Brocade Family").in_family("os")
        .detect do
          !brocade_version.nil?
        end

      register_cisco("brocade_fos", "Brocade FOS", "brocade", :brocade_version, "fos")
    end

    ######################################################################
    # Helpers (keep these sorted)

    def self.register_bsd(name, title, family, regexp)
      plat.name(name).title(title).in_family(family)
        .detect do
          set_from_uname if unix_uname_s =~ regexp
        end
    end

    def self.register_cisco(name, title, family, detect, type, uuid = nil)
      plat.name(name).title(title).in_family(family)
        .detect do
          v = send(detect)

          next unless v[:type] == type

          @platform[:release] = v[:version]
          @platform[:arch] = nil
          @platform[:uuid_command] = uuid if uuid
          true
        end
    end

    def self.register_file_content(name, title, family, path)
      plat.name(name).title(title).in_family(family)
        .detect do
          if (raw = unix_file_contents(path))
            @platform[:release] = raw.scan(/[\d.]+/).join
            true
          end
        end
    end

    def self.register_path_and_uname(name, title, family, path)
      plat.name(name).title(title).in_family(family)
        .detect do
          if unix_file_contents(path) # TODO: this is unused and dumb.
            # Because this is a rolling release distribution,
            # use the kernel release, ex. 4.1.6-1-ARCH
            @platform[:release] = unix_uname_r
            true
          end
        end
    end

    def self.register_lsb(name, title, family, regexp)
      register_lsb_or_content(name, title, family, nil, regexp)
    end

    def self.register_lsb_or_content(name, title, family, path, regexp1, regexp2 = regexp1)
      plat.name(name).title(title).in_family(family)
        .detect do
          lsb = read_linux_lsb
          if lsb && lsb[:id] =~ regexp1
            @platform[:release] = lsb[:release]
            true
          elsif path && (raw = unix_file_contents(path)) =~ regexp2
            @platform[:name] = redhatish_platform(raw)
            @platform[:release] = redhatish_version(raw)
            true
          end
        end
    end

    def self.register_os_or_file(name, title, family, path, regexp1, regexp2 = regexp1)
      plat.name(name).title(title).in_family(family)
        .detect do
          rel = linux_os_release
          (rel && rel["NAME"] =~ regexp1) ||
            unix_file_contents(path) =~ regexp2
        end
    end

    def self.register_path(name, title, family, path, regexp)
      plat.name(name).title(title).in_family(family)
        .detect do
          rel = unix_file_contents(path)
          if (m = regexp.match(rel))
            @platform[:release] = m[1]
            true
          end
        end
    end
  end
end
