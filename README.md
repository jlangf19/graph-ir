# Neo4j Incident Response Platform
*The vision of this project is to design an incident response and security monitoring tool that processes data the way humans do: as a series of observations that are interconnected in time and space. This platform will emphasize the interconnection of artifacts across a client network to show the relationships between IOCs, validate compromise scope, and generate insights in an intuitive fashion.*
## Requirements
### Hardware
* LOOK UP MIN SPECS FOR ITEMS in Software *
### Software
**Python:** Version 3.9+
Required packages: scapy, py2neo, pandas (see setup for installation)

**Neo4j:** Version 4.4+ (Community or Enterprise Edition)
## Setup

**Neo4j:**
* **Source:** /etc/neo4j/neo4j.conf
* **Data Import:** All data required for import into the graph database must be placed within */var/lib/neo4j/import*. Current cypher ingestion expressions ingest .CSV files.
* **Launch:** Launch Neo4j server with the following command: *sudo neo4j start*
## Sources
