jsonnetfile.json:
	jb init

vendor/grafonnet-lib: jsonnetfile.json
	jb install github.com/grafana/grafonnet-lib

dashboards/%.json: %.jsonnet vendor/grafonnet-lib
	jsonnet -J vendor/grafonnet-lib/grafonnet $< -o $@

clean:
	rm -rf vendor/grafonnet-lib jsonnetfile.*
