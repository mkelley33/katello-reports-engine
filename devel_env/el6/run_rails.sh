source ./env_vars

rpm -q screen
if [ $? -eq '1' ]; then
  sudo yum install -y screen
fi

screen -dmS 'rails'
screen -S rails -p 0 -X stuff "cd ${KATELLO_GIT_PATH} && sudo scl enable ruby193 'rails s'
"

echo "A Rails development server is now running listening on :3000"
echo "You may access the screen session by: 'sudo screen -r rails'"

