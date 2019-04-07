local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local row = grafana.row;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Process Exporter Detail",
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
    row.new(title="CPU"),
    gridPos={ x: 0, y: 5, w: 24, h: 1}
)
.addPanel(
    graphPanel.new(
        'CPU User',
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
            irate(namedprocess_namegroup_cpu_user_seconds_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 0, y: 5, w: 6, h: 12}
)
.addPanel(
    graphPanel.new(
        'CPU System',
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
            irate(namedprocess_namegroup_cpu_system_seconds_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 6, y: 5, w: 6, h: 12}
)
.addPanel(
    graphPanel.new(
        'Context switches',
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
            irate(namedprocess_namegroup_context_switches_total{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 12, y: 5, w: 6, h: 12}
)

.addPanel(
    row.new(title="Processes and Threads"),
    gridPos={ x: 0, y: 12, w: 24, h: 1}
)

.addPanel(
    graphPanel.new(
        'Num processes',
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
            namedprocess_namegroup_num_procs{groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 0, y: 13, w: 6, h: 12}
)

.addPanel(
    graphPanel.new(
        'Num threads',
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
            namedprocess_namegroup_num_threads{groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 6, y: 13, w: 6, h: 12}
)

.addPanel(
    graphPanel.new(
        'Exits/Restarts',
        description="These represent changes to the oldest start time in the group.
        When there is a single process in the group this must mean it restarted.
        With multiple processes it's more ambiguous: it could just mean that the
        oldest one exited and no new process has started.",
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
            changes(namedprocess_namegroup_oldest_start_time_seconds{groupname=~"$group", instance=~"$instance"}[1m])
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 12, y: 13, w: 6, h: 12}
)

.addPanel(
    row.new(title="Filedescs and waits"),
    gridPos={ x: 0, y: 25, w: 24, h: 1}
)

.addPanel(
    graphPanel.new(
        'Open filedescs',
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
            namedprocess_namegroup_open_filedesc{groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 0, y: 26, w: 6, h: 12}
)

.addPanel(
    graphPanel.new(
        'Worst filedesc ratio',
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
            namedprocess_namegroup_worst_fd_ratio{groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}}")
    ),
    gridPos={ x: 6, y: 26, w: 6, h: 12}
)

.addPanel(
    graphPanel.new(
        'Wchan threads',
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
        prom.target('sum by (groupname, wchan) (
            namedprocess_namegroup_threads_wchan{groupname=~"$group", instance=~"$instance"}
          )',
          legendFormat="{{groupname}} {{wchan}}")
    ),
    gridPos={ x: 12, y: 26, w: 6, h: 12}
)
