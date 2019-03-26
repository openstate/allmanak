SELECT 'CREATE TEMP TABLE tmp_' || c.relname || ' (' ||	STRING_AGG(
		a.attname || ' ' ||	pg_catalog.format_type(a.atttypid, a.atttypmod) ||
		CASE WHEN a.attnotnull = true THEN ' NOT NULL' ELSE '' END, ', ' ORDER BY a.attnum
	) || ');'
FROM pg_catalog.pg_class c
	LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	LEFT JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
WHERE n.nspname = 'almanak' AND relkind = 'r' AND a.attnum > 0 AND NOT a.attisdropped
GROUP BY c.relname;