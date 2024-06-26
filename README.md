# Google Analytics Events dbt package

The Google Analytics Events dbt package processes GA4 events data for analysis across various databases, not just BigQuery. 
It includes a pipeline script for **data ingestion** from BigQuery, **normalizing** the data into relational tables for cross-database compatibility. 
After normalization, the data is **loaded** into a chosen database like Redshift or Snowflake. 
To use the dbt package, you install it and run it on the prepared data, enabling SQL queries across different databases. 
The dbt package constructs **dimensional models** to facilitate analytics, providing insights into user behaviors and event interactions. 
Customization options allow alignment with specific analytical needs, enhancing the data's utility for in-depth analysis.


## Use case of the package

__You are using GA4 Events in a different database than Bigquery__
* This package comes with its own ingestion pipeline to copy data from GA4 Bigquery events export into one of [these](https://dlthub.com/docs/dlt-ecosystem/destinations/) destinations.
* This pipeline normalizes nested structures from bigquery into relational tables before loading, to enable db-agnostic, universal sql queries.
* The dbt package uses cross-db compatibility macros and was tested on Redshift, Athena, Snowflake, Postgres.
* The package creates stateful entities for users, sessions, to enable describing the event stream and answer questions like "What was the source of the user who clicked out on X".
* The package contains a small configurator that enables you to bring event parameters (which are their own table) into the event row for simpler usage.


## Install `dbt` model

dbt version required: >=1.7.0
Include the following in your `packages.yml` file:
```yaml
packages:
  - package: dlthub/ga4_event_export
    version: 0.1.0
```
Run dbt deps to install the package.

```shell
dbt deps
```

To load the data that this model depends on, follow this section: [How to run the `dlt` pipeline](#how-to-run-the-dlt-pipeline)


For more information on using packages in your dbt project, 
check out the [dbt Documentation](https://docs.getdbt.com/docs/package-management).

## Models overview

This dbt package contains a `dbt` dimensional models based on Google Analytics data from BigQuery source.
The main use of this package is to provide a stable cross-database dimensional model that will provide useful insights.
Models
The primary outputs of this package are fact and dimension tables as listed below. There are several intermediate stage models used to create these models. 

| Type      | Model              | Description                                                                                                                                                                                                                                                                                                                                                                                                           |
|-----------|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Dimension | dim_device         | The model contains all the information about the users' device.                                                                                                                                                                                                                                                                                                                                                       |
| Dimension | dim_geography      | The model consolidates event data with geographical information. This model provides insights into the geographic aspects of events, including city, country, continent, region, sub-continent, and metro information.                                                                                                                                                                                                |
| Dimension | dim_page           | This model provides insights into user interactions with pages, helping to analyze and understand user behavior on the platform.                                                                                                                                                                                                                                                                                      |
| Dimension | dim_traffic_source | The model contains traffic information. The model provides a comprehensive view of user acquisition and marketing performance.                                                                                                                                                                                                                                                                                        |
| Dimension | dim_user           | The model derives insights into user sessions. It calculates session metrics such as the number of sessions, the first and last seen timestamps, and the corresponding events and page titles associated with these timestamps. The model provides a comprehensive summary of user engagement, including details about the usage of transient tokens, user lifetime value currency, and session-specific information. |
| Fact      | fact_events        | This model provides a comprehensive view of user engagement, enabling analysis of revenue, acquisition channels, session engagement, and scroll behavior.                                                                                                                                                                                                                                                             | 
| Fact      | fact_sessions      | The model extracts key engagement metrics. This model provides insights into session-level engagement, capturing details about session activity, duration, and entrances, facilitating analysis of user interactions and session quality.                                                                                                                                                                             | 

## Database support
We support 
- Redshift, 
- BigQuery,
- Snowflake, 
- Athena, 
- Postgres.


## How to use this package

We recommend that you add this package as a dependency to your own `dbt` package.

### Package customizations

We advise you to customize your package if you
- Want to specify your own paid sources with `ga4_data_paid_sources`. 
  For instance, if Google marks Reddit ads as organic, you can define them as paid.
- Want to unpack more event parameters with `ga4_data_extra_event_params`.

The columns name for `ga4_data_extra_event_params` and `ga4_data_paid_sources` may be configured in `dbt_project.yml` or by passing the variables in command line:

```shell
dbt run --profiles-dir . --vars '{ga4_data_schema_name: <schema_name>, ga4_data_paid_sources: ["reddit.com", "youtube.com"], ga4_data_extra_event_params: ["page_referrer"]}' --fail-fast
```


### Configuration

In order to use any of them, you need to provide access credentials to the profile that you choose. 
Each profile requires a set of environment variables to be present. We recommend to use `.env` file to define env variables.

1. `ga4_schema_redshift` profile to connect to Redshift.
2. `ga4_schema_bigquery` profile to connect to BigQuery.
3. `ga4_schema_snowflake` profile to connect to Snowflake.

...

To use any of the profiles
1. Enable the profile in `dbt_project.yml` (or pass the profile explicitly to the `dbt` command)
2. Create `.env` file and fill the environment variables.
   Example:
   ```shell
   # .env file
   PG_DATABASE_NAME=databse-name
   PG_USER=database-uer
   PG_HOST=ip-or-host-name
   PG_PORT=5439
   PG_PASSWORD=set-me-up
   ```
3. Export the credentials into shell via `set -a && source .env && set +a`


## How to run the `dlt` pipeline

The package includes a pipeline script (`bigquery_pipeline.py`) to **ingest** GA4 events data from a BigQuery source. 
This pipeline is necessary when your analytics data resides in a different database than BigQuery, 
allowing you to migrate this data to a supported destination database. 

The pipeline **normalizes** nested structures found in the BigQuery export into relational tables. 
This process transforms complex JSON-like structures into a format that is understandable and usable across different databases, 
ensuring that the data is ready for cross-database SQL queries. 

The normalized data is then **loaded** into one of the supported destinations (e.g., Redshift, Athena, Snowflake, Postgres) 
as specified in the pipeline's configuration. 
The choice of destination depends on your analytical stack and preferences.


The [`bigquery_pipeline.py`](./bigquery_pipeline.py) is a [dlt](https://dlthub.com/docs/intro) pipeline,
which loads your GA4 data for the last month from BigQuery database to a [destination](https://dlthub.com/docs/dlt-ecosystem/destinations/).

### Install `dlt`
Install dlt with destination dependencies, e.g. [BigQuery](https://dlthub.com/docs/dlt-ecosystem/destinations/bigquery):

```shell
pip install dlt[bigquery]
```
or
```shell
pip install -r requirements.txt
```

> If you use [Redshift](https://dlthub.com/docs/dlt-ecosystem/destinations/redshift) as a destination, then run `pip install dlt[redshift]`. 
> 
> If you use [Snowflake](https://dlthub.com/docs/dlt-ecosystem/destinations/snowflake) as a destination, then run `pip install dlt[snowflake]`. 
> 
> If you use [Athena](https://dlthub.com/docs/dlt-ecosystem/destinations/athena) as a destination, then run `pip install dlt[athena]`. 
> 
> If you use [Postgres](https://dlthub.com/docs/dlt-ecosystem/destinations/postgres) as a destination, then run `pip install dlt[postgres]`. 

More about installing dlt: [Installation](https://dlthub.com/docs/reference/installation).

### Configuration

In `.dlt` folder copy `example.secrets.toml` file to `secrets.toml`.  
It's where you store sensitive information securely, like access tokens, private keys, etc. 
Keep this file safe, do not commit it.

**Credentials for source data**

Add the BigQuery credentials for a database where you want to get your data from:
```toml
# BigQuery source configuration

[sources.bigquery_pipeline]
location = "US"
[sources.bigquery_pipeline.credentials_info]
project_id = "please set me up!"
private_key = "please set me up!"
client_email = "please set me up!"
token_uri = "please set me up!"
dataset_name = "please set me up!"
table_name = "events"
```

**Credentials for destination**

Add the destination credentials for a database where you want to upload your data:
```toml
# BigQuery destination configuration

[destination.bigquery]
location = "US"
[destination.bigquery.credentials]
project_id = "please set me up!"
private_key = "please set me up!"
client_email = "please set me up!"
```

Read more about configuration: [Secrets and Configs](https://dlthub.com/docs/general-usage/credentials/configuration). 

### Run the pipeline

Run the CLI script with defaults by executing the following command:
```bash
python bigquery_pipeline.py
```
Options:
- `--pipeline_name` (required): Name of the pipeline. Defaults to "ga4_event_export_pipeline".
- `--tables`: List of tables to process. Defaults to "events".
- `--month`: Month for data processing. Defaults to last month.
- `--year`: Year for data processing. Defaults to current year.
- `--destination`: Destination for the pipeline. Defaults to "bigquery".
- `--dataset`: Name of the dataset. Defaults to "ga4_event_export_dataset".
- `--dbt_run_params`: Additional run parameters for dbt. Defaults to "--fail-fast --full-refresh".
- `--dbt_additional_vars`: Additional variables for dbt. Defaults to None.
- `--write_disposition`: dlt mode. The "replace" mode completely replaces the existing data in the destination with the new data, 
  while the "append" mode adds the new data to the existing data in the destination. Defaults to "replace".

**Example** 
```shell
python bigquery_pipeline.py --table events --month 11 --year 2023 \
       --destination bigquery --dataset test_dataset --pipeline_name my_bigquery_pipeline \
       --dbt_run_params "--fail-fast --full-refresh" --dbt_additional_vars "ga4_data_paid_sources=['reddit.com']" 
```

Read more about a running pipeline: [Run a pipeline.](https://dlthub.com/docs/walkthroughs/run-a-pipeline) 


## Database schema diagrams
Here are the database diagrams for the GA4 data transformation stages, from raw to modeled:

1. The schema of data exported from GA4 to BigQuery:

   ![picture1](https://storage.googleapis.com/dlt-blog-images/GA4_export_to_BQ.svg)

   Here's the link to the DB diagram: [link](https://dbdiagram.io/d/GA4_export_to_BQ-65e5c897cd45b569fb783939).

1. The schema of data exported from BigQuery export to data warehouse using `dlt` pipeline:

   ![picture2](https://storage.googleapis.com/dlt-blog-images/GA4_export_to_Bigquery.svg)

   Here's the link to the DB diagram: [link](https://dbdiagram.io/d/GA4_export_to_Bigquery-65e6899dcd45b569fb857716).

1. The schema of the data modelled using dbt transform.

   ![picture3](https://storage.googleapis.com/dlt-blog-images/GA4_modelled.svg)

   Here's the link to the DB diagram: [link](https://dbdiagram.io/d/GA4_modelled-65e5c12ccd45b569fb7781e0).


