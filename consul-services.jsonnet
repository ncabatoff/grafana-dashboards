local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local row = grafana.row;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Consul Services",
    editable = true,
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.new('service', '$ds', 'label_values(consul_catalog_service_node_healthy, service_name)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
  )
)
.addTemplate(
  template.new('node', '$ds', 'label_values(consul_catalog_service_node_healthy{service_name=~"$service"}, node)',
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
        'consul_exporter up',
        span=6,
        fill=0,
        min=0,
        max=1,
        decimals=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('up{job="consul_exporter"}')
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 4}
)
.addPanel(
    graphPanel.new(
        'consul up',
        span=6,
        fill=0,
        min=0,
        max=1,
        decimals=0,
        legend_show=false,
        datasource='$ds',
    ).addTarget(
        prom.target('consul_up')
    ),
    gridPos={ x: 6, y: 0, w: 6, h: 4}
)

.addPanel(
    row.new(title="Service status"),
    gridPos={ x: 0, y: 5, w: 24, h: 1}
)
.addPanel(
    graphPanel.new(
        '$service',
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        repeat='service',
        repeatDirection='h',
        fill=false,
    ).addSeriesOverride(
        { alias: "/(critical|warning|maintenance)/", yaxis: 2, lines: false, points: true, legend: false }
    ).resetYaxes(
    ).addYaxis(min=0, decimals=0
    ).addYaxis(min=0, decimals=0,
    ).addTarget(
        prom.target('sum by (node) (consul_catalog_service_node_healthy{service_name="$service", node=~"$node"})', legendFormat="{{node}}")
    ).addTarget(
        prom.target(
           'consul_health_service_status{service_name="$service", node=~"$node", status!="passing"} > 0',
           legendFormat="{{node}} {{status}}",
           intervalFactor=1,
        )
    ),
    gridPos={ x: 0, y: 6, w: 6, h: 5}
)

