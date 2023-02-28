server {
    enabled = true
    bootstrap_expect = {{ groups['nomad'] | length }}
}

{% if inventory_hostname == groups['nomad'][0] %}
ui {
    enabled = true
}
{% endif %}
