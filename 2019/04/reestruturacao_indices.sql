-- Drop indexes
drop index cecred.CRAPSDA##CRAPSDA2;
drop index cecred.CRAPSDA##CRAPSDA1;

-- Create/Recreate indexes

create unique index cecred.CRAPSDA##CRAPSDA1 on cecred.CRAPSDA (CDCOOPER, DTMVTOLT, NRDCONTA, PROGRESS_RECID) nologging local parallel 16;
ALTER INDEX cecred.CRAPSDA##CRAPSDA1 noparallel;

-- Statistics
begin
  execute DBMS_STATS.GATHER_TABLE_STATS (ownname => 'CECRED',
                                         TABNAME =>'CRAPSDA',
										 estimate_percent => 33,
										 method_opt => 'FOR ALL COLUMNS SIZE AUTO',
										 degree => 16 ,
										 granularity => 'ALL', 
										 cascade => TRUE, 
										 no_invalidate => FALSE);
end;
