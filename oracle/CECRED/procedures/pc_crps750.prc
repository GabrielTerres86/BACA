CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS750 (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo Agencia
                                       ,pr_nmdatela IN VARCHAR2                   --> Nome Tela
                                       ,pr_idparale in crappar.idparale%TYPE --> Indicador de processoparalelo
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
  Data    : Abril/2017                      Ultima atualizacao: 11/04/2017

  Dados referentes ao programa:

  Frequencia: Diaria
  Objetivo  : Prioriza��o das parcelas de empr�stimos (TR e PP) para pagamentos

  Alteracoes: 
    ............................................................................. */

  DECLARE

    /*Cursores Locais */

    --Selecionar Parcelas emprestimo
       CURSOR cr_crappep (pr_cdcooper  IN crappep.cdcooper%TYPE
                         ,pr_dtmvtolt  IN crappep.dtvencto%TYPE
                         ,pr_dtmvtoan  IN crappep.dtvencto%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
        SELECT 'PP' idtpprd -- Tipo de produto de emprestimo, se PP chama a PC_CRPS750_2
          , (select 1 from crapcyc 
             where crapcyc.cdcooper = crappep.cdcooper
             and   crapcyc.nrdconta = crappep.nrdconta
             and   crapcyc.nrctremp = crappep.nrctremp
             and   crapcyc.flgehvip = 1
             and   crapcyc.cdmotcin = 1) idacordo
           , crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crapass.cdagenci
           , crappep.dtvencto
           , crappep.vlsdvatu
           , crappep.vlsdvpar
           , crappep.nrparepr
           , crappep.inliquid 
           , crappep.rowid
           , crawepr.dtlibera
           , crawepr.tpemprst
        FROM crawepr
           , crapass
           , crappep
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         --AND CRAPPEP.NRDCONTA = 67784 -- Retirar apos testes
         AND crappep.cdcooper = pr_cdcooper
         AND crappep.dtvencto <= pr_dtmvtolt
         AND crappep.inprejuz = 0
         AND ((crappep.inliquid = 0) OR (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan))
       ORDER
          BY idacordo
           , crappep.dtvencto
           , crappep.vlsdvatu desc
           , crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crappep.nrparepr;
           -- efetuar o UNION com o cursor da 171
    rw_crappep cr_crappep%ROWTYPE;

    cursor cr_erro(pr_cdcooper in crapcop.cdcooper%TYPE) is
      select c.dsvlrprm
        from crapprm c
       where c.nmsistem = 'CRED'
         and c.cdcooper = pr_cdcooper
         and c.cdacesso = 'PC_CRPS750-ERRO';
    rw_erro cr_erro%ROWTYPE;

    --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS750';

    --Variaveis Locais
       vr_flgpripr BOOLEAN;
    
    --Variaveis para retorno de erro
       vr_cdcritic      INTEGER:= 0;
       vr_dscritic      VARCHAR2(4000);
       

    --Variaveis de Excecao
       vr_exc_final     EXCEPTION;
       vr_exc_saida     EXCEPTION;
       vr_exc_fimprg    EXCEPTION;

    -- ID para o paralelismo
    vr_idparale INTEGER;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs NUMBER;

    -- Busca de todas as agencias da cooperativa
    CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crappep.dtvencto%TYPE
                     ,pr_dtmvtoan IN crappep.dtvencto%TYPE) IS
      SELECT crapass.cdagenci
            ,count(crapass.cdagenci)
        FROM crappep
            ,crapass
       WHERE crappep.cdcooper = pr_cdcooper
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crapass.cdagenci =
             decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci)
         AND crappep.dtvencto <= pr_dtmvtolt
         AND ((crappep.inliquid = 0) OR
             (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan))
       group by crapass.cdagenci
       order by 2 desc;

    -- Bloco PLSQL para chamar a execu��o paralela do pc_crps750
    vr_dsplsql VARCHAR2(4000);
    -- Job name dos processos criados
    vr_jobname VARCHAR2(30);
 
    --Verificar a data do ultimo processamento
    PROCEDURE pc_verifica_processo IS

      -- Cursor de sele��o do parametro CRPS750_DATA_PROCESSO
      CURSOR cr_crapprm IS
        SELECT a.dsvlrprm
          FROM crapprm a
         WHERE a.cdcooper = pr_cdcooper
           and a.cdacesso = 'CRPS750_DATA_PROCESSO';

      rw_crapprm cr_crapprm%ROWTYPE;

      -- Variveis locais
      vr_dtutlpro DATE;

    BEGIN
      --Abre cursor buscando o parametro.
      OPEN cr_crapprm;
      FETCH cr_crapprm
        INTO rw_crapprm;
      CLOSE cr_crapprm;

      --Converte o valor do parametro em data
      vr_dtutlpro := to_date(substr(rw_crapprm.dsvlrprm, 1, 10)
                            ,'DD/MM/YYYY');

      --Verifica se ja ocorreu processo hoje
      IF vr_dtutlpro = TRUNC(rw_crapdat.dtmvtolt) THEN
         vr_flgpripr := TRUE;
      ELSE
         vr_flgpripr := FALSE;
      END IF;

    END pc_verifica_processo;

    ---------------------------------------
    -- Inicio Bloco Principal PC_CRPS750
    ---------------------------------------
  BEGIN

    --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

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
    
    if pr_cdagenci = 0 then
      begin
        delete crapprm c
         where c.nmsistem = 'CRED'
           and c.cdcooper = pr_cdcooper
           and c.cdacesso = 'PC_CRPS750-ERRO';
        
        commit;
        
      exception
        when others then
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || 'Erro ao tentar deletar registro de erro da CRAPPRM');
          --Sair do programa
          RAISE vr_exc_saida;
      end;
    end if;

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

    /* 229243 Paralelismo visando performance
       Rodar Somente no processo Noturno */
    IF rw_crapdat.inproces > 2 and
       pr_cdagenci = 0 THEN
      /* Inicial rotinas em paralelo por agencia para agilizar processamento */

      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
        -- Levantar exce��o
        pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
        RAISE vr_exc_saida;
      END IF;
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := NVL(gene0001.fn_param_sistema('CRED'
                                                 ,pr_cdcooper
                                                 ,'QTD_PARALE_CRPS750')
                       ,16);
      -- Para cada ag�ncia da cooperativa
      FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci
                                                      ,3
                                                      ,'0') --> Utiliza a ag�ncia como id programa
                                  ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exce�ao
          RAISE vr_exc_saida;
        END IF;
        -- Montar o bloco PLSQL que ser� executado
        -- Ou seja, executaremos a gera��o dos dados
        -- para a ag�ncia atual atraves de Job no banco
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
        -- Montar o prefixo do c�digo do programa para o jobname
        vr_jobname := 'crps750_' || rw_crapage.cdagenci || '$';
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper --> C�digo da cooperativa
                              ,pr_cdprogra => vr_cdprogra --> C�digo do programa
                              ,pr_dsplsql  => vr_dsplsql --> Bloco PLSQL a executar
                              ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva  => NULL --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                              ,pr_jobname  => vr_jobname --> Nome randomico criado
                              ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exce�ao
          RAISE vr_exc_saida;
        END IF;
        -- Chama rotina que ir� pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execu�ao
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => vr_qtdjobs --> M�ximo de 10 jobs neste processo
                                    ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exce�ao
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- at� que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => pr_dscritic);
      -- Testar saida com erro
      open cr_erro(pr_cdcooper);
      fetch cr_erro into rw_erro;
      if cr_erro%found then
        close cr_erro;
        vr_cdcritic := 0;
        vr_dscritic := rw_erro.dsvlrprm;
        raise vr_exc_saida;
      else
        close cr_erro;
      end if;

      IF pr_dscritic IS NOT NULL THEN
        -- Levantar exce�ao
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      --Salvar informacoes no banco de dados
      COMMIT;

      RETURN;
    END IF;
  
    /* 229243 Verifica na crapprm a ultima data de execu��o */
    pc_verifica_processo;
    /***************************************/
    
   IF  TRUNC(SYSDATE) <> rw_crapdat.dtmvtolt
   and rw_crapdat.inproces = 1 THEN
       --> O JOB esta configurado para rodar de Segunda a Sexta
       -- Mas nao existe a necessidade de rodar nos feriados
       -- Por isso que validamos se o dia de hoje eh o dia do sistema
       RAISE vr_exc_saida;
    END IF;

    /* Todas as parcelas nao liquidadas que estao para serem pagas em dia ou estao em atraso */
    FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                    ,pr_cdagenci => pr_cdagenci) LOOP

         
           /* Verificar tipo de produto, se TR, executar a PC_CRPS750_1, se PP, executar a PC_CRPS750_2 */
           if rw_crappep.idtpprd = 'TR' then
              --pc_crps750_1();
              null;
           elsif rw_crappep.idtpprd = 'PP' then
                 PC_CRPS750_2(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crappep.nrdconta --> N�mero da conta
                             ,pr_nrctremp => rw_crappep.nrctremp --> contrato de emprestimo
                             ,pr_nrparepr => rw_crappep.nrparepr --> numero da parcela
                             ,pr_cdagenci => rw_crappep.cdagenci --> c�digo da agencia
                             ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                             ,pr_infimsol => pr_infimsol            
                             ,pr_cdcritic => pr_cdcritic   --> Codigo da Critica
                             ,pr_dscritic => vr_dscritic  );      --> descricao da critica 
           end if;
           
           if vr_dscritic is not null  then
              raise vr_exc_fimprg;
           end if;
         
      /***************************************/
    END LOOP; /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

    /* 229243 - Atualizar Processamento na crapprm */
    --Atualiza ultimo processamento
    BEGIN
      UPDATE crapprm a
         SET a.dsvlrprm = to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')
       WHERE a.cdcooper = pr_cdcooper
         AND a.cdacesso = 'CRPS750_DATA_PROCESSO';
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapprm. ' || SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_saida;
    END;
   
    IF pr_cdagenci = 0 THEN
      -- Processo OK, devemos chamar a fimprg
         btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);

      --Salvar informacoes no banco de dados
      COMMIT;
    ELSE
      -- Encerrar o job do processamento paralelo dessa ag�ncia
         gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                     ,pr_idprogra => pr_cdagenci
                                     ,pr_des_erro => vr_dscritic);
    END IF;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descricao da critica
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

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa ag�ncia
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_cdagenci
                                    ,pr_des_erro => vr_dscritic);
      END IF;

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
      --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
      -- Efetuar commit pois gravaremos o que foi processado ate entao
      COMMIT;

    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descricao
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa ag�ncia
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_cdagenci
                                    ,pr_des_erro => vr_dscritic);
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;
      
      IF pr_cdagenci <> 0 THEN
        begin
          insert into crapprm(nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dstexprm
                             ,dsvlrprm)
                             values
                             ('CRED'
                             ,pr_cdcooper
                             ,'PC_CRPS750-ERRO'
                             ,'Erro na execu��o da rotina pc_crps750'
                             ,'Ag�ncia: '||pr_cdagenci||' - Erro: '||pr_dscritic);
        exception
          when dup_val_on_index then
            null;
        end;
      END IF;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa ag�ncia
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_cdagenci
                                    ,pr_des_erro => vr_dscritic);
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;
      
      IF pr_cdagenci <> 0 THEN
        begin
          insert into crapprm(nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dstexprm
                             ,dsvlrprm)
                             values
                             ('CRED'
                             ,pr_cdcooper
                             ,'PC_CRPS750-ERRO'
                             ,'Erro na execu��o da rotina pc_crps750'
                             ,'Ag�ncia: '||pr_cdagenci||' - Erro: '||pr_dscritic);
        exception
          when dup_val_on_index then
            null;
        end;
      END IF;
  END;
END PC_CRPS750;
/
