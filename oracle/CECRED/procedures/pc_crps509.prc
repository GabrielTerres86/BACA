CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS509 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                               ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                               ,pr_cdagenci IN PLS_INTEGER DEFAULT 0  --> Código da agência, utilizado no paralelismo
                                               ,pr_idparale IN PLS_INTEGER DEFAULT 0  --> Identificador do job executando em paralelo.
                                               ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                               ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                               ,pr_dscritic OUT VARCHAR2               --> Descricao da Critica
                                               ,pr_inpriori IN VARCHAR2 DEFAULT 'T') IS   --> Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, "T"=todos) 
  BEGIN

  /* .............................................................................

   Programa: pc_crps509                        Antigo: Fontes/crps509.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Abril/2008                        Ultima atualizacao: 03/07/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 005. Efetuar debito de agendamentos feitos 
               na Internet.

   Alteracoes: 17/06/2011 - Ajuste devido a alteracao da include (Henrique).

               31/10/2011 - Alterar situacao das transacoes pendentes de
                            operadores na internet(Guilherme).

               24/06/2013 - Conversão Progress -> Oracle - Alisson (AMcom)
               
               01/07/2014 - Tratamento para que o dtmvtopg seja a data do 
                            movimento atual qdo inproces = 1 
                            Prj automatiza compe (Tiago/Aline).
                            
               14/11/2014 - Incluido rotina de geração de arquivo de retorno de
                            pagamento de títulos agendados por arquivo ref. ao
                            Projeto 57-Upload de pagamento por arquivo (Rafael)
                            
               19/11/2015 - Alterado tratamento do para definir a data de acordo com o inprocess,
                            procedimento será rodado por job e inproces sempre será 1.
                          - Incluido tratamento para identificar se é o ultimo processo do dia, 
                            pois programa pode rodar diversas vezes no dia conforme configuração.
                            SD358499 (Odirlei-AMcom)
                            
               16/12/2015 - Atualização da situação dos agendamentos conforme solicitado no
                            chamado 335940 (Kelvin)
                            
               30/12/2015 - Ajuste na chamada da proc. pc_atualiza_trans_nao_efetiv, adicionado
                            param de saida pr_dstransa. (Jorge/David) Proj. 131 - Assinatura Multipla 
                            
               25/05/2016 - Ajustes realizados:
                            -> Passagem do novo parametro para a rotina que busca os agendamentos;
                            -> Não alterar a situação de agendamentos de TED para 4 - não efetivado
                            (Adriano - M117).             
                            
               23/01/2017 - COMMIT após SICR0001.pc_controle_exec_deb para mesmo que haja um
                            ROLlBACK avançar no controle das execuções 
                            SD590929 e SD594359  (Tiago/Fabricio).

               05/04/2018 - Projeto Ligeirinho. Alterado o programa para rodar de forma paralelizada no batch noturno. 
                            Melhora de performance (Fabiano Girardi - AMcom).         
							
               03/07/2018 - Inclusão do pr_inpriori: Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, "T"=todos).
                            Neste programa o valor DEFAULT eh 'T'. Criamos a PC_CRPS642_PRIORI com  valor DEFAULT 'S'. 	(Fabiano B. Dias - AMcom)
     ............................................................................. */

     
     
     DECLARE

      /* Busca informações da agência */
      cursor cr_crapage (pr_cdcooper in crapcop.cdcooper%type
                        ,pr_cdagenci in crapass.cdagenci%type
                        ,pr_dtmvtolt in crapdat.dtmvtolt%type
                        ,pr_cdprogra in tbgen_batch_controle.cdprogra%type
                        ,pr_qterro   in number) is
      select crapage.cdagenci
            ,crapage.nmresage
      from crapage
     where crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci <> 999
       and crapage.cdagenci = decode(pr_cdagenci,0,crapage.cdagenci,pr_cdagenci)
     order by crapage.cdagenci; 
       
       
       /* Tipos e registros da pc_crps509 */

       --Definicao das tabelas de memoria
       vr_tab_agendto PAGA0001.typ_tab_agendto;

       /* Cursores da rotina crps509 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;


       --Variaveis Locais

       vr_flsgproc     BOOLEAN;
       vr_cdcritic     INTEGER;
       vr_dtmvtopg     DATE;
       vr_cdprogra     VARCHAR2(50);
       vr_dstransa     VARCHAR2(4000);
       
       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;
       vr_dtmvtopr     DATE;
       vr_dtmvtoan     DATE;
       vr_dtultdia     DATE;
       vr_qtdiaute     INTEGER;
       vr_flultexe     INTEGER;
       vr_qtdexec      INTEGER;
       
       --Variaveis para retorno de erro
       vr_dscritic    VARCHAR2(4000);
       vr_dstextab    VARCHAR2(1000);

       vr_qtdjobs             number;
       vr_qterro              number := 0;
       vr_jobname             varchar2(30); 
       vr_idparale            integer; 
       vr_index_agendto       VARCHAR2(300);
       vr_ds_xml              tbgen_batch_relatorio_wrk.dsxml%type;
       vr_tpexecucao          tbgen_prglog.tpexecucao%type;
       ds_character_separador constant varchar2(1) := '|';
       cd_todas_agencias      constant number(5) := 0;
       vr_idlog_ini           tbgen_prglog.idprglog%type; 
       vr_idcontrole          tbgen_batch_controle.idcontrole%TYPE;   
       vr_dslog               varchar2(4000);
       vr_nm_procedure        varchar2(100);
       vr_flsgproc_char       varchar2(1);
       vr_sequencia_lote      number;
       
       --Variaveis de Excecao
       vr_exc_saida   EXCEPTION;
       vr_exc_fimprg  EXCEPTION;

       function fn_primeira_execucao return boolean is
       begin
          return vr_qtdexec = 1;

       end fn_primeira_execucao;
       
       
       function fn_existem_jobs return boolean is
       begin
         
         return vr_qtdjobs > 0;
         
       end fn_existem_jobs;
       
       procedure pc_resetar_sequencia is
         v_seq           number;
         vr_dsvlrprm     crapprm.dsvlrprm%type;
         vr_dsvlrprmnum  number;
         v_decremento    number;
       begin
         -- busca o valor parametrizado para o inicialização da sequence
         gene0001.pc_param_sistema(pr_nmsistem  => 'CRED',
                                   pr_cdcooper  => pr_cdcooper,
                                   pr_cdacesso  => 'CRAPLOT_509_SEQ',
                                   pr_dsvlrprm  => vr_dsvlrprm); 
         IF vr_dsvlrprm is null THEN
            vr_dscritic := 'Parâmetro CRAPLOT_509_SEQ não cadastrado.';
            raise vr_exc_saida; 
       END IF;
         vr_dsvlrprmnum:= to_number(vr_dsvlrprm);
         -- verifica a póxima sequencia
         EXECUTE IMMEDIATE 'SELECT cecred.craplot_509_seq.NEXTVAL FROM DUAL' INTO v_seq;
         -- verifica se é a primeira execução da sequencia após a criação da sequence
         IF v_seq < vr_dsvlrprmnum THEN
            -- atualiza o increment by para o valor do parametro
            EXECUTE IMMEDIATE 'ALTER SEQUENCE craplot_509_seq INCREMENT BY ' || vr_dsvlrprmnum;
            -- atualiza o valor atual da sequence para o valor do parâmetro
            EXECUTE IMMEDIATE 'SELECT cecred.craplot_509_seq.NEXTVAL FROM DUAL' INTO v_seq;
            -- volta o increment by para 1 
            EXECUTE IMMEDIATE 'ALTER SEQUENCE craplot_509_seq INCREMENT BY 1';
         ELSIF v_seq > vr_dsvlrprmnum then -- verifica se o valor atual é maior que o parâmetro
            -- calcula o valor do decremento
            v_decremento := v_seq - vr_dsvlrprmnum;
            -- atualiza o increment by negativo para voltar reiniciar a sequence com o valor do parametro             
            EXECUTE IMMEDIATE 'ALTER SEQUENCE craplot_509_seq INCREMENT BY -' || v_decremento;
            -- atualiza a sequence
            EXECUTE IMMEDIATE 'SELECT craplot_509_seq.NEXTVAL FROM DUAL' INTO v_seq; 
            -- atualiza o increment by para 1 e o minvalue para o valor do parâmetro
            EXECUTE IMMEDIATE 'ALTER SEQUENCE craplot_509_seq INCREMENT BY  1 minvalue '||vr_dsvlrprmnum ;
         END IF;
       exception
          when others then
             vr_dscritic := 'Erro pc_resetar_sequencia :'||sqlerrm;
             raise vr_exc_saida; 
       end pc_resetar_sequencia;
       
         
       procedure pc_acertar_lotes is
       
         vr_craplot_rowid  paga0001.typ_tab_tp_cralot_rowid;
         vr_ds_erro varchar2(4000);
       begin  
         vr_ds_erro := null;
         paga0001.pc_gerar_lote_from_wrk(pr_cdcooper      => pr_cdcooper
                                        ,PR_CRAPLOT_ROWID => vr_craplot_rowid
                                        ,pr_dserro        => vr_ds_erro); --out
         commit;
         if vr_ds_erro is null then
           paga0001.pc_atualiz_lote(pr_craplot_rowid => vr_craplot_rowid,
                                    pr_cdcooper      => pr_cdcooper,
                                    pr_sequecia_lote => vr_sequencia_lote);
           commit;
         else
           vr_dscritic := vr_ds_erro;
           raise vr_exc_saida;
         end if;
         
       end pc_acertar_lotes;


       function pc_rep_car_sep(pr_string in varchar2) return varchar2 is
       begin
         return replace(pr_string,ds_character_separador,null);
       end pc_rep_car_sep;

       procedure pc_buscar_dados_cooper is
       begin
       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
         --Atribuir a data do movimento anterior
         vr_dtmvtoan:= rw_crapdat.dtmvtoan;
         --Atribuir a quantidade de dias uteis
         vr_qtdiaute:= rw_crapdat.qtdiaute;
         --Ultimo dia do mes anterior
         vr_dtultdia:= rw_crapdat.dtultdma;
         --Determinar a data do proximo pagamento
         vr_dtmvtopg:= rw_crapdat.dtmvtolt;
                           
       END IF;

       end pc_buscar_dados_cooper;


       procedure pc_limpa_tabela_wrk(pr_CDAGENCI    in tbgen_batch_relatorio_wrk.cdagenci%type,
                                     pr_tipo_delete in varchar2) is 
         PRAGMA AUTONOMOUS_TRANSACTION;
       begin
         
         delete from tbgen_batch_relatorio_wrk wrk
         where wrk.cdcooper    = pr_cdcooper
           and wrk.cdprograma  = 'CRPS509'
           and wrk.dtmvtolt    = vr_dtmvtolt
           and ((wrk.dschave     = 'CRAPLOT' and pr_tipo_delete = 'LOTE') OR 
                (wrk.cdagenci    = decode(pr_CDAGENCI,cd_todas_agencias,wrk.cdagenci,pr_CDAGENCI) and 
                 wrk.dschave    != 'CRAPLOT' and pr_tipo_delete = 'INDEX'));
         commit;
         
       EXCEPTION
         WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro na pc_crps509.pc_limpa_tabela_wrk. Sqlerrm: '||sqlerrm;
           RAISE vr_exc_saida;
           
       end pc_limpa_tabela_wrk;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_pl_table IS
       BEGIN
         vr_tab_agendto.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps509.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
           
       END pc_limpa_pl_table;
     
     
      procedure pc_validar_cooperativa is
      begin
        -- Verifica se a cooperativa esta cadastrada
         OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
         FETCH cr_crapcop INTO rw_crapcop;
         -- Se não encontrar
         IF cr_crapcop%NOTFOUND THEN
           -- Fechar o cursor pois haverá raise
           CLOSE cr_crapcop;
           -- Montar mensagem de critica
           vr_cdcritic:= 651;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           RAISE vr_exc_saida;
         ELSE
           -- Apenas fechar o cursor
           CLOSE cr_crapcop;
         END IF;
      end pc_validar_cooperativa; 
      
      procedure pc_transf_dados_para_tab_wrk is
        PRAGMA AUTONOMOUS_TRANSACTION;
      begin
        vr_nm_procedure := 'pc_transf_dados_para_tab_wrk';
        vr_dslog := 'Inicio - pc_transf_dados_para_tab_wrk. AGENCIA: ['||pr_cdagenci||']'||
                    ' INPROCES: ['||rw_crapdat.inproces||']'||
                    ' pr_idparale: ['||pr_idparale||']'||
                    ' Qtde Registros: ['||vr_tab_agendto.count()||']';
         
        pc_log_programa(PR_DSTIPLOG     => 'O',
                        PR_CDPROGRAMA   => vr_cdprogra,
                        pr_cdcooper     => pr_cdcooper,
                        pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia => 4,
                        pr_dsmensagem   => vr_dslog,
                        PR_IDPRGLOG     => vr_idlog_ini);
                        
        vr_index_agendto := vr_tab_agendto.first;
        
        while vr_index_agendto is not null loop
        
          vr_ds_xml :=  ds_character_separador||
                        vr_tab_agendto(vr_index_agendto).cdcooper||ds_character_separador||
                        pc_rep_car_sep(vr_tab_agendto(vr_index_agendto).dscooper)||ds_character_separador||
                        vr_tab_agendto(vr_index_agendto).nrdconta||ds_character_separador||
                        pc_rep_car_sep(vr_tab_agendto(vr_index_agendto).nmprimtl)||ds_character_separador||
                        vr_tab_agendto(vr_index_agendto).cdagenci||ds_character_separador||
                        vr_tab_agendto(vr_index_agendto).cdtiptra||ds_character_separador;
          
          if vr_tab_agendto(vr_index_agendto).fltiptra then                         
            vr_ds_xml := vr_ds_xml||'TRUE'||ds_character_separador;
          elsif not vr_tab_agendto(vr_index_agendto).fltiptra then
            vr_ds_xml := vr_ds_xml||'FALSE'||ds_character_separador;
          else
            vr_ds_xml := vr_ds_xml||'NULL'||ds_character_separador;
          end if;   
          
          vr_ds_xml := vr_ds_xml||pc_rep_car_sep(vr_tab_agendto(vr_index_agendto).dstiptra)||ds_character_separador;
          
          if vr_tab_agendto(vr_index_agendto).fltipdoc then
           vr_ds_xml := vr_ds_xml||'TRUE'||ds_character_separador;
          elsif not vr_tab_agendto(vr_index_agendto).fltipdoc then
            vr_ds_xml := vr_ds_xml||'FALSE'||ds_character_separador;
          else
            vr_ds_xml := vr_ds_xml||'NULL'||ds_character_separador;
          end if;     
          
          vr_ds_xml := vr_ds_xml||pc_rep_car_sep(vr_tab_agendto(vr_index_agendto).dstransa)||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).vllanaut||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).dttransa||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).hrtransa||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).nrdocmto||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).dslindig||ds_character_separador||
                                  pc_rep_car_sep(vr_tab_agendto(vr_index_agendto).dscritic)||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).nrdrecid||ds_character_separador;
          
          if vr_tab_agendto(vr_index_agendto).fldebito then
            vr_ds_xml := vr_ds_xml||'TRUE'||ds_character_separador;
          elsif not vr_tab_agendto(vr_index_agendto).fldebito then
            vr_ds_xml := vr_ds_xml||'FALSE'||ds_character_separador;
          else
            vr_ds_xml := vr_ds_xml||'NULL'||ds_character_separador;
          end if;
         
          vr_ds_xml := vr_ds_xml||vr_tab_agendto(vr_index_agendto).dsorigem||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).dshistor||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).idseqttl||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).prorecid||ds_character_separador||
                                  vr_tab_agendto(vr_index_agendto).cdctrlcs||ds_character_separador;    
                                                                    
          insert into tbgen_batch_relatorio_wrk(CDCOOPER
                                               ,CDPROGRAMA
                                               ,DSRELATORIO
                                               ,DTMVTOLT
                                               ,CDAGENCI
                                               ,DSCHAVE
                                               ,NRDCONTA
                                               ,DSXML) values (pr_cdcooper
                                                              ,'CRPS509'
                                                              ,NULL
                                                              ,vr_dtmvtolt
                                                              ,vr_tab_agendto(vr_index_agendto).cdagenci
                                                              ,vr_index_agendto
                                                              ,vr_tab_agendto(vr_index_agendto).nrdconta
                                                              ,vr_ds_xml);  
                                                                        
          vr_index_agendto := vr_tab_agendto.next(vr_index_agendto);
        end loop;
        commit; 
        vr_dslog := 'Fim - pc_transf_dados_para_tab_wrk. AGENCIA: ['||pr_cdagenci||']'||
                    ' INPROCES: ['||rw_crapdat.inproces||']'||
                    ' pr_idparale: ['||pr_idparale||']'||
                    ' Qtde Registros: ['||vr_tab_agendto.count()||']';
         
        pc_log_programa(PR_DSTIPLOG     => 'O',
                        PR_CDPROGRAMA   => vr_cdprogra,
                        pr_cdcooper     => pr_cdcooper,
                        pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia => 4,
                        pr_dsmensagem   => vr_dslog,
                        PR_IDPRGLOG     => vr_idlog_ini);
                        
      end pc_transf_dados_para_tab_wrk; 
      
      procedure pc_buscar_qtde_processos is
      begin
         vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRTITULO'
                                                 ,pr_tpregist => 90);

         --Se nao encontrou
         IF vr_dstextab IS NULL THEN
           vr_cdcritic:= 0;
           vr_dscritic := 'Tabela HRTRTITULO nao cadastrada.';
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         --Determinar se é segundo processo
         vr_flsgproc:=  SUBSTR(Upper(vr_dstextab),15,3) = 'SIM';
         
      end pc_buscar_qtde_processos;
      
      procedure pc_popular_pl_table(pr_cdagenci IN PLS_INTEGER) is

        
        cursor cr_agend_wrk is
          select
            tab.cdcooper,
            tab.dscooper,
            tab.nrdconta,
            tab.nmprimtl,
            tab.cdagenci,
            tab.cdtiptra,
            tab.fltiptra,
            tab.dstiptra,
            tab.fltipdoc,
            tab.dstransa,
            tab.vllanaut,
            tab.dttransa,
            tab.hrtransa,
            tab.nrdocmto,
            tab.dslindig,
            tab.dscritic,
            tab.nrdrecid,
            tab.fldebito,
            tab.dsorigem,
            tab.dshistor,
            tab.idseqttl,
            tab.prorecid,
            tab.cdctrlcs,
            tab.indexador
          from ( 
          select 
            CDAGENCI,
            NRDCONTA,
            DSCHAVE as indexador, 
            substr(dsxml,instr(dsxml,ds_character_separador,1,1)  +1,instr(dsxml,ds_character_separador,1,2) -instr(dsxml,ds_character_separador,1,1)-1)  cdcooper,
            substr(dsxml,instr(dsxml,ds_character_separador,1,2)  +1,instr(dsxml,ds_character_separador,1,3) -instr(dsxml,ds_character_separador,1,2)-1)  dscooper,
            --substr(dsxml,instr(dsxml,ds_character_separador,1,3)  +1,instr(dsxml,ds_character_separador,1,4) -instr(dsxml,ds_character_separador,1,3)-1)  nrdconta,
            substr(dsxml,instr(dsxml,ds_character_separador,1,4)  +1,instr(dsxml,ds_character_separador,1,5) -instr(dsxml,ds_character_separador,1,4)-1)  nmprimtl,
            --substr(dsxml,instr(dsxml,ds_character_separador,1,5)  +1,instr(dsxml,ds_character_separador,1,6) -instr(dsxml,ds_character_separador,1,5)-1)  cdagenci,
            substr(dsxml,instr(dsxml,ds_character_separador,1,6)  +1,instr(dsxml,ds_character_separador,1,7) -instr(dsxml,ds_character_separador,1,6)-1)  cdtiptra,
            substr(dsxml,instr(dsxml,ds_character_separador,1,7)  +1,instr(dsxml,ds_character_separador,1,8) -instr(dsxml,ds_character_separador,1,7)-1)  fltiptra,
            substr(dsxml,instr(dsxml,ds_character_separador,1,8)  +1,instr(dsxml,ds_character_separador,1,9) -instr(dsxml,ds_character_separador,1,8)-1)  dstiptra,
            substr(dsxml,instr(dsxml,ds_character_separador,1,9)  +1,instr(dsxml,ds_character_separador,1,10)-instr(dsxml,ds_character_separador,1,9)-1)  fltipdoc,
            substr(dsxml,instr(dsxml,ds_character_separador,1,10) +1,instr(dsxml,ds_character_separador,1,11)-instr(dsxml,ds_character_separador,1,10)-1) dstransa,
            substr(dsxml,instr(dsxml,ds_character_separador,1,11) +1,instr(dsxml,ds_character_separador,1,12)-instr(dsxml,ds_character_separador,1,11)-1) vllanaut,
            substr(dsxml,instr(dsxml,ds_character_separador,1,12) +1,instr(dsxml,ds_character_separador,1,13)-instr(dsxml,ds_character_separador,1,12)-1) dttransa,
            substr(dsxml,instr(dsxml,ds_character_separador,1,13) +1,instr(dsxml,ds_character_separador,1,14)-instr(dsxml,ds_character_separador,1,13)-1) hrtransa,
            substr(dsxml,instr(dsxml,ds_character_separador,1,14) +1,instr(dsxml,ds_character_separador,1,15)-instr(dsxml,ds_character_separador,1,14)-1) nrdocmto,
            substr(dsxml,instr(dsxml,ds_character_separador,1,15) +1,instr(dsxml,ds_character_separador,1,16)-instr(dsxml,ds_character_separador,1,15)-1) dslindig,
            substr(dsxml,instr(dsxml,ds_character_separador,1,16) +1,instr(dsxml,ds_character_separador,1,17)-instr(dsxml,ds_character_separador,1,16)-1) dscritic,
            substr(dsxml,instr(dsxml,ds_character_separador,1,17) +1,instr(dsxml,ds_character_separador,1,18)-instr(dsxml,ds_character_separador,1,17)-1) nrdrecid,
            substr(dsxml,instr(dsxml,ds_character_separador,1,18) +1,instr(dsxml,ds_character_separador,1,19)-instr(dsxml,ds_character_separador,1,18)-1) fldebito,
            substr(dsxml,instr(dsxml,ds_character_separador,1,19) +1,instr(dsxml,ds_character_separador,1,20)-instr(dsxml,ds_character_separador,1,19)-1) dsorigem,
            substr(dsxml,instr(dsxml,ds_character_separador,1,20) +1,instr(dsxml,ds_character_separador,1,21)-instr(dsxml,ds_character_separador,1,20)-1) dshistor,
            substr(dsxml,instr(dsxml,ds_character_separador,1,21) +1,instr(dsxml,ds_character_separador,1,22)-instr(dsxml,ds_character_separador,1,21)-1) idseqttl,
            substr(dsxml,instr(dsxml,ds_character_separador,1,22) +1,instr(dsxml,ds_character_separador,1,23)-instr(dsxml,ds_character_separador,1,22)-1) prorecid,
            substr(dsxml,instr(dsxml,ds_character_separador,1,23) +1,instr(dsxml,ds_character_separador,1,24)-instr(dsxml,ds_character_separador,1,23)-1) cdctrlcs
          from (select 
                  CDAGENCI,
                  NRDCONTA,
                  DSCHAVE,
                  dbms_lob.substr(dsxml,4000,1) dsxml
                from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper   = pr_cdcooper
                  and wrk.cdprograma = 'CRPS509'
                  and wrk.dtmvtolt   = vr_dtmvtolt
                  and wrk.dschave   != 'CRAPLOT'
                  and wrk.cdagenci   = decode(pr_cdagenci,cd_todas_agencias,wrk.cdagenci,pr_cdagenci)
                order by CDAGENCI) ) tab; 
      begin
        vr_nm_procedure := 'pc_popular_pl_table';
        FOR rr_agend_wrk IN cr_agend_wrk LOOP
        
          vr_tab_agendto(rr_agend_wrk.indexador).cdcooper := rr_agend_wrk.cdcooper; 
          vr_tab_agendto(rr_agend_wrk.indexador).dscooper := rr_agend_wrk.dscooper;
          vr_tab_agendto(rr_agend_wrk.indexador).nrdconta := rr_agend_wrk.nrdconta;
          vr_tab_agendto(rr_agend_wrk.indexador).nmprimtl := rr_agend_wrk.nmprimtl;
          vr_tab_agendto(rr_agend_wrk.indexador).cdagenci := rr_agend_wrk.cdagenci;
          vr_tab_agendto(rr_agend_wrk.indexador).cdtiptra := rr_agend_wrk.cdtiptra;

          IF rr_agend_wrk.fltiptra = 'TRUE' THEN
            vr_tab_agendto(rr_agend_wrk.indexador).fltiptra := true;
          elsif rr_agend_wrk.fltiptra = 'FALSE' THEN
            vr_tab_agendto(rr_agend_wrk.indexador).fltiptra := false;
          else  
            vr_tab_agendto(rr_agend_wrk.indexador).fltiptra := null;
          end if;
            
          vr_tab_agendto(rr_agend_wrk.indexador).dstiptra := rr_agend_wrk.dstiptra;
          
          IF rr_agend_wrk.fltipdoc = 'TRUE' THEN
            vr_tab_agendto(rr_agend_wrk.indexador).fltipdoc := true;
          elsif rr_agend_wrk.fltipdoc = 'FALSE' THEN
            vr_tab_agendto(rr_agend_wrk.indexador).fltipdoc := false;
          else
            vr_tab_agendto(rr_agend_wrk.indexador).fltipdoc := null;
          END IF;
          
          vr_tab_agendto(rr_agend_wrk.indexador).dstransa := rr_agend_wrk.dstransa;
          vr_tab_agendto(rr_agend_wrk.indexador).vllanaut := rr_agend_wrk.vllanaut;
          vr_tab_agendto(rr_agend_wrk.indexador).dttransa := rr_agend_wrk.dttransa;
          vr_tab_agendto(rr_agend_wrk.indexador).hrtransa := rr_agend_wrk.hrtransa;
          vr_tab_agendto(rr_agend_wrk.indexador).nrdocmto := rr_agend_wrk.nrdocmto;
          vr_tab_agendto(rr_agend_wrk.indexador).dslindig := rr_agend_wrk.dslindig;
          vr_tab_agendto(rr_agend_wrk.indexador).dscritic := rr_agend_wrk.dscritic;
          vr_tab_agendto(rr_agend_wrk.indexador).nrdrecid := rr_agend_wrk.nrdrecid;
          
          if rr_agend_wrk.fldebito = 'TRUE' then 
            vr_tab_agendto(rr_agend_wrk.indexador).fldebito := true;
          elsif rr_agend_wrk.fldebito = 'FALSE' then 
            vr_tab_agendto(rr_agend_wrk.indexador).fldebito := false;
          else
            vr_tab_agendto(rr_agend_wrk.indexador).fldebito := null;
          end if;
          vr_tab_agendto(rr_agend_wrk.indexador).dsorigem := rr_agend_wrk.dsorigem;
          vr_tab_agendto(rr_agend_wrk.indexador).idseqttl := rr_agend_wrk.idseqttl;
          vr_tab_agendto(rr_agend_wrk.indexador).prorecid := rr_agend_wrk.prorecid;
          vr_tab_agendto(rr_agend_wrk.indexador).dshistor := rr_agend_wrk.dshistor;
          vr_tab_agendto(rr_agend_wrk.indexador).cdctrlcs := rr_agend_wrk.cdctrlcs;
        
        END LOOP rr_agend_wrk;
        
        
      end pc_popular_pl_table;
      
      procedure pc_criar_jobs is
         vr_dsplsql       varchar2(4000); 
         
      begin
        vr_nm_procedure := 'pc_criar_jobs'; 
        vr_idparale := gene0001.fn_gera_id_paralelo;
        -- Se houver algum erro, vr_idparale será 0 (Zero)
        IF vr_idparale = 0 THEN
           -- Levantar exceção
           vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
          RAISE vr_exc_saida;
        END IF;
        -- Verifica se algum job paralelo executou com erro
        vr_qterro := 0;
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => vr_dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);

        vr_dslog := '[BATCH] pc_criar_jobs - Inicio AGENCIA: ['||pr_cdagenci||']'||
                    ' INPROCES: ['||rw_crapdat.inproces||']'|| 
                    ' vr_idparale: ['||vr_idparale||']'||
                    ' Qtde Erro: ['||vr_qterro||']' ;                                                      
                    
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => vr_dslog,
                        PR_IDPRGLOG           => vr_idlog_ini);         
                                                       
        for reg_crapage in cr_crapage(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_dtmvtolt => vr_dtmvtolt
                                     ,pr_cdprogra => vr_cdprogra
                                     ,pr_qterro   => vr_qterro) loop
          
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := SUBSTR(vr_cdprogra,1,9) ||'_'|| reg_crapage.cdagenci || '$';  -- SUBSTR ADD em 30/10/2018.
    
          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(reg_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_dscritic);
                                
          -- Testar saida com erro
          if vr_dscritic is not null then
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;    
          
          vr_dsplsql := 'declare'            ||chr(13)||
                        ' wpr_stprogra  binary_integer; '||chr(13)||
                        ' wpr_infimsol  binary_integer; '||chr(13)||
                        ' wpr_cdcritic  number(5); '     ||chr(13)||
                        ' wpr_dscritic  varchar2(4000); '||chr(13)||
                        ' begin '||chr(13)||
                        '   cecred.PC_CRPS509('||pr_cdcooper||','||chr(13)||
                                                 pr_flgresta||','||chr(13)||
                                                 reg_crapage.cdagenci||','||chr(13)||
                                                 vr_idparale||','||chr(13)||
                                                 'wpr_stprogra,' ||chr(13)||
                                                 'wpr_infimsol,' ||chr(13)||
                                                 'wpr_cdcritic,' ||chr(13)||
                                                 'wpr_dscritic,' ||chr(13)||
                                                 ''''||pr_inpriori||'''' ||
                                                 ');'||chr(13)||
                        'end;';-- pr_inpriori ADD em 30/10/2018.
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_dscritic);    
                             
       -- Testar saida com erro
       if vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
       end if;
       
       -- Chama rotina que irá pausar este processo controlador
       -- caso tenhamos excedido a quantidade de JOBS em execuçao
       gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs 
                                   ,pr_des_erro => vr_dscritic);
       -- Testar saida com erro
       if  vr_dscritic is not null then 
         -- Levantar exceçao
         raise vr_exc_saida;
       end if;   

       end loop reg_crapage; 
       
       pc_log_programa(PR_DSTIPLOG           => 'O',
                       PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                       pr_cdcooper           => pr_cdcooper,
                       pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       pr_tpocorrencia       => 4,
                       pr_dsmensagem         => '[BATCH] pc_criar_jobs - FIM cursor cr_crapage. AGENCIA: '||pr_cdagenci||' INPROCES: ['||rw_crapdat.inproces||']',
                       PR_IDPRGLOG           => vr_idlog_ini);                       
       
     end pc_criar_jobs;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps509
     ---------------------------------------
     BEGIN

      --Atribuir o nome do programa que está executando
       IF pr_inpriori = 'S' THEN
         vr_cdprogra:= 'CRPS509_PRIORI';
       ELSE
		 vr_cdprogra:= 'CRPS509';
       END IF;

       -- Quando a tela DEBNET (progress) chamar esta procedure, nao deve contar a execucao.	   
       IF pr_inpriori <> 'T' THEN	   
         -- Verifica quantidade de execuções do programa durante o dia no Debitador Único
         gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper   => pr_cdcooper   --Cooperativa
                                                     ,pr_cdprocesso => 'PC_'||vr_cdprogra --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)                              
                                                     ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica  
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
       END IF;

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS509'
                                 ,pr_action => NULL);
                                 
       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
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

       --Quando pr_idparale for 0, quer dizer q a chamada da PC_CRPS509, nao foi feita via job.
       --é necessário verificar quantos jobs sao necessário criar.
       IF pr_idparale = 0 THEN
                 
                                               
         --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
         pc_log_programa(pr_dstiplog   => 'I',    
                         pr_cdprograma => vr_cdprogra,           
                         pr_cdcooper   => pr_cdcooper, 
                         pr_tpexecucao => 1, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_idprglog   => vr_idlog_ini); --Out.
         
         /*Popular as variaveis por cooperativa.
         vr_dtmvtolt = data do movimento atual
         vr_dtmvtopr = proxima data de movimento
         vr_dtmvtoan = data do movimento anterior
         vr_qtdiaute = Atribuir a quantidade de dias uteis
         vr_dtultdia = data do ultimo dia do mes corrente 
         vr_dtmvtopg = Determinar a data do proximo pagamento */
         pc_buscar_dados_cooper;
         --Validar o codigo da cooperativa que foi parametrizado.
         pc_validar_cooperativa;     

         --Este delete eh colocado aqui tbem pois a rotina pode ter sido interrompida.
         pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                            ,pr_tipo_delete => 'INDEX');
                            
         pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                            ,pr_tipo_delete => 'LOTE'); 
                            
         -- Quando a tela DEBNET (progress) chamar esta procedure, nao deve contar a execucao.	   
         IF pr_inpriori <> 'T' THEN	  
           /* Procedimento para verificar/controlar a execução da DEBNET e DEBSIC */
           SICR0001.pc_controle_exec_deb ( pr_cdcooper  => pr_cdcooper         --> Código da coopertiva
                                          ,pr_cdtipope  => 'I'                 --> Tipo de operacao I-incrementar e C-Consultar
                                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento                                
                                          ,pr_cdprogra  => vr_cdprogra         --> Codigo do programa                                  
                                          ,pr_flultexe  => vr_flultexe         --> Retorna se é a ultima execução do procedimento [OUT]
                                          ,pr_qtdexec   => vr_qtdexec          --> Retorna a quantidade [OUT]
                                          ,pr_cdcritic  => vr_cdcritic         --> Codigo da critica de erro [OUT]
                                          ,pr_dscritic  => vr_dscritic);       --> descrição do erro se ocorrer  [OUT]

           IF nvl(vr_cdcritic,0) > 0 OR
              TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida; 
           END IF;             
         END IF; --pr_inpriori <> 'T'
		 
         --Nao retirar este commit, nem para testar.
         COMMIT;
