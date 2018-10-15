master_setup:
  salt.state:
    - tgt: 'salt'
    - highstate: true

{% for type in pillar['virtual'] %}
  {% set count = pillar['virtual'][type]['config']['count'] %}
  {% for host in range(1,count) %}
func:
  salt.function:
    - name: cmd.run
    - tgt: salt
    - arg:
      - echo {{ type }} {{ count }} {{ host }}
  {% endfor %}
{% endfor %}