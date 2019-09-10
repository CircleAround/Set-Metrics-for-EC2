require 'json'
require 'aws-sdk'

# eventからregionを取得することも可能
EC2 = Aws::EC2::Resource.new(region: ENV["AWS_REGION"])
CW = Aws::CloudWatch::Resource.new(region: ENV["AWS_REGION"])

def lambda_handler(event:, context:)
  instance_id = event['detail']['EC2InstanceId']
  return unless instance_id

  case event['detail-type']
    # スケールアウトして新しくインスタンスが起動した場合
  when 'EC2 Instance Launch Successful'
    on_launched(instance_id)
    # スケールインしてインスタンスが削除された場合
  when 'EC2 Instance Terminate Successful'
    on_terminated(instance_id)
  end
end

def on_launched(instance_id)
  instance = EC2.instance(instance_id)

  return unless instance.exists?
  return if CW.alarm(alarm_name(instance_id)).exists?

  # CloudWatch Alarm を作成
  CW.client.put_metric_alarm({
                                 alarm_name: alarm_name(instance_id),
                                 alarm_description: "#{instance_id}のメモリ使用量が閾値を超えました。",
                                 namespace: 'System/Linux', # メトリクスのNameSpace
                                 dimensions: [{name: "InstanceId", value: instance.id}], # インスタンスを指定
                                 metric_name: 'MemoryUtilization', # メモリ使用率の最大
                                 statistic: "Maximum",
                                 threshold: 60, # > 50 %
                                 unit: 'Percent',
                                 comparison_operator: "GreaterThanThreshold",
                                 period: 300, # 5分間のうち1回
                                 evaluation_periods: 1,
                                 datapoints_to_alarm: 1,
                                 treat_missing_data: "ignore", # データなしは無視
                                 alarm_actions: [ENV['TOPIC_ARN']], # 閾値を超えたら警告通知 通知が必要ないならから配列でも良い
                                 # 監視状態が戻ったことも通知できる
                                 # ok_actions: [ ENV['TOPIC_ARN'] ],
                             })
end

# インスタンスが削除されたらアラームも削除
def on_terminated(instance_id)
  alarm = CW.alarm(alarm_name(instance_id))
  alarm.delete if alarm.exists?
end

def alarm_name(instance_id)
  "ec2-#{instance_id}-memory-util-notification"
end
