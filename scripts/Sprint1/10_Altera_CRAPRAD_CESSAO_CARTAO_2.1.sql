UPDATE CECRED.CRAPRAD
   SET DSSEQITE = 'Refinanciamento/Composicao de divida/Cessao Cart.'
 WHERE NRTOPICO = 2
   AND NRITETOP = 1 
   AND NRSEQITE = 4;

COMMIT;