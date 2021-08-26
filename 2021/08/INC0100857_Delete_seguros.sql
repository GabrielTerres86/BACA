begin
    
  delete tbseg_prestamista--- select * from tbseg_prestamista
  where cdcooper = 6  and nrdconta
   in (   92622,233609,206229, 231070, 131440,  69574, 124125, 234303 , 234885, 234656, 235210 , 234834, 235130, 104736, 232491, 230987, 203874, 236560, 209651, 147222, 240524,162914 )
  and dtDEVEND > to_date('01/05/2021','DD/MM/YYYY') 
  ;
  delete crapseg --- select * from crapseg 
  where cdcooper = 6  and dtmvtolt >  to_date('01/05/2021','DD/MM/YYYY')  and nrdconta in (
     92622,233609,206229, 231070, 131440,  69574, 124125, 234303 , 234885, 234656, 235210 , 234834, 235130, 104736, 232491, 230987, 203874, 236560, 209651, 147222, 240524,162914 )
  ;
  delete crawseg   --- select * from crawseg  
  where cdcooper = 6  and nrdconta in (
     92622,233609,206229, 231070, 131440,  69574, 124125, 234303 , 234885, 234656, 235210 , 234834, 235130, 104736, 232491, 230987, 203874, 236560, 209651, 147222, 240524,162914 )
  and dtmvtolt >  to_date('01/05/2021','DD/MM/YYYY') 
  ;

  COMMIT;
   EXCEPTION 
     WHEN OTHERS THEN 
       ROLLBACK;
END;
/
