#!/bin/bash
# A function to init certain things necessary for Node- and webdevelopment
function init {
  ### VARIABLES
  initialized=""

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


  ## FUNCTIONS
  function echo_info {
    message="${1}"
    size=${#message}
    dashes=""

    for ((n=0;n<${size};n++))
    do
      dashes+="-"
    done

    echo -e "\n"
    echo -e "${cyan}${dashes}${reset}"
    echo -e "${green}${message}${reset}"
    echo -e "${cyan}${dashes}${reset}"
    echo -e "\n"
  }

  function echo_silly {
    message="${1}"

    echo -e "\n"
    echo -e "${blue}${message}${reset}"
    echo -e "\n"
  }

  function echo_error {
    message="${1}"

    echo -e "\n"
    echo -e "${red}${message}${reset}"
    echo -e "\n"
  }

  function error_exit {
    echo "${red}${PROGNAME}:${reset} ${1:-"Unknown Error"}" 1>&2
    exit 1
  }

  function checknpm {
    if test -f "./package.json"; then
      echo_silly "package.json exists, good to go"
    else
      echo -n "${green}NPM is not initialized, do you want to init NPM?${reset} (Y/n): "
      read response
      if [ "${response}" = "" ] || [ "${response}" = "Y" ] || [ "${response}" = "y" ]; then
        npm init -y || error_exit "${LINENO}: Couldn't initialize NPM, try to do it manually."
      else
        echo_info "Ok, I wont initialize NPM, but be aware that the packages may not work as you want."
      fi
    fi
  }

  function babel {
    npm install --save-dev babel babel-preset-{es2015,stage-0,react,react-hmre}
    echo "{
      \"presets\": [\"es2015\", \"stage-0\", \"react\"],
      \"env\": {
        \"start\": {
          \"presets\": [\"react-hmre\"]
        }
      }
    }" >> .babelrc || error_exit "${LINENO}: Unable to init Babel"
    initialized+=" babel"
  }

  function eslint {
    npm install --save-dev eslint eslint-config-airbnb eslint-plugin-{import,react,jsx-a11y} babel-eslint
    echo "{
      \"parser\": \"babel-eslint\",
      \"extends\": \"airbnb\",
      \"rules\": {
        \"strict\": 0
      }
    }" >> .eslintrc || error_exit "${LINENO}: Unable to init Eslint"
    initialized+=" eslint"
  }

  function stylelint {
    npm install --save-dev stylelint stylelint-config-standard
    echo "{
      \"extends\": \"stylelint-config-standard\"
    }" >> .stylelintrc || error_exit "${LINENO}: Unable to init Stylelint"
    initialized+=" stylelint"
  }

  # RUNNER
  if [ "${1}" = "" ]; then
    echo_error "You have not defined anything to init \nIt's possible to init babel, eslint and stylelint (or all)"
    echo -n "${red}Would you like to init them all?${reset} (Y/n): "
    read response
    if [ "${response}" = "" ] || [ "${response}" = "Y" ] || [ "${response}" = "y" ]; then
      init all
    else
      echo_info "Ok, all good, see you next time!"
    fi
  else
    echo_info "Ok, time to initialize!"
    checknpm

    for arg in "${@}"
    do
      if [ "${arg}" = "babel" ]; then
        babel
      elif [ "${arg}" = "eslint" ]; then
        eslint
      elif [ "${arg}" = "stylelint" ]; then
        stylelint
      elif [ "${arg}" = "all" ]; then
        babel
        eslint
        stylelint
      else
        echo_error "${arg} is not an initializer \nTyr babel, eslint or stylelint instead"
      fi
    done

    echo_info "Everything ($(echo -e "${initialized}" | sed -e 's/^[[:space:]]*//')) is set up!"
  fi
}
