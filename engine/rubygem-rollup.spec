%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name rollup

%define rubyabi 1.9.1
%global katello_bundlerd_dir /usr/share/katello/bundler.d

Summary:    Enhanced satellite reporting ruby engine
Name:       %{?scl_prefix}rubygem-%{gem_name}
Version:    0.0.11
Release:    1%{?dist}
Group:      Development/Libraries
License:    GPLv2+
URL:        https://github.com/katello/katello-reports-engine
Source0:    rubygem-%{gem_name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
#Requires:   katello
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

%prep
%setup -n rubygem-%{gem_name}-%{version} -q
mkdir -p .%{gem_dir}

%build
%{?scl:scl enable %{scl} "}
cd engine && gem build %{gem_name}.gemspec && cd ..
gem install --local --no-wrappers --install-dir .%{gem_dir} \
            --force engine/%{gem_name}-%{version}.gem --no-rdoc --no-ri
%{?scl:"}


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/etc/rollup
mkdir -p %{buildroot}/etc/pki/rollup
mkdir -p %{buildroot}%{gem_dir}
mkdir -p %{buildroot}%{katello_bundlerd_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

cat <<GEMFILE > %{buildroot}%{katello_bundlerd_dir}/%{gem_name}.rb
gem 'rollup'
GEMFILE

cp etc/rollup/rollup.yml %{buildroot}/etc/rollup/

# TODO this will be replaced with a RPM that delivers the public key
cp etc/pki/rollup/rollup_key.gpg.pub %{buildroot}/etc/pki/rollup
%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%config /etc/rollup/rollup.yml
/etc/pki/rollup/rollup_key.gpg.pub
%{gem_dir}
%{gem_spec}
%{katello_bundlerd_dir}/rollup.rb

%changelog
TODO

