-- ALTER TYPE ... ADD cannot run inside a transaction block before PostgreSQL 12
-- Luckely this can run multiple times without issues, generating some errors:
-- "X is not an existing enum label" for the rename and "enum label X already exists" for the add value.
ALTER TYPE almanak.ootype RENAME VALUE 'Hoge Colleges van Staat' TO 'Hoog College van Staat';
ALTER TYPE almanak.ootype ADD VALUE 'Openbaar lichaam voor beroep en bedrijf' AFTER 'Ministerie';
ALTER TYPE almanak.ootype ADD VALUE 'Organisatie met overheidsbemoeienis' AFTER 'Organisatie';
ALTER TYPE almanak.ootype ADD VALUE 'Organisatieonderdeel' AFTER 'Organisatie met overheidsbemoeienis';
ALTER TYPE almanak.ootype ADD VALUE 'Regionaal samenwerkingsorgaan' AFTER 'Rechterlijke macht';