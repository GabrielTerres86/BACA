DECLARE
  pr_sld_devedor     crawseg.vlseguro%TYPE;
  pr_flgprestamista  CHAR(1);
  pr_flgdps          CHAR(1);
  pr_dsmotcan        VARCHAR2(500);
  pr_cdcritic        crapcri.cdcritic%TYPE;
  pr_dscritic        crapcri.dscritic%TYPE;
BEGIN
  FOR rw_crawepr IN (SELECT w.cdcooper, w.nrdconta, w.nrctremp, a.cdagenci
                       FROM crapass a,
                            crawepr w
                      WHERE w.cdcooper IN (9,13)
                        AND w.dtmvtolt >= '25/04/2022'
                        AND a.cdcooper = w.cdcooper
                        AND a.nrdconta = w.nrdconta
                        AND EXISTS (SELECT 1
                                      FROM crawseg p
                                     WHERE p.cdcooper = w.cdcooper
                                       AND p.nrdconta = w.nrdconta
                                       AND p.nrctrato = w.nrctremp)) LOOP
                                       
    segu0003.pc_validar_prestamista(pr_cdcooper        => rw_crawepr.cdcooper,
                                    pr_nrdconta        => rw_crawepr.nrdconta,
                                    pr_nrctremp        => rw_crawepr.nrctremp,
                                    pr_cdagenci        => rw_crawepr.cdagenci,
                                    pr_nrdcaixa        => 0,
                                    pr_cdoperad        => 1,
                                    pr_nmdatela        => 'SEGURO',
                                    pr_idorigem        => 5,
                                    pr_valida_proposta => 'S',
                                    pr_sld_devedor     => pr_sld_devedor,
                                    pr_flgprestamista  => pr_flgprestamista,
                                    pr_flgdps          => pr_flgdps,
                                    pr_dsmotcan        => pr_dsmotcan,
                                    pr_cdcritic        => pr_cdcritic,
                                    pr_dscritic        => pr_dscritic);
                           
    IF pr_flgprestamista = 'N' THEN
      DELETE crawseg p
       WHERE p.cdcooper = rw_crawepr.cdcooper
         AND p.nrdconta = rw_crawepr.nrdconta
         AND p.nrctrato = rw_crawepr.nrctremp;
    END IF;
  END LOOP;
  COMMIT;
END;
/
