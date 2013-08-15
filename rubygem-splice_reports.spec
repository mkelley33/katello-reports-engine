%{?scl:%scl_package rubygem-%{gem_name}}
%{!?scl:%global pkg_name %{name}}

%global gem_name splice_reports

%define rubyabi 1.9.1
%global katello_bundlerd_dir /usr/share/katello/bundler.d

Summary:    Enhanced satellite reporting ruby engine 
Name:       %{?scl_prefix}rubygem-%{gem_name}
Version:    0.0.5
Release:    41%{?dist}
Group:      Development/Libraries
License:    GPLv2+
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
cp etc/pki/splice/splice_reports_key.gpg.pub %{buildroot}/etc/pki/splice
%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%config /etc/splice/splice_reports.yml
/etc/pki/splice/splice_reports_key.gpg.pub
%{gem_dir}
%{gem_spec}
%{katello_bundlerd_dir}/splice_reports.rb

%changelog
* Thu Aug 15 2013 Chris Duryee (beav) <cduryee@redhat.com>
- 996636: remove empty doc subpackage (cduryee@redhat.com)

* Thu Aug 08 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-40
- Fix so filters are sorted with the default Red Hat filter on top
  (jwmatthews@gmail.com)
- Updated list of inactive systems to filter deleted systems, fixes issue with
  inactive system report in future (jwmatthews@gmail.com)
- 995132: remove double-validation of some form fields (cduryee@redhat.com)
- 995202: always use experimental UI for report view (cduryee@redhat.com)

* Thu Aug 08 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-39
- Updated column headers on export to match column names from webui
  (jwmatthews@gmail.com)

* Wed Jul 31 2013 Chris Duryee (beav) <cduryee@redhat.com>
- Merge branch 'master' of github.com:splice/splice-reports
  (whayutin@redhat.com)
- css to max out columns to the left of details (whayutin@redhat.com)
- fixed default report filter spacing (whayutin@redhat.com)

* Fri Jul 26 2013 Wes Hayutin <whayutin@redhat.com> 0.0.5-37
- unable to get this working w/o two clicks.. but adding selected class from
  katello vs underline (whayutin@redhat.com)
- changing the details panel to snap to the left hand column vs. lining up to
  the right (whayutin@redhat.com)
- changed the wording from total systems -> Subscribed Systems in the dashboard
  (whayutin@redhat.com)
- fix db seed .. change array to string for state (whayutin@redhat.com)
- underline of details navigation working w/ two clicks... not there yet
  (root@ec2-54-224-221-216.compute-1.amazonaws.com)
- trying to underline links in details (whayutin@redhat.com)
- fixing some uxd bugs (whayutin@redhat.com)

* Tue Jul 23 2013 Chris Duryee (beav) <cduryee@redhat.com>
- add cloude and katello-cli shared folders (cduryee@redhat.com)
- update sample data to use key organization_label (whayutin@redhat.com)
- Merge branch 'master' of github.com:splice/splice-reports
  (whayutin@redhat.com)
- change organization_id to organziation_label (whayutin@redhat.com)
- fixed up sample data for ec2 build
  (root@ec2-23-21-17-146.compute-1.amazonaws.com)

* Fri Jul 19 2013 wes hayutin <whayutin@redhat.com> 0.0.5-35
- updated query to pull the second to last checkin for the previous mpu before
  a delete mpu (whayutin@redhat.com)
- had to sanitize the checkin list and remove the link for deleted systems in
  the checkin list (root@ec2-107-21-145-194.compute-1.amazonaws.com)
- added some checking of previous mpu's (whayutin@redhat.com)
- fixed sanitized loop (whayutin@redhat.com)
- need to make sure the limit is atleast 2 (whayutin@redhat.com)
- remove debug statements (whayutin@redhat.com)
- first pass at sanitizing deleted records (whayutin@redhat.com)
- something is chomping off the last letter in katello using Route.
  (whayutin@redhat.com)

* Wed Jul 17 2013 wes hayutin <whayutin@redhat.com> 0.0.5-34
- bz#978377 fix filter popup capitalization (whayutin@redhat.com)

* Wed Jul 17 2013 wes hayutin <whayutin@redhat.com> 0.0.5-33
- found bug w/ query if active was not selected (whayutin@redhat.com)
- added tipsy tips for filters (whayutin@redhat.com)
- changed default report to active/inactive (whayutin@redhat.com)

* Wed Jul 17 2013 wes hayutin <whayutin@redhat.com> 0.0.5-32
- added more validation for the filters, also changed status to Subscription
  Status on the filter pages (whayutin@redhat.com)
- add lifecycle state to filter help popup (whayutin@redhat.com)
- fix filter state array (whayutin@redhat.com)
- update filter, edit filter for lifecycle state. Update reports controller for
  lifecycle state (whayutin@redhat.com)
- first pass at adding deleted systems, have it all in one report atm
  (whayutin@redhat.com)
- Fix timestamp on tag for devel env (jwmatthews@gmail.com)
- 977445 - ruby193-rubygem-splice_reports has wrong license file packaged
  (jwmatthews@gmail.com)

* Tue Jul 16 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-31
- 977453 - splice components should use same license (jwmatthews@gmail.com)
- Added run of 'rails s' at end of devel env setup scripts
  (jwmatthews@gmail.com)
- Scripts to launch a katello/splice devel env in EC-2 (jwmatthews@gmail.com)
- Fix missing 'echo' in script (jwmatthews@gmail.com)
- added tests, modified the way populate data works, updated setup_splice
  (whayutin@redhat.com)
