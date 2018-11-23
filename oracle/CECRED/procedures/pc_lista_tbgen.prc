CREATE OR REPLACE PROCEDURE CECRED.pc_lista_tbgen(pr_cdcopprm IN  crapcop.cdcooper%TYPE -- Especifica OU zero e nula vai via crapprm
                                                 ,pr_nrcadeia IN  crapprg.nrsolici%TYPE -- NULL, 0 Lista todas ou especifica
											                        	 ,pr_dtmovime IN DATE                   -- Data de seleção da execução
                        												 ,pr_idatzmed IN VARCHAR2               -- S - Atualiza média de tempo de xecução de programas senão não atualiza média
                        												 ,pr_cdcritic OUT INTEGER
                        												 ,pr_dscritic OUT VARCHAR2
                                   							 )
IS
BEGIN
  /* ......................................................................................
  
  Programa: pc_lista_tbgen
  Sistema : Rotina de Log
  Autor   : Belli/Envolti
  Data    : Maio/2018                   Ultima atualizacao: 01/11/2018  
    
  Dados referentes ao programa:
  
  Frequencia: Disparado pelo JOB JBPRG_LISTA_BATCH de segunda a sabado ás 05:30 da manha
              Caso não aconteceu o termino das cadeias o Job é reagendado com o Job JBPRG_R_LISTA_BAT

  Objetivo: 1) Resumo da execução das cadeias
            2) Detalhes da execução das cadeias
               - Listar os tempos de execução da cadeia
               - Listar os erros das cadeias
               - Listar os logs pendentes a acertos 
  
  Alterações: 06/09/2018 - Ajuste do padrão Decimal/Data
                           (Envolti - Belli - Chamado - REQ0026091)
                           
              20/09/2018 - Usar na GENE0001 PC CONTROLE EXEC a consulta 02, levando em conta se a data de parâmetro
                           for diferente da data do cadastro então nesta data não executou.
                           (Envolti - Belli - Chamado - REQ0027434)
                           
              27/09/2018 - Ajuste coluna "Percentual de diferença entre a execução atual 
                           e a média de execução do relatório resumo por programa.
                           - Padronizar valores inferiores a um segundo
                           - Padronizar demostração  se a quantidade de minutos atual for menor que a quantidade
                             de minutos médio (houve melhora de tempo) a diferença mostrar o percentual como Negativo..
                           (Envolti - Belli - Chamado - REQ0028395)
                           
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - Tratar programa exclusivo retirado da cadeia
                         - Criticas 1066/1067 - Inicio e Termino execução. Não é erro
                         - (Envolti - Belli - Chamado - REQ0029484)
                           
              01/11/2018 - Tratar programa exclusivo retirado da cadeia e não reexecutado
                         - Atualizar lay-out de decimal para minutos.
                         - (Envolti - Belli - Chamado - REQ0032025)
              
  ....................................................................................... */
    
