-- Create/Recreate indexes 
create index CECRED.CRAPASS##CRAPASS9 on CECRED.CRAPASS (CDCOOPER, INPESSOA, DECODE(inpessoa,1,nrcpfcgc,SUBSTR(to_char(nrcpfcgc,'FM00000000000000'),1,8) ))
  nologging;