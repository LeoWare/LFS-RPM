Summary:	The Tar package contains an archiving program.
Name:		tar
Version:	1.30
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Octothorpe
Requires:	man-db
Source0:	http://ftp.gnu.org/gnu/tar/%{name}-%{version}.tar.xz
%description
	The Tar package contains an archiving program.
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	FORCE_UNSAFE_CONFIGURE=1 \
	./configure \
		--prefix=%{_prefix} \
		--bindir=/bin
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	make -C doc DESTDIR=%{buildroot} install-html docdir=%{_docdir}/%{NAME}-%{VERSION}
	rm -rf %{buildroot}/%{_infodir}
	#	Copy license/copying file
	install -D -m644 COPYING %{buildroot}/usr/share/licenses/%{name}/LICENSE
	#	Create file list
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
%files -f filelist.rpm
	%defattr(-,root,root)
%changelog
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 1.30-1
-	Initial build.	First version