DECLARE
  vr_dtsysdat           DATE;
  vr_nmsistem           crapprm.nmsistem%TYPE := 'CRED';
  vr_cdproexe           tbgen_prglog.cdprograma%TYPE := 'pc_lista_tbgen';
  vr_cdproint           VARCHAR2(100);
  vr_cdcooper           crapcop.cdcooper%TYPE;
  vr_nmrescop           crapcop.nmrescop%TYPE;
  vr_cdmensag           tbgen_prglog_ocorrencia.cdmensagem%TYPE;
  vr_cdprogra           tbgen_prglog.cdprograma%TYPE;
  vr_dtmovime           DATE;
  -- Eliminada vr_dtmvtolt - 09/10/2018 - Chd REQ0029484
  --vr_dtmvtolt           DATE;  
  vr_cdmsgsal           tbgen_prglog_ocorrencia.cdmensagem%TYPE;
  vr_dtretsal           DATE; 
  --        
  vr_dtmvtoan           DATE;
  vr_dtmesant           DATE;
  vr_tpcadeia           crapord.tpcadeia%TYPE;
  vr_dsexclus           VARCHAR2(100);  
  vr_nrordsol           crapord.nrordsol%TYPE;
  vr_qtprogra           NUMBER(4);
  vr_nrsolici           crapord.nrsolici%TYPE;
  vr_cdultpro           tbgen_prglog.cdprograma%TYPE;
  vr_dsulthor           VARCHAR2(4);
  vr_nrcadeia           crapprg.nrsolici%TYPE;
  --
  vr_cdacesso           crapprm.cdacesso%TYPE;   
  vr_dsvlrprm           crapprm.dsvlrprm%TYPE; 
  vr_qtlimver           NUMBER(15); 
  vr_qtlimama           NUMBER(15);
  --
  vr_cdexeexc           NUMBER(4);
  vr_cdexepad           NUMBER(4);  
  vr_cdexcamd           NUMBER(4); -- Execução com tempo acima da media em dia de excesso de movimento
  vr_dthorret           DATE;
  vr_qthorpar           NUMBER(15,5);
  vr_ctsequec           NUMBER(15);      
  vr_qtmeddia           NUMBER(15,5);
  vr_prmeddia           NUMBER(15,5);
  vr_prmvtdia           NUMBER(15,5);
  
  -- Tabela para guardar os registros de erros - desta forma o programa fica bem rapido
  TYPE typ_reg_tbgen_prglog_ocor IS RECORD
         (cdcooper     tbgen_prglog.cdcooper%type
         ,nrsolici     crapord.nrsolici%type
         ,idocorrencia tbgen_prglog_ocorrencia.idocorrencia%type
         ,dsmensagem   tbgen_prglog_ocorrencia.dsmensagem%type
         ,cdprogra     tbgen_prglog.cdprograma%TYPE
         ,idtipo       VARCHAR2 (1)
         ,hrparada     VARCHAR2(10)
         );
  -- Tipos de erros - idtipo          
  -- E - Erros - Erros que retornam aos controladores CRPS359.P e CRPS000.P
  -- P - Pendecias - Erros que retornam aos controladores CRPS359.P e CRPS000.P mas já caracterezidos como apenas alertas
  -- O - Outros erros - Erros que não retornam aos controladores CRPS359.P e CRPS000.P - Exemplo executar Kill nos programas
  -- L - Erros paralelos - Erros que retornam aos controladores CRPS359.P e CRPS000.P mas em forma Paralela
        
  TYPE typ_tab_tbgen_prglog_ocor IS TABLE OF 
                                 typ_reg_tbgen_prglog_ocor 
                                                INDEX BY VARCHAR2(20);
  vr_tab_tbgen_prglog_ocor       typ_tab_tbgen_prglog_ocor;
  vr_index_tbgen_prglog_ocor     NUMBER(20) := 0;  

  -- Tabela para guardar os registros de controle de duração - desta forma o programa fica bem rapido     
  TYPE typ_reg_tbgen_prglog_duracao IS RECORD
         (cdcooper     tbgen_prglog.cdcooper%type
         ,dtexeexc     tbgen_prglog.dhinicio%type
         ,dtexepad     tbgen_prglog.dhinicio%type
         ,cdprogra     tbgen_prglog.cdprograma%TYPE);
           
  TYPE typ_tab_tbgen_prglog_duracao IS TABLE OF 
                                 typ_reg_tbgen_prglog_duracao 
                                                INDEX BY VARCHAR2(20);
  vr_tab_tbgen_prglog_duracao    typ_tab_tbgen_prglog_duracao;
  vr_index_tbgen_prglog_duracao  NUMBER(20) := 0;

  -- Elimina dtmvtolt - 09/10/2018 - Chd REQ0029484
  -- Tabela para guardar as cooperativas que processarão - desta forma o programa fica bem rapido     
  TYPE typ_reg_cooper IS RECORD
         (cdcooper     crapcop.cdcooper%TYPE
         ,nmrescop     crapcop.nmrescop%TYPE
         ,hrultpro     VARCHAR2(4)
         ,dtmvtoan     crapdat.dtmvtoan%TYPE);
  TYPE typ_tab_cooper IS TABLE OF 
                                 typ_reg_cooper 
                                                INDEX BY VARCHAR2(20);
  vr_tab_cooper    typ_tab_cooper;
  vr_index_cooper  NUMBER(20) := 0;
  --
  -- Selecionar programas das cadeias
  CURSOR cr_crapprg  IS
  SELECT t2.*
  FROM   crapprg t2
  WHERE  t2.cdcooper  = vr_cdcooper
  -- AND    T2.cdprogra  = vr_cdprogra
  AND    t2.nmsistem  = vr_nmsistem
  AND    t2.inlibprg  = 1 -- 1=lib, 2=bloq e 3=em teste
  AND    t2.nrsolici  = vr_nrsolici
  ORDER BY T2.nrordprg;
  rw_crapprg cr_crapprg%ROWTYPE;
  --
  -- Variaveis para tratar erro do programa
  vr_exc_erro_tratado   EXCEPTION;
  vr_exc_montada        EXCEPTION;
  vr_exc_others         EXCEPTION;
  vr_sqlerrm            VARCHAR2(4000);
  vr_dscritic           tbgen_prglog_ocorrencia.dsmensagem%TYPE;
  vr_cdcritic           tbgen_prglog_ocorrencia.cdmensagem%TYPE;
  vr_dsparame           VARCHAR2(4000);
  -- variavel para gerar o Log pode ser a da chamada da procedure ou a do loop de cooperativas.
  vr_cdcooinp           tbgen_prglog.cdcooper%TYPE := 0;
  --
  -- Variaveis para tratar a execução do programa
  vr_dhinicur           tbgen_prglog.dhinicio%TYPE;
  vr_dhfimcur           tbgen_prglog.dhfim%TYPE;
  vr_dhinipro           tbgen_prglog.dhinicio%TYPE;
  vr_dhfimpro           tbgen_prglog.dhfim%TYPE;
  vr_qterros            NUMBER(5) := 0;
  vr_qttoterr           NUMBER(5) := 0;
  vr_qtpenden           NUMBER(5) := 0;
  vr_qttotpen           NUMBER(5) := 0;
  vr_idprglog           tbgen_prglog.idprglog%TYPE;
  vr_nmprogra           VARCHAR2(400);
  --
  vr_existe             VARCHAR2(1);
  vr_intempro           VARCHAR2(1);
  vr_dsparcad           VARCHAR2(3);
  --
  vr_dsarqres           utl_file.file_type;
  vr_dsarqpro           utl_file.file_type;
  vr_dsarqerr           utl_file.file_type;
  vr_dsarqpen           utl_file.file_type;
  vr_dsarqcon           utl_file.file_type;
  
  vr_tparqtxt           VARCHAR2(3)  := 'txt';
  vr_tparqhtl           VARCHAR2(4)  := 'html';
  
  vr_nmarqres           VARCHAR2(40) := 'RESUMO';  
  vr_nmarqpro           VARCHAR2(40) := 'PROGRAMA';   
  vr_nmarqerr           VARCHAR2(40) := 'ERROS';   
  vr_nmarqpen           VARCHAR2(40) := 'PENDENCIA';
  vr_nmarqcon           VARCHAR2(40) := 'CONTEUDO';
  vr_nmdirarq           VARCHAR2(4000);
  vr_nmlisarq           VARCHAR2(4000);
  vr_nmlisger           VARCHAR2(4000);
  vr_nmlisope           VARCHAR2(4000);
  vr_dsacepos           VARCHAR2(4000);
  vr_dshorfim           VARCHAR2(4000);
  --
  vr_nmlisfim           VARCHAR2(4000);
  vr_nmlisprm           VARCHAR2(4000);
  --
  vr_dslisexe           VARCHAR2(32000);
  --
  vr_dslisver           VARCHAR2(4000);  
  vr_dslispad           VARCHAR2(4000);
  vr_dsdiamov           VARCHAR2(4000);
  vr_dsfimobs           VARCHAR2(4000);  
  vr_dslispr1           VARCHAR2(4000);
  vr_dslispr2           VARCHAR2(4000);
  vr_dslispr3           VARCHAR2(4000);
  vr_dslisve2           VARCHAR2(4000);  
  vr_dslispla           VARCHAR2(4000);  
  vr_dslispl1           VARCHAR2(4000);  
  vr_dslispl2           VARCHAR2(4000);  
  vr_dslispl3           VARCHAR2(4000);     
  vr_hrinicio           VARCHAR2   (6);
  vr_hrfim              VARCHAR2   (6);
  vr_ctprogra           NUMBER(2);
  --
  vr_dslisout           VARCHAR2(4000); 
  --
  vr_ctregist           NUMBER(2);
  vr_dslinerr           VARCHAR2(4000);
  vr_dslinpen           VARCHAR2(4000);
  vr_dslinres           VARCHAR2(4000);
  vr_dslinpro           VARCHAR2(4000);
  --
  vr_dsminatu           VARCHAR2(10);
  vr_dsminmed           VARCHAR2(10);
  --
  vr_inarqres           BOOLEAN := true;
  vr_inarqpro           BOOLEAN := true;
  vr_inarqerr           BOOLEAN := true;
  vr_inarqpen           BOOLEAN := true;
  --
  vr_inimprer           BOOLEAN := true;
  vr_inimprpe           BOOLEAN := true;
  --
  vr_dsfixa1            VARCHAR2(200) := 'Relatorio via tabela TBGEN_PRGLOG';
  vr_dscb1pad           VARCHAR2(200);
  vr_dscb2pad           VARCHAR2(200);
  vr_dstipcad           VARCHAR2(200);
  vr_dscb1res           VARCHAR2(200); 
  vr_dscb2res           VARCHAR2(200) := 'Cadeia  Tipo       Ordem   Hora Finalizada'; 
  vr_dscb1pro           VARCHAR2(200);  
  vr_dscb2pro           VARCHAR2(200); 
  vr_dscb3pro           VARCHAR2(200);                                                                                 
  vr_dscb1pen           VARCHAR2(200); 
  vr_dscb1err           VARCHAR2(200); 
  -- descrição da hora do ultimo programa por cadeia
  -- Criado porque nas cadeias paralelas elas iniciam sem precisar terminar entre elas
  -- Apenas a proxima exclusiva vai esperar o ultimo programa terminar
  -- esse programa pode ser de qualquer paralela anterior e não da ultima paralela    
  vr_dshoruca           VARCHAR2(200); 
  vr_dsdatuca           VARCHAR2(200);   
  vr_dshorult           VARCHAR2(200); 
  vr_dsdatult           VARCHAR2(200); 
  vr_nmresult           VARCHAR2(200); 
  vr_nrsolult           VARCHAR2(200);
  --
  vr_qtminmed           NUMBER(15,5);                            
  -- Atualizar lay-out de decimal para minutos - 01/11/2018 - REQ0032025
  vr_hrminmed           VARCHAR2(10);
  vr_hrmindif           VARCHAR2(10);
  vr_hrexeatu           VARCHAR2(10);
  vr_dssinal            VARCHAR2 (1);
  --
  vr_qtminatu           NUMBER(15,5);
  vr_qtperaux           NUMBER(15,5);
  vr_qtperdif           NUMBER(15,5);
  --       
  vr_dsnegmin           VARCHAR2(10);
  vr_qtmindif           NUMBER(15,5);
  vr_dsalert1           VARCHAR2(10);
  vr_dsalert2           VARCHAR2(10);
  vr_fgftulpr           BOOLEAN; -- Se não encontra o ultimo programa no final gera um alerta
  --
  vr_qtlanmen           NUMBER(15);
  vr_qtlantab           NUMBER(15);
  vr_qtlandia           NUMBER(15);
  vr_dtmovent           DATE;
  vr_dtmovtab           DATE;
  vr_dtdia              NUMBER(2);
  vr_qtdiauti           NUMBER(2);
  vr_cdproctl           VARCHAR2(10); -- Código de programa controlador Noturno CRPS359.P ou Diário CRPS000.P
  --
  vr_dstitema           VARCHAR2 (4000) := NULL;
  vr_dsconteu           VARCHAR2(32700) := NULL;
  vr_dscontok           VARCHAR2(32700) := NULL;
  vr_dscongra           VARCHAR2 (32700);
  vr_qtmaxcon           NUMBER       (4) := 3660;
  vr_dslin100           VARCHAR2 (4000) := NULL;
  vr_dslin110           VARCHAR2 (4000) := NULL;
  vr_dslin200           VARCHAR2 (4000) := NULL;
  vr_dslin210           VARCHAR2 (4000) := NULL;
  vr_dslin220           VARCHAR2 (4000) := NULL;
  vr_dslin300           VARCHAR2 (4000) := NULL;
  vr_dslin400           VARCHAR2 (4000) := NULL;
  vr_dslin410           VARCHAR2 (4000) := NULL;
  vr_dsagenda           VARCHAR2 (4000) := NULL;
  vr_hriniexe           VARCHAR2    (5) := NULL;
  vr_hrageexe           VARCHAR2    (5) := NULL;
  vr_hrfimexe           VARCHAR2    (5) := NULL;       
  vr_inproces           crapdat.inproces%TYPE;   
  vr_flultexe           INTEGER          := NULL;
  vr_qtdexec            INTEGER          := NULL;    

  -- Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN INTEGER  DEFAULT NULL
                                 ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução  
                                 ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                 ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
                                 ,pr_cdprogra IN VARCHAR2 DEFAULT NULL
  ) 
  IS
  /* ..........................................................................
    
  Procedure: pc_controla_log_batch
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Chamar a rotina de Log para gravação de criticas.
    
  Alteracoes: 
    
  ............................................................................. */
    
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    vr_cdprogra           tbgen_prglog.cdprograma%TYPE;
  BEGIN
    IF pr_cdprogra IS NULL THEN
      vr_cdprogra := vr_cdproexe;
    ELSE
      vr_cdprogra := pr_cdprogra;
    END IF;
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => SUBSTR(pr_dscritic,1,3900)
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdcooper      => vr_cdcooinp 
                          ,pr_flgsucesso    => pr_flgsuces
                          ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                          ,pr_texto_chamado => pr_textochd
                          ,pr_destinatario_email => pr_desemail
                          ,pr_flreincidente => pr_flreinci
                          ,pr_cdprograma    => vr_cdprogra
                          ,pr_idprglog      => vr_idprglog
                          );   
    IF LENGTH(pr_dscritic) > 3900 THEN   
      -- Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                            ,pr_tpocorrencia  => 3 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_cdcriticidade => 0 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            ,pr_tpexecucao    => 2 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                            ,pr_dsmensagem    => gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                                            '. Estouro do atributo pr_dscritic com tamanho de: '||LENGTH(pr_dscritic)||
                                            '. ' || vr_cdproexe || 
                                            '. ' || vr_dsparame ||
                                            '. ' || SUBSTR(pr_dscritic,3901,3900) 
                            ,pr_cdmensagem    => 9999
                            ,pr_cdcooper      => vr_cdcooinp 
                            ,pr_flgsucesso    => pr_flgsuces
                            ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                            ,pr_texto_chamado => pr_textochd
                            ,pr_destinatario_email => pr_desemail
                            ,pr_flreincidente => pr_flreinci
                            ,pr_cdprograma    => vr_cdprogra
                            ,pr_idprglog      => vr_idprglog
                            );     
    END IF;                                                       
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooinp
                                   ,pr_compleme => 'LENGTH(pr_dscritic):' || LENGTH(pr_dscritic) ||
                                                   'pr_cdcritic:'         || pr_cdcritic
                                   );      
  END pc_controla_log_batch;   
  --
  PROCEDURE pc_le_crapprm
  IS
  /* ..........................................................................
    
  Procedure: pc_le_crapprm
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  
  Objetivo  : Posicionar parâmetros
  
  Regra de pesquisa:
    Primeiro le o registro com o codigo da cooperativa, se não encontrar 
    le o registro com o codigo da cooperativa com ZERO, 
    desta forma para os parametros iguais em todas cooperativas basta um cadastro.

  Variantes de acesso cadastradas:
  1) Limite em minutos para emitir observação no resumo gerencial   - Alerta Vermelho
  2) Limite em minutos para emitir observação no resumo operacional - Alerta Amarelo
  3) LISTA_TBGEN_LIN_100 - Resumo de Execução da Cadeia linha codigo 100 introdução no e-mail com execução do batch
  4) LISTA_TBGEN_LIN_110 - Resumo de Execução da Cadeia linha codigo 110 introdução no e-mail sem execução do batch
  3) LISTA_TBGEN_LIN_200 - Resumo de Execução da Cadeia linha codigo 200 Finalização no e-mail com um incidente no batch
  4) LISTA_TBGEN_LIN_210 - Resumo de Execução da Cadeia linha codigo 210 Finalização no e-mail com mais de um incidente no batch
    
  Alteracoes: 
    
  ............................................................................. */ 
  vr_cdcoppar crapprm.cdcooper%TYPE;
  --
  PROCEDURE pc_le_crapprm_cooper
  IS
  /* ..........................................................................
    
  Procedure: pc_le_crapprm_cooper
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  
  Objetivo  : Posicionar parâmetros por cooperativa
  .............................................................................*/
  
  BEGIN
    SELECT  t30.dsvlrprm
    INTO    vr_dsvlrprm
    FROM    crapprm t30
    WHERE   t30.nmsistem = vr_nmsistem
    AND     t30.cdcooper = vr_cdcoppar
    AND     t30.cdacesso = vr_cdacesso;
  END;
  --
  BEGIN
    vr_cdcoppar := vr_cdcooper;
    pc_le_crapprm_cooper;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --
      vr_cdcoppar := 0;
      BEGIN
        pc_le_crapprm_cooper;
      EXCEPTION
        WHEN vr_exc_montada THEN  
          RAISE vr_exc_montada;
        WHEN vr_exc_erro_tratado THEN 
          RAISE vr_exc_erro_tratado; 
        WHEN vr_exc_others THEN 
          RAISE vr_exc_others; 
        WHEN OTHERS THEN   
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
          -- Trata erro
          pr_cdcritic := 1036;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                         ' crapprm(8): '  ||
                         vr_dsparame      ||
                         ', vr_cdcoppar:' || vr_cdcoppar ||
                         ', vr_cdacesso:' || vr_cdacesso ||
                         '. ' || SQLERRM; 
          RAISE vr_exc_montada;
      END;
      --
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      pr_cdcritic := 1036;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                    ' crapprm(4): '  ||
                    vr_dsparame      ||
                    ', vr_cdcoppar:' || vr_cdcoppar ||
                    ', vr_cdacesso:' || vr_cdacesso ||
                    '. ' || SQLERRM; 
      RAISE vr_exc_montada;
  END pc_le_crapprm;            
  --
  PROCEDURE pc_abre_arquivo(pr_nmarqpre IN VARCHAR2
                           ,pr_tparqext IN VARCHAR2
                           ,pr_dshandle OUT UTL_FILE.FILE_TYPE)
  IS
  /* ..........................................................................
    
  Procedure: pc_abre_arquivo
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar abertura de arquivo
    
  Alteracoes:                           
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
    --
    vr_nmdireto           VARCHAR2(4000);
    vr_nmarquiv           VARCHAR2(4000);
    --
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_abre_arquivo';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_nmsubdir => '/arq');    
    -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484                                                             
    vr_nmarquiv := '/' || pr_nmarqpre || 
                   '_' || to_char(vr_dtsysdat, 'MMDD_HH24MISS') ||
                   '_COOP_'  || vr_cdcooper ||
                   '_TPCAD_' || vr_tpcadeia ||
                    '.'      || pr_tparqext;                                    
    vr_nmdirarq := vr_nmdireto || vr_nmarquiv;
    IF vr_nmlisope IS NULL THEN
      vr_nmlisope := vr_nmdirarq;
    ELSE
      vr_nmlisope := vr_nmlisope || ',' || vr_nmdirarq;
    END IF;
    IF pr_nmarqpre IN ('RESUMO', 'CONTEUDO') THEN
      IF vr_nmlisger IS NULL THEN
        vr_nmlisger := vr_nmdirarq;
      ELSE
        vr_nmlisger := vr_nmlisger || ',' || vr_nmdirarq;
      END IF;
    END IF;
    
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto 
                            ,pr_nmarquiv => vr_nmarquiv
                            ,pr_tipabert => 'W'                -- Modo de abertura (R,W,A)
                            ,pr_flaltper => 0                  -- Não modifica permissões de arquivo
                            ,pr_utlfileh => pr_dshandle        -- Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      vr_dsparame := vr_dsparame || 
                     ', pr_nmdireto:' || vr_nmdireto || 
                     ', pr_nmarquiv:' || vr_nmarquiv || 
                     ', pr_tipabert:' || 'W' || 
                     ', pr_flaltper:' || '0';
      RAISE vr_exc_erro_tratado;
    END IF;
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_abre_arquivo;   
  --
  PROCEDURE pc_fecha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type)
  IS
  /* ..........................................................................
    
  Procedure: pc_fecha_arquivo
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar fechamento de arquivo
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN  
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_fecha_arquivo';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    
    IF utl_file.IS_OPEN(pr_utlfileh) THEN
      gene0001.pc_fecha_arquivo(pr_utlfileh => pr_utlfileh);
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    END IF;
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_fecha_arquivo; 
  --
  PROCEDURE pc_grava_linha(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type
                          ,pr_des_text  IN VARCHAR2)
  IS
  /* ..........................................................................
    
  Procedure: pc_grava_linha
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Tratar gravação de linha no arquivo
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN  
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_grava_linha';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => pr_utlfileh
                                  ,pr_des_text => pr_des_text);
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_grava_linha;  
  --
  --
  PROCEDURE pc_monta_e_mail
  IS
  /* ..........................................................................
    
  Procedure: pc_monta_e_mail
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Montar e-mails de retorno
    
  Alteracoes: 
    
  ............................................................................. */
    --    
    vr_dsenddst           VARCHAR2 (4000) := NULL;
  BEGIN  
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_monta_e_mail';
    -- Inclusão do módulo e ação logado
    gene0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);

    -- Busca o endereco de email para os casos de criticas
    vr_dsenddst := gene0001.fn_param_sistema('CRED',vr_cdcooper,vr_dsacepos);

    IF vr_dsenddst IS NULL THEN
      pr_cdcritic := 1230;  --1230 - Registro de parametro não encontrado.
      vr_dsparame := vr_dsparame || ', vr_dsacepos:' || vr_dsacepos;
      RAISE vr_exc_erro_tratado;
    END IF;
    
    -- email no Log    
    pc_controla_log_batch(pr_cdcritic => 1201
                         ,pr_dscritic => 'Solicita email:' ||
                                         ' pr_cdprogra:'    || vr_cdproexe ||
                                         ',pr_des_destino:' || vr_dsenddst ||
                                         ',pr_des_assunto:' || vr_dstitema ||
                                         ',pr_des_corpo:'   || vr_dscontok ||
                                         ',pr_des_anexo:'   || vr_nmlisarq
                          ,pr_dstiplog => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                         ); 
    --    
    gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                              ,pr_cdprogra        => vr_cdproexe
                              ,pr_des_destino     => vr_dsenddst
                              ,pr_des_assunto     => vr_dstitema
                              ,pr_des_corpo       => vr_dscontok
                              ,pr_des_anexo       => vr_nmlisarq
                              ,pr_flg_remove_anex => 'N'
                              ,pr_flg_enviar      => 'S'
                              ,pr_des_erro        => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      vr_dsparame := vr_dsparame || 
                     ' pr_cdprogra:'     || vr_cdproexe ||
                     ', pr_des_destino:' || vr_dsenddst ||
                     ', pr_des_assunto:' || vr_dstitema ||
                     ', pr_des_corpo:'   || vr_dscontok ||
                     ', pr_des_anexo:'   || vr_nmlisarq ||
                     ', pr_flg_remove_anex:' || 'N' ||
                     ', pr_flg_enviar:'      || 'S';
      RAISE vr_exc_erro_tratado;
    END IF;
    
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);    
  EXCEPTION
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;                                                         
  END pc_monta_e_mail;     
  --
  PROCEDURE pc_monta_arqpen
  IS
  /* ..........................................................................
    
  Procedure: pc_monta_arqpen
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata montagem do arquivo de pendencias de log
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_monta_arqpen';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
                        
    IF vr_inarqpen THEN
      pc_abre_arquivo(vr_nmarqpen
                     ,vr_tparqtxt
                     ,vr_dsarqpen) ;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_dscb1pen := vr_dsfixa1 || ' - Pendencias' || vr_dscb1pad;
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => vr_dscb1pen );       
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => vr_dscb2pad ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => 'Considerados erros indevidamente' );  
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => '' ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => 'Programa' ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => '' );     
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_inarqpen := false;
    END IF;
    IF vr_inimprpe THEN
      pc_grava_linha(pr_utlfileh => vr_dsarqpen
                    ,pr_des_text => vr_cdprogra );
      vr_inimprpe := false;
    END IF;
    pc_grava_linha(pr_utlfileh => vr_dsarqpen
                  ,pr_des_text => vr_dslinpen );
    pc_grava_linha(pr_utlfileh => vr_dsarqpen
                  ,pr_des_text => '' );
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);

  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;          
  END pc_monta_arqpen;   
  --
  PROCEDURE pc_monta_arqerr
  IS
  /* ..........................................................................
    
  Procedure: pc_monta_arqerr
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata montagem do arquivo de erros
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_monta_arqerr';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
                        
    IF vr_inarqerr THEN
      pc_abre_arquivo(vr_nmarqerr
                     ,vr_tparqtxt
                     ,vr_dsarqerr) ;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_dscb1err := vr_dsfixa1 || ' - Erros' || vr_dscb1pad;
      pc_grava_linha(pr_utlfileh => vr_dsarqerr
                    ,pr_des_text => vr_dscb1err );  
      pc_grava_linha(pr_utlfileh => vr_dsarqerr
                    ,pr_des_text => vr_dscb2pad );  
      pc_grava_linha(pr_utlfileh => vr_dsarqerr
                    ,pr_des_text => '' ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqerr
                    ,pr_des_text => 'Programa' ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqerr
                    ,pr_des_text => '' );     
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_inarqerr := false;
    END IF;
    IF vr_inimprer THEN
      pc_grava_linha(pr_utlfileh => vr_dsarqerr
                    ,pr_des_text => vr_cdprogra );
      vr_inimprer := false;
    END IF;
    pc_grava_linha(pr_utlfileh => vr_dsarqerr
                  ,pr_des_text => vr_dslinerr );
    pc_grava_linha(pr_utlfileh => vr_dsarqerr
                  ,pr_des_text => '' );
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);

  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;          
  END pc_monta_arqerr;   
  --  
  PROCEDURE pc_monta_arqres
  IS
  /* ..........................................................................
    
  Procedure: pc_monta_arqres
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata montagem do arquivo de resumo
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_monta_arqres';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
                        
    IF vr_inarqres THEN
      pc_abre_arquivo(vr_nmarqres
                     ,vr_tparqtxt
                     ,vr_dsarqres ) ;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);            
    
      vr_dscb1res := vr_dsfixa1 || ' - Resumo' || vr_dscb1pad;
      pc_grava_linha(pr_utlfileh => vr_dsarqres
                    ,pr_des_text => vr_dscb1res ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqres
                    ,pr_des_text => vr_dscb2pad ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqres
                    ,pr_des_text => '' );    
      pc_grava_linha(pr_utlfileh => vr_dsarqres
                    ,pr_des_text => vr_dscb2res ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqres
                    ,pr_des_text => '' );  
                       
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_inarqres := false;
    END IF;
    pc_grava_linha(pr_utlfileh => vr_dsarqres
                  ,pr_des_text => vr_dslinres );
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);


  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;          
  END pc_monta_arqres;
  --  
  PROCEDURE pc_monta_arqpro
  IS
  /* ..........................................................................
    
  Procedure: pc_monta_arqpro
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata montagem do arquivo de abertura por programa
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_monta_arqpro';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
                        
    IF vr_inarqpro THEN
      pc_abre_arquivo(vr_nmarqpro
                     ,vr_tparqtxt
                     ,vr_dsarqpro ) ;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);            
    
      vr_dscb1pro := vr_dsfixa1 || ' - Aberto por Programa' || vr_dscb1pad;
      pc_grava_linha(pr_utlfileh => vr_dsarqpro
                    ,pr_des_text => vr_dscb1pro ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqpro
                    ,pr_des_text => vr_dscb2pad ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqpro
                    ,pr_des_text => '' );
      
      vr_dscb2pro := 'Cadeia Tipo    Ordem Programa Inicio    Fim      Exec Atual  Erros Parada '||
                     ' Media       Diferença       Acima    Acima';               
      pc_grava_linha(pr_utlfileh => vr_dsarqpro
                    ,pr_des_text => vr_dscb2pro ); 
      
      vr_dscb3pro := '                                   (progress)       Minutos        Cadeia ' ||
                     'Minutos  Minutos - Percent   ' || vr_qtlimver || ' Mins  ' || vr_qtlimama || '  Mins';      
      pc_grava_linha(pr_utlfileh => vr_dsarqpro
                    ,pr_des_text => vr_dscb3pro ); 
      pc_grava_linha(pr_utlfileh => vr_dsarqpro
                    ,pr_des_text => '' ); 
                       
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_inarqpro := false;
    END IF;
    pc_grava_linha(pr_utlfileh => vr_dsarqpro
                  ,pr_des_text => vr_dslinpro );
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);

  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;          
  END pc_monta_arqpro;    
       
  --  
  PROCEDURE pc_espec_tbgen_prglog_ocor
  IS
  /* ..........................................................................
    
  Procedure: pc_espec_tbgen_prglog_ocor
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Verifica se programa parou a cadeia
    
  Alteracoes: 
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - Tratar programa exclusivo retirado da cadeia
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */ 

  -- Selecionar tbgen ocorrencia especifica 
  CURSOR cr_tbgen_oco_min  IS
    SELECT t3.idprglog, t5.dhocorrencia
    FROM   tbgen_prglog t3
          ,tbgen_prglog_ocorrencia t5
    WHERE  t3.cdcooper        = vr_cdcooper  
    AND    t3.cdprograma      = vr_cdprogra  
    AND    TRUNC(t3.dhinicio) = vr_dtmovime
    AND    TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
    AND    t5.idprglog        = t3.idprglog 
    AND    t5.cdmensagem      = vr_cdmensag
    AND    t5.tpocorrencia    = 4
    AND    t5.dhocorrencia    = 
         ( SELECT MIN(t6.dhocorrencia) 
           FROM   tbgen_prglog t4
                 ,tbgen_prglog_ocorrencia t6
           WHERE  t4.cdcooper        = t3.cdcooper 
           AND    t4.cdprograma      = t3.cdprograma
           AND    TRUNC(t4.dhinicio) = TRUNC(t3.dhinicio)
           AND    TO_CHAR(t4.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
           AND    t6.idprglog        = t4.idprglog 
           AND    t6.cdmensagem      = t5.cdmensagem -- Ajuste 10/10/2018  REQ0029484
           AND    t6.tpocorrencia    = 4 )
  ORDER BY  t5.dhocorrencia;
  rw_tbgen_oco_min    cr_tbgen_oco_min%ROWTYPE;     

  -- Selecionar tbgen ocorrencia especifica 
  CURSOR cr_tbgen_oco_max  IS
    SELECT t3.idprglog, t3.dhinicio, t5.dhocorrencia
    FROM   tbgen_prglog t3
          ,tbgen_prglog_ocorrencia t5
    WHERE  t3.cdcooper        = vr_cdcooper  
    AND    t3.cdprograma      = vr_cdprogra  
    AND    TRUNC(t3.dhinicio) = vr_dtmovime
    AND    TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
    AND    t5.idprglog        = t3.idprglog 
    AND    t5.cdmensagem      = vr_cdmensag
    AND    t5.tpocorrencia    = 4
    AND    t5.dhocorrencia    = 
         ( SELECT MAX(t6.dhocorrencia) 
           FROM   tbgen_prglog t4
                 ,tbgen_prglog_ocorrencia t6
           WHERE  t4.cdcooper        = t3.cdcooper 
           AND    t4.cdprograma      = t3.cdprograma
           AND    TRUNC(t4.dhinicio) = TRUNC(t3.dhinicio)
           AND    TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
           AND    t6.idprglog        = t4.idprglog 
           AND    t6.cdmensagem      = t5.cdmensagem -- Ajuste 10/10/2018  REQ0029484
           AND    t6.tpocorrencia    = 4 )
  ORDER BY  t5.dhocorrencia DESC;
  rw_tbgen_oco_max    cr_tbgen_oco_max%ROWTYPE;
  --
  --    
  -- Selecionar DATA E HORA de reinicio da cadeia após um programa ser saltado
  CURSOR cr_tbgen_retsal  IS
    SELECT t3.idprglog, t3.dhinicio, t5.dhocorrencia
    FROM   tbgen_prglog t3
          ,tbgen_prglog_ocorrencia t5
    WHERE  t3.cdcooper        = vr_cdcooper  
    ---AND    t3.cdprograma      = vr_cdprogra  
    AND    TRUNC(t3.dhinicio) = vr_dtmovime
    AND    TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
    AND    t5.idprglog        = t3.idprglog 
    AND    t5.cdmensagem      = vr_cdmsgsal
    AND    t5.tpocorrencia    = 4
    AND    t5.dhocorrencia    = 
         ( SELECT MAX(t6.dhocorrencia) 
           FROM   tbgen_prglog t4
                 ,tbgen_prglog_ocorrencia t6
           WHERE  t4.cdcooper        = t3.cdcooper 
           AND    t4.cdprograma      = t3.cdprograma
           AND    TRUNC(t4.dhinicio) = TRUNC(t3.dhinicio)
           AND    TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
           AND    t6.idprglog        = t4.idprglog 
           AND    t6.cdmensagem      = t5.cdmensagem -- Ajuste 10/10/2018  REQ0029484
           AND    t6.tpocorrencia    = 4 )
  ORDER BY  t5.dhocorrencia DESC;
  rw_tbgen_retsal    cr_tbgen_retsal%ROWTYPE;  
  --
  --
  CURSOR cr_execucao_manual
  IS
    SELECT t3.*
    FROM   tbgen_prglog t3
    WHERE  t3.cdcooper        = vr_cdcooper  
    AND    t3.cdprograma      = vr_cdprogra  
    AND    TRUNC(t3.dhinicio) = vr_dtmovime
    AND    TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor
    AND    NOT EXISTS 
      (SELECT 1 FROM tbgen_prglog_ocorrencia t50
       WHERE  t50.idprglog   = t3.idprglog 
       AND    t50.cdmensagem  IN ( 1229, 1231 ) )
       ORDER BY  t3.dhinicio; 
  rw_execucao_manual    cr_execucao_manual%ROWTYPE;
  --  
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_espec_tbgen_prglog_ocor';
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
    vr_cdmensag := 1231;
    vr_dthorret := NULL; 
    FOR rw_tbgen_oco_max IN cr_tbgen_oco_max  LOOP
       vr_dthorret := rw_tbgen_oco_max.dhocorrencia;         
       EXIT;
    END LOOP;

    -- Regra de execeção 3      
    --    
    vr_qthorpar := NULL;
    vr_cdmensag := 1229;
    FOR rw_tbgen_oco_min IN cr_tbgen_oco_min  LOOP
      vr_dslispr3 := '.';
      IF vr_dthorret IS NULL THEN
        vr_dslispr2 := NULL;
        -- Tratar programa exclusivo retirado da cadeia - 09/10/2018 - Chamado - REQ0029484              
        vr_dslispr3 := ', e o programa foi retirado da cadeia desta noite para não executar.';        
        vr_cdmsgsal := 1231;
        vr_dtretsal := NULL;
        --
        FOR rw_tbgen_retsal IN cr_tbgen_retsal  LOOP
          vr_dtretsal := rw_tbgen_retsal.dhocorrencia;
          IF rw_tbgen_retsal.dhocorrencia > rw_tbgen_oco_min.dhocorrencia THEN
             vr_dtretsal := rw_tbgen_retsal.dhocorrencia;
             
             vr_dthorret := vr_dtretsal;
             EXIT;
          END IF;
        END LOOP; 
        --  
      END IF;
      
      IF vr_dthorret IS NOT NULL THEN
        vr_qthorpar := TO_NUMBER(REPLACE(TRUNC((((vr_dthorret) - (rw_tbgen_oco_min.dhocorrencia)) * 24 * 60 ),2),',''.'));       
        vr_dslispr2 := ' de ' || TO_CHAR(TRUNC(vr_qthorpar), 'FM900') || ':' || TO_CHAR(MOD((vr_qthorpar * 60), 60), 'FM00') || ' minutos';      
      END IF;
      vr_dsparcad := '***';
      vr_ctregist := 0;
      BEGIN
        FOR rw_execucao_manual IN cr_execucao_manual LOOP
          vr_ctregist := vr_ctregist + 1;
          IF vr_ctregist >= 2 THEN
            IF rw_execucao_manual.dhfim IS NOT NULL THEN
              vr_dslispr3 := ', mas posteriormente executado manualmente com sucesso.';
              EXIT;
            END IF;
          END IF;
        END LOOP;
      END;
      
      vr_ctsequec := vr_ctsequec + 1;
      vr_dslispr1 := TO_CHAR(vr_ctsequec,'9900') || '&nbsp;-&nbsp;O programa "' || LOWER(vr_nmprogra) || '" (' ||
                     vr_cdprogra || ') '  || 
                     'teve sua execução interrompida devido a um erro (o que gerou um atraso' || 
                     vr_dslispr2 || ')' || vr_dslispr3; 
              
      IF vr_dslisexe IS NULL THEN
            vr_dslisexe := vr_dslispr1;  
          ELSE
            vr_dslisexe := vr_dslisexe || '<br>' || vr_dslispr1;  
      END IF;
      
      EXIT;
    END LOOP;
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;          
  END pc_espec_tbgen_prglog_ocor;
    
  --
  PROCEDURE pc_tbgen_prglog
  IS
  /* ..........................................................................
    
  Procedure: pc_tbgen_prglog
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata cadastro de cabeçalho de Log
    
  Alteracoes: 
    
  ............................................................................. */
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_tbgen_prglog';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
  
    SELECT
         t3.dhinicio
        ,t3.dhfim
        ,t3.idprglog
    INTO 
         vr_dhinicur
        ,vr_dhfimcur
        ,vr_idprglog
    FROM  tbgen_prglog T3
    WHERE t3.cdcooper   = vr_cdcooper 
    AND   t3.cdprograma = vr_cdprogra
    AND   TRUNC(t3.dhinicio)            = vr_dtmovime
    AND   TO_CHAR(t3.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor  
    AND   t3.idprglog        = 
        ( SELECT MAX(t4.idprglog  ) 
          FROM   tbgen_prglog T4
          WHERE  t4.cdcooper   = t3.cdcooper 
          AND    t4.cdprograma = t3.cdprograma
          AND    TRUNC(t4.dhinicio)            = TRUNC(t3.dhinicio)
          AND    TO_CHAR(t4.dhinicio,'HH24MI') BETWEEN '0000' AND vr_dsulthor 
           );
    vr_existe := 'S';
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
      vr_existe := 'N';
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      pr_cdcritic := 1036;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                    ' tbgen_prglog(1): ' ||
                    vr_dsparame          ||
                    '. ' || SQLERRM; 
      RAISE vr_exc_montada;
  END pc_tbgen_prglog;
  --
  PROCEDURE pc_crapprg
  IS
  /* ..........................................................................
    
  Procedure: pc_crapprg
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata cadastro de programa
    
  Alteracoes:                           
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
  
    vr_qtprocad  NUMBER(3);
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_crapprg';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
                               
    vr_qtprocad := 0;
    vr_dshoruca := NULL;
    vr_dsdatuca := NULL; 

    -- Selecionar programas das cadeias
    FOR rw_crapprg IN cr_crapprg  LOOP    
      --
      vr_inimprer := true;
      vr_inimprpe := true;
      vr_qterros  := 0;
      vr_intempro := 'N';
      vr_cdprogra := rw_crapprg.cdprogra || '.P';
            
      -- Limitado em 93 o tamanho maximo para alinhar no HTML do e-mail
      vr_nmprogra := RPAD(rw_crapprg.dsprogra##1 ||
                     rw_crapprg.dsprogra##2 ||
                     rw_crapprg.dsprogra##3 ||
                     rw_crapprg.dsprogra##4,93,' ' );
     
      pc_tbgen_prglog;
      
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      IF vr_existe = 'N' THEN
        NULL;
        
      ELSE    
        vr_dsparcad := '   ';    
        pc_espec_tbgen_prglog_ocor;
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
        
        vr_intempro := vr_existe;
        vr_dhinipro := vr_dhinicur;
        vr_dhfimpro := vr_dhfimcur;
        vr_cdprogra := rw_crapprg.cdprogra;
        pc_tbgen_prglog;
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      
      IF vr_intempro = 'S' THEN
        
        FOR vr_idoco IN 1 ..  vr_tab_tbgen_prglog_ocor.COUNT LOOP
          IF ( vr_tab_tbgen_prglog_ocor(vr_idoco).cdcooper    = rw_crapprg.cdcooper OR
                ( vr_tab_tbgen_prglog_ocor(vr_idoco).cdcooper = 0 AND
                  rw_crapprg.cdcooper                         = 3     )                ) AND
             ( vr_tab_tbgen_prglog_ocor(vr_idoco).nrsolici = rw_crapprg.nrsolici OR
               vr_tab_tbgen_prglog_ocor(vr_idoco).idtipo   = 'O'                 OR
               vr_tab_tbgen_prglog_ocor(vr_idoco).idtipo   = 'L'                       ) AND
             vr_tab_tbgen_prglog_ocor(vr_idoco).cdprogra = rw_crapprg.cdprogra     THEN
             
            IF vr_tab_tbgen_prglog_ocor(vr_idoco).idtipo IN ( 'E', 'O' ) THEN
              vr_dslinerr := 'Idoco:' || vr_tab_tbgen_prglog_ocor(vr_idoco).idocorrencia ||
                             ', msg:' || vr_tab_tbgen_prglog_ocor(vr_idoco).dsmensagem;
              vr_qterros  := vr_qterros + 1;
              vr_qttoterr := vr_qttoterr + 1;
              pc_monta_arqerr;
            ELSIF vr_tab_tbgen_prglog_ocor(vr_idoco).idtipo = 'P' THEN
              vr_dslinpen := 'Idoco:' || vr_tab_tbgen_prglog_ocor(vr_idoco).idocorrencia ||
                             ', msg:' || vr_tab_tbgen_prglog_ocor(vr_idoco).dsmensagem;
              vr_qtpenden := vr_qtpenden + 1;
              vr_qttotpen := vr_qttotpen + 1;
              pc_monta_arqpen;
            END IF; 
            
            IF vr_tab_tbgen_prglog_ocor(vr_idoco).idtipo = 'O' THEN 
              vr_dsparcad := '***';       
              vr_ctsequec := vr_ctsequec + 1;
              vr_dslisout := TO_CHAR(vr_ctsequec,'9900') || 
                             '&nbsp;-&nbsp;' || 
                             'O programa "' || LOWER(vr_nmprogra) || '" (' || rw_crapprg.cdprogra || ') ' ||
                             'teve sua execução interrompida ' ||
                             'devido a um erro (o que gerou um atraso de ' || 
                             vr_tab_tbgen_prglog_ocor(vr_idoco).hrparada  ||        
                             ' minutos).';               
              IF vr_dslisexe IS NULL THEN
                vr_dslisexe := vr_dslisout;  
              ELSE
                vr_dslisexe := vr_dslisexe || '<br>' || vr_dslisout;  
              END IF;  
              
            END IF;
            
            IF vr_tab_tbgen_prglog_ocor(vr_idoco).idtipo = 'L' THEN 
              vr_dsparcad := '***';              
            END IF;
            
          END IF;
        END LOOP;                    
        vr_qtprocad := vr_qtprocad + 1;  
        -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484
        vr_dshorfim := TO_CHAR(NVL(vr_dhfimpro,TRUNC(vr_dtsysdat)),'HH24:MI:SS');
        vr_dsdatuca := TO_CHAR(vr_dtmvtoan,'DD/MM');
              
        IF vr_dshoruca IS NULL       OR
           vr_dshorfim >= vr_dshoruca  THEN
          vr_dshoruca := vr_dshorfim;
        END IF;
    
        vr_qtminmed := rw_crapprg.qtminmed;
        -- Padronizar valores inferiores a um segundo - 27/09/2018 - Chd REQ0028395
        IF vr_qtminmed < 0.01 THEN
          vr_qtminmed :=  0.01;
        END IF;
            
        vr_qtminatu := NVL(TO_NUMBER(TRUNC((((vr_dhfimpro) - (vr_dhinipro)) * 24 * 60 ),2)),0);
             
        IF NVL(vr_qtminatu,0) > 0 AND NVL(vr_qtminmed,0) > 0 THEN
          vr_qtperaux := ( ( TRUNC(vr_qtminatu,2) * 100 ) / TRUNC(vr_qtminmed,2) ); -- 27/09/2018 - Chd REQ0028395
          IF vr_qtperaux > 9999 THEN
            vr_qtperdif := 9999.99;
          ELSIF vr_qtperaux > 100 THEN
            vr_qtperdif := vr_qtperaux - 100;
          ELSE
            vr_qtperdif := vr_qtperaux;
          END IF;
          -- Padronizar demostração da quantidade de minutos atual - 27/09/2018 - Chd REQ0028395          
          IF vr_qtminatu < vr_qtminmed THEN
            vr_qtperdif := 100 - vr_qtperdif;
            IF vr_qtperdif >= 0 THEN
              vr_qtperdif := vr_qtperdif * -1;
            END IF;
          END IF;
        ELSE
          vr_qtperdif := 100;
        END IF;
    
        vr_dsalert1 := '   ';  
        vr_dsalert2 := '   ';      
        IF vr_qtminatu >= vr_qtminmed THEN
          vr_dsnegmin := ' ';
          vr_qtmindif := vr_qtminatu - vr_qtminmed;
          IF vr_qtmindif > vr_qtlimver THEN 
            vr_dsalert1 := '***';
          ELSIF vr_qtmindif > vr_qtlimama THEN 
            vr_dsalert2 := '***'; 
          END IF;      
        ELSE
          vr_dsnegmin := '-';
          vr_qtmindif := vr_qtminatu - vr_qtminmed;
        END IF;
        
        -- Regra de execção 1 execução no vermelho
        -- Programas que demoram mais de um tempo parametrizado que a média de todos registros da base
        IF  vr_dsalert1 = '***' THEN
          vr_dsminatu := TO_CHAR(TRUNC(vr_qtminatu), 'FM900') || ':' || TO_CHAR(MOD((vr_qtminatu * 60), 60), 'FM00');
          vr_dsminmed := TO_CHAR(TRUNC(vr_qtminmed), 'FM900') || ':' || TO_CHAR(MOD((vr_qtminmed * 60), 60), 'FM00');

          IF vr_dsdiamov IS NULL THEN      
            vr_dslisve2 := ' de ' || 
                           TO_CHAR(TRUNC(vr_qtminatu - TRUNC(vr_qtminmed,2) ), 'FM900') || ':' || 
                           TO_CHAR(MOD(((vr_qtminatu - TRUNC(vr_qtminmed,2) ) * 60), 60), 'FM00') || 
                           ' minutos';
                                               
            vr_ctsequec := vr_ctsequec + 1;
            vr_dslisver := TO_CHAR(vr_ctsequec,'9900') || '&nbsp;-&nbsp;O programa "' || LOWER(vr_nmprogra) || '" (' ||
                           vr_cdprogra || ') '  || 
                           'executou em ' || vr_dsminatu || ' minutos ' ||                     
                           '(quando o esperado é em torno de '   || vr_dsminmed ||
                           ' minutos e que gerou um atraso' || vr_dslisve2 || ').';
                           
            IF vr_dslisexe IS NULL THEN
              vr_dslisexe := vr_dslisver;  
            ELSE
              vr_dslisexe := vr_dslisexe || '<br>' || vr_dslisver;  
            END IF; 
            pr_cdcritic := vr_cdexeexc;
          ELSE
            pr_cdcritic := vr_cdexcamd;
          END IF;
          
          -- Geração de registro de programa com alerta vermelho - excessao de tempo na execução          
          -- Monta mensagem
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         vr_dsparame || ', vr_cdprogra:' || vr_cdprogra;                   
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_dstiplog => 'O'
                               ,pr_tpocorre => 4
                               ,pr_cdcricid => 0
                               ,pr_cdprogra => vr_cdprogra
                               );
          pr_cdcritic := NULL;
          pr_dscritic := NULL;
          
        END IF;
        
        -- Regra de execção 2
        -- Se agora o tempo de execução esta no padrão e antes estava com excesso então listar a entrada no padrão
        IF vr_dsalert1 = '   ' THEN
          FOR vr_idoco IN 1 ..  vr_tab_tbgen_prglog_duracao.COUNT LOOP
            IF vr_tab_tbgen_prglog_duracao(vr_idoco).cdcooper = rw_crapprg.cdcooper AND
               vr_tab_tbgen_prglog_duracao(vr_idoco).cdprogra = rw_crapprg.cdprogra     THEN
                                           
              IF   (   vr_tab_tbgen_prglog_duracao(vr_idoco).dtexepad IS NOT NULL
                   AND vr_tab_tbgen_prglog_duracao(vr_idoco).dtexeexc > vr_tab_tbgen_prglog_duracao(vr_idoco).dtexepad )
                OR (   vr_tab_tbgen_prglog_duracao(vr_idoco).dtexepad IS NULL
                   AND vr_tab_tbgen_prglog_duracao(vr_idoco).dtexeexc IS NOT NULL )                  
                THEN          
                -- Geração de registro de programa com alerta vermelho - excessao de tempo na execução          
                -- Monta mensagem
                pr_cdcritic := vr_cdexepad;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                              vr_dsparame || ', vr_cdprogra:' || vr_cdprogra;                   
                -- Log de erro de execucao
                pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic
                                     ,pr_dstiplog => 'O'
                                     ,pr_tpocorre => 4
                                     ,pr_cdcricid => 0
                                     ,pr_cdprogra => vr_cdprogra
                                     );
                pr_cdcritic := NULL;
                pr_dscritic := NULL;
                
                --  2. Retorno do tempo conforme esperado.
                vr_dsminatu := TO_CHAR(TRUNC(vr_qtminatu), 'FM900') || ':' || TO_CHAR(MOD((vr_qtminatu * 60), 60), 'FM00');
                vr_dsminmed := TO_CHAR(TRUNC(vr_qtminmed), 'FM900') || ':' || TO_CHAR(MOD((vr_qtminmed * 60), 60), 'FM00');
                vr_ctsequec := vr_ctsequec + 1;
                vr_dslispad := TO_CHAR(vr_ctsequec,'9900') || '&nbsp;-&nbsp;O programa "' || LOWER(vr_nmprogra) || '" (' ||
                               vr_cdprogra || ') '  || 
                               'voltou a executar em ' || TO_CHAR(vr_qtminatu,'9990d00') || ' minutos, conforme esperado.'; 
              
                IF vr_dslisexe IS NULL THEN
                  vr_dslisexe := vr_dslispad;  
                ELSE
                  vr_dslisexe := vr_dslisexe || '<br>' || vr_dslispad;  
                END IF;
             
              END IF; 
            
            END IF;
          END LOOP;             
        END IF;
        -- Atualizar lay-out de decimal para minutos - 01/11/2018 - REQ0032025
        IF NVL(vr_qtminmed,0) = 0 THEN
          vr_hrminmed := '00:00:00';
        ELSE
          vr_hrminmed := 
            TO_CHAR(TRUNC((vr_qtminmed * 60) / 3600), 'FM9900') || ':' ||
            TO_CHAR(TRUNC(MOD((vr_qtminmed * 60), 3600) / 60), 'FM00') || ':' ||
            TO_CHAR(MOD((vr_qtminmed * 60), 60), 'FM00');
        END IF;
        --
        vr_dssinal := ' ';
        IF NVL(vr_qtmindif,0) = 0 THEN
          vr_hrmindif := '00:00:00';
          
        ELSIF vr_qtmindif < 0 THEN 
          --TO_NUMBER(TO_CHAR(REPLACE(TRUNC((((vr_dhfimpro) - (vr_dhinipro)) * 24 * 60 ),2),',''.'),'990d00') ) THEN
          vr_dssinal  := '-';
          vr_qtmindif := vr_qtmindif * -1;
          vr_hrmindif := 
            TO_CHAR(TRUNC((vr_qtmindif * 60) / 3600), 'FM9900') || ':' ||
            TO_CHAR(TRUNC(MOD((vr_qtmindif * 60), 3600) / 60), 'FM00') || ':' ||
            TO_CHAR(MOD((vr_qtmindif * 60), 60), 'FM00');
        ELSE
          vr_hrmindif := 
            TO_CHAR(TRUNC((vr_qtmindif * 60) / 3600), 'FM9900') || ':' ||
            TO_CHAR(TRUNC(MOD((vr_qtmindif * 60), 3600) / 60), 'FM00') || ':' ||
            TO_CHAR(MOD((vr_qtmindif * 60), 60), 'FM00');
        END IF;
        --
        IF NVL(TO_CHAR(REPLACE(TRUNC((((vr_dhfimpro) - (vr_dhinipro)) * 24 * 60 ),2),',''.'),'990d00'),'0') = '0' THEN
          vr_hrexeatu := '00:00:00';
        ELSE
          vr_hrexeatu := 
            TO_CHAR(TRUNC((TO_NUMBER(TO_CHAR(REPLACE(TRUNC((((vr_dhfimpro) - (vr_dhinipro)) * 24 * 60 ),2),',''.'),'990d00') ) * 60) / 3600), 'FM9900') || ':' ||
            TO_CHAR(TRUNC(MOD((TO_NUMBER(TO_CHAR(REPLACE(TRUNC((((vr_dhfimpro) - (vr_dhinipro)) * 24 * 60 ),2),',''.'),'990d00') ) * 60), 3600) / 60), 'FM00') || ':' ||
            TO_CHAR(MOD((TO_NUMBER(TO_CHAR(REPLACE(TRUNC((((vr_dhfimpro) - (vr_dhinipro)) * 24 * 60 ),2),',''.'),'990d00') ) * 60), 60), 'FM00');
        END IF;
        -- Atualizar lay-out de decimal para minutos - 01/11/2018 - REQ0032025   
        vr_dslinpro := LPAD(vr_nrsolici,5) || '  ' ||
                       vr_dsexclus         || ' '  || 
                       LPAD(vr_nrordsol,3) || ' '  ||
                       rw_crapprg.cdprogra || '  ' || 
                       TO_CHAR(vr_dhinipro,'HH24:MI:SS') || '  '  || 
                       TO_CHAR(vr_dhfimpro,'HH24:MI:SS') || '   ' ||
                       vr_hrexeatu || '   '  ||
                       TO_CHAR(vr_qterros,'990') || '  '  || 
                       vr_dsparcad || '  '   ||
                       vr_hrminmed || '  '     ||
                       vr_dssinal ||  vr_hrmindif || ' '     ||
                       TO_CHAR(vr_qtperdif,'9990d00') || '%' || '     ' ||
                       vr_dsalert1 || '     ' ||
                       vr_dsalert2
                       ;       
                                                      
        pc_monta_arqpro;
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      --
    END LOOP;
    
    IF vr_qtprocad > 0 THEN
          
      vr_dslinres := LPAD(vr_nrsolici,5) || '   ' ||  
                     vr_dsexclus         || 
                     LPAD(vr_nrordsol,7) || ' - ' || 
                     vr_dshoruca;                           
      pc_monta_arqres;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      IF vr_dshorult IS NULL       OR
         vr_dshoruca >= vr_dshorult  THEN
        vr_dshorult := vr_dshoruca;
        vr_dsdatult := vr_dsdatuca;
        vr_nmresult := vr_nmrescop;
        vr_nrsolult := vr_nrsolici;
      END IF;
      
    END IF;
        
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_crapprg;
  --
  PROCEDURE pc_cadeia  
  IS
  /* ..........................................................................
    
  Procedure: pc_cadeia
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Listar as cadeias por cooperativa e tipo de cadeia com o horario de termino alinahr no e-mail
    
  Alteracoes: 
    
  ............................................................................. */   
  
  -- selecionar todas cadeias
  CURSOR cr_cadeia
  IS  
    SELECT * FROM (
      SELECT t.nrsolici , t2.inexclus, t2.nrordsol
            ,COUNT(*)    qtprogra
      FROM   crapprg t 
            ,crapord t2  
      WHERE  T.cdcooper  = vr_cdcooper   
      AND    T.nrsolici  > 0  
      AND    T.inlibprg  = 1
      AND    t2.cdcooper = t.cdcooper   
      AND    t2.nrsolici = t.nrsolici 
      AND    t2.tpcadeia = vr_tpcadeia
      AND    (   vr_nrcadeia  = 0 
               OR t2.nrsolici = vr_nrcadeia
               ) 
      GROUP BY t.nrsolici , t2.inexclus, t2.nrordsol
      ) t20
    ORDER BY 3, 2 desc, 1;
    rw_cadeia    cr_cadeia%ROWTYPE; 
    vr_dsparaux  VARCHAR2(4000);
  
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_cadeia';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    
    vr_dsparaux := vr_dsparame;
    
    -- selecionar todos tipos de cadeia
    FOR rw_cadeia IN cr_cadeia  LOOP
      --
      vr_nrsolici := rw_cadeia.nrsolici;
      vr_qtprogra := rw_cadeia.qtprogra;
      vr_nrordsol := rw_cadeia.nrordsol;
      
      vr_dsparame := vr_dsparaux ||
                     ', vr_nrsolici:' || vr_nrsolici ||
                     ', vr_qtprogra:' || vr_qtprogra;
      
      IF rw_cadeia.inexclus = 1 THEN
        vr_dsexclus := 'Exclusiva';
      ELSE
        vr_dsexclus := 'Paralela ';
      END IF;
      
      pc_crapprg;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
    END LOOP;        
    
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_cadeia;
  --
  PROCEDURE pc_tipo_cadeia  
  IS
  /* ..........................................................................
    
  Procedure: pc_tipo_cadeia
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Abrir as rotinas em tipo de cadeia e listar dois emails por coopertiva
              Primeiro tipo cadeia 3 Noturna
              Segundo  tipo cadeia 1 Diaria
    
  Alteracoes:                            
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */  
  
  -- selecionar todos tipos de cadeia
  CURSOR cr_tipo_cadeia
    IS  
    SELECT  distinct t2.tpcadeia
    FROM    crapord t2 
    WHERE   t2.cdcooper = vr_cdcooper   
    AND     t2.tpcadeia IN (1, 3)
    AND     (   vr_nrcadeia = 0 
             OR t2.nrsolici = vr_nrcadeia ) 
    ORDER BY t2.tpcadeia desc; -- Listar a cadeia noturna em primeiro lugar
    rw_tipo_cadeia    cr_tipo_cadeia%ROWTYPE; 
  --  
  CURSOR cr_erro_tipo_cad_paralela
    IS
    SELECT  dtparada
           ,dtreinicio
           ,TO_NUMBER(REPLACE(TRUNC((((dtreinicio) - (dtparada)) * 24 * 60 ),2),',''.')) qthrparada
           ,TO_CHAR(TRUNC(TO_NUMBER(REPLACE(TRUNC((((dtreinicio) - (dtparada)) * 24 * 60 ),2),',''.'))), 'FM900')
            || ':' 
            || TO_CHAR(MOD((TO_NUMBER(REPLACE(TRUNC((((dtreinicio) - (dtparada)) * 24 * 60 ),2),',''.')) * 60), 60), 'FM00') hrparada
    FROM (
    SELECT  t2.dhocorrencia dtparada
         ,( SELECT MIN(t3.dhocorrencia)
            FROM   tbgen_prglog_ocorrencia  t3
            WHERE  t3.idprglog          = t2.idprglog
            AND    t3.dhocorrencia      > t2.dhocorrencia
            AND    NVL(t3.cdmensagem,0) = 1231 
          ) dtreinicio
    FROM   tbgen_prglog             t1
          ,tbgen_prglog_ocorrencia  t2 
    WHERE    t2.idprglog          = t1.idprglog
    AND      t1.cdcooper          = vr_cdcooper 
    AND      t1.cdprograma        = vr_cdproctl
    AND      NVL(t2.cdmensagem,0) = 1229
    AND      t1.dhinicio          >= TRUNC(vr_dtmovime) 
    ORDER BY t1.dhinicio desc  , t2.dhocorrencia
    ) T4;
    rw_erro_tipo_cad_paralela    cr_erro_tipo_cad_paralela%ROWTYPE; 
  --  
  CURSOR cr_erro_programa_na_paralela
    IS
    SELECT  t1.cdprograma  cdprogra
           ,RPAD(t3.dsprogra##1 ||
                 t3.dsprogra##2 ||
                 t3.dsprogra##3 ||
                 t3.dsprogra##4,93,' ' ) dsprogra
    FROM   tbgen_prglog             t1
          ,tbgen_prglog_ocorrencia  t2
          ,crapprg                  t3
    WHERE    t2.idprglog          = t1.idprglog
    AND      t1.cdcooper          = vr_cdcooper 
    AND      NVL(t2.cdmensagem,0) = 1278 
    AND      t1.dhinicio          >= TRUNC(vr_dtmovime)
    AND      TO_CHAR(t2.dhocorrencia,'HH24MISS') >= vr_hrinicio
    AND      TO_CHAR(t2.dhocorrencia,'HH24MISS') <= vr_hrfim
    AND      t3.cdcooper          = t1.cdcooper  
    AND      t3.cdprogra          = t1.cdprograma
    ORDER BY t2.dhocorrencia;
    rw_erro_programa_na_paralela    cr_erro_programa_na_paralela%ROWTYPE; 
  --
  --      
    vr_dsparaux       VARCHAR2(4000);
    -- Tratar programa exclusivo retirado da cadeia e não reexecutado - 01/11/2018 - REQ0032025
    vr_dtreinicio2    DATE;
    vr_hrparada       VARCHAR2  (20);
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_tipo_cadeia';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    
    vr_dsparaux := vr_dsparame;
    
    -- selecionar todos tipos de cadeia
    FOR rw_tipo_cadeia IN cr_tipo_cadeia  LOOP
      --
      vr_tpcadeia := rw_tipo_cadeia.tpcadeia;
      
      vr_dsparame := vr_dsparaux ||
                     ', vr_tpcadeia:' || vr_tpcadeia;
    
      IF vr_tpcadeia = 3 THEN
        vr_dstipcad := 'Noturna';
        vr_cdproctl := 'CRPS359.P';
      ELSIF vr_tpcadeia = 1 THEN
        vr_dstipcad := 'Diaria';
        vr_cdproctl := 'CRPS000.P';
      ELSE
        vr_dstipcad := 'Não identificada';
      END IF;
      
      -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484            
      vr_dscb1pad := ' - Cooperativa: '      || vr_cdcooper || ' ' || vr_nmrescop ||
                     ' - Gerado em: '        || TO_CHAR(vr_dtsysdat,'DD/MM/YYYY HH24:MI:SS');   
      
      vr_dscb2pad := 'Data parâmetro: ' || vr_dtmovime || 
                     ' - Tipo Cadeia: '      || vr_tpcadeia || ' ' || vr_dstipcad ||
                     ' - Data lote: ' || vr_dtmvtoan;  
                     
      vr_qtprogra := 0;            
      vr_qterros  := 0;
      vr_qttoterr := 0;
      vr_qtpenden := 0;
      vr_qttotpen := 0;
      vr_inarqres := true;
      vr_inarqpro := true;
      vr_inarqerr := true;
      vr_inarqpen := true;
      
      -- Verficar se tem registro 1229 com CRPS359.P ou CRPS000.P
      -- Verficar se tem registro 1278
      -- Para cada registro encontrado acumular em uma lista para ser incluida no e-mail. 
      vr_dslispla := NULL;
      vr_dslispl1 := NULL; 
      vr_dslispl2 := NULL;  
      vr_dslispl3 := NULL;   
      vr_hrinicio := '000000';
      vr_hrfim    := '230000';
      FOR rw_erro_tipo_cad_paralela IN cr_erro_tipo_cad_paralela LOOP
        
        vr_hrfim    := TO_CHAR(rw_erro_tipo_cad_paralela.dtparada,'HH24MISS');
        vr_dslispl2 := NULL;  
        vr_dslispl3 := NULL;  
        vr_ctprogra := 0;
        FOR rw_erro_programa_na_paralela IN cr_erro_programa_na_paralela LOOP
          vr_dslispl3 := '"' ||
                         rw_erro_programa_na_paralela.dsprogra ||
                         '" ' || 
                         rw_erro_programa_na_paralela.cdprogra;
          IF vr_dslispl2 IS NULL THEN
            vr_dslispl2 := vr_dslispl3;
          ELSE
            vr_dslispl2 := vr_dslispl2 || ', ' || --  '<br>' ||
                           vr_dslispl3;
          END IF;
          vr_ctprogra := vr_ctprogra + 1;
          
          vr_index_tbgen_prglog_ocor := vr_index_tbgen_prglog_ocor + 1;                   
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idtipo       := 'L';        
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).cdcooper     := vr_cdcooper;
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).nrsolici     := 0;
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idocorrencia := 0;
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).dsmensagem   := 'Programa paralelo que interrompeu a cadeia';
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).cdprogra     := rw_erro_programa_na_paralela.cdprogra;  
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).hrparada     := '00:00:00';
          
        END LOOP;
        
        IF vr_ctprogra = 1 THEN
          vr_dslispl1 := 'O programa ' || vr_dslispl2 || ' ' ||
                         'referente a cadeia paralela ' ||
                         'teve sua execução interrompida '; 
        ELSE
          vr_dslispl1 := 'Os programas ' || vr_dslispl2 || ' ' ||
                         'referentes a cadeia paralela ' ||
                         'tiveram suas execuções interrompidas ';
        END IF; 
        
        -- Tratar programa exclusivo retirado da cadeia e não reexecutado - 01/11/2018 - REQ0032025             
        IF rw_erro_tipo_cad_paralela.dtreinicio IS NOT NULL THEN
          vr_hrinicio := TO_CHAR(rw_erro_tipo_cad_paralela.dtreinicio,'HH24MISS');
          vr_hrparada := rw_erro_tipo_cad_paralela.hrparada;
        ELSE
          BEGIN
            SELECT MIN(t3.dhocorrencia) 
            INTO   vr_dtreinicio2
            FROM   tbgen_prglog_ocorrencia  t3
            WHERE  t3.dhocorrencia      > rw_erro_tipo_cad_paralela.dtparada
            AND    NVL(t3.cdmensagem,0) = 1231; 
          EXCEPTION 
            WHEN NO_DATA_FOUND THEN  
              vr_dtreinicio2 := NULL;  
            WHEN vr_exc_montada THEN  
              RAISE vr_exc_montada;  
            WHEN vr_exc_erro_tratado THEN 
              RAISE vr_exc_erro_tratado; 
            WHEN vr_exc_others THEN 
              RAISE vr_exc_others; 
            WHEN OTHERS THEN   
              -- No caso de erro de programa gravar tabela especifica de log
              cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
              -- Trata erro
              pr_cdcritic := 1036;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                             ' tbgen_prglog_ocorrencia(3): ' ||
                             vr_dsparame           ||
                             ', vr_dslispl3:' || vr_dslispl3 ||
                             ', vr_dslispl2:' || vr_dslispl2 ||
                             ', rw_erro_tipo_cad_paralela.dtparada:' || rw_erro_tipo_cad_paralela.dtparada ||
                             '. ' || SQLERRM; 
              RAISE vr_exc_montada;    
          END;  
          IF vr_dtreinicio2 IS NOT NULL THEN
            vr_hrinicio := TO_CHAR(vr_dtreinicio2,'HH24MISS');
            vr_hrparada :=         
            TO_CHAR(TRUNC(TO_NUMBER(REPLACE(TRUNC((((vr_dtreinicio2) - (rw_erro_tipo_cad_paralela.dtparada)) * 24 * 60 ),2),',''.'))), 'FM900') ||
            ':' ||
            TO_CHAR(MOD((TO_NUMBER(REPLACE(TRUNC((((vr_dtreinicio2) -  (rw_erro_tipo_cad_paralela.dtparada)) * 24 * 60 ),2),',''.')) * 60), 60), 'FM00');                
        
          ELSE
            vr_hrinicio := NULL;   
          END IF;  
        END IF;     
        
        
        vr_ctsequec := vr_ctsequec + 1;
        -- Tratar programa exclusivo retirado da cadeia e não reexecutado - 01/11/2018 - REQ0032025    
        vr_dslispla := TO_CHAR(vr_ctsequec,'9900') || 
                       '&nbsp;-&nbsp;' || 
                       vr_dslispl1 ||
                       'devido a erros (o que gerou um atraso de ' || 
                       vr_hrparada || 
                       ' minutos).'; 
              
        IF vr_dslisexe IS NULL THEN
          vr_dslisexe := vr_dslispla;  
        ELSE
          vr_dslisexe := vr_dslisexe || '<br>' || vr_dslispla;  
        END IF;
        
        -- atributo vr_hrinicio foi movido daqui e incluido pouco mais acima - 01/11/2018 - REQ0032025
        
      END LOOP;   
            
      pc_cadeia;
      
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      IF NOT vr_inarqres THEN      
        pc_fecha_arquivo(vr_dsarqres ) ;
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      
      IF vr_qttoterr > 0 AND NOT vr_inarqpro THEN       
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => '');   
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => 'Total de erros: ' ||  vr_qttoterr );
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      
      IF vr_qttotpen > 0 AND NOT vr_inarqpro THEN          
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => '');   
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => 'Total de pendencias: ' ||  vr_qttotpen ); 
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;

      IF NOT vr_inarqpro THEN                             
        --               
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => '' ); 
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => 
                      'Resumo da movimentação de lançamentos para apontar se o batch executou com movimento acima da média.');
        pc_grava_linha(pr_utlfileh => vr_dsarqpro
                      ,pr_des_text => vr_nmlisprm ); 
        --               
        pc_fecha_arquivo(vr_dsarqpro ) ;
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      
      IF NOT vr_inarqerr THEN
        pc_fecha_arquivo(vr_dsarqerr);
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      
      IF NOT vr_inarqpen THEN
        pc_fecha_arquivo(vr_dsarqpen);
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
      
    END LOOP;  
    
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_tipo_cadeia;   
  --  
  PROCEDURE pc_crapcop  
  IS
  /* ..........................................................................
    
  Procedure: pc_crapcop
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata cadastro de cooperativa
    
  Alteracoes:                            
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - Tratar programa exclusivo retirado da cadeia
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */   
    
  --
  -- Lista erros que não retornaram ao Progress "PROGRAMA COM ERRO", exemplo programa em loop 
  CURSOR cr_erro_outros
    IS
    SELECT 
          t10.cdcooper
         ,t10.cdprograma
         ,t10.dhinicio
         ,t10.dtreinicio 
         ,( SELECT MAX(t3.dhinicio)
            FROM   tbgen_prglog             t3
            WHERE  TRUNC(t3.dhinicio) = TRUNC(t10.dhinicio)
            AND    t3.cdcooper        = t10.cdcooper 
            AND    t3.dhinicio        < t10.dhinicio
            AND    t3.cdprograma      = t10.cdprograma
          ) dtparada
         ,( SELECT MAX(t3.dhinicio)
            FROM   tbgen_prglog             t3
                  ,tbgen_prglog_ocorrencia  t4
            WHERE  TRUNC(t3.dhinicio) = TRUNC(t10.dhinicio)
            AND    t3.cdcooper        = t10.cdcooper 
            AND    t3.dhinicio        < t10.dhinicio
            AND    t3.cdprograma      LIKE 'CRPS%.P'
            AND    t4.idprglog        = t3.idprglog
            AND    t4.cdmensagem      = 1229
          ) dtpar002
         ,( SELECT REPLACE(t3.cdprograma,'.P','') cdproant
            FROM   tbgen_prglog             t3
                  ,tbgen_prglog_ocorrencia  t4
            WHERE  TRUNC(t3.dhinicio) = TRUNC(t10.dhinicio)
            AND    t3.cdcooper        = t10.cdcooper 
            AND    t3.dhinicio        < t10.dhinicio
            AND    t3.cdprograma      LIKE 'CRPS%.P'
            AND    t4.idprglog        = t3.idprglog
            AND    t4.cdmensagem      = 1229
            AND    t3.dhinicio        = 
              ( SELECT MAX(t33.dhinicio)
              FROM   tbgen_prglog             t33
                    ,tbgen_prglog_ocorrencia  t44
              WHERE  TRUNC(t33.dhinicio) = TRUNC(t10.dhinicio)
              AND    t33.cdcooper        = t10.cdcooper 
              AND    t33.dhinicio        < t10.dhinicio
              AND    t33.cdprograma      LIKE 'CRPS%.P'
              AND    t44.idprglog        = t33.idprglog
              AND    t44.cdmensagem      = 1229 )
          ) cdproant
    FROM
    ( SELECT  
          t1.cdcooper
         ,t1.dhinicio
         ,REPLACE(t1.cdprograma,'.P','') cdprograma
         ,t2.dhocorrencia dtreinicio
      FROM   tbgen_prglog             t1
            ,tbgen_prglog_ocorrencia  t2 
      WHERE    t2.idprglog          = t1.idprglog
      AND      t1.cdcooper          = vr_cdcooper 
      AND      t1.cdprograma        NOT IN ('CRPS359.P', 'CRPS000.P')
      AND      NVL(t2.cdmensagem,0) = 1231 
      AND      t1.dhinicio          >= vr_dtmovime
      ORDER BY t1.dhinicio desc  
             , t2.dhocorrencia
    ) T10
    ORDER BY t10.dhinicio desc  
           , t10.dtreinicio;
  
    rw_erro_outros  cr_erro_outros%ROWTYPE;
  
    vr_dsparaux       VARCHAR2(4000);
    vr_hrparada       VARCHAR2  (10);
    vr_inerrout       BOOLEAN;
    vr_inexclus       crapord.inexclus%TYPE;
  
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_crapcop';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    
    vr_cdcooper := NVL(pr_cdcopprm,0);    
    vr_dsparaux := vr_dsparame;
        
    -- Varre tabela "interna" com as cooperativas liberadas
    FOR vr_idoco IN 1 ..  vr_tab_cooper.COUNT LOOP
      --
      vr_cdcooper := vr_tab_cooper(vr_idoco).cdcooper;
      vr_cdcooinp := vr_cdcooper;
      vr_dsparame := vr_dsparaux ||
                     ', vr_cdcooper:' || vr_cdcooper;    
      
      IF NVL(pr_cdcopprm,0) = 0 THEN
        -- Log de fim de execucao
        pc_controla_log_batch(pr_dstiplog => 'I');
      END IF;
      --
      vr_nmrescop := vr_tab_cooper(vr_idoco).nmrescop;
      -- Eliminada vr_dtmvtolt - 09/10/2018 - Chd REQ0029484
      --vr_dtmvtolt := vr_tab_cooper(vr_idoco).dtmvtolt;
      vr_dtmvtoan := vr_tab_cooper(vr_idoco).dtmvtoan;
      vr_tpcadeia := 0;
      vr_dsexclus := 'NULL';      
      vr_dshorfim := '00:00';
      vr_nmlisope := NULL;  
      vr_nmlisger := NULL; 
      vr_dshorult := NULL;
      vr_dsdatult := NULL;
      vr_nmresult := NULL; 
      vr_nrsolult := NULL;
      --
      vr_nmlisfim := NULL;  
      vr_dslisexe := NULL;
      --
      vr_ctsequec := 0;
      vr_dslisver := NULL;
      vr_dslispad := NULL;
      vr_dsdiamov := NULL;
      vr_dsfimobs := NULL; 
      vr_dslispr1 := NULL;
      --
      IF pr_dtmovime IS NULL THEN
        -- Assume sysdate no lugar da dtmvtlt crapdat - 09/10/2018 - Chd REQ0029484
        -- vr_dtmovime := vr_dtmvtolt;
        vr_dtmovime := TRUNC(vr_dtsysdat); 
      ELSE
        vr_dtmovime := pr_dtmovime;
        vr_dtmvtoan := GENE0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper         -- Cooperativa conectada
                                                  ,pr_dtmvtolt => ( vr_dtmovime - 1 ) -- Data do movimento
                                                  ,pr_tipo     => 'A'                 -- Tipo de busca (P = proximo, A = anterior)
                                                  );
      END IF;
    
      vr_dsparame := vr_dsparame ||
                   ', vr_dtmovime:' || vr_dtmovime;
                                           
      -- Regra 5
      -- Lista erros que não retornaram ao Progress "PROGRAMA COM ERRO", exemplo programa em loop 
      --
      vr_dslisout := NULL;
      FOR rw_erro_outros IN cr_erro_outros LOOP
         
        IF rw_erro_outros.dtpar002 IS NOT NULL AND 
           rw_erro_outros.dtparada IS NOT NULL AND 
           rw_erro_outros.dtpar002 >= rw_erro_outros.dtparada THEN
          vr_inerrout := false;
        ELSE
          
          BEGIN            
            SELECT t2.inexclus into 
                   vr_inexclus
            FROM   crapprg       t
                  ,crapord      t2
            WHERE  t.cdcooper  = vr_cdcooper 
            AND    t.inlibprg  = 1 
            AND    t2.cdcooper = t.cdcooper 
            AND    t2.nrsolici = t.nrsolici 
            AND    t.cdprogra  = REPLACE(rw_erro_outros.cdprograma,'.P');
          EXCEPTION 
            WHEN vr_exc_montada THEN  
              RAISE vr_exc_montada;  
            WHEN vr_exc_erro_tratado THEN 
              RAISE vr_exc_erro_tratado; 
            WHEN vr_exc_others THEN 
              RAISE vr_exc_others; 
            WHEN OTHERS THEN   
              -- No caso de erro de programa gravar tabela especifica de log
              cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
              -- Trata erro
              pr_cdcritic := 1036;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                             ' tbgen_prglog(3): ' ||
                            vr_dsparame           ||
                            ', cdcooper:' || rw_erro_outros.cdcooper ||
                            ', cdprogra:' || rw_erro_outros.cdprograma ||
                            ', dhinicio:' || rw_erro_outros.dhinicio ||
                            ', dtreinic:' || rw_erro_outros.dtpar002 ||
                            ', cdproant:' || rw_erro_outros.cdproant ||
                            ', dtparada:' || rw_erro_outros.dtparada ||
                            '. ' || SQLERRM; 
              RAISE vr_exc_montada;
          END;  
          IF vr_inexclus = 1 THEN
            vr_inerrout := false;
          ELSE
            vr_inerrout := true;
          END IF;
        END IF;
        
        IF rw_erro_outros.cdprograma <> rw_erro_outros.cdproant THEN
          IF rw_erro_outros.dtpar002 < rw_erro_outros.dhinicio THEN
            vr_inerrout := false;
          END IF;
        END IF;
        
        -- Log de acoompanhamento de exceção de erro
        pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                           '. Acompanhamento exc(1):' ||
                            vr_dsparame           ||
                            ', cdcooper:' || rw_erro_outros.cdcooper ||
                            ', cdprogra:' || rw_erro_outros.cdprograma ||
                            ', cdproant:' || rw_erro_outros.cdproant ||
                            ', dhinicio:' || TO_CHAR(rw_erro_outros.dhinicio,'YYYY-MM-DD HH24:MI:SS') ||
                            ', dtreinic:' || TO_CHAR(rw_erro_outros.dtpar002,'YYYY-MM-DD HH24:MI:SS') ||
                            ', dtparada:' || TO_CHAR(rw_erro_outros.dtparada,'YYYY-MM-DD HH24:MI:SS') ||
                            ', inexclus:' || vr_inexclus
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_cdcricid => 0 );
        
        IF vr_inerrout THEN
          
          vr_hrparada := 
          TO_CHAR(TRUNC(TO_NUMBER(REPLACE(TRUNC((((rw_erro_outros.dtreinicio) - (rw_erro_outros.dtparada)) * 24 * 60 ),2),',''.'))), 'FM900')
          || ':'
          || TO_CHAR(MOD((TO_NUMBER(REPLACE(TRUNC((((rw_erro_outros.dtreinicio) - (rw_erro_outros.dtparada)) * 24 * 60 ),2),',''.')) * 60), 60), 'FM00');
          
          vr_index_tbgen_prglog_ocor := vr_index_tbgen_prglog_ocor + 1;                   
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idtipo       := 'O';        
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).cdcooper     := vr_cdcooper;
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).nrsolici     := 0;
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idocorrencia := 0;
          
          -- Erro registrado apenas no proc_batch.log(Particularidade Progress)         
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).dsmensagem   := gene0001.fn_busca_critica(pr_cdcritic => 1281)  ||
                                                                               ', dtparada: '   || rw_erro_outros.dtparada ||
                                                                               ', dtpar002: '   || rw_erro_outros.dtpar002 ||
                                                                               ', dtreinicio: ' || rw_erro_outros.dtreinicio;
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).cdprogra     := rw_erro_outros.cdprograma;  
          vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).hrparada     := vr_hrparada;
        END IF;                   
          
      END LOOP;               
                                      
      vr_fgftulpr := TRUE;   
      BEGIN
        --  
        SELECT  NVL(TO_CHAR(MAX(t13.dhfim),'HH24MI'),'0800') 
        INTO    vr_dsulthor
        FROM    tbgen_prglog  t13 
        WHERE   t13.cdcooper     = vr_cdcooper
        AND     TRUNC(t13.dhfim) = vr_dtmovime 
        AND     t13.cdprograma   = vr_cdultpro;
      EXCEPTION 
        WHEN NO_DATA_FOUND THEN
          vr_dsulthor := '0800';
          vr_fgftulpr := FALSE;    
        WHEN vr_exc_montada THEN  
          RAISE vr_exc_montada;  
        WHEN vr_exc_erro_tratado THEN 
          RAISE vr_exc_erro_tratado; 
        WHEN vr_exc_others THEN 
          RAISE vr_exc_others; 
        WHEN OTHERS THEN   
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
          -- Trata erro
          pr_cdcritic := 1036;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                         ' tbgen_prglog(4): ' ||
                         vr_dsparame          ||
                         '. ' || SQLERRM; 
          RAISE vr_exc_montada;
      END;
      IF vr_dsulthor > '0800' THEN
        vr_dsulthor := '0800';
      END IF;

      vr_cdacesso := 'ALERTA_VERMELHO';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_qtlimver := TO_NUMBER(vr_dsvlrprm);

      vr_cdacesso := 'ALERTA_AMARELO';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_qtlimama := TO_NUMBER(vr_dsvlrprm);

      vr_cdacesso := 'PCT_MVT_LST_TBGEN';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_prmvtdia := TO_NUMBER(vr_dsvlrprm);
      
      -- Log de término de execucao da parte 1
      pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                           '. Inicio parte CRAPLCM'
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 3
                           ,pr_cdcricid => 0 );
      
      vr_dtdia    := 1;
      vr_qtdiauti := 0;
      vr_qtlanmen := 0;
      vr_dtmesant := ADD_MONTHS(vr_dtmovime,-1);
      
      LOOP
        -- Monta Calendario
        --vr_dtmovent := TO_CHAR(vr_dtdia,'00') || '/' || TO_CHAR(vr_dtmesant,'MM/YYYY');
        -- Ajuste do padrão Decimal/Data - 06/09/2018 - Chd REQ0026091
        vr_dtmovent := TO_CHAR(vr_dtdia,'00') || '/' || TO_CHAR(vr_dtmesant,'MON/RR');         
        -- Verifica se o dia de execução da cadeia foi um dia de movimento atipico
        vr_dtmovtab := GENE0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper -- Cooperativa conectada
                                                  ,pr_dtmvtolt => vr_dtmovent -- Data do movimento
                                                  ,pr_tipo     => 'A'         -- Tipo de busca (P = proximo, A = anterior)
                                                  );
        -- Busca dia util
        IF vr_dtmovtab = vr_dtmovent THEN
          vr_qtdiauti := vr_qtdiauti + 1;
          -- Busca lançamentos do extrato bancario     
          BEGIN
            SELECT /*+ index (crap craplcm##craplcm4)*/          
                  COUNT(*) INTO vr_qtlantab
            FROM  craplcm crap
            WHERE crap.dtmvtolt = vr_dtmovent
            AND   crap.cdcooper = vr_cdcooper;
          EXCEPTION 
            WHEN vr_exc_montada THEN  
              RAISE vr_exc_montada;  
            WHEN vr_exc_erro_tratado THEN 
              RAISE vr_exc_erro_tratado; 
            WHEN vr_exc_others THEN 
              RAISE vr_exc_others; 
            WHEN OTHERS THEN   
             -- No caso de erro de programa gravar tabela especifica de log
             cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
            -- Trata erro
            pr_cdcritic := 1036;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                           ' craplcm(6): ' ||
                           vr_dsparame     ||
                           '. ' || SQLERRM; 
            RAISE vr_exc_montada;
          END;
          vr_qtlanmen := vr_qtlanmen + NVL(vr_qtlantab,0);
        END IF;              
        
        vr_dtdia := vr_dtdia + 1;
        IF vr_dtdia > TO_CHAR(LAST_DAY(vr_dtmesant),'DD') THEN
          EXIT;
        END IF;
      END LOOP;

      -- Busca dia do movimento em execução      
      BEGIN
        SELECT /*+ index (crap craplcm##craplcm4)*/
               COUNT(*) INTO vr_qtlantab
        FROM  craplcm crap
        WHERE crap.dtmvtolt = vr_dtmvtoan
        AND   crap.cdcooper = vr_cdcooper;
      EXCEPTION  
        WHEN vr_exc_montada THEN  
          RAISE vr_exc_montada;  
        WHEN vr_exc_erro_tratado THEN 
          RAISE vr_exc_erro_tratado; 
        WHEN vr_exc_others THEN 
          RAISE vr_exc_others; 
        WHEN OTHERS THEN   
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
          -- Trata erro
          pr_cdcritic := 1036;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                         ' craplcm(7): ' ||
                         vr_dsparame          ||
                         '. ' || SQLERRM; 
          RAISE vr_exc_montada;
      END;
      
      vr_qtlandia := NVL(vr_qtlantab,0);
        
      -- Log de término de execucao da parte 1
      pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                           '. Finalizado parte CRAPLCM'
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 3
                           ,pr_cdcricid => 0 );
      
      vr_qtmeddia := TRUNC (( vr_qtlanmen / vr_qtdiauti ));
      IF NVL(vr_qtmeddia,0) = 0 THEN
        vr_prmeddia := 0;
      ELSE
        vr_prmeddia := TRUNC (( ( vr_qtlandia * 100 ) / vr_qtmeddia ) ,2);
      END IF;
            
      -- Regra de execção 4
      -- Dia com excesso de movimento
      -- Se for então não listar a regra de execção 1
      IF (vr_prmeddia - 100) > vr_prmvtdia THEN
        vr_dsdiamov := vr_dslin300;
      ELSE
        vr_dsdiamov := NULL;
      END IF;     
                           
      vr_nmlisprm := 'Base mes:' || TO_CHAR(vr_dtmesant,'MM') ||
                     ' ; Dias Úteis: '    || vr_qtdiauti ||
                     ' ; Total mensal: '  || vr_qtlanmen || 
                     ' ; Media Diária: '  || vr_qtmeddia ||
                     ' ; Total dia: '     || vr_qtlandia ||
                     ' ; Med_X_Dia: '     || (vr_prmeddia - 100)  || '%' ||
                     ' ; Tolerância: '    || vr_prmvtdia || '%';            
            
      pc_tipo_cadeia;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);

      vr_cdacesso := 'LISTA_TBGEN_LIN_100';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin100 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_110';         
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin110 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_200';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin200 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_210';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin210 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_220';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin220 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_300';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin300 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_400';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin400 := vr_dsvlrprm;

      vr_cdacesso := 'LISTA_TBGEN_LIN_410';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dslin410 := vr_dsvlrprm;
                  
      IF vr_dshorult IS NOT NULL THEN       
        IF vr_nmlisfim IS NULL THEN
          vr_nmlisfim := vr_dslin100 || vr_nmresult || '</b>' || '</font>' || 
                         '<font size="3">' || '<b>' || ' - ' || vr_dsdatult || ' - ' || vr_dshorult || '</b>' || 
                         '</font>' || '<br>';
        END IF;
        IF NOT vr_fgftulpr THEN  
          -- Log de erro de execucao
          pc_controla_log_batch(pr_cdcritic => 1132
                               ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1132) ||
                                                vr_dsparame      || 
                                                ', vr_cdultpro:' || vr_cdultpro
                               ,pr_dstiplog => 'O'
                               ,pr_tpocorre => 3
                               ,pr_cdcricid => 0 );
        END IF;
      ELSE
        vr_nmlisfim := vr_dslin110 || vr_nmrescop || '</b>' || '</font>'  ||   
                       '<font size="3">' || '<b>' || ' - ' || TO_CHAR(vr_dtmvtoan,'DD/MM') || '</b>' || 
                       '</font>' || '<br>';
        vr_dsdiamov := NULL;
        vr_dslisexe := NULL;
      END IF;
      
      ---
    
      IF vr_dslisver IS NULL THEN 
        vr_dsdiamov := NULL;
      END IF;
    
      IF ( vr_dslisver IS NOT NULL 
          AND vr_dsdiamov IS NULL ) 
        OR
         vr_dslispr1 IS NOT NULL THEN
         IF vr_ctsequec = 1 THEN
           vr_dsfimobs := vr_dslin200;
         ELSE
           vr_dsfimobs := vr_dslin210;
         END IF;
      ELSE
         vr_dsfimobs := vr_dslin220;
      END IF;        
    
      vr_dsconteu := vr_nmlisfim  ||  '<br>' ||
                     vr_dslisexe  ||  '<br>' || '<br>' ||
                     vr_dsdiamov  ||  '<br>' ||
                     vr_dsfimobs;
                     
      vr_dscontok := vr_dsconteu;               
      -- Tratar se o tamanho de caracteres do conteudo excese o limite do e-mail 
      IF LENGTH(vr_dscontok) > vr_qtmaxcon THEN
        vr_dscongra := vr_dscontok;
        vr_dscontok := vr_nmlisfim || '<br><br>' || 
                       vr_dslin400 ||
                       vr_qtmaxcon || 
                       vr_dslin410 || '<br>' || '<br>' ||
                       vr_dsdiamov || '<br>' ||
                       vr_dsfimobs;
        -- Abre arquivo
        pc_abre_arquivo(vr_nmarqcon
                       ,vr_tparqhtl
                       ,vr_dsarqcon) ;
        -- Grava o conteudo volumoso no arquivo        
        pc_grava_linha(vr_dsarqcon
                      ,vr_dscongra); 
        -- Fecha o arquivo
        pc_fecha_arquivo(vr_dsarqcon);
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      END IF;
            
      --Envia os emails
      vr_nmlisarq := vr_nmlisger;
      vr_dsacepos := 'PC_LISTA_TBGEN_EMAIL_1';
      vr_dstitema := 'Revitalização de Sistemas informa - Cooperativa ' || vr_nmrescop;
      pc_monta_e_mail;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      vr_nmlisarq := vr_nmlisope;
      vr_dsacepos := 'PC_LISTA_TBGEN_EMAIL_2';
      vr_dstitema := 'Cooperativa ' || vr_nmrescop || ' - Detalhes';
      pc_monta_e_mail;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);    
     
      IF NVL(pr_cdcopprm,0) = 0 THEN
        -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484
        -- Registrar como executado
        CECRED.gene0001.pc_controle_exec(pr_cdcooper  => vr_cdcooper   -- Código da coopertiva
                                        ,pr_cdtipope  => 'I'           -- Tipo de operacao I-incrementar e C-Consultar
                                        ,pr_dtmvtolt  => vr_dtsysdat       -- Data do movimento
                                        ,pr_cdprogra  => 'PCLISBATCH'  -- Codigo do programa
                                        ,pr_flultexe  => vr_flultexe   -- Retorna se é a ultima execução do procedimento
                                        ,pr_qtdexec   => vr_qtdexec    -- Retorna a quantidade
                                        ,pr_cdcritic  => vr_cdcritic   -- Codigo da critica de erro
                                        ,pr_dscritic  => vr_dscritic); -- descrição do erro se ocorrer
        -- Trata retorno
        IF nvl(vr_cdcritic,0) > 0         OR
          TRIM(vr_dscritic)   IS NOT NULL THEN
          -- Trata erro
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic; 
          RAISE vr_exc_montada;
        END IF;
        -- Retorno nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);  
      END IF;
                     
      IF NVL(pr_cdcopprm,0) = 0 THEN
        -- Log de fim de execucao
        pc_controla_log_batch(pr_dstiplog => 'F');
      END IF;  
    END LOOP;
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;                
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END  pc_crapcop;
  
  --
  PROCEDURE pc_lista_media
  IS
  /* ..........................................................................
    
  Procedure: pc_lista_media
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Carrega lista da média da execução dos cdprograma
    
  Alteracoes: 
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
  -- Eliminada CRAPDAT - 09/10/2018 - Chd REQ0029484  
  CURSOR cr_lista_media
  IS
  SELECT 
     t20.cdcooper      cdcooper
    ,t20.cdprogra      cdprogra
    ,SUM(t20.qtmintot) qtmintot
    ,MIN(t20.qtexetot) qtexetot
    ,SUM(t20.qtmintot) / MIN(t20.qtexetot) qtmedexe
  FROM (
    SELECT
     t.cdcooper   cdcooper
    ,t.cdprograma cdprogra
    ,SUM(TO_NUMBER(TRUNC((((t.dhfim) - (t.dhinicio)) * 24 * 60 ),2)))  qtmintot
    ,COUNT(*) qtexetot 
    FROM   tbgen_prglog  t
    WHERE  t.cdprograma   LIKE 'CRPS%.P'  
    AND    t.dhinicio     IS NOT NULL 
    AND    t.dhfim        IS NOT NULL		  
    AND    TRUNC(t.dhfim) < vr_dtmovime
    AND    t.idprglog        = 
    ( SELECT   MAX(t4.idprglog) 
        FROM   tbgen_prglog T4
       WHERE   t4.cdcooper   = t.cdcooper
         AND   t4.cdprograma = t.cdprograma
         AND   t4.dhinicio   IS NOT NULL 
                AND   t4.dhfim      IS NOT NULL
               AND    TRUNC(t4.dhinicio) = TRUNC(t.dhinicio)  
              ) group by  t.cdcooper, t.cdprograma
  ) t20
  WHERE ( t20.cdcooper,t20.cdprogra ) IN
    ( SELECT DISTINCT t.cdcooper, t.cdprogra || '.P'
    FROM   crapprg t 
           ,crapord t2
           ,crapcop t3
    WHERE  t3.flgativo = 1 
    AND    t.cdcooper  = t3.cdcooper  
    AND    t.nrsolici  <> 999  
    AND    t.inlibprg  = 1
    AND    t.nmsistem  = 'CRED'                           
    AND    t2.cdcooper = t.cdcooper    
    AND    t2.tpcadeia IN (1, 3)
    AND    t2.nrsolici <> 999     
    AND    t2.nrsolici = t.nrsolici  )           
  GROUP BY t20.cdcooper, t20.cdprogra;          
  --
  rw_lista_media cr_lista_media%ROWTYPE;
  vr_qtminmed crapprg.qtminmed%TYPE := 0;
  --  
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_lista_media';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    vr_cdprogra := NULL;
    vr_qtminmed := 0;
    
    -- Carrega lista de erros sem cdprograma relacionado em memoria
    FOR rw_lista_media IN cr_lista_media  LOOP   
      vr_cdprogra := REPLACE(rw_lista_media.cdprogra,'.P');
      vr_qtminmed := TRUNC(rw_lista_media.qtmedexe,5);
      BEGIN
        --      
        UPDATE crapprg t
        SET    t.qtminmed = vr_qtminmed
        WHERE t.cdcooper = rw_lista_media.cdcooper
        AND   t.cdprogra = vr_cdprogra
        AND   t.nmsistem = vr_nmsistem; 
        IF SQL%ROWCOUNT <> 1 THEN
          -- Trata erro
          pr_cdcritic := 1035;
          -- Quando não encontrou o registro
          IF SQL%ROWCOUNT = 0 THEN
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                           ' crapprg(9): ' ||
                           vr_dsparame     ||
                           ', cdcooper:'   || rw_lista_media.cdcooper ||
                           ', cdprogra:'   || vr_cdprogra ||
                           ', qtminmed:'   || vr_qtminmed ||
                           '. ' || 'Update não encontrou registro: '; 
          ELSE
            -- Quando encontrou mais de registro
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                           ' crapprg(10): ' ||
                           vr_dsparame     ||
                           ', cdcooper:'   || rw_lista_media.cdcooper ||
                           ', cdprogra:'   || vr_cdprogra ||
                           ', qtminmed:'   || vr_qtminmed ||
                           '. ' || 'Update encontrou ' || SQL%ROWCOUNT || ' registros.';
          END IF;
          RAISE vr_exc_montada;
        END IF;
      EXCEPTION
        WHEN vr_exc_montada THEN  
          RAISE vr_exc_montada;  
        WHEN vr_exc_erro_tratado THEN 
          RAISE vr_exc_erro_tratado; 
        WHEN vr_exc_others THEN 
          RAISE vr_exc_others; 
        WHEN OTHERS THEN   
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
          -- Trata erro
          pr_cdcritic := 1035;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                         ' crapprg(8): ' ||
                         vr_dsparame     ||
                         ', cdcooper:'   || rw_lista_media.cdcooper ||
                         ', cdprogra:'   || vr_cdprogra ||
                         ', qtminmed:'   || vr_qtminmed ||
                         '. ' || SQLERRM; 
          RAISE vr_exc_montada;
      END;
    END LOOP; 
    --      
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;            
  END pc_lista_media;  
  --
  PROCEDURE pc_tbgen_prg_ocorre_geral
  IS
  /* ..........................................................................
    
  Procedure: pc_tbgen_prg_ocorre_geral
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata cadastro de detalhe de Log --- Fora do Padrão
              Carrega lista de erros sem cdprograma relacionado em memoria
    
  Alteracoes: 
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - Criticas 1067/1066. Não é erro - 09/10/2018 - Chd REQ0029484
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
  --
    vr_cdprosel       VARCHAR2(100);
    vr_dtexctem       DATE;
    --
    -- Carrega lista de erros sem cdprograma relacionado em memoria
    -- A segunda QUERY lista erros de cooper 0 ou NULL ou Sem cadastro
    CURSOR cr_tbgen_prglog_ocorrencia 
    IS
      SELECT  t6.cdcooper  cdcopoco
             ,t7.cdcooper  cdcopcad
             ,t5.idocorrencia
             ,t6.cdprograma
             ,t5.dsmensagem
             ,t5.dhocorrencia
             ,t6.dhinicio
      FROM tbgen_prglog_ocorrencia  t5
          ,tbgen_prglog             t6
          ,crapcop                  t7  
      WHERE  TRUNC(t5.dhocorrencia)    = TRUNC(vr_dtsysdat)  
      AND    t5.cdmensagem             NOT IN (1229, 1278)
      AND   (   t5.tpocorrencia        IN (1,2) 
             OR UPPER( t5.dsmensagem ) LIKE '%ERRO%') 
      AND  TRUNC(t6.dhinicio)          = TRUNC(vr_dtsysdat)              
      AND    t6.idprglog               = T5.idprglog 
      AND  t7.cdcooper (+)             = t6.cdcooper
      AND  t7.flgativo (+)             = 1
    ORDER BY 6;
    --
    rw_tbgen_prglog_ocorrencia cr_tbgen_prglog_ocorrencia%ROWTYPE;       
    --
    
    vr_cdcopoco crapcop.cdcooper%TYPE;
    
    -- Selecionar programas de todas cadeias
    CURSOR cr_crapprg_tot  IS
    SELECT t2.*
    FROM   crapprg t2
          ,crapcop t3
    WHERE t3.cdcooper  = vr_cdcopoco
    AND   t2.cdcooper  = t3.cdcooper
    AND   t2.nmsistem  = vr_nmsistem
    AND   t2.inlibprg  = 1 -- 1=lib, 2=bloq e 3=em teste
    AND   t2.nrsolici  <> 999 -- = vr_nrsolici
    AND   t3.flgativo = 1
    ORDER BY T2.nrordprg;
    rw_crapprg_tot cr_crapprg_tot%ROWTYPE;
    --
    -- Carrega lista de registros de excesso e de retorno do tempo dexecução dos programas
    --
    -- Essa lista considera os movimentos da data do sysdate pelo motivo que 
    -- ao incluir registros 1262 e 1263 sera com a data de hoje
    -- e no caso de executar com parametro diferente da data atual estara validando todos registros da base
    --
    CURSOR cr_excesso_tempo
    IS
    SELECT cdcooper, cdprogra, dtexeexc, dtexepad FROM (
      SELECT DISTINCT 
	     t1.cdcooper cdcooper, t1.cdprograma cdprogra
        ,( SELECT MAX(t20.dhocorrencia) 
           FROM   tbgen_prglog t10
                 ,( SELECT DISTINCT t2.idprglog, t2.dhocorrencia 
                    FROM   tbgen_prglog_ocorrencia t2
                    WHERE  t2.dhocorrencia  >= vr_dtexctem
                    AND    t2.cdmensagem    = vr_cdexeexc ) t20
           WHERE  t10.cdcooper      = t1.cdcooper 
           AND    t10.cdprograma    = t1.cdprograma
           AND    t10.dhinicio      >= vr_dtexctem
           AND    t20.idprglog      = t10.idprglog ) dtexeexc
        ,( SELECT MAX(t20.dhocorrencia) 
           FROM   tbgen_prglog t10
                 ,( SELECT DISTINCT t2.idprglog, t2.dhocorrencia 
                    FROM   tbgen_prglog_ocorrencia t2
                    WHERE  t2.dhocorrencia  >= vr_dtexctem
                    AND    t2.cdmensagem    = vr_cdexepad ) t20
           WHERE  t10.cdcooper      = t1.cdcooper 
           AND    t10.cdprograma    = t1.cdprograma
           AND    t10.dhinicio      >= vr_dtexctem
           AND    t20.idprglog      = t10.idprglog ) dtexepad
      FROM   tbgen_prglog t1
            ,( SELECT DISTINCT t2.idprglog 
               FROM   tbgen_prglog_ocorrencia t2
               WHERE  t2.dhocorrencia  >= vr_dtexctem
               AND    t2.cdmensagem    IN ( vr_cdexeexc,  vr_cdexepad )) t2
      WHERE   t1.idprglog      = t2.idprglog
      AND     t1.dhinicio      >= vr_dtexctem
      ORDER BY  1,2,3 
      ) t50
    WHERE EXISTS ( 
    SELECT  1
    FROM    crapprg t52
           ,crapcop t53
    WHERE  t53.cdcooper = t50.cdcooper
    AND    t52.cdcooper = t53.cdcooper
    AND    t52.cdprogra = REPLACE(t50.cdprogra,'.P','')
    AND    t52.nmsistem = vr_nmsistem
    AND    t52.inlibprg = 1 
    AND    t52.nrsolici <> 999
    AND    t53.flgativo = 1 );
    rw_excesso_tempo cr_excesso_tempo%ROWTYPE; 
    --
    vr_inselect       BOOLEAN;
    vr_nrsolici       crapprg.nrsolici%TYPE;
  --  
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_tbgen_prg_ocorre_geral';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    vr_index_tbgen_prglog_ocor := 0;
    --    
    -- Carrega lista de erros sem cdprograma relacionado em memoria
    FOR rw_tbgen_prglog_ocorrencia IN cr_tbgen_prglog_ocorrencia  LOOP
      vr_cdcopoco := NVL(rw_tbgen_prglog_ocorrencia.cdcopoco,3);
      IF vr_cdcopoco <> NVL(rw_tbgen_prglog_ocorrencia.cdcopcad,0) THEN        
        vr_cdcopoco := 3;
      END IF;
      -- Varre tabela "interna" com as cooperativas liberadas
      FOR vr_idoco IN 1 ..  vr_tab_cooper.COUNT LOOP
        -- Seleciona cooperativa liberada
        IF vr_cdcopoco = 0                                OR
           vr_cdcopoco = vr_tab_cooper(vr_idoco).cdcooper OR
           vr_cdcopoco = pr_cdcopprm                         THEN             
      
          vr_inselect := false;
           
          -- Seleciona erros somente até o final da cadeia      
          IF TO_CHAR(rw_tbgen_prglog_ocorrencia.dhocorrencia,'HH24MI') <= vr_tab_cooper(vr_idoco).hrultpro THEN

            -- Selecionar programas de todas cadeias
            FOR rw_crapprg_tot IN cr_crapprg_tot  LOOP 
              vr_cdprosel := '%'|| rw_crapprg_tot.cdprogra || '%';        

              IF  UPPER( rw_tbgen_prglog_ocorrencia.dsmensagem ) LIKE vr_cdprosel
              OR  NVL(rw_tbgen_prglog_ocorrencia.cdprograma,'0') LIKE vr_cdprosel THEN          
                vr_inselect := true;
                vr_cdprogra := rw_crapprg_tot.cdprogra;
                vr_nrsolici := rw_crapprg_tot.nrsolici;
                EXIT;
              END IF;
            END LOOP; 
             
          END IF;  

          IF vr_inselect THEN   
         
            vr_index_tbgen_prglog_ocor := vr_index_tbgen_prglog_ocor + 1;        
            IF   UPPER( rw_tbgen_prglog_ocorrencia.dsmensagem ) LIKE '%191 - ARQUIVO INTEGRADO COM REJEITADOS%'
              OR UPPER( rw_tbgen_prglog_ocorrencia.dsmensagem ) LIKE '%190 - ARQUIVO INTEGRADO COM SUCESSO%'
              OR UPPER( rw_tbgen_prglog_ocorrencia.dsmensagem ) LIKE '%219 - INTEGRANDO ARQUIVO%'  
              OR (    rw_tbgen_prglog_ocorrencia.dsmensagem LIKE '%182 - Arquivo nao existe%'
                  AND rw_tbgen_prglog_ocorrencia.cdprograma IN 
                     ('CRPS533','CRPS534','CRPS535'
                     ,'CRPS536','CRPS541','CRPS543'
                     ,'CRPS602','CRPS625','CRPS626'
                    ,'CRPS647','CRPS673','CRPS681')           
                 )        
              OR (    rw_tbgen_prglog_ocorrencia.dsmensagem LIKE '%258 - Nao ha arquivo%'
                  AND rw_tbgen_prglog_ocorrencia.cdprograma IN 
                     ('CRPS346','CRPS444','CRPS594') 
                 )
              OR (    rw_tbgen_prglog_ocorrencia.dsmensagem LIKE '%ARQUIVO INTEGRADO%'
                 AND rw_tbgen_prglog_ocorrencia.cdprograma = 'CRPS657' )
            THEN
              vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idtipo := 'P';
              
            ELSIF rw_tbgen_prglog_ocorrencia.dsmensagem LIKE '%1066 - Inicio execução%' OR
                  rw_tbgen_prglog_ocorrencia.dsmensagem LIKE '%1067 - Termino execução%'  
            THEN
              vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idtipo := 'P';
            ELSE
              vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idtipo := 'E';
            END IF;
            vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).cdcooper     := vr_cdcopoco;
            vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).nrsolici     := vr_nrsolici;
            vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).idocorrencia := rw_tbgen_prglog_ocorrencia.idocorrencia;
            vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).dsmensagem   := rw_tbgen_prglog_ocorrencia.dsmensagem;
            vr_tab_tbgen_prglog_ocor(vr_index_tbgen_prglog_ocor).cdprogra     := vr_cdprogra;
          END IF;           
        END IF;
      END LOOP;                
    END LOOP;    
    --
    -- Log de término de execucao da parte pc_tbgen_prg_ocorre_geral
    pc_controla_log_batch(pr_cdcritic => 1201
                         ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                         '. Finalizado pc_tbgen_prg_ocorre_geral Parte 1'
                         ,pr_dstiplog => 'O'
                         ,pr_tpocorre => 4
                         ,pr_cdcricid => 0 );
    
    vr_dtexctem := ADD_MONTHS(vr_dtsysdat,-1);
    -- Carrega lista de programas que estrapolaram o tempo padrão
    FOR rw_excesso_tempo IN cr_excesso_tempo  LOOP        
      vr_index_tbgen_prglog_duracao := vr_index_tbgen_prglog_duracao + 1;
      vr_tab_tbgen_prglog_duracao(vr_index_tbgen_prglog_duracao).cdcooper := rw_excesso_tempo.cdcooper;
      vr_tab_tbgen_prglog_duracao(vr_index_tbgen_prglog_duracao).cdprogra := rw_excesso_tempo.cdprogra;      
      vr_tab_tbgen_prglog_duracao(vr_index_tbgen_prglog_duracao).dtexeexc := rw_excesso_tempo.dtexeexc;
      vr_tab_tbgen_prglog_duracao(vr_index_tbgen_prglog_duracao).dtexepad := rw_excesso_tempo.dtexepad;
    END LOOP;
      
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;
  END pc_tbgen_prg_ocorre_geral;  
  --  
  PROCEDURE pc_execucao_aprovada
  IS
  /* ..........................................................................
    
  Procedure: pc_execucao_aprovada
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Execução aprovada
    
  Alteracoes: 
    
  ............................................................................. */
  --
  --  
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_execucao_aprovada';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
                          
    vr_nrcadeia := NVL(pr_nrcadeia,0);                 
    vr_cdultpro := 'CRPS659.P';
    vr_cdexeexc := 1262;
    vr_cdexepad := 1263;  
    vr_cdexcamd := 1264;    
    -- Carrega lista: Erros sem cdprograma relacionado em memoria e Tempos excessivos e retorno da normalidade
    pc_tbgen_prg_ocorre_geral;   
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);    
    -- Log de término de execucao da parte pc_tbgen_prg_ocorre_geral
    pc_controla_log_batch(pr_cdcritic => 1201
                         ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                         '. Finalizado pc_tbgen_prg_ocorre_geral Parte 2'
                         ,pr_dstiplog => 'O'
                         ,pr_tpocorre => 4
                         ,pr_cdcricid => 0 );
                       
    -- Atualiza média de tempo de xecução de programas senão não atualiza média               
    IF pr_idatzmed = 'S' THEN
      
      pc_lista_media;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);      
      -- Log de término de execucao da parte pc_lista_media
      pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                           '. Finalizado pc_lista_media'
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_cdcricid => 0 );
    END IF;
    
    -- Trata cooperativas
    pc_crapcop; 
    ----------
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
  
    -- Limpa as tabelas internas      
    vr_tab_tbgen_prglog_ocor.DELETE;
    vr_tab_tbgen_prglog_duracao.DELETE;
      
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;      
  END pc_execucao_aprovada;    
  --  
  --               
  -- pc_cria_job 
  PROCEDURE pc_cria_job 
  IS
  /* ..........................................................................
    
  Procedure: pc_cria_job
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Cria job
    
  Alteracoes:                            
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
  --
  --  
    vr_jobname     VARCHAR2  (100);
    vr_dsplsql     VARCHAR2 (4000);
    vr_dtagenda    DATE;
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_cria_job';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    -- Job permanente: JBPRG_LISTA_BATCH
    -- Job reagendado: JBPRG_R_LISTA_BAT_$123456789    
    vr_jobname  := 'JBPRG_R_LISTA_BAT'||'_'||'$';
    vr_dsplsql  := 
      'DECLARE
         vr_cdcritic     INTEGER:= 0;
         vr_dscritic     VARCHAR2(4000);
       BEGIN         
            
         CECRED.PC_LISTA_TBGEN
         ( pr_cdcopprm  => ''0'' 
         , pr_nrcadeia  => ''0'' 
         , pr_dtmovime  => NULL
         , pr_idatzmed  => ''N''
         , pr_cdcritic  => vr_cdcritic  
         , pr_dscritic  => vr_dscritic
         );
         IF vr_dscritic IS NOT NULL THEN
           raise_application_error(-20001,vr_dscritic);
         END IF;
       END;';
    -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484
    --Horario de agendamento
    vr_dtagenda := ( vr_dtsysdat + (( ( SUBSTR(vr_hrageexe,1,2) * 60 ) + SUBSTR(vr_hrageexe,4,2) ) /1440) );
    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper     -- Código da cooperativa
                          ,pr_cdprogra  => vr_cdprogra     -- Código do programa
                          ,pr_dsplsql   => vr_dsplsql      -- Bloco PLSQL a executar
                          ,pr_dthrexe   => vr_dtagenda     -- Horario da execução
                          ,pr_interva   => NULL            -- apenas uma vez
                          ,pr_jobname   => vr_jobname      -- Nome randomico criado
                          ,pr_des_erro  => vr_dscritic);
    IF TRIM(vr_dscritic) is not null THEN
      -- Montar mensagem de critica
      pr_cdcritic := 1197;
      pr_dscritic := 'retorno gene0001.pc_submit_job' ||
                     ' , vr_jobname:'  || vr_jobname ||
                     ' , vr_dsplsql:'  || vr_dsplsql ||
                     ' , vr_dtagenda:'  || vr_dtagenda ||
                     ' , vr_dscritic:' || vr_dscritic;
      RAISE vr_exc_erro_tratado;    
    END IF;
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);           
      
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;            
  END pc_cria_job;            
  --                                           
  -- pc_posiciona_dat 
  PROCEDURE pc_posiciona_dat(pr_cdcooperprog IN crapcop.cdcooper%TYPE
                            ,pr_fgferiado    OUT BOOLEAN
                            ) 
  IS
  /* ..........................................................................
    
  Procedure: pc_posiciona_dat
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : posiciona DATAS
    
  Alteracoes: 
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
  --
  --  
    rw_crapdat            BTCH0001.cr_crapdat%ROWTYPE;	 
    vr_datautil           DATE;
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_posiciona_dat';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooperprog);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
         pr_cdcritic := 1;
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
         RAISE vr_exc_erro_tratado;
    ELSE
        -- Fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
    END IF;                   
    -- Verifica se a cadeia da cooperativa especifica terminou
    vr_inproces := rw_crapdat.Inproces;
    -- Eliminada dtmvtlt CRAPDAT - 09/10/2018 - Chd REQ0029484
    --vr_dtmvtolt := rw_crapdat.dtmvtolt;
    vr_dtmvtoan := rw_crapdat.dtmvtoan;    
    -- trata feriado
    vr_datautil := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooperprog -- Cooperativa conectada
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtoan  -- Data do movimento
                                              --pr_tipo in varchar2 default 'P',      -- Tipo de busca (P = proximo, A = anterior)
                                              --pr_feriado IN BOOLEAN DEFAULT TRUE,   -- Considerar feriados
                                              --pr_excultdia IN BOOLEAN DEFAULT FALSE -- Desconsiderar Feriado 31/12
                                              );
    IF vr_datautil <> rw_crapdat.dtmvtoan THEN
      pr_fgferiado := FALSE;
    ELSE
      pr_fgferiado := FALSE;
    END IF;      
              
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;  
        
  END pc_posiciona_dat;                   
  --
  PROCEDURE pc_controle_execucao
  IS
  /* ..........................................................................
    
  Procedure: pc_controle_execucao
  Sistema  : Rotina de Log
  Autor    : Belli/Envolti
  Data     : 03/05/2018                        Ultima atualizacao: 09/10/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Controle de execução.
  
  Regras 01: Se o batch terminou até o horário previsto para execução.
         02: Se o horário agendado não passou do limite previsto para execução.
         03: O sistema reagenda de tempo em tempo conforme parametro.
         04: Esse 3 parãmetros seguem a regra de cooperativa parametrizada, se houver 
             cooper específica vale a propria senão vale o parametro de cooper ZERO.
             Neste caso o acesso é LISTA_TBGEN_AGENDA no cadastro CRAPPRM
             Descrição do valor exemplo: 05:30;00:30;16:00
             a) Horario previsto para execução
             b) Tempo de reagendamento(Tempo de espera para nova tentativa de execução)
             c) Horário limite previsto para execução
         05: Senão executar no dia registra um ALERTA no sistema.
         06: Para obter a execução aprovada precisa obter a Regra 01 e 02.
    
  Alteracoes:                            
              09/10/2018 - Eliminar a utilização do dtmvtolt CRAPDAT
                         - (Envolti - Belli - Chamado - REQ0029484)
    
  ............................................................................. */
  --
    -- Selecionar lista de Cooperativas ativas
    CURSOR cr_crapcop_ativas  IS
         SELECT cop.cdcooper
               ,cop.nmrescop
         FROM crapcop cop
         WHERE cop.flgativo = 1 
         AND ( cop.cdcooper = pr_cdcopprm 
              OR NVL(pr_cdcopprm,0) = 0 )                  
         ORDER BY cop.cdcooper;
    rw_crapcop_ativas cr_crapcop_ativas%ROWTYPE;
    
    --Variaveis Locais       
    vr_fgferiad           BOOLEAN := FALSE;
    vr_fgfimsem           BOOLEAN := FALSE;
    vr_ctcooper           NUMBER(4) := 0; -- quantidade de cooperativa
    vr_ctjaexec           NUMBER(4) := 0; -- já executou
    vr_ctexebat           NUMBER(4) := 0; -- cooperativa com reagedamento
    vr_ctlibera           NUMBER(4) := 0; -- vai executar nessa seção mesmo
    vr_ctexelim           NUMBER(4) := 0; -- passou do horario limite de execução
    vr_ctferfin           NUMBER(4) := 0; -- cooperativa em feriado ou fim de semana
    vr_ctnaoaut           NUMBER(4) := 0; -- cooperativa não aurorizada
    vr_diaSemana          NUMBER(1) := 0;
    vr_dsparaux           VARCHAR2(4000)   := NULL;
    vr_hrultpro           VARCHAR2   (4);
  BEGIN
    -- Posiciona procedure
    vr_cdproint := vr_cdproexe || '.pc_controle_execucao';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    -- Posiciona cooper     
    vr_cdcooper := NVL(pr_cdcopprm,0);    
    vr_dsparaux := vr_dsparame;    
    -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484    
    -- Verifica sabado para não executar a Cecred
    vr_diaSemana := TO_CHAR(vr_dtsysdat,'D');
        
    -- selecionar todas cooperativas ativas
    FOR rw_crapcop_ativas IN cr_crapcop_ativas  LOOP
        
      -- verifica a quantidade de cooperativas a processar
      vr_ctcooper := vr_ctcooper + 1; 
      vr_cdcooper := rw_crapcop_ativas.cdcooper;      
      vr_cdcooinp := vr_cdcooper;
      --
      vr_dsparame := vr_dsparaux ||
                     ', vr_cdcooper:' || vr_cdcooper;    
      ---vr_dsparaux := vr_dsparame;
      -- Verifica se a cooperativa tem autorizada
      vr_cdacesso := 'LISTA_TBGEN';      
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);    
      IF SUBSTR(NVL(vr_dsvlrprm,'N'),1,1) <> 'S' THEN
        vr_ctnaoaut := vr_ctnaoaut + 1;
      ELSE 
      -- Consulta 02, levando em conta se a data de parâmetro for diferente da data do cadastro 
      -- então nesta data não executou - 20/09/2018 - REQ0027434
      -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484
      -- Verificar se já executou
      CECRED.gene0001.pc_controle_exec(pr_cdcooper  => vr_cdcooper   -- Código da coopertiva
                                      ,pr_cdtipope  => 'C2'          -- Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => vr_dtsysdat   -- Data do movimento
                                      ,pr_cdprogra  => 'PCLISBATCH'    -- Codigo do programa
                                      ,pr_flultexe  => vr_flultexe   -- Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec    -- Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic   -- Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic); -- descrição do erro se ocorrer
      -- Trata retorno
      IF nvl(vr_cdcritic,0) > 0         OR
        TRIM(vr_dscritic)   IS NOT NULL THEN
          -- Trata erro
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic; 
          RAISE vr_exc_montada;
      END IF;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      
      IF vr_flultexe = 1 THEN
        vr_ctjaexec := vr_ctjaexec + 1;
      ELSE
      -- posiciona parametros
      vr_cdacesso := 'LISTA_TBGEN_AGENDA';         
      pc_le_crapprm;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
      vr_dsagenda := vr_dsvlrprm;
      vr_hriniexe := SUBSTR(vr_dsagenda,01,05);
      vr_hrageexe := SUBSTR(vr_dsagenda,07,05);
      vr_hrfimexe := SUBSTR(vr_dsagenda,13,05);

      vr_fgfimsem := FALSE;         
      IF vr_diaSemana                = 1   THEN -- domingo não executa nenhuma cooper
          vr_fgfimsem := TRUE; 
        ELSIF vr_diaSemana           = 2 AND      -- segunda 
          rw_crapcop_ativas.cdcooper <> 3  THEN -- Processa somente a cooper Cecred                                                                       
          vr_fgfimsem := TRUE;             
        ELSIF vr_diaSemana           = 7 AND      -- sabado  
          rw_crapcop_ativas.cdcooper = 3   THEN -- Não Processa apenas a cooper Cecred                                                      
          vr_fgfimsem := TRUE;
      END IF;
      --                    
      -- Quando executar por fora não analisar feriado
      IF NVL(pr_cdcopprm,0) > 0 THEN
        IF vr_fgfimsem THEN
          vr_fgfimsem := FALSE;
        END IF;
      END IF;
      --
      IF vr_fgfimsem THEN
        vr_ctferfin := vr_ctferfin + 1;
      ELSE
      pc_posiciona_dat(pr_cdcooperprog => vr_cdcooper
                      ,pr_fgferiado    => vr_fgferiad
                      );
      --                    
      -- Quando executar por fora não analisar feriado
      IF NVL(pr_cdcopprm,0) > 0 THEN
        IF vr_fgfimsem THEN
          vr_fgfimsem := FALSE;
        END IF;
      END IF;
      --
      IF vr_fgferiad THEN
        vr_ctferfin := vr_ctferfin + 1;
      ELSE        
      --                    
      -- Quando executar por fora não analisar limite de horario de execução
      IF NVL(pr_cdcopprm,0) > 0 THEN
        vr_hrfimexe := '23:59';
      END IF;
      --
      -- Ajuste SYSDATE em variavel vr_dtsysdat - 09/10/2018 - Chd REQ0029484
      -- Verificar se não passou do horário limite
      IF vr_hrfimexe < TO_CHAR(vr_dtsysdat,'HH24:MI') THEN
        vr_ctexelim := vr_ctexelim + 1;   
        -- Log acompanhamento
        pc_controla_log_batch(pr_cdcritic => 1201
                             ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                             '. Passou do horario limite'     ||
                                             ', vr_cdcooper:'  || vr_cdcooper ||
                                             ', vr_hrfimexe:'  || vr_hrfimexe ||
                                             ', hora sysdate:' || TO_CHAR(vr_dtsysdat,'HH24:MI')
                             ,pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_cdcricid => 0 );
      ELSE      
      -- Verifica se a cadeia da cooperativa especifica terminou
      IF vr_inproces = 1 THEN
        vr_ctlibera     := vr_ctlibera + 1;
        -- Incluir em array as cooperativas liberadas para execução
        vr_index_cooper := vr_index_cooper + 1;        
        vr_tab_cooper(vr_index_cooper).cdcooper := vr_cdcooper;
        vr_tab_cooper(vr_index_cooper).nmrescop := rw_crapcop_ativas.nmrescop;
        -- Eliminada dtmvtolt - 09/10/2018 - Chd REQ0029484
        --vr_tab_cooper(vr_index_cooper).dtmvtolt := vr_dtmvtolt;
        vr_tab_cooper(vr_index_cooper).dtmvtoan := vr_dtmvtoan;
        -- Buscar a data e hora final da cadeia para não listar os erros pós cadeia
        BEGIN
          SELECT MAX(NVL(TO_CHAR(t1.dhfim,'HH24MI'),'0800')) 
          INTO   vr_hrultpro
          FROM   tbgen_prglog  t1 
          WHERE  t1.cdcooper     = vr_cdcooper
          AND    TRUNC(t1.dhfim) = TRUNC(vr_dtsysdat)
          AND    t1.cdprograma   = 'CRPS659.P';     
        EXCEPTION  
          WHEN vr_exc_montada THEN  
            RAISE vr_exc_montada;  
          WHEN vr_exc_erro_tratado THEN 
            RAISE vr_exc_erro_tratado; 
          WHEN vr_exc_others THEN 
            RAISE vr_exc_others; 
          WHEN OTHERS THEN   
            -- No caso de erro de programa gravar tabela especifica de log
            cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
            -- Trata erro
            pr_cdcritic := 1036;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                           ' tbgen_prglog(10): ' ||
                           vr_dsparame          ||
                           '. ' || SQLERRM; 
            RAISE vr_exc_montada;    
        END;
        vr_tab_cooper(vr_index_cooper).hrultpro := vr_hrultpro;
      ELSE
        vr_ctexebat := vr_ctexebat + 1;
      END IF; -- vr_inproces -- Batch executando      
      END IF; -- vr_hrfimexe -- Passou do horário            
      END IF; -- vr_fgferiad -- Finde sem execução da cooperativa
      END IF; -- vr_fgfimsem -- Finde sem execução da cooperativa      
      END IF; -- vr_flultexe -- ja executou 
      END IF; -- Cooperativa não autorizada
             
    END LOOP;
      
    vr_dsparame := vr_dsparaux;    
    vr_cdcooinp := NVL(pr_cdcopprm,0);  
    
    IF vr_ctexebat > 0 THEN 
      --------    Reagendar
      pc_cria_job;  
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    END IF;
            
    IF vr_ctlibera > 0 THEN                        
      pc_execucao_aprovada;  
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    END IF;
      
    IF vr_ctcooper <> vr_ctjaexec AND
       vr_ctexebat = 0            AND
       vr_ctlibera = 0            AND
       vr_ctexelim = 0               THEN  
      -- Log acompanhamento
      pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                           '. Sem execução ou reagendamento' ||
                                           ', vr_ctcooper:' || vr_ctcooper ||
                                           ', vr_ctjaexec:' || vr_ctjaexec ||
                                           ', vr_ctexebat:' || vr_ctexebat ||
                                           ', vr_ctexelim:' || vr_ctexelim ||
                                           ', vr_ctferfin:' || vr_ctferfin ||
                                           ', vr_ctlibera:' || vr_ctlibera ||
                                           ', vr_ctnaoaut:' || vr_ctnaoaut 
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_cdcricid => 0 );
    END IF;       
      
  EXCEPTION 
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;  
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;      
  END pc_controle_execucao;           
  --
  --
  --BLOCO PRINCIPAL
