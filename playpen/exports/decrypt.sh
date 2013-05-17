if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` {encrypted file}"
    exit 1
fi

IN_FILE=$1
SEC_KEY="./example/splice_reports_key.gpg.sec"
OUT_DIR="./output"
KEY_RING="${OUT_DIR}/keyring"
OUT_FILE="${OUT_DIR}/decrypted_data"

if [ ! -e ${SEC_KEY} ]; then
    echo "Unable to find secret GPG key at: ${SEC_KEY}"
    exit 1
fi
if [ ! -r ${SEC_KEY} ]; then
    echo "Unable to read secret GPG key at: ${SEC_KEY}"
    echo "Consider re-running with 'sudo'"
    exit 1
fi

if [ ! -e ${OUT_DIR} ]; then
    mkdir ${OUT_DIR}
fi

if [ ! -e ${IN_FILE} ]; then
    echo "Unable to find encrypted file to decrypt at: ${IN_FILE}"
    exit 1
fi


gpg --import --no-default-keyring --secret-keyring ${KEY_RING} ${SEC_KEY}
gpg --decrypt --no-default-keyring --secret-keyring ${KEY_RING} -o ${OUT_FILE} ${IN_FILE}

echo "Ran:"
echo gpg --import --no-default-keyring --secret-keyring ${KEY_RING} ${SEC_KEY}
echo gpg --decrypt --no-default-keyring --secret-keyring ${KEY_RING} -o ${OUT_FILE} ${IN_FILE}
