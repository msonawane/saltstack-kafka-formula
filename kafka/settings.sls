{%- from 'zookeeper/settings.sls' import zk with context %}
{% set p  = salt['pillar.get']('kafka', {}) %}
{% set pc = p.get('config', {}) %}
{% set g  = salt['grains.get']('kafka', {}) %}
{% set gc = g.get('config', {}) %}

# these are global - hence pillar-only
{%- set prefix            = p.get('prefix', '/usr/lib/kafka') %}

{%- set version           = g.get('version', p.get('version', '0.8.2.1')) %}
{%- set scala_version     = g.get('scala_version', p.get('scala_version', '2.11')) %}

{%- set version_name = 'kafka_' + scala_version + '-' + version %}
{%- set real_home    = prefix + '_' + scala_version + '-' + version %}
{%- set default_url  = 'http://www.mirrorservice.org/sites/ftp.apache.org/kafka/' + version + '/' + version_name + '.tgz' %}
{%- set source_url   = g.get('source_url', p.get('source_url', default_url)) %}

# bind_address is only supported as a grain, because it has to be host-specific


{%- set config = {
  'broker_id': gc.get('broker_id', pc.get('broker_id', 0)),
  'port': gc.get('port', pc.get('port', 9092)),
  'zookeeper_connect': gc.get('zookeeper_connect', pc.get('zookeeper_connect', zk.connection_string)),
  'log_dirs': gc.get('log_dirs', pc.get('log_dirs', ['/kafka-logs'])),
  'num_partitions': gc.get('num_partitions', pc.get('num_partitions', 4)),
  'host_name': gc.get('host_name', pc.host_name),
  'advertised_host_name': gc.get('advertised_host_name', pc.advertised_host_name),
  'log_retention_hours': gc.get('log_retention_hours', pc.get('log_retention_hours', 72)),
  'user': gc.get('user', pc.get('user', 'kafka')),
  } %}

{%- set kafka = {} %}

{%- do kafka.update({
  'userhome': userhome,
  'prefix': prefix,
  'version': version,
  'version_name': version_name,
  'source_url': source_url,
  'real_home': real_home
  }) %}