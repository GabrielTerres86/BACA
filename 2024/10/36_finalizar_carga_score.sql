DECLARE
  vr_dscritic VARCHAR2(4000);

  CURSOR cr_loop IS
    SELECT *
      FROM (SELECT c.*,
                   nvl((SELECT MAX(ass.inpessoa)
                      FROM cecred.crapass ass
                     WHERE ass.nrcpfcnpj_base = c.nrcpfcnpjbase),c.tppessoa) tppessoa_novo
              FROM cecred.tbcrd_score_exclusao c
             WHERE c.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
               AND c.cdmodelo = 3
               AND c.nrcpfcnpjbase NOT IN
                   (27396908, 50760050, 5405017, 27845990, 39477932))
     WHERE tppessoa_novo <> tppessoa;
  rw_loop cr_loop%ROWTYPE;

  CURSOR cr_loop2 IS
    SELECT *
      FROM (SELECT c.*,
                   nvl((SELECT MAX(ass.inpessoa)
                      FROM cecred.crapass ass
                     WHERE ass.nrcpfcnpj_base = c.nrcpfcnpjbase),c.tppessoa) tppessoa_novo
              FROM cecred.tbcrd_score c
             WHERE c.dtbase = to_date('01/09/2024', 'DD/MM/RRRR')
               AND c.cdmodelo = 3
               AND c.nrcpfcnpjbase NOT IN
                   (27396908, 50760050, 5405017, 27845990, 39477932))
     WHERE tppessoa_novo <> tppessoa;
  rw_loop2 cr_loop2%ROWTYPE;

BEGIN

  FOR rw_loop IN cr_loop LOOP
  
    INSERT INTO cecred.tbcrd_score
      SELECT y.cdcooper,
             y.cdmodelo,
             y.dtbase,
             rw_loop.tppessoa_novo,
             y.nrcpfcnpjbase,
             y.nrscore_alinhado,
             y.dsclasse_score,
             y.dsexclusao_principal,
             y.flvigente,
             y.cdscore,
             y.obdetalhamento,
             y.cdsegmento_modelo
        FROM cecred.tbcrd_score y
       WHERE y.cdcooper = rw_loop.cdcooper
         AND y.dtbase = rw_loop.dtbase
         AND y.nrcpfcnpjbase = rw_loop.nrcpfcnpjbase;
  
    UPDATE cecred.tbcrd_score_exclusao x
       SET x.tppessoa = rw_loop.tppessoa_novo
     WHERE x.cdcooper = rw_loop.cdcooper
       AND x.dtbase = rw_loop.dtbase
       AND x.nrcpfcnpjbase = rw_loop.nrcpfcnpjbase;
  
    DELETE cecred.tbcrd_score y
     WHERE y.cdcooper = rw_loop.cdcooper
       AND y.dtbase = rw_loop.dtbase
       AND y.nrcpfcnpjbase = rw_loop.nrcpfcnpjbase
       AND y.tppessoa = rw_loop.tppessoa;
  
    COMMIT;
  END LOOP;

  COMMIT;

  FOR rw_loop2 IN cr_loop2 LOOP
    UPDATE cecred.tbcrd_score x
       SET x.tppessoa = rw_loop2.tppessoa_novo
     WHERE x.cdcooper = rw_loop2.cdcooper
       AND x.dtbase = rw_loop2.dtbase
       AND x.nrcpfcnpjbase = rw_loop2.nrcpfcnpjbase;
    COMMIT;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
