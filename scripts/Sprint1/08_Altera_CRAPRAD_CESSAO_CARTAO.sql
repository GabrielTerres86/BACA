UPDATE CECRED.CRAPRAD
   SET DSSEQITE = 'Refinanciamento/Composicao de divida/Cessao Cart.'
 WHERE NRTOPICO = 4
   AND NRITETOP = 1 
   AND NRSEQITE = 6;

COMMIT;