#!/bin/zsh
echo "Setting up Spark Magic"
jupyter nbextension enable --py --sys-prefix widgetsnbextension
jupyter labextension install "@jupyter-widgets/jupyterlab-manager"

var=`python -c "import sparkmagic as _; import os; print(os.path.dirname(_.__path__[0]))"`
cd $var
jupyter-kernelspec install sparkmagic/kernels/pysparkkernel
jupyter-kernelspec install sparkmagic/kernels/sparkkernel
jupyter serverextension enable --py sparkmagic