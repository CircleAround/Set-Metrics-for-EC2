# AWS Lambda's script for Auto Attach and Detach CloudWatch Alert to EC2

## 概要
Auto ScaleしたEC2にCloudWatchのアラームを自動で付与するスクリプト
Scale IN した場合はアラームを自動で削除する

## Usage
1. `git clone https://github.com/CircleAround/Set-Metrics-for-EC2.git`
2. `bin/package`でアップロード対象を圧縮する
3. AWS Lambdaで関数を作成する *下記、`AWS Lambda関数作成`を参照のこと
4. CloudWatch イベントでイベントを作成する　`AWS CloudWatchイベント作成`を参照のこと

`CW.client.put_metric_alarm['metric_name']`でアラームを仕掛ける対象のメトリクスを設定する

### AWS Lambda関数作成
1. 「関数の作成」を押し、１から作成を選ぶ
2. 関数名を設定し、ランタイムをRubyに設定する
3. ロールを設定する（指定がなければ「基本的な Lambda アクセス権限で新しいロールを作成」で良い）
4. 関数コード - コードエントリタイプ で`.zipファイルをアップロード`を選択し圧縮したzipファイルをアップロードする
5. 関数名のディレクトリ直下に`lambda_function.rb`が配置されていれば成功
6. 関数コード - ランタイム がRubyであることを確認する
7. 関数コード - ハンドラに`lambda_function.lambda_handler`が設定されていることを確認する
8. 環境変数に以下を追加する

`TOPIC_ARN`：通知を送信するSNSトピック(必要であれば設定)
`AWS_REGION`：リージョン名(例： ap-northeast-1)

### AWS CloudWatchイベント作成
1. CloudWatchダッシュボードからイベントを作成する
2. イベントパターンにチェック
3. サービス名を`AutoScaling` イベントタイプを`Instance Launch and Terminate`に設定
4. `特定のインスタンスイベント`にチェックし`EC2 Instance Launch Successful`と`EC2 Instance Terminate Successful`を選択
5. ターゲットに作成したLambda関数を選択
