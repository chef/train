# Change Log

## [0.22.1](https://github.com/chef/train/tree/0.22.1) (2017-01-17)
[Full Changelog](https://github.com/chef/train/compare/v0.22.0...0.22.1)

**Merged pull requests:**

- Relax net-ssh dep to allow 4.0 [\#168](https://github.com/chef/train/pull/168) ([tduffield](https://github.com/tduffield))
- Fix Oracle Linux detection [\#167](https://github.com/chef/train/pull/167) ([carldjohnston](https://github.com/carldjohnston))
- Add support for parallels & virtuozzo linux [\#166](https://github.com/chef/train/pull/166) ([jaxxstorm](https://github.com/jaxxstorm))

## [v0.22.0](https://github.com/chef/train/tree/v0.22.0) (2016-11-29)
[Full Changelog](https://github.com/chef/train/compare/v0.21.1...v0.22.0)

**Implemented enhancements:**

- Try to use ssh agent if no password or key files have been specified [\#165](https://github.com/chef/train/pull/165) ([alexpop](https://github.com/alexpop))

**Merged pull requests:**

- Add openvms detection [\#159](https://github.com/chef/train/pull/159) ([briandoodyie](https://github.com/briandoodyie))

## [v0.21.1](https://github.com/chef/train/tree/v0.21.1) (2016-11-04)
[Full Changelog](https://github.com/chef/train/compare/v0.21.0...v0.21.1)

**Closed issues:**

- detect\_arista\_eos raises exception against unix host [\#160](https://github.com/chef/train/issues/160)

**Merged pull requests:**

- ensure the os detection works in pty mode [\#161](https://github.com/chef/train/pull/161) ([chris-rock](https://github.com/chris-rock))

## [v0.21.0](https://github.com/chef/train/tree/v0.21.0) (2016-11-04)
[Full Changelog](https://github.com/chef/train/compare/v0.20.1...v0.21.0)

**Implemented enhancements:**

- Train doesn't create a login shell [\#148](https://github.com/chef/train/issues/148)

**Merged pull requests:**

- Add detection for Arista EOS [\#158](https://github.com/chef/train/pull/158) ([jerearista](https://github.com/jerearista))

## [v0.20.1](https://github.com/chef/train/tree/v0.20.1) (2016-10-15)
[Full Changelog](https://github.com/chef/train/compare/v0.20.0...v0.20.1)

**Fixed bugs:**

- support empty URIs [\#154](https://github.com/chef/train/pull/154) ([arlimus](https://github.com/arlimus))

## [v0.20.0](https://github.com/chef/train/tree/v0.20.0) (2016-09-21)
[Full Changelog](https://github.com/chef/train/compare/v0.19.1...v0.20.0)

**Fixed bugs:**

- get `Preparing modules for first use.` when I use train on Windows [\#153](https://github.com/chef/train/issues/153)

**Merged pull requests:**

- `Preparing modules for first use.` error message on Windows [\#152](https://github.com/chef/train/pull/152) ([chris-rock](https://github.com/chris-rock))
- Convert `wmic` architecture to a normal standard [\#151](https://github.com/chef/train/pull/151) ([jerryaldrichiii](https://github.com/jerryaldrichiii))
- Login shell [\#149](https://github.com/chef/train/pull/149) ([jonathanmorley](https://github.com/jonathanmorley))

## [v0.19.1](https://github.com/chef/train/tree/v0.19.1) (2016-09-16)
[Full Changelog](https://github.com/chef/train/compare/v0.19.0...v0.19.1)

**Implemented enhancements:**

- hostname property for WinRM::Connection [\#128](https://github.com/chef/train/issues/128)
- Return hostname from WinRM::Connection same as SSH::Connection [\#150](https://github.com/chef/train/pull/150) ([alexpop](https://github.com/alexpop))

## [v0.19.0](https://github.com/chef/train/tree/v0.19.0) (2016-09-05)
[Full Changelog](https://github.com/chef/train/compare/v0.18.0...v0.19.0)

**Fixed bugs:**

- use stat -c for alpine linux [\#146](https://github.com/chef/train/pull/146) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- support ruby 2.2.1 [\#145](https://github.com/chef/train/pull/145) ([chris-rock](https://github.com/chris-rock))
- Use winrm v2 implementation [\#122](https://github.com/chef/train/pull/122) ([mwrock](https://github.com/mwrock))

## [v0.18.0](https://github.com/chef/train/tree/v0.18.0) (2016-08-26)
[Full Changelog](https://github.com/chef/train/compare/v0.17.0...v0.18.0)

**Merged pull requests:**

- Allow JSON 2.0 on Ruby 2.2 and above [\#144](https://github.com/chef/train/pull/144) ([jkeiser](https://github.com/jkeiser))
- Enable Ruby 2.3 in Travis, make it default suite [\#143](https://github.com/chef/train/pull/143) ([jkeiser](https://github.com/jkeiser))
- Add the darwin platform family [\#141](https://github.com/chef/train/pull/141) ([tas50](https://github.com/tas50))
- update integration test dependencies [\#139](https://github.com/chef/train/pull/139) ([tas50](https://github.com/tas50))
- Add badges to the readme [\#138](https://github.com/chef/train/pull/138) ([tas50](https://github.com/tas50))
- use --decode on base64 command to maintain compatibility with Darwin. [\#137](https://github.com/chef/train/pull/137) ([thomascate](https://github.com/thomascate))

## [v0.17.0](https://github.com/chef/train/tree/v0.17.0) (2016-08-19)
[Full Changelog](https://github.com/chef/train/compare/v0.16.0...v0.17.0)

**Implemented enhancements:**

- return owner for files on windows [\#132](https://github.com/chef/train/pull/132) ([chris-rock](https://github.com/chris-rock))

**Closed issues:**

- prefix powershell commands with `$ProgressPreference = "SilentlyContinue"` [\#134](https://github.com/chef/train/issues/134)

**Merged pull requests:**

- CI improvements [\#133](https://github.com/chef/train/pull/133) ([chris-rock](https://github.com/chris-rock))
- Rescue EPIPE on connect in ssh transport [\#130](https://github.com/chef/train/pull/130) ([stevendanna](https://github.com/stevendanna))

## [v0.16.0](https://github.com/chef/train/tree/v0.16.0) (2016-08-08)
[Full Changelog](https://github.com/chef/train/compare/v0.15.1...v0.16.0)

**Merged pull requests:**

- provide file\_version and product\_version for windows files [\#127](https://github.com/chef/train/pull/127) ([chris-rock](https://github.com/chris-rock))
- Bring train platform data more in line with ohai's platform data [\#126](https://github.com/chef/train/pull/126) ([stevendanna](https://github.com/stevendanna))

## [v0.15.1](https://github.com/chef/train/tree/v0.15.1) (2016-07-11)
[Full Changelog](https://github.com/chef/train/compare/v0.15.0...v0.15.1)

**Fixed bugs:**

- bugfix: higher mode bits on local connection [\#125](https://github.com/chef/train/pull/125) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- Test ruby 2.1 instead of 1.9.3 and only launch one test group per travis/appveyor [\#123](https://github.com/chef/train/pull/123) ([mwrock](https://github.com/mwrock))

## [v0.15.0](https://github.com/chef/train/tree/v0.15.0) (2016-07-01)
[Full Changelog](https://github.com/chef/train/compare/v0.14.2...v0.15.0)

**Implemented enhancements:**

- have net-ssh request a pty [\#60](https://github.com/chef/train/issues/60)

**Merged pull requests:**

- Allow requesting a PTY [\#121](https://github.com/chef/train/pull/121) ([srenatus](https://github.com/srenatus))

## [v0.14.2](https://github.com/chef/train/tree/v0.14.2) (2016-06-28)
[Full Changelog](https://github.com/chef/train/compare/v0.14.1...v0.14.2)

**Merged pull requests:**

- do not log password in ssh connection output [\#120](https://github.com/chef/train/pull/120) ([marcparadise](https://github.com/marcparadise))

## [v0.14.1](https://github.com/chef/train/tree/v0.14.1) (2016-06-27)
[Full Changelog](https://github.com/chef/train/compare/v0.14.0...v0.14.1)

**Fixed bugs:**

- bugfix: add mock backend initialization [\#119](https://github.com/chef/train/pull/119) ([arlimus](https://github.com/arlimus))

## [v0.14.0](https://github.com/chef/train/tree/v0.14.0) (2016-06-27)
[Full Changelog](https://github.com/chef/train/compare/v0.13.1...v0.14.0)

**Implemented enhancements:**

- json in and out for base connection [\#118](https://github.com/chef/train/pull/118) ([arlimus](https://github.com/arlimus))
- ESX support [\#116](https://github.com/chef/train/pull/116) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

**Fixed bugs:**

- sporadic appveyor failure on `winrm delete ...` [\#105](https://github.com/chef/train/issues/105)
- bugfix: run frozen string commands via ssh [\#117](https://github.com/chef/train/pull/117) ([arlimus](https://github.com/arlimus))

## [v0.13.1](https://github.com/chef/train/tree/v0.13.1) (2016-06-16)
[Full Changelog](https://github.com/chef/train/compare/v0.13.0...v0.13.1)

**Implemented enhancements:**

- use train as gem name. Thanks @halo [\#115](https://github.com/chef/train/pull/115) ([chris-rock](https://github.com/chris-rock))

## [v0.13.0](https://github.com/chef/train/tree/v0.13.0) (2016-06-16)
[Full Changelog](https://github.com/chef/train/compare/v0.12.1...v0.13.0)

**Implemented enhancements:**

- provide uri-formatted information on all connections [\#113](https://github.com/chef/train/pull/113) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- Authentication with SSH Server on OSX is failing [\#111](https://github.com/chef/train/issues/111)

**Merged pull requests:**

- adding support for vmware's esx server [\#114](https://github.com/chef/train/pull/114) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))
- add missing keyboard-interactive authentication method [\#112](https://github.com/chef/train/pull/112) ([chris-rock](https://github.com/chris-rock))

## [v0.12.1](https://github.com/chef/train/tree/v0.12.1) (2016-05-23)
[Full Changelog](https://github.com/chef/train/compare/v0.12.0...v0.12.1)

**Fixed bugs:**

-  loosen restriction for docker api [\#109](https://github.com/chef/train/pull/109) ([chris-rock](https://github.com/chris-rock))

**Closed issues:**

- docker-api conflict when using docker cookbook [\#108](https://github.com/chef/train/issues/108)

## [v0.12.0](https://github.com/chef/train/tree/v0.12.0) (2016-05-16)
[Full Changelog](https://github.com/chef/train/compare/v0.11.4...v0.12.0)

**Merged pull requests:**

- Custom sudo command [\#107](https://github.com/chef/train/pull/107) ([jeremymv2](https://github.com/jeremymv2))

## [v0.11.4](https://github.com/chef/train/tree/v0.11.4) (2016-05-13)
[Full Changelog](https://github.com/chef/train/compare/v0.11.3...v0.11.4)

**Fixed bugs:**

- mount resource incorrect matching [\#103](https://github.com/chef/train/issues/103)
- Add a space to avoid matching partial paths [\#104](https://github.com/chef/train/pull/104) ([alexpop](https://github.com/alexpop))
- Update README.md [\#102](https://github.com/chef/train/pull/102) ([mcquin](https://github.com/mcquin))

**Merged pull requests:**

- 0.11.4 [\#106](https://github.com/chef/train/pull/106) ([arlimus](https://github.com/arlimus))

## [v0.11.3](https://github.com/chef/train/tree/v0.11.3) (2016-05-10)
[Full Changelog](https://github.com/chef/train/compare/v0.11.2...v0.11.3)

**Fixed bugs:**

- appveyor fixing... [\#98](https://github.com/chef/train/pull/98) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- fix: winrm https listener is not configured anymore in appveyor [\#100](https://github.com/chef/train/pull/100) ([chris-rock](https://github.com/chris-rock))
- use aix stats implementation for hpux as well [\#99](https://github.com/chef/train/pull/99) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

## [v0.11.2](https://github.com/chef/train/tree/v0.11.2) (2016-04-29)
[Full Changelog](https://github.com/chef/train/compare/v0.11.1...v0.11.2)

**Fixed bugs:**

- bugfix: windows file failed to initialize with new symlink handler [\#96](https://github.com/chef/train/pull/96) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- 0.11.2 [\#97](https://github.com/chef/train/pull/97) ([alexpop](https://github.com/alexpop))

## [v0.11.1](https://github.com/chef/train/tree/v0.11.1) (2016-04-28)
[Full Changelog](https://github.com/chef/train/compare/v0.11.0...v0.11.1)

**Fixed bugs:**

- fix nil file paths [\#94](https://github.com/chef/train/pull/94) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- provide a source path for filecommon [\#95](https://github.com/chef/train/pull/95) ([arlimus](https://github.com/arlimus))
- restructure docker tests to balance load between 2 runs [\#93](https://github.com/chef/train/pull/93) ([arlimus](https://github.com/arlimus))

## [v0.11.0](https://github.com/chef/train/tree/v0.11.0) (2016-04-28)
[Full Changelog](https://github.com/chef/train/compare/v0.10.8...v0.11.0)

**Implemented enhancements:**

- Overhault file\(...\) and stat\(...\); point to destination of symlinks [\#92](https://github.com/chef/train/pull/92) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- validate the backend configuration [\#91](https://github.com/chef/train/pull/91) ([arlimus](https://github.com/arlimus))

## [v0.10.8](https://github.com/chef/train/tree/v0.10.8) (2016-04-25)
[Full Changelog](https://github.com/chef/train/compare/v0.10.7...v0.10.8)

**Implemented enhancements:**

- loose restriction for mixlib-shellout [\#89](https://github.com/chef/train/pull/89) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- use gemspec for travis [\#90](https://github.com/chef/train/pull/90) ([chris-rock](https://github.com/chris-rock))
- Don't strip off the second byte of the octal mode. [\#88](https://github.com/chef/train/pull/88) ([justindossey](https://github.com/justindossey))

## [v0.10.7](https://github.com/chef/train/tree/v0.10.7) (2016-04-21)
[Full Changelog](https://github.com/chef/train/compare/v0.10.6...v0.10.7)

**Merged pull requests:**

- 0.10.7 [\#87](https://github.com/chef/train/pull/87) ([arlimus](https://github.com/arlimus))
- Revert "add -L to get stat for symlink" [\#86](https://github.com/chef/train/pull/86) ([arlimus](https://github.com/arlimus))

## [v0.10.6](https://github.com/chef/train/tree/v0.10.6) (2016-04-20)
[Full Changelog](https://github.com/chef/train/compare/v0.10.5...v0.10.6)

**Merged pull requests:**

- add -L to get stat for symlink [\#85](https://github.com/chef/train/pull/85) ([vjeffrey](https://github.com/vjeffrey))
- release via travis + test via rubygems [\#84](https://github.com/chef/train/pull/84) ([arlimus](https://github.com/arlimus))

## [v0.10.5](https://github.com/chef/train/tree/v0.10.5) (2016-04-18)
[Full Changelog](https://github.com/chef/train/compare/v0.10.4...v0.10.5)

**Merged pull requests:**

- 0.10.5 [\#83](https://github.com/chef/train/pull/83) ([srenatus](https://github.com/srenatus))
- detection for hp-ux machine [\#82](https://github.com/chef/train/pull/82) ([Anirudh-Gupta](https://github.com/Anirudh-Gupta))

## [v0.10.4](https://github.com/chef/train/tree/v0.10.4) (2016-03-31)
[Full Changelog](https://github.com/chef/train/compare/v0.10.3...v0.10.4)

**Fixed bugs:**

- bugfix: do not use unix path escape for windows [\#79](https://github.com/chef/train/pull/79) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.10.4 [\#80](https://github.com/chef/train/pull/80) ([arlimus](https://github.com/arlimus))

## [v0.10.3](https://github.com/chef/train/tree/v0.10.3) (2016-03-07)
[Full Changelog](https://github.com/chef/train/compare/v0.10.1...v0.10.3)

**Fixed bugs:**

- set default value for ssh compression to false [\#77](https://github.com/chef/train/pull/77) ([chris-rock](https://github.com/chris-rock))
- avoid mock backend error on nil commands [\#75](https://github.com/chef/train/pull/75) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- 0.10.3 [\#78](https://github.com/chef/train/pull/78) ([chris-rock](https://github.com/chris-rock))
- 0.10.2 [\#76](https://github.com/chef/train/pull/76) ([arlimus](https://github.com/arlimus))

## [v0.10.1](https://github.com/chef/train/tree/v0.10.1) (2016-02-29)
[Full Changelog](https://github.com/chef/train/compare/v0.10.0...v0.10.1)

**Merged pull requests:**

- 0.10.1 [\#74](https://github.com/chef/train/pull/74) ([chris-rock](https://github.com/chris-rock))
- fix gem build license warning [\#73](https://github.com/chef/train/pull/73) ([chris-rock](https://github.com/chris-rock))
- depend on docker-api 1.26.2 [\#72](https://github.com/chef/train/pull/72) ([someara](https://github.com/someara))

## [v0.10.0](https://github.com/chef/train/tree/v0.10.0) (2016-02-19)
[Full Changelog](https://github.com/chef/train/compare/v0.9.7...v0.10.0)

**Implemented enhancements:**

- show mock failures for commands [\#69](https://github.com/chef/train/pull/69) ([arlimus](https://github.com/arlimus))
- update gems and rubocop [\#68](https://github.com/chef/train/pull/68) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- complete rewrite of windows version detection [\#70](https://github.com/chef/train/pull/70) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.10.0 [\#71](https://github.com/chef/train/pull/71) ([chris-rock](https://github.com/chris-rock))

## [v0.9.7](https://github.com/chef/train/tree/v0.9.7) (2016-02-05)
[Full Changelog](https://github.com/chef/train/compare/v0.9.6...v0.9.7)

**Implemented enhancements:**

- feature: add file.basename [\#64](https://github.com/chef/train/pull/64) ([arlimus](https://github.com/arlimus))
- add `requiretty` workaround measures [\#63](https://github.com/chef/train/pull/63) ([srenatus](https://github.com/srenatus))

**Fixed bugs:**

- ensure bundler is installed on travis [\#66](https://github.com/chef/train/pull/66) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.7 [\#67](https://github.com/chef/train/pull/67) ([chris-rock](https://github.com/chris-rock))

## [v0.9.6](https://github.com/chef/train/tree/v0.9.6) (2016-01-29)
[Full Changelog](https://github.com/chef/train/compare/v0.9.5...v0.9.6)

**Implemented enhancements:**

- add solaris support [\#61](https://github.com/chef/train/pull/61) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.6 [\#62](https://github.com/chef/train/pull/62) ([chris-rock](https://github.com/chris-rock))

## [v0.9.5](https://github.com/chef/train/tree/v0.9.5) (2016-01-25)
[Full Changelog](https://github.com/chef/train/compare/v0.9.4...v0.9.5)

**Implemented enhancements:**

- use minitest for windows tests [\#56](https://github.com/chef/train/pull/56) ([chris-rock](https://github.com/chris-rock))
- use negotiate auth for winrm and not basic\_auth [\#55](https://github.com/chef/train/pull/55) ([mwrock](https://github.com/mwrock))
- bugfix: pin net-ssh 2.9 in gem file [\#54](https://github.com/chef/train/pull/54) ([chris-rock](https://github.com/chris-rock))
- Add appveyor and Windows test [\#53](https://github.com/chef/train/pull/53) ([chris-rock](https://github.com/chris-rock))
- Deprecating winrm-tansport gem [\#46](https://github.com/chef/train/pull/46) ([mwrock](https://github.com/mwrock))

**Fixed bugs:**

- Cannot install train on Windows with ChefDK if username \>9 chars in length due to spec filename lengths in docker-api gem. [\#28](https://github.com/chef/train/issues/28)
- Properly wrap commands in powershell for local backend [\#57](https://github.com/chef/train/pull/57) ([chris-rock](https://github.com/chris-rock))
- Copying https://github.com/test-kitchen/test-kitchen/pull/919 to this repo [\#52](https://github.com/chef/train/pull/52) ([tyler-ball](https://github.com/tyler-ball))

**Merged pull requests:**

- 0.9.5 [\#58](https://github.com/chef/train/pull/58) ([chris-rock](https://github.com/chris-rock))

## [v0.9.4](https://github.com/chef/train/tree/v0.9.4) (2016-01-15)
[Full Changelog](https://github.com/chef/train/compare/v0.9.3...v0.9.4)

**Implemented enhancements:**

- 0.9.3 is empty on Windows [\#48](https://github.com/chef/train/pull/48) ([tyler-ball](https://github.com/tyler-ball))
- Updating to the latest release of net-ssh to consume https://github.com/net-ssh/net-ssh/pull/280 [\#47](https://github.com/chef/train/pull/47) ([tyler-ball](https://github.com/tyler-ball))

**Fixed bugs:**

- bugfix: command wrapper always return nil [\#50](https://github.com/chef/train/pull/50) ([chris-rock](https://github.com/chris-rock))

**Merged pull requests:**

- 0.9.4 [\#51](https://github.com/chef/train/pull/51) ([chris-rock](https://github.com/chris-rock))

## [v0.9.3](https://github.com/chef/train/tree/v0.9.3) (2016-01-03)
[Full Changelog](https://github.com/chef/train/compare/v0.9.2...v0.9.3)

**Implemented enhancements:**

- introduce `mounted` as a separate method to retrieve the content [\#44](https://github.com/chef/train/pull/44) ([chris-rock](https://github.com/chris-rock))
- Support for local transport on Windows [\#43](https://github.com/chef/train/pull/43) ([chris-rock](https://github.com/chris-rock))
- Split integration test preparation from executing [\#42](https://github.com/chef/train/pull/42) ([chris-rock](https://github.com/chris-rock))
- Support for AIX and targeted SSH testing [\#41](https://github.com/chef/train/pull/41) ([foobarbam](https://github.com/foobarbam))

**Merged pull requests:**

- 0.9.3 [\#45](https://github.com/chef/train/pull/45) ([chris-rock](https://github.com/chris-rock))

## [v0.9.2](https://github.com/chef/train/tree/v0.9.2) (2015-12-11)
[Full Changelog](https://github.com/chef/train/compare/v0.9.1...v0.9.2)

**Implemented enhancements:**

- add changelog [\#38](https://github.com/chef/train/pull/38) ([chris-rock](https://github.com/chris-rock))
- activate integration tests in travis [\#37](https://github.com/chef/train/pull/37) ([chris-rock](https://github.com/chris-rock))
- Adding support for Wind River Linux in support of Cisco devices [\#33](https://github.com/chef/train/pull/33) ([adamleff](https://github.com/adamleff))

**Fixed bugs:**

- Integration test failures [\#34](https://github.com/chef/train/issues/34)
- Implemented WindowsFile\#exist? [\#36](https://github.com/chef/train/pull/36) ([docwhat](https://github.com/docwhat))
- adapt integration test to changes in command\_wrapper [\#35](https://github.com/chef/train/pull/35) ([srenatus](https://github.com/srenatus))

**Closed issues:**

- WinRM plaintext transport is hardcoded \(cannot use SSL\) [\#29](https://github.com/chef/train/issues/29)

**Merged pull requests:**

- 0.9.2 [\#40](https://github.com/chef/train/pull/40) ([arlimus](https://github.com/arlimus))
- add rake version helpers [\#39](https://github.com/chef/train/pull/39) ([arlimus](https://github.com/arlimus))

## [v0.9.1](https://github.com/chef/train/tree/v0.9.1) (2015-11-03)
[Full Changelog](https://github.com/chef/train/compare/0.9.0...v0.9.1)

**Implemented enhancements:**

- R train [\#27](https://github.com/chef/train/pull/27) ([arlimus](https://github.com/arlimus))
- Update style of readme [\#26](https://github.com/chef/train/pull/26) ([chris-rock](https://github.com/chris-rock))
- Add Apache 2.0 License [\#25](https://github.com/chef/train/pull/25) ([jamesc](https://github.com/jamesc))

## [0.9.0](https://github.com/chef/train/tree/0.9.0) (2015-11-03)
**Implemented enhancements:**

- set windows name in :release [\#23](https://github.com/chef/train/pull/23) ([arlimus](https://github.com/arlimus))
- basic file transport via winrm [\#21](https://github.com/chef/train/pull/21) ([chris-rock](https://github.com/chris-rock))
- dont return nil on command errors stdout/stderr [\#20](https://github.com/chef/train/pull/20) ([arlimus](https://github.com/arlimus))
- skip .delivery in gemspec [\#19](https://github.com/chef/train/pull/19) ([arlimus](https://github.com/arlimus))
- Verify sudo is working and fail with error messages if it isn't [\#18](https://github.com/chef/train/pull/18) ([arlimus](https://github.com/arlimus))
- improve file eposure [\#16](https://github.com/chef/train/pull/16) ([chris-rock](https://github.com/chris-rock))
- add delivery [\#13](https://github.com/chef/train/pull/13) ([arlimus](https://github.com/arlimus))
- Sudo [\#12](https://github.com/chef/train/pull/12) ([arlimus](https://github.com/arlimus))
- Extract options handling for transport [\#11](https://github.com/chef/train/pull/11) ([arlimus](https://github.com/arlimus))
- don't let mock commands return nil on stdout or stderr [\#10](https://github.com/chef/train/pull/10) ([arlimus](https://github.com/arlimus))
- allow mock command to support sha256 mocking of commands [\#9](https://github.com/chef/train/pull/9) ([arlimus](https://github.com/arlimus))
- register plugins with both names and symbols [\#8](https://github.com/chef/train/pull/8) ([arlimus](https://github.com/arlimus))
- split of mock into transport and connection [\#7](https://github.com/chef/train/pull/7) ([arlimus](https://github.com/arlimus))
- bugfix: add docker dependency to gemspec [\#6](https://github.com/chef/train/pull/6) ([arlimus](https://github.com/arlimus))
- move train/plugins/common to train/extras [\#2](https://github.com/chef/train/pull/2) ([arlimus](https://github.com/arlimus))
- add Travis [\#1](https://github.com/chef/train/pull/1) ([arlimus](https://github.com/arlimus))

**Fixed bugs:**

- bugfix: prevent debugging info to stdout on winrm [\#22](https://github.com/chef/train/pull/22) ([arlimus](https://github.com/arlimus))
- bugfix: fail ssh connections correctly [\#17](https://github.com/chef/train/pull/17) ([arlimus](https://github.com/arlimus))
- bugfix: initialize mock transport to correct family [\#14](https://github.com/chef/train/pull/14) ([arlimus](https://github.com/arlimus))

**Merged pull requests:**

- bump train version to 0.9.0 [\#24](https://github.com/chef/train/pull/24) ([chris-rock](https://github.com/chris-rock))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*