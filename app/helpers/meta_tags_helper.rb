# frozen_string_literal: true

module MetaTagsHelper
  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    {
      site: 'シルバーカレンダー',
      title: 'シルバーカレンダー',
      reverse: true,
      charset: 'utf-8',
      description: '勤務日程自動調整アプリ',
      canonical: 'https://silver-calendar.com',
      separator: '|',
      viewport: 'width=device-width, initial-scale=1.0',
      og: {
        title: 'シルバーカレンダー',
        type: 'website',
        site_name: 'シルバーカレンダー',
        description: '勤務日程自動調整アプリ',
        image: image_url('ogp.png'),
        url: 'https://silver-calendar.com',
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@tomonar78242114',
        description: '勤務日程自動調整アプリ',
        domain: 'https://silver-calendar.com'
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
