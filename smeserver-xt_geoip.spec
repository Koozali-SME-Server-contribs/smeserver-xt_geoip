%define name smeserver-xt_geoip
%define version 1.3.1
%define release 39

Summary: smserver rpm to setup database, update and configuration for xt_geoip module with a panel.
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GNU GPL version 2
URL: http://wiki.contribs.org/Main_Page
Group: SMEserver/addon
Source: %{name}-%{version}.tar.xz

BuildArchitectures: noarch
BuildRoot: /var/tmp/%{name}-%{version}
BuildRequires: smeserver-devtools
Requires: smeserver-release >= 11.0
Requires: smeserver-manager >= 11
Requires: xtables-addons >= 3.25
# Is this required now?
Requires: GeoIP >= 1.6.0
Requires: libmaxminddb >= 1.1.1
# Is this required now?
Requires: libmaxminddb-devel >= 1.1.1
Requires: geolite2-country
Requires: geolite2-city
Requires: perl-Text-CSV_XS
AutoReqProv: no

%description
smserver rpm to setup database, update and configuration for xt_geoip module with a panel.


%prep
%setup
# tmp fix before new source archive
rm -rf root/etc/e-smith/events/bootstrap-console-save/templates2expand
rm -rf root/etc/e-smith/events/console-save/templates2expand
rm -rf root/etc/e-smith/events/xt_geoip-modify/templates2expand/usr
rm -rf root/etc/e-smith/events/xt_geoip-update/templates2expand/usr

%build
perl createlinks


%install
rm -rf $RPM_BUILD_ROOT

(cd root   ; find . -depth -print | cpio -dump $RPM_BUILD_ROOT)
rm -f %{name}-%{version}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT \
 --file /usr/share/xt_geoip/geoip_countries_list.txt  'attr(0755, root, root)'\
 --file /usr/share/xt_geoip/geoip_exstat  'attr(0755, root, root)'\
 --file /usr/share/xt_geoip/geoip_listat 'attr(0755, root, root)'\
 --file /usr/share/xt_geoip/geoip_look  'attr(0755, root, root)'\
 --file /usr/share/xt_geoip/geoip_stats 'attr(0755, root, root)'\
 --file /usr/share/xt_geoip/xt_geoip_dl 'attr(0750, root, root)'\
 --file /usr/share/xt_geoip/update_base 'attr(0750, root, root)'\
 --file /usr/share/xt_geoip/xt_geoip_build_maxmind 'attr(0750, root, root)'\
    > %{name}-%{version}-filelist
echo "%doc COPYING"  >> %{name}-%{version}-filelist

%clean
cd ..
rm -rf %{name}-%{version}

%pre
%preun

%post


%postun

%files -f %{name}-%{version}-filelist
%defattr(-,root,root)



%changelog
* Tue Nov 17 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.3.1-39.sme
- fix detection of kernel module
- fix detection of country db (permissive path)

* Wed Jul 08 2026 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-38.sme
- Fix ulog references [SME: 12418]

* Fri Jun 26 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.3.1-37.sme
- fix service reverse match (!=) config screen mismatch

* Sun Jun 21 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.3.1-36.sme
- add ability to block UDP service [SME: 12418]
- also display TCPPorts and UDPPorts

* Sun Jun 21 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.3.1-35.sme
- fix missing imap(s) pop3(s) and other subservices [SME: 13614]

* Sun Jun 21 2026 Zsolt Vasarhelyi <zsoltv@koozali.org> 1.3.1-34.sme
- Also list services now definded in DB as configuration [SME: 13614]
- remove old panel code

* Thu May 28 2026 Jean-Philippe Pialasse <jpp@koozali.org> 1.3.1-33.sme
- remove old panel link

* Tue Oct 28 2025 Jean-Philippe Pialasse <jpp@koozali.org> 1.3.1-31.sme
- Update the references in Createlinks to smeserver-*-update [SME: 13249]
  thanks to Zsolt Vasarhelyi

* Wed Oct 22 2025 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-30.sme
- Fix error in patch for [SME: 12445]
- Tidy template

* Tue Oct 21 2025 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-29.sme
- Fix SmartMatch errors [SME: 13240]
- Fix panel errors [SME: 13173]
- Do not block remote access authorized [SME: 12445]

