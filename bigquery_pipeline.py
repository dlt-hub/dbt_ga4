import argparse
from typing import Optional

import dlt
from dlt.common import pendulum
from google.cloud import bigquery
from google.oauth2 import service_account
from tqdm import tqdm

today = pendulum.now()
if today.month > 1:
    last_month = today.month - 1
    year = today.year
else:
    last_month = 12
    year = today.year - 1


@dlt.source
def bigquery_source(
    credentials_info=dlt.secrets.value, tables=(), month=last_month, year=year
):
    for table in tables:
        return dlt.resource(
            bigquery_table_resource,
            name=table,
        )(credentials_info, table, month, year)


def bigquery_table_resource(credentials_info, table=None, month=last_month, year=year):
    """
    Loads all the GA events data for the period of 1 month.
    If the month is not explicitly passed, then it loads the data for the previous month.
    """
    # credentials are read from .dlt/secrets.toml or ENVs
    credentials = service_account.Credentials.from_service_account_info(
        credentials_info
    )
    client = bigquery.Client(credentials=credentials)

    query_str = f"""
        select * from `{credentials_info['project_id']}.{credentials_info['dataset_name']}.{table}_*` 
        where _table_suffix between format_date('%Y%m%d', cast('{year}-{month}-1' as date)) 
                                and format_date('%Y%m%d', date_add(cast('{year}-{month}-1' as date), interval 1 month))
    """

    for row in tqdm(client.query(query_str), desc="Loading data..."):
        yield {key: value for key, value in row.items()}


def transform_data(pipeline, dbt_run_params, dbt_additional_vars: Optional[dict]):
    # make or restore venv for dbt, using latest dbt version
    # NOTE: if you have dbt installed in your current environment, just skip this line
    #       and the `venv` argument to dlt.dbt.package()
    venv = dlt.dbt.get_venv(pipeline)
    dbt = dlt.dbt.package(pipeline, "dbt_transform", venv=venv)
    additional_vars = {"ga4_data_schema_name": pipeline.dataset_name}
    if dbt_additional_vars:
        additional_vars.update(dbt_additional_vars)
    # run the models and collect any info
    # If running fails, the error will be raised with full stack trace
    models = dbt.run_all(run_params=dbt_run_params, additional_vars=additional_vars)

    return models


class ParseKwargs(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, dict())
        for value in values:
            key, value = value.split("=")
            getattr(namespace, self.dest)[key] = value


def parse_arguments():
    parser = argparse.ArgumentParser(description="BigQuery Data Pipeline CLI")
    parser.add_argument(
        "--pipeline_name",
        default="ga4_event_export_pipeline",
        help="Name of the pipeline",
    )
    parser.add_argument("--tables", nargs="+", default=["events"], help="List of tables to process")
    parser.add_argument("--month", type=int, default=last_month, help="Month for data processing")
    parser.add_argument("--year", type=int, default=today.year, help="Year for data processing")
    parser.add_argument("--destination", default="bigquery", help="Destination for pipeline")
    parser.add_argument("--dataset", default="ga4_event_export_dataset", help="Name of the schema")
    parser.add_argument(
        "--dbt_run_params",
        type=str,
        default="--fail-fast --full-refresh",
        help="Additional run parameters for dbt",
    )
    parser.add_argument(
        "--dbt_additional_vars",
        nargs="*",
        action=ParseKwargs,
        help="Additional variables for dbt",
    )
    parser.add_argument(
        "--write_disposition",
        default="replace",
        choices=["replace", "append"],
        help="The replace mode in dlt completely replaces the existing data in the destination with the new data, "
             "while the append mode adds the new data to the existing data in the destination.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()

    data_source = bigquery_source(tables=args.tables, month=args.month, year=args.year)

    pipeline = dlt.pipeline(
        pipeline_name=args.pipeline_name,
        destination=args.destination,
        dataset_name=args.dataset,
    )

    # run the pipeline with your parameters
    load_info = pipeline.run(data_source, write_disposition=args.write_disposition)
    # pretty print the information on data that was loaded
    print(load_info)

    models = transform_data(pipeline, args.dbt_run_params, args.dbt_additional_vars)

    for m in models:
        print(
            f"Model {m.model_name} materialized "
            + f"in {m.time} "
            + f"with status {m.status} "
            + f"and message {m.message}"
        )
