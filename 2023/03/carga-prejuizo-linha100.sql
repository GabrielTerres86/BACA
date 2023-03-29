DECLARE
  
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_idprglog tbgen_prglog.idprglog%TYPE;
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_crapris_9_100(pr_cdcooper IN crapris.cdcooper%TYPE,
                          pr_dtmvtolt IN crapepr.dtmvtolt%TYPE) IS

    SELECT ris.nrdconta
          ,ris.nrctremp
          ,ris.dtrefere
          ,NVL(ris.qtdiaatr, 0) qtdiaatr
      FROM crapris ris
          ,crapepr e
     WHERE ris.dtrefere = (SELECT MAX(dtrefere)
                             FROM crapris ris2
                            WHERE ris2.nrdconta = ris.nrdconta
                              AND ris2.cdcooper = ris.cdcooper
                              AND ris2.cdorigem = ris.cdorigem
                              AND ris2.innivris = ris.innivris
                              AND ris2.inddocto = ris.inddocto
                              AND ris2.nrctremp = ris.nrctremp
                              AND ris2.dtrefere < pr_dtmvtolt)
       AND e.cdcooper = ris.cdcooper
       AND e.nrdconta = ris.nrdconta
       AND e.nrctremp = ris.nrctremp
       AND ris.cdcooper = pr_cdcooper
       AND ((ris.nrctremp = ris.nrdconta) OR
           (ris.nrctremp = (SELECT t.nrctaant
                               FROM craptco t
                              WHERE t.cdcooper = ris.cdcooper
                                AND t.nrdconta = ris.nrdconta)))
       AND ris.cdorigem = 1
       AND ris.inddocto = 1
       AND ris.innivris = 9
       AND e.cdlcremp = 100
       AND e.tpemprst IN (0,1)
       AND e.inprejuz = 1;
  TYPE typ_crapris_9_100_bulk IS TABLE OF cr_crapris_9_100%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_crapris_9_100_bulk typ_crapris_9_100_bulk;
  
  TYPE typ_reg_tbrisco_atraso_prejuizo_cc IS
    RECORD(cdcooper gestaoderisco.tbrisco_atraso_prejuizo_conta_corrente.cdcooper%TYPE
          ,nrdconta gestaoderisco.tbrisco_atraso_prejuizo_conta_corrente.nrdconta%TYPE
          ,nrctremp gestaoderisco.tbrisco_atraso_prejuizo_conta_corrente.nrctremp%TYPE
          ,dtrefere gestaoderisco.tbrisco_atraso_prejuizo_conta_corrente.dtrefere%TYPE
          ,qtdiaatr gestaoderisco.tbrisco_atraso_prejuizo_conta_corrente.qtdiaatr%TYPE
          );
  TYPE typ_tab_tbrisco_atraso_prejuizo_cc IS TABLE OF typ_reg_tbrisco_atraso_prejuizo_cc INDEX BY PLS_INTEGER;
  vr_tab_tbrisco_atraso_prejuizo_cc typ_tab_tbrisco_atraso_prejuizo_cc;
  
  rw_crapdat datascooperativa;
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    rw_crapdat := datascooperativa(rw_crapcop.cdcooper);
    
    vr_tab_tbrisco_atraso_prejuizo_cc.delete;
    vr_tab_crapris_9_100_bulk.delete;

    OPEN cr_crapris_9_100(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvcentral);
    FETCH cr_crapris_9_100 BULK COLLECT INTO vr_tab_crapris_9_100_bulk;
    CLOSE cr_crapris_9_100;

    IF vr_tab_crapris_9_100_bulk.count > 0 THEN
      
      FOR idx IN vr_tab_crapris_9_100_bulk.first..vr_tab_crapris_9_100_bulk.last LOOP
        vr_tab_tbrisco_atraso_prejuizo_cc(idx).cdcooper := rw_crapcop.cdcooper;
        vr_tab_tbrisco_atraso_prejuizo_cc(idx).nrdconta := vr_tab_crapris_9_100_bulk(idx).nrdconta;
        vr_tab_tbrisco_atraso_prejuizo_cc(idx).nrctremp := vr_tab_crapris_9_100_bulk(idx).nrctremp;
        vr_tab_tbrisco_atraso_prejuizo_cc(idx).dtrefere := vr_tab_crapris_9_100_bulk(idx).dtrefere;
        vr_tab_tbrisco_atraso_prejuizo_cc(idx).qtdiaatr := vr_tab_crapris_9_100_bulk(idx).qtdiaatr;
      END LOOP;
      
      BEGIN
        FORALL idx IN INDICES OF vr_tab_tbrisco_atraso_prejuizo_cc SAVE EXCEPTIONS
          INSERT INTO GESTAODERISCO.tbrisco_atraso_prejuizo_conta_corrente
                    (cdcooper
                    ,nrdconta
                    ,nrctremp
                    ,dtrefere
                    ,qtdiaatr
                    )
              VALUES (vr_tab_tbrisco_atraso_prejuizo_cc(idx).cdcooper
                     ,vr_tab_tbrisco_atraso_prejuizo_cc(idx).nrdconta
                     ,vr_tab_tbrisco_atraso_prejuizo_cc(idx).nrctremp
                     ,vr_tab_tbrisco_atraso_prejuizo_cc(idx).dtrefere
                     ,vr_tab_tbrisco_atraso_prejuizo_cc(idx).qtdiaatr
                     );
      EXCEPTION
         WHEN others THEN

          FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                  ,PR_CDPROGRAMA => 'gravarCargaEmprestimo'
                                  ,pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_dsmensagem => 'vr_tab_tbrisco_atraso_prejuizo_cc -' ||
                                                    ' cdcooper: ' || vr_tab_tbrisco_atraso_prejuizo_cc(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                    ' nrdconta: ' || vr_tab_tbrisco_atraso_prejuizo_cc(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                    ' nrctremp: ' || vr_tab_tbrisco_atraso_prejuizo_cc(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                    ' qtdiaatr: ' || vr_tab_tbrisco_atraso_prejuizo_cc(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).qtdiaatr ||
                                                    ' Oracle error: ' || SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE)
                                 ,pr_idprglog => vr_idprglog);
          END LOOP;

           vr_dscritic := 'Erro ao inserir na tabela tbrisco_operacao_emprestimo. '||
                          '- ' || SQL%BULK_EXCEPTIONS(1).ERROR_INDEX || ' ' ||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_erro;
      END;
    END IF;
	COMMIT;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, 'Erro nao tratado na gravarCargaEmprestimo -> ' || SQLERRM);
END;