# Joe Bylund's Resume

[joseph.bylund@gmail.com](mailto:joseph.bylund+resume@gmail.com?subject=Resume%20from%20Github)  
[resume](https://github.com/jbylund/resume/raw/main/joseph_bylund.pdf)  

# Previous Employment

## Altana
[Altana](https://altana.ai/) - ai powered solutions for shipping/logistics/customs/government - supply chain intelligence  
Spring 2022 - Summer 2023  
* Business network discovery and traversal - built tools to construct business networks from graph of world
wide shipment data.
* Search microservice - Built search microservice for companies, facilities and transactions in the Altana atlas using FastAPI, Pydantic, ArangoDB.
* Arango client library - built http client for ArangoDB supporting synchronous and asynchronous requests
used in search mircoservice.
* Spark client library - shimmed three different client libraries (pyspark, pyhive, databricks-sql-connector) to
pep-249 interface, supports creation of business networks.
* Geocoding client - wrote geocoding client library which handles address pre-processing and http requests to a pelias service. Built tooling to measure geocoding accuracy over time.
* Geocoding pipeline - built continuous address geocoding pipeline and geocoded the ~400 million addresses in the Altana atlas.


## Kensho
[Kensho](https://kensho.com/) - ai solutions for the financial industry  
Summer 2018 - Spring 2022

* Designed and implemented multi-step document processing pipeline using multiple in-house ML services.
* Designed and built speech-to-text alignment pipeline using SQS & gentle forced aligner.
* Implemented a number of checks in github hooks (pylint, flake8, mypy...), improving the developer experience.
* Migrated fuzzy company identification service to kubernetes and optimized performance.

## Moat / Oracle
[Moat](https://www.oracle.com/cx/advertising/measurement/) - Advertising analytics for advertisers and publishers  
Fall 2013 - Summer 2018  

* Designed and implemented distributed, fault-tolerant ETL, reducing cost by an order of magnitude, increasing reliability, and reducing processing time from ~10 hours to ~1 hour, making data available to clients far earlier in the day (using python, SQS, Redis, PostgreSQL).
* Numerous data-driven API improvements which lead to 3-4x improvement in API latency as well as maximum request size (PHP, CakePHP).
* Contributed improvements to ORM (CakePHP) and [PHP postgres driver](https://github.com/php/php-src/pull/1534) in order to reduce the number of queries necessary to render a page by 5x (decreasing page load time by ~3x) (CakePHP, c).
* Standardized deployment framework used to deploy thousands of servers of ~30 different roles to AWS (AWS, EC2, boto3).
* Migrated primary non-statistical database (users, accounts, metadata) from MySQL to PostgreSQL, improving uptime & flexibility (MySQL, PostgreSQL, foreign data wrappers).
* Migrated primary statistical database (500 million rows/day) from non-first normal form to first normal form schema, improving query latency, reducing storage demands, and increasing throughput.
* Architected and implemented sophisticated message routing system which is responsible for moving ~40 billion events per day from pixel servers to real-time processing servers while balancing CPU and memory constraints (c++).
* Architected and prototyped massively parallel decentralized data lake using AWS lambda and S3 for cost-effective storage and low-latency and cost-effective queries (AWS lambda, python, PostgreSQL)

# Education

## PhD Columbia University
2007 - 2013

PhD - Integrated Program In Cellular, Molecular and Biomedical Studies
Thesis: [Monte-Carlo Sampling of Protein-Ligand Interactions and Computational Improvements to Implicit Solvent Models](https://academiccommons.columbia.edu/doi/10.7916/D80G3H7B)

* Led development and maintenance of Protein Local Optimization Program (PLOP) project, a molecular mechanics library for protein structure prediction (fortran).
* Designed and implemented the computational mutation scanning module of PLOP.
* Redesigned build system to automatically determine dependencies and take advantage of parallel compilation, reducing build time from ~30 minutes to ~3 minutes and accelerating development.
* Created a small molecule database representing 95%+ of small molecules in the Protein Data Bank, extending PLOP from a protein-only program to a general molecular mechanics toolkit.
* Designed and implemented a Perl based automated regression testing framework, which accelerated development while minimizing bugs and regressions.
* Created a project wiki, combining scattered documentation and completing missing documentation.

## Undergraduate Rice University
2003 - 2007

# Skills

