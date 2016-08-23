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
        echo_info "Ok, I won't initialize NPM, but be aware that the packages may not work as you want."
      fi
    fi
  }

  function babel {
    npm install --save-dev babel-cli babel-preset-{es2015,es2016,stage-0,react,react-hmre} babel-plugin-{syntax-trailing-function-commas,transform-class-properties,transform-object-rest-spread,transform-runtime}
    echo "{
      \"presets\": [\"es2015\", \"stage-0\", \"react\"],
      \"plugins\": [
        \"syntax-trailing-function-commas\",
        \"transform-class-properties\",
        \"transform-object-rest-spread\",
        [\"transform-runtime\", {
          \"helpers\": false,
          \"polyfill\": false,
          \"regenerator\": true
        }]
      ]
      \"env\": {
        \"start\": {
          \"presets\": [\"react-hmre\"]
        }
      }
    }" >> .babelrc || error_exit "${LINENO}: Unable to init Babel"
    initialized+=" babel"
  }

  function eslint {
    npm install --save-dev eslint eslint-config-airbnb eslint-plugin-{import,react,jsx-a11y,flowtype} babel-eslint
    echo "{
      \"parser\": \"babel-eslint\",
      \"extends\": \"airbnb\",
      \"plugins\": [\"react\", \"jsx-a11y\", \"import\"],
      \"env\": {
        \"browser\": true,
        \"commonjs\": true,
        \"es6\": true,
        \"node\": true,
        \"mocha\": true
      },
      \"parserOptions\": {
        \"ecmaVersion\": 6,
        \"sourceType\": \"module\",
        \"ecmaFeatures\": {
          \"jsx\": true,
          \"generators\": true,
          \"experimentalObjectRestSpread\": true,
        }
      },
      \"settings\": {
        \"import/ignore\": [
          \"node_modules\",
          \"\\\\.(json|css|jpg|png|gif|eot|otf|svg|ttf|woff|woff2|mp4|webm)$',\"
        ],
        \"import/extensions\": [\".js\"],
        \"import/resolver\": {
          \"node\": {
            \"extensions\": [\".js\", \".json\"]
          }
        }
      },
      \"rules\": {
        \"strict\": 0,
        \"no-console\": 0,
        \"react/jsx-filename-extension\": 0,
        \"flowtype/define-flow-type\": \"warn\",
        \"flowtype/require-valid-file-annotation\": \"warn\",
        \"flowtype/use-flow-type\": \"warn\"
      }
    }" >> .eslintrc || error_exit "${LINENO}: Unable to init Eslint"
    initialized+=" eslint"
  }

  function stylelint {
    npm install --save-dev stylelint stylelint-config-standard
    echo "{
      \"extends\": \"stylelint-config-standard\",
      \"plugins\": [],
      \"rules\": {
        \"font-family-name-quotes\": \"always-unless-keyword\",
        \"function-url-quotes\": \"always\",
        \"selector-attribute-quotes\": \"always\",
        \"string-quotes\": \"double\",
        \"at-rule-no-vendor-prefix\": true,
        \"media-feature-name-no-vendor-prefix\": true,
        \"property-no-vendor-prefix\": true,
        \"selector-no-vendor-prefix\": true,
        \"value-no-vendor-prefix\": true,
        \"max-nesting-depth\": [3, {
          \"ignore\": \"at-rules-without-declaration-blocks\"
        }],
        \"selector-max-compound-selectors\": 3,
        \"selector-max-specificity\": \"0,3,0\",
        \"at-rule-no-unknown\": [true, {
          \"ignoreAtRules\": [\"include\", \"mixin\"]
        }],
        \"declaration-no-important\": true,
        \"property-no-unknown\": true,
        \"declaration-block-properties-order\": [
          [
            {
              \"order\": \"flexible\",
              \"properties\": [
                \"position\",
                \"z-index\",
                \"top\",
                \"right\",
                \"bottom\",
                \"left\"
              ]
            },
            {
              \"order\": \"flexible\",
              \"properties\": [
                \"display\",
                \"overflow\",
                \"box-sizing\",
                \"width\",
                \"max-width\",
                \"height\",
                \"max-height\",
                \"padding\",
                \"border\",
                \"margin\"
              ]
            },
            {
              \"order\": \"flexible\",
              \"properties\": [
                \"transform\"
              ]
            },
            {
              \"order\": \"flexible\",
              \"properties\": [
                \"background\",
                \"color\"
              ]
            },
            {
              \"order\": \"flexible\",
              \"properties\": [
                \"font\",
                \"line\",
                \"text\"
              ]
            }
          ],
          {
            \"unspecified\": \"bottom\"
          }
        ]
      }
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
        echo_error "${arg} is not an initializer \nTry babel, eslint or stylelint instead"
      fi
    done

    echo_info "Everything ($(echo -e "${initialized}" | sed -e 's/^[[:space:]]*//')) is set up!"
  fi
}
