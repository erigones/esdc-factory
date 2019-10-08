%global sname psycopg2
%ifarch ppc64 ppc64le
# Define the AT version and path.
%global atstring	at10.0
%global atpath		/opt/%{atstring}
%endif
%global pgmajorversion 95

%if 0%{?fedora} > 23
%global with_python3 1
%else
%global with_python3 0
%endif

%if 0%{?with_python3}
 %global	python_runtimes	python2 python-debug python3 python3-debug
%else
  %if 0%{?rhel} && 0%{?rhel} <= 6 || 0%{?suse_version} >= 1315
    %global	python_runtimes	python2
   %else
    %global python_runtimes python2 python-debug
  %endif
%endif

# Python major version.
%{expand: %%global pyver %(python -c 'import sys;print(sys.version[0:3])')}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(1)")}

%if 0%{?with_python3}
%{expand: %%global py3ver %(python3 -c 'import sys;print(sys.version[0:3])')}
%endif # with_python3

Summary:	A PostgreSQL database adapter for Python (Danube Cloud version)
Name:		python-%{sname}-dc
Version:	2.7.5
Release:	1%{?dist}
# The exceptions allow linking to OpenSSL and PostgreSQL's libpq
License:	LGPLv3+ with exceptions
Group:		Applications/Databases
Url:		http://www.psycopg.org/psycopg/
Source0:	http://www.psycopg.org/psycopg/tarballs/PSYCOPG-2-7/%{sname}-%{version}.tar.gz
Patch0:		%{name}-pg%{pgmajorversion}-setup.cfg.patch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:	postgresql%{pgmajorversion}-devel
BuildRequires:	python-devel
%if 0%{?with_python3}
BuildRequires:	python3-devel
BuildRequires:	python3-debug
%endif # with_python3

%if 0%{?fedora} >= 23 || 0%{?rhel} >= 7
BuildRequires:	python-debug
%endif # Python 2.7
%ifarch ppc64 ppc64le
AutoReq:	0
Requires:	advance-toolchain-%{atstring}-runtime
%endif

%ifarch ppc64 ppc64le
BuildRequires:	advance-toolchain-%{atstring}-devel
%endif

Requires:	postgresql%{pgmajorversion}-libs

Conflicts:	python-%{sname}-zope < %{version}

%description
Psycopg is the most popular PostgreSQL adapter for the Python
programming language. At its core it fully implements the Python DB
API 2.0 specifications. Several extensions allow access to many of the
features offered by PostgreSQL.

%package debug
Summary:	A PostgreSQL database adapter for Python 2 (debug build)
# Require the base package, as we're sharing .py/.pyc files:
Requires:	%{name} = %{version}-%{release}
Group:		Applications/Databases

%description debug
This is a build of the psycopg PostgreSQL database adapter for the debug
build of Python 2.

%package -n python2-%{sname}-tests
Summary:	A testsuite for %sum 2
Requires:	python2-%sname = %version-%release

%description -n python2-%{sname}-tests
%desc
This sub-package delivers set of tests for the adapter.

%if 0%{?with_python3}
%package -n python3-%{sname}
Summary:	A PostgreSQL database adapter for Python 3
%ifarch ppc64 ppc64le
AutoReq:	0
Requires:	advance-toolchain-%{atstring}-runtime
%endif

%description  -n python3-%{sname}
This is a build of the psycopg PostgreSQL database adapter for Python 3.

%package -n python3-%{sname}-tests
Summary:	A testsuite for %sum 2
Requires:	python3-%sname = %version-%release

%description -n python3-%{sname}-tests
%desc
This sub-package delivers set of tests for the adapter.

%package -n python3-%{sname}-debug
Summary:	A PostgreSQL database adapter for Python 3 (debug build)
# Require base python 3 package, as we're sharing .py/.pyc files:
Requires:	python3-%{sname} = %{version}-%{release}

%description -n python3-%{sname}-debug
This is a build of the psycopg PostgreSQL database adapter for the debug
build of Python 3.
%endif # with_python3

%package doc
Summary:	Documentation for psycopg python PostgreSQL database adapter
Group:		Documentation
Requires:	%{name} = %{version}-%{release}

%description doc
Documentation and example files for the psycopg python PostgreSQL
database adapter.

%prep
%setup -q -n %{sname}-%{version}
%patch0 -p0

%build
%ifarch ppc64 ppc64le
	CFLAGS="${CFLAGS} $(echo %{__global_cflags} | sed 's/-O2/-O3/g') -m64 -mcpu=power8 -mtune=power8 -I%{atpath}/include"
	CXXFLAGS="${CXXFLAGS} $(echo %{__global_cflags} | sed 's/-O2/-O3/g') -m64 -mcpu=power8 -mtune=power8 -I%{atpath}/include"
	LDFLAGS="-L%{atpath}/%{_lib}"
	CC=%{atpath}/bin/gcc; export CC
	PATH=%{atpath}/bin/:%{atpath}/sbin:$PATH ; export PATH
