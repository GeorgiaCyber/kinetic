wait_for_cache_identity_assignment:
  salt.wait_for_event:
    - name: salt/beacon/pxe/log/bootstrap/request/event
    - id_list:
      - pxe
    - timeout: 300

{% set cache_id = salt['cmd.run']('ls /tmp/cache') %}

rm /tmp/cache/{{ cache_id }}:
  cmd.run

wait_for_{{ cache_id }}_provisioning:
  salt.wait_for_event:
    - name: salt/auth
    - id_list:
      - {{ cache_id }}
    - timeout: 600
    - require:
      - wait_for_cache_identity_assignment

validate_cache_key:
  salt.wheel:
    - name: key.accept
    - match: cache*
    - require:
      - wait_for_{{ cache_id }}_provisioning

cache_setup:
  salt.state:
    - tgt: 'cache*'
    - highstate: true
    - require:
      - validate_cache_key
