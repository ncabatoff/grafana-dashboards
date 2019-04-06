local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Supervisord Jobs",
    editable = true,
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.new('job', '$ds', 'label_values(node_supervisord_up, group)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
  )
)
.addTemplate(
  template.new('instance', '$ds', 'label_values(node_supervisord_up{group=~"$job"}, instance)',
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
        lines=false,
        points=true,
    ).addTarget(
        prom.target('sum by(group) (node_supervisord_up{group=~"$job", instance=~"($instance).*"})', legendFormat="{{group}}")
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 7}
)

