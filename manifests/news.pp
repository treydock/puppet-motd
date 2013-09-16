# == Define: motd::news
#
# Adds and entry to the /etc/motd file and /etc/motd-archive/ directory  
# with a timestamp.
#
# === Parameters
# 
# [*newstitle*]
#   If not set this is taken from *namevar* for instance. It is used as 
#   the heading of the news item.
#
# [*date*]
#   Must be specified as YYYY-MM-DD and marks a news item's date. 
#   Items older than 30 days will
#   not appear in /etc/motd and will only appear in /etc/motd-archive 
#   e.g 2013-12-25.
#
# [*message*]
#    If defined then specifies a long message for new news item on 
#    multilines.
#
# The resulting format of a news item is :
#
#    [*date*] - [*newtitle*]
#       [*message*]
#
#
# === Examples
#    motd::news{'package x installed': date => '2013-12-11'}
#    motd::news{'package x installed': 
#        date    => '2013-12-11',
#        message => 'Package X can be used for Y'
#
define motd::news ($newstitle = $title, $message = undef, $date) {
  $year_month = regsubst($date, '^(\d+)\-(\d+)\-(\d+)$', '\1\2')
  $motd_archive_files = "/etc/motd-archive/${year_month}"

  ensure_resource('concat', "${motd_archive_files}", 
                     { mode => '0444'
                     }
  )

  $newsdate = inline_template('<%=  Date.strptime(@date, \'%Y-%m-%d\') + 30 -%>')
  $currentdate = inline_template('<%= Date.strptime(Time.new.strftime("%Y-%m-%d"), \'%Y-%m-%d\') -%>')

  if ($currentdate < $newsdate) {
    concat::fragment { "motd_frag_${name}":
      target  => "/etc/motd",
      content => template('motd/news.erb'),
      order   => "07-${date}",
    }

  }

  concat::fragment { "motd_archive_frag_${date}_${name}":
    target  => "$motd_archive_files",
    content => template('motd/news.erb'),
    order   => "01-${date}-${name}",
  }

}
