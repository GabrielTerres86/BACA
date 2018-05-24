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

    /* Rotina para inclusao de C.C. pra prejuizo */
    PROCEDURE    pc_transfere_prejuizo_cc(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Coop conectada
                                         ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                         ,pr_stprogra  OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol  OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic  OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                         ,pr_dscritic  OUT VARCHAR2 );

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

 ---------------- Cursores genéricos ----------------

     -- Busca dos dados da cooperativa
     CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     -- Variáveis para controle de restart
     vr_nrctares crapass.nrdconta%TYPE;--> Número da conta de restart
     vr_dsrestar VARCHAR2(4000);       --> String genérica com informações para restart
     vr_inrestar INTEGER;              --> Indicador de Restart


     vr_cdcritic  NUMBER(3);
     vr_dscritic  VARCHAR2(1000);

     rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2 ) is
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

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_valor_arrasto crapris.vldivida%TYPE) IS
      
      SELECT  ris.nrdconta,
              trunc(sysdate)  dtinc_prejuizo,
              ris.dtdrisco,
              pass.cdsitdct,
              ris.vldivida,
              ris.dtrefere,
             ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtdrisco) dias_risco, 
             ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtinictr) dias_atraso 
        FROM crapris ris,
             crapass pass
       WHERE ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.cdorigem  = 1    -- Conta Corrente
       AND   ris.innivris  = 9    -- Situação H  
       AND  ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtdrisco)> = 180  -- dias_risco
       AND  ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtinictr)> = 180  -- dias_ADP       
       AND   ris.nrdconta  not in (SELECT epr.nrdconta
                                   FROM   crapepr epr 
                                   WHERE epr.cdcooper = ris.cdcooper 
                                   AND   epr.nrdconta = ris.nrdconta 
                                   AND   epr.inprejuz = 1 
                                   AND   epr.cdlcremp = 100)

       AND   ris.dtrefere =pr_dtrefere 
       AND   ris.vldivida > pr_valor_arrasto; -- Materialidade 
       
    --Busca contratos de limite 
    CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                       pr_nrdconta craplim.nrdconta%TYPE   ) IS
    SELECT lim.tpctrlim
         , lim.nrctrlim
         , lim.nrdconta
    FROM   craplim lim
    WHERE  lim.tpctrlim  = 2 -- Ativo
    AND    lim.Insitlim  = 1
    AND    lim.cdcooper  = pr_cdcooper
    AND    lim.nrdconta  = pr_nrdconta;
    
    rw_craplim cr_craplim%rowtype;




     vr_valor_arrasto  crapris.vldivida%TYPE;
     -- Código do programa
     vr_cdprogra crapprg.cdprogra%TYPE;
     -- Erro para parar a cadeia
     vr_exc_saida exception;
     -- Erro sem parar a cadeia
     vr_exc_fimprg exception;

     vr_des_erro VARCHAR2(500);
     
     vr_dtrefere_aux DATE;

     vr_tab_msg_confirm CADA0003.typ_tab_msg_confirma;
     vr_tab_erro        gene0001.typ_tab_erro;


  BEGIN

      -- Código do programa
      vr_cdprogra := 'PREJ0003';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PREJ0003'
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

   
 
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

       --Verificar data
       IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
       ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
       END IF; 

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código da critica
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Se houver indicador de restart, mas não veio conta
      IF vr_inrestar > 0 AND vr_nrctares = 0  THEN
        -- Remover o indicador
        vr_inrestar := 0;
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
  

    --Transfere as contas em prejuizo para a tabela HIST...
    FOR rw_crapris IN cr_crapris(pr_cdcooper,vr_dtrefere_aux,vr_valor_arrasto) LOOP
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

        EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao transferir a conta em prejuizo --> '
                          ||'Cooperativa:'||pr_cdcooper || 'Conta: '||rw_crapris.nrdconta||', Situção: '||rw_crapris.cdsitdct
                          || '. Detalhes:'||SQLERRM;
              RAISE vr_exc_saida;
        END;        
        
        BEGIN
           UPDATE crapass pass
           SET pass.cdsitdct = 3,
               pass.inprejuz = 1
           WHERE pass.cdcooper = pr_cdcooper
           AND   pass.nrdconta = rw_crapris.nrdconta;
        
        EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao alterar da situação da conta --> '
                          ||'Cooperativa:'||pr_cdcooper || 'Conta: '||rw_crapris.nrdconta||', Situção: '||rw_crapris.cdsitdct
                          || '. Detalhes:'||SQLERRM;
              RAISE vr_exc_saida;
        END;   
           
    END LOOP;

    -- Chamar rotina para eliminação do restart para evitarmos
    -- reprocessamento das aplicações indevidamente
    btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                               ,pr_cdprogra => vr_cdprogra   --> Código do programa
                               ,pr_flgresta => pr_flgresta   --> Indicador de restart
                               ,pr_des_erro => vr_dscritic); --> Saída de erro
    -- Testar saída de erro
    IF vr_dscritic IS NOT NULL THEN
      -- Sair do processo
      RAISE vr_exc_saida;
    END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

  END pc_transfere_prejuizo_cc;
--

END PREJ0003;
/
