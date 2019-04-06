local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Node Exporter",
    editable = true,
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.custom('job', 'node_exporter-core,node_exporter', 'node_exporter-core') + {multi: true},
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
        '$instance CPU',
        min=0,
        max=1,
        fill=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        repeat='instance',
        repeatDirection='v',
        format="percentunit",
    ).addTarget(
        prom.target('avg without (cpu) (irate(node_cpu_seconds_total{instance=~"($instance).*",mode!="idle"}[5m]))', legendFormat="{{mode}}")
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 5}
)

.addPanel(
    graphPanel.new(
        '$instance Disk',
        min=0,
        max=1,
        fill=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        repeat='instance',
        repeatDirection='v',
        format="percentunit",
    ).addTarget(
        prom.target('irate(node_disk_io_time_seconds_total{instance=~"($instance).*",device!~"^(md[0-9]+$|dm-)"}[5m])', legendFormat="{{device}}")
    ),
    gridPos={ x: 6, y: 0, w: 6, h: 5}
)

.addPanel(
    graphPanel.new(
        '$instance RAM',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        repeat='instance',
        repeatDirection='v',
        format="bytes",
        stack=true,
    ).addTarget(
        prom.target('node_memory_MemTotal_bytes{instance=~"($instance).*"}
         - node_memory_MemFree_bytes{instance=~"($instance).*"}
         - node_memory_Buffers_bytes{instance=~"($instance).*"}
         - node_memory_Cached_bytes{instance=~"($instance).*"}', legendFormat="Used")
    ).addTarget(
        prom.target('node_memory_Buffers_bytes{instance=~"($instance).*"}', legendFormat="Buffers")
    ).addTarget(
        prom.target('node_memory_Cached_bytes{instance=~"($instance).*"}', legendFormat="Cached")
    ).addTarget(
        prom.target('node_memory_MemFree_bytes{instance=~"($instance).*"}', legendFormat="Free")
    ),
    gridPos={ x: 12, y: 0, w: 6, h: 5}
)