%endif
for python in %{python_runtimes} ; do
  $python setup.py build
done

# Fix for wrong-file-end-of-line-encoding problem; upstream also must fix this.
for i in `find doc -iname "*.html"`; do sed -i 's/\r//' $i; done
for i in `find doc -iname "*.css"`; do sed -i 's/\r//' $i; done

# Get rid of a "hidden" file that rpmlint complains about
%{__rm} -f doc/html/.buildinfo

%install
for python in %{python_runtimes} ; do
  $python setup.py install --no-compile --root %{buildroot}
done

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root)
%doc AUTHORS LICENSE NEWS README.rst
%dir %{python_sitearch}/%{sname}
%{python_sitearch}/%{sname}/*.py
%{python_sitearch}/%{sname}/_psycopg.so
%if 0%{?suse_version} >= 1315
%{python_sitearch}/%{sname}/*.py
%else
%{python_sitearch}/%{sname}/*.py
%{python_sitearch}/%{sname}/*.pyc
%{python_sitearch}/%{sname}/*.pyo
%endif
%{python_sitearch}/%{sname}-%{version}-py%{pyver}.egg-info

%files -n python2-%{sname}-tests
%{python_sitearch}/psycopg2/tests

%if 0%{?fedora} >= 23 || 0%{?rhel} >= 7
%files debug
%defattr(-,root,root)
%doc LICENSE
%{python_sitearch}/%{sname}/_psycopg_d.so
%endif

%if 0%{?with_python3}
%files -n python3-%{sname}
%defattr(-,root,root)
%doc AUTHORS LICENSE NEWS README.rst
%dir %{python3_sitearch}/%{sname}
%{python3_sitearch}/%{sname}/*.py
%dir %{python3_sitearch}/%{sname}/__pycache__
%{python3_sitearch}/%{sname}/__pycache__/*.pyc
%{python3_sitearch}/%{sname}-%{version}-py%{py3ver}.egg-info
%{python3_sitearch}/%{sname}/_psycopg.cpython-3?m*.so

%files -n python3-%{sname}-tests
%{python3_sitearch}/psycopg2/tests

%files -n python3-%{sname}-debug
%defattr(-,root,root)
%doc LICENSE
%{python3_sitearch}/%{sname}/_psycopg.cpython-3*dm*.so
%endif # with_python3

%files doc
%defattr(-,root,root)
%doc doc examples/

%changelog
* Mon Jun 18 2018 Devrim Gündüz <devrim@gunduz.org> 2.7.5-1
- Update to 2.7.5 per
  http://www.psycopg.org/psycopg/articles/2018/06/17/psycopg-275-released/
- Change python to python2, to supress warning on Fedora 28+.

* Fri Feb 9 2018 Devrim Gündüz <devrim@gunduz.org> 2.7.4-1
- Update to 2.7.4 per
  http://www.psycopg.org/psycopg/articles/2018/02/08/psycopg-274-released/

* Sun Dec 10 2017 Devrim Gündüz <devrim@gunduz.org> 2.7.3.2-1
- Update to 2.7.3.2, per
  http://initd.org/psycopg/articles/2017/10/24/psycopg-2732-released/
- Add -tests subpackages.

* Mon Jul 24 2017 Devrim Gündüz <devrim@gunduz.org> 2.7.3-1
- Update to 2.7.3

* Tue Mar 14 2017 Devrim Gündüz <devrim@gunduz.org> 2.7.1-1
- Update to 2.7.1

* Sun Mar 05 2017 Devrim Gündüz <devrim@gunduz.org> 2.7-1
- Update to 2.7, per #2223.

* Fri Feb 24 2017 Devrim Gündüz <devrim@gunduz.org> 2.7b2-1
- Update to 2.7 beta 2

* Fri Oct 7 2016 Devrim Gündüz <devrim@gunduz.org> 2.6.2-3
- Move one .so file into python3-psycopg2 subpackage, per report
  from Oskari Saarenmaa.
- Fix RHEL 6 builds, with custom conditionals.
- Add BR for Python 2.7 environments.

* Tue Sep 13 2016 Devrim Gündüz <devrim@gunduz.org> 2.6.2-2
- Move python-debug (PY2 version) package into non-py3 builds.
  We need this at least for pgadmin4.

* Thu Jul 7 2016 Devrim Gündüz <devrim@gunduz.org> 2.6.2-1
- Update to 2.6.2, per changes described at:
  http://www.psycopg.org/psycopg/articles/2016/07/07/psycopg-262-released/

* Thu Jan 21 2016 Devrim Gündüz <devrim@gunduz.org> 2.6.1-1
- Update to 2.6.1
- Create unified spec file for all distros.
- Remove Zope subpackage.
- Minor spec file cleanups

* Mon Feb 9 2015 Devrim Gündüz <devrim@gunduz.org> 2.6-1
- Update to 2.6, per changes described at:
  http://www.psycopg.org/psycopg/articles/2015/02/09/psycopg-26-and-255-released/
- Trim changelog
- Merge some changes from Fedora spec file.