- fix call to get dates (whayutin@redhat.com)
- added some more help messages to vagrant devel setup (whayutin@redhat.com)
- add sample data to build (whayutin@redhat.com)
- Added more instructions at end of splice install (jwmatthews@gmail.com)
- Added an error message when katello-reset-dbs fails, prompts user to ensure
  katello has been refreshed (jwmatthews@gmail.com)
- remove sublime files (whayutin@redhat.com)
- install sst (cduryee@redhat.com)
- fixed merge conflict (whayutin@redhat.com)
- merge in nutupane (whayutin@redhat.com)
- breaking out a report_index.js file.. (whayutin@redhat.com)
- the tipsy info on the report keeps interfering w/ the dashboard and becomes
  hidden behind the other objects.. The top left hand corner is a safer spot to
  place this tip for now (whayutin@redhat.com)
- del mpu file if created (whayutin@redhat.com)
- first pass at combining active, inactive and deleted systems
  (whayutin@redhat.com)
- updated data load scripts (whayutin@redhat.com)
- committed changes for the updated nutupane, added Routes, nutupane is now
  instantiated (whayutin@redhat.com)

* Tue Jul 02 2013 wes hayutin <whayutin@redhat.com> 0.0.5-30
- Merge branch 'wes_test' (whayutin@redhat.com)
- broke out the mongo aggragtion into its own class, and changed the cuke tests
  to use that class (whayutin@redhat.com)
- Update vagrant devel to cleanup prior setups with katello db/schema.rb, also
  save setup runs to separate log files (jwmatthews@gmail.com)
- Fix syntax issue with clear splice script (jwmatthews@gmail.com)
- adding more tests (whayutin@redhat.com)
- Clear prior splice_reports installs when using Vagrant (jwmatthews@gmail.com)
- have cuke running queries successfully (whayutin@redhat.com)
- Do not run "railties:install:migrations" (jwmatthews@gmail.com)
- Move common vars to env_vars (jwmatthews@gmail.com)
- Ignore .vagrant (jwmatthews@gmail.com)
- Update so KATELLO_GIT_PATH is consistent with both scripts
  (jwmatthews@gmail.com)
- first pass at breaking out the mongo aggregtion query, have it running
  independently of rails (whayutin@redhat.com)
- Change location of Katello checkout to be relative to this directory
  (jwmatthews@gmail.com)
- Updating gems for rspec/cucumber (jwmatthews@gmail.com)
- Adding scripts to launcha  katello+splice devel env in a VM.  Needs more work
  on splice integration to Katello (jwmatthews@gmail.com)

* Mon Jun 24 2013 wes hayutin <whayutin@redhat.com> 0.0.5-29
- changed fitler removal message s/provider/filter/ (whayutin@redhat.com)

* Mon Jun 24 2013 wes hayutin <whayutin@redhat.com> 0.0.5-28
- bz#977314 fix for check-in's not found when there are older and newer
  checkins than the specified date range (whayutin@redhat.com)

* Wed Jun 19 2013 wes hayutin <whayutin@redhat.com> 0.0.5-27
- finally have a working query for active and inactive systems.. inactive =
  find latest checkin for each instance.. if a checkin is not gt than
  start_date => inactive (whayutin@redhat.com)
- update playpen script (whayutin@redhat.com)

* Wed Jun 19 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-26
- Update path for pub key (jwmatthews@gmail.com)

* Wed Jun 19 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-25
- Update spec to install pub key from etc/pki instead of playpen/example
  (jwmatthews@gmail.com)

* Wed Jun 19 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-24
- Update public gpg key with beta key, private is in internal cloude.git
  (jwmatthews@gmail.com)

* Wed Jun 19 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-23
- missed a row (whayutin@redhat.com)
- update test data (whayutin@redhat.com)
- moved the date filter back in front of the mongo grouping, put an end date on
  inactive queries and increased the checkin detail limit from 50 to 250
  (whayutin@redhat.com)

* Mon Jun 17 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-22
- adding another example json file (whayutin@redhat.com)
- del mpu file if created (whayutin@redhat.com)
- updated data load scripts (whayutin@redhat.com)
- changed status sort to DESCENDING, still not working ideally.. when the table
  is paginated the sort does not work as expected (whayutin@redhat.com)
- fix for pagination not working.. count was set to page instead of total
  (whayutin@redhat.com)

* Thu Jun 13 2013 wes hayutin <whayutin@redhat.com> 0.0.5-21
- added gpl notice (whayutin@redhat.com)

* Thu Jun 13 2013 wes hayutin <whayutin@redhat.com> 0.0.5-20
- moved date back to after the mongo group, also reverted the count to cycle
  through the systems.  This is much slower but with deleted and inactive
  systems getting added we need to simplify (whayutin@redhat.com)

* Fri Jun 07 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-19
- 

* Fri Jun 07 2013 wes hayutin <whayutin@redhat.com> 0.0.5-18
- moving the matching date range before the mongo agg. grouping to fix a bug
  where checkins were not found, however the checkin count was found
  (whayutin@redhat.com)
- updated system not found message (whayutin@redhat.com)

* Thu Jun 06 2013 wes hayutin <whayutin@redhat.com> 0.0.5-17
- added tool tips for filter creation (whayutin@redhat.com)

* Wed Jun 05 2013 John Matthews <jwmatthews@gmail.com> 0.0.5-16
- Getting ready to build in brew (jwmatthews@gmail.com)
- add some spacing if the filter description is very long (whayutin@redhat.com)
- fixed some report table rendering issues in firefox (whayutin@redhat.com)
- updated report rules ordering to fix an older checkin showing up in inactive
  reports (whayutin@redhat.com)

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
