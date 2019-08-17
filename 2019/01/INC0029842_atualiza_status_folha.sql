UPDATE craplfp lfp
   SET lfp.idsitlct = 'T'
      ,lfp.dsobslct = NULL
 WHERE lfp.cdcooper = 1
   AND lfp.cdempres = 3875
   AND lfp.nrseqpag = 10
   AND lfp.nrseqlfp = 1;
   
COMMIT;
