DECLARE
BEGIN
UPDATE tbgen_analise_fraude
SET cdstatus_analise = 0
, cdparecer_analise = 0
WHERE idanalise_fraude  in (152524828, 152524694);
  
COMMIT;
END;
/