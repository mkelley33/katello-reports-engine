%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name splice_reports

%define rubyabi 1.9.1
%global katello_bundlerd_dir /usr/share/katello/bundler.d

Summary:    Enhanced satellite reporting ruby engine 
Name:       %{?scl_prefix}rubygem-%{gem_name}
Version:    0.0.5
Release:    15%{?dist}
Group:      Development/Libraries
License:    GPLv2
URL:        https://github.com/splice/splice-reports
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
mkdir -p %{buildroot}/etc/splice
mkdir -p %{buildroot}/etc/pki/splice
mkdir -p %{buildroot}%{gem_dir}
mkdir -p %{buildroot}%{katello_bundlerd_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

cat <<GEMFILE > %{buildroot}%{katello_bundlerd_dir}/%{gem_name}.rb
gem 'splice_reports'
GEMFILE

cp etc/splice/splice_reports.yml %{buildroot}/etc/splice/

# TODO this will be replaced with a RPM that delivers the public key
cp playpen/exports/example/splice_reports_key.gpg.pub %{buildroot}/etc/pki/splice
%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%config /etc/splice/splice_reports.yml
/etc/pki/splice/splice_reports_key.gpg.pub
%{gem_dir}
%{gem_spec}
%{katello_bundlerd_dir}/splice_reports.rb

%files doc
%defattr(-,root,root,-)

%changelog
* Tue Jun 04 2013 wes hayutin <whayutin@redhat.com> 0.0.5-15
- update to seeds (whayutin@redhat.com)
- change RH Satellite -> Red Hat Satellite (whayutin@redhat.com)

* Tue Jun 04 2013 wes hayutin <whayutin@redhat.com> 0.0.5-14
- add status to default reprots, and add inactive report (whayutin@redhat.com)

* Mon Jun 03 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-13
- Adding a workaround so each time our Rails engine is loaded it will execute
  seed.rb This workaround is intended to be removed once Katello adds support
  to load seed data from all the engines (jwmatthews@gmail.com)
- seeds.rb will only create a new default filter if one is not found
  (whayutin@redhat.com)
- empty out orgs before adding them (whayutin@redhat.com)
- allow default redhat report w/ any will pull all available orgs
  (whayutin@redhat.com)
- inactive status now can be edited like the other fields (whayutin@redhat.com)
- uploading sample data (whayutin@redhat.com)

* Mon Jun 03 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-12
- Update initializer so our db migrations will run when katello runs their own
  (jwmatthews@gmail.com)

* Fri May 31 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-11
- Adding an initializer to help with precompiling assets (jwmatthews@gmail.com)
- updated RHN Satellite to RH Satellite (whayutin@redhat.com)

* Fri May 31 2013 Unknown name <whayutin@redhat.com> 0.0.5-10
- updating css and haml.. to adjust width of _form and _new filter..
  (whayutin@redhat.com)

* Fri May 31 2013 Unknown name <whayutin@redhat.com> 0.0.5-9
- bug in nutupane css that slightly misrenders the details page, override css.
  Also added some padding to the filter edit page (whayutin@redhat.com)
- move satellite link to the right of the details page (whayutin@redhat.com)
- clean up (whayutin@redhat.com)
- add link to spacewalk system details (whayutin@redhat.com)
- Merge branch 'master' of github.com:splice/splice-reports
  (whayutin@redhat.com)
- add check to see if query returned value for status (whayutin@redhat.com)

* Thu May 30 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-8
- Removing Katello requires as we work through some packaging problems with
  asset precompiling with Katello (jwmatthews@gmail.com)
- made change so hostname and id are shown when details are opened
  (whayutin@redhat.com)
- refactor for mpu change from date -> checkin_date (whayutin@redhat.com)
- fixed nutupane rendering issue where details was rendered under the table
  (whayutin@redhat.com)
- seperating hostname and system id, eric is putting in a change to alchemy so
  two columns can be displayed, commit f988c9fdbc466e74c5605bde0d81f2001554d180
  (whayutin@redhat.com)
- reduced the number of times the report query is called from two to one
  (whayutin@redhat.com)
- move the filter description up the page (whayutin@redhat.com)
- fixed bug in report query that on individual status queries would show the
  lastest + status instead of just the latest checkin (whayutin@redhat.com)
- Finally have the counts right for the dashboard, only using the latest
  checkin now (whayutin@redhat.com)
- clean up (whayutin@redhat.com)
- the aggregation for counts are picking up additional unique checkins w/ diff
  status (whayutin@redhat.com)
- found a better way to aggregate the status counts w/o having to hit the db
  three times (whayutin@redhat.com)
- Merge branch 'master' of github.com:splice/splice-reports
  (whayutin@redhat.com)
- changed dashboard counts, no longer loops through array. Gets counts from
  mongo directly (whayutin@redhat.com)

* Wed May 29 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-7
- Add config file and gpg pub key to RPM (jwmatthews@gmail.com)
- add a line break if filter tip orgs is too long (whayutin@redhat.com)
- remove check boxes from table (whayutin@redhat.com)
- clean up new filter page, use labels (whayutin@redhat.com)
- update report controller for the inactive boolean (whayutin@redhat.com)
- changed inactive from an integer to a boolean, changed db, model, controller
  and views (whayutin@redhat.com)
- Merge branch 'master' of github.com:splice/splice-reports
  (whayutin@redhat.com)
- adding help tip for filter creation (whayutin@redhat.com)

* Fri May 24 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-6
- Include gem_spec in files of .spec (jwmatthews@gmail.com)
- fix for type conversion error on tool tip (whayutin@redhat.com)
- little clean up for uxd (whayutin@redhat.com)
- fix tool tip status array (whayutin@redhat.com)
- clean up filter create (whayutin@redhat.com)
- made dates consistent accross all views, set to iso gmt time
  (whayutin@redhat.com)

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