* Tue Oct 07 2025 Brian Read <brianr@koozali.org> 1.3.1-28.sme
- Add UTF8 and avoid potential DB caching problems [SME: 13209]

* Sat Oct 04 2025 Brian Read <brianr@koozali.org> 1.3.1-27.sme
- Remove smanager-refresh from spec file [SME: 13212]

* Thu Mar 20 2025 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-26.sme
- Fix createlink typo remote-access-update [SME: 12438]

* Thu Feb 13 2025 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-25.sme
- Fix various typos as per bug but more to find [SME: 12472]

* Thu Feb 13 2025 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-24.sme
- move scripting back to /usr/share/geoip
- Lose the LE/BE (Little/Big Endian) parts as iptables can't seem to read the file in subdirs
- Update ULOG to NFLOG in rules but restricts the number of countries

* Wed Feb 12 2025 John Crisp <jcrisp@safeandsoundit.co.uk> 1.3.1-23.sme
- Update dependencies for xtables addons
- Remove $ from config in templates
- Add db open entries to subs

* Sat Sep 07 2024 cvs2git.sh aka Brian Read <brianr@koozali.org> 1.3.1-22.sme
- Roll up patches and move to git repo [SME: 12338]

* Sat Sep 07 2024 BogusDateBot
- Eliminated rpmbuild "bogus date" warnings due to inconsistent weekday,
  by assuming the date is correct and changing the weekday.

* Fri Sep 06 2024 Terry Fage <terry@fage.id.au> 1.3.1-21.sme
- apply locale 2024-09-06 patch

* Sat Mar 02 2024 Brian Read <brianr@koozali.org> 1.3.1-20.sme
- Edit SM2 Menu entry to conform to new arrangements [SME: 12493]

* Wed Feb 15 2023 Michel Begue <mab974@misouk.com> 1.3.1-19.sme
- fix module not loaded after update [SME: 10793]

* Wed Jan 11 2023 Michel Begue <mab974@misouk.com> 1.3.1-18.sme
- add a message if module xt_geoip is missing or not loaded [SME: 12291]
- add a message if chain XTGeoIP is missing (iptables) [SME: 12291]

* Fri Nov 11 2022 Jean-Philippe Pialasse <tests@pialasse.com> 1.3.1-17.sme
- apply locale 2022-11-11 patch

* Wed Jul 13 2022 Michel Begue <mab974@misouk.com> 1.3.1-16.sme
- add fail2ban stats [SME: 12098]

* Mon Jul 11 2022 Michel Begue <mab974@misouk.com> 1.3.1-15.sme
- fix logs date test [SME: 12097]

* Thu Jul 07 2022 Michel Begue <mab974@misouk.com> 1.3.1-14.sme
- add xt_geoip to backup list [SME: 12029]
- archive and clean up  Ip & Country bases [SME: 10863]

* Wed Mar 09 2022 Michel Begue <mab974@misouk.com> 1.3.1-13.sme
- fix Other and Reverse parameters for SM2 [SME: 11887]

* Fri Jan 07 2022 Brian Read <brianr@bjsystems.co.uk> 1.3.1-12.sme
- Add-class-to-div-for-AdminLTE [SME: 11839]

* Fri Oct 29 2021 Michel Begue <mab974@misouk.com> 1.3.1-11.sme
- fix multiple_rpm_owners [SME: 11676]
- add event for smeserver-manager
- delete expand-template for update_base

* Thu Oct 28 2021 Michel Begue <mab974@gmail.com> 1.3.1-10.sme
- apply locale 2021-10-28 patch

* Fri Sep 24 2021 Terry Fage <tfage@yahoo.com.au> 1.3.1-09.sme
- apply locale 2021-09-23 patch

* Wed Aug 25 2021 Terry Fage <tfage@yahoo.com.au> 1.3.1-08.sme
- apply locale 2021-08-25 patch

* Tue Mar 16 2021 Michel Begue <mab974@gmail.com> 1.3.1-07.sme
- Fix script as logfiles change (sshd - iptables)

* Sun Mar 14 2021 Jean-Philippe Pialasse <tests@pialasse.com> 1.3.1-06.sme
- change Geoip requirement to >= 1.5

