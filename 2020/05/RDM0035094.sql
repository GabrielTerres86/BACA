-- Created on 20/05/2020 by F0032494 
declare 
  -- Local variables here
  i integer;
  vr_cdcritic        INTEGER:= 0;
  vr_dscritic        VARCHAR2(4000);  
  vr_dtmvtolt        DATE;
  
BEGIN
  
          -- retorna valor do lancamento ao valor pago efetivamente
          UPDATE craplem
             SET vllanmto =  46.38 
           WHERE progress_recid = 152202747;
           
           SELECT dtmvtolt
           INTO vr_dtmvtolt
           FROM crapdat
           WHERE cdcooper = 1;

           --lanca novo pagamento de parcela
           --Cria lancamento craplem e atualiza o seu lote */
           empr0001.pc_cria_lancamento_lem(pr_cdcooper => 1 --Codigo Cooperativa
                                          ,pr_dtmvtolt => vr_dtmvtolt --Data Emprestimo
                                          ,pr_cdagenci => 28 --Codigo Agencia
                                          ,pr_cdbccxlt => 100 --Codigo Caixa
                                          ,pr_cdoperad => 1 --Operador
                                          ,pr_cdpactra => 28 --Posto Atendimento - - agencia do coperado crapass
                                          ,pr_tplotmov => 5 --Tipo movimento
                                          ,pr_nrdolote => 600012 --Numero Lote
                                          ,pr_nrdconta => 2625806 --Numero da Conta
                                          ,pr_cdhistor => 1044 --Codigo Historico
                                          ,pr_nrctremp => 1784246 --Numero Contrato
                                          ,pr_vllanmto => 194.06 -- Valor do lançamento
                                          ,pr_dtpagemp => vr_dtmvtolt --Data Pagamento Emprestimo
                                          ,pr_txjurepr => 0.0315222 --Taxa Juros Emprestimo
                                          ,pr_vlpreemp => 240.44 --Valor Emprestimo
                                          ,pr_nrsequni => 1 --Numero Sequencia
                                          ,pr_nrparepr => 1 --Numero Parcelas Emprestimo
                                          ,pr_flgincre => TRUE --Indicador Credito
                                          ,pr_flgcredi => TRUE --Credito
                                          ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                          ,pr_cdorigem => 5
                                          ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                          ,pr_dscritic => vr_dscritic); --Descricao Erro
                                          
     COMMIT;                                     
                                          
     EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;                                     
  
end;