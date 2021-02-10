PL/SQL Developer Test script 3.0
238
-- Created on 13/01/2021 by T0032717 
DECLARE
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper craplem.cdcooper%TYPE) IS
    SELECT e.nrdconta, e.nrctremp, e.inprejuz, e.vlsdprej, e.vlttmupr, e.vlpgmupr, e.vlttjmpr, e.vlpgjmpr, e.vltiofpr, e.vlpiofpr, e.dtprejuz
      FROM crapepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.inprejuz = 1
       AND e.tpemprst = 1
       AND e.dtprejuz >= '01/01/2016'
       AND e.dtprejuz <= '31/12/2020'
       AND e.vlsdprej > 0;
  rw_principal cr_principal%ROWTYPE;

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  CURSOR cr_craplem5(pr_cdcooper craplem.cdcooper%TYPE
                    ,pr_nrdconta craplem.nrdconta%TYPE
                    ,pr_nrctremp craplem.nrctremp%TYPE
                    ,pr_dtmvtolt craplem.dtmvtolt%TYPE
                    ) IS
    SELECT nvl(SUM(lem.vllanmto),0) vllanmto
      FROM craplem lem
     WHERE to_char(lem.dtmvtolt, 'MMRRRR') = to_char(pr_dtmvtolt, 'MMRRRR')
       AND lem.cdhistor = 2409
       AND lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp;
  rw_craplem5 cr_craplem5%ROWTYPE;
  
  CURSOR cr_devedor(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_nrdconta craplem.nrdconta%TYPE
                   ,pr_nrctremp craplem.nrctremp%TYPE) IS
    SELECT cdcooper,
           nrdconta,
           SUM(decode(inprejuz,1,vlsdprej, --> Para contas em prejuizo, somar valor saldo em prejuizo
                                vlsdeved)) vlsdeved
      FROM crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND (inliquid = 0 OR (inliquid = 1 AND inprejuz = 1))
       AND (nvl(vlsdeved,0) <> 0 OR 
            nvl(vlsdprej,0) <> 0)
     GROUP BY cdcooper, nrdconta;
  rw_devedor cr_devedor%ROWTYPE;
  
  CURSOR cr_crapdir(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_nrdconta craplem.nrdconta%TYPE) IS
    SELECT vlsddvem 
      FROM crapdir
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta
       AND dtmvtolt = '31/12/2020';
  rw_crapdir cr_crapdir%ROWTYPE;
  
  --
  vr_tab_extrato_epr      extr0002.typ_tab_extrato_epr; 
  TYPE typ_tab_extrato_epr_novo IS TABLE OF extr0002.typ_reg_extrato_epr INDEX BY VARCHAR2(100);
  vr_tab_extrato_epr_novo typ_tab_extrato_epr_novo;
  pr_tab_extrato_epr_aux  extr0002.typ_tab_extrato_epr_aux;
  vr_des_reto VARCHAR2(1000);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_index_extrato PLS_INTEGER;
  vr_index_novo    VARCHAR2(100);
  vr_index_epr_aux PLS_INTEGER;
  vr_flgloop  BOOLEAN := FALSE;
  vr_vlsaldo1 NUMBER;
  vr_vlsaldo2 NUMBER;
  vr_exc_proximo EXCEPTION;
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
  vr_tab_calculado empr0001.typ_tab_calculado;
  vr_vljurdia NUMBER;
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_vlsdprej NUMBER;
  vr_flgativo INTEGER;
  vr_vlsddvem NUMBER;
  vr_vldezemb NUMBER;
