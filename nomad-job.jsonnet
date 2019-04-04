local grafana = import "grafana.libsonnet";
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

local legformat = '{{task_group}}.{{exported_job}}';

grafana.dashboard.new(
    "Nomad Jobs",
    editable = true,    
)

.addTemplate(
  template.datasource('ds', 'prometheus', 'default')
)

.addPanel(
    graphPanel.new(
        'jobs running',
        span=6,
        fill=0,
        min=0,
        legend_show=true,
        legend_alignAsTable=true,
        legend_rightSide=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
    ).addTarget(
        prom.target('sum by(task_group,exported_job) (nomad_nomad_job_summary_running)',
          legendFormat=legformat)
    ),
    gridPos={ x: 0, y: 0, w: 15, h: 4}
)
.addPanel(
    graphPanel.new(
        'jobs queued',
        span=6,
        fill=0,
        min=0,
        legend_show=true,
        legend_alignAsTable=true,
        legend_rightSide=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
    ).addTarget(
        prom.target('sum by(task_group,exported_job) (nomad_nomad_job_summary_queued)',
          legendFormat=legformat)
    ),
    gridPos={ x: 0, y: 0, w: 15, h: 4}
)
.addPanel(
    graphPanel.new(
        'jobs complete',
        span=6,
        fill=0,
        min=0,
        legend_show=true,
        legend_alignAsTable=true,
        legend_rightSide=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
    ).addTarget(
        prom.target('sum by(task_group,exported_job) (nomad_nomad_job_summary_complete)',
          legendFormat=legformat)
    ),
    gridPos={ x: 0, y: 0, w: 15, h: 4}
)
.addPanel(
    graphPanel.new(
        'jobs failed',
        span=6,
        fill=0,
        min=0,
        legend_show=true,
        legend_alignAsTable=true,
        legend_rightSide=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
    ).addTarget(
        prom.target('sum by(task_group,exported_job) (nomad_nomad_job_summary_failed)',
          legendFormat=legformat)
    ),
    gridPos={ x: 0, y: 0, w: 15, h: 4}
)
.addPanel(
    graphPanel.new(
        'jobs starting',
        span=6,
        fill=0,
        min=0,
        legend_show=true,
        legend_alignAsTable=true,
        legend_rightSide=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
    ).addTarget(
        prom.target('sum by(task_group,exported_job) (nomad_nomad_job_summary_starting)',
          legendFormat=legformat)
    ),
    gridPos={ x: 0, y: 0, w: 15, h: 4}
)
.addPanel(
    graphPanel.new(
        'jobs lost',
        span=6,
        fill=0,
        min=0,
        legend_show=true,
        legend_alignAsTable=true,
        legend_rightSide=true,
        legend_hideEmpty=true,
        legend_hideZero=true,
        datasource='$ds',
    ).addTarget(
        prom.target('sum by(task_group,exported_job) (nomad_nomad_job_summary_lost)',
          legendFormat=legformat)
    ),
    gridPos={ x: 0, y: 0, w: 15, h: 4}
)



