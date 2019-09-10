# AWS Lambda's script for Notifying CloudWatch Alert to Slack
CloudWatchのアラームをSlackで通知するためのスクリプト
当プロジェクトを圧縮したファイルをAWS Lambdaにアップロードして使う

## 概要
CloudWatchで設定したアラームをAWS Lambdaを通してSlackの選択したチャンネルへ通知する

CloudWatch → SNSトピック → AWS Lambda → Slack のようになるように下記で設定する

## Usage
1. `git clone https://github.com/CircleAround/CloudWatch-notify-to-Slack.git`
2. `bundle install --deployment`
3. `bin/package`でアップロード対象を圧縮する
4. SlackのworkspaceにIncoming WebHooksを追加
5. AWS Lambdaで関数を作成する *下記、`AWS Lambda関数作成`を参照のこと
6. AWS Simple Notification Service でSNSトピックを作成する  `AWS SNSトピック作成`を参照のこと
7. CloudWatch でアラームを作成する `AWS Alertの作成`を参照のこと

### AWS Lambda関数作成
1. 「関数の作成」を押し、１から作成を選ぶ
2. 関数名を設定し、ランタイムをRubyに設定する
3. ロールを設定する（指定がなければ「基本的な Lambda アクセス権限で新しいロールを作成」で良い）
4. 関数コード - コードエントリタイプ で`.zipファイルをアップロード`を選択し`Usage.3`で圧縮したzipファイルをアップロードする
5. 関数名のディレクトリ直下に`vendor Gemfile Gemfile.lock, lambda_function.rb`が配置されていれば成功
6. 関数コード - ランタイム がRubyであることを確認する
7. 関数コード - ハンドラに`lambda_function.handler`が設定されていることを確認する
8. 環境変数に以下を追加する

`WEB_HOOK_CHANNEL`：通知を送るSlackのチャンネル（例：#AWS_activity）
`WEB_HOOK_URL`：SlackのWebhookのエンドポイント

### AWS SNSトピック作成
1. 「トピックの作成」からトピックの作成を始める
2. トピック名と表示名を決めるオプションは必要に応じて設定する
3. トピック詳細画面から「サブスクリプションの作成」を押して送信先を設定する
4.  プロトコルを`AWS Lambda`に設定 エンドポイントを`AWS Lambda関数作成`で作ったLambda関数のARNに設定する
5. SNSトピックが通知を発信する先の設定は完了

### AWS Alertの作成
1. CloudWatchの画面からアラームを作成する
2. アクションの設定 - 通知 - SNSトピックの選択 で「既存の SNS トピックを選択」を選択し「通知の送信先」から`AWS SNSトピック作成`で作成したSNSトピックを選択しておくこと
3. これでアラーム通知がSNSトピックに送信されるようになる
