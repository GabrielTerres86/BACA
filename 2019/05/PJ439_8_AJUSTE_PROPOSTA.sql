declare

begin

  delete from tbepr_cdc_empr_doc where cdcooper=1 and nrdconta in (3012522,6884679) and nrctremp in  (1544332,1548915);
  
  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1',
         flgdocdg = 1
   WHERE cdcooper=1 
     and nrdconta in (3012522,6884679)
     and nrctremp in (1544332,1548915);
   
COMMIT;

end;