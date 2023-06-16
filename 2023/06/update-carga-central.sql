BEGIN

  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.cdstatus = 2
   WHERE c.IDCENTRAL_CARGA IN (8774, 8788);

  COMMIT;

END;
