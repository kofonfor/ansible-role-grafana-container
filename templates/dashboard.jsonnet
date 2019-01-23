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
  tags=['nginx'],
  time_from='now-3h',
  refresh='30s',
)
.addTemplate(
  template.new(
    'instance',
    'default',
    'label_values(nginx_http_requests_total, instance)',
    label='Instance',
    refresh='time',
  )
)
{% for panel in item.panels %}
.addPanel(
  graphPanel.new(
    '{{ panel.name }}',
    span=6,
    format='short',
    fill={{ panel.fill }},
    min=0,
    stack={{ panel.stack }},
    decimals=2,
    datasource='default',
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_current=true,
    legend_total=false,
    legend_avg=true,
    legend_alignAsTable=true,
  )
{% for target in panel.targets %}
  .addTarget(
    prometheus.target(
      '{{ target.expr }}',
      datasource='default',
      legendFormat='{{ target.legend_format }}'
    )
  )
{% endfor %}
  , gridPos={
    x: {{ panel.gridpos_x }},
    y: {{ panel.gridpos_y }},
    w: {{ panel.gridpos_w }},
    h: {{ panel.gridpos_h }},
  }
)
{% endfor %}
