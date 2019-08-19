DECLARE
  CURSOR c1 IS
    SELECT c.cdcooper
         , c.nrdconta
         , c.rowid
         , 20.35 vllanmto
      FROM craplcm c
     WHERE c.cdcooper = 1
       AND c.nrdconta = 1355368
       AND c.dtmvtolt = to_date('24/01/2019','DD/MM/RRRR')
       AND c.vllanmto = 0
    UNION
    SELECT c.cdcooper
         , c.nrdconta
         , c.rowid
         , DECODE(c.nrseqdig,10000523,1753.95,1976.37) vllanmto
      FROM craplcm c
     WHERE c.cdcooper = 10
       AND c.nrdconta = 73750
       AND c.dtmvtolt = to_date('24/01/2019','DD/MM/RRRR')
       AND c.vllanmto = 0;
BEGIN
  FOR r1 IN c1 LOOP
    BEGIN
      UPDATE craplcm lcm
         SET lcm.vllanmto = r1.vllanmto
       WHERE ROWID = r1.rowid;
      
      UPDATE crapsda sda
         SET sda.vlsddisp = sda.vlsddisp + r1.vllanmto
       WHERE sda.cdcooper = r1.cdcooper
         AND sda.nrdconta = r1.nrdconta
         AND sda.dtmvtolt = to_date('24/01/2019','DD/MM/RRRR');
      
      UPDATE crapsld sld
         SET sld.vlsddisp = sld.vlsddisp + r1.vllanmto
       WHERE sld.cdcooper = r1.cdcooper
         AND sld.nrdconta = r1.nrdconta;
      
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line(r1.rowid||' - '||SQLERRM);
        ROLLBACK;
    END;
  END LOOP;
END;