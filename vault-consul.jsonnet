local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local row = grafana.row;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Vault on Consul",
    editable = true,
    graphTooltip = 'shared_crosshair',
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.custom('interval', '10s,30s,1m,5m,15m', '1m')
)
.addTemplate(
  template.custom('quantile', '0.5,0.9,0.99', '0.99') + {multi: true},
)
.addPanel(
    row.new(title="Node stats"),
    gridPos={ x: 0, y: 0, w: 24, h: 1}
)
.addPanel(
    graphPanel.new(
        'CPU',
        min=0,
        max=1,
        fill=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format="percentunit",
    ).addTarget(
        prom.target('avg without (cpu) (rate(node_cpu_seconds_total{mode!="idle"}[5m]))', legendFormat="{{mode}}")
    ),
    gridPos={ x: 0, y: 1, w: 6, h: 5}
)
.addPanel(
    graphPanel.new(
        'Disk I/O',
        min=0,
        max=1,
        fill=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format="percentunit",
    ).addTarget(
        prom.target('rate(node_disk_io_time_seconds_total{device!~"^(md[0-9]+$|dm-)"}[5m])', legendFormat="{{device}}")
    ),
    gridPos={ x: 6, y: 1, w: 6, h: 5}
)
.addPanel(
    graphPanel.new(
        'Network I/O',
        description="Negative=transmit, Positive=receive",
        fill=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format="bps",
    ).addTarget(
        prom.target('rate(node_network_receive_bytes_total[$interval])', legendFormat="{{device}}")
    ).addTarget(
        prom.target('-rate(node_network_transmit_bytes_total[$interval])', legendFormat="{{device}}")
    ),
    gridPos={ x: 12, y: 1, w: 6, h: 5}
)
.addPanel(
    graphPanel.new(
        'Memory',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format="bytes",
        stack=true,
    ).addTarget(
        prom.target('node_memory_MemTotal_bytes
         - node_memory_MemFree_bytes
         - node_memory_Buffers_bytes
         - node_memory_Cached_bytes', legendFormat="Used")
    ).addTarget(
        prom.target('node_memory_Buffers_bytes
                    + node_memory_Cached_bytes', legendFormat="Buffers+Cached")
    ).addTarget(
        prom.target('node_memory_MemFree_bytes', legendFormat="Free")
    ),
    gridPos={ x: 18, y: 1, w: 6, h: 5}
)

.addPanel(
    row.new(title="Vault Requests"),
    gridPos={ x: 0, y: 5, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('Request $interval Rate',
        format='ops', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('rate(vault_core_handle_request_count[$interval])')
    ),
    gridPos={ x: 0, y: 6, w: 6, h: 5}
)
.addPanel(
    (graphPanel.new('Handle Request Time',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_core_handle_request{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 6, y: 6, w: 6, h: 5}
)
.addPanel(
    (graphPanel.new('Check Token Time',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_core_check_token{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 12, y: 6, w: 6, h: 5}
)
.addPanel(
    (graphPanel.new('Fetch ACL and Token Time',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_core_fetch_acl_and_token{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 18, y: 6, w: 6, h: 5}
)

.addPanel(
    row.new(title="Consul Backend Timing"),
    gridPos={ x: 0, y: 11, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('consul GET',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_consul_get{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 0, y: 12, w: 6, h: 5}
)
.addPanel(
    (graphPanel.new('consul PUT',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_consul_put{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 6, y: 12, w: 6, h: 5}
)
.addPanel(
    (graphPanel.new('consul LIST',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_consul_list{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 12, y: 12, w: 6, h: 5}
)
.addPanel(
    (graphPanel.new('consul DELETE',
        format='ms', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_consul_delete{quantile=~"$quantile"}', legendFormat='{{quantile}}')
    ),
    gridPos={ x: 18, y: 12, w: 6, h: 5}
)

.addPanel(
    row.new(title="Consul Backend Throughput"),
    gridPos={ x: 0, y: 16, w: 24, h: 1}
)
.addPanel(
    graphPanel.new('consul GET rate',
        format='ops', fill=0, min=0, legend_show=false,
    ).addTarget(
        prom.target('rate(vault_consul_get_count[$interval])')
    ),
    gridPos={ x: 0, y: 17, w: 6, h: 5}
)
.addPanel(
    graphPanel.new('consul PUT rate',
        format='ops', fill=0, min=0, legend_show=false,
    ).addTarget(
        prom.target('rate(vault_consul_put_count[$interval])')
    ),
    gridPos={ x: 6, y: 17, w: 6, h: 5}
)
.addPanel(
    graphPanel.new('consul LIST rate',
        format='ops', fill=0, min=0, legend_show=false,
    ).addTarget(
        prom.target('rate(vault_consul_list_count[$interval])')
    ),
    gridPos={ x: 12, y: 17, w: 6, h: 5}
)
.addPanel(
    graphPanel.new('consul DELETE rate',
        format='ops', fill=0, min=0, legend_show=false,
    ).addTarget(
        prom.target('rate(vault_consul_delete_count[$interval])')
    ),
    gridPos={ x: 18, y: 17, w: 6, h: 5}
)
