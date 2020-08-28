# Indexes
```sql
SELECT distinct ind.name AS IndexName,
          OBJECT_NAME(ind.OBJECT_ID) AS TableName,
          --,indexstats.index_type_desc AS IndexType,
          indexstats.avg_fragmentation_in_percent
      FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
      INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id
          AND ind.index_id = indexstats.index_id
      WHERE indexstats.avg_fragmentation_in_percent > 35
          AND indexstats.index_type_desc NOT LIKE 'Heap'         
      ORDER BY indexstats.avg_fragmentation_in_percent DESC

```

```sql
	  ALTER INDEX ALL
                     ON TableName
                     REBUILD WITH ( FILLFACTOR = 80, 
                        SORT_IN_TEMPDB = ON,
                        STATISTICS_NORECOMPUTE = ON)
```