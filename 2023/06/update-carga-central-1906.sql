BEGIN

  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.cdstatus = 2
   WHERE c.IDCENTRAL_CARGA IN (8914);

  COMMIT;

END;
