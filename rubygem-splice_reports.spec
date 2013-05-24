%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name splice_reports

%define rubyabi 1.9.1
%global katello_bundlerd_dir /usr/share/katello/bundler.d

Summary:    Enhanced satellite reporting ruby engine 
Name:       %{?scl_prefix}rubygem-%{gem_name}
Version:    0.0.5
Release:    5%{?dist}
Group:      Development/Libraries
License:    GPLv2
URL:        https://github.com/splice/splice-reports
Source0:    rubygem-%{gem_name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:   katello
Requires:   %{?scl_prefix}ruby(abi) >= %{rubyabi}
Requires:   %{?scl_prefix}rubygems
Requires:   %{?scl_prefix}rubygem-mongo
Requires:   %{?scl_prefix}rubygem-bson_ext
Requires:   %{?scl_prefix}rubygem-zipruby

BuildRequires: %{?scl_prefix}rubygems-devel
BuildRequires: %{?scl_prefix}ruby(abi) >= %{rubyabi}
BuildRequires: %{?scl_prefix}rubygems
BuildArch: noarch
Provides: %{?scl_prefix}rubygem(%{gem_name}) = %{version}

%description
A ruby engine that provides enhanced Satellite reporting 
for Katello/SAM

%package doc
BuildArch:  noarch
Requires:   %{?scl_prefix}%{pkg_name} = %{version}-%{release}
Summary:    Documentation for rubygem-%{gem_name}

%description doc
This package contains documentation for rubygem-%{gem_name}.

%prep
%setup -n rubygem-%{gem_name}-%{version} -q
mkdir -p .%{gem_dir}

%build
%{?scl:scl enable %{scl} "}
cd src && gem build %{gem_name}.gemspec && cd ..
gem install --local --no-wrappers --install-dir .%{gem_dir} \
            --force src/%{gem_name}-%{version}.gem --no-rdoc --no-ri
%{?scl:"}


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{katello_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{katello_bundlerd_dir}/%{gem_name}.rb
gem 'splice_reports'
GEMFILE

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{gem_dir}
%{gem_spec}
%{katello_bundlerd_dir}/splice_reports.rb

%files doc
%defattr(-,root,root,-)

%changelog
* Fri May 24 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-5
- Added Requires for bson_ext, mongo, zipruby (jwmatthews@gmail.com)
- Merge branch 'master' of github.com:splice/splice-reports
  (whayutin@redhat.com)
- fix bug, always sort status with failures at the top (whayutin@redhat.com)

* Fri May 24 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-4
- Update to include %%{gem_dir} instead of %%{gem_instdir}
  (jwmatthews@gmail.com)
- few more uxd improvements for details (whayutin@redhat.com)

* Thu May 23 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-3
- RPM builds and removed rpmlint warnings (jwmatthews@gmail.com)
- Back to regular tito Builder (jwmatthews@gmail.com)

* Thu May 23 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-2
- Changing tito to a ReleaseTagger and manual set version.rb to match spec
  (jwmatthews@gmail.com)

* Thu May 23 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-1
- Removed some comments from spec (jwmatthews@gmail.com)
- Update tito config (jwmatthews@gmail.com)

* Thu May 23 2013 John Matthews <jwmatthews@gmail.com> 0.0.4-1
- Update Source0 so we can build with tito (jwmatthews@gmail.com)

* Thu May 23 2013 John Matthews <jwmatthews@gmail.com> 0.0.3-1
- Change name of spec to match convention for rubygem packaged rpm
  (jwmatthews@gmail.com)

* Thu May 23 2013 John Matthews <jwmatthews@gmail.com> 0.0.2-1
- new package built with tito

* Tue May 21 2013 John Matthews <jmatthew@redhat.com> 0.1-1
- Initial packaging (jmatthew@redhat.com)
