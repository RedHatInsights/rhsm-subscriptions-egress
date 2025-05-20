-- postgres-init/init.sql
CREATE TABLE IF NOT EXISTS table1 (
    id SERIAL PRIMARY KEY,
    data TEXT
);

INSERT INTO table1 (data) VALUES
('data row 1 for table1'),
('data row 2 for table1');

CREATE TABLE IF NOT EXISTS table2 (
    name TEXT PRIMARY KEY,
    value INTEGER
);

INSERT INTO table2 (name, value) VALUES
('row_one', 100),
('row_two', 200);