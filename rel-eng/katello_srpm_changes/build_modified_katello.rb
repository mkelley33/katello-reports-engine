#!/usr/bin/env ruby

require 'fileutils'

def src_dir
  File.expand_path File.dirname(__FILE__)
end

DEFAULT_TMP_DIR="#{Dir.pwd}/tmp"
DEFAULT_OUT_DIR="#{Dir.pwd}/out"
KATELLO_GIT_URL="https://github.com/Katello/katello.git"
SPEC_PATCH="#{src_dir}/splice_reports_precompile.patch"
PATCHES=["#{src_dir}/splice_reports_1.patch"]

def tmp_dir
  DEFAULT_TMP_DIR
end

def out_dir
  DEFAULT_OUT_DIR
end

def work_dir
  "#{tmp_dir}/work"
end

def rpmbuild_dir
  "#{out_dir}/rpmbuild"
end

def get_dist
  "el6_splice"
end

def patches
  PATCHES
end

def cmd(command)
  output = `#{command}`
  raise "Error running '#{command}`\n#{output}\nExit Code: #{$?.exitstatus}" unless $?.exitstatus == 0
  output
end

def clean_work_dir
  FileUtils.rm_rf(work_dir)
end

def ensure_dirs_exist(dirs)
  clean_work_dir
  dirs.each do |path|
    FileUtils.mkdir_p path unless File.exists? path
  end
end

def setup_rpmbuild_env
  dirs = ["BUILD","RPMS","SOURCES","SPECS","SRPMS"]
  dirs.each do |d|
    path = "#{rpmbuild_dir}/#{d}"
    FileUtils.mkdir_p path unless File.exists? path
  end
end

def get_srpm_path(output)
  m = output.match(/^Wrote: (.*\.src\.rpm)/)
  if m
    return m.captures[0]
  else
    raise "Unable to determine generated SRPM from output of: '#{output}'"
  end
end

def fetch_katello_git
  cmd("cd #{tmp_dir} && git clone #{KATELLO_GIT_URL}") unless File.exists? "#{tmp_dir}/katello"
  cmd("cd #{tmp_dir}/katello && git pull --rebase")
end

def generate_srpm
  output = cmd("cd #{tmp_dir}/katello && tito build --test --srpm -o #{tmp_dir}")
  get_srpm_path(output)
end

def patch_srpm raw_srpm
  cmd("cp #{raw_srpm} #{work_dir}")
  cmd("cd #{work_dir} && rpm2cpio #{raw_srpm} | cpio -i")
  cmd("cd #{work_dir} && patch -p0 < #{SPEC_PATCH}")
  # Note:  We are using sed to modify the katello.spec below opposed to putting these changes
  # in the .patch file because the .spec is going to slightly change each time there is a new
  # build/commit to katello master.  To avoid patches failing, we are trying to isolate those
  # associated with text that will change and cause patch applying to be rejected.
  cmd("sed -i '/^Release:/ s/$/_splice/' #{work_dir}/katello.spec")
  cmd("sed -i '/^%setup -q .*/ s/$/\\n%patch1 -p1 -b .splice_reports_1/' #{work_dir}/katello.spec")
  cmd("cd #{work_dir} && cp katello-*.tar.gz #{rpmbuild_dir}/SOURCES")
  patches.each do |path|
    cmd("cd #{work_dir} && cp #{path} #{rpmbuild_dir}/SOURCES")
  end
  output = cmd("cd #{work_dir} && rpmbuild --define '_topdir #{rpmbuild_dir}' -bs katello.spec -D 'scl ruby193'")
  get_srpm_path(output)
end

def build_srpm patched_srpm
  cmd("rpmbuild --define '_topdir #{rpmbuild_dir}' --rebuild #{patched_srpm} -D 'scl ruby193'")
end

if __FILE__ == $0

  ensure_dirs_exist [out_dir, tmp_dir, work_dir, rpmbuild_dir]

  setup_rpmbuild_env

  fetch_katello_git
  raw_srpm = generate_srpm 
  patched_srpm = patch_srpm raw_srpm
  build_srpm patched_srpm
  puts ""
  puts "Success!"
  puts ""
  puts "Raw Katello SRPM formed at: '#{raw_srpm}'"
  puts "Patched Katello SRPM formed at: `#{patched_srpm}`"
  puts "SRPM has been built and is available under: #{rpmbuild_dir}"
end

