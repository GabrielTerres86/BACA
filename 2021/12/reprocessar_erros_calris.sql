cursor c01 is
    SELECT a.idcalris_tanque,
           decode(a.cdstatus, 2, 1, 4, 3, 6, 5, 8, 7) cdstatus
      FROM tbcalris_tanque a
     WHERE a.cdstatus IN (2, 4, 6, 8);
  TYPE tb_cursor IS TABLE OF C01%ROWTYPE index by pls_integer;
  tb_c01    tb_cursor;
BEGIN
  OPEN C01;
  LOOP
    FETCH C01 BULK COLLECT
      INTO tb_c01;
    FORALL I IN tb_c01.FIRST .. tb_c01.LAST
      UPDATE tbcalris_tanque
         SET cdstatus = tb_c01(i).cdstatus
       WHERE idcalris_tanque = tb_c01(i).idcalris_tanque;
    COMMIT;
    EXIT;
  END LOOP;
  CLOSE C01;