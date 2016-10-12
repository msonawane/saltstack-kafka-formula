{%- from 'kafka/settings.sls' import kafka, config with context %}
{%- set slack = salt['pillar.get']('slack', {}) %}

include:
  - java
  - kafka

kafka-directories:
  file.directory:
    - user: kafka
    - group: kafka
    - mode: 755
    - makedirs: True
    - names:
{% for log_dir in config.log_dirs %}
      - {{ log_dir }}
{% endfor %}

kafka-server-conf:
  file.managed:
    - name: {{ kafka.real_home }}/config/server.properties
    - source: salt://kafka/config/server.properties
    - user: kafka
    - group: kafka
    - mode: 644
    - template: jinja
    - require:
      - cmd: install-kafka-dist

kafka-init-file:
  file.managed:
    - name: /etc/init.d/kafka
    - source: salt://kafka/config/kafka_init.sh
    - mode: 755
    - template: jinja
    - context:
        workdir: {{ kafka.prefix }}
        user: {{config.user}}
    - require:
      - file: kafka-server-conf

kafka_run_class_sh:
  file.managed:
    - name: {{ kafka.real_home }}/bin/kafka-run-class.sh
    - source: salt://kafka/config/kafka-run-class.sh
    - mode: 755
    - require:
      - file: kafka-server-conf

kafka_server_start_sh:
  file.managed:
    - name: {{ kafka.real_home }}/bin/kafka-server-start.sh
    - source: salt://kafka/config/kafka-server-start.sh
    - mode: 755
    - require:
      - file: kafka-server-conf

kafka-service:
  service.running:
    - name: kafka
    - enable: true
    - watch:
      - file: kafka-server-conf
      - file: kafka-init-file
      - file: kafka_run_class_sh
      - file: kafka_server_start_sh

success_notification:
  slack.post_message:
    - channel: "#{{slack.test_channel}}"
    - from_name: {{slack.from_name}}
    - message: |
            *Job Purpose*: Kafka server deploy
            *Status*: Success
            *Server*: {{ grains['id'] }}: 
            *Notifying Devops Members*: @msonawane
    - api_key: {{slack.api_key}}
    - onchanges:
      - service: kafka-service

failure_notification:
  slack.post_message:
    - channel: "#{{slack.test_channel}}"
    - from_name: {{slack.from_name}}
    - message: |
            *Job Purpose*: Kafka server deploy
            *Status*: Failure
            *Server*: {{ grains['id'] }}: 
            *Notifying Devops Members*: @msonawane
    - api_key: {{slack.api_key}}
    - onfail:
      - service: kafka-service
