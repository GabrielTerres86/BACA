BEGIN
 
    UPDATE CECRED.tbseg_parametros_prst p 
       SET p.nrapolic = '000000077001006',
              p.pagsegu = 0.02088
     WHERE idseqpar = 3
       AND cdcooper = 3;
     
    UPDATE CECRED.tbseg_parametros_prst p 
       SET p.pagsegu = 0.030380
     WHERE idseqpar = 1002
       AND cdcooper = 3; 
     
    UPDATE CECRED.tbseg_param_prst_tax_cob t
       SET t.gbsegmin = 0.02850479,
           t.gbsegmax = 0.00187521 
     WHERE idseqpar = 1002;
     
    UPDATE CECRED.tbseg_param_prst_tax_cob t
       SET t.gbsegmin = 0.01956083,
           t.gbsegmax = 0.00131917 
     WHERE idseqpar = 3;
 
    COMMIT;
END;