local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local row = grafana.row;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Process Exporter Storage",
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
    row.new(title="Group memory"),
    gridPos={ x: 0, y: 5, w: 24, h: 1}
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
    gridPos={ x: 0, y: 5, w: 6, h: 12}
)
.addPanel(
    graphPanel.new(
        'Virtual memory',
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
            namedprocess_namegroup_memory_bytes{memtype="virtual", groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 6, y: 5, w: 6, h: 12}
)
.addPanel(
    graphPanel.new(
        'Swapped memory',
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
            namedprocess_namegroup_memory_bytes{memtype="swapped", groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 12, y: 5, w: 6, h: 12}
)

.addPanel(
    row.new(title="Group Disk"),
    gridPos={ x: 0, y: 12, w: 24, h: 1}
)

.addPanel(
    graphPanel.new(
        'Disk Read',
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
            irate(namedprocess_namegroup_read_bytes_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 0, y: 13, w: 6, h: 12}
)

.addPanel(
    graphPanel.new(
        'Disk Write',
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
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 6, y: 13, w: 6, h: 12}
)

.addPanel(
    graphPanel.new(
        'Major page faults',
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
            irate(namedprocess_namegroup_major_page_faults_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 12, y: 13, w: 6, h: 12}
)
