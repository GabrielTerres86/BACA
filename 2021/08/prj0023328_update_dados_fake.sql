DECLARE
  conta NUMBER(11) := 2879107;
  benefAntigo NUMBER(11) := 1096907019;
  benefNovo  NUMBER(11) := 202881776;

BEGIN

UPDATE crapcbi c 
   SET c.nrrecben = benefNovo
 WHERE c.nrdconta = conta
   AND c.nrrecben = benefAntigo;
   
UPDATE crapdbi d
   SET d.nrrecben = benefNovo
 WHERE d.nrrecben = benefAntigo;

UPDATE craplcm l
   SET l.cdpesqbb = REPLACE(l.cdpesqbb,to_char(benefAntigo),to_char(benefNovo))
 WHERE l.nrdconta = conta
   AND TRUNC(l.dtmvtolt) >= TRUNC(SYSDATE - 90);
   
UPDATE tbinss_dcb d
   SET d.nrrecben = benefNovo
 WHERE d.nrrecben = benefAntigo
   AND d.nrdconta = conta;
   
DELETE FROM tbinss_notif_benef_sicredi ntf
 WHERE ntf.nrdconta = conta
   AND ntf.nrrecben = benefAntigo;
 
COMMIT;
END;
