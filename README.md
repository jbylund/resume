# Joe Bylund

Lead Software Engineer — Boston, MA

[joseph.bylund@gmail.com](mailto:joseph.bylund+resume@gmail.com?subject=Resume%20from%20Github)
· [github.com/jbylund](https://github.com/jbylund)
· [linkedin.com/in/josephbylund](https://www.linkedin.com/in/josephbylund/)
· [resume (pdf)](https://github.com/jbylund/resume/raw/main/joseph_bylund.pdf)

# Experience

## Klaviyo — Lead Software Engineer
Boston, MA · August 2023 - Present

* **Purchase containment filtering** - designed a bloom filter architecture replacing repeated large-scale ClickHouse scans, bulk-streaming (person, item) pairs into Redis. Reduced data scanned by ~1000x on a path accounting for ~1/3 of total ClickHouse cluster load. Sketched the design for a partner team and shepherded them through implementation (ClickHouse, Redis, python).
* **Information schema as a service** - prototyped a SQL interface over multi-tenant, schema-on-read JSON data, and later rejoined the team that productionized it. Built the manifest service translating user-supplied SQL into queries against JSON-backed tables, giving customers a typed SQL API over untyped storage. Cut manifest resolution latency 3x end to end (python, gRPC, MySQL, StarRocks).
* **Query service** - founding engineer on a gRPC query service over multi-tenant event data: interceptor stack (rate limiting, validation, concurrency limiting, slow-request logging), sharded connection pooling, executors for ClickHouse, PostgreSQL and MySQL, and query rewriting (python, gRPC, ClickHouse, PostgreSQL, MySQL).
* **Metrics service performance** - added profiling instrumentation, then optimized query mapping and result processing, reducing latency ~58% across every request the service serves (python, gRPC, ClickHouse).
* **Custom objects** - built gRPC APIs letting customers define schemas for their own objects, with per-company partitioned rate limiting and a shared Redis Sentinel client, modeled as data vault hubs, links and satellites (python, gRPC, Redis, Pulsar).
* **Developer velocity** - parallelized test containers, added CI cache targets, and built local development environments used across teams.

## Altana — Senior Software Engineer
New York City (Remote) · March 2022 - June 2023

* **Business network discovery and traversal** - built the tools constructing business networks from a graph of worldwide shipment data (python).
* **Search service** - built the search microservice for companies, facilities and transactions in Altana's Atlas, and the two libraries under it: a synchronous and asynchronous ArangoDB http client, and a query layer composing logical filters into AQL (python, FastAPI, Pydantic, ArangoDB).
* **Spark client library** - shimmed three client libraries (pyspark, pyhive, databricks-sql-connector) to one pep-249 interface, so network construction could run against any of them.
* **Geocoding** - built a continuous pipeline and the client under it — address pre-processing, requests to a Pelias service, and tooling tracking match accuracy over time — geocoding the ~400 million addresses in Altana's Atlas (python, Pelias).

## Kensho — Software Engineer
Cambridge, MA · September 2018 - March 2022

* **Document processing** - designed and built a multi-step pipeline orchestrating several in-house ML services (python).
* **PDF extraction performance** - the extractor held pages in a memory-efficient form that the pipeline then mutated heavily. Wrapped the hot path in a conversion to a mutable representation and back, invisible to every caller and with no test changed, cutting the worst documents from 30-60 minutes to 1-2 minutes (python).
* **Neighbour search** - applied spatial hashing to an element-to-element distance search, comparing only the same and adjacent cells rather than every pair (python).
* **Speech-to-text alignment** - built the pipeline aligning earnings call transcripts to audio with the gentle forced aligner (python, SQS).
* **Entity resolution** - migrated the entity resolution service to kubernetes, then profiled and parallelized it for a ~3x speedup (python, kubernetes).
* **Developer experience** - added pylint, flake8 and mypy checks to github hooks.

## Moat — Senior Backend Engineer & Data Scientist
New York, NY · September 2013 - September 2018

* **Distributed ETL** - designed and built a fault-tolerant pipeline, cutting cost by an order of magnitude and processing time from ~10 hours to ~1 hour, so data reached clients far earlier in the day (python, SQS, Redis, PostgreSQL).
* **Event routing** - routed ~40 billion events per day from pixel servers into real-time processing, sharding by client, by configurable key and by session, so that one client's traffic could not degrade another's and data arrived pre-aggregated, leaving the ETL far less to merge (c++).
* **Statistical database** - migrated the primary statistical store (500 million rows/day) from non-first to first normal form, improving query latency and throughput while reducing storage demands.
* **Stats API performance** - sped up the primary statistics routes clients called for reporting and exports, cutting latency ~3x and raising the maximum request size through profiling-guided work on serialization and the query paths behind them (PHP, CakePHP).
* **Platform** - migrated users, accounts and metadata from MySQL to PostgreSQL with zero downtime, bridging the two through a MySQL foreign data wrapper during the cutover, and standardized the deployment framework running thousands of servers across ~30 roles on AWS (PostgreSQL, MySQL, EC2, boto3).
* **Data lake** - architected and prototyped a decentralized data lake querying compressed SQLite files on S3 through massively parallel AWS Lambda invocations, and wrote a Multicorn foreign data wrapper exposing it through a standard PostgreSQL interface, so it could be queried like any other data system (AWS lambda, python, SQLite, PostgreSQL).

# Projects

### Sylvan Librarian ([sylvan-librarian.com](https://sylvan-librarian.com/), [source](https://github.com/jbylund/sylvan_librarian))

Open source Magic: The Gathering card search engine in rust, implementing Scryfall's query syntax - a query engine with its own parser, cost based planner and execution engine. Self-hosted with blue/green deploys behind nginx; independently forked to Cloudflare Workers by an outside contributor.

* **Cost based query planner** - replaced a hand-maintained decision tree over four execution plans with a cost model picking the cheapest, fed exact counts (plane popcounts, partition-point widths, posting lengths) rather than cardinality estimates. Chooses the empirically fastest plan on 87 of 88 calibration queries at unchanged throughput: shipped for extensibility, not speed (rust, [pull request](https://github.com/jbylund/sylvan_librarian/pull/712)).
* **In-process query engine** - replaced the PostgreSQL search path with an in-memory rust/PyO3 filter engine over 96k cards, ~76x faster on a geometric mean of representative queries (0.20ms vs 14.9ms), taking the database out of the hot path (rust, PyO3, [pull request](https://github.com/jbylund/sylvan_librarian/pull/490)).
* **Query parser** - hand-rolled a recursive descent parser for the full query language, ~49x faster than the pyparsing grammar it replaced (158k vs 3.2k parses/sec), with a 133 case parity suite asserting both emit identical SQL (python, [pull request](https://github.com/jbylund/sylvan_librarian/pull/482)).

### [pg_mimic](https://github.com/jbylund/pg_mimic)

Pure-python asyncio implementation of the PostgreSQL wire protocol, letting any python process present a postgres interface to standard clients rather than a bespoke http api. Verified against psycopg, asyncpg, pg8000 and psql (python, asyncio).

# Open Source Contributions

### [Python packaging - pip and packaging](https://github.com/pypa/pip)

* **Candidate selection** - replaced a linear scan of the supported tag list with a precomputed index lookup, cutting best-candidate selection 11x in profiling, from 68s to 6.2s over 30 calls ([pull request](https://github.com/pypa/pip/pull/9748)).
* **Tag equality** - short-circuited tag comparison on a cached hash. Comparing tags accounted for two thirds of the time spent picking a candidate; it got 2.5x faster and nearly halved the operation overall ([pull request](https://github.com/pypa/packaging/pull/417)).

Together these cut the time spent on pip steps in ci (at Kensho).

### [Python typeshed](https://github.com/python/typeshed)

Widened the cachetools stubs, where cache sizes were typed as integers although a custom getsizeof may return any number, so correctly typed code using fractional sizes failed type checking ([pull request](https://github.com/python/typeshed/pull/5440)).

### [Gnome Shotwell Photo Manager](https://gitlab.gnome.org/GNOME/shotwell)

47 commits from 2013 to 2021, across the import pipeline, thumbnail cache, saved searches, publishing plugins and build system (vala).

* **Import throughput** - reworked thumbnail generation to decode each photo once and derive every thumbnail size from that single decode, rather than decoding once per size ([commit](https://gitlab.gnome.org/GNOME/shotwell/-/commit/3a424909653f77e1e337ac3e1aad803b49f04942)).
* **RAW metadata** - cached metadata on the RAW reader so a file is parsed once per import instead of on every access ([commit](https://gitlab.gnome.org/GNOME/shotwell/-/commit/979f26a1347b39461722e9c9ef15caa6285b6b9f)).

### [PHP](https://github.com/php/php-src)

Removed a per-column roundtrip to the database in PDO's PostgreSQL driver, resolving the common type OIDs directly instead of querying for each one ([commit](https://github.com/php/php-src/commit/e10257ba8069fb982d9cd8681f6633de9fea534d)). Shipped in PHP since 2015; the saving scales with the width of the result set, and at Moat it cut queries and page load time by more than an order of magnitude on the user administration pages.

# Education

## Columbia University
New York, NY · 2007 - 2013

PhD - Computational Chemistry

Thesis: [Monte-Carlo Sampling of Protein-Ligand Interactions and Computational Improvements to Implicit Solvent Models](https://academiccommons.columbia.edu/doi/10.7916/D80G3H7B)

* **PLOP** - led development and maintenance of the Protein Local Optimization Program, a molecular mechanics library for protein structure prediction, and wrote its computational mutation scanning module (fortran).
* **Build system** - redesigned it to automatically determine dependencies and take advantage of parallel compilation, reducing build time from ~30 minutes to ~3 minutes and accelerating development.
* **Small molecule database** - built a database representing 95%+ of small molecules in the Protein Data Bank, extending PLOP from a protein-only program to a general molecular mechanics toolkit.
* **Regression testing** - built a Perl based automated test framework, which accelerated development while minimizing bugs and regressions.

## Rice University
Houston, TX · 2003 - 2007

Bachelor of Arts - Mathematics  
Bachelor of Science - Ecology and Evolutionary Biology

# Technologies & Skills

* **Languages** - Python, SQL, rust, C++
* **Data stores** - ClickHouse, PostgreSQL, MySQL, StarRocks, Redis, ArangoDB; previously Vertica, Redshift
* **Platform** - AWS (EC2, S3, RDS, Lambda, DynamoDB), Kubernetes, gRPC; Kafka, Pulsar, SQS, Kinesis, RabbitMQ