/*
       -- Valido somente para InternetBank, por isto pac 90
       PAGA0001.pc_atualiza_trans_nao_efetiv (pr_cdcooper => pr_cdcooper   --Código da Cooperativa
                                             ,pr_nrdconta => 0             --Numero da Conta
                                             ,pr_cdagenci => 90            --Código da Agencia
                                             ,pr_dtmvtolt => vr_dtmvtopg   --Data Proximo Pagamento
                                             ,pr_dstransa => vr_dstransa   --Msg Transação
                                             ,pr_cdcritic => vr_cdcritic   --Codigo erro
                                             ,pr_dscritic => vr_dscritic); --Descricao erro
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
*/
         --Buscar a quantidade de jobs simultaneos para a cooperativa.
         vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper 
                                                      ,pr_cdprogra => SUBSTR(vr_cdprogra,1,7)); -- 30/10/2018.
       
         if (fn_primeira_execucao and fn_existem_jobs) then
           pc_resetar_sequencia;
         end if;
          
         --Este if determina se é para usar do paralelismo 
         if (vr_qtdjobs  > 0 and pr_cdagenci  = 0) then 
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra,
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => '[BATCH] Inicio - pc_obtem_agend_debitos. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces,
                           PR_IDPRGLOG     => vr_idlog_ini); 
           
           --Obter Agendamentos de Debito      
           PAGA0001.pc_obtem_agend_debitos(pr_cdcooper    => pr_cdcooper         --Cooperativa
                                          ,pr_dtmvtopg    => vr_dtmvtopg         --Data de pagamento
                                          ,pr_inproces    => rw_crapdat.inproces --Indicador processo
                                          ,pr_cdprogra    => vr_cdprogra         --Nome do programa
                                          ,pr_inpriori    => pr_inpriori         --Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, "T"=todos) -- 30/10/2018.
                                          ,pr_tab_agendto => vr_tab_agendto      --tabela de agendamento
                                          ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                          ,pr_dscritic    => vr_dscritic);       --Descricao da Critica
           
           vr_dslog := '[BATCH] Fim - pc_obtem_agend_debitos. AGENCIA: ['||cd_todas_agencias||']'||
                     ' INPROCES: ['||rw_crapdat.inproces||']'||
                     ' pr_idparale: ['||pr_idparale||']'||
                     ' pr_inpriori: ['||pr_inpriori||']'|| -- 30/10/2018
                     ' Qtde Registros: ['||vr_tab_agendto.count()||']';
         
          pc_log_programa(PR_DSTIPLOG     => 'O',
                          PR_CDPROGRAMA   => vr_cdprogra,
                          pr_cdcooper     => pr_cdcooper,
                          pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia => 4,
                          pr_dsmensagem   => vr_dslog,
                          PR_IDPRGLOG     => vr_idlog_ini); 
                         
           if vr_tab_agendto.count() > 0 then
             pc_transf_dados_para_tab_wrk;
             --return;
             vr_sequencia_lote:= PAGA0001.fn_seq_parale_craplcm;
             pc_criar_jobs;   
             --Chama rotina de aguardo agora passando 0, para esperar
             --até que todos os Jobs tenha finalizado seu processamento
             gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                         ,pr_qtdproce => 0
                                         ,pr_des_erro => vr_dscritic);
                                  
             -- Testar saida com erro
             if  vr_dscritic is not null then 
               -- Levantar exceçao
               raise vr_exc_saida;
             end if;
           else
         vr_cdcritic:= 0;
             vr_dscritic := 'Não existem agendamentos para a data: '||vr_dtmvtopg||' e a cooperativa: '||pr_cdcooper;
             raise vr_exc_saida;
           end if;  
             
         else
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra,
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => '[BATCH-NOP] Inicio - pc_obtem_agend_debitos. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces,
                           PR_IDPRGLOG     => vr_idlog_ini); 
       --Obter Agendamentos de Debito
       PAGA0001.pc_obtem_agend_debitos (pr_cdcooper    => pr_cdcooper         --Cooperativa
                                       ,pr_dtmvtopg    => vr_dtmvtopg         --Data de pagamento
                                       ,pr_inproces    => rw_crapdat.inproces --Indicador processo
                                       ,pr_cdprogra    => vr_cdprogra         --Nome do programa
																			 ,pr_inpriori    => pr_inpriori         --Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, "T"=todos) 
                                       ,pr_tab_agendto => vr_tab_agendto      --tabela de agendamento
                                       ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                       ,pr_dscritic    => vr_dscritic);       --Descricao da Critica

           vr_dslog := '[BATCH-NOP] Fim - pc_obtem_agend_debitos. AGENCIA: ['||cd_todas_agencias||']'||
                       ' INPROCES: ['||rw_crapdat.inproces||']'||
                       ' pr_idparale: ['||pr_idparale||']'||
                       ' pr_inpriori: ['||pr_inpriori||']'|| -- 30/10/2018
                       ' Qtde Registros: ['||vr_tab_agendto.count()||']';
         
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra,
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => vr_dslog,
                           PR_IDPRGLOG     => vr_idlog_ini); 
                         
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
           --Nao existe o paralelismo, vai executar de forma serial.
           vr_tpexecucao := 1;
           
           --Buscar O FLAG vr_flsgproc
           pc_buscar_qtde_processos;

       --Efetuar Debitos
           vr_dslog:= '[BATCH-NOP] INICIO pc_efetua_debitos sem paralelismo. Agencia: ['||pr_cdagenci||']'||
                      ' vr_tpexecucao: ['||vr_tpexecucao||']'||
                      ' INPROCES: ['||rw_crapdat.inproces||']'||
                      ' vr_flsgproc: ['||vr_flsgproc_char||']'||
                      ' vr_dtmvtopg: ['||to_char(vr_dtmvtopg,'dd/mm/yyyy')||']'||
                      ' Qtde Registros: ['||vr_tab_agendto.COUNT()||']'||
                      ' vr_tpexecucao: ['||vr_tpexecucao||']';
                                
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => vr_dslog,
                           PR_IDPRGLOG     => vr_idlog_ini); 
                                        
       PAGA0001.pc_efetua_debitos (pr_cdcooper    => pr_cdcooper         --Cooperativa
                                  ,pr_tab_agendto => vr_tab_agendto      --tabela de agendamento
                                  ,pr_cdprogra    => vr_cdprogra         --Codigo programa
                                  ,pr_dtmvtopg    => vr_dtmvtopg         --Data Pagamento
                                  ,pr_inproces    => rw_crapdat.inproces --Indicador processo
                                  ,pr_flsgproc    => vr_flsgproc         --Flag segundo processamento
                                  ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                  ,pr_dscritic    => vr_dscritic);       --Descricao da critica;
           
           vr_dslog:= '[BATCH-NOP] FIM pc_efetua_debitos. sem paralelismo Agencia: ['||pr_cdagenci||']'||
                    ' vr_tpexecucao: ['||vr_tpexecucao||']'||
                    ' INPROCES: ['||rw_crapdat.inproces||']'||
                    ' Qtde Registros: ['||vr_tab_agendto.COUNT()||']'||
                    ' vr_tpexecucao: ['||vr_tpexecucao||']'||
                    ' vr_flsgproc: ['||vr_flsgproc_char||']'||
                    ' vr_dtmvtopg: ['||to_char(vr_dtmvtopg,'dd/mm/yyyy')||']'||
                    ' Critica: ['||vr_cdcritic||' - '||vr_dscritic||']';
           
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => vr_dslog,
                           PR_IDPRGLOG     => vr_idlog_ini); 
           
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
         
           --End IF da verificacao se existe  paralelismo ou nao.
         end if;
       
         --Fim do IF da execucao da rotina batch. Pode ter tido paralelismo ou nao.
       ELSE
         --Se caiu aqui deste lado eh pq pr_idparale > 0, logo este codigo abaixo deve ser executado por um job paralelo.
         if pr_cdagenci <> 0 then
           vr_tpexecucao := 2;
         else
           vr_tpexecucao := 1;
         end if;
         --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
         pc_log_programa(pr_dstiplog   => 'I',    
                         pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                         pr_cdcooper   => pr_cdcooper, 
                         pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_idprglog   => vr_idlog_ini); 
        
         --Buscar os dados da Cooperativa. Executar este procedure aqui tbem. :{
         pc_buscar_dados_cooper;                 
         -- Grava controle de batch por agência
         gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                         ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                         ,pr_dtmvtolt    => vr_dtmvtolt               -- Data de Movimento
                                         ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                         ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                         ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                         ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                         ,pr_idcontrole  => vr_idcontrole             -- ID de Controle [OUT]
                                         ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                         ,pr_dscritic    => vr_dscritic              
                                         );   
         -- Testar saida com erro
         if vr_dscritic is not null then 
           -- Levantar exceçao
           raise vr_exc_saida;
         end if; 
                     

         --É necessario ter este if, pois a cooperativa, pode nao ter paralelismo.
         vr_dslog := '[JOB] Início - pc_popular_pl_table. AGENCIA: [' ||pr_cdagenci||']'||
                       ' INPROCES: ['||rw_crapdat.inproces||']'||
                       ' vr_dtmvtolt: ['||to_char(vr_dtmvtolt,'dd/mm/rrrr')||']';
           
         -- Grava LOG de ocorrência inicial do cursor cr_craprpp
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => vr_dslog,
                         PR_IDPRGLOG     => vr_idlog_ini);
                            

  
                                       
         pc_popular_pl_table(pr_cdagenci => pr_cdagenci);
           
        -- Grava LOG de ocorrência final do cursor cr_craprpp
         vr_dslog := '[JOB] Fim - pc_popular_pl_table. AGENCIA: ['||pr_cdagenci||']'||
                     ' pr_idparale: ['||pr_idparale||']'||
                     ' INPROCES: ['||rw_crapdat.inproces||']'||
                     ' Qtde Reg.: ['||vr_tab_agendto.count()||']';
                       
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => vr_dslog,
                         PR_IDPRGLOG     => vr_idlog_ini); 
         
         --Buscar O FLAG vr_flsgproc
         pc_buscar_qtde_processos; 
                           
         if vr_tab_agendto.count() > 0 then
           
           if vr_flsgproc then
             vr_flsgproc_char := 'S';
           else
             vr_flsgproc_char := 'N';
           end if;
           
           --Efetuar Debitos
           vr_dslog:= '[JOB] INICIO pc_efetua_debitos_paralelo. Agencia: ['||pr_cdagenci||']'||
                      ' vr_tpexecucao: ['||vr_tpexecucao||']'||
                      ' INPROCES: ['||rw_crapdat.inproces||']'||
                      ' vr_flsgproc: ['||vr_flsgproc_char||']'||
                      ' vr_dtmvtopg: ['||to_char(vr_dtmvtopg,'dd/mm/yyyy')||']'||
                      ' Qtde Registros: ['||vr_tab_agendto.COUNT()||']'||
                      ' vr_tpexecucao: ['||vr_tpexecucao||']';
                              
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => vr_dslog,
                           PR_IDPRGLOG     => vr_idlog_ini); 
                                      
                                  
           PAGA0001.pc_efetua_debitos_paralelo(pr_cdcooper    => pr_cdcooper         --Cooperativa
                                            ,pr_tab_agendto => vr_tab_agendto      --tabela de agendamento
                                            ,pr_cdprogra    => vr_cdprogra         --Codigo programa
                                            ,pr_dtmvtopg    => vr_dtmvtopg         --Data Pagamento
                                            ,pr_inproces    => rw_crapdat.inproces --Indicador processo
                                            ,pr_flsgproc    => vr_flsgproc         --Flag segundo processamento
                                            ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                            ,pr_dscritic    => vr_dscritic);       --Descricao da critica;
         
                    
           
           vr_dslog := '[JOB] FIM pc_efetua_debitos_paralelo. Agencia: ['||pr_cdagenci||']'||
                    ' vr_tpexecucao: ['||vr_tpexecucao||']'||
                    ' INPROCES: ['||rw_crapdat.inproces||']'||
                    ' Qtde Registros: ['||vr_tab_agendto.COUNT()||']'||
                    ' vr_tpexecucao: ['||vr_tpexecucao||']'||
                    ' vr_flsgproc: ['||vr_flsgproc_char||']'||
                    ' vr_dtmvtopg: ['||to_char(vr_dtmvtopg,'dd/mm/yyyy')||']'||
                    ' Critica: ['||vr_cdcritic||' - '||vr_dscritic||']';
         
           pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => vr_dslog,
                           PR_IDPRGLOG     => vr_idlog_ini); 
         
           --Se ocorreu erro
           IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
           END IF;
           
           --Apos efetuar as transações é necessário limpar a tabela temporaria conforme a agencia que foi executada.
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI,
                               pr_tipo_delete => 'INDEX');
           --Nao limpar os registros de lotes!!!
           --Com os dados da pl-table, transferir as informações que estao na pl-table vr_tab_agendto para a tabela wrk.
           pc_transf_dados_para_tab_wrk;
           
           --Fim Se tiver dados na Pl-table.
         end if;
         --Fim da execucao dos Jobs Paralelos.
       end if;
         
       --Commit para garantir o controle de execucao do programa
       COMMIT;
            
       IF pr_idparale = 0 THEN
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => '[BATCH] Início - pc_acertar_lotes. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces,
                         PR_IDPRGLOG     => vr_idlog_ini); 
         
         pc_acertar_lotes;
         
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => '[BATCH] Fim - pc_acertar_lotes. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces,
                         PR_IDPRGLOG     => vr_idlog_ini); 
       
       -- Proj. Pagamento de Titulos - Gera registro de Retorno
       IF vr_flultexe = 1 THEN -- Apenas na ultima execução do processo
          PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => pr_cdcooper
                                          , pr_dtmvtolt => vr_dtmvtopg
                                          , pr_idorigem => 3    -- Ayllos
                                          , pr_cdoperad => '1'
                                          , pr_cdcritic => vr_cdcritic
                                          , pr_dscritic => vr_dscritic );
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_saida;
          END IF;
       END IF;              
       
         --Processo On-line.
       IF rw_crapdat.inproces = 1 THEN
         UPDATE craplau lau
            SET lau.insitlau = 4
               ,lau.dtdebito = lau.dtmvtopg 
               ,lau.cdcritic = 999
          WHERE lau.cdcooper = pr_cdcooper
            AND lau.dsorigem IN ('INTERNET','TAA')
            AND lau.insitlau = 1
              AND lau.dtmvtopg BETWEEN vr_dtmvtoan - 7 AND vr_dtmvtoan --Data movimento anterior.
            AND lau.cdtiptra <> 4; --TED
       END IF;
           
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => '[BATCH] Início - pc_popular_pl_table. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces,
                         PR_IDPRGLOG     => vr_idlog_ini); 

         --Popula a pl-table [vr_tab_agendto] com todos os dados gravados na tabela wrk.
         pc_popular_pl_table(pr_cdagenci => cd_todas_agencias);
   
         pc_log_programa(PR_DSTIPLOG     => 'O',
                           PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                           pr_cdcooper     => pr_cdcooper,
                           pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_tpocorrencia => 4,
                           pr_dsmensagem   => '[BATCH] Fim - pc_popular_pl_table. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces,
                           PR_IDPRGLOG     => vr_idlog_ini); 
        
         vr_dslog := '[BATCH] Início - pc_gera_relatorio. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces||
                     ' Qtde Registros: '||vr_tab_agendto.count(); 
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => vr_dslog,
                         PR_IDPRGLOG     => vr_idlog_ini);                         

       --Gerar Relatorio
       PAGA0001.pc_gera_relatorio (pr_cdcooper    => 0              --Todas Cooperativas
                                  ,pr_cdprogra    => SUBSTR(vr_cdprogra,1,7)    --Codigo Programa
                                  ,pr_tab_agendto => vr_tab_agendto --Tabela de memoria c/ agendamentos
                                  ,pr_rw_crapdat  => rw_crapdat     --Registro de Datas
                                  ,pr_cdcritic    => vr_cdcritic    --Codigo da Critica
                                  ,pr_dscritic    => vr_dscritic);  --Descricao da critica;
         
         vr_dslog := '[BATCH] Fim - pc_gera_relatorio. AGENCIA: '||cd_todas_agencias||' - INPROCES: '||rw_crapdat.inproces||
                     ' Qtde Registros: ['||vr_tab_agendto.count()||']';
                     
         pc_log_programa(PR_DSTIPLOG     => 'O',
                         PR_CDPROGRAMA   => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper     => pr_cdcooper,
                         pr_tpexecucao   => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia => 4,
                         pr_dsmensagem   => vr_dslog,
                         PR_IDPRGLOG     => vr_idlog_ini); 
         
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       --Zerar tabelas de memoria auxiliar
         
         pc_limpa_tabela_wrk(pr_CDAGENCI => cd_todas_agencias
                            ,pr_tipo_delete => 'INDEX');
                            
         pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                            ,pr_tipo_delete => 'LOTE');
         
         pc_limpa_pl_table;
         
           --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
           pc_log_programa(pr_dstiplog   => 'F',    
                           pr_cdprograma => vr_cdprogra,           
                           pr_cdcooper   => pr_cdcooper, 
                           pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           pr_idprglog   => vr_idlog_ini,
                           pr_flgsucesso => 1);                 
       
       else
         --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
         pc_log_programa(pr_dstiplog   => 'F',    
                         pr_cdprograma => vr_cdprogra,           
                         pr_cdcooper   => pr_cdcooper, 
                         pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_idprglog   => vr_idlog_ini,
                         pr_flgsucesso => 1);  
         -- Atualiza finalização do batch na tabela de controle 
         gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => vr_dscritic);  
                                           
          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                      ,pr_des_erro => vr_dscritic);
       END IF;

       --Salvar informacoes no banco de dados

       COMMIT;

       
     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descrição
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         -- Se foi gerada critica para envio ao log
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;
         --Limpar variaveis retorno
         pr_cdcritic:= NULL;
         pr_dscritic:= NULL;
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         -- Efetuar commit pois gravaremos o que foi processo até então

         COMMIT;
         if pr_cdagenci = 0 then
           --Quando o erro ocorrer na rotina principal, limpar todas as agencias.
           pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                              ,pr_tipo_delete => 'INDEX');
            
           pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                              ,pr_tipo_delete => 'LOTE');                               
           
         else
         
           --Quando o erro ocorrer na agencia especifica, limpar somente esta agencia.
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI
                              ,pr_tipo_delete => 'INDEX');
           
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI
                              ,pr_tipo_delete => 'LOTE');                               
           
         end if;              
         --Importantisso. Nunca  tirar esta condicao e o seu conteudo.
         --Deve-se encerrar o processo paralelo qdo houver algum  erro,  senao fica em loop eterno.
         if pr_idparale <> 0 then                
            -- Grava LOG de Erro
            pc_log_programa(PR_DSTIPLOG           => 'E',
                            PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 2,
                            pr_dsmensagem         => 'vr_exc_saida - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                     'pr_dscritic:'||pr_dscritic,
                            PR_IDPRGLOG           => vr_idlog_ini);  

            --Grava data fim para o JOB na tabela de LOG 
            pc_log_programa(pr_dstiplog   => 'F',    
                            pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini,
                            pr_flgsucesso => 0);  
                              
           -- Encerrar o job do processamento paralelo dessa agência
           gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                       ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                       ,pr_des_erro => vr_dscritic);
         end if;
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
         
         --Zerar tabela de memoria auxiliar
         if pr_cdagenci = 0 then
           --Quando o erro ocorrer na rotina principal, limpar todas as agencias.
           pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                              ,pr_tipo_delete => 'INDEX');
            
           pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                              ,pr_tipo_delete => 'LOTE');                               
           
         else
         
           --Quando o erro ocorrer na agencia especifica, limpar somente esta agencia.
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI
                              ,pr_tipo_delete => 'INDEX');
           
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI
                              ,pr_tipo_delete => 'LOTE');                               
           
         end if;

         --Importantisso. Nunca  tirar esta condicao e o seu conteudo.
         --Deve-se encerrar o processo paralelo qdo houver algum  erro,  senao fica em loop eterno.
         if pr_idparale <> 0 then 
            -- Grava LOG de Erro
            vr_dslog := 'EXCEPTION - vr_exc_saida.'||
                     ' pr_cdcritic:'||pr_cdcritic||
                     ' pr_dscritic:'||pr_dscritic||
                     ' Procedure: ['||vr_nm_procedure||']'||
                     ' Agencia  : ['||pr_cdagenci||']' ;               
         pc_log_programa(PR_DSTIPLOG           => 'E',
                         PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                         pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 2,
                         pr_dsmensagem         => vr_dslog,
                         PR_IDPRGLOG           => vr_idlog_ini);

            --Grava data fim para o JOB na tabela de LOG 
            pc_log_programa(pr_dstiplog   => 'F',    
                            pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini,
                            pr_flgsucesso => 0);  
                              
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                        ,pr_des_erro => vr_dscritic);
            COMMIT;
          end if;
         pc_limpa_pl_table;
         COMMIT;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro na procedure pc_crps509. '||sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
         pc_limpa_pl_table;

         if pr_cdagenci = 0 then
           --Quando o erro ocorrer na rotina principal, limpar todas as agencias.
         pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                            ,pr_tipo_delete => 'INDEX');
         
         pc_limpa_tabela_wrk(pr_CDAGENCI    => cd_todas_agencias
                            ,pr_tipo_delete => 'LOTE');                             
 
         else
         
           --Quando o erro ocorrer na agencia especifica, limpar somente esta agencia.
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI
                              ,pr_tipo_delete => 'INDEX');
           
           pc_limpa_tabela_wrk(pr_CDAGENCI    => pr_CDAGENCI
                              ,pr_tipo_delete => 'LOTE');                               

         end if;   
         
         if pr_idparale <> 0 then 
            -- Grava LOG de Erro
            vr_dslog := 'EXCEPTION OTHERS -'||
                     ' pr_cdcritic:'||pr_cdcritic||
                     ' pr_dscritic:'||pr_dscritic||
                     ' Procedure: ['||vr_nm_procedure||']'||
                     ' Agencia  : ['||pr_cdagenci||']' ;               
         pc_log_programa(PR_DSTIPLOG           => 'E',
                         PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                         pr_cdcooper           => pr_cdcooper,
                         pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 2,
                         pr_dsmensagem         => vr_dslog,
                         PR_IDPRGLOG           => vr_idlog_ini);

            --Grava data fim para o JOB na tabela de LOG 
            pc_log_programa(pr_dstiplog   => 'F',    
                            pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini,
                            pr_flgsucesso => 0);  
                              
           -- Encerrar o job do processamento paralelo dessa agência
           gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                       ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                       ,pr_des_erro => vr_dscritic);
         end if;

         COMMIT;
     END;
                                   
   END pc_crps509;
/
