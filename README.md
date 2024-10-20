
~/.zshrc

```
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
```


source ~/.zshrc

pyenv install --list

pyenv install 3.11.9

pyenv global 3.11.9

python --version