#!/bin/bash

function init-site {
  ##### Variables
  PROGNAME=$0
  MY_IP=$(ifconfig eth0 | sed -n '/inet addr/s/.*addr.\([^ ]*\) .*/\1/p')
  # ROOT=/srv/
  ROOT=~/Desktop/
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

  function setup_nginx {
    # NGINX_SITES_AVAILABLE=/etc/nginx/sites-available
    # NGINX_SITES_ENABLED=/etc/nginx/sites-enabled
    NGINX_SITES_AVAILABLE=~/Desktop/
    NGINX_SITES_ENABLED=~/Desktop/

    sudo echo \
    "upstream ${SITE_URL}_upstream {
      server 127.0.0.1:3000;
      keepalive 64;
    }

    server {
      listen 80;
      # listen 443 ssl;
      # ssl_certificate /some/location/pomodore.fransvilhelm.com.bundle.crt;
      # ssl_certificate_key /some/location/pomodore.fransvilhelm.com.key;
      # ssl_protocols SSLv3 TLSv1;
      # ssl_ciphers HIGH:!aNULL:!MD5;

      server_name ${SITE_URL}
      root ${site_dir}

      location ~* \\.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp3|mp4|ogg|ogv|webm|htc)$ {
        try_files /public/\$uri =404;
        expires 1M;
        access_log off;
        add_header Cache-Control \"public\";
      }

      location ~* \\.(?:css|js)$ {
        try_files /public/\$uri =404;
        expires 1M;
        access_log off;
        add_header Cache-Control \"public\";
      }

      location / {
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Host \$http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_set_header Connection \"\";
        proxy_http_version 1.1;
        proxy_cache one;
        proxy_cache_min_uses 3;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;
        proxy_cache_key sfs\$request_uri\$scheme;

        proxy_pass ${SITE_URL}_upstream;
      }
    }" >> ${NGINX_SITES_AVAILABLE}/${SITE_URL} || error_exit "${LINENO}: Failed create configuration file. Exiting"

    sudo ln -s ${NGINX_SITES_AVAILABLE}/${SITE_URL} ${NGINX_SITES_ENABLED}/${SITE_URL} || error_exit "${LINENO}: Failed to link files between sites-available and sites-enabled. Exiting"
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
  echo -e "${cyan}--------------------------------------------------${reset}"

  echo -n "${red}Would you also like to setup Nginx for ${SITE_URL}? (Y/n)"
  read response
  if [ "$($response | awk '{print toupper($0)}')" = "Y" ]; then
    setup_nginx || error_exit "${LINENO}: Failed to setup Nginx. Exiting"
  fi
}
