cp ./example/splice_reports_key.gpg.pub /etc/pki/splice/

if [ ! -e /etc/splice/splice_reports.yml ]; then
    ln -s "`pwd`/../../etc/splice/splice_reports.yml" /etc/splice/splice_reports.yml
fi


