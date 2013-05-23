%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

# TODO consider name change after things are building
# splice-reports-katello-engine???
%global gem_name splice_reports

%define rubyabi 1.9.1
%global katello_bundlerd_dir /usr/share/katello/bundler.d

#%if 0%{?rhel} == 6 && "%{?scl}" == ""
#%global gem_dir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
#%global gem_docdir %{gem_dir}/doc/%{gem_name}-%{version}
#%global gem_cache %{gem_dir}/cache/%{gem_name}-%{version}.gem
#%global gem_spec %{gem_dir}/specifications/%{gem_name}-%{version}.gemspec
#%global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}
#%endif

Summary:    Enhanced satellite reporting ruby engine 
Name:       %{?scl_prefix}rubygem-%{gem_name}
Version:    0.0.1
Release:    1%{?dist}
Group:      Development/Libraries
License:    GPLv2
URL:        https://github.com/splice/splice-reports
Source0:    %{gem_name}-%{version}.tar.gz
Requires:   katello
Requires:   %{?scl_prefix}ruby(abi) >= %{rubyabi}
# Need Requires for:
# - mongo
# - bson
# - zip
Requires:   %{?scl_prefix}rubygems
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
%setup -n %{gem_name}-%{version}
mkdir -p .%{gem_dir}

%build
%{?scl:scl enable %{scl} "}
cd src && gem build %{gem_name}.gemspec && cd ..
gem install --local --install-dir .%{gem_dir} \
            --force src/%{gem_name}-%{version}.gem --no-rdoc --no-ri
%{?scl:"}


%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

mkdir -p %{buildroot}%{katello_bundlerd_dir}
cat <<GEMFILE > %{buildroot}%{katello_bundlerd_dir}/%{gem_name}.rb
gem 'splice_reports'
GEMFILE


%files
%{gem_instdir}
%exclude %{gem_cache}
%{katello_bundlerd_dir}/splice_reports.rb

%exclude %{gem_instdir}/test
%exclude %{gem_dir}/cache/%{gem_name}-%{version}.gem
#%exclude %{gem_dir}/bin/ruby_noexec_wrapper

%files doc
%{gem_spec}

%changelog
* Tue May 21 2013 John Matthews <jmatthew@redhat.com> 0.1-1
- Initial packaging (jmatthew@redhat.com)
