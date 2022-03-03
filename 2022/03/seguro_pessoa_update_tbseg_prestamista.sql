BEGIN
  UPDATE tbseg_prestamista p
    SET p.dtdevend = TO_DATE('03/03/2022','DD/MM/RRRR')
  WHERE p.cdcooper = 1
    AND p.nrdconta = 9058001
    AND p.nrctrseg = 948909;
 COMMIT;
END;
/
