# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ms_iis
class ms_iis (
  String $root_folder = 'c:\\inetpub',
  String $web_folder  = '\\web_site',
  String $root_file   = '\\index.html',
){
#  $iis_features = ['Web-WebServer','Web-Scripting-Tools','Web-AppInit']
  $iis_features = ['Web-WebServer']

  iis_feature { $iis_features:
    ensure                   => 'present',
    include_management_tools => true,
  }

  file { $root_folder:
    ensure => 'directory',
  }

  file { "${root_folder}${web_folder}":
    ensure  => 'directory',
    require => File[$root_folder],
  }

  # Delete the default website to prevent a port binding conflict.
  iis_site {'Default Web Site':
    ensure  => absent,
    require => Iis_feature['Web-WebServer'],
  }

  iis_site { 'complete':
    ensure           => 'started',
    physicalpath     => "${root_folder}${web_folder}",
    applicationpool  => 'DefaultAppPool',
    enabledprotocols => 'http',
    bindings         => [
      {
        'bindinginformation' => '*:80:',
        'protocol'           => 'http'
      }
    ],
    require          => [
      Iis_feature['Web-WebServer'],
#      Iis_site['Default Web Site'],
      File["${root_folder}${web_folder}"],
      File['index']
    ],
  }

  file { 'index':
    path    => "${root_folder}${web_folder}${root_file}",
    source  => 'puppet:///modules/ms_iis/index.html',
    require => File["${root_folder}${web_folder}"],
  }

  file { 'web.config':
    ensure  => 'file',
    path    => "${root_folder}${web_folder}\\web.config",
    require => File["${root_folder}${web_folder}"],
  }
}
