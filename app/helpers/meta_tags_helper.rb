# frozen_string_literal: true

module MetaTagsHelper
  def default_meta_tags
    {
      site: 'SilverCalendar',
      title: 'SilverCalendar',
      reverse: true,
      charset: 'utf-8',
      description: '勤務日程自動調整アプリ',
      canonical: 'https://silver-calendar.com',
      separator: '|',
      viewport: 'width=device-width, initial-scale=1.0',
      og: {
        title: 'SilverCalendar',
        type: 'website',
        site_name: 'SilverCalendar',
        description: :description,
        image: image_url('ogp.png'),
        url: 'https://silver-calendar.com',
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@tomonar78242114',
        description: :description,
        domain: 'https://silver-calendar.com'
      }
    }
  end
end
