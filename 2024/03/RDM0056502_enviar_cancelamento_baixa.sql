DECLARE
  vr_data_referencia DATE := TO_DATE('15/03/2024', 'DD/MM/YYYY');

  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);
  vr_exc_erro EXCEPTION;

  CURSOR cr_cancel(pr_dtreferencia_inicial DATE
                  ,pr_dtreferencia_final   DATE) IS
    SELECT cob.rowid idrowid_crapcob
          ,COALESCE(tol.cdmotivo_devolucao, 0) cdmotivo_devolucao
          ,tbo_b.nrbaixa_operac cdidentificador_baixa
      FROM CECRED.tbcobran_baixa_operac tbo_b
      LEFT JOIN CECRED.tbcobran_baixa_operac tbo_c
        ON tbo_c.nrdident = tbo_b.nrdident
       AND tbo_c.nrbaixa_operac = tbo_b.nrbaixa_operac
       AND tbo_c.tpoperac_jd = 'CO'
     INNER JOIN CECRED.crapcob cob
        ON cob.nrdident = tbo_b.nrdident
      LEFT JOIN COBRANCA.tbcobran_ocorrencia_liquidacao tol
        ON tol.nrboleto = cob.nrdocmto
       AND tol.nrconta_corrente = cob.nrdconta
       AND tol.nrconvenio = cob.nrcnvcob
       AND tol.nrconta_base = cob.nrdctabb
       AND tol.cdbanco_emissor = cob.cdbandoc
       AND tol.cdcooperativa = cob.cdcooper
       AND tol.dtmovimento_sistema = tbo_b.dtmvtolt
      LEFT JOIN PAGAMENTO.tb_baixa_pcr_remessa tbprem
        ON tbprem.nrtitulo_npc = tbo_b.nrdident
       AND tbprem.nrindenticacao_bo = tbo_b.nrbaixa_operac
       AND tbprem.tpoperjd = 'CX'
      LEFT JOIN PAGAMENTO.tb_baixa_pcr_retorno tbpret
        ON tbpret.idbaixa_pcr_remessa = tbprem.idbaixa_pcr_remessa
       AND tbpret.cdsituacao = 3
     WHERE tbo_b.dtmvtolt >= pr_dtreferencia_inicial
       AND tbo_b.dtmvtolt < pr_dtreferencia_final + 1
       AND tbo_b.dtmvtolt < trunc(SYSDATE)
       AND tbo_b.tpoperac_jd = 'BO'
       AND cob.incobran + 0 = 5
       AND tbo_c.nrdident IS NULL
       AND tbpret.idbaixa_pcr_retorno IS NULL
       AND tol.idocorrencia_liquidacao IN
           (HEXTORAW('E26425116D8F441BA9D6B135001D8C84')
           ,HEXTORAW('74870C03B48445BFB242B135001DB65C')
           ,HEXTORAW('97FB00E1DDA4470AA0C2B135001D9A28')
           ,HEXTORAW('6D0FC1A7E61D496FBF4AB135001E543C')
           ,HEXTORAW('79765C8887AA4103A2E1B135001E8CC9')
           ,HEXTORAW('9366839816D44B4D9069B135001DE876')
           ,HEXTORAW('53742BB85B26418197C3B135001E1BE3')
           ,HEXTORAW('7D5DA8CC7994432BAE5CB135001DE5DA')
           ,HEXTORAW('A97E2F01822A4E8FAF32B135001E6FD9')
           ,HEXTORAW('20C2EEC42D4E4A4EB187B135001DF591'));

BEGIN
  FOR rw_cancel IN cr_cancel(pr_dtreferencia_inicial => vr_data_referencia
                            ,pr_dtreferencia_final   => vr_data_referencia) LOOP
                            
    PAGAMENTO.prepararCancelamentoBaixaAvulsaAimaro(pr_rowid_cob => rw_cancel.idrowid_crapcob
                                                   ,pr_cdmotivo  => rw_cancel.cdmotivo_devolucao
                                                   ,pr_nrdbaixa  => rw_cancel.cdidentificador_baixa
                                                   ,pr_cdcritic  => vr_cdcritic
                                                   ,pr_dscritic  => vr_dscritic);
    IF COALESCE(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    BEGIN
      IF COALESCE(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := CECRED.gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
    
      ROLLBACK;
      raise_application_error(-20001, COALESCE(vr_cdcritic, 0) || '-' || vr_dscritic);
    END;
  WHEN OTHERS THEN
    BEGIN
      SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
      ROLLBACK;
      RAISE;
    END;
END;
