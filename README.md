# Jaffle Shop for SQL Server

This repository is a SQL Server port of the
[dbt Labs Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) sample project.
It is intended both as a working dbt example and as an end-to-end fixture for
SQL Server integrations such as Supaflow.

The project is pinned to:

- `dbt-core==1.12.0`
- `dbt-sqlserver==1.12.1`

## SQL Server compatibility

The port preserves the upstream models and sample data while adapting the SQL
that is not portable to T-SQL:

- monetary casts use a SQL Server implementation of `cents_to_dollars`;
- boolean projections and predicates use adapter-dispatched macros;
- the MetricFlow time spine is generated with SQL Server system rows;
- positional `group by` clauses use named columns;
- dbt unit-test fixtures use SQL Server-compatible bit values and timestamp
  precision;
- `dbt_utils.expression_is_true` returns a named failure column so SQL Server
  can materialize the test query as a view.

The profile's `target.schema` is the model schema. Seed data is written to
`<target.schema>_raw`, and the project sources read from that matching raw
schema. This keeps each run isolated and ensures a schema supplied by the user
or orchestration system is honored.

## Local setup

Create and activate a virtual environment, then install the pinned dbt runtime:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dbt.txt
```

Copy the example profile and edit its non-secret connection fields if needed:

```bash
cp profiles.yml.example profiles.yml
export DBT_SQLSERVER_PASSWORD='<password>'
```

`profiles.yml` is ignored by Git. Never put a real password in
`profiles.yml.example` or commit a populated profile.

Install packages and validate the connection:

```bash
./scripts/dbt-local deps
./scripts/dbt-local debug
```

The included profile targets `localhost:51433`, database `supaflow_dest`, and
schema `jaffle_shop_sqlserver`. The SQL Server login must be able to create and
replace objects in that database.

## Existing Docker SQL Server

For local development, `scripts/dbt-local` can read `MSSQL_SA_PASSWORD` from an
existing SQL Server container without printing or writing the value. It defaults
to `integration-sqlserver-destination-1` and can be pointed elsewhere:

```bash
DBT_SQLSERVER_CONTAINER=my-sqlserver ./scripts/dbt-local debug
```

Set `DBT_SQLSERVER_PASSWORD` directly when Docker is unavailable. Set `DBT_BIN`
to use a particular dbt executable and `DBT_PROFILES_DIR` to use a different
profile directory.

## Full verification

Run the same command sequence used by the Supaflow full dbt E2E checklist:

```bash
./scripts/test-all
```

It runs `deps`, `debug`, `parse`, `list`, `compile`, `seed`, `run`, `test`,
`snapshot`, `build`, `docs generate`, `source freshness`, and a dedicated
`show` preview. `seed`, `run`, and `build` use `--full-refresh`.

Two warnings are expected with the unchanged upstream fixture metadata:

- `snapshot` reports that there are no snapshots to run;
- source freshness warns for the historical `raw_orders` and `raw_stores`
  timestamps.

dbt 1.12 may also report that the cumulative metric cannot be represented in
its OSI export. That warning does not prevent parsing, execution, catalog
generation, or the model and unit-test suites from passing.

## Supaflow import

Import this repository as a dbt project, select a SQL Server datasource, and
provide a target namespace. Supaflow supplies the runtime profile; the ignored
local `profiles.yml` is not required. The project derives both its model and raw
seed schemas from the supplied target namespace.

## Attribution

The models and fixture data originate from the dbt Labs Jaffle Shop project.
The SQL Server adapter changes in this repository are maintained separately so
the upstream example and any project already imported into Supaflow remain
untouched during development.
