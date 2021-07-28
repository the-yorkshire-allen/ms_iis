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
  $iis_features = ['Web-WebServer','Web-Scripting-Tools','Web-AppInit']

  iis_feature { $iis_features:
    ensure => 'present',
  }

  # Delete the default website to prevent a port binding conflict.
  iis_site {'Default Web Site':
    ensure  => absent,
    require => Iis_feature['Web-WebServer'],
  }

  iis_site { 'minimal':
    ensure          => 'started',
    physicalpath    => 'c:\\inetpub\\minimal',
    applicationpool => 'DefaultAppPool',
    require         => [
      File['minimal'],
      Iis_site['Default Web Site']
    ],
  }

  file { 'minimal':
    ensure => 'directory',
    path   => 'c:\\inetpub\\minimal',
  } 
}
