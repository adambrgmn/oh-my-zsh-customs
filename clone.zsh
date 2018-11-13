CL_RED='\033[0;31m'
CL_BLUE='\033[0;34m'
CL_NONE='\033[0m'

function clone() {
  if [ $# -eq 0 ]; then
    echo -e "No arguments specified. usage: \n${CL_BLUE}clone [repo-name] [local-dir] [github-user]${CL_NONE}";
    return 1;
  fi

  if [ -z ${3+x}]; then
    GITHUB_USER=$(git config --global github.user)
  else;
    GITHUB_USER=${3}
  fi

  if [[ -z "${GITHUB_USER// }" ]]; then
    echo -e "${CL_RED}Github user must be defined in ~/.gitconfig\n${CL_NONE}Set it using ${CL_BLUE}git config --global github.user [username]${CL_NONE}"
    return 1;
  fi

  if [ -z ${2+x} ]; then
    CLONE_DIR=${1}
  else;
    CLONE_DIR=${2}
  fi

  echo ${GITHUB_USER}
  git clone git@github.com:${GITHUB_USER}/${1}.git ${CLONE_DIR}
  cd ${CLONE_DIR}
}