DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;

CREATE TABLE t1 (id Int) ENGINE = Memory;
CREATE TABLE t2 (id Int) ENGINE = Memory;

INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (2), (3);

SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 JOIN t2 ON 1 = 1;
SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 JOIN t2 ON 1;
SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 JOIN t2 ON 2 = 2 AND 3 = 3;
SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 INNER ANY JOIN t2 ON toNullable(1);
SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 INNER ANY JOIN t2 ON toLowCardinality(1);
SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 INNER ANY JOIN t2 ON toLowCardinality(toNullable(1));
SELECT 70 = 10 * sum(t1.id) + sum(t2.id) AND count() == 4 FROM t1 INNER ANY JOIN t2 ON toNullable(toLowCardinality(1));

SELECT * FROM t1 INNER ANY JOIN t2 ON toUInt16(1); -- { serverError 403 }
SELECT * FROM t1 INNER ANY JOIN t2 ON toInt8(1); -- { serverError 403 }
SELECT * FROM t1 INNER ANY JOIN t2 ON 256; -- { serverError 403 }
SELECT * FROM t1 INNER ANY JOIN t2 ON -1; -- { serverError 403 }
SELECT * FROM t1 INNER ANY JOIN t2 ON toString(1); -- { serverError 403 }

SELECT '- ON NULL -';

SELECT '- inner -';
SELECT * FROM t1 INNER ANY JOIN t2 ON NULL;
SELECT * FROM t1 INNER ANY JOIN t2 ON 0;
SELECT * FROM t1 INNER ANY JOIN t2 ON 1 = 2;
SELECT '- left -';
SELECT * FROM t1 LEFT JOIN t2 ON NULL ORDER BY t1.id, t2.id;
SELECT '- right -';
SELECT * FROM t1 RIGHT JOIN t2 ON NULL ORDER BY t1.id, t2.id;
SELECT '- full -';
SELECT * FROM t1 FULL JOIN t2 ON NULL ORDER BY t1.id, t2.id;

SELECT '- inner -';
SELECT * FROM t1 INNER ANY JOIN t2 ON NULL ORDER BY t1.id NULLS FIRST, t2.id SETTINGS join_use_nulls = 1;
SELECT '- left -';
SELECT * FROM t1 LEFT JOIN t2 ON NULL ORDER BY t1.id NULLS FIRST, t2.id SETTINGS join_use_nulls = 1;
SELECT '- right -';
SELECT * FROM t1 RIGHT JOIN t2 ON NULL ORDER BY t1.id NULLS FIRST, t2.id SETTINGS join_use_nulls = 1;
SELECT '- full -';
SELECT * FROM t1 FULL JOIN t2 ON NULL ORDER BY t1.id NULLS FIRST, t2.id SETTINGS join_use_nulls = 1;

-- in this cases we have AMBIGUOUS_COLUMN_NAME instead of INVALID_JOIN_ON_EXPRESSION
-- because there's some function in ON expression is not constant itself (result is constant)
SELECT * FROM t1 JOIN t2 ON 1 = 1 SETTINGS join_algorithm = 'full_sorting_merge'; -- { serverError AMBIGUOUS_COLUMN_NAME }
SELECT * FROM t1 JOIN t2 ON 1 = 1 SETTINGS join_algorithm = 'partial_merge'; -- { serverError AMBIGUOUS_COLUMN_NAME }
SELECT * FROM t1 JOIN t2 ON 1 = 1 SETTINGS join_algorithm = 'auto'; -- { serverError AMBIGUOUS_COLUMN_NAME }

SELECT * FROM t1 JOIN t2 ON NULL SETTINGS join_algorithm = 'full_sorting_merge'; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 JOIN t2 ON NULL SETTINGS join_algorithm = 'partial_merge'; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 LEFT JOIN t2 ON NULL SETTINGS join_algorithm = 'partial_merge'; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 RIGHT JOIN t2 ON NULL SETTINGS join_algorithm = 'auto'; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 FULL JOIN t2 ON NULL SETTINGS join_algorithm = 'partial_merge'; -- { serverError INVALID_JOIN_ON_EXPRESSION }

-- mixing of constant and non-constant expressions in ON is not allowed
SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND 1 == 1; -- { serverError AMBIGUOUS_COLUMN_NAME }
SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND 1 == 2; -- { serverError AMBIGUOUS_COLUMN_NAME }

SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND 1 != 1; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND NULL; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND 'aaa'; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 JOIN t2 ON 'aaa'; -- { serverError INVALID_JOIN_ON_EXPRESSION }

SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND 0; -- { serverError INVALID_JOIN_ON_EXPRESSION }
SELECT * FROM t1 JOIN t2 ON t1.id = t2.id AND 1; -- { serverError INVALID_JOIN_ON_EXPRESSION }

DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;

