local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

local green = "#299c46";
local amber = "rgba(237, 129, 40, 0.89)";
local red = "#d44a3a";

grafana.dashboard.new(
    "Nomad Clients",
    editable = true,    
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)

.addPanel(
    graphPanel.new(
        'allocations running',
        span=6,
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocations_running)')
    ),
    gridPos={ x: 0, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'allocations blocked',
        span=6,
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocations_blocked)')
    ),
    gridPos={ x: 0, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'allocations migrating',
        span=6,
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocations_migrating)')
    ),
    gridPos={ x: 0, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'allocations pending',
        span=6,
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocations_pending)')
    ),
    gridPos={ x: 0, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'allocations terminal',
        span=6,
        fill=0,
        min=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocations_terminal)')
    ),
    gridPos={ x: 0, y: 0, w: 8, h: 4}
)

.addPanel(
    graphPanel.new(
        'cpu allocation',
        span=6,
        format="percentunit",
        fill=0,
        min=0,
        max=1,
        decimals=1,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocated_cpu) /
                     (sum without(job, node_id) (nomad_client_allocated_cpu)
                     +sum without(job, node_id) (nomad_client_unallocated_cpu))')
    ),
    gridPos={ x: 8, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'disk allocation',
        span=6,
        format="percentunit",
        fill=0,
        min=0,
        max=1,
        decimals=1,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocated_disk) /
                     (sum without(job, node_id) (nomad_client_allocated_disk)
                     +sum without(job, node_id) (nomad_client_unallocated_disk))')
    ),
    gridPos={ x: 8, y: 0, w: 8, h: 4}
)
.addPanel(
    graphPanel.new(
        'memory allocation',
        span=6,
        format="percentunit",
        fill=0,
        min=0,
        max=1,
        decimals=1,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('sum without(job, node_id) (nomad_client_allocated_memory) /
                     (sum without(job, node_id) (nomad_client_allocated_memory)
                     +sum without(job, node_id) (nomad_client_unallocated_memory))')
    ),
    gridPos={ x: 8, y: 0, w: 8, h: 4}
)
