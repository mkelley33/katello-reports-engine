source ./source_me

if [ ! -e ${INSTALL_DIR} ]; then
    mkdir ${INSTALL_DIR}
fi

sudo cp ${MY_SEC_KEY} ${INSTALL_DIR}
