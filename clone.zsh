CL_RED='\033[0;31m'
CL_BLUE='\033[0;34m'
CL_NONE='\033[0m'

function clone() {
  if [ $# -eq 0 ]; then
    echo -e "No arguments specified. usage: \n${CL_BLUE}clone [repo-name]${CL_NONE}";
    return 1;
  fi

  github_user=$(git config --global github.user)

  if [[ -z "${github_user// }" ]]; then
    echo -e "${CL_RED}Github user must be defined in ~/.gitconfig\n${CL_NONE}Set it using ${CL_BLUE}git config --global github.user [username]${CL_NONE}"
    return 1;
  fi

  git clone git@github.com:${github_user}/${1}.git ${2}
}