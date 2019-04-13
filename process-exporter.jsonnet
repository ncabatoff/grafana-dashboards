local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local row = grafana.row;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Process Exporter",
    editable = true,
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.new('instance', '$ds', 'label_values(namedprocess_scrape_errors{job=~"process-exporter.*"}, instance)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
  )
)
.addTemplate(
  template.new('group', '$ds', 'label_values(namedprocess_namegroup_num_procs{job=~"process-exporter.*", instance=~"($instance)"}, groupname)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
  )
)

.addPanel(
    row.new(title="Monitoring status"),
    gridPos={ x: 0, y: 0, w: 24, h: 1}
)

.addPanel(
    graphPanel.new(
        'process_exporter up',
        datasource='$ds',
        span=6,
        fill=0,
        min=0,
        max=1,
        decimals=0,
        legend_show=false,
        legend_hideEmpty=true,
        legend_hideZero=true,
    ).addTarget(
        prom.target('up{job=~"process-exporter.*", instance=~"$instance"}')
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 4}
)
.addPanel(
    graphPanel.new(
        'scrape duration',
        datasource='$ds',
        span=6,
        fill=0,
        min=0,
        legend_show=false,
        legend_hideEmpty=true,
        legend_hideZero=true,
        format="s",
    ).addTarget(
        prom.target('scrape_duration_seconds{job=~"process-exporter.*", instance=~"$instance"}')
    ),
    gridPos={ x: 6, y: 0, w: 6, h: 4}
)
.addPanel(
    graphPanel.new(
        'process scrape errors',
        datasource='$ds',
        span=6,
        fill=0,
        min=0,
        decimals=0,
        legend_show=false,
        legend_hideEmpty=true,
        legend_hideZero=true,
    ).addTarget(
        prom.target('rate(namedprocess_scrape_errors{instance=~"$instance"}[1m])')
    ).addTarget(
        prom.target('rate(namedprocess_scrape_partial_errors{instance=~"$instance"}[1m])')
    ).addTarget(
        prom.target('rate(namedprocess_scrape_procread_errors{instance=~"$instance"}[1m])')
    ),
    gridPos={ x: 12, y: 0, w: 6, h: 4}
)

.addPanel(
    row.new(title="Group status"),
    gridPos={ x: 0, y: 5, w: 24, h: 1}
)
.addPanel(
    graphPanel.new(
        'CPU',
        datasource='$ds',
        fill=true,
        stack=true,
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        legend_values=true,
        legend_min=true,
        legend_max=true,
        legend_current=true,
        legend_avg=true,
        legend_alignAsTable=true,
    ).addTarget(
        prom.target('sum by (groupname) (
            irate(namedprocess_namegroup_cpu_seconds_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 0, y: 5, w: 6, h: 15}
)
.addPanel(
    graphPanel.new(
        'Resident memory',
        datasource='$ds',
        fill=true,
        stack=true,
        min=0,
        format="bytes",
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        legend_values=true,
        legend_min=true,
        legend_max=true,
        legend_current=true,
        legend_avg=true,
        legend_alignAsTable=true,
    ).addTarget(
        prom.target('sum by (groupname) (
            namedprocess_namegroup_memory_bytes{memtype="resident", groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 6, y: 5, w: 6, h: 15}
)

.addPanel(
    graphPanel.new(
        'Disk I/O',
        datasource='$ds',
        fill=true,
        stack=true,
        min=0,
        format="bps",
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        legend_values=true,
        legend_min=true,
        legend_max=true,
        legend_current=true,
        legend_avg=true,
        legend_alignAsTable=true,
    ).addTarget(
        prom.target('sum by (groupname) (
            irate(namedprocess_namegroup_write_bytes_total{groupname=~"$group", instance=~"$instance"}[1m])
            + irate(namedprocess_namegroup_read_bytes_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 12, y: 5, w: 6, h: 15}
)
