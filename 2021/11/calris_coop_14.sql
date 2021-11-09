DECLARE

  CURSOR C01 IS
    SELECT a.nrcpfcgc,
           'L' tpcooperado,
           1 cdstatus,
           DECODE(x.tppessoa, 1, 1, 2) tpcalculadora
      FROM crapass a, tbcadast_pessoa x
     WHERE a.cdcooper IN (14)
       AND a.dtdemiss is null
       AND x.nrcpfcgc = a.nrcpfcgc
       AND NOT EXISTS (SELECT 1
                        FROM tbcalris_tanque y
                       WHERE y.nrcpfcgc = a.nrcpfcgc
                         AND y.tpcalculadora IN (1, 2))
     GROUP BY a.nrcpfcgc, DECODE(x.tppessoa, 1, 1, 2);

  TYPE tb_cursor IS TABLE OF C01%ROWTYPE;
  tb_c01 tb_cursor;

BEGIN

  OPEN C01;
  LOOP
    FETCH C01 BULK COLLECT
      INTO tb_c01;
    EXIT WHEN tb_c01.count = 0;
    FORALL I IN tb_c01.FIRST .. tb_c01.LAST
      INSERT INTO tbcalris_tanque
        (nrcpfcgc, tpcooperado, cdstatus, tpcalculadora)
      VALUES
        (tb_c01(i).nrcpfcgc,
         tb_c01(i).tpcooperado,
         tb_c01(i).cdstatus,
         tb_c01(i).tpcalculadora);
    COMMIT;
  END LOOP;
  CLOSE C01;

END;
