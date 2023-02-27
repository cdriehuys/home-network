server = true
bootstrap_expect = {{ groups['consul'] | length }}

client_addr = "0.0.0.0"

{% if inventory_hostname == groups['consul'][0] -%}
ui_config {
    enabled = true
}
{% endif %}
