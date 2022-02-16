declare

begin

UPDATE tbgen_analise_fraude a
   SET a.cdstatus_analise = 2
 WHERE a.cdstatus_analise = 0
   AND a.cdparecer_analise = 0
   AND a.dtmvtolt >= TRUNC(SYSDATE);

COMMIT;

end;