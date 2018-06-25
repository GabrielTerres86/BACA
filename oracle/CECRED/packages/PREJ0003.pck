CREATE OR REPLACE PACKAGE CECRED.PREJ0003 AS

/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Move  C.C. para prejuízo

   Alteracoes:

..............................................................................*/

 FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE)
  RETURN BOOLEAN;

 /* Rotina para inclusao de C.C. pra prejuizo */
 PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro);

  -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  PROCEDURE pc_atualiza_juros_remunera( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2);   --> Critica

end PREJ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   :Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes:

..............................................................................*/

  -- Verifica se a conta está em prejuízo
  FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                  , pr_nrdconta craplcm.nrdconta%TYPE)
    RETURN BOOLEAN AS vr_conta_em_prejuizo BOOLEAN;

    CURSOR cr_conta IS
    SELECT ass.inprejuz
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

    vr_inprejuz  crapass.inprejuz%TYPE;
  BEGIN
    OPEN cr_conta;
    FETCH cr_conta INTO vr_inprejuz;
    CLOSE cr_conta;

    vr_conta_em_prejuizo := vr_inprejuz = 1;

    RETURN vr_conta_em_prejuizo;
  END fn_verifica_preju_conta;

  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro  ) is
    /* .............................................................................

    Programa: pc_transfere_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de prejuizo de conta corrente.


    Alteracoes:
    ..............................................................................*/
    --

    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
      SELECT t.dstextab
      FROM craptab t
      WHERE t.cdcooper = pr_cdcooper
      AND t.nmsistem = 'CRED'
      AND t.tptabela = 'USUARI'
      AND t.cdempres = 11
      AND t.cdacesso = 'RISCOBACEN'
      AND t.tpregist = 000;

     rw_tab cr_tab%ROWTYPE;

     --Numero de contrato de limite de credito ativo
     CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                        pr_nrdconta craplim.nrdconta%TYPE   ) IS
      SELECT  lim.nrctrlim
      FROM craplim lim
      WHERE lim.cdcooper = pr_cdcooper
      AND   lim.nrdconta = pr_nrdconta
      AND   lim.insitlim = 2;

      rw_craplim  cr_craplim%ROWTYPE;

      --Cartões magneticos ativos
      CURSOR  cr_crapcrm  (pr_cdcooper crapcrm.cdcooper%TYPE,
                           pr_nrdconta crapcrm.nrdconta%TYPE) IS
       SELECT crm.nrcartao
       FROM crapcrm crm
       WHERE crm.cdcooper = pr_cdcooper
       AND  crm.nrdconta  = pr_nrdconta
       AND  crm.cdsitcar  = 2;

     rw_crapcrm  cr_crapcrm%ROWTYPE;

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_dtmvtolt      crapris.dtrefere%TYPE,
                       pr_valor_arrasto crapris.vldivida%TYPE) IS

      SELECT  ris.nrdconta,
              pr_dtmvtolt  dtinc_prejuizo,
              ris.dtdrisco,
              pass.cdsitdct,
              ris.vldivida,
              ris.dtrefere
        FROM crapris ris,
             crapass pass
       WHERE ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.cdorigem  = 1    -- Conta Corrente
       AND   ris.innivris  = 9    -- Situação H
       AND  (pr_dtmvtolt - ris.dtdrisco) >= 180  -- dias_risco
       AND   ris.qtdiaatr >=180 -- dias_atraso
       AND   ris.nrdconta  not in (SELECT epr.nrdconta
                                   FROM   crapepr epr
                                   WHERE epr.cdcooper = ris.cdcooper
                                   AND   epr.nrdconta = ris.nrdconta
                                   AND   epr.inprejuz = 1
                                   AND   epr.cdlcremp = 100)
       AND  ris.nrdconta  not in   (SELECT cyc.nrdconta
                                    FROM   crapcyc cyc
                                    WHERE cyc.cdcooper = ris.cdcooper
                                    AND   cyc.nrdconta = ris.nrdconta
                                    AND   cyc.cdmotcin = 2)
       AND   ris.dtrefere =  pr_dtrefere
       AND   ris.vldivida > pr_valor_arrasto; -- Materialidade

     vr_cdcritic  NUMBER(3);
     vr_dscritic  VARCHAR2(1000);
     vr_des_erro  VARCHAR2(1000);

     rw_crapdat   btch0001.cr_crapdat%ROWTYPE;


     vr_valor_arrasto  crapris.vldivida%TYPE;
     vr_exc_saida exception;

     vr_tab_msg_confirm cada0003.typ_tab_msg_confirma;
     vr_dtrefere_aux  DATE;

     vr_tab_erro cecred.gene0001.typ_tab_erro;
     vr_des_reto VARCHAR2(100);

  BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
     -- CLOSE cr_tab;

      -- Se não encontrar
      IF cr_tab%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_tab;
        vr_valor_arrasto :=0;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_tab;
         -- Materialidade(Arrasto)
         vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), '.', ','));
      END IF;

      --Verificar data
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;


    --Transfere as contas em prejuizo para a tabela HIST...
    FOR rw_crapris IN cr_crapris(pr_cdcooper
                                ,vr_dtrefere_aux
                                ,rw_crapdat.dtmvtolt
                                ,vr_valor_arrasto) LOOP
      BEGIN

        INSERT INTO TBCC_PREJUIZO(cdcooper
                                  ,nrdconta
                                  ,dtinclusao
                                  ,cdsitdct_original
                                  ,vldivida_original)
         VALUES (pr_cdcooper,
                 rw_crapris.nrdconta,
                 rw_crapris.dtinc_prejuizo,
                 rw_crapris.cdsitdct,
                 rw_crapris.vldivida);



        UPDATE crapass pass
        SET pass.cdsitdct = 2, -- 2-Em Prejuizo
            pass.inprejuz = 1
        WHERE pass.cdcooper = pr_cdcooper
        AND   pass.nrdconta = rw_crapris.nrdconta;


         --Cancela Internet Banking
         CADA0003.pc_cancelar_senha_internet(pr_cdcooper =>pr_cdcooper                 --Cooperativa
                                             ,pr_cdagenci => 0                          --Agência
                                             ,pr_nrdcaixa => 0                          --Caixa
                                             ,pr_cdoperad => '1'                        --Operador
                                             ,pr_nmdatela => 'PC_CANCELAR_SENHA_INTERNET' --Nome da tela
                                             ,pr_idorigem => 1                          --Origem
                                             ,pr_nrdconta => rw_crapris.nrdconta        --Conta
                                             ,pr_idseqttl => 1                          --Sequência do titular
                                             ,pr_dtmvtolt => rw_crapris.dtinc_prejuizo  --Data de movimento
                                             ,pr_inconfir => 3                          --Controle de confirmação
                                             ,pr_flgerlog => 0                          --Gera log
                                             ,pr_tab_msg_confirma => vr_tab_msg_confirm
                                             ,pr_tab_erro => vr_tab_erro--Registro de erro
                                             ,pr_des_erro => vr_des_erro);            --Saida OK/NOK

            --Se Ocorreu erro
           IF vr_des_erro <> 'OK' THEN

              --Se possuir erro na tabela
              IF vr_tab_erro.COUNT > 0 THEN

                --Mensagem Erro
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;

              ELSE
                --Mensagem Erro
                vr_dscritic:= 'Erro na pc_cancelar_senha_internet.';
              END IF;

           END IF;

           --Verifica se existe contrato de limite ativo para conta
           OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapris.nrdconta );
           FETCH cr_craplim
           INTO rw_craplim;
           -- Se não encontrar
           IF cr_craplim%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craplim;
           ELSE
             --Cancelamento Limite de Credito

    
             LIMI0002.pc_cancela_limite_credito(pr_cdcooper   => pr_cdcooper                -- Cooperativa
                                               ,pr_cdagenci   => 0                          -- Agência
                                               ,pr_nrdcaixa   => 0                          -- Caixa
                                               ,pr_cdoperad   => '1'                        -- Operador
                                               ,pr_nrdconta   =>rw_crapris.nrdconta           -- Conta do associado
                                               ,pr_nrctrlim   => rw_craplim.nrctrlim          -- Contrato de Rating
                                               ,pr_inadimp    => 1                          -- 1-Inadimplência 0-Normal
                                               ,pr_cdcritic   => vr_cdcritic                -- Retorno OK / NOK
                                               ,pr_dscritic   => vr_dscritic);              -- Erros do processo                                               


            --Se Ocorreu erro
           IF  vr_cdcritic <>0  OR  vr_dscritic <> ' '  THEN

              --Se possuir erro na tabela
              IF vr_tab_erro.COUNT > 0 THEN

                --Mensagem Erro
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;

              ELSE
                --Mensagem Erro
                vr_dscritic:= 'Erro na pc_cancelar_senha_internet.';
              END IF;

             pr_cdcritic := vr_cdcritic;
             pr_dscritic := vr_dscritic;  

           END IF;                                               

           CLOSE cr_craplim;
         END IF;


         --Verifica se existe cartao ativo para a conta
           OPEN cr_crapcrm(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapris.nrdconta);
           FETCH cr_crapcrm
           INTO rw_crapcrm;
           -- Se não encontrar

           IF cr_crapcrm%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapcrm;
           ELSE
            -- Bloqueio cartão magnetico
                cada0004.pc_bloquear_cartao_magnetico( pr_cdcooper => pr_cdcooper, --> Codigo da cooperativa
                                                                  pr_cdagenci => 0,  --> Codigo de agencia
                                                                  pr_nrdcaixa => 0, --> Numero do caixa
                                                                  pr_cdoperad => '1',  --> Codigo do operador
                                                                  pr_nmdatela => 'ATENDA', --> Nome da tela
                                                                  pr_idorigem => 1,               --> Identificado de origem
                                                                  pr_nrdconta => rw_crapris.nrdconta,  --> Numero da conta
                                                                  pr_idseqttl => 1,  --> sequencial do titular
                                                                  pr_dtmvtolt => rw_crapris.dtinc_prejuizo,              --> Data do movimento
                                                                  pr_nrcartao => rw_crapcrm.nrcartao, --> Numero do cartão
                                                                  pr_flgerlog => 'S',                 --> identificador se deve gerar log S-Sim e N-Nao
                                                                    ------ OUT ------
                                                                  pr_cdcritic  => vr_cdcritic,
                                                                  pr_dscritic  => vr_dscritic,
                                                                  pr_des_reto  => vr_des_reto);--> OK ou NOK
              
                IF vr_des_reto <> 'OK' THEN
                   pr_cdcritic := vr_cdcritic;
                   pr_dscritic := vr_dscritic;  
                END IF;   

              CLOSE cr_crapcrm;
        END IF ;
      END;  
    END LOOP;


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK; 
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||SQLERRM;
        
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);



  END pc_transfere_prejuizo_cc;