* Sat Mar 13 2021 Jean-Philippe Pialasse <tests@pialasse.com> 1.3.1-05.sme
- readded changelog from contribs9
- moved changelog to the end of spec
- TODO review the two section of %files
- added link to wrapper for e-smith-manager

* Wed Jan 06 2021 Michel Begue <mab974@gmail.com> 1.3.1-03.sme
- Back to compatibility with e-smith-manager
- (s)qpsmtpd replace (s)smtpd (services)
- remove 'update_base' script template

* Fri Jul 31 2020 Michel Begue <mab974@gmail.com> 1.3.1-01.sme
- initial release for smeserver-manager (sme10)
- [1.0.1-26 sme9]
- xtables-addons v2.14

* Mon Feb 24 2020 Michel Begue <mab974@gmail.com> 1.0.1-26.sme
- add localhost to whitelist [SME: 10881]

* Tue Jan 21 2020 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-25.sme
- add requirement for mmdb provided by rpm to allow accounting [SME: 10860]

* Sat Jan 18 2020 Michel Begue <mab974@gmail.com> 1.0.1-24.sme
- new download script adapted to SME (from xtables-addons) [SME: 10860]
- change geoiplookup to mmdblookup

* Sat Jan 11 2020 Michel Begue <mab974@gmail.com> 1.0.1-23.sme
- add license_key in config db and test in panel [SME: 10860]

* Sat Dec 07 2019 SME Translation Server <translations@contribs.org> 1.0.1-21.sme
- apply locale 2019-12-07 patch

* Wed Oct 16 2019 Michel Begue <mab974@gmail.com> 1.0.1-20.sme
- panel to add services  [SME: 10792]
- french translation

* Mon Sep 30 2019 Michel Begue <mab974@gmail.com> 1.0.1-19.sme
- add country code list [SME: 10791]
- fix stats SSH errors [SME: 10807]
- improved panel [SME: 10788]

* Sat Sep 21 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-18.sme
- add more service [SME: 10789]
- no email from log analysis by default [SME: 10797]

* Sun Jul 28 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-17.sme
- fix empty global filter disable all geoip iptables rules [SME: 10794]
- tidy masq templates for xt geoip [SME: 10794]

* Wed Jul 24 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-16.sme
- add missing file to patch [SME: 10760]
- workaround link issue in source [SME: 10790]

* Tue Jul 23 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-15.sme
- improved per service filtering [SME: 10760]
- remove A1 forced as default and allow empty filter [SME: 10785]

* Sun Jul 21 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-13.sme
- fix network lock out on adjust [SME: 10760]
  this arised on initial install with a simple masq adjust
  or if XT_geoip is disbaled on any masq restart or adjust

* Wed Apr 24 2019 Michel Begue <mab974@gmail.com> 1.0.1-12.sme
- add per service management of GeoIP bans [SME: 10760]
- move panel to Security [SME: 10773]

* Wed Apr 17 2019 Michel Begue <mab974@gmail.com> 1.0.1-9.sme
- add stats access in the panel [SME: 10745]
- add control of maximum number of countries [SME: 10749]

* Wed Mar 06 2019 Michel Begue <mab974@gmail.com> 1.0.1-7.sme
- add stats of geoip blocked countries [SME: 10745]
- add stats of ssh attacks not geoip blocked [SME: 10744]
- expand /etc/crontab on update

* Mon Feb 18 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-6.sme
- fix unable to load iptables rules [SME: 10739]
  fix warning localtime
  fix warning "enabled" isn't numeric in numeric eq (==)

* Wed Feb 06 2019 Jean-Philipe Pialasse <tests@pialasse.com> 1.0.1-5.sme
- first import to SME buildsys

* Sun Oct 29 2017 Michel Begue <mab974@gmail.com>
- bug in crontab update job,
- [1.0.1-4]

* Mon Oct 16 2017 Michel Begue <mab974@gmail.com>
- new message : inactive GeoIP,
- value of country code added in message "country not found",
- [1.0.1-3]

* Sat Oct 07 2017 Michel Begue <mab974@gmail.com>
- test kernel module presence in "/lib/modules/weak-updates" directory
- [1.0.1-2]

* Wed Sep 20 2017 Michel Begue <mab974@gmail.com>
- panel added in server manager
- [1.0.1-1]

* Tue Sep 12 2017 Michel Begue <mab974@gmail.com>
- initial release
- [1.0.0-1]
