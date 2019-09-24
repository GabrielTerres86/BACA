PL/SQL Developer Test script 3.0
48
-- Created on 21/08/2019 by F0030250 
declare 
  -- Local variables here
  i integer;
  vr_des_erro VARCHAR2(2000);
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(2000);
  
  vr_tab_erro GENE0001.typ_tab_erro;
begin
  -- Test statements here
  
  -- Lanca em C/C e atualiza o lote
  empr0001.pc_cria_lancamento_cc(pr_cdcooper => 1 --> Cooperativa conectada
                                ,pr_dtmvtolt => to_date('22/08/2019', 'dd/mm/RRRR') --> Movimento atual
                                ,pr_cdagenci => 90 --> Código da agência
                                ,pr_cdbccxlt => 100         --> Número do caixa
                                ,pr_cdoperad => 1 --> Código do Operador
                                ,pr_cdpactra => 90 --> P.A. da transação
                                ,pr_nrdolote => 600015 --> Numero do Lote 600015 = Financiamento
                                ,pr_nrdconta => 9902015 --> Número da conta
                                ,pr_cdhistor => 108 --> Codigo historico 108 = PREST EMPREST
                                ,pr_vllanmto => 2043.53 --> Valor emprestimo
                                ,pr_nrparepr => 0 --> Número parcelas empréstimo
                                ,pr_nrctremp => 1573045 --> Número do contrato de empréstimo
                                ,pr_nrseqava => 0 --> Pagamento: Sequencia do avalista
                                ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros

  IF vr_des_erro = 'NOK' THEN
    --Se tem erro na tabela
    IF vr_tab_erro.count > 0 THEN
      vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
    ELSE
      vr_cdcritic:= 0;
      vr_dscritic:= 'Erro ao executar empr0001.pc_liquida_mesmo_dia.';
    END IF;
    --Levantar Excecao
    --RAISE vr_exc_saida;
    dbms_output.put_line('ERRO: ' || vr_cdcritic || ' - ' || vr_dscritic);
    
    ROLLBACK;
  ELSE
    dbms_output.put_line('Registro inserido com sucesso!');
    COMMIT;
  END IF;
end;
0
0
