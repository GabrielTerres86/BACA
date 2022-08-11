BEGIN
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'BA'  , t.grescola = 0 , t.cdnatopc = 9 WHERE t.cdcooper = 1 AND t.nrdconta = 14647974 AND t.nrcpfcgc = 10023265590 AND t.idseqttl = 1;
 UPDATE CECRED.Crapcrl r SET r.idorgexp = 999 WHERE r.Nrctamen = 14670607 AND r.cdcooper = 11 AND r.nrcpfcgc = 7130132906;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 3 , t.cdnatopc = 12 WHERE t.cdcooper = 1 AND t.nrdconta = 7559283 AND t.nrcpfcgc = 2161037978 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 5 , t.cdnatopc = 1 WHERE t.cdcooper = 1 AND t.nrdconta = 8568740 AND t.nrcpfcgc = 3277400948 AND t.idseqttl = 2;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 3 , t.cdnatopc = 12 WHERE t.cdcooper = 1 AND t.nrdconta = 8781125 AND t.nrcpfcgc = 2161037978 AND t.idseqttl = 2;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 5 , t.cdnatopc = 1 WHERE t.cdcooper = 11 AND t.nrdconta = 425249 AND t.nrcpfcgc = 3806246998 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 6 , t.cdufdttl =  'SC'  , t.grescola = 3 , t.cdnatopc = 1 WHERE t.cdcooper = 16 AND t.nrdconta = 984086 AND t.nrcpfcgc = 472971905 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 2 , t.cdnatopc = 1 WHERE t.cdcooper = 1 AND t.nrdconta = 12207110 AND t.nrcpfcgc = 1215502222 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 5 , t.cdnatopc = 1 WHERE t.cdcooper = 1 AND t.nrdconta = 8569690 AND t.nrcpfcgc = 3277400948 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 0 , t.idorgexp = 66 , t.cdufdttl =  'NI'  , t.grescola = 0 , t.cdnatopc = 1 WHERE t.cdcooper = 1 AND t.nrdconta = 14600986 AND t.nrcpfcgc = 9460867960 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 1 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 293 , t.cdnatopc = 1 WHERE t.cdcooper = 1 AND t.nrdconta = 14597845 AND t.nrcpfcgc = 10337226938 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 1 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 293 , t.cdnatopc = 1 WHERE t.cdcooper = 1 AND t.nrdconta = 13665227 AND t.nrcpfcgc = 7476537980 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 4 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 2 , t.cdnatopc = 81 WHERE t.cdcooper = 1 AND t.nrdconta = 14217929 AND t.nrcpfcgc = 6990342560 AND t.idseqttl = 1;
 UPDATE CECRED.crapttl t SET t.cdturnos = 0 , t.idorgexp = 66 , t.cdufdttl =  'SC'  , t.grescola = 2 , t.cdnatopc = 81 WHERE t.cdcooper = 11 AND t.nrdconta = 14418096 AND t.nrcpfcgc = 6696452907 AND t.idseqttl = 1;
COMMIT;
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;
