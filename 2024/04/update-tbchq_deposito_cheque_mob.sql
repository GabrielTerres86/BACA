BEGIN
  UPDATE cecred.tbchq_deposito_cheque_mob mob
     SET mob.insituacao = 4
   WHERE mob.dtdeposito < trunc(SYSDATE)
     AND mob.insituacao = 1
     AND mob.cdcooper = 1
     AND mob.idseqdeposito IN (216984, 219382);
 
  COMMIT;
END;
