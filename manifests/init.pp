# == Class: webook
#
# This will install and configure the webhook for git webhooks
# so it will run an r10k deploy * action
#
# === Requirements
#
# No requirements.
#
# - puppetlabs-operations/puppet-bundler
#
# === Parameters
#
# [*webhook_home*]
# This is the directory where all stuff of
# this webhook is installed
#
# [*webhook_port*]
# On which port it is listening for requests
#
# [*webhook_owner*]
# The owner of this service/script
#
# [*webhook_group*]
# The group of this service/script
#
# [*repo_puppetfile*]
# The name of the repository where the 'Puppetfile'
# is stored.
#
# [*repo_hieradata*]
# The name of the repository where the 'hieradata'
# is stored.
#
# [*ruby_dev*]
# The package name of ruby-devel (or when debian: ruby-dev)
#
# === Example
#
#  class { 'webhook':
#    webhook_port    => '82',
#    repo_puppetfile => "puppetfilerepo",
#    repo_hieradata  => "puppethieradata",
#  }
#
# === Authors
#
# Author Name: ikben@werner-dijkerman.nl
#
# === Copyright
#
# Copyright 2014 Werner Dijkerman
#
class webhook (
  $webhook_home    = $webhook::params::homedir,
  $webhook_port    = $webhook::params::port,
  $webhook_owner   = $webhook::params::owner,
  $webhook_group   = $webhook::params::group,
  $repo_puppetfile = undef,
  $repo_hieradata  = undef,
  $ruby_dev        = $webhook::params::ruby_dev,
) inherits webhook::params {

  osfamily = inline_template('<%= osfamily.downcase %>')

  exec { 'create_webhook_homedir':
    command => "mkdir -p ${webhook_home}",
    path    => '/bin:/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin',
    creates => $webhook_home,
  }

  file { "${webhook_home}/config.ru":
    ensure  => present,
    owner   => $webhook_owner,
    group   => $webhook_group,
    mode    => '0755',
    source  => 'puppet:///modules/webhook/config.ru',
    require => Exec['create_webhook_homedir'],
  }

  file { "${webhook_home}/Gemfile":
    ensure  => present,
    owner   => $webhook_owner,
    group   => $webhook_group,
    mode    => '0755',
    source  => 'puppet:///modules/webhook/Gemfile',
    #notify  => Bundler::Install[$webhook_home],
    require => Exec['create_webhook_homedir'],
  }

  file { "${webhook_home}/Gemfile.lock":
    ensure  => present,
    owner   => $webhook_owner,
    group   => $webhook_group,
    mode    => '0755',
    source  => 'puppet:///modules/webhook/Gemfile.lock',
    #notify  => Bundler::Install[$webhook_home],
    require => Exec['create_webhook_homedir'],
  }

  file { "${webhook_home}/log":
    ensure  => directory,
    owner   => $webhook_owner,
    group   => $webhook_group,
    mode    => '0755',
    require => Exec['create_webhook_homedir'],
  }

  file { "${webhook_home}/webhook.rb":
    ensure  => present,
    owner   => $webhook_owner,
    group   => $webhook_group,
    mode    => '0755',
    require => Exec['create_webhook_homedir'],
    content => template('webhook/webhook.rb'),
    notify  => Service['webhook'],
  }

  file { '/etc/init.d/webhook':
    ensure  => present,
    mode    => '0775',
    content => template("webhook/service.${::osfamily}.erb"),
  }

  if ! defined(Package[$ruby_dev]) {
    package { $ruby_dev:
      ensure   => 'installed',
    }
  }

  bundler::install { $webhook_home:
    user       => $webhook_owner,
    group      => $webhook_group,
    deployment => false,
    without    => 'development test doc',
    require    => [
      File["${webhook_home}/config.ru"],
      File["${webhook_home}/Gemfile"],
      File["${webhook_home}/Gemfile.lock"],
      Package[$ruby_dev],
    ],
  }

  service { 'webhook':
    ensure     => running,
    hasstatus  => true,
    enable     => true,
    hasrestart => true,
    require    => [
      Bundler::Install[$webhook_home],
      File["${webhook_home}/webhook.rb"],
    ],
  }
}

