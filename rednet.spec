%define revcount %(git rev-list HEAD | wc -l)
%define treeish %(git rev-parse --short HEAD)
%define localmods %(git diff-files --exit-code --quiet  || date +.m%%j%%H%%M%%S)

%define srcdir   %{getenv:PWD}

Summary: Rednet Cloud Switch Service
Name: rednet
Version: 1.0
Release: %{revcount}.%{treeish}%{localmods}
Distribution: Redgates/Services
Group: System Environment/Daemons
License: Proprietary
Vendor: Redgates.com
Packager: Karl Redgate <Karl.Redgate@gmail.com>
BuildArch: noarch
%define _topdir %(echo $PWD)/rpm
BuildRoot: %{_topdir}/BUILDROOT
Requires: openvpn

Requires(preun): chkconfig
Requires(post): chkconfig

%description
Config and scripts for the rednet service

%prep
%build

%install
install --directory --mode=755 $RPM_BUILD_ROOT/etc/sysconfig/
install --mode=644 %{srcdir}/sysconfig/* $RPM_BUILD_ROOT/etc/sysconfig/

install --directory --mode=755 $RPM_BUILD_ROOT/etc/init/
install --mode=644 %{srcdir}/init/* $RPM_BUILD_ROOT/etc/init/

install --directory --mode=755 $RPM_BUILD_ROOT/etc/cron.d/
install --mode=644 %{srcdir}/cron.d/* $RPM_BUILD_ROOT/etc/cron.d/

install --directory --mode=755 $RPM_BUILD_ROOT/etc/profile.d/
install --mode=644 %{srcdir}/profile.d/* $RPM_BUILD_ROOT/etc/profile.d/

install --directory --mode=755 $RPM_BUILD_ROOT/etc/bash_completion.d/
install --mode=644 %{srcdir}/completion/* $RPM_BUILD_ROOT/etc/bash_completion.d/

install --directory --mode=755 $RPM_BUILD_ROOT/etc/openvpn
install --mode=644 %{srcdir}/server.conf $RPM_BUILD_ROOT/etc/openvpn/

install --directory --mode=755 $RPM_BUILD_ROOT/etc/pki/rednet
install --mode=644 %{srcdir}/pki/* $RPM_BUILD_ROOT/etc/pki/rednet/

install --directory --mode=755 $RPM_BUILD_ROOT/var/run/rednet
install --directory --mode=755 $RPM_BUILD_ROOT/var/cache/rednet
install --directory --mode=755 $RPM_BUILD_ROOT/var/spool/rednet
install --directory --mode=755 $RPM_BUILD_ROOT/var/log/rednet
install --directory --mode=775 $RPM_BUILD_ROOT/var/cache/rednet/s3

install --directory --mode=755 $RPM_BUILD_ROOT/usr/share/rednet
install --mode=644 %{srcdir}/share/* $RPM_BUILD_ROOT/usr/share/rednet
install --mode=644 %{srcdir}/xslt/* $RPM_BUILD_ROOT/usr/share/rednet

install --directory --mode=755 $RPM_BUILD_ROOT/usr/libexec/rednet/hooks
install --mode=755 %{srcdir}/libexec/* $RPM_BUILD_ROOT/usr/libexec/rednet/
install --mode=755 %{srcdir}/hooks/* $RPM_BUILD_ROOT/usr/libexec/rednet/hooks/

install --directory --mode=755 $RPM_BUILD_ROOT/usr/bin
install --mode=755 %{srcdir}/commands/* $RPM_BUILD_ROOT/usr/bin

install --directory --mode=755 $RPM_BUILD_ROOT/usr/share/man/man1/
install --mode=755 %{srcdir}/doc/*.1 $RPM_BUILD_ROOT/usr/share/man/man1/

# install --directory --mode=700 $RPM_BUILD_ROOT/home/ec2-user/.ssh
# cat %{srcdir}/keys/*.pub > $RPM_BUILD_ROOT/home/ec2-user/.ssh/authorized_keys
# chmod 600 $RPM_BUILD_ROOT/home/ec2-user/.ssh/authorized_keys

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,0755)
%config /etc/sysconfig/rednet
/etc/init/
/etc/cron.d/
/etc/profile.d/
/etc/bash_completion.d/
/etc/openvpn/server.conf
/etc/pki/rednet/server.conf
/usr/bin
/usr/share/python/
/usr/libexec/rednet
/usr/share/rednet
/usr/share/man/
%attr(0700,ec2-user,rednet) /home/ec2-user/.ssh
%attr(0600,ec2-user,rednet) /home/ec2-user/.ssh/authorized_keys
%attr(0775,ec2-user,rednet) /var/cache/carbonite/s3
/var/run/rednet
/var/log/rednet/
%attr(0775,root,rednet) /var/cache/rednet/
%attr(0775,root,rednet) /var/spool/rednet/

%pre

getent group rednet || groupadd rednet
getent passwd ec2-user || useradd ec2-user -g rednet
groupmems --group rednet --add ec2-user > /dev/null 2>&1 || : ignore error

%post
[ "$1" -gt 1 ] && {
    : Upgrading
}

[ "$1" = 1 ] && {
    : New install
}

setenforce 0

# openvpn will not be started by the init.d scripts, since
# that does not cause daemon restart.  Instead it is started
# by an Upstart config.
chkconfig openvpn off

: ignore test return value

%preun
[ "$1" = 0 ] && {
    : cleanup
}

: ignore test return value

%postun

[ "$1" = 0 ] && {
    : This is really an uninstall
    groupmems --group rednet --del ec2-user
    groupdel rednet
}

: ignore test errs

%changelog

* Fri May  8 2015 Karl Redgate <www.redgates.com>
- Initial release

# vim:autoindent expandtab sw=4
