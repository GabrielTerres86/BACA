DECLARE

CURSOR C01 IS
SELECT a.nrcpfcgc
     , 'L' tpcooperado
     , 1 cdstatus
     , DECODE(x.tppessoa, 1, 1, 2) tpcalculadora
  FROM crapass a
     , tbcadast_pessoa x
 WHERE a.cdcooper IN (3, 8, 12)
   AND a.dtdemiss is null
   AND x.nrcpfcgc = a.nrcpfcgc
   AND NOT EXISTS(SELECT 1
                    FROM tbcalris_tanque y
                   WHERE y.nrcpfcgc = a.nrcpfcgc
                     AND y.tpcalculadora IN (1, 2));

TYPE tb_cursor IS TABLE OF C01%ROWTYPE;
tb_c01  tb_cursor;

BEGIN

OPEN C01;
LOOP
  FETCH C01 BULK COLLECT INTO tb_c01;
  FORALL I IN tb_c01.FIRST..tb_c01.LAST LOOP
    INSERT INTO tbcalris_tanque (
        nrcpfcgc,
        tpcooperado,
        cdstatus,
        tpcalculadora
    ) (
        tb_c01.nrcpfcgc,
        tb_c01.tpcooperado,
        tb_c01.cdstatus,
        tb_c01.tpcalculadora
    );
  COMMIT;
END LOOP;
CLOSE C01;

END;