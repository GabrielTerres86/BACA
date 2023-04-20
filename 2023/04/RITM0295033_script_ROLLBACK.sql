BEGIN
UPDATE CECRED.crapttl SET vlsalari = 2200 WHERE ROWID = 'AAJ4BTAAAAAKqvrAAQ'; 
    DELETE cecred.craplgi i  WHERE EXISTS  ( SELECT 1 FROM cecred.craplgm m    WHERE m.rowid = 'AAKGbyAAAAAAPjZACw'      AND i.cdcooper = m.cdcooper      AND i.nrdconta = m.nrdconta      AND i.idseqttl = m.idseqttl      AND i.dttransa = m.dttransa      AND i.hrtransa = m.hrtransa      AND i.nrsequen = m.nrsequen);
  DELETE cecred.craplgm WHERE rowid = 'AAKGbyAAAAAAPjZACw'; 
 DELETE cecred.crapalt  WHERE nrdconta = 90261011   and cdcooper = 1   and dtaltera = to_date( '24/03/2023', 'dd/mm/rrrr'); 
 
UPDATE CECRED.crapttl SET vlsalari = 1234 WHERE ROWID = 'AAJ4BTAAAAAK0d7AAd'; 
    DELETE cecred.craplgi i  WHERE EXISTS  ( SELECT 1 FROM cecred.craplgm m    WHERE m.rowid = 'AAKGbyAAAAAAPjZACx'      AND i.cdcooper = m.cdcooper      AND i.nrdconta = m.nrdconta      AND i.idseqttl = m.idseqttl      AND i.dttransa = m.dttransa      AND i.hrtransa = m.hrtransa      AND i.nrsequen = m.nrsequen);
  DELETE cecred.craplgm WHERE rowid = 'AAKGbyAAAAAAPjZACx'; 
 DELETE cecred.crapalt  WHERE nrdconta = 93857772   and cdcooper = 1   and dtaltera = to_date( '24/03/2023', 'dd/mm/rrrr'); 
 
UPDATE CECRED.crapttl SET vlsalari = 1 WHERE ROWID = 'AAJ4BTAAAAAK0J2AAN'; 
    DELETE cecred.craplgi i  WHERE EXISTS  ( SELECT 1 FROM cecred.craplgm m    WHERE m.rowid = 'AAKGbyAAAAAAPjZACy'      AND i.cdcooper = m.cdcooper      AND i.nrdconta = m.nrdconta      AND i.idseqttl = m.idseqttl      AND i.dttransa = m.dttransa      AND i.hrtransa = m.hrtransa      AND i.nrsequen = m.nrsequen);
  DELETE cecred.craplgm WHERE rowid = 'AAKGbyAAAAAAPjZACy'; 
 DELETE cecred.crapalt  WHERE nrdconta = 84871326   and cdcooper = 1   and dtaltera = to_date( '24/03/2023', 'dd/mm/rrrr'); 
 
UPDATE CECRED.crapttl SET vlsalari = 2870.61 WHERE ROWID = 'AAJ4BTAAAAAKx77AAH'; 
    DELETE cecred.craplgi i  WHERE EXISTS  ( SELECT 1 FROM cecred.craplgm m    WHERE m.rowid = 'AAKGbyAAAAAAPjZACz'      AND i.cdcooper = m.cdcooper      AND i.nrdconta = m.nrdconta      AND i.idseqttl = m.idseqttl      AND i.dttransa = m.dttransa      AND i.hrtransa = m.hrtransa      AND i.nrsequen = m.nrsequen);
  DELETE cecred.craplgm WHERE rowid = 'AAKGbyAAAAAAPjZACz'; 
 DELETE cecred.crapalt  WHERE nrdconta = 86373986   and cdcooper = 1   and dtaltera = to_date( '24/03/2023', 'dd/mm/rrrr'); 
 
UPDATE CECRED.crapttl SET vlsalari = 1873.67 WHERE ROWID = 'AAJ4BTAAAAAKpzrAAQ'; 
    DELETE cecred.craplgi i  WHERE EXISTS  ( SELECT 1 FROM cecred.craplgm m    WHERE m.rowid = 'AAKGbyAAAAAAPjZAC0'      AND i.cdcooper = m.cdcooper      AND i.nrdconta = m.nrdconta      AND i.idseqttl = m.idseqttl      AND i.dttransa = m.dttransa      AND i.hrtransa = m.hrtransa      AND i.nrsequen = m.nrsequen);
  DELETE cecred.craplgm WHERE rowid = 'AAKGbyAAAAAAPjZAC0'; 
 DELETE cecred.crapalt  WHERE nrdconta = 90445260   and cdcooper = 1   and dtaltera = to_date( '24/03/2023', 'dd/mm/rrrr'); 
 
COMMIT;
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;
