local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

local green = "#299c46";
local amber = "rgba(237, 129, 40, 0.89)";
local red = "#d44a3a";

grafana.dashboard.new(
    "Nomad Servers",
    editable = true,    
)
.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)

.addPanel(
    singlestat.new('nomad up',
        valueName='current',
        sparklineShow=true,
        gaugeShow=true,
        gaugeMaxValue=3,
        colorValue=true,
        thresholds='2,3',
        colors=[red, amber, green],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(up{job="nomad-servers"})')
    ),
    gridPos={ x: 0, y: 0, w: 2, h: 4}
)
.addPanel(
    singlestat.new('broker ready',
        valueName='current',
        sparklineShow=true,
        colorValue=true,
        thresholds='1,3',
        colors=[green, amber, red],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(nomad_nomad_broker_total_ready)')
    ),
    gridPos={ x: 2, y: 0, w: 2, h: 4}
)
.addPanel(
    singlestat.new('broker unacked',
        valueName='current',
        sparklineShow=true,
        colorValue=true,
        thresholds='1,3',
        colors=[green, amber, red],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(nomad_nomad_broker_total_unacked)')
    ),
    gridPos={ x: 4, y: 0, w: 2, h: 4}
)
.addPanel(
    singlestat.new('broker blocked',
        valueName='current',
        sparklineShow=true,
        colorValue=true,
        thresholds='1,3',
        colors=[green, amber, red],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(nomad_nomad_broker_total_blocked)')
    ),
    gridPos={ x: 6, y: 0, w: 2, h: 4}
)
.addPanel(
    graphPanel.new(
        'raft: GC pausing over prev minute',
        description="Indicator of memory pressure. See [doc](https://www.nomadproject.io/docs/telemetry/index.html)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=500,
        legend_show=false,
        datasource='$ds',
   )
    .addTarget(
        prom.target('sum without(job) (rate(nomad_runtime_total_gc_pause_ns{job="nomad-servers"}[1m]))/1000000'),
    ),
    gridPos={ x: 8, y: 0, w: 8, h: 4}
)

.addPanel(
    graphPanel.new(
        'raft: rpc request rate',
        span=6,
        format='ops',
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
   )
    .addTarget(
        prom.target('sum without(job) (rate(nomad_nomad_rpc_request[1m]))'),
    ),
    gridPos={ x: 0, y: 4, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: rpc request error rate',
        span=6,
        format='ops',
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job) (rate(nomad_nomad_rpc_request_error[1m]))'),
    ),
    gridPos={ x: 8, y: 4, w: 8, h: 5}
)

.addPanel(
    graphPanel.new(
        'raft: time for leader to contact followers - 99th%',
        description="General indicator of Raft latency. See [doc](https://www.nomadproject.io/docs/telemetry/index.html)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=2000,
        legend_show=false,
        datasource='$ds',
   )
    .addTarget(
        prom.target('sum without(job,quantile) (nomad_raft_leader_lastContact{quantile="0.99"})'),
    ),
    gridPos={ x: 0, y: 9, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: append time - 99th%',
        description="General indicator of Raft latency.",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job,quantile) (nomad_raft_replication_appendEntries_rpc{quantile="0.99"})'),
    ),
    gridPos={ x: 8, y: 9, w: 8, h: 5}
)

