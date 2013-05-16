source ./source_me

gpg --import --no-default-keyring --secret-keyring ${KEY_RING} ${MY_SEC_KEY}
gpg --decrypt --no-default-keyring --secret-keyring ${KEY_RING} -o ${OUTPUT_DECRYPT} ${FILE_TO_DECRYPT} 