BEGIN
  dbms_output.enable(NULL);

  FOR rw_crapcop IN cr_crapcop LOOP
    --Buscar Data do Sistema para a cooperativa 
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
    --Limpar tabela Emprestimo
      vr_tab_extrato_epr.DELETE; 
      pr_tab_extrato_epr_aux.DELETE;
      vr_vlsaldo1 := 0;
      --Obter Extrato do Emprestimo
      cecred.extr0002.pc_obtem_extrato_emprest (pr_cdcooper    => rw_crapcop.cdcooper            --Codigo Cooperativa
                                               ,pr_cdagenci    => 0                              --Codigo Agencia
                                               ,pr_nrdcaixa    => 0                              --Numero do Caixa
                                               ,pr_cdoperad    => 1                              --Codigo Operador
                                               ,pr_nmdatela    => 'ATENDA'                       --Nome da Tela
                                               ,pr_idorigem    => 5                              --Origem dos Dados
                                               ,pr_nrdconta    => rw_principal.nrdconta          --Numero da Conta do Associado
                                               ,pr_idseqttl    => 1                              --Sequencial do Titular
                                               ,pr_nrctremp    => rw_principal.nrctremp          --Numero Contrato Emprestimo           
                                               ,pr_dtiniper    => NULL                           --Inicio periodo Extrato
                                               ,pr_dtfimper    => to_date('05/01/2021')          --Final periodo Extrato
                                               ,pr_flgerlog    => FALSE                          --Imprimir log
                                               ,pr_extrato_epr => vr_tab_extrato_epr             --Tipo de tabela com extrato emprestimo
                                               ,pr_des_reto    => vr_des_reto                    --Retorno OK ou NOK
                                               ,pr_tab_erro    => vr_tab_erro);                  --Tabela de Erros
      
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN 
        RETURN;
      END IF; 
      
      --Percorrer todo o extrato emprestimo para carregar tabela auxiliar
      vr_index_novo:= vr_tab_extrato_epr.FIRST;
      WHILE vr_index_novo IS NOT NULL LOOP
        BEGIN
          --Primeira Ocorrencia
          IF vr_flgloop = FALSE THEN
            /* Saldo Inicial */
            vr_vlsaldo1:= vr_tab_extrato_epr(vr_index_novo).vllanmto; 
            vr_flgloop := TRUE;
            --Proximo Registro
            RAISE vr_exc_proximo;            
          END IF; 
          --Se for Credito
          IF vr_tab_extrato_epr(vr_index_novo).indebcre = 'C' THEN
            --Se possuir Saldo
            IF vr_tab_extrato_epr(vr_index_novo).flgsaldo THEN
              vr_vlsaldo1:= nvl(vr_vlsaldo1,0) - vr_tab_extrato_epr(vr_index_novo).vllanmto;
            END IF;    
          ELSIF vr_tab_extrato_epr(vr_index_novo).indebcre = 'D' THEN 
            --Valor Debito
            --Se possuir Saldo
            IF vr_tab_extrato_epr(vr_index_novo).flgsaldo THEN
              vr_vlsaldo1:= nvl(vr_vlsaldo1,0) + vr_tab_extrato_epr(vr_index_novo).vllanmto;
            END IF;    
          END IF;
          IF to_char(vr_tab_extrato_epr(vr_index_novo).dtmvtolt, 'DD/MM/YYYY') IN ('30/12/2020', '31/12/2020') THEN
            vr_vldezemb := vr_vlsaldo1;
          END IF;
        EXCEPTION
          WHEN vr_exc_proximo THEN
            NULL;
        END;       
        --Proximo Registro Extrato
        vr_index_novo:= vr_tab_extrato_epr.NEXT(vr_index_novo);
      END LOOP; 
      
      IF rw_principal.inprejuz = 1 AND extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => rw_crapcop.cdcooper
                                                                       ,pr_tpemprst => 1) = TRUE THEN
              
        rw_craplem5 := NULL;
        vr_vlsdprej := 0;
        OPEN cr_craplem5(pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => rw_principal.nrdconta
                        ,pr_nrctremp => rw_principal.nrctremp
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplem5 INTO rw_craplem5;
        CLOSE cr_craplem5;

        vr_vljurdia := 0;

        prej0001.pc_calcula_juros_diario(pr_cdcooper => rw_crapcop.cdcooper            -- IN
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- IN
                                        ,pr_dtmvtoan => rw_crapdat.dtmvtoan -- IN
                                        ,pr_nrdconta => rw_principal.nrdconta            -- IN
                                        ,pr_nrctremp => rw_principal.nrctremp    -- IN
                                        ,pr_vljurdia => vr_vljurdia            -- OUT
                                        ,pr_cdcritic => vr_cdcritic            -- OUT
                                        ,pr_dscritic => vr_dscritic            -- OUT
                                        );  
        --
        vr_vlsdprej := nvl(rw_principal.vlsdprej, 0) +
                      (nvl(rw_principal.vlttmupr, 0) - nvl(rw_principal.vlpgmupr, 0)) +
                      (nvl(rw_principal.vlttjmpr, 0) - nvl(rw_principal.vlpgjmpr, 0)) +
                      (nvl(rw_principal.vltiofpr, 0) - nvl(rw_principal.vlpiofpr, 0)); 
                            
        IF vr_vlsdprej > 0 THEN
          vr_vlsdprej := vr_vlsdprej + (nvl(vr_vljurdia,0) - nvl(rw_craplem5.vllanmto, 0));
        END IF;
        
      END IF;
     
      IF vr_vlsdprej < vr_vlsaldo1 THEN
        OPEN cr_crapdir(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_principal.nrdconta);
        FETCH cr_crapdir INTO rw_crapdir;
        CLOSE cr_crapdir;
        -- Total atual da crapdir
        vr_vlsddvem := rw_crapdir.vlsddvem;
        -- Tirar o contrato antigo
        OPEN cr_devedor(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_principal.nrdconta
                       ,pr_nrctremp => rw_principal.nrctremp);
        FETCH cr_devedor INTO rw_devedor;
        CLOSE cr_devedor;
        vr_vlsddvem := vr_vlsddvem - rw_devedor.vlsdeved;
        -- Atualizar devedor do contrato
        BEGIN 
          UPDATE crapepr
             SET vlsdprej = vr_vlsaldo1
           WHERE cdcooper = rw_crapcop.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND nrctremp = rw_principal.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro crapepr na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || vr_vlsdprej || '/' || vr_vlsaldo1 || ' - ' || SQLERRM);
        END;
        -- Somar o novo devedor na crapdir
        BEGIN 
          UPDATE crapdir
             SET vlsddvem = vr_vlsddvem + vr_vldezemb
           WHERE cdcooper = rw_crapcop.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND dtmvtolt = '31/12/2020';
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro crapdir na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || SQLERRM);
        END;
        dbms_output.put_line('Atualizado na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || vr_vlsdprej || '/' || vr_vlsaldo1);
      END IF;
    END LOOP;
    COMMIT;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, 'Erro: '||SQLERRM);
END;
0
0
