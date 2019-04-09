local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local row = grafana.row;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Vault on Consul - Merged",
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
.addTemplate(
  template.new('route_query', '$ds', '{__name__=~"vault_route.+_count"}',
    regex="/^(.+)_count{/",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
  )
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
    row.new(title="Throughput"),
    gridPos={ x: 0, y: 6, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('Request $interval Rate',
        format='ops', fill=0, min=0, legend_show=false,
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('rate(vault_core_handle_request_count[$interval])')
    ),
    gridPos={ x: 0, y: 7, w: 6, h: 6}
)
.addPanel(
    graphPanel.new('Barrier $interval rate',
        format='ops', min=0, legend_show=true, stack=true,
    ).addTarget(
        prom.target('rate(vault_barrier_get_count[$interval])', legendFormat='GET')
    ).addTarget(
        prom.target('rate(vault_barrier_put_count[$interval])', legendFormat='PUT')
    ).addTarget(
        prom.target('rate(vault_barrier_list_count[$interval])', legendFormat='LIST')
    ).addTarget(
        prom.target('rate(vault_barrier_delete_count[$interval])', legendFormat='DELETE')
    ),
    gridPos={ x: 6, y: 7, w: 6, h: 6}
)
.addPanel(
    graphPanel.new('Consul Backend $interval Rate',
        format='ops', min=0, legend_show=true, stack=true,
    ).addTarget(
        prom.target('rate(vault_consul_get_count[$interval])', legendFormat='GET')
    ).addTarget(
        prom.target('rate(vault_consul_put_count[$interval])', legendFormat='PUT')
    ).addTarget(
        prom.target('rate(vault_consul_list_count[$interval])', legendFormat='LIST')
    ).addTarget(
        prom.target('rate(vault_consul_delete_count[$interval])', legendFormat='DELETE')
    ),
    gridPos={ x: 12, y: 7, w: 6, h: 6}
)
.addPanel(
    graphPanel.new('Tokens $interval Rate',
        format='ops', min=0, legend_show=true, stack=true,
    ).addTarget(
        prom.target('rate(vault_token_createAccessor_count[$interval])', legendFormat='createAccessor')
    ).addTarget(
        prom.target('rate(vault_token_create_count[$interval])', legendFormat='create')
    ).addTarget(
        prom.target('rate(vault_token_lookup_count[$interval])', legendFormat='lookup')
    ).addTarget(
        prom.target('rate(vault_token_revoke_count[$interval])', legendFormat='revoke')
    ).addTarget(
        prom.target('rate(vault_token_revoke_tree_count[$interval])', legendFormat='revoke_tree')
    ).addTarget(
        prom.target('rate(vault_token_store_count[$interval])', legendFormat='store')
    ),
    gridPos={ x: 18, y: 7, w: 6, h: 6}
)

.addPanel(
    row.new(title="Request Timings"),
    gridPos={ x: 0, y: 13, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('Handle Request Time - $quantile',
        format='ms', fill=0, min=0,
        repeat='quantile', repeatDirection='h',
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_core_handle_login_request{quantile=~"$quantile"}', legendFormat='login_request')
    ).addTarget(
        prom.target('vault_core_handle_request{quantile=~"$quantile"}', legendFormat='request')
    ).addTarget(
        prom.target('vault_core_check_token{quantile=~"$quantile"}', legendFormat='check_token')
    ).addTarget(
        prom.target('vault_core_fetch_acl_and_token{quantile=~"$quantile"}', legendFormat='fetch_acl_and_token')
    ),
    gridPos={ x: 0, y: 14, w: 8, h: 6}
)

.addPanel(
    row.new(title="Backend Timings"),
    gridPos={ x: 0, y: 20, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('Barrier Time - $quantile',
        format='ms', fill=0, min=0,
        repeat='quantile', repeatDirection='h',
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_barrier_get{quantile=~"$quantile"}', legendFormat='GET')
    ).addTarget(
        prom.target('vault_barrier_put{quantile=~"$quantile"}', legendFormat='PUT')
    ).addTarget(
        prom.target('vault_barrier_list{quantile=~"$quantile"}', legendFormat='LIST')
    ).addTarget(
        prom.target('vault_barrier_delete{quantile=~"$quantile"}', legendFormat='DELETE')
    ),
    gridPos={ x: 0, y: 21, w: 8, h: 6}
)
.addPanel(
    (graphPanel.new('Consul Backend Time - $quantile',
        format='ms', fill=0, min=0,
        repeat='quantile', repeatDirection='h',
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_consul_get{quantile=~"$quantile"}', legendFormat='GET')
    ).addTarget(
        prom.target('vault_consul_put{quantile=~"$quantile"}', legendFormat='PUT')
    ).addTarget(
        prom.target('vault_consul_list{quantile=~"$quantile"}', legendFormat='LIST')
    ).addTarget(
        prom.target('vault_consul_delete{quantile=~"$quantile"}', legendFormat='DELETE')
    ),
    gridPos={ x: 0, y: 21, w: 8, h: 6}
)

.addPanel(
    row.new(title="Token Timings"),
    gridPos={ x: 0, y: 27, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('Tokens - $quantile',
        format='ms', fill=0, min=0,
        repeat='quantile', repeatDirection='h',
    ) + {interval: '1s'}
    ).addTarget(
        prom.target('vault_token_createAccessor{quantile=~"$quantile"}', legendFormat='createAccessor')
    ).addTarget(
        prom.target('vault_token_create{quantile=~"$quantile"}', legendFormat='create')
    ).addTarget(
        prom.target('vault_token_revoke{quantile=~"$quantile"}', legendFormat='revoke')
    ).addTarget(
        prom.target('vault_token_revoke_tree{quantile=~"$quantile"}', legendFormat='revoke_tree')
    ).addTarget(
        prom.target('vault_token_store{quantile=~"$quantile"}', legendFormat='store')
    ).addTarget(
        prom.target('vault_token_lookup{quantile=~"$quantile"}', legendFormat='lookup')
    ),
    gridPos={ x: 0, y: 28, w: 8, h: 6}
)

.addPanel(
    row.new(title="Route Timings And Rate"),
    gridPos={ x: 0, y: 34, w: 24, h: 1}
)
.addPanel(
    (graphPanel.new('$route_query - $quantile - $interval',
        format='ms', fill=0, min=0, legend_show=true,
        repeat='route_query', repeatDirection='h',
    ) + {interval: '1s'}
    ).addSeriesOverride(
        { alias: "/^(0.5|0.9|0.99)$/", yaxis: 2, lines: false, points: true, legend: true, pointRadius: 2 }
    ).resetYaxes(
    ).addYaxis(min=0, format="ops",
    ).addYaxis(min=0, format="ms",
    ).addTarget(
        prom.target('rate(${route_query}_count[$interval])', legendFormat='rate')
    ).addTarget(
        prom.target('$route_query{quantile=~"$quantile"}', legendFormat='{{ quantile }}')
    ),
    gridPos={ x: 0, y: 35, w: 8, h: 6}
)


//vault_audit_log_request_count
//vault_audit_log_response_count

//vault_expire_fetch_lease_times_by_token_count
//vault_expire_fetch_lease_times_count
//vault_expire_register_auth_count
//vault_expire_renew_token_count
//vault_expire_revoke_by_token_count
//vault_expire_revoke_common_count
//vault_expire_revoke_count

//vault_policy_delete_policy_count
//vault_policy_get_policy_count
//vault_policy_set_policy_count

//vault_rollback_attempt_auth_token__count
//vault_rollback_attempt_cubbyhole__count
//vault_rollback_attempt_identity__count
//vault_rollback_attempt_sys__count

//vault_runtime_free_count
//vault_runtime_gc_pause_ns_count
//vault_runtime_malloc_count
