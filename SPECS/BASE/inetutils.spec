Summary:	The Inetutils package contains programs for basic networking.
Name:		inetutils
Version:	1.9.4
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Octothorpe
Requires:	expat
Source0:	http://ftp.gnu.org/gnu/inetutils/%{name}-%{version}.tar.xz
%description
	The Inetutils package contains programs for basic networking.
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--localstatedir=/var \
		--disable-logger \
		--disable-whois \
		--disable-rcp \
		--disable-rexec \
		--disable-rlogin \
		--disable-rsh \
		--disable-servers
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/{hostname,ping,ping6,traceroute} %{buildroot}/bin
	install -vdm 755 %{buildroot}/sbin
	mv -v %{buildroot}%{_bindir}/ifconfig %{buildroot}/sbin
	#	Copy license/copying file
	install -D -m644 COPYING %{buildroot}/usr/share/licenses/%{name}/LICENSE
	#	Create file list
	rm  %{buildroot}%{_infodir}/dir
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
	sed -i '/man/d' filelist.rpm
%files -f filelist.rpm
	%defattr(-,root,root)
%changelog
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 1.9.4-1
-	Initial build.	First version
