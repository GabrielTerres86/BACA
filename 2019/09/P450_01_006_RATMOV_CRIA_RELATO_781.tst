PL/SQL Developer Test script 3.0
28
declare
  prox INTEGER;
  PROXPROGRESS_RECID INTEGER ;
begin
  SELECT  max(cdrelato) + 1, MAX(PROGRESS_RECID) +1  into prox, PROXPROGRESS_RECID  FROM CRAPREL where cdrelato <> 999  ;
  prox := 781;

  for reg in (
              
              SELECT cdcooper
                FROM crapcop 
               WHERE flgativo = 1         
                ) loop
    
    begin 
    insert into CRAPREL (CDRELATO, NRVIADEF, NRVIAMAX, NMRELATO                       , NRMODULO, NMDESTIN, NMFORMUL, INDAUDIT, CDCOOPER, PERIODIC, TPRELATO, INIMPREL, INGERPDF, DSDEMAIL, PROGRESS_RECID, CDFILREL, NRSEQPRI)
    values               (prox,    1,        1,       'RATMOV - Manutenção do Rating', 5,       'CREDITO',   ' ', '', reg.cdcooper, 'D', 1, 1, 1, ' ', PROXPROGRESS_RECID, null, null);
    dbms_output.put_line('Inseriu : coop: '||
                         reg.cdcooper || ' Tipo PROXPROGRESS ' ||PROXPROGRESS_RECID||'  REL '||prox      );
  
  PROXPROGRESS_RECID := PROXPROGRESS_RECID +1;
  EXCEPTION 
   WHEN dup_val_on_index THEN
        dbms_output.put_line(prox||' ERR '||SQLERRM);
    end;
  end loop ; 
  commit;
end;
0
0
