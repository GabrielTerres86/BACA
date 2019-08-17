declare

begin

  delete from tbepr_cdc_empr_doc where cdcooper=1 and nrdconta in (2448289,6720773) and nrctremp in (1537605,1528252);
  
  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1',
         flgdocdg = 1
   WHERE cdcooper=1 
     and nrdconta in (2448289,6720773) 
     and nrctremp in (1537605,1528252);
   
COMMIT;

end;