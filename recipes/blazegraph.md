# Blazegraph

Blazegraph is a high-performance graph database that supports RDF and SPARQL.  
It is designed for large-scale data management and provides features like high
availability, scalability, and support for complex queries.

## Installation

Install openjdk, as Blazegraph requires Java to run:

```bash
sudo apt install openjdk-17-jre-headless
```

Create a folder for blazegraph jar, download the jar file, and set permissions:

```bash
sudo mkdir -p /opt/blazegraph
sudo wget https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_2_1_6_RC/blazegraph.jar -O /opt/blazegraph/blazegraph.jar
sudo chown -R $USER:$USER /opt/blazegraph
```

You can also create a dedicated system user for it if you prefer:

```bash
sudo adduser --system --no-create-home --group blazegraph
sudo chown -R blazegraph:blazegraph /opt/blazegraph
```

Create a systemd service for blazegraph:

```bash
sudo vi /etc/systemd/system/blazegraph.service
```

```ini
[Unit]
Description=blazegraph
After=network.target

[Service]
Type=simple
User=my_user
SyslogIdentifier=blazegraph
WorkingDirectory=/opt/blazegraph
ExecStart=/usr/bin/java \
  -Dfile.encoding=UTF-8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djetty.port=9999 \
  -server \
  -Xmx2g \
  -jar /opt/blazegraph/blazegraph.jar
SuccessExitStatus=143
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Activate service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now blazegraph
sudo systemctl status blazegraph
```

## Configuration

Creating namespaces (minimal or via properties file):

```bash
# Configuration
BLAZEGRAPH_URL="http://localhost:9999/blazegraph"
NAMESPACE="$1"
PROPS_FILE="${2:-$NAMESPACE.properties}"

# usage
if [[ -z "$NAMESPACE" ]]; then
  echo "Usage: $0 <namespace> [properties_file]"
  exit 1
fi

# create namespace
echo "Creating namespace '$NAMESPACE'..."

if [[ -f "$PROPS_FILE" ]]; then
  echo "Using properties file: $PROPS_FILE"
  curl -s -X POST -H 'Content-Type: text/plain' \
       --data-binary @"$PROPS_FILE" \
       "$BLAZEGRAPH_URL/namespace"
  echo
else
  echo "No properties file found. Using minimal inline config."
  curl -s -X POST -H 'Content-Type: text/plain' \
       --data-binary $'com.bigdata.rdf.sail.namespace='"$NAMESPACE"$'\n' \
       "$BLAZEGRAPH_URL/namespace"
  echo
fi
```

Example properties file:

```properties
com.bigdata.rdf.sail.namespace=mynamespace
com.bigdata.rdf.store.AbstractTripleStore.textIndex=false
com.bigdata.rdf.store.AbstractTripleStore.axiomsClass=com.bigdata.rdf.axioms.NoAxioms
com.bigdata.rdf.store.AbstractTripleStore.quads=false
com.bigdata.rdf.store.AbstractTripleStore.statementIdentifiers=false
com.bigdata.rdf.store.AbstractTripleStore.duplicateStatements=false
```

Drop all, load ttl file and query:

```bash
NS="mynamespace"
TTL="$NS.ttl"
ENDPOINT="http://localhost:9999/blazegraph/namespace/${NS}/sparql"

# Drop all data in the namespace
curl -X POST \
  -H 'Content-Type: application/sparql-update' \
  --data 'DROP ALL' \
  "$ENDPOINT"

# Load turtle file into the namespace
curl -X POST \
  -H 'Content-Type: text/turtle' \
  --data-binary @"$TTL" \
  "$ENDPOINT"

# Query the namespace as JSON to verify data
curl -G "$ENDPOINT" \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o } LIMIT 10" | jq .
```
