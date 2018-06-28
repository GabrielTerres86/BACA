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

   Alteracoes: 27/06/2018 - P450 - Criação de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Criação de procedure para efetuar lançamentos - pc_gera_lcm_cta_prj (Daniel/AMcom)  

..............................................................................*/

 FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                 , pr_nrdconta craplcm.nrdconta%TYPE)
  RETURN BOOLEAN;

 /* Rotina para inclusao de C.C. pra prejuizo */
 PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro);

  -- calcula juros remuneratorios de uma determinada conta em cooperativa
  FUNCTION fn_calcula_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2)
  RETURN NUMBER;   --> Critica

  -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  PROCEDURE pc_atualiza_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2);   --> Critica

    FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER  --> Código da Cooperativa
                           ,pr_nrdconta   IN NUMBER) --> Número da Conta
                            RETURN NUMBER;
  
    PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper    IN NUMBER             --> Código da Cooperativa
                                     ,pr_nrdconta IN NUMBER             --> Número da conta
                                     ,pr_nrctremp IN NUMBER             --> Contrato
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

    PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER             --> Número da conta
                                 ,pr_tpope     IN VARCHAR2           --> Tipo de Operação(E-Empréstimo T-Transferência S-Saque)
                                 ,pr_cdcoperad IN NUMBER             --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER             --> Valor do Lançamento
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);        --> Erros do processo

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

   Alteracoes: 27/06/2018 - P450 - Criação de procedure para consulta de saldos - pc_consulta_sld_cta_prj (Daniel/AMcom)
               27/06/2018 - P450 - Criação de procedure para efetuar lançamentos - pc_gera_lcm_cta_prj (Daniel/AMcom)  

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
  FUNCTION fn_calcula_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                      ,pr_nrdconta IN NUMBER          --> Conta
                                      ,pr_dscritic OUT VARCHAR2)    --> Critica
  RETURN NUMBER AS vr_vljuprat NUMBER;

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
          CLOSE cr_tbcc_prejuizo;
          vr_cdcritic := 55;
          RAISE vr_exc_erro;
        ELSE
          vr_pctaxpre := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,105,6)),0);
        END IF;

       vr_vljuprat := (((rw_tbcc_prejuizo.vlsdprej + rw_tbcc_prejuizo.vljuprej) / 100) * vr_pctaxpre);
     ELSE 
       vr_vljuprat := -1; -- nenhum registro de prejuizo encontrado
     END IF;
     
     CLOSE cr_tbcc_prejuizo;
     
     RETURN vr_vljuprat;
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
       pr_dscritic := 'Erro nao tratado na PREJ0003.fn_calcula_juros_preju_cc --> ' || SQLERRM;

  END fn_calcula_juros_preju_cc;
  
 -- atualiza juros remuneratorios de uma determinada conta em cooperativa
  PROCEDURE pc_atualiza_juros_preju_cc( pr_cdcooper IN NUMBER           --> Cooperativa
                                        ,pr_nrdconta IN NUMBER          --> Conta
                                        ,pr_dscritic OUT VARCHAR2) IS   --> Critica
    -- cursores
                   
    -- variaveis
    vr_vljuprat             NUMBER := 0; -- valor do juros prejuizo atualizado
    
    -- Variaveis de Erro
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_exc_erro             EXCEPTION;
    
  BEGIN
    BEGIN
      vr_vljuprat := PREJ0003.fn_calcula_juros_preju_cc(pr_cdcooper
                                                      , pr_nrdconta
                                                      , pr_dscritic);
                                                            
      UPDATE tbcc_prejuizo SET vljuprej = vr_vljuprat
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtliquidacao IS NULL;
    EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro de prejuizo. '||
                        SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
        RAISE vr_exc_erro;
    END;
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
       pr_dscritic := 'Erro nao tratado na PREJ0003.pc_atualiza_juros_remunera --> ' || SQLERRM;

  END pc_atualiza_juros_preju_cc;

  FUNCTION fn_sld_cta_prj(pr_cdcooper   IN NUMBER --> Código da Cooperativa
                         ,pr_nrdconta   IN NUMBER) --> Número da Conta
                          RETURN NUMBER IS
  BEGIN

    /* .............................................................................

    Programa: fn_sld_conta_prejuizo
    Sistema : Ayllos
    Autor   : Daniel Silva - AMcom
    Data    : Junho/2018                 Ultima atualizacao: 

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Retornar o saldo da contra transitória
    Alteracoes: 
    ..............................................................................*/

    DECLARE

      -- Busca Saldo
      CURSOR cr_sld IS
        SELECT (select nvl(SUM(decode(his.indebcre, 'D', tr.vllanmto*-1, tr.vllanmto)), 0)
                  from tbcc_prejuizo_lancamento tr
                     , craphis his
                 where tr.cdcooper = pr_cdcooper
                   and tr.nrdconta = pr_nrdconta
                   and tr.dtmvtolt = (select dtmvtolt from crapdat where cdcooper = tr.cdcooper)
                   and tr.cdhistor = his.cdhistor   
                   and tr.cdcooper = his.cdcooper)
                /*+
               (select nvl(SUM(\*sld.vlblqprj*\sld.vlblqjud),0) vlsaldo
                  from crapsld sld
                 where sld.cdcooper = &pr_cdcooper
                   and sld.nrdconta = &pr_nrdconta
                   and sld.vlblqjud > 0) VLSALDO*/
           FROM DUAL;
      vr_sld NUMBER := 0;
    BEGIN
      -- Busca da quantidade
      OPEN cr_sld;
      FETCH cr_sld
       INTO vr_sld;
      CLOSE cr_sld;
      -- Retornar quantidade encontrada
      RETURN vr_sld;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_sld_cta_prj;  

  PROCEDURE pc_consulta_sld_cta_prj(pr_cdcooper    IN NUMBER             --> Código da Cooperativa
                                   ,pr_nrdconta IN NUMBER             --> Número da conta
                                   ,pr_nrctremp IN NUMBER             --> Contrato
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS

    /* .............................................................................

        Programa: pc_consulta_sld_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Daniel/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar saldo de conta em Prejuízo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'saldo',
                             pr_tag_cont => fn_sld_cta_prj(vr_cdcooper
                                                          ,pr_nrdconta),
                             pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    END pc_consulta_sld_cta_prj;

    PROCEDURE pc_gera_lcm_cta_prj(pr_cdcooper  IN NUMBER             --> Código da Cooperativa
                                 ,pr_nrdconta  IN NUMBER             --> Número da conta
                                 ,pr_tpope     IN VARCHAR2           --> Tipo de Operação(E-Empréstimo T-Transferência S-Saque)
                                 ,pr_cdcoperad IN NUMBER             --> Código do Operador
                                 ,pr_vlrlanc   IN NUMBER             --> Valor do Lançamento
                                 ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS      --> Erros do processo    

/* .............................................................................

        Programa: pc_gera_lcm_cta_prj
        Sistema : CECRED
        Sigla   : PREJ
        Autor   : Daniel/AMcom
        Data    : Junho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para efetuar lançamento em conta Prejuízo
        Observacao: -----
        Alteracoes:
      ..............................................................................*/

      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;

      -- Outras
      vr_vlrlanc      NUMBER     := 0;
      vr_nrseqdig     NUMBER     := 0;
      vr_nrdocmto     NUMBER(25) := 0;
      vr_nrdocmto_prj NUMBER(25) := 0;
      vr_cdhistor     NUMBER(5);
      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      --vr_nrdrowid ROWID;
      ---------->> CURSORES <<--------      
    -- Calendário da cooperativa selecionada
    CURSOR cr_dat(pr_cdcooper INTEGER) IS
    SELECT dat.dtmvtolt
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END) dtmvtoan
         , dat.dtultdma
         , (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
              THEN dat.dtmvtoan
              ELSE dat.dtultdma END)-5 dtdelreg
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    rw_dat cr_dat%ROWTYPE;           

    BEGIN

      -- Busca calendário para a cooperativa selecionada
      OPEN cr_dat(pr_cdcooper);
      FETCH cr_dat INTO rw_dat;
      -- Se não encontrar calendário
      IF cr_dat%NOTFOUND THEN
        CLOSE cr_dat;
        -- Montar mensagem de critica
        vr_cdcritic  := 794;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_dat;
      END IF;


      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- Consiste saldo com valor do parâmetro
      vr_vlrlanc := fn_sld_cta_prj(vr_cdcooper
                                  ,pr_nrdconta);
                                  
      IF vr_vlrlanc < pr_vlrlanc THEN
        pr_cdcritic := 0;
        pr_dscritic := 'A conta'||pr_nrdconta||' não possui saldo para esta operação!';        
        RAISE vr_exc_saida;
      END IF;
             
      -- Consite tipo de operação
      IF pr_tpope NOT IN('T','S') THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Informe uma operação válida: (T-Transferência S-Saque)';        
        RAISE vr_exc_saida;  
      ELSE
        -- Identifica HISTORICO
        IF pr_tpope = 'T' THEN
          vr_cdhistor := 99; -- *** FALTA DEFINIÇÃO ***
        ELSIF pr_tpope = 'S' THEN 
          vr_cdhistor := 98; -- *** FALTA DEFINIÇÃO ***
        END IF; 

        -- Buscar Documento TBCC_PREJUIZO_LANCAMENTO
        BEGIN
          SELECT nvl(MAX(t.nrdocmto)+1, 1)
            INTO vr_nrdocmto_prj
            FROM tbcc_prejuizo_lancamento t
           WHERE t.cdcooper = pr_cdcooper
             AND t.nrdconta = pr_nrdconta
             AND t.cdhistor = vr_cdhistor
             AND t.dtmvtolt = rw_dat.dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento TBCC_PREJUIZO_LANCAMENTO';        
          RAISE vr_exc_saida;                       
        END;

        -- Buscar Documento CRAPLCM
        BEGIN
          SELECT NVL(MAX(lcm.nrdocmto)+1, 1)
            INTO vr_nrdocmto
            FROM craplcm lcm
           WHERE lcm.cdcooper = pr_cdcooper
             AND lcm.nrdconta = pr_nrdconta
             AND lcm.dtmvtolt = rw_dat.dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro Buscar Documento CRAPLCM';        
          RAISE vr_exc_saida;                       
        END;                     
      END IF;
 
      -- Efetua lancamento de crédito na CRAPLCM(LANC0001)         
      -- Buscar sequence
      vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                 to_char(SYSDATE, 'DD/MM/RRRR')||';'||
                                '1;100;650010');
      
      LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper      
                                        ,pr_dtmvtolt => rw_dat.dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 650010
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_cdoperad => pr_cdcoperad
                                        ,pr_nrdctabb => pr_nrdconta
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_dtrefere => rw_dat.dtmvtolt
                                        ,pr_vllanmto => pr_vlrlanc
                                        ,pr_cdhistor => 2720
                                        -- OUTPUT --
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg => vr_incrineg
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
       
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        IF vr_incrineg = 0 THEN
          RAISE vr_exc_saida;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir lançamento (LANC0001)';
          RAISE vr_exc_saida;
        END IF;
      END IF;                                
                 
      -- Efetua lancamento de débito na contra transitória 
      BEGIN
        INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                            ,cdagenci
                                            ,nrdconta
                                            ,cdhistor
                                            ,nrdocmto
                                            ,vllanmto
                                            ,dthrtran
                                            ,cdoperad
                                            ,cdcooper
                                            ,dtliberacao)
                                      VALUES(rw_dat.dtmvtolt  -- dtmvtolt
                                            ,1                -- cdagenci
                                            ,100              -- nrdconta
                                            ,vr_cdhistor      -- cdhistor    
                                            ,vr_nrdocmto_prj  -- nrdocmto  
                                            ,pr_vlrlanc       -- vllanmto
                                            ,rw_dat.dtmvtolt  -- dthrtran
                                            ,pr_cdcoperad     -- cdoperad
                                            ,pr_cdcooper      -- cdcooper
                                            ,rw_dat.dtmvtolt); -- dtliberacao
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro insert TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
          RAISE vr_exc_saida;                                              
      END;
      --
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_gera_lcm_cta_prj;  

END PREJ0003;
/
