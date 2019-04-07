# grafana-dashboards

These are dashboards I use in my home systems.  They are built using 
[Jsonnet](https://jsonnet.org/) and [Grafonnet](https://github.com/grafana/grafonnet-lib)
but you don't need any of those unless you want to submit changes to this repo,
because the compiled dashboards are available under [dashboards](dashboards/).

You can push these into your Grafana as admin 
(assuming you have curl and jq installed) using

```bash
bin/pushToGrafana.sh http://admin:yourpassword@my-grafana-host:3000 
```

## Dashboards

### consul-server

Monitor a Consul cluster's Consul servers.

### consul-services

Monitor a Consul cluster's services using consul_exporter.

### nomad-server

Monitor a Nomad cluster's Nomad servers.

### nomad-client

Monitor a Nomad cluster's Nomad client agents.

### nomad-job

Monitor a Nomad cluster's Nomad jobs.

### process-exporter

High-level view of the most important process-exporter metrics.

### process-exporter-storage

Drill down on process-exporter memory and disk metrics.

### process-exporter-detail

Detail view of process-exporter metrics not covered by process-exporter-storage.

### prom-targets

Monitor Prometheus scrape targets for `up` and `scrape_duration_seconds`.

### raspberrypi

Use script-exporter and raspberrypi_exporter to monitor your Pi hardware.

### node_exporter

Derived from the Robust Perceptions dashboard, this one is tweaked to my needs.

