#!/bin/zsh

echo "Setting up Remote EMR Environment & Port Forwarding"
zsh src/remote/task_3/setup/0_setup_key_pair.sh

zsh src/remote/task_3/setup/1_start_emr_w_jupyter.sh

zsh src/remote/task_3/setup/2_setup_sparkmagic.sh

zsh src/remote/task_3/setup/3_enable_port_forwarding.sh
