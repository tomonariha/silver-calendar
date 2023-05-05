module MetaTagsHelper
  def default_meta_tags
    {
      site: 'WorkingDayDeployer',
      title: 'WDD',
      reverse: true,
      charset: 'utf-8',
      description: '勤務日程自動調整アプリ',
      canonical: 'https://working-day-deployer.fly.dev/',
      separator: '|',
      viewport: 'width=device-width, initial-scale=1.0',
      og: {
        title: 'WorkingDayDeployer',
        type: 'website',
        site_name: 'WorkingDayDeployer',
        description: :description,
        # image: image_url('ogp.png'),
        url: 'https://working-day-deployer.fly.dev/',
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@tomonari',
        description: :description,
        domain: 'https://working-day-deployer.fly.dev/'
      }
    }
  end
end
