DECLARE
  /* INC0121741 - Retirar o status de remessa de cartório do boleto para poder realizar a baixa */

  --Tabelas de Memoria de Remessa
  vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;

  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro   VARCHAR2(100);  
  vr_excerro EXCEPTION;

BEGIN

  FOR rw_crapcob IN (SELECT cob.*
                           ,ROWID
                       FROM crapcob cob
                      WHERE cob.incobran = 0
                        AND cob.insitpro = 3
                        AND cob.ininscip = 2
                        AND cob.cdcooper IN (9, 11)
                        AND cob.nrdconta IN (83399, 448184, 531472)
                        AND cob.nrdocmto IN (3085, 3, 526))
  LOOP
  
    BEGIN
      UPDATE crapcob
         SET flgdprot = 0
            ,qtdiaprt = 0
            ,insrvprt = 0
            ,dtbloque = NULL
            ,insitcrt = 0
            ,dtsitcrt = NULL
            ,dtlipgto = CASE
                          WHEN ADD_MONTHS(dtlipgto, -60) > trunc(SYSDATE) THEN
                           ADD_MONTHS(dtlipgto, -60)
                          ELSE
                           dtlipgto
                        END
       WHERE ROWID = rw_crapcob.rowid;
    END;
  
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => SYSDATE
                                 ,pr_dsmensag => 'Retirar boleto da situacao Remessa em Cartorio - Manual'
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_dscritic => vr_dscritic);
  
    DDDA0001.pc_procedimentos_dda_jd(pr_rowid_cob       => rw_crapcob.rowid --ROWID da Cobranca
                                    ,pr_tpoperad        => 'A' --Tipo Operacao
                                    ,pr_tpdbaixa        => ' ' --Tipo de Baixa
                                    ,pr_dtvencto        => rw_crapcob.dtvencto --Data Vencimento
                                    ,pr_vldescto        => rw_crapcob.vldescto --Valor Desconto
                                    ,pr_vlabatim        => rw_crapcob.vlabatim --Valor Abatimento
                                    ,pr_flgdprot        => rw_crapcob.flgdprot --Flag Protesto
                                    ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                    ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                    ,pr_cdcritic        => vr_cdcritic --Codigo Critica
                                    ,pr_dscritic        => vr_dscritic); --Descricao Critica
    --Se ocorreu erro
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_excerro;
    END IF;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN vr_excerro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_cdcritic || '-' || vr_dscritic);
  
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
