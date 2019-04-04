local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

local green = "#299c46";
local amber = "rgba(237, 129, 40, 0.89)";
local red = "#d44a3a";

grafana.dashboard.new(
    "Consul Servers",
    editable = true,    
)
.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)

.addPanel(
    singlestat.new('consuls up',
        valueName='current',
        sparklineShow=true,
        gaugeShow=true,
        gaugeMaxValue=3,
        colorValue=true,
        thresholds='2,3',
        colors=[red, amber, green],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(up{job="consul-servers"})')
    ),
    gridPos={ x: 0, y: 0, w: 2, h: 4}
)
.addPanel(
    singlestat.new('autopilot',
        valueName='current',
        sparklineShow=true,
        gaugeShow=true,
        gaugeMaxValue=1,
        colorValue=true,
        thresholds='0,1',
        colors=[red, amber, green],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(consul_autopilot_healthy)')
    ),
    gridPos={ x: 2, y: 0, w: 2, h: 4}
)
.addPanel(
    singlestat.new('candidate',
        valueName='current',
        sparklineShow=true,
        gaugeShow=true,
        gaugeMaxValue=1,
        colorValue=true,
        thresholds='2,1',
        colors=[green, amber, red],
        datasource='$ds',
    ).addTarget(
        prom.target('sum(consul_raft_state_candidate)')
    ),
    gridPos={ x: 4, y: 0, w: 2, h: 4}
)
.addPanel(
    graphPanel.new(
        'raft: GC pausing over prev minute',
        description="see [doc](https://www.consul.io/docs/agent/telemetry.html#leadership-changes)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=500,
        legend_show=false,
        datasource='$ds',
   )
    .addTarget(
        prom.target('rate(consul_runtime_total_gc_pause_ns[1m])/1000000'),
    ),
    gridPos={ x: 8, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'raft: time for leader to contact followers - 99th%',
        description="see [doc](https://www.consul.io/docs/agent/telemetry.html#leadership-changes)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=2000,
        legend_show=false,
        datasource='$ds',
   )
    .addTarget(
        prom.target('consul_raft_leader_lastContact{quantile="0.99"}'),
    ),
    gridPos={ x: 0, y: 4, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: replication heartbeat - 99th%',
        description="see [doc](https://www.consul.io/docs/agent/telemetry.html#leadership-changes)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=500,
        legend_show=false,
        datasource='$ds',
   )
    .addTarget(
        prom.target('consul_raft_replication_heartbeat{quantile="0.99"}'),
    ),
    gridPos={ x: 8, y: 4, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: transaction rate',
        span=6,
        fill=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('rate(consul_raft_apply[1m])'),
    ),
    gridPos={ x: 0, y: 9, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: transaction commit time - 99th%',
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('consul_raft_commitTime{quantile="0.99"}'),
    ),
    gridPos={ x: 8, y: 14, w: 8, h: 5}
)

