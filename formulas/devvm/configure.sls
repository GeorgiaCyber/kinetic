include:
  - /formulas/devvm/install
  - formulas/common/base
  - formulas/common/networking
  - /formulas/devvm/install-zun-ui

/etc/openstack-dashboard/local_settings.py:
  file.managed:
    - source: salt://formulas/devvm/files/local_settings.py
    - template: jinja
    - defaults:
{% for server, address in salt['mine.get']('type:memcached', 'network.ip_addrs', tgt_type='grain') | dictsort() %}
        memcached_servers: {{ address[0] }}:11211
{% endfor %}
        keystone_url: {{ pillar['endpoints']['internal'] }}

/etc/apache2/conf-enabled/openstack-dashboard.conf:
  file.managed:
    - source: salt://formulas/devvm/files/openstack-dashboard.conf

/var/www/html/index.html:
  file.managed:
    - source: salt://formulas/devvm/files/index.html

/var/lib/openstack-dashboard/secret_key:
  file.managed:
    - user: horizon
    - group: horizon

apache2_service:
  service.running:
    - name: apache2
    - watch:
      - file: /etc/openstack-dashboard/local_settings.py
      - file: /var/lib/openstack-dashboard/secret_key
      - file: /etc/apache2/conf-enabled/openstack-dashboard.conf