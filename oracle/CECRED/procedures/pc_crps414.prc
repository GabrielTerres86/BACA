CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS414 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                              ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utiliza��o de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                              ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT varchar2) IS
  BEGIN
    /* ..........................................................................

       Programa: pc_crps414 (Antigo Fontes/crps414.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Junior
       Data    : Outubro/2004.                   Ultima atualizacao: 19/09/2014

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Gerar informacoes sobre emprestimos, cotas, desconto de cheques,
                   aplicacoes, para os relatorios gerenciais.

       Alteracoes: 07/12/2004 - Incluir gravacao de dados no campo vldcotas da
                                tabela gntotpl (Valor de cotas das Cooperativas na
                                CECRED) (Junior).

                   16/02/2005 - Buscar o saldo RDCA das Cooperativas na CECRED,
                                para gravar na tabela gntotpl (campo vlrdca30)
                                (Junior).

                   14/03/2005 - Buscar o total de cheques descontados por agencia,
                                para gravar na tabela gninfpl (campo vltotdsc)
                                (Junior).
                   11/04/2005 - Verificar qdo mensal, obter saldo tabela
                                crapepr(Mirtes).

                   05/09/2005 - Gravacao de dados de RDCA30 e RDCA60 por PAC
                                na tabela gninfpl do banco generico (Junior).

                   23/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   04/10/2006 - Alteracao na rotina de soma de desconto de cheques,
                                para considerar os valores por cooperado e nao por
                                PAC (Junior).

                   09/08/2007 - Efetuar tratamento para aplicacoes RDC (David).

                   19/11/2007 - Substituir chamada da include aplicacao.i pela
                                BO b1wgen0004.i. (Sidnei - Precise).

                   30/09/2008 - Alimentar o campo gninfpl.vltottit referente ao
                                desconto de titulos (David).

                   13/10/2008 - No total de cotistas, somar apenas as contas com
                                crapass.inmatric = 1 (Junior).

                   05/05/2009 - Ajuste na leitura de desconto de titulos(Guilherme).

                   10/06/2010 - Tratamento para pagamentos feitos atraves de TAA
                                (Elton).

                   20/05/2011 - Melhorar performance (Magui).

                   16/08/2011 - Alterado para rodar em paralelo consigo mesmo,
                                programa crps414_1.p (Evandro).

                   14/11/2011 - Aumentada a quantidade de processos paralelos
                               (Evandro).

                   22/06/2012 - Substituido gncoper por crapcop (Tiago).

                   31/01/2013 - Convers�o Progress >> Oracle PLSQL

                   25/11/2013 - Limpar parametros de saida de critica no caso da
                                exce��o vr_exc_fimprg (Marcos-Supero)
                                
                   27/01/2014 - Passagem de par�metro repeat_interval no submit 
                                ao Job, evitando assim jobs inv�lidos ap�s execu��o
                                (Marcos-Supero)
                                
                   13/05/2014 - Retirada a inicializa��o do log especifico do programa
                                pois o nome do arquivo mudar� para CRPS414_AAAAMMDD(dtmvtolt)(Odirlei - Amcom)             
																
									 19/09/2014 - Adicionado tratamento para aplica��es dos produtos
									              de capta��o. (Reinert)   

     ............................................................................ */
    DECLARE
      -- C�digo do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      -- Tratamento de erros
      vr_exc_saida  exception;
      vr_exc_fimprg EXCEPTION;			
      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
			vr_cdcritic INTEGER;
			vr_dscritic VARCHAR2(4000);
      -- ID para o paralelismo
      vr_idparale INTEGER;
      -- Qtde parametrizada de Jobs
      vr_qtdjobs NUMBER;
			
			-- Vari�veis que retornam da procedure de apli0005.pc_busca_saldo_aplicacoes
      vr_vlsldtot NUMBER;
      vr_vlsldrgt NUMBER;
						
      -- Busca de todas as agencias da cooperativa
      CURSOR cr_crapage IS
        SELECT age.cdagenci
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper;
      -- Bloco PLSQL para chamar a execu��o paralela do pc_crps414
      vr_dsplsql VARCHAR2(4000);
      -- Job name dos processos criados
      vr_jobname VARCHAR2(30);
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      -- Busca das contas das pr�prias cooperativas
      CURSOR cr_crapass IS
        SELECT cop.cdcooper
              ,cop.nrctactl
              ,cot.vldcotas
							,ass.nrdconta
          FROM crapcot cot
              ,crapcop cop
              ,crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.dtdemiss IS NULL
           AND ass.cdcooper = cot.cdcooper
           AND ass.nrdconta = cot.nrdconta
           AND ass.nrdconta = cop.nrctactl;
      -- Variaveis para a chamada da apli0001.pc_calcula_sldrda
      vr_tab_crawext FORM0001.typ_tab_crawext;
      vr_vltotrda    NUMBER(18,8);
    BEGIN
      -- C�digo do programa
      vr_cdprogra := 'CRPS414';
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS414'
                                ,pr_action => NULL );
      
      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF pr_cdcritic <> 0 THEN
        -- Buscar descri��o da cr�tica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
        -- Levantar exce��o
        pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
        RAISE vr_exc_saida;
      END IF;
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_PARALE_CRPS414'),10);
      -- Para cada ag�ncia da cooperativa
      FOR rw_crapage IN cr_crapage LOOP
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci,3,'0') --> Utiliza a ag�ncia como id programa
                                  ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exce�ao
          RAISE vr_exc_saida;
        END IF;
        -- Montar o bloco PLSQL que ser� executado
        -- Ou seja, executaremos a gera��o dos dados
        -- para a ag�ncia atual atraves de Job no banco
        vr_dsplsql := 'DECLARE'||chr(13)
                   || '  vr_cdcritic NUMBER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                   || 'BEGIN'||chr(13)
                   || '  pc_crps414_1('||pr_cdcooper||','||vr_idparale||','||rw_crapage.cdagenci||',vr_cdcritic,vr_dscritic);'||chr(13)
                   || 'END;';
        -- Montar o prefixo do c�digo do programa para o jobname
        vr_jobname := 'crps414_'||rw_crapage.cdagenci||'$';
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> C�digo da cooperativa
                              ,pr_cdprogra  => vr_cdprogra  --> C�digo do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva   => NULL          --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => pr_dscritic);
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
      IF pr_dscritic IS NOT NULL THEN
        -- Levantar exce�ao
        RAISE vr_exc_saida;
      END IF;
      -- Para a Cecred existe uma contabiliza��o especial
      IF pr_cdcooper = 3 THEN
        -- Buscar calend�rio
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        -- Busca das contas das pr�prias cooperativas
        FOR rw_crapass IN cr_crapass LOOP
          -- Chamar rotina para montar o saldo das aplicacoes financeiras
          APLI0001.pc_calc_sldrda(pr_cdcooper    => pr_cdcooper         --> Cooperativa
                                 ,pr_dtmvtolt    => rw_crapdat.dtmvtolt --> Data do processo
                                 ,pr_inproces    => rw_crapdat.inproces --> Indicador do processo
                                 ,pr_dtmvtopr    => rw_crapdat.dtmvtopr --> Pr�ximo dia util
                                 ,pr_cdprogra    => vr_cdprogra         --> Programa em execu��o
                                 ,pr_cdagenci    => 0                   --> C�digo da ag�ncia
                                 ,pr_nrdcaixa    => 999                 --> N�mero do caixa
                                 ,pr_nrdconta    => rw_crapass.nrctactl --> N�mero da conta para o saldo
                                 ,pr_flgextra    => FALSE               --> Indicar de extrato S/N
                                 ,pr_tab_crapdat => rw_crapdat          --> Dados da tabela de datas
                                 ,pr_tab_crawext => vr_tab_crawext      --> Tabela com as informa��es de extrato
                                 ,pr_vltotrda    => vr_vltotrda         --> Total aplica��o RDC ou RDCA
                                 ,pr_des_reto    => vr_des_reto         --> OK ou NOK
                                 ,pr_tab_erro    => vr_tab_erro);       --> Tabela com erros IS
          -- Se retornar erro
          IF vr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapass.nrctactl;
            ELSE
              pr_dscritic := 'Retorno "NOK" na apli0001.pc_calc_sldrda e sem informa��o na pr_vet_erro, Conta: '||rw_crapass.nrctactl;
            END IF;
            -- Levantar exce��o
            RAISE vr_exc_saida;
          END IF;
					
					APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper           --> C�digo da Cooperativa
																					  ,pr_cdoperad => '1'                   --> C�digo do Operador
																					  ,pr_nmdatela => 'pc_crps414'          --> Nome da Tela
																					  ,pr_idorigem => 1         	          --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
																					  ,pr_nrdconta => rw_crapass.nrdconta   --> N�mero da Conta
																					  ,pr_idseqttl => 1                     --> Titular da Conta
																					  ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data de Movimento
																					  ,pr_idblqrgt => 1                     --> Identificador de Bloqueio de Resgate (1 � Todas / 2 � Bloqueadas / 3 � Desbloqueadas)
																					  ,pr_idgerlog => 0                     --> Identificador de Log (0 � N�o / 1 � Sim)
																					  ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplica��o
																					  ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
																					  ,pr_cdcritic => vr_cdcritic           --> C�digo da cr�tica
																					  ,pr_dscritic => vr_dscritic);         --> Descri��o da cr�tica
																						
					IF vr_cdcritic <> 0 OR 
						 TRIM(vr_dscritic) IS NOT NULL THEN
					  vr_dscritic := 'Erro na procedure APLI0005.pc_busca_saldo_aplicacoes --> ' || vr_dscritic;
					  RAISE vr_exc_saida;						 
					END IF;
					
					vr_vltotrda := vr_vltotrda + nvl(vr_vlsldrgt, 0);
					
          -- Se o retorno for inferior a zero ou null
          IF vr_vltotrda < 0 OR vr_vltotrda IS NULL THEN
            -- Utilizar zero
            vr_vltotrda := 0;
          END IF;
          -- Gravar a tabela GNTOTPL - Informa��es gerenciais totalizas por Cooperativa
          DECLARE
            vr_dsopera VARCHAR2(30);
          BEGIN
            -- Tenta atualizar as informa��es
            vr_dsopera := 'Atualizar';
            UPDATE gntotpl
               SET vldcotas = rw_crapass.vldcotas
                  ,vlrdca30 = vr_vltotrda
             WHERE cdcooper = rw_crapass.cdcooper  --> Cooperativa do registro
               AND dtmvtolt = rw_crapdat.dtmvtolt; --> Data atual
            -- Se n�o conseguiu atualizar nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
              -- N�o encontrou nada para atualizar, ent�o inserimos
              vr_dsopera := 'Inserir';
              INSERT INTO gntotpl
                         (cdcooper
                         ,dtmvtolt
                         ,vldcotas
                         ,vlrdca30)
                   VALUES(rw_crapass.cdcooper
                         ,rw_crapdat.dtmvtolt
                         ,rw_crapass.vldcotas
                         ,vr_vltotrda);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao '||vr_dsopera||' as informa��es na tabela GNTOTPL: '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        END LOOP;
      END IF;
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || pr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Limpar variaveis de saida de critica pois � um erro tratado
        pr_cdcritic := 0;
        pr_dscritic := null;
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps414;
/