BEGIN                                     --- --- --- INICIO DO PROCESSO      
  -- Incluido nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);
  vr_cdcooinp := NVL(pr_cdcopprm,0);
  -- Log de inicio de execucao
  pc_controla_log_batch(pr_dstiplog => 'I');
  
  vr_dsparame := 'pr_cdcopprm:'   || pr_cdcopprm ||
                 ', pr_nrcadeia:' || pr_nrcadeia ||
                 ', pr_dtmovime:' || pr_dtmovime ||
                 ', pr_idatzmed:' || pr_idatzmed;  

  -- Ajuste do padrão Decimal/Data - 06/09/2018 - Chd REQ0026091
  EXECUTE IMMEDIATE 'ALTER SESSION SET 
  nls_calendar = ''GREGORIAN''
  nls_comp = ''BINARY''
  nls_date_format = ''DD-MON-RR''
  nls_date_language = ''AMERICAN''
  nls_iso_currency = ''AMERICA''
  nls_language = ''AMERICAN''
  nls_length_semantics = ''BYTE''
  nls_nchar_conv_excp = ''FALSE''
  nls_numeric_characters = ''.,''
  nls_sort = ''BINARY''
  nls_territory = ''AMERICA''
  nls_time_format = ''HH.MI.SSXFF AM''
  nls_time_tz_format = ''HH.MI.SSXFF AM TZR''
  nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''
  nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR'''; 
  -- Incluida SYSDATE em variavel vr_dtsysdat para manupilar melhor quando teste - 09/10/2018 - Chd REQ0029484
  vr_dtsysdat := SYSDATE;
  pc_controle_execucao;
   
  -- Retorno nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => vr_cdproexe, pr_action => NULL);
  
  vr_tab_cooper.DELETE;
  
  vr_cdcooinp := NVL(pr_cdcopprm,0);    
  -- Log de fim de execucao
  pc_controla_log_batch(pr_dstiplog => 'F');
    
  -- Retorna nome do módulo logado
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
EXCEPTION 
  WHEN vr_exc_erro_tratado THEN
    IF NVL(pr_cdcritic,0) = 0 THEN
      -- Busca a primeira sequencia de numeros até o Hifen, de no maximo 5 caracteres         
      -- Se não encontrar hifen ou nenhum numero ou der algum problema permanece 0 no codigo
      BEGIN
        pr_cdcritic := SUBSTR(NVL(LTRIM(TRANSLATE(SUBSTR(pr_dscritic
                                                         , 1, REPLACE(INSTR(pr_dscritic, '-', 1, 1),0,1))
                                       ,TRANSLATE(SUBSTR(pr_dscritic
                                                         , 1, REPLACE(INSTR(pr_dscritic, '-', 1, 1),0,1))
                                       ,'1234567890',' '), ' ')),0),1,5); 
      EXCEPTION 
        WHEN OTHERS THEN   
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper); 
          pr_cdcritic := 0;
      END;
      --
      IF pr_cdcritic = 0 THEN
        pr_cdcritic := 1197;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||
                         ' pr_dscritic:' || pr_dscritic; 
      END IF;                                      
      --
    END IF;
    -- Monta mensagem
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic
                                            ,pr_dscritic => pr_dscritic) ||
                   ' ' || vr_dsparame;                   
    -- Log de erro de execucao
    pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                         ,pr_dscritic => pr_dscritic);
  WHEN vr_exc_montada THEN                 
    -- Log de erro de execucao
    pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                         ,pr_dscritic => pr_dscritic);
  WHEN vr_exc_others THEN   
    -- Monta mensagem
    pr_cdcritic := 9999;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                   vr_cdproint ||
                   '. ' || vr_sqlerrm ||
                   '. ' || vr_dsparame;                   
    -- Log de erro de execucao
    pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                         ,pr_dscritic => pr_dscritic);
  WHEN OTHERS THEN   
    -- No caso de erro de programa gravar tabela especifica de log
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcopprm);    
    -- Monta mensagem
    pr_cdcritic := 9999;
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                   vr_cdproexe ||
                   '. ' || SQLERRM ||
                   '. ' || vr_dsparame;                   
    -- Log de erro de execucao
    pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                         ,pr_dscritic => pr_dscritic);
END;
--
END pc_lista_tbgen;               
              
/
