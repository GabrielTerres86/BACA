CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS750 (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo Agencia
                                       ,pr_nmdatela IN VARCHAR2              --> Nome Tela
                                       ,pr_idparale IN crappar.idparale%TYPE --> Indicador de processoparalelo
                                       ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
BEGIN

  /* .............................................................................

  Programa: PC_CRPS750
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Jean
  Data    : Abril/2017                      Ultima atualizacao: 19/10/2018

  Dados referentes ao programa:

  Frequencia: Diaria
  Objetivo  : Priorização das parcelas de empréstimos (TR e PP) para pagamentos

  Alteracoes: 22/06/2017 - Correção do tratamento de erros, não deve abortar o programa e
                           sim continuar para o próximo registro - Jean - Mout´S

              07/08/2017 - Correção da execução do relatório 135, que não estava sendo
                           gerado na execução em paralelo.

              09/08/2017 - Inclusao do filtro para produto PP. (Jaison/James - PRJ298)

              16/02/2018 - #674939 Inclusão do controle de execução dos jobs por agência
                           para permitir o restart do mesmo, não reexecutando as agências
                           que já foram processadas com sucesso (Carlos)
   
              13/04/2018 - Debitador Unico - (Fabiano B. Dias AMcom).

              30/08/2018 - Debitador Unico - permitir executar na cadeia da CECRED alem do debitador (Fabiano B. Dias AMcom).
              
              19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)              
			  
 ............................................................................. */

  DECLARE

    /*Cursores Locais */

    --Selecionar Parcelas emprestimo
       CURSOR cr_crappep (pr_cdcooper  IN crappep.cdcooper%TYPE
                         ,pr_dtmvtolt  IN crappep.dtvencto%TYPE
                         ,pr_dtmvtoan  IN crappep.dtvencto%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
        SELECT 'PP' idtpprd -- Tipo de produto de emprestimo, se PP chama a PC_CRPS750_2
           , nvl((select 1 from crapbpr
                 where  crapbpr.cdcooper = crappep.cdcooper
                 and    crapbpr.nrdconta = crappep.nrdconta
                 and    crapbpr.nrctrpro = crappep.nrctremp
                 and    grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
                 and    crapbpr.cdsitgrv not in (1,4,5)
                 and    rownum = 1),0) idgravame
           , nvl((select 1 from crapavl
                 where  crapavl.cdcooper = crappep.cdcooper
                 and    crapavl.nrdconta = crappep.nrdconta
                 and    rownum = 1),0) idavalista
           , crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crapass.cdagenci
           , crappep.dtvencto
           , crappep.vlsdvatu vlsdvpar -- crappep.vlsdvpar
           , crappep.nrparepr
           , crappep.inliquid
           , crappep.rowid
        FROM crawepr
           , crapass
           , crappep
           , crapepr
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         and crapepr.cdcooper = crappep.cdcooper
         and crapepr.nrdconta = crappep.nrdconta
         and crapepr.nrctremp = crappep.nrctremp
         and crapepr.tpemprst = 1 -- Price Pre Fixado
         and crapepr.inliquid = 0
         and crapepr.inprejuz = 0
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.dtvencto <= pr_dtmvtolt
         AND crappep.inprejuz = 0
         AND ((crappep.inliquid = 0) OR (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan))
       UNION

       SELECT 'TR' idtpprd
              , nvl((select 1 from crapbpr
                 where  crapbpr.cdcooper = epr.cdcooper
                 and    crapbpr.nrdconta = epr.nrdconta
                 and    crapbpr.nrctrpro = epr.nrctremp
                 and    grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
                 and    crapbpr.cdsitgrv not in (1,4,5)
                 and    rownum = 1),0) idgravame
              , nvl((select 1 from crapavl
                    where  crapavl.cdcooper = epr.cdcooper
                    and    crapavl.nrdconta = epr.nrdconta
                    and     rownum = 1),0) idavalista
              ,epr.cdcooper
              ,epr.nrdconta
              ,epr.nrctremp
              ,PRC.CDAGENCI
              ,prc.dtdpagto dtvencto
              ,prc.vlparcela vlsdvpar
              ,prc.nrparcela nrparepr
              ,epr.inliquid
              ,epr.rowid
          FROM crapepr epr,
               tbepr_tr_parcelas prc
         WHERE epr.cdcooper = prc.cdcooper
      --   AND epr.cdagenci = prc.cdagenci
           AND epr.nrdconta = prc.nrdconta
           AND epr.nrctremp = prc.nrctremp
           AND epr.cdcooper = pr_cdcooper          --> Coop conectada
           AND PRC.CDAGENCI = decode(pr_cdagenci,0,PRC.cdagenci,pr_cdagenci)
           AND epr.inliquid = 0                    --> Somente não liquidados
           AND epr.indpagto = 0                    --> Nao pago no mês ainda
           AND epr.flgpagto = 0                    --> Débito em conta
           AND epr.tpemprst = 0                    --> Price TR
           AND epr.dtdpagto <= pr_dtmvtolt --> data corrente
           and prc.flgacordo <> 1
           and prc.flgprocessa = 1
       ORDER
          BY dtvencto
           , idgravame  desc
           , idavalista desc
           , vlsdvpar   desc
           , cdcooper
           , nrdconta
           , nrctremp
           , nrparepr;

    rw_crappep cr_crappep%ROWTYPE;


    -- Alterações na rotina para executar na cadeia noturna além do debitador
    cursor cr_tbgen_param_debit_unico IS
      select tdp.inexec_cadeia_noturna,
             tdp.incontrole_exec_prog      
        from tbgen_debitador_param  tdp
       where exists (select 1 
                       from tbgen_debitador_horario_proc  tdhp 
                      where tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único        
         and nrprioridade is not null --Programa deve ter prioridade informada
         and cdprocesso = 'PC_CRPS750';    
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;

    --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS750';

    --Variaveis para retorno de erro
       vr_cdcritic      INTEGER:= 0;
       vr_dscritic      VARCHAR2(4000);
       vr_idprglog      NUMBER;


    --Variaveis de Excecao
       vr_exc_final     EXCEPTION;
       vr_exc_saida     EXCEPTION;
       vr_exc_fimprg    EXCEPTION;

    -- ID para o paralelismo
    vr_idparale INTEGER;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs NUMBER;
    vr_nrdconta number;
    vr_nrctremp number;
    vr_nrparcela number;
    vr_idtpprd varchar2(2);

    -- Debitador Unico
    vr_flultexe     NUMBER;
    vr_qtdexec      NUMBER;

    -- Busca de todas as agencias da cooperativa
    CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crappep.dtvencto%TYPE
                     ,pr_dtmvtoan IN crappep.dtvencto%TYPE
                     ,pr_qterro   IN NUMBER) IS
        SELECT CDAGENCI, SUM(QTDE)
          FROM (SELECT crapass.cdagenci cdagenci, count(crapass.cdagenci) QTDE
                  FROM crappep, crapass
                 WHERE crappep.cdcooper = pr_cdcooper
                   AND crapass.cdcooper = crappep.cdcooper
                   AND crapass.nrdconta = crappep.nrdconta
                   AND crapass.cdagenci =
                       decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci)
                   AND crappep.dtvencto <= pr_dtmvtolt
                   AND ((crappep.inliquid = 0) OR
                       (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan))
                       
                   and (pr_qterro = 0 or
                       (pr_qterro > 0 and exists (select 1
                                                    from tbgen_batch_controle
                                                   where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                                     and tbgen_batch_controle.cdprogra    = vr_cdprogra
                                                     and tbgen_batch_controle.tpagrupador = 1
                                                     and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                                     and tbgen_batch_controle.insituacao  = 1
                                                     and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))

                 group by cdagenci
                UNION ALL
                Select t.cdagenci cdagenci, count(T.cdagenci) QTDE
                  from cecred.tbepr_tr_parcelas t
                 where t.flgacordo <> 1
                   and t.cdcooper = pr_cdcooper
                   and t.cdagenci =
                       decode(pr_cdagenci, 0, t.cdagenci, pr_cdagenci)
                 group by cdagenci)
                 
         GROUP BY CDAGENCI
         order by 2 desc;

    -- Bloco PLSQL para chamar a execução paralela do pc_crps750
    vr_dsplsql VARCHAR2(4000);
    -- Job name dos processos criados
    vr_jobname VARCHAR2(30);

    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;    
    vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
    vr_qterro        number := 0;    

    ---------------------------------------
    -- Inicio Bloco Principal PC_CRPS750
    ---------------------------------------
  BEGIN

    --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

    IF pr_cdagenci = 0           -- JOB principal do paralelismo.
    AND pr_cdcooper <> 3 THEN	 -- nao seja CECRED.
      -- Verifica quantidade de execuções do programa durante o dia no Debitador Único
      gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper   => pr_cdcooper   --Cooperativa
                                                  ,pr_cdprocesso => 'PC_'||vr_cdprogra --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)
                                                  ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF; -- pr_cdagenci = 0 THEN -- JOB principal do paralelismo.
    
    
    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
      open cr_tbgen_param_debit_unico;
      fetch cr_tbgen_param_debit_unico into rw_tbgen_param_debit_unico;
      if cr_tbgen_param_debit_unico%notfound then
        close cr_tbgen_param_debit_unico;
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao buscar parâmetro de indicador de execução do programa do debitor na cadeia noturna';
        raise vr_exc_saida;
      else
        close cr_tbgen_param_debit_unico;
      end if;

    -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

    -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

    --Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      --Descricao do erro recebe mensagam da critica
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
      --Sair do programa
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    -- define como primeira execucao
    
    -- Debitador Unico:
    IF pr_cdagenci = 0 THEN -- JOB principal do paralelismo.
      IF pr_cdcooper <> 3 THEN -- nao seja CECRED.
	    --> Verificar/controlar a execução.
        SICR0001.pc_controle_exec_deb (  pr_cdcooper  => pr_cdcooper                 --> Código da coopertiva
                                        ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento
                                        ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa
                                        ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                        ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                        ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                        ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

        IF nvl(vr_cdcritic,0) > 0 OR
        TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        ELSE
          COMMIT;
        END IF;
      END IF; -- pr_cdcooper <> 3.
    END IF; -- pr_cdagenci = 0 THEN -- JOB principal do paralelismo.

  -- gera log para futuros rastreios
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => 'CRPS750',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => 2,
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Antes PC_CRPS750_1 - fase 1. AGENCIA - '||PR_CDAGENCI||' - INPROCES - '||rw_crapdat.inproces,
                        PR_IDPRGLOG           => vr_idprglog); 

      /* Todas as parcelas nao liquidadas que estao para serem pagas em dia ou estao em atraso */
    if PR_CDAGENCI = 0 then
    --and   rw_crapdat.inproces >= 2 then
      
       --
       PC_CRPS750_1( pr_faseprocesso => 1
                    ,pr_cdcooper     => pr_cdcooper --> Codigo Cooperativa
                    ,pr_nrdconta     => null  --> Número da conta
                    ,pr_nrctremp     => null  --> contrato de emprestimo
                    ,pr_nrparepr     => null  --> numero da parcela
                    ,pr_cdagenci     => null  --> código da agencia
                    ,pr_cdoperad     => null  --> Código do operador
                    ,pr_cdcritic     => vr_cdcritic --> Codigo da Critica
                    ,pr_dscritic     => vr_dscritic);
        COMMIT;
    END IF;


    /* 229243 Paralelismo visando performance
       Rodar Somente no processo Noturno */
      -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := NVL(gene0001.fn_param_sistema('CRED'
                                               ,pr_cdcooper
                                               ,'QTD_PARALE_CRPS750')
                     ,16);

    
     --  Paralelisar somente na primeira execucao do dia ou se o parametro de execução na cadeia estiver S irá executar na cadeia noturna também*/
    IF (vr_qtdexec = 1 OR (rw_crapdat.inproces >= 2 AND NVL(rw_tbgen_param_debit_unico.inexec_cadeia_noturna,'N') = 'S'))
	AND pr_cdagenci = 0
    AND vr_qtdjobs > 0 THEN
       
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      cecred.pc_log_programa(pr_dstiplog   => 'I',    
                             pr_cdprograma => vr_cdprogra,           
                             pr_cdcooper   => pr_cdcooper, 
                             pr_tpexecucao => 1, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_idprglog   => vr_idlog_ini_ger);

      /* Inicial rotinas em paralelo por agencia para agilizar processamento */

      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
        -- Levantar exceção
        vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);                                                      

      -- Para cada agência da cooperativa
      FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                  ,pr_qterro   => vr_qterro) LOOP
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci
                                                      ,3
                                                      ,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13) || --
                      '  wpr_stprogra NUMBER;' || chr(13) || --
                      '  wpr_infimsol NUMBER;' || chr(13) || --
                      '  wpr_cdcritic NUMBER;' || chr(13) || --
                      '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                      'BEGIN' || chr(13) || --
                      '  pc_crps750( ' || --
                      pr_cdcooper || ',' || --
                       rw_crapage.cdagenci || --
                      ', ''JOB'',' || --
                      vr_idparale || ',' || --
                      ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
                      chr(13) || --
                      'END;'; --
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := 'crps750_' || rw_crapage.cdagenci || '$';
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                              ,pr_cdprogra => vr_cdprogra --> Código do programa
                              ,pr_dsplsql  => vr_dsplsql --> Bloco PLSQL a executar
                              ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva  => NULL --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname  => vr_jobname --> Nome randomico criado
                              ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
        -- Chama rotina que irá pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execuçao
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                    ,pr_des_erro => vr_dscritic);
        -- Testar saida com erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      --Salvar informacoes no banco de dados
      COMMIT;

      --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
      cecred.pc_log_programa(pr_dstiplog   => 'F',    
                             pr_cdprograma => vr_cdprogra,           
                             pr_cdcooper   => pr_cdcooper, 
                             pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             pr_idprglog   => vr_idlog_ini_ger,
                             pr_flgsucesso => 1);

      RETURN;
    END IF;

    /***************************************/

   /*IF  TRUNC(SYSDATE) <> rw_crapdat.dtmvtolt
   and rw_crapdat.inproces = 1 THEN
       --> O JOB esta configurado para rodar de Segunda a Sexta
       -- Mas nao existe a necessidade de rodar nos feriados
       -- Por isso que validamos se o dia de hoje eh o dia do sistema
       RAISE vr_exc_saida;
    END IF;*/

    IF pr_cdagenci <> 0 THEN
      vr_tpexecucao := 2;
    ELSE
      vr_tpexecucao := 1;
    END IF;

    -- Grava controle de batch por agência
    gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                    ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                    ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                    ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                    ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                    ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                    ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                    ,pr_cdcritic    => vr_cdcritic               -- Codigo da critica
                                    ,pr_dscritic    => vr_dscritic              
                                     );   
    -- Testar saida com erro
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_saida;
    END IF;

    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    cecred.pc_log_programa(pr_dstiplog   => 'I',    
                           pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                           pr_cdcooper   => pr_cdcooper, 
                           pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_idprglog   => vr_idlog_ini_par); 
                      
    -- Grava LOG de ocorrência inicial do cursor cr_craprpp
    cecred.pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => 'Início - cursor cr_craprpp. AGENCIA: '||pr_cdagenci||' - INPROCES: '||rw_crapdat.inproces,
                           PR_IDPRGLOG     => vr_idlog_ini_par);

    FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                    ,pr_cdagenci => pr_cdagenci) LOOP


           /* Verificar tipo de produto, se TR, executar a PC_CRPS750_1, se PP, executar a PC_CRPS750_2 */
           vr_nrdconta := rw_crappep.nrdconta;
           vr_nrctremp := rw_crappep.nrctremp;
           vr_nrparcela := rw_crappep.nrparepr;
           vr_idtpprd := rw_crappep.idtpprd;

           if  rw_crappep.idtpprd = 'TR' then
               --if rw_crapdat.inproces >= 2 then
          PC_CRPS750_1(pr_faseprocesso => 2
                              ,pr_cdcooper     => pr_cdcooper --> Codigo Cooperativa
                              ,pr_nrdconta     => rw_crappep.nrdconta  --> Número da conta
                              ,pr_nrctremp     => rw_crappep.nrctremp  --> contrato de emprestimo
                              ,pr_nrparepr     => rw_crappep.nrparepr  --> numero da parcela
                              ,pr_cdagenci     => rw_crappep.cdagenci  --> código da agencia
                              ,pr_cdoperad     => user  --> Código do operador
                      ,pr_cdcritic     => vr_cdcritic --> Codigo da Critica
                              ,pr_dscritic     => vr_dscritic);

          IF vr_dscritic IS NULL THEN
             COMMIT;
          END IF;
        --end if;
      elsif rw_crappep.idtpprd = 'PP' then

                 PC_CRPS750_2(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                             ,pr_nrctremp => rw_crappep.nrctremp --> contrato de emprestimo
                             ,pr_nrparepr => rw_crappep.nrparepr --> numero da parcela
                             ,pr_cdagenci => rw_crappep.cdagenci --> código da agencia
                             ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                             ,pr_infimsol => pr_infimsol
                    ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                    ,pr_dscritic => vr_dscritic);      --> descricao da critica
      end if;

      if vr_dscritic is not null then
         btch0001.pc_gera_log_batch(pr_cdcooper  => pr_cdcooper,
                                    pr_ind_tipo_log => 2,
                                    pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra ||' --> '|| vr_dscritic,
                                    pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));



      end if;
      /***************************************/
    END LOOP; /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

    /* encerra a execucao da pc_crps750_1 */
    IF pr_cdagenci <> 0 THEN
    --and rw_crapdat.inproces >= 2 THEN

        PC_CRPS750_1( pr_faseprocesso => 3
                      ,pr_cdcooper     => pr_cdcooper --> Codigo Cooperativa
                      ,pr_nrdconta     => null  --> Número da conta
                      ,pr_nrctremp     => null  --> contrato de emprestimo
                      ,pr_nrparepr     => null  --> numero da parcela
                      ,pr_cdagenci     => pr_cdagenci  --> código da agencia
                      ,pr_cdoperad     => null  --> Código do operador
                     ,pr_cdcritic     => vr_cdcritic --> Codigo da Critica
                      ,pr_dscritic     => vr_dscritic);
    END IF;

    /* 229243 - Atualizar Processamento na crapprm */
    BEGIN

         insert into crapprm a
         (nmsistem
         ,cdcooper
         ,cdacesso
         ,dstexprm
         ,dsvlrprm)
         values('CRED',
         pr_cdcooper
         ,'CRPS750_DATA_PROCESSO'
         ,'Fim processo'
         ,to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY'));

    EXCEPTION
      WHEN dup_val_on_index THEN
        UPDATE crapprm a
         SET a.dsvlrprm = to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')
       WHERE a.cdcooper = pr_cdcooper
         AND a.cdacesso = 'CRPS750_DATA_PROCESSO';


      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapprm. ' || SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_saida;
    END;

    --Grava data fim para o JOB na tabela de LOG 
    cecred.pc_log_programa(pr_dstiplog   => 'F',    
                           pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                           pr_cdcooper   => pr_cdcooper, 
                           pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_idprglog   => vr_idlog_ini_par,
                           pr_flgsucesso => 1);       

    
    IF pr_idparale <> 0 THEN
      
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);  

      -- Encerrar o job do processamento paralelo dessa agência
         gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                     ,pr_des_erro => vr_dscritic);

      --Salvar informacoes no banco de dados
      COMMIT;
    END IF;
  EXCEPTION
    WHEN vr_exc_saida THEN

      -- Buscar a descricao
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_cdcritic);

      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF vr_dscritic IS NOT NULL AND pr_cdagenci = 0 THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
      END IF;
      
      IF pr_idparale <> 0 THEN
        -- Grava LOG de Erro
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'vr_exc_fimprg - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||vr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);                                   
      END IF;

      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper,
                                   pr_compleme => 'pr_cdcooper: ' || pr_cdcooper ||
                                                 ' pr_cdagenci: ' || pr_cdagenci ||
                                                 ' pr_nmdatela: ' || pr_nmdatela ||
                                                 ' pr_idparale: ' || pr_idparale);

      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      if pr_idparale <> 0 then 
        -- Grava LOG de Erro
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'vr_exc_fimprg - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                 'pr_dscritic:'||vr_dscritic,
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if;

      -- Efetuar rollback
      ROLLBACK;

  END;
END PC_CRPS750;
/
