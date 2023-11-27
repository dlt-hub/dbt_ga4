# Google Analytics dbt package

## Installation

dbt version required: >=1.7.0
Include the following in your `packages.yml` file:
```yaml
packages:
  - package: dlthub/dbt_ga4
    version: 0.1.0
```
Run dbt deps to install the package.

```shell
dbt deps
```

For more information on using packages in your dbt project, 
check out the [dbt Documentation](https://docs.getdbt.com/docs/package-management).

## Models overview

This dbt package:

Contains a `dbt` dimensional models based on Google Analytics data from BigQuery source.
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

## How to use this package

We recommend that you add this package as a dependence to your own DBT package.

### Package customizations

We advise you to customize your package if you
- Want to specify your own paid sources with `paid_sources`. 
  For instance, if Google marks Reddit ads as organic, you can define them as paid.
- Want to unpack more event parameters with `extra_event_params`.

The columns name for `extra_event_params` and `paid_sources` may be configured in `dbt_project.yml` or by passing the variables in command line:

```shell
dbt run --profiles-dir . --vars '{schema_name: <schema_name>, paid_sources: ["reddit.com", "youtube.com"], extra_event_params: ["page_referrer"]}' --fail-fast
```

## Database support
We support 
- Redshift, 
- BigQuery
- Snowflake, 
- Athena, 
- Postgres.

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




