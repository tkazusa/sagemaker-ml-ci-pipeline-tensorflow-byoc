参考にしているのは、これ
https://github.com/aws-samples/amazon-sagemaker-examples-jp/blob/master/tensorflow2_training_and_serving/tensorflow2_training_and_serving.ipynb


これは Tensorflow イメージ使ってる、こっちは Dockerfile からイメージビルド

データはこのオープンなバケットにあるものを
training_data_uri = f's3://sagemaker-sample-data-{region}/tensorflow/mnist/'
print(training_data_uri)
!aws s3 ls {training_data_uri}

コンテナの準備
アカウントIDとリージョンを　ecr-train.sh へ入力
815969174475
us-east-1



flow.yaml の解説
- train_url は、ビルドした環境 → 本当は Account ID とか region とかに分けたい。いや提供しているものを使う体だから、url でいいのか。
