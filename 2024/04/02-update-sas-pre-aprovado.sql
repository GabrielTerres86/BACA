DECLARE

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

BEGIN
      
  FOR rw_crapcop IN cr_crapcop LOOP

    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    UPDATE tbrisco_operacoes t
       SET t.flintegrar_sas = 0
          ,t.dhalteracao    = SYSDATE
          ,t.dhtransmissao  = NULL
     WHERE ROWID IN(SELECT opr.rowid          row_id
                      FROM tbrisco_operacoes opr, crapass ass
                     WHERE opr.cdcooper = rw_crapcop.cdcooper
                       AND opr.tpctrato = 68
                       AND opr.flencerrado = 0
                       AND ass.cdcooper = opr.cdcooper
                       AND ass.nrdconta = opr.nrdconta
                       AND NOT EXISTS (SELECT 1
                                         FROM crapepr epr
                                        WHERE epr.cdcooper = opr.cdcooper
                                          AND epr.nrdconta = ass.nrdconta
                                          AND epr.inliquid = 0
                                          AND epr.cdfinemp = 68
                                          AND epr.dtmvtolt >= to_date('13/09/2019', 'DD/MM/yyyy')
                                      )
                       AND NOT EXISTS (SELECT 1
                                         FROM crapcpa              cpa
                                             ,tbepr_carga_pre_aprv pre
                                        WHERE pre.cdcooper           = cpa.cdcooper
                                          AND pre.idcarga            = cpa.iddcarga
                                          AND pre.cdcooper           = opr.cdcooper
                                          AND cpa.nrcpfcnpj_base     = opr.nrcpfcnpj_base
                                          AND pre.flgcarga_bloqueada = 0
                                          AND pre.indsituacao_carga  = 2
                                          AND nvl(pre.dtfinal_vigencia, rw_crapdat.dtmvtolt) >= rw_crapdat.dtmvtolt
                                      )
                    );
  
    UPDATE tbrisco_operacoes t
       SET t.flencerrado    = 1
          ,t.flintegrar_sas = 0
          ,t.dhalteracao    = SYSDATE
          ,t.dhtransmissao  = NULL
     WHERE ROWID IN(SELECT opr.rowid          row_id
                      FROM crapepr epr, tbrisco_operacoes opr
                     WHERE epr.cdcooper = opr.cdcooper
                       AND epr.nrdconta = opr.nrdconta
                       AND epr.nrctremp = opr.nrctremp
                       AND opr.cdcooper = rw_crapcop.cdcooper
                       AND opr.tpctrato = 90
                       AND epr.inliquid = 1
                       AND opr.flencerrado = 0
                       AND epr.cdfinemp = 68
                       AND epr.dtmvtolt >= to_date('13/09/2019', 'DD/MM/yyyy')
                       AND NOT EXISTS (SELECT 1
                                         FROM crapcpa              cpa
                                             ,tbepr_carga_pre_aprv pre
                                        WHERE pre.cdcooper           = cpa.cdcooper
                                          AND pre.idcarga            = cpa.iddcarga
                                          AND pre.cdcooper           = opr.cdcooper
                                          AND cpa.nrcpfcnpj_base     = opr.nrcpfcnpj_base
                                          AND pre.flgcarga_bloqueada = 0
                                          AND pre.indsituacao_carga  = 2
                                          AND nvl(pre.dtfinal_vigencia, rw_crapdat.dtmvtolt) >= rw_crapdat.dtmvtolt
                                      )
                    );
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
