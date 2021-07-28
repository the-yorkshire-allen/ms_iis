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
  $iis_features = ['Web-WebServer','Web-Scripting-Tools']

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

  # Set Permissions
  acl { "${root_folder}\\${web_folder}":
    permissions => [
      {'identity' => 'IISCompleteGroup', 'rights' => ['read', 'execute']},
    ],
  }

  acl { "${root_folder}\\${vdir_folder}":
    permissions => [
      {'identity' => 'IISCompleteGroup', 'rights' => ['read', 'execute']},
    ],
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

  iis_site { 'complete':
    ensure           => 'started',
    physicalpath     => "${root_folder}\\${web_folder}",
    applicationpool  => 'complete_site_app_pool',
    enabledprotocols => 'http',
    require          => [File["${root_folder}\\${web_folder}"],File['index']],
  }

  iis_virtual_directory { 'vdir':
    ensure       => 'present',
    sitename     => 'complete',
    physicalpath => "${root_folder}\\${vdir_folder}",
    require      => File["${root_folder}\\${vdir_folder}"],
  }

  file { 'index':
    path   => "${root_folder}\\${web_folder}\\${root_file}",
    source => 'puppet:///modules/ms_iis/index.html',
  }
}
