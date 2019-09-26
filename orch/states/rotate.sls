{% set type = pillar['type'] %}
{% set ipmi_password = pillar['ipmi_password'] %}
{% for address in pillar['hosts'][type]['ipmi_addresses'] %}

ipmitool -I lanplus chassis bootdev pxe options=efiboot -U ADMIN -P {{ ipmi_password }} -H {{ address }}:
  cmd.run

{% if salt.cmd.shell("ipmitool -I lanplus chassis power status -U ADMIN -P " + ipmi_password + " -H "+ address) == "Chassis Power is off" %}

ipmitool -I lanplus chassis power on -U ADMIN -P {{ pillar['ipmi_password'] }} -H {{ address }}:
  cmd.run

{% else %}

ipmitool -I lanplus chassis power reset -U ADMIN -P {{ pillar['ipmi_password'] }} -H {{ address }}:
  cmd.run

{% endif %}

## There is a slight delay between the ipmi commands and execution
## This will prevent minions from re-asking to pair with master
## after their keys are removed

{% endfor %}

sleep 5 for {{ type }}:
  cmd.run:
    - name: sleep 5

salt-call ipmi.raw_command netfn=0x00 command=0x08 data=[0x05,0xa0,0x04,0x00,0x00,0x00]
