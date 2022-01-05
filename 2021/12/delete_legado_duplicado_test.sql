DECLARE
  CURSOR c01 IS
    SELECT a.idcalris_tanque
          ,a.tpcalculadora
      FROM tbcalris_tanque a
     WHERE a.nrcpfcgc IN (83618538000191
                         ,6668197930
                         ,11267450908
                         ,61637538367
                         ,10147046939
                         ,62852183900
                         ,12155505965
                         ,3542344982
                         ,4691530916
                         ,3627096967
                         ,23700831000171
                         ,7707716965
                         ,93642938949
                         ,371325986
                         ,66966507920
                         ,29968474827
                         ,86028707953
                         ,73007382904
                         ,7784984928
                         ,9273713408
                         ,80184258928
                         ,30774209000173)
       AND a.tpcooperado = 'L';
  TYPE tb_cursor IS TABLE OF c01%ROWTYPE INDEX BY PLS_INTEGER;
  tb_c01 tb_cursor;
BEGIN
  OPEN c01;
  LOOP
    FETCH c01 BULK COLLECT
      INTO tb_c01;
    FORALL i IN tb_c01.first .. tb_c01.last
      DELETE FROM tbcalris_tanque
       WHERE idcalris_tanque = tb_c01(i).idcalris_tanque
         AND tpcalculadora = tb_c01(i).tpcalculadora;
    COMMIT;
    EXIT;
  END LOOP;
  CLOSE c01;
END;