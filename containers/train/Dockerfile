FROM tensorflow/tensorflow:nightly-gpu

# かつては RUN pip install sagemaker-containers を行っていた
# install the SageMaker Training Toolkit 
RUN pip3 install sagemaker-training

# Copies the training code inside the container
# Directory structure in SageMaker training instance is followings.
# opt/
# ├ /ml
#    ├ code
#      ├ tf_model.py
#      └ train.py
# └ ml/
#  ├ input/
#    └ data/
#  └ model/
COPY mnist /opt/ml/code/

# SageMaker SDK で学習のために使うスクリプト(エントリーポイントと呼ばれている)を指定。
# SAGEMAKER_PROGRAM はデフォルトでは /opt/ml/code/ 以下を指す。
# 絶対パスを指定しても良い。
# define train.py as the script entry point
ENV SAGEMAKER_PROGRAM train.py