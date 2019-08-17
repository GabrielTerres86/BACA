DECLARE
  CURSOR c1 IS 
    SELECT x.nrdconta
         , x.vllanmto
      FROM crapsda sda
         , (select 2500876 nrdconta, 6896.4 vllanmto from dual UNION
            select 7974400, 420 from dual UNION
            select 8432627, 1315 from dual UNION
            select 3502678, 2803 from dual UNION
            select 3770001, 396.67 from dual UNION
            select 2347032, 130 from dual UNION
            select 2571552, 300 from dual UNION
            select 1501976, 1000 from dual UNION
            select 6179819, 2452 from dual UNION
            select 6244009, 15000 from dual UNION
            select 8851972, 1991.25 from dual UNION
            select 9115145, 3463.91 from dual UNION
            select 1964712, 225 from dual UNION
            select 3030334, 2116 from dual UNION
            select 80004903, 1910.5 from dual UNION
            select 6057888, 2542.92 from dual UNION
            select 3885100, 1398.56 from dual UNION
            select 6321062, 100 from dual UNION
            select 6898491, 2483.87 from dual UNION
            select 7182775, 1413.62 from dual UNION
            select 8507201, 285.97 from dual UNION
            select 9037950, 500 from dual) x
     WHERE sda.cdcooper = 1
       AND sda.nrdconta = x.nrdconta
       AND sda.dtmvtolt = '13/12/2018'
       AND sda.vlsdblpr < 0;
BEGIN
  FOR r1 IN c1 LOOP
    BEGIN
      UPDATE crapsda c
         SET c.vlsddisp = c.vlsddisp - (r1.vllanmto * 4)
           , c.vlsdblpr = DECODE(GREATEST(c.dtmvtolt,to_date('05/01/2019','DD/MM/RRRR')),c.dtmvtolt,c.vlsdblpr,c.vlsdblpr + (r1.vllanmto * 4))
       WHERE c.cdcooper = 1
         AND c.nrdconta = r1.nrdconta
         AND c.dtmvtolt >= to_date('13/12/2018');
      
      UPDATE crapsld c
         SET c.vlsddisp = c.vlsddisp - (r1.vllanmto * 4)
       WHERE c.cdcooper = 1
         AND c.nrdconta = r1.nrdconta;

      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro '||r1.nrdconta||' - '||SQLERRM);
        ROLLBACK;
    END;
  END LOOP;
END;
