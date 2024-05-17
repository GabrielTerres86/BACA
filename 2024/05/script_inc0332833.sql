BEGIN
    UPDATE cecred.craplrt a
       SET a.dsdlinha = 'CHEQUE ESPECIAL PF BAIXISSIMO'
     WHERE a.cdcooper = 13
       AND a.cddlinha = 50;

    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
