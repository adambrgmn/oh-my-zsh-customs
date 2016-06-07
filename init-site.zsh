#!/bin/bash

function init-site {
  ##### Variables
  PROGNAME=$0
  MY_IP=$(ifconfig eth0 | sed -n '/inet addr/s/.*addr.\([^ ]*\) .*/\1/p')
  ROOT=/srv/
  SITE_URL="test.com"
  START_SCRIPT="npm start"
  CURR_USER=$(logname)
  CURR_GROUP=$(groups $(whoami) | cut -d' ' -f1)

  ##### Colorize
  black=$(tput setaf 0)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
  white=$(tput setaf 7)

  reset=$(tput sgr0)



  echo -n "Site URL ($SITE_URL): "
  read response
  if [ "${response}" != "" ]; then
    SITE_URL=${response}
  fi

  echo -n "Start script ($START_SCRIPT): "
  read response
  if [ "${response}" != "" ]; then
    START_SCRIPT=${response}
  fi

  site_dir=${ROOT}www/${SITE_URL}
  repo_dir=${ROOT}repo/${SITE_URL}.git


  ##### Functions

  function error_exit {
    echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    exit 1
  }

  function make_directories {
    sudo mkdir -p ${site_dir} ${repo_dir} || error_exit "${LINENO}: Could not create directories. Exiting."
    sudo chown -R ${CURR_USER}:${CURR_GROUP} ${site_dir} ${repo_dir} || error_exit "${LINENO}: Could not change ownership. Exiting."
  }

  function init_git {
    cd ${repo_dir} || error_exit "${LINENO}: Could not change directory. Exiting."
    git init --bare || error_exit "${LINENO}: Could not initialize git repo. Exiting."
  }

  function create_hook {
    echo \
    "#!/bin/sh

    error_exit () {
      echo \"$1\" 1>&2
      exit 1
    }

    git --work-tree=${site_dir} --git-dir=${repo_dir} checkout -f
    cd ${site_dir} || error_exit \"Error changing directory. Exiting.\"
    npm install || error_exit \"Error running npm install. Exiting.\"
    ${START_SCRIPT} || error_exit \"Error starting process. Exiting.\"" \
    >> ./hooks/post-receive || error_exit "${LINENO}: Could not create hook. Exiting."

    sudo chmod +x ./hooks/post-receive || error_exit "${LINENO}: Could not make post-receive executable. Exiting."
  }

  make_directories || error_exit "${LINENO}: Failed to create directories. Exiting."
  init_git || error_exit "${LINENO}: Failed to initialize git. Exiting."
  create_hook || error_exit "${LINENO}: Failed to create hook. Exiting."

  echo -e "\n\n\n\n"
  echo -e "${cyan}--------------------------------------------------${reset}"
  echo -e "${cyan}--------------------------------------------------${reset}"
  echo -e "                    ${red}Everything${reset}"
  echo -e "                    ${red}is set up!${reset}"
  echo -e "\n"
  echo -e "The repo is located at: ${yellow}${repo_dir}${reset}"
  echo -e "The sites files is located at: ${yellow}${site_dir}${reset}"
  echo -e "${cyan}--------------------------------------------------${reset}"
  echo -e "Run ${red}\"git remote add production ${CURR_USER}@${MY_IP}:${repo_dir}\"${reset} on your local repo"
  echo -e "When ready to push to production: ${red}\"git push production master\"${reset}"

  exit 0
}
