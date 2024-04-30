BEGIN
UPDATE cecred.tbcadast_politico_exposto
SET NMEMPRESA = NULL,
    NRCNPJ_EMPRESA = NULL
WHERE idseqttl = 1
   AND cdcooper = 9
   AND nrdconta = 99865076;
commit;

UPDATE cecred.tbcadast_politico_exposto
SET NMEMPRESA = NULL,
    NRCNPJ_EMPRESA = NULL
WHERE idseqttl = 1
   AND cdcooper = 2
   AND nrdconta = 99295601;
commit;

UPDATE cecred.tbcadast_politico_exposto
SET NMEMPRESA = NULL,
    NRCNPJ_EMPRESA = NULL
WHERE idseqttl = 1
   AND cdcooper = 1
   AND nrdconta = 92629920;
commit;
END;