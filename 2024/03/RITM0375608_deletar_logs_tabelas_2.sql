BEGIN
  DELETE FROM craplgm lgm
   WHERE lgm.cdoperad = 't0035324';

  DELETE FROM craplgi lgi
   WHERE lgi.dttransa = TRUNC(SYSDATE);

  DELETE FROM cecred.tbgen_erro_sistema s
   WHERE TRUNC(s.dherro) = TRUNC(SYSDATE);
 COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
    ROLLBACK;
END;
