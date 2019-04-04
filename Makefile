DASHBOARDS=consul-server.json nomad-server.json nomad-client.json nomad-job.json

jsonnetfile.json:
	jb init

vendor/grafonnet-lib: jsonnetfile.json
	jb install github.com/grafana/grafonnet-lib

dashboards/%.json: %.jsonnet vendor/grafonnet-lib
	jsonnet -J vendor/grafonnet-lib/grafonnet $< -o $@

#grafana: $(DASHBOARDS)
#	for i in $(DASHBOARDS); do ../bin/dashToCurl < $$i | curl -i -u admin:admin -H "Content-Type: application/json" -X POST http://grafana.service.dc1.consul:3000/api/dashboards/db -d @- ; done

clean:
	rm $(DASHBOARDS)
	rm -rf vendor/grafonnet-lib jsonnetfile.*
