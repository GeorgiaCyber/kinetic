{% set type = data['path'].split('/')[6] %}

publish pending id:
  runner.event.send:
    - args:
      - tag: {{ type }}
