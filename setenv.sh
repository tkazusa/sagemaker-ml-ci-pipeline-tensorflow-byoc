# train
TRAIN_URL=$(python setenv.py train train_url)
DATA_PATH=$(python setenv.py train data_path)
BATCH_SIZE=$(python setenv.py train hyper_parameter batch_size)
EPOCH=$(python setenv.py train hyper_parameter epoch)