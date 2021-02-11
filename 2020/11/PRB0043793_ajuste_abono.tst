PL/SQL Developer Test script 3.0
427
-- Created on 28/10/2020 by F0032386 
declare 
  vr_vlsddisp NUMBER(25,2) := 0; -- Saldo disponivel
  vr_vltotpag NUMBER(25,2) := 0; -- Valor Total de Pagamento
  vr_vllancam NUMBER(25,2) := 0; -- Saldo disponivel
  vr_vllanacc NUMBER(25,2) := 0; -- Valor do abatimento em conta corrente
  vr_vllanact NUMBER(25,2) := 0; -- Valor do abatimento em contratos (emprésitmo, desc. de título)
  vr_vlpagmto NUMBER;
  vr_idvlrmin NUMBER(25,2) := 0; -- Indicador de valor Minimo
  vr_cdoperad crapope.cdoperad%TYPE := '1';
  vr_nmdatela craptel.nmdatela%TYPE := 'JOB';
  vr_nracordo NUMBER;
  vr_dtquitac DATE;
  -- Variaveis Locais
  vr_des_erro VARCHAR2(1000);
  vr_des_reto VARCHAR2(1000);
  -- Variaveis de Erros
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic crapcri.dscritic%TYPE := '';    

  
  vr_cdhistor craplcm.cdhistor%type;
  
  -- Cursor genérico de data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    TYPE typ_tab_crapdat IS
    TABLE OF btch0001.cr_crapdat%ROWTYPE
    INDEX BY BINARY_INTEGER;
      
  -- Tabela de Saldos
  vr_tab_saldos EXTR0001.typ_tab_saldos;
  vr_tab_crapdat typ_tab_crapdat;
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_index_saldo INTEGER;
      
  vr_vlrabono tbcc_prejuizo.vlrabono%TYPE;
  vr_exc_proximo EXCEPTION;
  
  -- Consulta contratos em acordo
  CURSOR cr_crapcyb(pr_nracordo tbrecup_acordo.nracordo%TYPE) IS
    WITH acordo_contrato AS (
         SELECT a.cdcooper
          , a.nracordo
          , a.nrdconta
          , c.nrctremp
          , c.cdorigem
          , c.indpagar
       FROM tbrecup_acordo a
          , tbrecup_acordo_contrato c
     WHERE a.nracordo = pr_nracordo
       AND c.nracordo = a.nracordo 
       AND c.indpagar = 'S'
    )
    SELECT acc.nracordo
          ,acc.cdcooper
          ,acc.nrdconta
          ,acc.cdorigem
          ,acc.nrctremp
      FROM acordo_contrato acc,
           crapcyb cyb
     WHERE cyb.cdcooper(+) = acc.cdcooper
       AND cyb.nrdconta(+) = acc.nrdconta
       AND cyb.nrctremp(+) = acc.nrctremp
       AND cyb.cdorigem(+) = acc.cdorigem    
       AND cyb.cdorigem = 1      
  ORDER BY cyb.cdorigem;
  rw_crapcyb cr_crapcyb%ROWTYPE;
  
  -- Consulta PA e limites de credito do cooperado
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
          ,ass.vllimcre
          ,ass.cdcooper
          ,ass.nrdconta
          ,ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
     
  -- Consulta cooperativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Consulta valor bloqueado pelo acordo
  CURSOR cr_nracordo(pr_nracordo tbrecup_acordo.nracordo%TYPE)IS
    SELECT aco.vlbloqueado
          ,aco.cdcooper
          ,aco.nrdconta
          ,aco.nracordo
          ,aco.cdsituacao
     FROM tbrecup_acordo aco
    WHERE aco.nracordo = pr_nracordo;
  rw_nracordo cr_nracordo%ROWTYPE;  
  
  
  CURSOR cr_acordos_ajuste IS
    SELECT s.vlsddisp
          ,s.vllimcre
          ,x.*
      FROM tbrecup_acordo          x
          ,tbrecup_acordo_contrato c
          ,crapsda                 s
     WHERE x.dtliquid > '20/10/2020'
       AND x.nracordo = c.nracordo
       AND c.cdorigem = 1
       AND x.cdcooper = s.cdcooper
       AND x.nrdconta = s.nrdconta
       AND s.dtmvtolt = x.dtliquid
       AND x.nracordo NOT IN (293207,292071,292654)
       AND s.vlsddisp < 0;
  
  
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);        
    FETCH btch0001.cr_crapdat INTO rw_crapdat;        
    vr_tab_crapdat(rw_crapcop.cdcooper) := rw_crapdat;
    CLOSE btch0001.cr_crapdat;

  END LOOP;  


  FOR rw_acordos_ajuste IN cr_acordos_ajuste LOOP
    
    vr_vllanacc := 0;
    vr_vllanact := 0;
    vr_dtquitac := TRUNC(SYSDATE);
    vr_nracordo := rw_acordos_ajuste.nracordo;

    -- Test statements here
    FOR rw_crapcyb IN cr_crapcyb(pr_nracordo => vr_nracordo) LOOP
                     
      OPEN cr_crapass(pr_cdcooper => rw_crapcyb.cdcooper
                     ,pr_nrdconta => rw_crapcyb.nrdconta);
      FETCH cr_crapass INTO rw_crapass;                         
      CLOSE cr_crapass;
        
      -- Estouro de Conta
      IF rw_crapcyb.cdorigem IN (1) THEN 
       --Limpar tabela saldos
       vr_tab_saldos.DELETE;
                          
       -- Saldo  disponivel
       vr_vlsddisp := 0;

       --Obter Saldo do Dia
       EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcyb.cdcooper
                                  ,pr_rw_crapdat => vr_tab_crapdat(rw_crapcyb.cdcooper)
                                  ,pr_cdagenci   => rw_crapass.cdagenci
                                  ,pr_nrdcaixa   => 100
                                  ,pr_cdoperad   => vr_cdoperad
                                  ,pr_nrdconta   => rw_crapcyb.nrdconta
                                  ,pr_vllimcre   => rw_crapass.vllimcre
                                  ,pr_dtrefere   => vr_tab_crapdat(rw_crapcyb.cdcooper).dtmvtolt
                                  ,pr_des_reto   => vr_des_erro
                                  ,pr_tab_sald   => vr_tab_saldos
                                  ,pr_tipo_busca => 'A'
                                  ,pr_tab_erro   => vr_tab_erro);

       IF vr_des_erro <> 'OK' THEN
         vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
         vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
         -- Log de erro de execucao
         vr_dscritic := 'Erro na extr0001.pc_obtem_saldo_dia - ' || 
                        ' Cooper: ' || rw_crapcyb.cdcooper ||
                        ' Conta: ' || rw_crapcyb.nrdconta ||
                        ' Acordo: ' || rw_crapcyb.nracordo ||
                        ' vllimcre: ' || rw_crapass.vllimcre || ' - ' || vr_dscritic;

         RAISE vr_exc_proximo;
                             
       END IF;
       -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
       GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

       --Buscar Indice
       vr_index_saldo := vr_tab_saldos.FIRST;
       IF vr_index_saldo IS NOT NULL THEN
         -- Saldo Disponivel na conta corrente
         vr_vlsddisp := NVL(vr_tab_saldos(vr_index_saldo).vlsddisp, 0);
       END IF;

       -- Armazenar valor para ser lancado no final como ajuste contabil
       -- Somente deverá conter o valor para zerar o estouro de conta.
       IF vr_vlsddisp < 0 THEN        

         -- RITM0081683
         IF NVL(rw_crapass.vllimcre,0) > 0 THEN
           vr_vlsddisp := vr_vlsddisp + NVL(rw_crapass.vllimcre,0);
         END IF;  

         RECP0001.pc_pagar_contrato_conta(pr_cdcooper => rw_crapcyb.cdcooper
                                         ,pr_nrdconta => rw_crapcyb.nrdconta
                                         ,pr_cdagenci => rw_crapass.cdagenci
                                         ,pr_crapdat  => vr_tab_crapdat(rw_crapcyb.cdcooper)
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nracordo => rw_crapcyb.nracordo
                                         ,pr_vlsddisp => vr_vlsddisp
                                         ,pr_vlparcel => ABS(vr_vlsddisp)
                                         ,pr_vltotpag => vr_vltotpag
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                             
         IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN

           IF NVL(vr_cdcritic,0) > 0 THEN
             vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           END IF;

           vr_dscritic := 'Erro na RECP0001.pc_pagar_contrato_conta - ' || 
                          ' Cooper: ' || rw_crapcyb.cdcooper ||
                          ' Conta: ' || rw_crapcyb.nrdconta ||
                          ' Acordo: ' || rw_crapcyb.nracordo ||
                          ' vr_vlsddisp: ' || vr_vlsddisp || ' - ' || vr_dscritic;

           RAISE vr_exc_proximo;

         END IF;
         -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
         GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

         vr_vllanacc := NVL(vr_vllanacc,0) + NVL(ABS(vr_vltotpag),0);  -- Valor para lancto de abatimento na C/C (Reginaldo/AMcom - P450)
                             
       END IF;
      END IF; 
    END LOOP;
    
    OPEN cr_nracordo(pr_nracordo => vr_nracordo);
    FETCH cr_nracordo INTO rw_nracordo;
    CLOSE cr_nracordo;

    OPEN cr_crapass(pr_cdcooper => rw_nracordo.cdcooper
                   ,pr_nrdconta => rw_nracordo.nrdconta);   
    FETCH cr_crapass INTO rw_crapass;               
    CLOSE cr_crapass;
    
    IF vr_vllanacc + vr_vllanact - rw_nracordo.vlbloqueado > 0 THEN
      IF rw_crapass.inprejuz = 0 THEN        
       vr_vlrabono := vr_vllanacc + vr_vllanact - rw_nracordo.vlbloqueado;
                                        
        -- Lança crédito do abono na conta corrente
        EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                     ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                     ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                     ,pr_cdbccxlt => 100                                          --> Número do caixa
                                     ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                     ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                     ,pr_nrdolote => 650001                                       --> Numero do Lote
                                     ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                     ,pr_cdhistor => 2181                                         --> Codigo historico
                                       ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                     ,pr_nrparepr => 0                                            --> Número do Acordo
                                     ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                     ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                     ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
       -- Se possui algum erro na tabela de erros
       IF vr_tab_erro.COUNT() > 0 THEN
         vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
         vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
       ELSE
         vr_cdcritic := 0;
         vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
       END IF;
       -- Log de erro de execucao
       vr_dscritic := 'Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                      ' Cooper: ' || rw_crapass.cdcooper ||
                      ' Conta: ' || rw_crapass.nrdconta ||
                      ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
       
       RAISE vr_exc_proximo;
                              
      END IF;
      
      -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
      ELSE
       IF vr_vllanacc > 0 THEN -- Abatimento em conta corrente
         IF vr_vllanacc > rw_nracordo.vlbloqueado THEN
           vr_vlrabono := vr_vllanacc - rw_nracordo.vlbloqueado;
                             
           -- Lança crédito do abono na conta corrente
           EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                         ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                         ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                         ,pr_cdbccxlt => 100                                          --> Número do caixa
                                         ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                         ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                         ,pr_nrdolote => 650001                                       --> Numero do Lote
                                         ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                         ,pr_cdhistor => 2919                                         --> Codigo historico
                                         ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                         ,pr_nrparepr => 0                                            --> Número do Acordo
                                         ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                         ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                         ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

           -- Se ocorreu erro
           IF vr_des_reto <> 'OK' THEN
             -- Se possui algum erro na tabela de erros
             IF vr_tab_erro.COUNT() > 0 THEN
               vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
             ELSE
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
             END IF;
             -- Log de erro de execucao
             vr_dscritic := 'Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                            ' Cooper: ' || rw_crapass.cdcooper ||
                            ' Conta: ' || rw_crapass.nrdconta ||
                            ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

             RAISE vr_exc_proximo;
           END IF;
                               
                              
           --01/10/2019 - PJ450.2 - Bug 25724 - Diferenças Contábeis - histórico 2919 - (Marcelo Elias Gonçalves/AMcom).                               
           -- Efetua o pagamento do prejuízo de conta corrente
           prej0003.pc_pagar_prejuizo_cc(pr_cdcooper => rw_crapass.cdcooper
                                       , pr_nrdconta => rw_crapass.nrdconta
                                       , pr_vlrpagto => vr_vlrabono 
                                       , pr_indabono => 1 -- se for abono/abatimento (0 - Nao, 1 - Sim)                                          
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic);                                                                                                                              
           IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             vr_dscritic := 'Erro ao Efetuar o Pagamento do Prejuízo de Conta Corrente (Abono). Cooperativa: '||rw_crapass.cdcooper||' | Conta: '||rw_crapass.nrdconta||'. Erro: '|| SubStr(SQLERRM,1,255);
              -- Log de erro de execucao
             vr_dscritic := 'Erro na prej0003.pc_pagar_prejuizo_cc - ' || 
                            ' Cooper: ' || rw_crapass.cdcooper ||
                            ' Conta: ' || rw_crapass.nrdconta ||
                            ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
       
             RAISE vr_exc_proximo;
           END IF; 
                               
                               
           -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
           GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');

      -- Atualiza valor do abono do saldo do prejuízo da conta corrente
      BEGIN
      -- Abate o valor do abono do saldo do prejuízo da conta corrente
      UPDATE tbcc_prejuizo prj
        SET vlsdprej = 0
          , vljur60_ctneg = 0
          , vljur60_lcred = 0
          , vljuprej = 0
          , vlrabono = vlrabono + vr_vlrabono
      WHERE cdcooper = rw_crapass.cdcooper
         AND nrdconta = rw_crapass.nrdconta
          AND dtliquidacao IS NULL;
      EXCEPTION
      WHEN OTHERS THEN
       vr_dscritic := 'Erro ao atualizar registro na tabela TBCC_PREJUIZO: ' || SQLERRM;
       -- Log de erro de execucao
       vr_dscritic := 'Cooper: ' || rw_crapass.cdcooper ||
                      ' Conta: ' || rw_crapass.nrdconta ||
                      ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;
             
       RAISE vr_exc_proximo;
      END;
      END IF;
                           
         IF vr_vllanacc >= rw_nracordo.vlbloqueado THEN
           rw_nracordo.vlbloqueado := 0;
         ELSE
           rw_nracordo.vlbloqueado := rw_nracordo.vlbloqueado - vr_vllanacc;
      END IF;
       END IF;
                           
       IF vr_vllanact > 0 THEN -- Abatimento em contratos (empréstimo, descto. de títulos, ...)
         vr_vlrabono := vr_vllanact - rw_nracordo.vlbloqueado;
                             
         -- Lança crédito do abono na conta corrente
         EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper                          --> Cooperativa conectada
                                       ,pr_dtmvtolt => vr_tab_crapdat(rw_crapass.cdcooper).dtmvtolt --> Movimento atual
                                       ,pr_cdagenci => rw_crapass.cdagenci                          --> Código da agência
                                       ,pr_cdbccxlt => 100                                          --> Número do caixa
                                       ,pr_cdoperad => vr_cdoperad                                  --> Código do Operador
                                       ,pr_cdpactra => rw_crapass.cdagenci                          --> P.A. da transação
                                       ,pr_nrdolote => 650001                                       --> Numero do Lote
                                       ,pr_nrdconta => rw_crapass.nrdconta                          --> Número da conta
                                       ,pr_cdhistor => 2181                                         --> Codigo historico
                                       ,pr_vllanmto => vr_vlrabono                                  --> Valor do credito
                                       ,pr_nrparepr => 0                                            --> Número do Acordo
                                       ,pr_nrctremp => rw_nracordo.nracordo                         --> Número do contrato de empréstimo
                                       ,pr_des_reto => vr_des_reto                                  --> Retorno OK / NOK
                                       ,pr_tab_erro => vr_tab_erro);                                --> Tabela com possíves erros

         -- Se ocorreu erro
         IF vr_des_reto <> 'OK' THEN
           -- Se possui algum erro na tabela de erros
           IF vr_tab_erro.COUNT() > 0 THEN
             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
           ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao criar o lancamento na conta corrente.';
           END IF;
           -- Log de erro de execucao
           vr_dscritic := 'Erro na EMPR0001.pc_cria_lancamento_cc - ' || 
                          ' Cooper: ' || rw_crapass.cdcooper ||
                          ' Conta: ' || rw_crapass.nrdconta ||
                          ' Acordo: ' || vr_nracordo || ' - ' || vr_dscritic;

           RAISE vr_exc_proximo;
         END IF;
         -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
         GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0003.pc_imp_arq_acordo_quitado');
                             
       END IF;
      END IF;
      END IF;
  END LOOP;
  
  COMMIT;           
end;
0
3
vr_vllanacc
vr_vlsddisp
rw_crapcyb.nrdconta
