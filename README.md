# シルバーカレンダー
## サービスURL
https://silver-calendar.com

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
