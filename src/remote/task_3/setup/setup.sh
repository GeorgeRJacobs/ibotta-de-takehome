#!/bin/zsh

echo "Setting up Remote EMR Environment & Port Forwarding"
zsh src/remote/task_3/setup/0_setup_key_pair.sh

echo "SparkMagic implementation"
zsh src/remote/task_3/setup/1_setup_sparkmagic.sh

echo "Port Forwarding"
zsh src/remote/task_3/setup/2_enable_port_forwarding.sh
