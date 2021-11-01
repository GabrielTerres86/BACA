BEGIN
  UPDATE crapaca a 
     SET a.lstparam = 'pr_nrdolote,pr_dtmvtolt'
    WHERE a.nmdeacao = 'CONSULTAMOVCMP_P10';
    COMMIT;
    

END;
