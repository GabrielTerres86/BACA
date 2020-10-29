/*Cria Lançamento LEM*/
declare 
  vr_cdcritic        INTEGER:= 0;
  vr_dscritic        VARCHAR2(4000);  
  vr_dtmvtolt        DATE;
  
BEGIN
  
           
           vr_dtmvtolt := to_date('22/10/2020');

           --lanca novo pagamento de parcela
           --Cria lancamento craplem e atualiza o seu lote */
           empr0001.pc_cria_lancamento_lem(pr_cdcooper => 1 --Codigo Cooperativa
                                          ,pr_dtmvtolt => vr_dtmvtolt --Data Emprestimo
                                          ,pr_cdagenci => 34 --Codigo Agencia
                                          ,pr_cdbccxlt => 100 --Codigo Caixa
                                          ,pr_cdoperad => 1 --Operador
                                          ,pr_cdpactra => 34 --Posto Atendimento - - agencia do coperado crapass
                                          ,pr_tplotmov => 4 --Tipo movimento
                                          ,pr_nrdolote => 600005 --Numero Lote
                                          ,pr_nrdconta => 8854610 --Numero da Conta
                                          ,pr_cdhistor => 1036 --Codigo Historico
                                          ,pr_nrctremp => 3100038 --Numero Contrato
                                          ,pr_vllanmto => 1500 -- Valor do lançamento
                                          ,pr_dtpagemp => vr_dtmvtolt --Data Pagamento Emprestimo
                                          ,pr_txjurepr => 0.0545661 --Taxa Juros Emprestimo
                                          ,pr_vlpreemp => 0 --Valor Emprestimo
                                          ,pr_nrsequni => 0 --Numero Sequencia
                                          ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                          ,pr_flgincre => TRUE --Indicador Credito
                                          ,pr_flgcredi => TRUE --Credito
                                          ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                          ,pr_cdorigem => 3
                                          ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                          ,pr_dscritic => vr_dscritic); --Descricao Erro
                                          
     COMMIT;                                     
                                          
     EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;                                     
  
end;
/
