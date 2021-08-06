# Amazon SageMaker と AWS CodeBuild による機械学習の継続的インテグレーション BYOC編

本サンプルコードは、機械学習モデル開発へのガバナンス強化を目的に、継続的インテグレーションのビルドプロジェクトの中でモデルの学習を行うものです。

学習のための Docker イメージや、学習にまつわるパラメーターなどは `flow.yaml` に設定として定義します。機械学習ビルド中に実行するワークフローは [AWS Step Fuinctions](https://aws.amazon.com/jp/step-functions/) で定義してあり、[AWS Step Functions Data Science SDK](https://docs.aws.amazon.com/ja_jp/step-functions/latest/dg/concepts-python-sdk.html) を用いて Python で `pipeline.py` で定義してあります。ワークフロー中でのデータの前処理や学習の実行には[AWS Glue](https://aws.amazon.com/jp/glue/) [Amazon SageMaker](https://aws.amazon.com/jp/sagemaker/) を活用しています。 [AWS CodeBuild](https://aws.amazon.com/jp/codebuild/) でのビルド仕様は `buildspec.yaml` に定義してあります。

## 実行手順
### Step1. GtiHub リポジトリをフォークする
本サンプルコードは GitHub リポジトリと AWS CodeBuild を連携させてビルド中に機械学習モデルの学習を行います。このプロセスはリポジトリへのプッシュをトリガーにするため、 後ほど GitHub のアカウントと CodeBuild の接続が必要になります。その前準備として、このハンズオンの[リポジトリ](https://github.com/tkazusa/sagemaker-ml-ci-pipeline-xgboost)をフォークします。


### Step2. SageMaker notebook を作成する
Amazon SageMaker ノートブックインスタンスを立ち上げます。

- ロールを新規に作成し、任意の S3 バケットへのアクセス権限を付与する。
- `Clone a public Git repository to this notebook instance only`  を選択し、このリポジトリをクローン
- ノートブックインスタンスが ‘InService’ になるのを確認


### Step3. データを Amazon S3 バケットへアップロードする
本ハンズオンでは、ニューヨークのタクシー運賃データを活用します。
- `dataprep.ipynb` を実行し、末尾のセルを実行した際に表示されているバケット名を保存する。


### Step4. IAM ロールを作成する
データの前処理、学習といったステップやパイプラインの実行において AWS リソースが活用する IAM ロールを準備します。 IAM ロールの作成については、[こちら](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_roles_create.html)をご確認ください。

- AWS Glue の IAM ロールへ付与するポリシー: `AWSGlueServiceRole`, `S3FullAccess`
- SageMaker の IAM ロールへ付与するポリシー: `AWSStepFunctionsFullAccess`, `AmazonSageMakerFullAccess`
- AWS StepFunctions の IAM ロールへ付与するポリシー: `AWSGlueServiceRole`, `AmazonSageMakerFullAccess`, `AWSStepFunctionsFullAccess`
    
  
それぞれ作成したロールの ARN は後ほど活用するので保存しておいて下さい。


### Step.5 AWS CodeBuild のビルドプロジェクトを作成する

本ハンズオンでは CodeBuild でのビルド中に機械学習モデルの学習を行います。
AWS CodeBuildから、「ビルドプロジェクト」→「ビルドプロジェクトを作成する」へ進んで下さい。ビルドプロジェクトの作成画面で設定を行っていきます。

まずは、プロジェクト名を指定します。

![img1](img/img1-byoc.png)

ソースプロバイダの設定を行います。ソースプロバイダを GitHub にし、OAuth もしくはアカウントトークンを使って GitHub と接続します。

![img2](img/img2.png)

クローンしてきた GitHub リポジトリを連携するよう指定します。

![img3](img/img3.png)


ウェブフックイベントをプルリクエストの作成と更新時に設定します。

![img4](img/img4.png)


ビルド環境の設定を下記のように行います。

![img5](img/img5.png)


Buildspec は下記のように指定します。

![img6](img/img6.png)


ビルドプロジェクト作成時に作成した `codebuild-sagemaker-ci-pipeline-xgboost-service-role` へ下記のポリシーを追加します。

- `StepFunctionsFullAccess`
- `AWSCodebuildDeveloperAccess`
- `AmazonS3FullAccess`
- `AWSGlueServiceRole`
    
下記インラインポリシーを作成して追加します。
```JSON
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"iam:PassRole"
			],
			"Effect": "Allow",
			"Resource": "*"
		}
	]
}
```


### Step6. ビルドプロジェクトの実行
SageMaker Notebook 上からスクリプトへの変更を実行し、プルリクエストを更新することで、ビルドプロジェクトを実行します。

- SageMaker ノートブックインスタスにて JupyterLab を開きます。
- ターミナルを起動して、新しいブランチ `model-dev` を作成し、チェックアウトします。

```Bash
$ cd SageMaker/
$ git checkout -b model-dev
```

`pipeline.py` 中の下記項目を設定します。

```Python
BUCKET = '<データを準備した際に保存したバケット>'
FLOW_NAME = 'flow_{}'.format(id) 
TRAINING_JOB_NAME = 'sf-train-{}'.format(id) # To avoid duplication of job name
GLUE_ROLE = '<Glue に付与するロール>'
SAGEMAKER_ROLE = '<SageMaker に付与するロール>'
WORKFLOW_ROLE ='<Step Functions に付与するロール>'
```

git 上にて変更を反映します。

```Bash
$ git add pipeline.py
$ git commit -m “mod pipeline.py”
$ git push origin HEAD
```

GitHub リポジトリ上で Pull Request を作成します。ビルドプロジェクトが成功すると下記のような表示が出ます。

![img7](img/img7.png)
