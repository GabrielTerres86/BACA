DECLARE
  vr_dstexarq  crapndb.dstexarq%TYPE;
  CURSOR cr_crapndb IS
select b.rowid linha_ndb, a.nrdocmto, b.dstexarq
 from craplau a, crapndb b 
 where --a.cdhistor in (31,48,667,961,2147,2169,2263) 
       b.dstexarq like 'F  %'
   and a.dtmvtopg >= '04/12/2019' 
   and a.insitlau = 3 
   and a.cdcooper = b.cdcooper 
   and a.nrdconta = b.nrdconta 
   and a.cdhistor = b.cdhistor 
   and a.dtmvtopg = b.dtmvtolt;
BEGIN
  FOR creg IN cr_crapndb LOOP
    vr_dstexarq := 'F'||rpad(creg.nrdocmto,25,' ')||substr(creg.dstexarq,27,200);
/*    dbms_output.put_line('Antes ='||creg.dstexarq);
    dbms_output.put_line('Depois='||vr_dstexarq);*/
    update crapndb a
    set a.dstexarq = vr_dstexarq
    where rowid = creg.linha_ndb;
  END LOOP;
  commit;
END;
