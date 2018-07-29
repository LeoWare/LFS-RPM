Summary:	Package manager
Name:		rpm
Version:	4.14.1
Release:	1
License:	GPLv2
URL:		http://rpm.org
Group:		LFS/BASE
Vendor:		Octothorpe
Source0:	http://ftp.rpm.org/releases/rpm-4.14.x/%{name}-%{version}.tar.bz2
Source1:	http://download.oracle.com/berkeley-db/db-6.0.20.tar.gz
%description
	Package manager
%prep
%setup -q -n %{name}-%{version}
%setup -q -T -D -a 1 -n %{name}-%{version}
sed -i 's/--srcdir=$db_dist/--srcdir=$db_dist --with-pic/' db3/configure
%build
	ln -vs db-6.0.20 db
	./configure \
		--prefix=%{_prefix} \
		--program-prefix= \
		--sysconfdir=/etc \
		--with-crypto=openssl \
		--with-cap \
		--with-acl  \
		--without-external-db \
		--without-archive \
		--without-lua \
		--disable-plugins \
		--disable-dependency-tracking \
		--disable-silent-rules
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	#	Copy license/copying file 
	install -D -m644 COPYING %{buildroot}%{_datarootdir}/licenses/%{name}-%{version}/COPYING
	install -D -m644 INSTALL %{buildroot}%{_datarootdir}/licenses/%{name}-%{version}/INSTALL
	#	Create file list
#	rm  %{buildroot}%{_infodir}/dir
	find %{buildroot} -name '*.la' -delete
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
	sed -i '/man\/man/d' filelist.rpm
	sed -i '/\/usr\/share\/info/d' filelist.rpm
	sed -i '/man\/fr/d' filelist.rpm
	sed -i '/man\/pl/d' filelist.rpm
	sed -i '/man\/sk/d' filelist.rpm
	sed -i '/man\/ko/d' filelist.rpm
	sed -i '/man\/ja/d' filelist.rpm
	sed -i '/man\/ru/d' filelist.rpm	
%files -f filelist.rpm
	%defattr(-,root,root)
#	%%{_infodir}/*.gz
	%{_mandir}/man1/*.gz
	%{_mandir}/man8/*.gz
	%{_mandir}/fr/man8/*.gz
	%{_mandir}/ja/man8/*.gz
	%{_mandir}/ko/man8/*.gz
	%{_mandir}/pl/man1/*.gz
	%{_mandir}/pl/man8/*.gz
	%{_mandir}/ru/man8/*.gz
	%{_mandir}/sk/man8/*.gz
%changelog
*	Sat Jul 28 2018 baho-utot <baho-utot@columbus.rr.com> 4.14.1-1
*	Sat Mar 10 2018 baho-utot <baho-utot@columbus.rr.com> 4.14.0-4
-	Added acl and cap Removed plugins and disabled python
*	Tue Feb 20 2018 baho-utot <baho-utot@columbus.rr.com> 4.14.0-3
-	Added python bindings for rpmlint
*	Mon Jan 01 2018 baho-utot <baho-utot@columbus.rr.com> 4.14.0-1
-	LFS-8.1