--

 -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  PROCEDURE pc_atualiza_juros_remunera( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2) IS   --> Critica
    -- cursores
    CURSOR cr_tbcc_prejuizo (pr_cdcooper   NUMBER
                            ,pr_nrdconta   NUMBER) IS

    SELECT * FROM tbcc_prejuizo 
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND dtliquidacao IS NULL;

    rw_tbcc_prejuizo cr_tbcc_prejuizo%ROWTYPE;
                   
    -- variaveis
    vr_pctaxpre             NUMBER  :=0;
    vr_vljuprat             tbcc_prejuizo.vljuprej%TYPE; -- valor do juros prejuizo atualizado
    
    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;
    
    vr_dstextab             craptab.dstextab%TYPE;
                                      
   BEGIN
   
     -- procura um registro de prejuizo não liquidado
     OPEN cr_tbcc_prejuizo(pr_cdcooper, pr_nrdconta);
     FETCH cr_tbcc_prejuizo INTO rw_tbcc_prejuizo;
     
     -- se tivermos um registro ainda no liquidado...
     IF cr_tbcc_prejuizo%FOUND THEN
        -- captura valor de juros remuneratório da cooperativa
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'PAREMPREST'
                                                 ,pr_tpregist => 01);

        IF TRIM(vr_dstextab) IS NULL THEN
          vr_cdcritic := 55;
          RAISE vr_exc_erro;
        ELSE
          vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,6)),0);
          
          -- calcula valor atualizado do juros
          vr_vljuprat := ((rw_tbcc_prejuizo.vlsdprej / 100) * vr_pctaxpre);

          -- grava valor do juros atualizado em tbcc_prejuizo
          BEGIN
            UPDATE tbcc_prejuizo SET vljuprej = vr_vljuprat
                               WHERE cdcooper = pr_cdcooper
                                 AND nrdconta = pr_nrdconta;
          EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar registro de prejuizo. '||
                              SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
              RAISE vr_exc_erro;
          END;
        END IF;

     END IF;
     
     CLOSE cr_tbcc_prejuizo;
   EXCEPTION
     WHEN vr_exc_erro THEN
       ROLLBACK;
       -- Variavel de erro recebe erro ocorrido
       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;
     WHEN OTHERS THEN
       ROLLBACK;
       -- Descricao do erro
       pr_dscritic := 'Erro nao tratado na risc0003.pc_dias_atraso_liquidados --> ' || SQLERRM;

  END pc_atualiza_juros_remunera;
END PREJ0003;
/
