local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Raspberry Pi",
    editable = true,
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)
.addTemplate(
  template.new('instance', '$ds', 'label_values(rpi_throttled, instance)',
    allValues=".+",
    includeAll=true,
    multi=true,
    sort=1,
    refresh=1,
    regex="^([^:]+):.+$",
  )
)

.addPanel(
    graphPanel.new(
        'Temperature',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format='celsius',
    ).addTarget(
        prom.target('rpi_temperature_celsius{instance=~"($instance).*"}', legendFormat="{{instance}}")
    ),
    gridPos={ x: 0, y: 0, w: 6, h: 7}
)

.addPanel(
    graphPanel.new(
        'Throttled',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format='hex0x',
    ).addTarget(
        prom.target('rpi_throttled{instance=~"($instance).*"}', legendFormat="{{instance}}")
    ),
    gridPos={ x: 6, y: 0, w: 6, h: 7}
)

.addPanel(
    graphPanel.new(
        'Voltage',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format='volt',
    ).addTarget(
        prom.target('rpi_voltage_volts{instance=~"($instance).*"}', legendFormat="{{instance}} {{component}}")
    ),
    gridPos={ x: 0, y: 7, w: 6, h: 7}
)
.addPanel(
    graphPanel.new(
        'Frequency',
        min=0,
        legend_show=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
        format='hertz',
    ).addTarget(
        prom.target('rpi_frequency_hz{instance=~"($instance).*"}', legendFormat="{{instance}} {{component}}")
    ),
    gridPos={ x: 6, y: 7, w: 6, h: 7}
)
