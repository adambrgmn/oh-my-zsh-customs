# A shorthand alias to init eslint with Airbnb preset
alias init-eslint="npm i -D eslint eslint-config-airbnb eslint-plugin-{import,react,jsx-a11y} babel-eslint && echo '{
  \"parser\": \"babel-eslint\",
  \"extends\": \"airbnb\",
  \"rules\": {
    \"strict\": 0
  }
}' > .eslintrc"

# A shorthand alias to init Babel with basic presets
alias init-babel="npm i -D babel babel-preset-{es2015,stage-0,react,react-hmre} && echo '{
  \"presets\": [\"es2015\", \"stage-0\", \"react\"],
  \"env\": {
    \"start\": {
      \"presets\": [\"react-hmre\"]
    }
  }
}' > .babelrc"

alias init-stylelint="npm i -D stylelint stylelint-config-standard && echo '{
  \"extends\": \"stylelint-config-standard\"
}' > .stylelintrc"
