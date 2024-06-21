BEGIN
  UPDATE cecred.crapass a
     SET a.cdtipcta = 20
   WHERE a.cdcooper = 9
     AND a.nrdconta = 81394659;

  UPDATE cecred.crapass a
     SET a.cdtipcta = 23
   WHERE a.cdcooper = 9
     AND a.nrdconta = 81393148;

  UPDATE cecred.crapass a
     SET a.cdtipcta = 24
   WHERE a.cdcooper = 9
     AND a.nrdconta = 81485611;

  UPDATE cecred.crapass a
     SET a.cdtipcta = 24
   WHERE a.cdcooper = 9
     AND a.nrdconta = 81407793;

  UPDATE cecred.crapass a
     SET a.cdtipcta = 25
   WHERE a.cdcooper = 9
     AND a.nrdconta = 81483287;

  UPDATE cecred.crapass a
     SET a.cdtipcta = 26
   WHERE a.cdcooper = 9
     AND a.nrdconta = 81497458;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line(SQLERRM);

END;
