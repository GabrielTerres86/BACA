-- Drop indexes 
drop index CRAPSDA##CRAPSDA2;

-- Create/Recreate indexes 
drop index CRAPSDA##CRAPSDA1;
create unique index CRAPSDA##CRAPSDA1 on CRAPSDA (CDCOOPER, DTMVTOLT, NRDCONTA, PROGRESS_RECID)
  nologging  local;

-- Statistics
begin
  dbms_stats.gather_table_stats(ownname          => 'CECRED',
                                tabname          => 'CRAPSDA',
                                estimate_percent => 33);
end;