BEGIN
  UPDATE gestaoderisco.tbrisco_central_carga c SET c.cdstatus = 7 WHERE c.dtrefere < '03/04/2023' AND c.cdstatus <> 7;
  COMMIT;
END;
