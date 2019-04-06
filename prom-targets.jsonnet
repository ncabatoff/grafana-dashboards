local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Prometheus Targets",
    editable = true,
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.new('job', '$ds', 'label_values(up, job)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
  )
)
.addTemplate(
  template.new('instance', '$ds', 'label_values(up{job=~"$job"}, instance)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
    regex="^([^:]+):.+$",
  )
)

.addPanel(
    graphPanel.new(
        '$job',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        repeat='job',
        repeatDirection='h',
    ).addSeriesOverride(
        { alias: "/\\d+/", yaxis: 2, lines: false, points: true }
    ).resetYaxes(
    ).addYaxis(min=0, decimals=0
    ).addYaxis(min=0, format='s', max=2,
    ).addTarget(
        prom.target('sum by(job) (up{job=~"$job", instance=~"($instance).*"})', legendFormat="{{job}}")
    ).addTarget(
        prom.target('scrape_duration_seconds{job=~"$job", instance=~"($instance).*"}', legendFormat="{{instance}}")
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 7}
)

