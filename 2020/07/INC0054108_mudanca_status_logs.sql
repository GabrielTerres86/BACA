/*
  SCRIPT BACA - INC0054108
  
  Boletos enviados para protesto com dscidade = UNIAO DOS PALMARES apresenta erro.
  
  Onde não volta log de críticas e o sistema não informa nada.
  
  Script responsável por fazer o log em cada um dos boletos, cancelar protesto, 
  arrumar os status dos boletos na crapcob e desbloquear boletos na CIP
  
  Daniel Lombardi (Mout'S) e Rafael Cechet (Ailos)

*/
DECLARE 

  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_des_erro VARCHAR2(100);
  vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
  
  --Variaveis de Excecao
  vr_exc_erro EXCEPTION;
  
  CURSOR cr_crapcob IS
      SELECT cob.rowid
            ,cob.nrdconta
            ,cob.insitcrt
            ,cob.nrcnvcob
            ,cob.nrdocmto
            ,cob.dtvencto
            ,cob.vldescto
            ,cob.vlabatim
            ,cob.flgdprot
        FROM crapcob cob
       WHERE cob.nrdconta = 7598394 
         AND cob.cdcooper = 1 
         AND cob.nrdocmto BETWEEN 1745 AND 1748;
   rw_crapcob cr_crapcob%ROWTYPE;
  
BEGIN
  
  FOR rw_crapcob IN cr_crapcob LOOP
    
      -- gera log
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                  , pr_cdoperad => '1'
                                  , pr_dtmvtolt => TRUNC(SYSDATE)
                                  , pr_dsmensag => 'A comarca de Uniao dos Palmares nao esta habilitada para protestar.'
                                  , pr_des_erro => vr_des_erro
                                  , pr_dscritic => vr_dscritic);
      IF vr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
                                 
      -- atualizar o boleto
      UPDATE crapcob SET crapcob.flgdprot = 0,
                         crapcob.qtdiaprt = 0,
                         crapcob.dsdinstr = ' ',
                         crapcob.insrvprt = 0,
                         crapcob.dtbloque = NULL, 
                         crapcob.dtlipgto = ADD_MONTHS(crapcob.dtlipgto,-60),
                         crapcob.insitcrt = 0,
                         crapcob.dtsitcrt = NULL
      WHERE crapcob.rowid = rw_crapcob.rowid;
   
      -- gerar movimento de cobrança - ocorrencia 26 com motivo '39'
      COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                                   ,pr_cdocorre => 26   -- Instrucao rejeitada
                                                   ,pr_cdmotivo => '39' -- Pedido de protesto nao permitido
                                                   ,pr_vltarifa => 0    -- Valor da Tarifa
                                                   ,pr_cdbcoctl => 85
                                                   ,pr_cdagectl => 101
                                                   ,pr_dtmvtolt => TRUNC(SYSDATE)
                                                   ,pr_cdoperad => '1'
                                                   ,pr_nrremass => 0
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
      IF vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                                                   
                                                   
                                               
      -- enviar registro de desbloqueio do boleto para a CIP
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid      --ROWID da Cobranca
                                       ,pr_tpoperad => 'A'                        --Tipo Operacao
                                       ,pr_tpdbaixa => ' '                        --Tipo de Baixa
                                       ,pr_dtvencto => rw_crapcob.dtvencto    --Data Vencimento
                                       ,pr_vldescto => rw_crapcob.vldescto    --Valor Desconto
                                       ,pr_vlabatim => rw_crapcob.vlabatim    --Valor Abatimento
                                       ,pr_flgdprot => rw_crapcob.flgdprot    --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda  --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda  --Tabela memoria retorno DDA
                                       ,pr_cdcritic        => vr_cdcritic           --Codigo Critica
                                       ,pr_dscritic        => vr_dscritic);         --Descricao Critica
      IF vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                                        
  END LOOP;
  
  COMMIT;
  EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
