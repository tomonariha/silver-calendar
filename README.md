# シルバーカレンダー
## サービスURL
https://silver-calendar.com

![silvercalendar-min](https://github.com/tomonariha/silver-calendar/assets/96340764/55bd235c-f0c1-42eb-914a-a2d893fbe728)


## 概要
シルバーカレンダーというサービスは、
嘱託職員などの年間日数で労働契約している方が
自分で勤務予定を調整する手間を軽減するための
勤務日自動調整サービスです。
条件を入れて自動で勤務予定の配置ができます。

## 特徴
- 条件を入力して、勤務予定を自動入力できます。
- 手動で予定を入れたり微調整したりすることもできます。
- Googleカレンダーに予定を反映できます。

## 使用技術
- Ruby(3.1.0)
- RubyOnRails(7.0.4)
- Vue.js(3.2.36)
- Vite(3.2.0)
- PostgreSQL
- GoogleCalendarAPI
- GithubActions
- Fly.io

## 開発環境の構築
### 環境変数の設定
|環境変数|説明|
|------|---|
|GOOGLE_CLIENT_ID|Google CloudのクライアントIDです|
|GOOGLE_CLIENT_SECRET|Google Cloudのクライアントシークレットです|

 ### セットアップ
```
$ git clone https://github.com/tomonariha/silver-calendar.git
$ cd silver-calendar
$ bin/setup
```

## 起動
```
$ bin/dev
```

## テスト
```
$ bundle exec rspec
```

## Lint
```
$ bin/lint
```

## キャプチャー
### 勤務予定入力
<img width="412" alt="スクリーンショット 2023-06-04 23 11 45-min" src="https://github.com/tomonariha/working-day-deployer/assets/96340764/c52d95ef-9673-4980-88a7-fd8d2e591a94">

### 自動調整
<img width="412" alt="スクリーンショット 2023-06-04 23 14 38-min" src="https://github.com/tomonariha/working-day-deployer/assets/96340764/222aa419-ebfb-4d29-96b6-2b9952842580">

### 年間カレンダー
<img width="412" alt="スクリーンショット 2023-06-04 23 08 45-min" src="https://github.com/tomonariha/working-day-deployer/assets/96340764/f49f2c9e-c84f-4333-93c7-0bfb1a0ba237">

### Googleカレンダーへ反映
<img width="412" alt="スクリーンショット 2023-05-16 1 49 20-min" src="https://github.com/tomonariha/working-day-deployer/assets/96340764/4bd0c017-e341-4586-855e-a59f7f32d5a9">
