BEGIN
UPDATE CRAPDOC SET DTMVTOLT = TO_DATE('28/06/2021', 'DD/MM/YYYY') where nrdconta = 8881529 and tpdocmto in (42,43);
COMMIT;
END;