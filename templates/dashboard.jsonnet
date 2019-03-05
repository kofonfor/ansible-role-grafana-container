local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;

dashboard.new(
  '{{ item.dashboard_name }}',
  schemaVersion=16,
  tags=[
{% for tag in item.tags %}
    '{{ tag }}'{% if not loop.last %},{% endif %}
{% endfor %}
  ],
  time_from='{{ item.time_from }}',
  refresh='{% if item.refresh is defined %}{{ item.refresh }}{% else %}30s{% endif %}',
)
{% for template in item.templates %}
.addTemplate(
  template.new(
    '{{ template.name }}',
    'default',
    '{{ template.query }}',
    label='{{ template.label }}',
    refresh='time',
    includeAll={{ template.includeAll }},
  )
)
{% endfor %}
{% for panel in item.panels %}
.addPanel(
{% if panel.type is not defined or panel.type == "graph" %}
  graphPanel.new(
    '{{ panel.name }}',
    span={{ panel.span }},
    format='{{ panel.format }}',
    fill={{ panel.fill }},
    min={% if panel.min is defined %}{{ panel.min }}{% else %}null{% endif %},
    max={% if panel.max is defined %}{{ panel.max }}{% else %}null{% endif %},
    stack={% if panel.stack is defined %}{{ panel.stack }}{% else %}false{% endif %},
    decimals={{ panel.decimals }},
    aliasColors={% if panel.alias_colors is defined %}{{ '{ ' }}{% for alias, color in panel.alias_colors.iteritems() %}"{{ alias }}": "{{ color }}", {% endfor %}{{ ' }' }}{% else %}{}{% endif %},
    linewidth={% if panel.linewidth is defined %}{{ panel.linewidth }}{% else %}1{% endif %},
    datasource='default',
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_current=true,
    legend_total=false,
    legend_avg=true,
    legend_alignAsTable=true,
  )
{% else %}
  singlestat.new(
    '{{ panel.name }}',
    valueName='{{ panel.value_name }}',
    colorValue={{ panel.color_value }},
    datasource='default',
  )
{% endif %}
{% for target in panel.targets %}
  .addTarget(
    prometheus.target(
      '{{ target.expr }}',
      datasource='default',
      legendFormat='{{ target.legend_format }}',
      format='{% if target.format is defined %}{{ target.format }}{% else %}time_series{% endif %}',
      intervalFactor='{% if target.interval_factor is defined %}{{ target.interval_factor }}{% else %}2{% endif %}',
    )
  )
{% endfor %}
{% if panel.series_overrides is defined %}
{% for override_alias, overrides_hash in panel.series_overrides.iteritems() %}
  .addSeriesOverride(
    {
      "alias": "{{ override_alias }}",
{% for override_param, override_val in overrides_hash.iteritems() %}
      "{{ override_param }}": {{ override_val }},
{% endfor %}
    }
  )
{% endfor %}
{% endif %}
  , gridPos={
    x: {{ panel.gridpos_x }},
    y: {{ panel.gridpos_y }},
    w: {{ panel.gridpos_w }},
    h: {{ panel.gridpos_h }},
  }
)
{% endfor %}
