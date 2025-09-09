ClickHouse vector search benchmark
====

1 Million Docs (Rows), 1K dimention each.

```sql
-- 既存のテーブルがあれば削除
DROP TABLE IF EXISTS test_vectors;

set allow_experimental_vector_similarity_index=1;

-- 1. テーブル定義: id (UInt64) と 1024 次元の vector (Array(Float32))
CREATE TABLE test_vectors
(
    id UInt64,
    vector Array(Float32)
--    ,    INDEX index_name vector TYPE vector_similarity('hnsw', 'cosineDistance')
)
ENGINE = MergeTree()
ORDER BY id;

INSERT INTO test_vectors
SELECT
    number AS id,
    arrayMap(x -> toFloat32(rand() % 10000) / 10000.0, range(1024)) AS vector
FROM numbers(10000000);
```

```
WITH
    -- 例として、ランダムな 1024 次元のクエリベクトルを生成
    arrayMap(x -> toFloat32(rand() % 10000) / 10000.0, range(1024)) AS query_vector
SELECT
    id,
    cosineDistance(vector, query_vector) AS cosine_distance
FROM test_vectors
ORDER BY cosineDistance(vector, query_vector)  ASC
LIMIT 10;
```