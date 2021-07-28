# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ms_iis
class ms_iis (
  String $root_folder = 'c:\\inetpub\\',
  String $web_folder  = 'web_site',
  String $vdir_folder = 'web_site_vdir',
  String $root_file   = 'index.html',
){
  $iis_features = ['Web-WebServer','Web-Scripting-Tools','Web-WebAdministration']

  iis_feature { $iis_features:
    ensure => 'present',
  }

  file { $root_folder:
    ensure => 'directory'
  }

  file { "${root_folder}\\${web_folder}":
    ensure => 'directory'
  }

  file { "${root_folder}\\${vdir_folder}":
    ensure => 'directory'
  }

  # Configure IIS
  iis_application_pool { 'complete_site_app_pool':
    ensure                  => 'present',
    state                   => 'started',
    managed_pipeline_mode   => 'Integrated',
    managed_runtime_version => 'v4.0',
  }

  #Application Pool No Managed Code .Net CLR Version set up
  iis_application_pool {'test_app_pool':
    ensure                    => 'present',
    enable32_bit_app_on_win64 => true,
    managed_runtime_version   => '',
    managed_pipeline_mode     => 'Classic',
    start_mode                => 'AlwaysRunning'
  }

  # Delete the default website to prevent a port binding conflict.
  iis_site {'Default Web Site':
    ensure  => absent,
    require => Iis_feature['Web-WebServer'],
  }

  iis_site { 'complete':
    ensure           => 'started',
    physicalpath     => "${root_folder}\\${web_folder}",
    applicationpool  => 'complete_site_app_pool',
    enabledprotocols => 'http',
    bindings         => [
      {
        'bindinginformation' => '*:80:',
        'protocol'           => 'http'
      }
    ],
    require          => [
      Iis_feature['Web-WebServer'],
      Iis_site['Default Web Site'],
      File["${root_folder}\\${web_folder}"],
      File['index']
    ],
  }

  iis_virtual_directory { 'vdir':
    ensure       => 'present',
    sitename     => 'complete',
    physicalpath => "${root_folder}\\${vdir_folder}",
    require      => [
      File["${root_folder}\\${vdir_folder}"],
      Iis_feature['Web-WebServer']
    ],
  }

  file { 'index':
    path    => "${root_folder}\\${web_folder}\\${root_file}",
    source  => 'puppet:///modules/ms_iis/index.html',
    require => File["${root_folder}\\${web_folder}"],
  }
}
