local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new("Vault and Consul", editable = true, time_from='now-5m', refresh='5s')

.addPanel(
    (graphPanel.new('vault: update auth token (5s rate)',
        format='ops', span=6, fill=0, min=0, legend_show=false) + {interval: '1s'})
    .addTarget(prom.target(
        'rate(vault_route_update_auth_token__count[5s])',
        intervalFactor=1, interval='1s')),
    gridPos={ x: 0, y: 0, w: 8, h: 4}
)
.addPanel(
    (graphPanel.new('vault: consul put (5s rate)',
        format='ops', span=6, fill=0, min=0, legend_show=false) + {interval: '1s'})
    .addTarget(prom.target(
        'rate(vault_consul_put_count[1m])',
        intervalFactor=1, interval='1s')),
    gridPos={ x: 0, y: 4, w: 8, h: 4}
)

.addPanel(
    (graphPanel.new('host: cpu',
        format='percentunit', span=6, fill=0, min=0, legend_show=false, max=1) + {interval: '1s'})
    .addTarget(prom.target(
        'avg without (cpu)(irate(node_cpu_seconds_total{mode!="idle"}[5s]))',
        intervalFactor=1, interval='1s')),
    gridPos={ x: 0, y: 8, w: 8, h: 4}
)
.addPanel(
    (graphPanel.new('host: disk I/O utilization',
        format='percentunit', span=6, fill=0, min=0, legend_show=false, max=1) + {interval: '1s'})
    .addTarget(prom.target(
        "irate(node_disk_io_time_seconds_total[5s])",
        intervalFactor=1, interval='1s')),
    gridPos={ x: 0, y: 12, w: 8, h: 4}
)



