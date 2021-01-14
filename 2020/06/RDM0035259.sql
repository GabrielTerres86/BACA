
declare 
  -- Local variables here
  i integer;
  vr_cdcritic        INTEGER:= 0;
  vr_dscritic        VARCHAR2(4000);  
  vr_dtmvtolt        DATE;
  
BEGIN
   
           SELECT dtmvtolt
           INTO vr_dtmvtolt
           FROM crapdat
           WHERE cdcooper = 12;

           --lanca novo pagamento de parcela
           --Cria lancamento craplem e atualiza o seu lote */
           empr0001.pc_cria_lancamento_lem(pr_cdcooper => 12 --Codigo Cooperativa
                                                  ,pr_dtmvtolt => vr_dtmvtolt --Data Emprestimo
                                                  ,pr_cdagenci => 1 --Codigo Agencia
                                                  ,pr_cdbccxlt => 100 --Codigo Caixa
                                                  ,pr_cdoperad => 1 --Operador
                                                  ,pr_cdpactra => 1 --Posto Atendimento - - agencia do coperado crapass
                                                  ,pr_tplotmov => 4 --Tipo movimento
                                                  ,pr_nrdolote => 600005 --Numero Lote
                                                  ,pr_nrdconta => 101125 --Numero da Conta
                                                  ,pr_cdhistor => 1036 --Codigo Historico
                                                  ,pr_nrctremp => 20780 --Numero Contrato
                                                  ,pr_vllanmto => 2000 -- Valor do lançamento
                                                  ,pr_dtpagemp => vr_dtmvtolt --Data Pagamento Emprestimo
                                                  ,pr_txjurepr => 0.1044040 --Taxa Juros Emprestimo
                                                  ,pr_vlpreemp => 2000 --Valor Emprestimo
                                                  ,pr_nrsequni => 1 --Numero Sequencia
                                                  ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                                  ,pr_flgincre => FALSE --Indicador Credito
                                                  ,pr_flgcredi => FALSE --Credito
                                                  ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                                  ,pr_cdorigem => 7
                                                  ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                                  ,pr_dscritic => vr_dscritic); --Descricao Erro
                                          
     COMMIT;                                     
                                          
     EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;                                     
  
end;