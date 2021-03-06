-- DROP FUNCTION IF EXISTS public.ensure_partition_timescale(text);
-- select * from public.ensure_partition_timescale('wal');

CREATE OR REPLACE FUNCTION admin.ensure_partition_timescale(
    metric text
)
RETURNS void AS
/*
  creates a top level metric table if not already existing.
  expects the "metrics_template" table to exist.
*/
$SQL$
DECLARE
    l_template_table text := 'admin.metrics_template';
    l_compression_policy text := $$
      ALTER TABLE public.%I SET (
        timescaledb.compress,
        timescaledb.compress_segmentby = 'dbname'
      );
    $$;
    l_chunk_time_interval interval;
    l_compress_chunk_interval interval;
BEGIN
    --RAISE NOTICE 'creating partition % ...', metric;
    IF NOT EXISTS (SELECT *
                       FROM _timescaledb_catalog.hypertable
                      WHERE table_name = metric
                        AND schema_name = 'public')
      THEN
        SELECT value::interval INTO l_chunk_time_interval FROM admin.config WHERE key = 'timescale_chunk_interval';
        IF NOT FOUND THEN
            l_chunk_time_interval := '2 days'; -- Timescale default is 7d
        END IF;

        SELECT value::interval INTO l_compress_chunk_interval FROM admin.config WHERE key = 'timescale_compress_interval';
        IF NOT FOUND THEN
            l_compress_chunk_interval := '1 day';
        END IF;

        EXECUTE format($$CREATE TABLE IF NOT EXISTS public.%I (LIKE %s INCLUDING INDEXES)$$, metric, l_template_table);
        EXECUTE format($$COMMENT ON TABLE public.%I IS 'pgwatch2-generated-metric-lvl'$$, metric);
        PERFORM create_hypertable(format('public.%I', metric), 'time', chunk_time_interval => l_chunk_time_interval);
        EXECUTE format(l_compression_policy, metric);
        PERFORM add_compress_chunks_policy(format('public.%I', metric), l_compress_chunk_interval);
    END IF;

END;
$SQL$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION admin.ensure_partition_timescale(text) TO pgwatch2;
