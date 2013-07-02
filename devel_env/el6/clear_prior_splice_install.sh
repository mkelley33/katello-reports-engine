source ./env_vars

if [ -f ${KATELLO_GIT_PATH}/bundler.d/splice_reports.rb ]; then
    echo "Removing prior bundler.d/splice_reports.rb install"
    rm ${KATELLO_GIT_PATH}/bundler.d/splice_reports.rb
fi

