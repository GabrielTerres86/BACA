declare

begin

  delete from tbepr_cdc_empr_doc where cdcooper=1 and nrdconta in (7083890,2134284) and nrctremp in (1544857,1544727);
  
  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1',
         flgdocdg = 1
   WHERE cdcooper=1 
     and nrdconta in (7083890,2134284)
     and nrctremp in (1544857,1544727);
   
COMMIT;

end;