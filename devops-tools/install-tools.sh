#!/bin/bash
dir="${HOME}/.oh-my-zsh/custom/plugins/devops-tools/"
if [ ! -d "${dir}" ]; then
  mkdir -p "${dir}"
fi

cp ./devops-tools.plugin.zsh ${dir}/devops-tools.plugin.zsh