BEGIN
  UPDATE crapfin fin
     SET fin.tpfinali = 4
   WHERE fin.cdfinemp IN(62,63);
   
   COMMIT;
END;
