BEGIN

  INSERT INTO cecred.tbcalris_tanque
    (nrcpfcgc, tpcooperado, cdstatus, dsobservacao, tpcalculadora)
    SELECT cpa.nrcpfcgc,
           'N' tpcooperado,
           1 cdstatus,
           'Registro populado pelo script CORRIGE_INCIDENTE_707054',
           tcp.tppessoa tpcalculadora
      FROM cecred.crapass cpa, cecred.tbcadast_pessoa tcp
     WHERE cpa.dtdemiss IS NULL
       AND cpa.nrcpfcgc = tcp.nrcpfcgc
       AND tcp.nrcpfcgc IN (84846267920,
                            44125534934,
                            12344612777,
                            9680508919,
                            6534197910,
                            2840403129,
                            11675598940,
                            92532080825)
       AND NOT EXISTS (SELECT 1
              FROM cecred.tbcalris_tanque ttq
             WHERE ttq.nrcpfcgc = cpa.nrcpfcgc
               AND ttq.tpcalculadora = 1);

  COMMIT;

END;
