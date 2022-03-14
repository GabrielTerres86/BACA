BEGIN 
UPDATE crapttl
                       SET inpolexp = 1
                     WHERE idseqttl = 2
                       AND cdcooper = 1
                       AND nrdconta = 624349; 
UPDATE crapttl
                       SET inpolexp = 1
                     WHERE idseqttl = 1
                       AND cdcooper = 1
                       AND nrdconta = 3803538; 
DELETE FROM tbcadast_pessoa_polexp WHERE idpessoa = 189667;
UPDATE crapttl
                       SET inpolexp = 0
                     WHERE idseqttl = 1
                       AND cdcooper = 1
                       AND nrdconta = 21237; 
DELETE FROM tbcadast_politico_exposto WHERE cdcooper = 1 AND nrdconta = 21237 AND idseqttl = 1;
UPDATE crapttl
                       SET inpolexp = 1
                     WHERE idseqttl = 1
                       AND cdcooper = 1
                       AND nrdconta = 591718; 
UPDATE crapttl
                       SET inpolexp = 1
                     WHERE idseqttl = 1
                       AND cdcooper = 1
                       AND nrdconta = 624349; 
DELETE FROM tbcadast_pessoa_polexp WHERE idpessoa = 1773;
UPDATE crapttl
                       SET inpolexp = 0
                     WHERE idseqttl = 1
                       AND cdcooper = 1
                       AND nrdconta = 165514; 
DELETE FROM tbcadast_politico_exposto WHERE cdcooper = 1 AND nrdconta = 165514 AND idseqttl = 1;
UPDATE crapttl
                       SET inpolexp = 1
                     WHERE idseqttl = 1
                       AND cdcooper = 1
                       AND nrdconta = 830046; 
UPDATE crapttl
                       SET inpolexp = 0
                     WHERE idseqttl = 1
                       AND cdcooper = 2
                       AND nrdconta = 43; 
DELETE FROM tbcadast_politico_exposto WHERE cdcooper = 2 AND nrdconta = 43 AND idseqttl = 1;
DELETE FROM tbcadast_politico_exposto WHERE cdcooper = 1 AND nrdconta = 591718 AND idseqttl = 1;
DELETE FROM tbcadast_politico_exposto WHERE cdcooper = 1 AND nrdconta = 624349 AND idseqttl = 1;
COMMIT; 
END; 
