CREATE OR REPLACE PACKAGE CECRED.CCRD0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0003
  --  Sistema  : Rotinas genericas referente a tela de Cartões
  --  Sigla    : CCRD
  --  Autor    : Jean Michel - CECRED
  --  Data     : Abril - 2014.                   Ultima atualizacao: 30/04/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a cartoes

  -- Alteracoes:
  --             01/10/2014 - Alterações referente ao novo campo NRSEQCRD ( Renato - Supero ):
  --                          - Criação da função fn_sequence_nrseqcrd, para retornar o próximo
  --                            valor da sequence que ainda não foi utilizado.
  --
  --             11/12/2014 - Ajuste para pegar a sequencia do lancamento apartir da sequence. (James)                    
  --
  --             03/09/2015 - Incluido tratamento na pc_crps670 para tarifacao de saques e consultas,
  --                          Prj. Tarifas - 218(Jean Michel).
  --
  --             16/02/2016 - Ajustes referentes ao projeto melhoria 157 (Lucas Ranghetti #330322)
  --             23/02/2016 - Quando for verificar o saldo retirar a subtracao do valor do bloqueio judicial
  --                          da somatoria (Tiago/Rodrigo SD405466)
  --  
  --             14/09/2016 - #519895 No procedimento pc_debita_fatura_job, incluído log de início, fim e 
  --                          erro na execução do job (Carlos)
  --
  --             29/09/2016 - Executar o comando ux2dos no dir /bancoob para
  --                          nao correr o risco de enviar o arquivo CSDC*
  --                          incompleto ao parceiro por "demora" na execução do
  --                          comando (pc_crps669). (Chamado 521613) - (Fabricio)
  --
  --             22/11/2016 - #557129 Correção do retorno de críticas na rotina pc_debita_fatura e correção de
  --                          como é feita a iteração das cooperativas na rotina pc_debita_fatura_job para não 
  --                          ocorrer o erro ORA-01002: extração fora de sequência (Carlos)
  --
  --             03/01/2017 - #574756 Ajuste de posição da data de movimento do arquivo CEXT na 
  --                          rotina pc_crps670 para buscar os registros corretamente pela chave (Carlos)
  --
  --             19/01/2017 - Alterei a procedure pc_debita_fatura_web para nao logar o erro de validacao
  --                          de dia util. SD 579741. (Carlos Rafael Tanholi)
  --             03/02/2017 - #601772 Inclusão de verificação e log de erros de execução através do procedimento
  --                          pc_internal_exception no procedimento pc_crps670 (Carlos)
  --
  --             17/04/2017 - Incluir pc_crps672 e efetuar tratamento para abrir chamado e 
  --                          enviar email caso ocorra algum erro na importacao do arquivo 
  --                          ccr3 (Lucas Ranghetti #630298)
  --
  --             04/05/2017 - Inclusão dos parâmetros pr_cdmensagem e pr_flreincidente => 1 no programa
  --                          pc_crps672 para atender a verificação de abertura de chamado; Inclusão
  --                          das críticas na tabela crapcri (Carlos)
  --
  --             08/05/2017 - Incluido parenteses no IF que valida se deve terminar o repique (Tiago/Fabricio)
  --
  --             18/05/2017 - Ajuste na busca do sequencial do arquivo CEXT em virtude da
  --                          informacao de data acrescentada ao nome do arquivo pelo Bancoob.
  --                          (Fabricio)
  --
  --             24/05/2017 - Ajustar para o tipo de operacao '02' validar os tipos
  --                          aceitos antes de buscar as demais informacoes (Lucas Ranghetti #678334)
  --
  --             26/05/2017 - ajustes na pc_debita_fatura pra pegar corretamente a data de referencia para 
  --                          buscar as faturas (Tiago/Fabricio #677702)
  --
  --             13/06/2017 - Tratar para abrir chamado quando ocorrer algum erro no 
  --                          processamento da conciliacao do cartao Bancoob/Cabal (Lucas Ranghetti #680746)
  --
  --             02/08/2017 - Incluir validacao na pc_crps670 para o trailer do arquivo CEXT, caso o arquivo 
  --                          venha incompleto vamos abrir chamado e rejeitar o arquivo (Lucas Ranghetti #727623)
  --             
  --             08/08/2017 - #724754 Ajuste no procedimento pc_crps672 para filtrar apenas as cooperativas 
  --                          ativas para não solicitar relatórios para as inativas (Carlos)
  --
  --             21/09/2017 - Validar ultima linha do arquivo corretamente no pc_crps672 (Lucas Ranghetti #753170)
  --
  --             23/02/2018 - Criar no relatorio 676 a critica Representante nao encontrado
  --                          (Lucas Ranghetti #847282)
  --
  --             13/04/2018 - Incluido o controle de execução de programa
  --                          Projeto Debitador Unico - Josiane Stiehler (AMcom)
  --
  --             30/05/2018 - Tratamento para Grupo de afinidade zerado 
  --                          (Lucas Ranghetti SCTASK0014662)
  --
  --             09/07/2018 - Validar critica 080 apos a criacao da critica no
  --                          relatorio (Lucas Ranghetti INC0018668)
  --
  --             10/07/2018 - Validar valores nulos na geracao das linhas do arquivo ccb3 e 
  --                          enviar e-mail caso nao gere arquivo (Lucas Ranghetti PRB0040160)
  --
  --             30/07/2018 - Adicionado tratamento para não enviar conta PJ caso a mesma ainda não tenha sido criada 
  --                          no arquivo gerado na procedure pc_crps671 (Reinert).
  --
  --             10/10/2018 - Feita a inclusao de uma nova variavel que faz a leitura do nome do titular do cartao,
  --                          onde é gerada a critica 999.
  --
  --             23/11/2018 - Implantacao projeto 421 - Melhorias nas ferramentas contabeis e fiscais, entrega 2.
  --                          Heitor (Mouts) - Prj421
  --
  --             13/12/2018 - Limitar em 8 solicitacoes de cartoes para a mesma conta no mesmo 
  --                          arquivo CCB3 (Lucas Ranghetti INC0027563)
  --
  --             14/12/2018 - Adicionar dup_val_on_index ao inserir registro na crapdcb, caso 
  --                          utilize o dup_val será adicionado + 1 segundo na hrgmt para evitar
  --                          problemas referente uk de tarifas (Lucas Ranghetti PRB0040489)
  --
  --             21/12/2018 - Efetuado ajuste para caso seja efetuado um upgrade ele atualize
  --                          todos os cartões que vieram no arquivo com o tipo 4 do ccr3
  --                          (Lucas Ranghetti #INC0029505)
  --                         - Incluir a critica 143 - conta duplicada junto da critica 080
  --                           para não prosseguirmos com a inclusão do cartão pois o mesmo
  --                           ja possui cartão (Lucas Ranghetti #PRB0040493)
  --
  --             22/01/2019 - Implementação para contemplar cartão provisório na crps672 (Augusto Supero)
  --
  --             11/02/2019 - Tratamento para flgprcrd quando incluir segunda via 
  --                          (Lucas Ranghetti #PRB0040597)
  --                        - Limpar data de rejeicao ao alterar a situação para 
  --                          3 - liberado (Lucas Ranghetti PRB0040596)
  --
  --             08/03/2019 - Verificar se processo batch ainda está rodando na central
  --                          pois vamos rodar o programa mesmo com a central rodando
  --                          (Lucas Ranghetti PRB0040618)
  --
  --             29/03/2019 - Ajustar cursor cr_nrctaitg para buscar somente cartoes em uso
  --                          na procedure pc_crps671 (Lucas Ranghetti PRB0040697)
  --
  --              30/04/2019 - Utilizar o vr_nrcctitg no lugar do rw_crawcrd.nrcctitg 
  --                           no insert do crawcrd da segunda via dos cartões (Lucas Ranghetti PRB0041609)
  --                         - Incluir insitdec 8 na leitura do cursor cr_crawcrd
  --                           (Lucas Ranghettu PRB0041606)
  --                         - No Cursor cr_nrctaitg vamos utilizar o and w.nrcctitg > 0 ao 
  --                           invés de usar o insitcrd = 4, assim garantimos que só vamos
  --                           pegar a conta cartã correta (Lucas Ranghetti PRB0041677)
  ---------------------------------------------------------------------------------------------------------------

  --Tipo de Registro para as faturas pendentes
  TYPE typ_reg_fatura_pend IS
    RECORD (dtvencimento   tbcrd_fatura.dtvencimento%TYPE,
            dsdocumento    tbcrd_fatura.dsdocumento%TYPE,
            nrconta_cartao tbcrd_fatura.nrconta_cartao%TYPE,
            vlpendente     tbcrd_fatura.vlpendente%TYPE,
            fatrowid       ROWID);
            
  TYPE typ_tab_fatura_pend IS
     TABLE OF typ_reg_fatura_pend
      INDEX BY PLS_INTEGER; 

  /* Rotina destinada ao retorno do valor sequencial para o campo CRAWCRD.nrseqcrd,
    validando se o mesmo não existe */
  FUNCTION fn_sequence_nrseqcrd(pr_cdcooper IN NUMBER) RETURN NUMBER;

  /* Rotina para tratar a mensageria referente ao CABAL */
    PROCEDURE pc_consulta_arq_param(pr_tparquiv IN crapscb.tparquiv%TYPE --> Tipo do arquivo
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Rotina referente as acoes da tela PARBCB */
  PROCEDURE pc_tela_grabcb(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                          ,pr_cdcopgru IN crapcop.cdcooper%TYPE --> Codigo da cooperativa do grupo de afinidade
                          ,pr_cdgrafin IN crapacb.cdgrafin%TYPE --> Codigo do grupo de afinidade
                          ,pr_cdagengr IN crapage.cdagenci%TYPE --> Codigo do PA do grupo de afinidade
                          ,pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Codigo da administradora de cartao
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Rotina referente as acoes da tela TRNBCB */
  PROCEDURE pc_tela_trnbcb(pr_cddopcao IN VARCHAR2               --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                          ,pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE  --> Codigo da transacao
                          ,pr_dstrnbcb IN craphcb.dstrnbcb%TYPE  --> Descricao da transacao
                          ,pr_cdhisest IN tbcrd_his_vinculo_bancoob.cdhistor%TYPE --> Codigo do historico
													,pr_flgdebcc IN VARCHAR2               --> Debitar C/C
                          ,pr_tphistor IN tbcrd_his_vinculo_bancoob.tphistorico%TYPE
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Rotina referente as acoes da tela PARBCB */
  PROCEDURE pc_tela_parbcb(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                          ,pr_tparquiv IN crapscb.tparquiv%TYPE --> Tipo de Arquivo
                          ,pr_nrseqarq IN crapscb.nrseqarq%TYPE --> Codigo da sequencia de arquivo
                          ,pr_dsdirarq IN crapscb.dsdirarq%TYPE --> Descricao do diretorio do arquivo
                          ,pr_flgretpr IN crapscb.flgretpr%TYPE --> Flag de retorno
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Ultima sequencia de arquivo cadastrada */
  PROCEDURE pc_ult_seq_arq(pr_tparquiv IN crapscb.tparquiv%TYPE  --> Tipo de Arquivo
                          ,pr_nrseqinc IN BOOLEAN                --> Indica se sequencial deve ser incrementado ou não (TRUE => Incrementa/ FALSE => Retorno o que esta cadastrado)
                          ,pr_nrseqarq OUT crapscb.nrseqarq%TYPE --> Codigo da sequencia de arquivo
                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                          ,pr_dscritic OUT VARCHAR2);            --> Descricao do erro encontrado

  /* Consulta de administradoras */
  PROCEDURE pc_consulta_admcrd(pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Codigo da Administradora
                              ,pr_cdcopaux IN crapadc.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

	/* Procedimento para o CRPS669 */
  PROCEDURE pc_gera_saldo_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                 ,pr_cdcoppar IN NUMBER                --> Cooperativa (QUando execução paralela)
                                 ,pr_cdagepar IN NUMBER                --> Agencia (Quando execução paralela)
                                 ,pr_idparale IN crappar.idparale%TYPE --> Indicador de processo paralelo
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                 ,pr_nmdatela IN VARCHAR2              --> Rotina acionadora
                                 ,pr_qtdEjobs IN NUMBER                --> Programa chamador
											,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
                      
	/* Procedimento para o CRPS669 atraves da mensageria PHP */
  PROCEDURE pc_crps669_web(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
											,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
											,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
											,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
											,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Processamento das informações do arquivo do crp670 */ 
  PROCEDURE pc_proces_arq_cet_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                     ,pr_dtmvtolt IN DATE                  --> Data Execução
                                     ,pr_dtcxtmig IN VARCHAR2              --> DAta contas migradas
                                     ,pr_nrseqarq in number                --> Sequencia do arquivo
                                     ,pr_nrseqexe in number                --> Sequencia da execucao
                                     ,pr_idparale IN NUMBER                --> Indicador de processo paralelo
											,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
  
  /* Rotina com a os procedimentos para o CRPS670 */
  PROCEDURE pc_recebe_arq_cet_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                     ,pr_nmdatela IN VARCHAR2              --> Rotina acionadora
                                     ,pr_qtdejobs IN INTEGER DEFAULT 0     --> Quantidade de Jobs para execução paralela
                                     ,pr_qtregjob IN INTEGER DEFAULT 0     --> Quantidade de Registros por Jobs de execução paralela
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

	/* Procedimento para o CRPS670 */
  PROCEDURE pc_crps670_web(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
											,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
											,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
											,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
											,pr_des_erro OUT VARCHAR2);           --> Erros do processo                      

	/* Procedimento para o CRPS671 */
  PROCEDURE pc_crps671(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Procedimento para o CRPS672 */
  PROCEDURE pc_crps672(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Procedimento para debito de faturas cartao credito*/
  PROCEDURE pc_debita_fatura(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa
                            ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa
                            ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Operador                        
                            ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data movimento
                            ,pr_fatrowid  IN ROWID DEFAULT NULL       --> Rowid da fatura                     
                            ,pr_cdcritic  OUT crapcri.cdcritic%TYPE   --> Codigo critica 
                            ,pr_dscritic  OUT crapcri.dscritic%TYPE); --> Descricao da critica
                            
  /* Procedimento para debito de faturas cartao credito parte web do sistema debccr*/                          
  PROCEDURE pc_debita_fatura_web(pr_dtmvtolt IN VARCHAR2
                                ,pr_fatrowid IN ROWID DEFAULT NULL                                
                                ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_debita_fatura_job;                                
              
  /*Relatorio 693 dos debitos nao efetuados*/              
  PROCEDURE pc_rel_nao_efetuados(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa
                                ,pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Programa
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Operador
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE    --> Data movimento
                                ,pr_cdcritic  OUT crapcri.cdcritic%TYPE   --> Codigo critica
                                ,pr_dscritic  OUT crapcri.dscritic%TYPE); --> Descricao critica

  /*Busca as faturas pendentes de pagamento para uma conta*/
  PROCEDURE pc_busca_fatura_pend_web(pr_cdcopatu IN  crapcop.cdcooper%TYPE --> Cooperativa                                   
                                    ,pr_nrdconta IN  crapass.nrdconta%TYPE --> Numero conta
                                    ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);

  /* Insere conta cartao na tabela de relacionamento conta x conta cartao */
  PROCEDURE pc_insere_conta_cartao(pr_cdcooper       IN  crapcop.cdcooper%TYPE                 --> Cooperativa                                    
                                  ,pr_nrdconta       IN  crapass.nrdconta%TYPE                 --> Numero da conta
                                  ,pr_nrconta_cartao IN tbcrd_conta_cartao.nrconta_cartao%TYPE --> Conta cartao
                                  ,pr_cdcritic OUT PLS_INTEGER                                 --> Codigo da crítica
                                  ,pr_dscritic OUT VARCHAR2);                                  --> Erros do processo

END CCRD0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0003 AS

  vr_dsmsglog VARCHAR2(4000); -- Mensagem de log

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
        ,cop.cdagebcb
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Selecionar os dados de arquivos de parametros
  CURSOR cr_crapscb (pr_tparquiv IN crapscb.tparquiv%TYPE) IS

  SELECT
    scb.tparquiv AS tparquiv,
    scb.dsdsigla || ' - ' || scb.dsarquiv AS dsarquiv,
    scb.nrseqarq AS nrseqarq,
    scb.dtultint AS dtultint,
    scb.flgretpr AS flgretpr,
    scb.dsdirarq AS dsdirarq
  FROM
    crapscb scb
  WHERE
    (scb.tparquiv = pr_tparquiv OR pr_tparquiv = 0);

  rw_crapscb cr_crapscb%ROWTYPE;

  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  
  --> Enviar lote de SMS para o Aymaru
  PROCEDURE pc_enviar_lote_SMS ( pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_idlotsms  IN tbgen_sms_lote.idlote_sms%TYPE
                                ,pr_dscritic OUT VARCHAR2 
                                ,pr_cdcritic OUT INTEGER )IS
                                  
  /* ............................................................................

       Programa: pc_enviar_lote_SMS
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : novembro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para envio lote de SMS para o Aymaru

       Alteracoes: 30/08/2017 - Rotina copiada a COBR0005 e adaptada conforme 
                                necessidade (Renato Darosci - Prj360)

    ............................................................................ */

    -------------->> VARIAVEIS <<----------------
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    vr_cdcritic     INTEGER;
    
    vr_resposta     AYMA0001.typ_http_response_aymaru;
    vr_parametros   WRES0001.typ_tab_http_parametros;
    vr_conteudo     json := json();
      
    vr_code         VARCHAR2(10);
    vr_Message      VARCHAR2(1000);
    vr_Detail       VARCHAR2(4000);
      
  BEGIN
    
    /* Só vamos enviar o SMS se for a base for produção, para evitar envio de SMS indevido na base de teste. */
    IF gene0001.fn_database_name <> gene0001.fn_param_sistema('CRED',pr_cdcooper,'DB_NAME_PRODUC') THEN --> Produção
      pr_dscritic := 'Lote de SMS não enviado pois a base não é PRODUÇÃO.';
      RETURN;
    END IF; 
  
    -- Montar o conteúdo do JSON para envio via POST
    vr_conteudo.put('CodigoLote', pr_idlotsms); -- Código do Lote
    vr_conteudo.put('CodigoProduto', 21); -- Código do produto
    
    AYMA0001.pc_consumir_ws_rest_aymaru
                        (pr_rota       => '/Comunicacao/Sms/EnviarLote'
                        ,pr_verbo      => WRES0001.POST
                        ,pr_servico    => 'SMS.BOLETOS'
                        ,pr_parametros => vr_parametros
                        ,pr_conteudo   => vr_conteudo
                        ,pr_resposta   => vr_resposta
                        ,pr_dscritic   => vr_dscritic
                        ,pr_cdcritic   => vr_cdcritic);
          
    
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
       RAISE vr_exc_erro;
    END IF;
    
    --> Se retorno diferente de 200 - Sucesso
    IF vr_resposta.status_code <> 200 THEN
    
    vr_code    := vr_resposta.conteudo.get('Code').to_char();--.print();
    vr_Message := vr_resposta.conteudo.get('Message').get_string();
    vr_Detail  := vr_resposta.conteudo.get('Detail').get_string();
      
    IF TRIM(vr_code) IS NOT NULL THEN
        vr_dscritic := gene0007.fn_convert_web_db(vr_Message);
        vr_dscritic := REPLACE(vr_dscritic,CHR(14));
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_cdcritic := vr_cdcritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel enviar SMS: '||SQLERRM;
  END pc_enviar_lote_SMS; 
  
  
  /* Buscar o próximo NRSEQCRD, conforme regras */
  FUNCTION fn_sequence_nrseqcrd(pr_cdcooper IN NUMBER) RETURN NUMBER IS

    -- Buscar a sequencia
    CURSOR cr_crawcrd(pr_nrseqcrd  NUMBER) IS
      SELECT 1
        FROM crawcrd crd
       WHERE crd.nrseqcrd = pr_nrseqcrd
         AND crd.cdcooper = pr_cdcooper;

    -- Variáveis
    vr_nrseqret     NUMBER;
    vr_nrretsel     NUMBER;

  BEGIN

    LOOP
      -- Lê a próxima sequencia da FN_SEQUENCE, normalmente
      vr_nrseqret := fn_sequence(pr_nmtabela => 'CRAWCRD'
                                ,pr_nmdcampo => 'NRSEQCRD'
                                ,pr_dsdchave => to_char(pr_cdcooper));

      -- verificar se a sequencia lida já está sendo utilizada
      OPEN  cr_crawcrd(vr_nrseqret);
      FETCH cr_crawcrd INTO vr_nrretsel;

      -- Se não encontrar nenhum registro com este sequencial
      EXIT WHEN cr_crawcrd%NOTFOUND;

      -- Fecha o cursor
      CLOSE cr_crawcrd;
    END LOOP;

    -- Se o cursor ainda está aberto, fecha!
    IF cr_crawcrd%ISOPEN THEN
      CLOSE cr_crawcrd;
    END IF;

    RETURN vr_nrseqret;

  END fn_sequence_nrseqcrd;

  /* Rotina para tratar a mensageria referente ao CABAL */
  PROCEDURE pc_consulta_arq_param(pr_tparquiv IN crapscb.tparquiv%TYPE  --> Tipo do arquivo
                                 ,pr_xmllog   IN VARCHAR2                   --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS              --> Erros do processo
  BEGIN
    DECLARE

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_contador      PLS_INTEGER := 0;

      BEGIN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        --Busca parametros de integracao de arquivos
        OPEN cr_crapscb(pr_tparquiv => pr_tparquiv);

        LOOP
          FETCH cr_crapscb INTO rw_crapscb;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapscb%NOTFOUND;

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'tparquiv', pr_tag_cont => rw_crapscb.tparquiv, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsarquiv', pr_tag_cont => rw_crapscb.dsarquiv, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

        END LOOP;

        CLOSE cr_crapscb;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PARBCB: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PARBCB: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;


  END pc_consulta_arq_param;

  /* Rotina referente as acoes da tela GRABCB */
  PROCEDURE pc_tela_grabcb(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - ALteracao / C - Consulta / E - Exclur / I - Inclur)
                          ,pr_cdcopgru IN crapcop.cdcooper%TYPE --> Codigo da cooperativa do grupo de afinidade
                          ,pr_cdgrafin IN crapacb.cdgrafin%TYPE --> Codigo do grupo de afinidade
                          ,pr_cdagengr IN crapage.cdagenci%TYPE --> Codigo do PA do grupo de afinidade
                          ,pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Codigo da administradora de cartao
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN


    /* .............................................................................

     Programa: pc_tela_grabcb
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : CRRD
     Autor   : Jean Michel
     Data    : Abril/14.                    Ultima atualizacao: 11/04/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de insert, update, select e delete da tela GRABCB de
                 Grupo de Afinidades de Cartoes.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/
    DECLARE

      -- Selecionar os dados de grupos de afinidade
      CURSOR cr_crapacb (pr_cdgrafin IN crapacb.cdgrafin%TYPE) IS
      SELECT LPAD(acb.cdgrafin,7,0) AS cdgrafin
            ,acb.cdcooper
            ,cop.nmrescop
            ,acb.cdagenci
            ,acb.cdadmcrd
        FROM crapacb acb
            ,crapcop cop
       WHERE acb.cdcooper = cop.cdcooper
         AND acb.cdgrafin = pr_cdgrafin;

      rw_crapacb cr_crapacb%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_null          EXCEPTION;
      BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        OPEN cr_crapacb(pr_cdgrafin);
          FETCH cr_crapacb
            INTO rw_crapacb;

          -- Se não encontrar
          IF cr_crapacb%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapacb;

            IF pr_cddopcao <> 'I' THEN
              vr_dscritic := 'Grupo de Afinidade nao cadastrado.';
              RAISE vr_exc_saida;
            END IF;

          ELSE
            IF pr_cddopcao = 'I' THEN
              vr_dscritic := 'Grupo de Afinidade ja cadastrado.';
              RAISE vr_exc_saida;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crapacb;
          END IF;

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao de registro de grupo de afinidade
              UPDATE
                crapacb
              SET
                crapacb.cdcooper = pr_cdcopgru,
                crapacb.cdadmcrd = pr_cdadmcrd
              WHERE
                crapacb.cdgrafin = pr_cdgrafin;

              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh:mm:ss') || ' Operador: ' || vr_cdoperad ||
                             ' --- Alterado Grupo de Afinidade: ' || pr_cdgrafin;

              IF rw_crapacb.cdcooper <> pr_cdcopgru THEN
                vr_dsmsglog := vr_dsmsglog || ', de cooperativa: ' || rw_crapacb.cdcooper || ' para cooperativa: ' || pr_cdcopgru;
              END IF;

              IF rw_crapacb.cdadmcrd <> pr_cdadmcrd THEN
                vr_dsmsglog := vr_dsmsglog || ', de Administradora: ' || rw_crapacb.cdadmcrd || ' para Administradora: ' || pr_cdadmcrd;
              END IF;

              vr_dsmsglog := vr_dsmsglog || '.';

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar Grupo de Afinidade: ' || sqlerrm;
              RAISE vr_exc_saida;

            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdgrafin', pr_tag_cont => rw_crapacb.cdgrafin, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapacb.cdcooper, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapacb.nmrescop, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapacb.cdagenci, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdadmcrd', pr_tag_cont => rw_crapacb.cdadmcrd, pr_des_erro => vr_dscritic);

          WHEN 'E' THEN -- Exclusao

            BEGIN

              DELETE crapacb WHERE crapacb.cdgrafin = pr_cdgrafin;

              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh:mm:ss') || ' Operador: ' || vr_cdoperad ||
                             ' --- Excluido Grupo de Afinidade: ' || pr_cdgrafin || '.';

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir Grupo de Afinidade: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

          WHEN 'I' THEN -- Inclusao

            IF pr_cdcopgru = 0 THEN
               RAISE vr_null;
            END IF;

            BEGIN
              INSERT INTO
                crapacb(
                  cdgrafin,
                  cdcooper,
                  cdagenci,
                  cdadmcrd
                )
                VALUES(
                  pr_cdgrafin,
                  pr_cdcopgru,
                  0,
                  pr_cdadmcrd
                );

              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh:mm:ss') || ' Operador: ' || vr_cdoperad;

              vr_dsmsglog := vr_dsmsglog || ' --- Inclusao do Grupo de Afinidade: ' || pr_cdgrafin ||
                             ' para cooperativa: ' || pr_cdcopgru || ', agencia: ' || '0' ||
                             ' e administradora: ' || pr_cdadmcrd || '.';

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                --vr_dscritic := 'Seq: ' || pr_cdgrafin || ', Coop: ' || pr_cdcopgru || ', PA: ' || pr_cdagengr;
                --vr_dscritic := vr_dscritic || ', Adm: ' || pr_cdadmcrd;
                vr_dscritic := 'Problema ao inserir Grupo de Afinidade: ' || sqlerrm;
                RAISE vr_exc_saida;

            END;

        END CASE;

        IF vr_dsmsglog IS NOT NULL THEN

          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'grabcb'
                                    ,pr_flnovlog     => 'N');
        END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPACB: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;


  END pc_tela_grabcb;

  /* Rotina referente as acoes da tela TRNBCB */
  PROCEDURE pc_tela_trnbcb(pr_cddopcao IN VARCHAR2               --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                          ,pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE  --> Codigo da transacao
                          ,pr_dstrnbcb IN craphcb.dstrnbcb%TYPE  --> Descricao da transacao
                          ,pr_cdhisest IN tbcrd_his_vinculo_bancoob.cdhistor%TYPE  --> Codigo do historico
                          ,pr_flgdebcc IN VARCHAR2               --> Debitar C/C
                          ,pr_tphistor IN tbcrd_his_vinculo_bancoob.tphistorico%TYPE
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_tela_trnbcb
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : CRRD
     Autor   : Jean Michel
     Data    : Abril/14.                    Ultima atualizacao: 16/02/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de insert, update, select e delete da tela TRNBCB de
                 Transacoes BANCOOB X Historicos.

     Observacao: -----

     Alteracoes: 13/06/2014 - Inclusão da opção H (Jean Michel).
     
                 16/02/2016 - Ajustes referentes ao projeto melhoria 157(Lucas Ranghetti #330322)
     ..............................................................................*/
     
    DECLARE

      -- Selecionar os dados de vinculos de transacao
      CURSOR cr_craphcb (pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE) IS
      SELECT hcb.cdtrnbcb
            ,hcb.dstrnbcb
            ,hcb.flgdebcc
            ,DECODE(hcb.flgdebcc,1,'SIM','NAO') dsflgdeb
       FROM craphcb hcb
           --,tbcrd_his_vinculo_bancoob tbcrd
       WHERE hcb.cdtrnbcb   = pr_cdtrnbcb;
        -- AND tbcrd.cdtrnbcb = hcb.cdtrnbcb;
      rw_craphcb cr_craphcb%ROWTYPE;
      
      CURSOR cr_tbcrd_his_vinculo_bancoob (pr_cdtrnbcb IN tbcrd_his_vinculo_bancoob.cdtrnbcb%TYPE) IS 
      SELECT tbcrd.cdtrnbcb
            ,tbcrd.cdhistor
            ,tbcrd.tphistorico
            ,(SELECT his.dshistor FROM craphis his WHERE his.cdhistor = tbcrd.cdhistor AND ROWNUM = 1) dshistor
            ,DECODE(tbcrd.tphistorico,0,'ONLINE','OFFLINE') dstphistor
        FROM tbcrd_his_vinculo_bancoob tbcrd
       WHERE tbcrd.cdtrnbcb = pr_cdtrnbcb;
      rw_tbcrd_his_vinculo_bancoob cr_tbcrd_his_vinculo_bancoob%ROWTYPE;
      
      CURSOR cr_tbcrd_his_vinculo_bancoob_2(pr_cdtrnbcb IN tbcrd_his_vinculo_bancoob.cdtrnbcb%TYPE
                                           ,pr_tphistor IN tbcrd_his_vinculo_bancoob.tphistorico%TYPE) IS 
      SELECT tbcrd.cdtrnbcb
            ,tbcrd.cdhistor
            ,tbcrd.tphistorico
        FROM tbcrd_his_vinculo_bancoob tbcrd
       WHERE tbcrd.cdtrnbcb    = pr_cdtrnbcb
         AND tbcrd.tphistorico = pr_tphistor;
      rw_tbcrd_his_vinculo_bancoob_2 cr_tbcrd_his_vinculo_bancoob_2%ROWTYPE;      
      
      -- Selecionar os dados de históricos
      CURSOR cr_craphis (pr_cdhistor IN craphis.cdhistor%TYPE) IS
      SELECT his.cdhistor
            ,his.dshistor
        FROM craphis his
       WHERE his.cdcooper = 3 -- históricos da CECRED
         AND his.cdhistor = pr_cdhistor;

      rw_craphis cr_craphis%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_null          EXCEPTION;

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      vr_flgdebcc      VARCHAR2(100);
      vr_flgdebcctb    VARCHAR2(100);
      vr_tphistor      VARCHAR2(10);
      vr_tphistortb    VARCHAR2(10);
      vr_dstrnbcb      VARCHAR2(100);
      vr_tbcrd         BOOLEAN;

      BEGIN
        -- inicia como nao encontrado
        vr_tbcrd := FALSE;
        
        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);        
        
        OPEN cr_craphcb(pr_cdtrnbcb);
              FETCH cr_craphcb
               INTO rw_craphcb;
          -- Se não encontrar
          IF cr_craphcb%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craphcb;
            
            IF pr_cddopcao <> 'I' AND  pr_cddopcao <> 'H'  AND
               pr_cddopcao <> 'VT' AND pr_cddopcao <> 'I1' AND
               pr_cddopcao <> 'E3' THEN
              vr_dscritic := 'Transacao Bancoob nao cadastrada.';
              RAISE vr_exc_saida;
            END IF;

          ELSE           
            -- Fechar o cursor
            CLOSE cr_craphcb;
          END IF;

        IF (pr_flgdebcc = '1') THEN
          vr_flgdebcc := 'SIM';
        ELSE
          vr_flgdebcc := 'NAO';
        END IF;        

        -- Buscar registros e mostrar em tela
        -- Criar cabecalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados><Historicos></Historicos></Dados>');
        FOR rw_tbcrd_his_vinculo_bancoob IN cr_tbcrd_his_vinculo_bancoob(rw_craphcb.cdtrnbcb) LOOP              
          --Caso encontre registros
          vr_tbcrd := TRUE;    

          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Dados/Historicos'
                                        ,XMLTYPE('<Historico>'
                                               ||'  <cdtrnbcb>'||nvl(LPAD(rw_craphcb.cdtrnbcb,4,'0'),'')||'</cdtrnbcb>'
                                               ||'  <dstrnbcb>'||nvl(rw_craphcb.dstrnbcb,'')||'</dstrnbcb>'
                                               ||'  <cdhistor>'||nvl(rw_tbcrd_his_vinculo_bancoob.cdhistor,'')||'</cdhistor>'
                                               ||'  <dshistor>'||nvl(rw_tbcrd_his_vinculo_bancoob.dshistor,'')||'</dshistor>'
                                               ||'  <flgdebcc>'||nvl(rw_craphcb.flgdebcc,'')||'</flgdebcc>'
                                               ||'  <tphistor>'||nvl(rw_tbcrd_his_vinculo_bancoob.tphistorico,'')||'</tphistor>'
                                               ||'  <dstphistor>'||nvl(rw_tbcrd_his_vinculo_bancoob.dstphistor,'')||'</dstphistor>'                                                                                                
                                               ||'</Historico>'));
                
        END LOOP;       
        
        -- Caso nao tenha registros na tabela de vinculo com bancoob
        IF NOT vr_tbcrd THEN         
        
          IF pr_dstrnbcb IS NULL THEN 
            vr_dstrnbcb := upper(rw_craphcb.dstrnbcb);
          ELSIF pr_cddopcao <> 'E3' THEN
               vr_dstrnbcb := upper(pr_dstrnbcb);               
          END IF;
          
           pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Dados/Historicos'
                                        ,XMLTYPE('<Historico>'
                                               ||'  <cdtrnbcb>'||nvl(LPAD(rw_craphcb.cdtrnbcb,4,'0'),'')||'</cdtrnbcb>'
                                               ||'  <dstrnbcb>'||nvl(vr_dstrnbcb,'')||'</dstrnbcb>'
                                               ||'  <cdhistor></cdhistor>'
                                               ||'  <dshistor></dshistor>'
                                               ||'  <flgdebcc>'||nvl(rw_craphcb.flgdebcc,'')||'</flgdebcc>'
                                               ||'  <tphistor></tphistor>'
                                               ||'  <dstphistor></dstphistor>'                                                                                                
                                               ||'</Historico>'));
        END IF;
        
        vr_tphistor := CASE pr_tphistor WHEN 0 THEN 'ONLINE' WHEN 1 THEN 'OFFLINE' END;
        
        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao
        
          WHEN 'I1' THEN -- Inclusao do vinculo            

            -- Incluir transacao craphcb
            IF pr_dstrnbcb IS NULL THEN
              vr_dscritic := 'Descricao da transacao Bancoob nao informado.';
              RAISE vr_exc_saida;
            END IF;
          
            OPEN cr_craphcb(pr_cdtrnbcb);
              FETCH cr_craphcb
               INTO rw_craphcb;
             
            -- Se não encontrar
            IF cr_craphcb%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_craphcb;
              
              BEGIN
                -- Grava registro
                INSERT INTO
                  craphcb(cdtrnbcb,
                          dstrnbcb,
                          flgdebcc)
                  VALUES(pr_cdtrnbcb,
                         pr_dstrnbcb,
                         pr_flgdebcc);
              -- Verifica se houve problema na insercao de registros
              EXCEPTION
                WHEN OTHERS THEN
                  -- Descricao do erro na insercao de registros
                  vr_dscritic := 'Problema ao inserir Vinculacao de Transacao: ' || sqlerrm;
                  RAISE vr_exc_saida;
              END;
              
            ELSE
              CLOSE cr_craphcb;
              BEGIN
                -- Atualizacao de registro de transacoes
                UPDATE craphcb
                SET craphcb.dstrnbcb = UPPER(pr_dstrnbcb),
                    craphcb.flgdebcc = pr_flgdebcc
                WHERE craphcb.cdtrnbcb = pr_cdtrnbcb;
              EXCEPTION
                  WHEN OTHERS THEN
                    -- Descricao do erro na alteracao dos registros
                    vr_dscritic := 'Problema ao atualizar a Transacao: ' || sqlerrm;
                    RAISE vr_exc_saida;
              END;              
            END IF;                
            
            -- Verificar se historico esta vinculado a transacao
              OPEN cr_tbcrd_his_vinculo_bancoob_2 (pr_cdtrnbcb,
                                                   pr_tphistor);
              FETCH cr_tbcrd_his_vinculo_bancoob_2 INTO rw_tbcrd_his_vinculo_bancoob_2;
              
              -- Caso nao encontre historico vinculado
              IF cr_tbcrd_his_vinculo_bancoob_2%NOTFOUND THEN
                CLOSE cr_tbcrd_his_vinculo_bancoob_2;                
              ELSE
                -- Apenas fecha o cursor
                CLOSE cr_tbcrd_his_vinculo_bancoob_2;
                -- Soh podemos incluir tipos diferentes                
                vr_dscritic := 'Historico do tipo Online|Offline ja cadastrado.';
                RAISE vr_exc_saida;
              END IF;

            BEGIN
              -- Grava registro
              INSERT INTO
                tbcrd_his_vinculo_bancoob(
                  cdtrnbcb,
                  cdhistor,
                  tphistorico
                )
                VALUES(
                  pr_cdtrnbcb,
                  pr_cdhisest,
                  pr_tphistor
                );

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN

                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao inserir Vinculacao de Transacao: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;           

            -- Gerar log da transacao
            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' Operador: ' || vr_cdoperad ||
                             ' --- Inclusao de Vinculo de Transacao: ' || pr_cdtrnbcb ||
                             ', descricao: '   || pr_dstrnbcb ||
                             ', historico: '   || pr_cdhisest ||
                             ', tipo historico: '   || vr_tphistor || 
                             ', Movimenta C/C: ' || vr_flgdebcc || '.';
                             
          WHEN 'A1' THEN -- alterar historicos do vinculo                        

              -- Verificar se historico esta vinculado a transacao
              OPEN cr_tbcrd_his_vinculo_bancoob_2 (pr_cdtrnbcb,
                                                   pr_tphistor);
              FETCH cr_tbcrd_his_vinculo_bancoob_2 INTO rw_tbcrd_his_vinculo_bancoob_2;
              
              -- Caso nao encontre historico vinculado
              IF cr_tbcrd_his_vinculo_bancoob_2%NOTFOUND THEN
                CLOSE cr_tbcrd_his_vinculo_bancoob_2;

                vr_dscritic := 'Historico nao vinculado para esta transacao Bancoob.';
                RAISE vr_exc_saida;
              ELSE
                -- fecha o cursor
                CLOSE cr_tbcrd_his_vinculo_bancoob_2;

                -- Soh podemos incluir/alterar tipos diferentes       
                IF pr_tphistor = rw_tbcrd_his_vinculo_bancoob_2.tphistorico AND 
                   pr_cdhisest = rw_tbcrd_his_vinculo_bancoob_2.cdhistor THEN         
                  vr_dscritic := 'Historico do tipo Online|Offline ja cadastrado.';
                  RAISE vr_exc_saida;
                END IF;
              END IF;
              
              BEGIN
                -- Atualizacao de registro de transacoes
                UPDATE tbcrd_his_vinculo_bancoob
                SET tbcrd_his_vinculo_bancoob.cdhistor    = pr_cdhisest
                WHERE tbcrd_his_vinculo_bancoob.cdtrnbcb    = pr_cdtrnbcb
                  AND tbcrd_his_vinculo_bancoob.tphistorico = pr_tphistor;
              EXCEPTION
                WHEN OTHERS THEN
                -- Descricao do erro na alteracao dos registros
                vr_dscritic := 'Problema ao atualizar Vinculacao de Transacao: ' || sqlerrm;
                RAISE vr_exc_saida;
              END;                          
              
              -- Gera log de alteracao dos registros
              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' Operador: ' || vr_cdoperad ||
                             ' --- Inclusao de Vinculo de Transacao: ' || pr_cdtrnbcb ||
                             ', descricao: '   || pr_dstrnbcb ||
                             ', Movimenta C/C: ' || vr_flgdebcc || '.';              

              IF rw_tbcrd_his_vinculo_bancoob_2.cdhistor <> pr_cdhisest THEN
                vr_dsmsglog := vr_dsmsglog || ', historico: ' || to_char(rw_tbcrd_his_vinculo_bancoob_2.cdhistor) || ' para: ' ||
                               to_char(pr_cdhisest);
              END IF;

              vr_tphistortb := CASE rw_tbcrd_his_vinculo_bancoob_2.tphistorico WHEN 0 THEN 'ONLINE' WHEN 1 THEN 'OFFLINE' END;
              
              IF rw_tbcrd_his_vinculo_bancoob_2.tphistorico <> pr_tphistor THEN
                vr_dsmsglog := vr_dsmsglog || ', tipo de historico: ' || vr_tphistortb || ' para: ' ||
                               vr_tphistor;
              END IF;
              
              vr_dsmsglog := vr_dsmsglog || '.';  
              
          WHEN 'H' THEN -- Consulta de Históricos
            
            -- Verifica históricos
            OPEN cr_craphis(pr_cdhistor => pr_cdhisest);
              FETCH cr_craphis
               INTO rw_craphis;

            -- Se não encontrar
            IF cr_craphis%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_craphis;

              vr_dscritic := 'Historico nao cadastrado para esta cooperativa.';
              RAISE vr_exc_saida;

            ELSE
              -- Fechar o cursor
              CLOSE cr_craphis;
            END IF;

            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdhisotr', pr_tag_cont => rw_craphis.cdhistor, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dshistor', pr_tag_cont => rw_craphis.dshistor, pr_des_erro => vr_dscritic);                    
          WHEN 'E1' THEN -- Exclusao historico da transacao

            BEGIN

              DELETE tbcrd_his_vinculo_bancoob 
               WHERE tbcrd_his_vinculo_bancoob.cdtrnbcb    = pr_cdtrnbcb
                 AND tbcrd_his_vinculo_bancoob.tphistorico = pr_tphistor;

              -- Gerar log da exclusao do registro
              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' Operador: ' || vr_cdoperad ||
                             ' --- Excluido Vinculo de Transacao: ' || pr_cdtrnbcb ||  
                             ', historico: '   || pr_cdhisest ||
                             ', tipo historico: '   || vr_tphistor || '.';
            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir Vinculacao de Transacao: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
          WHEN 'E' THEN -- Exclui todo vinculo da transacao
            BEGIN                          
              -- Excluir vinculo
              DELETE tbcrd_his_vinculo_bancoob 
               WHERE tbcrd_his_vinculo_bancoob.cdtrnbcb = pr_cdtrnbcb
                 AND tbcrd_his_vinculo_bancoob.tphistorico IN(0,1);

              -- Excluir transacao
              DELETE craphcb 
               WHERE craphcb.cdtrnbcb = pr_cdtrnbcb;
               
              -- Gerar log da exclusao do registro
              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' Operador: ' || vr_cdoperad ||
                             ' --- Excluido Transacao: ' || pr_cdtrnbcb || ' - ' ||
                             pr_dstrnbcb || '.';
            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir Vinculacao de Transacao(1): ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
          WHEN 'I' THEN -- Incluir transacao
            NULL;              
                             
          WHEN 'A' THEN -- Alteracao
            NULL;
          WHEN 'C' THEN -- Consulta          
            NULL;                  
          WHEN 'A2' THEN -- Alteracao da descricao e se movimenta c/c                         
             
           IF pr_dstrnbcb IS NULL THEN
              vr_dscritic := 'Descricao da transacao Bancoob nao informado.';
              RAISE vr_exc_saida;
            END IF;
          
            BEGIN
              -- Atualizacao de registro de transacoes
              UPDATE craphcb
              SET craphcb.dstrnbcb = UPPER(pr_dstrnbcb),
                  craphcb.flgdebcc = pr_flgdebcc
              WHERE craphcb.cdtrnbcb = pr_cdtrnbcb;
            EXCEPTION
                WHEN OTHERS THEN
                  -- Descricao do erro na alteracao dos registros
                  vr_dscritic := 'Problema ao atualizar a Transacao: ' || sqlerrm;
                  RAISE vr_exc_saida;
            END;
              
            -- Gera log de alteracao dos registros
            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' Operador: ' || vr_cdoperad ||
                           ' --- Alterado Vinculo de Transacao: ' || to_char(pr_cdtrnbcb);

            IF rw_craphcb.dstrnbcb <> pr_dstrnbcb THEN
              vr_dsmsglog := vr_dsmsglog || ', descricao: ' || rw_craphcb.dstrnbcb || ' para: ' ||
                             pr_dstrnbcb;
            END IF;
              
            IF rw_craphcb.flgdebcc = 1 THEN 
              vr_flgdebcctb := 'SIM'; 
            ELSE
              vr_flgdebcctb := 'NAO';
            END IF;
              
            IF rw_craphcb.flgdebcc <> pr_flgdebcc THEN
              vr_dsmsglog := vr_dsmsglog || ', movimenta c/c: ' || vr_flgdebcctb || ' para: ' ||
                             vr_flgdebcc;
            END IF;
          WHEN 'VT' THEN -- Validar transacao bancoob
            IF pr_cdtrnbcb IS NULL THEN
              vr_dscritic := 'Codigo da transacao Bancoob nao informado.';
              RAISE vr_exc_saida;
            END IF;
          
            OPEN cr_craphcb(pr_cdtrnbcb);
              FETCH cr_craphcb INTO rw_craphcb;
             
            -- Se encontrar transacao
            IF cr_craphcb%FOUND THEN
              vr_dscritic := 'Transacao bancoob ja cadastrada.';
              RAISE vr_exc_saida;            
            END IF;
            CLOSE cr_craphcb;
          WHEN 'E3' THEN -- Exclui todo vinculo da transacao ao clicar no cancelar
            BEGIN                          
              -- Excluir vinculo
              DELETE tbcrd_his_vinculo_bancoob 
               WHERE tbcrd_his_vinculo_bancoob.cdtrnbcb = pr_cdtrnbcb
                 AND tbcrd_his_vinculo_bancoob.tphistorico IN(0,1);

              -- Excluir transacao
              DELETE craphcb 
               WHERE craphcb.cdtrnbcb = pr_cdtrnbcb;               
             
            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir Vinculacao de Transacao(1): ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
        END CASE;           
        
        IF vr_dsmsglog IS NOT NULL THEN

          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'trnbcb'
                                    ,pr_flnovlog     => 'N');
        END IF;
        -- Salvar alteracoes
        COMMIT;        
    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPHCB: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_tela_trnbcb;

  /* Rotina referente as acoes da tela PARBCB */
  PROCEDURE pc_tela_parbcb(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                          ,pr_tparquiv IN crapscb.tparquiv%TYPE --> Tipo de Arquivo
                          ,pr_nrseqarq IN crapscb.nrseqarq%TYPE --> Codigo da sequencia de arquivo
                          ,pr_dsdirarq IN crapscb.dsdirarq%TYPE --> Descricao do diretorio do arquivo
                          ,pr_flgretpr IN crapscb.flgretpr%TYPE --> Flag de retorno
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_tela_parbcb
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : CRRD
     Autor   : Jean Michel
     Data    : Abril/14.                    Ultima atualizacao: 14/04/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de insert, update, select e delete da tela PARBCB de
                 Parametros de Integracao de Arquivos BANCOOB.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      BEGIN

        OPEN cr_crapscb(pr_tparquiv);
        FETCH cr_crapscb INTO rw_crapscb;

          -- Se não encontrar
          IF cr_crapscb%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapscb;

            vr_dscritic := 'Erro ao consulta de Parametros de Integracao de Arquivos, Arquivo Tipo: ' || pr_tparquiv;
            RAISE vr_exc_saida;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapscb;
          END IF;

          gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_nmeacao  => vr_nmeacao
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          CASE pr_cddopcao
            WHEN 'A' THEN
              BEGIN
                -- Atualizacao de registro de parametros de integracao de arquivos
                UPDATE crapscb
                SET crapscb.nrseqarq = pr_nrseqarq
                   ,crapscb.dsdirarq = pr_dsdirarq
                WHERE crapscb.tparquiv = pr_tparquiv;

                COMMIT;

                vr_dsmsglog := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' Operador: ' || vr_cdoperad;

                IF rw_crapscb.nrseqarq <> pr_nrseqarq OR
                   rw_crapscb.dsdirarq <> pr_dsdirarq THEN

                  vr_dsmsglog := vr_dsmsglog || ' --- Alteracao de Parametros de Integracao Arquivos Bancoob: '
                                || pr_tparquiv || ', Sequencia alterada de: ' || rw_crapscb.nrseqarq || ' para: '
                                || pr_nrseqarq || ', alterado diretorio de: ' || rw_crapscb.dsdirarq ||
                                ' para: ' || pr_dsdirarq;
                END IF;

              -- Verifica se houve problema na atualizacao do registro
              EXCEPTION
                WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar Parametros de Integracao de Arquivos Bancoob: ' || sqlerrm;
                RAISE vr_exc_saida;
              END;
            WHEN 'C' THEN
              -- Criar cabeçalho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'tparquiv', pr_tag_cont => rw_crapscb.tparquiv, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrseqarq', pr_tag_cont => rw_crapscb.nrseqarq, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dtultint', pr_tag_cont => TO_CHAR(rw_crapscb.dtultint,'dd/mm/RRRR hh24:MI:ss'), pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsdirarq', pr_tag_cont => rw_crapscb.dsdirarq, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgretpr', pr_tag_cont => rw_crapscb.flgretpr, pr_des_erro => vr_dscritic);
            WHEN 'I' THEN
              -- Ate o momento nao ha possibilidade de inclusao de registros
              NULL;
            WHEN 'E' THEN
              -- Ate o momento nao ha possibilidade de exclusao de registros
              NULL;
          END CASE;

        IF vr_dsmsglog IS NOT NULL THEN
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'parbcb'
                                    ,pr_flnovlog     => 'N');
        END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PARBCB: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_tela_parbcb;

  /* Rotina referente as acoes da tela PARBCB */
  PROCEDURE pc_ult_seq_arq(pr_tparquiv IN crapscb.tparquiv%TYPE  --> Tipo de Arquivo
                          ,pr_nrseqinc IN BOOLEAN                --> Indica se sequencial deve ser incrementado ou não (TRUE => Incrementa/ FALSE => Retorno o que esta cadastrado)
                          ,pr_nrseqarq OUT crapscb.nrseqarq%TYPE --> Codigo da sequencia de arquivo
                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da critica de erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro encontrado
  BEGIN

    /* .............................................................................

     Programa: pc_ult_seq_arq
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : CRRD
     Autor   : Jean Michel
     Data    : Abril/14.                    Ultima atualizacao: 24/04/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de ultima sequencia de arquivo cadastrada.

     Observacao: -----

     Alteracoes: -----
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      BEGIN

        OPEN cr_crapscb(pr_tparquiv);
              FETCH cr_crapscb
               INTO rw_crapscb;

          -- Se não encontrar
          IF cr_crapscb%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapscb;

            vr_dscritic := 'Erro ao consulta de Parametros de Integracao de Arquivos.';
            RAISE vr_exc_saida;

          ELSE
            -- Fechar o cursor
            CLOSE cr_crapscb;
            IF pr_nrseqinc THEN
               pr_nrseqarq := rw_crapscb.nrseqarq + 1;
            ELSE
               pr_nrseqarq := rw_crapscb.nrseqarq;
            END IF;
          END IF;


    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPSBC: ' || SQLERRM;

    END;


  END pc_ult_seq_arq;

  /* Rotina referente a consulta de administradoras de cartao */
  PROCEDURE pc_consulta_admcrd(pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Codigo da Administradora
                              ,pr_cdcopaux IN crapadc.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_consulta_admcrd
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : CRRD
     Autor   : Jean Michel
     Data    : Abril/14.                    Ultima atualizacao: 04/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de administradoras de cartao de credito.

     Observacao: -----

     Alteracoes: 04/08/2014 - Adicionado parametro de Cod. Cooperativa (Lunelli)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;

      -- Selecionar as administradoras de cartao
      CURSOR cr_crapadc (pr_cdadmcrd IN crapadc.cdadmcrd%TYPE,
                         pr_cdcopaux IN crapadc.cdcooper%TYPE) IS
      SELECT
        adc.cdadmcrd,
        adc.nmadmcrd
      FROM
       crapadc adc
      WHERE
            adc.cdadmcrd BETWEEN 10 AND 80
       AND (adc.cdcooper = pr_cdcopaux OR pr_cdcopaux = 0)
       AND (adc.cdadmcrd = pr_cdadmcrd OR pr_cdadmcrd = 0);

       rw_crapadc cr_crapadc%ROWTYPE;

      BEGIN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        --Busca administradoras de cartao
        OPEN cr_crapadc(pr_cdadmcrd,
                        pr_cdcopaux);

        LOOP
          FETCH cr_crapadc INTO rw_crapadc;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapadc%NOTFOUND;

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdamdcrd', pr_tag_cont => rw_crapadc.cdadmcrd, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmamdcrd', pr_tag_cont => rw_crapadc.nmadmcrd, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

        END LOOP;

        CLOSE cr_crapadc;

        IF vr_contador = 0 THEN
           vr_dscritic := 'Adminstradoras Bancoob nao cadastradas.';
           RAISE vr_exc_saida;
        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Administradoras: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_consulta_admcrd;

  /* Rotina para chamada do procedimento de geração do arquivo de saldos Cartões Cabal e BANCOOB */
  PROCEDURE pc_gera_saldo_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                 ,pr_cdcoppar IN NUMBER                --> Cooperativa (QUando execução paralela)
                                 ,pr_cdagepar IN NUMBER                --> Agencia (Quando execução paralela)
                                 ,pr_idparale IN crappar.idparale%TYPE --> Indicador de processo paralelo
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Operador
                                 ,pr_nmdatela IN VARCHAR2              --> Rotina acionadora
                                 ,pr_qtdejobs  IN NUMBER               --> Programa chamador
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    /* .............................................................................

    Programa: pc_gera_saldo_bancoob
    Sistema : Cartoes de Credito - Cooperativa de Credito
    Sigla   : CRRD
    Autor   : Lucas Lunelli
    Data    : Maio/14.                    Ultima atualizacao: 16/07/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado.
                ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB e CRON.

    Objetivo  : procedimento para a geração do arquivo de Saldo Disp. dos Associados
                dos Cartões de Crédito BANCOOB/CABAL.

    Observacao: -----

    Alteracoes: 13/08/2014 - Ajuste para converter arquivo para DOS ao final da criação
                             (Odirlei/AMcom)

                22/08/2014 - Alteração da busca do diretorio do bancoob e remover
                             arquivo TMP(Odirlei/AMcom)

                06/10/2014 - Alterado para contabilizar também os saldos de
                             cartões liberados. ( Renato - Supero )

                17/10/2014 - Ajustar os controles de transação incluindo Rollbacks em caso
                             de erros na execução ( Renato - Supero )

                09/01/2015 - Alterado para gerar arquivo TMP fora da pasta envia,
                             e no final mover para a envia SD241651 (Odirlei-AMcom)
                             
                22/05/2015 - Tratado parametro na rotina EXTR0001.pc_obtem_saldo_dia
                             para melhoria de performace SD282933 (odirlei-Amcom)             
                             
                14/07/2016 - Adequacoes no layout do CSDC solicitados pela Cabal.
                             (Chamado 482238) - (Fabrício)
                             
                29/09/2016 - Executar o comando ux2dos no dir /bancoob para
                             nao correr o risco de enviar o arquivo CSDC*
                             incompleto ao parceiro por "demora" na execução do
                             comando. (Chamado 521613) - (Fabricio)
                             
                16/07/2018 - Projeto Revitalização Sistemas - Mudança no nome da rotina para 
                             melhoria do entendimento do processo e paralelização da rotina por 
                             cooperativa e agencia - Andreatta (MOUTs)             
                             
    ..............................................................................*/
    DECLARE
       ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   VARCHAR2(10) := 'CRPS669';
      vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_nmrquivo    VARCHAR2(2000);                                   --> Nome do arquivo
      vr_dsheader    VARCHAR2(2000);                                   --> HEADER  do arquivo
      vr_dsdetalh    VARCHAR2(2000);                                   --> DETALHE do arquivo
      vr_dstraile    VARCHAR2(2000);                                   --> TRAILER do arquivo
      vr_contador   PLS_INTEGER := 0;                                  --> Contador de linhas DETALHES
      vr_tab_sald   EXTR0001.typ_tab_saldos;                           --> Temp-Table com o saldo do dia
      vr_ind_sald   PLS_INTEGER;                                       --> Indice sobre a temp-table vr_tab_sald
      vr_vlsddisp   NUMBER(17,2);                                      --> Valor de saldo disponivel
      vr_dessinal  VARCHAR2(1);                                        --> Sinal + / - para Saldo Disponível
      vr_nrseqarq   INTEGER;                                           --> Sequencia de Arquivo
      vr_clob_arq   CLOB;                                              --> DAdos para o Arquivo POUP.txt
      vr_text_arq   VARCHAR2(32767);                                   --> Dados temporários para o arquivos POUP.txt

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro;

      ------------------------------- CURSORES ---------------------------------
      
      -- Busca listagem das cooperativas
      CURSOR cr_crapcol(pr_cdcoppar crapcop.cdcooper%TYPE              DEFAULT 0
                       ,pr_cdprogra tbgen_batch_controle.cdprogra%TYPE DEFAULT 0 
                       ,pr_qterro   number                             DEFAULT 0
                       ,pr_dtmvtolt tbgen_batch_controle.dtmvtolt%TYPE DEFAULT NULL) IS
       SELECT cop.cdcooper
             ,cop.cdagebcb
       FROM crapcop cop
        WHERE cop.cdcooper <> 3
          AND cop.cdcooper = decode(pr_cdcoppar,0,cop.cdcooper,pr_cdcoppar)
          AND (pr_qterro = 0 or
              (pr_qterro > 0 and exists (select 1
                                           from tbgen_batch_controle
                                          where tbgen_batch_controle.cdcooper    = pr_cdcooper -- Controle é gravado com a Coop Central
                                            and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                            and tbgen_batch_controle.tpagrupador = 3
                                            -- Somente possibilidades de agencia desta Coop
                                            AND tbgen_batch_controle.cdagrupador BETWEEN (lpad(cop.cdcooper,3,'0')||'00000') AND (lpad(cop.cdcooper,3,'0')||'99999')
                                            and tbgen_batch_controle.insituacao  = 1
                                            and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));

      -- Busca listagem das agencias da cooperativa
      CURSOR cr_crapage(pr_cdcoppar crapcop.cdcooper%TYPE              DEFAULT 0
                       ,pr_cdagepar crapage.cdagenci%TYPE              DEFAULT 0 
                       ,pr_cdprogra tbgen_batch_controle.cdprogra%TYPE DEFAULT 0 
                       ,pr_qterro   number                             DEFAULT 0
                       ,pr_dtmvtolt tbgen_batch_controle.dtmvtolt%TYPE DEFAULT NULL) IS
       SELECT age.cdagenci
         FROM crapage age
        WHERE age.cdcooper = pr_cdcoppar
          AND age.cdagenci = decode(pr_cdagepar,0,age.cdagenci,pr_cdagepar)
          AND (pr_qterro = 0 or
              (pr_qterro > 0 and exists (select 1
                                           from tbgen_batch_controle
                                          where tbgen_batch_controle.cdcooper    = pr_cdcooper -- Controle é gravado com a Coop Central
                                            and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                            and tbgen_batch_controle.tpagrupador = 3
                                            AND tbgen_batch_controle.cdagrupador = (lpad(age.cdcooper,3,'0')||lpad(age.cdagenci,5,'0'))
                                            and tbgen_batch_controle.insituacao  = 1
                                            and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));

      -- Cursor genérico de calendário da Cooperativa em operação
      rw_crabdat  btch0001.cr_crapdat%ROWTYPE;
      rw_crapdatc btch0001.cr_crapdat%ROWTYPE;

      -- cursor para busca de dados do cartão e associado
      CURSOR cr_crapcrd_loop (pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT crd.nrdconta
            ,ass.cdagenci
            ,ass.vllimcre
        FROM crapcrd crd
            ,crawcrd pcr
            ,crapass ass
         WHERE crd.cdcooper = pr_cdcooper  
           AND crd.dtcancel IS NULL        
           AND crd.cdadmcrd BETWEEN 10 AND 80
           AND ass.cdcooper = crd.cdcooper 
           AND ass.nrdconta = crd.nrdconta 
           AND pcr.cdadmcrd = crd.cdadmcrd 
           AND pcr.tpcartao = crd.tpcartao 
           AND pcr.nrdconta = crd.nrdconta 
           AND pcr.nrcrcard = crd.nrcrcard 
           AND pcr.nrctrcrd = crd.nrctrcrd 
           AND pcr.insitcrd IN (3,4)  -- LIBERADO E EM USO
           AND ass.dtdemiss IS NULL
           AND ass.cdagenci = decode(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
             GROUP BY crd.nrdconta
                     ,ass.cdagenci
                     ,ass.vllimcre
             ORDER BY crd.nrdconta;

      -- Informações arquivo bancoob
      CURSOR cr_crapscb IS
        SELECT crapscb.Dsdirarq
          FROM crapscb
         WHERE crapscb.tparquiv = 1;
      rw_crapscb cr_crapscb%ROWTYPE;

      -- Dados das tabela de trabalho de dados do arquivo
      cursor cr_work_arquv(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                          ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                          ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                          ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
       SELECT dscritic
         FROM tbgen_batch_relatorio_wrk
        WHERE cdcooper    = pr_cdcooper   
          AND cdprograma  = pr_cdprograma 
          AND dsrelatorio = pr_dsrelatorio
          AND dtmvtolt    = pr_dtmvtolt 
        ORDER BY dschave,nrdconta; 

      -- Variavel para arquivo de dados     
      TYPE vr_reg_texto IS RECORD(nrdconta crapass.nrdconta%TYPE
                                 ,destexto VARCHAR2(4000));
      TYPE vr_typ_texto IS TABLE OF vr_reg_texto INDEX BY PLS_INTEGER;
      vr_tab_texto vr_typ_texto;
      
      -- ID para o paralelismo
      vr_idparale      INTEGER := 0;
      -- Qtde parametrizada de Jobs
      vr_qtdjobs       NUMBER := pr_qtdejobs;
      -- Job name dos processos criados
      vr_jobname       varchar2(30);
      -- Bloco PLSQL para chamar a execução paralela do pc_crps750
      vr_dsplsql       varchar2(4000);
      
      -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
      vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE; 
      vr_idlog_ini_ger tbgen_prglog.idprglog%type;
      vr_idlog_ini_par tbgen_prglog.idprglog%type;
      vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
      vr_qterro        number := 0; 
      
      BEGIN

      -- Na execução principal
      if nvl(pr_idparale,0) = 0 then
        -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        vr_idlog_ini_ger := null;
        pc_log_programa(pr_dstiplog   => 'I'    
                       ,pr_cdprograma => vr_cdprogra          
                       ,pr_cdcooper   => pr_cdcooper
                       ,pr_tpexecucao => 2    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_ger);
      end if;  

        -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;

        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;

        -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crabdat;

        -- Se nao encontrar
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

      -- Para execução principal ou sem paralelo
      IF pr_idparale = 0 THEN

        -- Busca sequencial do arquivo
        CCRD0003.pc_ult_seq_arq(pr_tparquiv => 1
                               ,pr_nrseqinc => TRUE
                               ,pr_nrseqarq => vr_nrseqarq
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
        -- Se a variavel nao for 0
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          RAISE vr_exc_saida;
        END IF;

        -- buscar informações do arquivo a ser processado
        OPEN cr_crapscb;
        FETCH cr_crapscb INTO rw_crapscb;
        IF cr_crapscb%NOTFOUND  THEN
          vr_dscritic := 'Registro crapscb não encontrado!';
          CLOSE cr_crapscb;
           --levantar excecao
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapscb;

        -- buscar caminho de arquivos do Bancoob/CABAL
        vr_direto_connect := rw_crapscb.dsdirarq;

        -- monta nome do arquivo
        vr_nmrquivo := 'CSDC_756' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '_' || TO_CHAR(rw_crabdat.dtmvtolt,'YYYYMMDD') || '_' || lpad(vr_nrseqarq,7,0) || '.CCB';      

        -- monta HEADER do arquivo
        vr_dsheader := 'CSDC0' || TO_CHAR(rw_crabdat.dtmvtolt,'DDMMYYYY') || lpad(vr_nrseqarq,7,0)  || '0';
      
      END IF;

      /* CAso tenha retornado threads para paralelizar */
      IF vr_qtdjobs > 0 and pr_cdcoppar = 0 then  

        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;

        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
           -- Levantar exceção
           vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se algum job paralelo executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                     ,pr_cdprogra    => vr_cdprogra
                                                     ,pr_dtmvtolt    => rw_crabdat.dtmvtolt
                                                     ,pr_tpagrupador => 3
                                                     ,pr_nrexecucao  => 1);   

        -- Buscar todas as cooperativas ou as com erros de execuções anteriores
        FOR rw_crapcol IN cr_crapcol(pr_cdprogra => vr_cdprogra
                                    ,pr_qterro   => vr_qterro
                                    ,pr_dtmvtolt => rw_crabdat.dtmvtolt) LOOP

          -- Buscar todas as agencias ou as com erros de execuçoes anteriores
          FOR rw_crapage IN cr_crapage(pr_cdcoppar => rw_crapcol.cdcooper
                                      ,pr_cdprogra => vr_cdprogra
                                      ,pr_qterro   => vr_qterro
                                      ,pr_dtmvtolt => rw_crabdat.dtmvtolt) LOOP
            
            -- Montar o prefixo do código do programa para o jobname
            vr_jobname := vr_cdprogra ||'_'|| rw_crapcol.cdcooper ||'_'|| rw_crapage.cdagenci || '$';  
          
            -- Cadastra o programa paralelo
            gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                      ,pr_idprogra => (LPAD(rw_crapcol.cdcooper,3,'0')||LPAD(rw_crapage.cdagenci,5,'0'))
                                      ,pr_des_erro => vr_dscritic);
                                      
            -- Testar saida com erro
            if vr_dscritic is not null then
              -- Levantar exceçao
              raise vr_exc_saida;
            end if;     
            
            -- Montar o bloco PLSQL que será executado
            -- Ou seja, executaremos a geração dos dados
            -- para a agência atual atraves de Job no banco
            vr_dsplsql := 'DECLARE' || chr(13) 
                       || '  wpr_cdcritic NUMBER;' || chr(13) 
                       || '  wpr_dscritic VARCHAR2(1500);' || chr(13) 
                       || 'BEGIN' || chr(13) 
                       || '  ccrd0003.pc_gera_saldo_bancoob'
                       || '            ('||pr_cdcooper
                       || '            ,'||rw_crapcol.cdcooper
                       || '            ,'||rw_crapage.cdagenci
                       || '            ,'||vr_idparale 
                       || '            ,'||''''||pr_cdoperad||''''
                       || '            ,'||''''||pr_nmdatela||''''
                       || '            ,'||pr_qtdejobs
                       || '            ,wpr_cdcritic, wpr_dscritic);' 
                       || chr(13) 
                       || 'END;';   
             
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
                                         ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                         ,pr_des_erro => vr_dscritic);

             -- Testar saida com erro
             if  vr_dscritic is not null then 
               -- Levantar exceçao
               raise vr_exc_saida;
             end if;
          END LOOP;  
        end loop;
        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => vr_dscritic);
                                    
        -- Testar saida com erro
        if vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;    

        -- Verifica se algum job executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                     ,pr_cdprogra    => vr_cdprogra
                                                     ,pr_dtmvtolt    => rw_crabdat.dtmvtolt
                                                     ,pr_tpagrupador => 3
                                                     ,pr_nrexecucao  => 1);
        if vr_qterro > 0 then 
          vr_cdcritic := 0;
          vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
          raise vr_exc_saida;
        end if;
      
      ELSE
        
        -- Caso não for execução paralela
        IF pr_idparale = 0 THEN
          -- Gerar o Header do arquivo
          vr_tab_texto(0).nrdconta := 0;
          vr_tab_texto(0).destexto := vr_dsheader;
        END IF;
        
        if pr_cdcoppar <> 0 then
          vr_tpexecucao := 2;
        else
          vr_tpexecucao := 1;
        end if;   
        
        -- Grava controle de batch por agência
        gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper                                      -- Codigo da Cooperativa
                                        ,pr_cdprogra    => vr_cdprogra                                      -- Codigo do Programa
                                        ,pr_dtmvtolt    => rw_crabdat.dtmvtolt                              -- Data de Movimento
                                        ,pr_tpagrupador => 3                                                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                        ,pr_cdagrupador => lpad(pr_cdcoppar,3,'0')||lpad(pr_cdagepar,5,'0') -- Codigo do agrupador conforme (tpagrupador)
                                        ,pr_cdrestart   => null                                             -- Controle do registro de restart em caso de erro na execucao
                                        ,pr_nrexecucao  => 1                                                -- Numero de identificacao da execucao do programa
                                        ,pr_idcontrole  => vr_idcontrole                                    -- ID de Controle
                                        ,pr_cdcritic    => pr_cdcritic                                      -- Codigo da critica
                                        ,pr_dscritic    => vr_dscritic);                                    -- Descricao da critica
        -- Testar saida com erro
        if vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if; 

        -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I'  
                       ,pr_cdprograma => vr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar
                       ,pr_cdcooper   => pr_cdcooper 
                       ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_par);  

        -- Executa LOOP para cada Cooperativa
        FOR rw_crapcol IN cr_crapcol(pr_cdcoppar) LOOP

          -- Leitura do calendario da cooperativa do LOOP
          OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcol.cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdatc;

          -- Se nao encontrar
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

          -- Executa LOOP em registro de Cartões para gravar DETALHE
          FOR rw_crapcrd IN cr_crapcrd_loop(rw_crapcol.cdcooper,pr_cdagepar) LOOP

            -- Obter valores de saldos diários
            extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcol.cdcooper,
                                        pr_rw_crapdat => rw_crapdatc,
                                        pr_cdagenci   => rw_crapcrd.cdagenci,
                                        pr_nrdcaixa   => 0,
                                        pr_cdoperad   => pr_cdoperad,
                                        pr_nrdconta   => rw_crapcrd.nrdconta,
                                        pr_vllimcre   => rw_crapcrd.vllimcre,
                                        pr_dtrefere   => rw_crapdatc.dtmvtolt,
                                        pr_tipo_busca => 'A', -- tipo de busca (Buscar saldo na crapsda, fltrando pela dtmvtoan)
                                        pr_des_reto   => vr_des_erro,
                                        pr_tab_sald   => vr_tab_sald,
                                        pr_tab_erro   => vr_tab_erro);

            -- se encontrar erro
            IF vr_des_erro = 'NOK' THEN
              -- presente na tabela de erros
              IF vr_tab_erro.count > 0 THEN
                -- adquire descrição
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                -- grava log
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, -- Erro tratato
                                           pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' -'    ||
                                                                               vr_cdprogra  || ' --> ' || vr_dscritic);
              END IF;
              -- Volta para o inicio do loop
              CONTINUE;
            END IF;

            -- alimenta indice da temp-table
            vr_ind_sald := vr_tab_sald.last;

            -- adquire saldo disponível total da conta
            vr_vlsddisp := (vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vllimcre);

            -- Verifica sinal do Saldo (-/+)
            IF vr_vlsddisp < 0 THEN
              vr_dessinal := '-';
              vr_vlsddisp := (vr_vlsddisp * (-1)); -- Remove sinal de Negativo do Valor
            ELSE
              vr_dessinal := ' ';
            END IF;

            -- monta registro de DETALHE
            vr_dsdetalh := ('CSDC1756'                                                      ||
                            lpad(rw_crapcol.cdagebcb,4,'0')                                 ||
                            lpad(rw_crapcrd.nrdconta,12,'0')                                ||
                            vr_dessinal                                                     ||
                            lpad((vr_vlsddisp * 100), 14, '0')                              ||
                            lpad((vr_tab_sald(vr_ind_sald).vllimcre * 100), 15, '0')        ||
                            '1');

            -- incremente contador de Linhas
            vr_contador := vr_contador + 1;

            -- Gravar na tab de memória
            vr_tab_texto(vr_contador).nrdconta := rw_crapcrd.nrdconta;
            vr_tab_texto(vr_contador).destexto := vr_dsdetalh;
              
          END LOOP;
        END LOOP;

        -- Se for execucao paralela, gravar pltable na tabela WORK
        IF pr_cdcoppar > 0 AND vr_tab_texto.COUNT > 0 THEN
          -- Gravar informações na tabela 
          FOR idx IN vr_tab_texto.first..vr_tab_texto.last LOOP
            -- Inserir na tabela temporária
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,dschave
                         ,cdagenci
                         ,nrdconta
                         ,dscritic)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'dados_arquivo'
                         ,rw_crabdat.dtmvtolt
                         ,pr_cdcoppar   
                         ,pr_cdagepar
                         ,vr_tab_texto(idx).nrdconta
                         ,vr_tab_texto(idx).destexto);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[dados_arquivo]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END LOOP;
        END IF;

        -- Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F'  
                       ,pr_cdprograma => vr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar
                       ,pr_cdcooper   => pr_cdcooper
                       ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_par
                       ,pr_flgsucesso => 1); 

      END IF;

      -- Para execução principal ou sem paralelo
      IF pr_idparale = 0 THEN

        -- Caso execução paralela
        IF vr_idparale > 0 THEN
          -- Gerar o Header do arquivo
          vr_tab_texto(0).destexto := vr_dsheader;
                             
          -- Buscar dados da tabela genérica para a pltable
          FOR rw_work IN cr_work_arquv(pr_cdcooper    => pr_cdcooper
                                      ,pr_cdprograma  => vr_cdprogra
                                      ,pr_dsrelatorio => 'dados_arquivo' 
                                      ,pr_dtmvtolt    => rw_crabdat.dtmvtolt) LOOP
            -- Incremente contador de Linhas
            vr_contador := vr_contador + 1;
            -- Cada registro é uma linha para o arquivo
            vr_tab_texto(vr_contador).destexto := rw_work.dscritic;
          END LOOP;
        END IF;
        
        -- monta TRAILER do arquivo
        vr_dstraile := 'CSDC9' || lpad(vr_contador,12,'0');

        -- escrever TRAILER do arquivo
        vr_tab_texto(vr_contador+1).destexto := vr_dstraile;
                             
        -- Incializar CLOB do arquivo txt
        dbms_lob.createtemporary(vr_clob_arq, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_clob_arq, dbms_lob.lob_readwrite);

        -- VArrer pltable
        FOR idx IN vr_tab_texto.first..vr_tab_texto.last LOOP
          -- Escreve no CLOB
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                 ,pr_texto_completo => vr_text_arq
                                 ,pr_texto_novo     => vr_tab_texto(idx).destexto ||chr(13)||chr(10));
        END LOOP;

        -- Fechar Arquivo
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                               ,pr_texto_completo => vr_text_arq
                               ,pr_texto_novo     => ''
                               ,pr_fecha_xml      => TRUE);

        -- Submeter a geração do arquivo 
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper   => pr_cdcooper                             --> Cooperativa conectada
                                           ,pr_cdprogra   => vr_cdprogra                             --> Programa chamador
                                           ,pr_dtmvtolt   => rw_crabdat.dtmvtolt                     --> Data do movimento atual
                                           ,pr_dsxml      => vr_clob_arq                             --> Arquivo XML de dados
                                           ,pr_cdrelato   => '147'                                   --> Código do relatório
                                           ,pr_dsarqsaid  => vr_direto_connect||'/'||vr_nmrquivo     --> Arquivo final com o path
                                           ,pr_flg_gerar  => 'S'                                     --> Gerar na hora
                                           ,pr_dspathcop  => vr_direto_connect||'/envia'             --> Copiar para o diretório
                                           ,pr_fldoscop   => 'S'                                     --> Executar comando ux2dos
                                           ,pr_flgremarq  => 'S'                                     --> Após cópia, remover arquivo de origem
                                           ,pr_des_erro   => vr_dscritic);                         
        -- Liberar memória alocada
        dbms_lob.close(vr_clob_arq);
        dbms_lob.freetemporary(vr_clob_arq);

        -- Se houve erro na geração
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Limpa os registros da tabela de trabalho somente em execução paralela
        IF vr_idparale > 0 THEN
          begin    
            delete from tbgen_batch_relatorio_wrk
             where cdcooper    = pr_cdcooper
               and cdprograma  = vr_cdprogra
               AND dsrelatorio = 'dados_arquivo'
               and dtmvtolt    = rw_crabdat.dtmvtolt;    
          exception
            when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
              raise vr_exc_saida;            
          end;
        END IF;
        
        -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
        BEGIN
          UPDATE crapscb
             SET nrseqarq = vr_nrseqarq
                ,dtultint = SYSDATE
           WHERE crapscb.tparquiv = 1; -- Arquivo CSDC - Saldo Disponivel de Cooperados

        -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
        EXCEPTION
          WHEN OTHERS THEN
            -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
            vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

        -- Caso seja o controlador 
        if vr_idcontrole <> 0 then
          -- Atualiza finalização do batch na tabela de controle 
          gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                             ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                             ,pr_dscritic   => vr_dscritic);
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;                                       
        end if;   
        
        -- Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F'   
                       ,pr_cdprograma => vr_cdprogra           
                       ,pr_cdcooper   => pr_cdcooper 
                       ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_ger
                       ,pr_flgsucesso => 1);      
        
        -- Efetuar commit
        COMMIT;
      ELSE
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                           ,vr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                           ,vr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => (LPAD(pr_cdcoppar,3,'0')||LPAD(pr_cdagepar,5,'0'))
                                    ,pr_des_erro => vr_dscritic);  
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        -- Salvar informacoes no banco de dados
        COMMIT;
      END IF;  

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Na execução paralela
        IF nvl(pr_idparale,0) <> 0 THEN

          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);                                     

          -- Grava LOG de erro com as críticas retornadas                           
          pc_log_programa(pr_dstiplog      => 'E', 
                          pr_cdprograma    => vr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,
                          pr_cdcooper      => pr_cdcooper,
                          pr_tpexecucao    => vr_tpexecucao,
                          pr_tpocorrencia  => 3,
                          pr_cdcriticidade => 1,
                          pr_cdmensagem    => pr_cdcritic,
                          pr_dsmensagem    => pr_dscritic,
                          pr_flgsucesso    => 0,
                          pr_idprglog      => vr_idlog_ini_par);  

          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => (LPAD(pr_cdcoppar,3,'0')||LPAD(pr_cdagepar,5,'0'))
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

        -- Desfaz as alterações da base
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS669: ' || SQLERRM;

        -- Na execução paralela
        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_cdcoppar||'_'||pr_cdagepar,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  
          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => (LPAD(pr_cdcoppar,3,'0')||LPAD(pr_cdagepar,5,'0'))
                                      ,pr_des_erro => vr_dscritic);
        end if; 
        
        -- Desfaz as alterações da base
        ROLLBACK;
    END;

  END pc_gera_saldo_bancoob;


  /* Rotina com a os procedimentos para o CRPS669 via mensageria PHP */
  PROCEDURE pc_crps669_web(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_crps669
    Sistema : Cartoes de Credito - Cooperativa de Credito
    Sigla   : CRRD
    Autor   : Lucas Lunelli
    Data    : Maio/14.                    Ultima atualizacao: 16/07/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado.
                ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB 

    Objetivo  : Direcionar para a geração do arquivo de Saldo Disp. dos Associados
                dos Cartões de Crédito BANCOOB/CABAL.

    Observacao: -----

    Alteracoes: 16/07/2018 - Projeto Revitalização Sistemas - Ajustes nas chamadas
                             devido paralelismo - Andreatta (MOUTs)             

    ..............................................................................*/
    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      -- Extração dados XML
      vr_cdcooper   NUMBER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

    BEGIN
      -- extrai dados do XML (para uso Ayllos WEB)
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Chamar rotina executora
      pc_gera_saldo_bancoob(pr_cdcooper => vr_cdcooper
                           ,pr_cdcoppar => 0
                           ,pr_cdagepar => 0
                           ,pr_idparale => 0
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_qtdejobs  => 0
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      -- Em caso de erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                           

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>1</TpException></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS669: ' || SQLERRM;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_crps669_web;
                             
  /* Processamento das informações do arquivo do crp670 */ 
  PROCEDURE pc_proces_arq_cet_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                     ,pr_dtmvtolt IN DATE                  --> Data Execução
                                     ,pr_dtcxtmig IN VARCHAR2              --> DAta contas migradas
                                     ,pr_nrseqarq in number                --> Sequencia do arquivo
                                     ,pr_nrseqexe in number                --> Sequencia da execucao
                                     ,pr_idparale IN NUMBER                --> Indicador de processo paralelo
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    /* .............................................................................
                             
    Programa: pc_proces_arq_cet_bancoob
    Sistema : Cartoes de Credito - Cooperativa de Credito
    Sigla   : CRRD
    Autor   : Andreatta - Mouts
    Data    : Agosto/18.                    Ultima atualizacao: 14/12/2018
                
    Dados referentes ao programa:
                
    Frequencia: Sempre que for chamado.
                ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB e CRON.
                
    Objetivo  : Conciliar débitos dos Cartões de Crédito BANCOOB/CABAL.
                Rotina separada para processamento paralelo por porcões do arquivo
                
    Observacao: -----
                             
    Alteracoes: 14/12/2018 - Adicionar dup_val_on_index ao inserir registro na crapdcb, caso 
                             utilize o dup_val será adicionado + 1 segundo na hrgmt para evitar
                             problemas referente uk de tarifas (Lucas Ranghetti PRB0040489)

                30/07/2019 - Ajuste para que não tenha chave duplicada ao niserir na tabela
                             crapdcb. Alcemir Jr. (PRB0042044)
            	 
    ....................................................................................................*/
    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------

      -- Extração dados XML
      vr_cdcopban   NUMBER;
      vr_nrdconta   crapass.nrdconta%type;
      vr_flgrejei   NUMBER;
      vr_cdprogra   VARCHAR2(10) := 'CRPS670';
      
      -- Numero do documento
      vr_nrdocmto   VARCHAR2(50);
      vr_crialcmt   BOOLEAN;
      vr_criardcb    BOOLEAN;
      vr_dthstran   VARCHAR2(10);
      vr_nsuredec   VARCHAR2(6);
      vr_nrseqdig_lot craplot.nrseqdig%TYPE;
      vr_cdhistor_ori craphcb.cdhistor%TYPE;
      vr_indebcre   VARCHAR2(1);
      vr_cdtrnbcb   VARCHAR2(4);
      vr_cdpesqbb   VARCHAR2(50);
      vr_dtmvtolt   DATE;
      
      vr_cdbccxlt   constant INTEGER := 100;
      vr_nrdolote   constant INTEGER := 6902;
      vr_tipostaa   INTEGER;

      vr_tpmensag   VARCHAR2(4);
      vr_cdcrimsg   VARCHAR2(2);

      vr_tpmsg200   BOOLEAN;
      vr_tpmsg220   BOOLEAN;
      vr_tpmsg420   BOOLEAN;

      vr_cdhistor   INTEGER;
      vr_vldtrans   craplcm.vllanmto%TYPE;
      vr_cdorigem   craplcm.cdorigem%TYPE;
      vr_dtmovtoo   craplcm.dtmvtolt%TYPE;
      vr_cdhistor_off INTEGER;
      vr_cdhistor_on  INTEGER;
      vr_dshistor_off VARCHAR2(100);
      vr_dshistor_on  VARCHAR2(100);
      vr_indebcre_on  Varchar2(1);
      vr_indebcre_off VARCHAR2(1);
      vr_dshistor_ori VARCHAR2(100);
      vr_flgdebcc   INTEGER;
      vr_cdtrnbcb_ori INTEGER;      
      vr_dstrnbcb VARCHAR2(100);
      vr_nrdlinha INTEGER := 0;
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_exc_rejeitado EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      --index da temp-table do relatorio
      vr_index      VARCHAR2(38);   
      vr_idxlcm     VARCHAR2(500);
      vr_idxdcb     VARCHAR2(500);

      vr_qtacobra INTEGER := 0;
      vr_fliseope INTEGER := 0;
      
      -- data base para transacoes no periodo da migracao
      vr_dtcxtmig date;

      -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
      vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
      vr_idlog_ini_par tbgen_prglog.idprglog%type;

      ---------------------------- ESTRUTURAS DE REGISTRO ----------------------


      -- Definicao de temptable para registros da craplcm
      TYPE typ_tab_craplcm IS
        TABLE OF craplcm%ROWTYPE
        INDEX BY VARCHAR2(500); --CDCOOPER(10) + DTMVTOLT(8) + CDAGENCI(5) + CDBCCXLT(5) + NRDOLOTE(10) + NRDCTABB(10) + NRDOCMTO(25)
      vr_tab_craplcm typ_tab_craplcm;

      TYPE typ_rec_crapdcb
       IS RECORD(det       crapdcb%ROWTYPE,
                 ROWID_dcb ROWID,
                 operacao  VARCHAR2(1));

      -- Definicao de temptable para registros da crapdcb
      TYPE typ_tab_crapdcb IS
        TABLE OF typ_rec_crapdcb--crapdcb%ROWTYPE
        INDEX BY VARCHAR2(500); -- TPMENSAG(5), NRNSUCAP(10), DTDTRGMT(8), HRDTRGMT(10), CDCOOPER(10), NRDCONTA(10)
      vr_tab_crapdcb typ_tab_crapdcb;

      -- DAdos de Lote
      type typ_reg_craplot is record(cdcooper craplot.cdcooper%type
                                    ,cdagenci craplot.cdagenci%type
                                    ,nrseqdig craplot.nrseqdig%type
                                    ,qtcompln craplot.qtcompln%type
                                    ,qtinfoln craplot.qtinfoln%type
                                    ,vlcompdb craplot.vlcompdb%type
                                    ,vlinfodb craplot.vlinfodb%type);
      type typ_tab_craplot is table of typ_reg_craplot index by varchar2(8);
      vr_tab_craplot typ_tab_craplot;
      vr_idx_lot varchar2(8);
      
      ------------------------------- CURSORES ---------------------------------

      -- Cursor para buscar valores para relatorio      
      cursor cr_work_arq(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_nrseqexe    tbgen_batch_relatorio_wrk.cdagenci%type
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
        select a.dschave  nmarquiv
              ,a.nrdconta nrdlinha
              ,a.dscritic des_text
          from tbgen_batch_relatorio_wrk a
         where a.cdcooper    = pr_cdcooper
           and a.cdagenci    = pr_nrseqexe
           and a.cdprograma  = pr_cdprograma
           and a.dsrelatorio = pr_dsrelatorio
           and a.dtmvtolt    = pr_dtmvtolt
           and SUBSTR(a.dscritic,1,5) not in('CEXT0','CEXT9') -- Ignorar Header e Trailler
         order by a.nrdconta;

      -- busca registro de Debito efetuado com cartão Bancoob
      CURSOR cr_crapdcb_200(pr_nrnsucap IN crapdcb.nrnsuori%TYPE,
                             pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE,
                             pr_hrdtrgmt IN crapdcb.hrdtrgmt%TYPE,
                             pr_cdcooper IN crapass.cdcooper%TYPE,
                             pr_nrdconta IN crapdcb.nrdconta%TYPE,
                             pr_cdhistor IN crapdcb.cdhistor%TYPE) IS
        SELECT dcb.rowid,
               dcb.cdhistor
          FROM crapdcb dcb
         WHERE dcb.cdcooper = pr_cdcooper   
           AND dcb.nrdconta = pr_nrdconta   
           AND upper(dcb.tpmensag) = '0200' 
           AND dcb.nrnsuori = pr_nrnsucap   
           AND dcb.dtdtrgmt = pr_dtdtrgmt   
           AND dcb.hrdtrgmt = pr_hrdtrgmt  
           AND dcb.cdhistor = pr_cdhistor ;
      rw_crapdcb_200 cr_crapdcb_200%ROWTYPE;
      
      -- busca registro de Credito efetuado com cartão Bancoob
      CURSOR cr_crapdcb_400 (pr_nrnsucap IN crapdcb.nrnsuori%TYPE,
                             pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE,
                             pr_hrdtrgmt IN crapdcb.hrdtrgmt%TYPE,
                             pr_cdcooper IN crapass.cdcooper%TYPE,
                             pr_nrdconta IN crapdcb.nrdconta%TYPE,
                             pr_cdhistor IN crapdcb.cdhistor%TYPE) IS
        SELECT dcb.rowid
          FROM crapdcb dcb
         WHERE dcb.cdcooper = pr_cdcooper  
           AND dcb.nrdconta = pr_nrdconta  
           AND upper(dcb.tpmensag) = '0400'
           AND dcb.nrnsuori = pr_nrnsucap  
           AND dcb.dtdtrgmt = pr_dtdtrgmt  
           AND dcb.hrdtrgmt = pr_hrdtrgmt  
           AND dcb.cdhistor = pr_cdhistor ;
      rw_crapdcb_400 cr_crapdcb_400%ROWTYPE;
      
      -- Debitos e Creditos Bancoob
       CURSOR cr_crapdcb (pr_nrnsucap IN crapdcb.nrnsuori%TYPE,
                          pr_cdcooper IN crapass.cdcooper%TYPE,
                          pr_nrdconta IN crapdcb.nrdconta%TYPE,
                          pr_vldtrans IN crapdcb.vldtrans%TYPE,
                          pr_nrseqarq IN crapdcb.nrseqarq%TYPE,
                          pr_dtdtrgmt IN crapdcb.dtdtrgmt%TYPE) IS
        SELECT dcb.dtmvtolt,
               dcb.tpmensag,
               dcb.tpdtrans,
               dcb.vldtrans,
               dcb.nrnsucap,
               dcb.nrnsuori,
               dcb.cdhistor,
               dcb.cdtrresp
          FROM crapdcb dcb
        WHERE dcb.cdcooper = pr_cdcooper
          AND dcb.nrdconta = pr_nrdconta
          AND dcb.nrnsuori = pr_nrnsucap
          AND upper(dcb.tpmensag) in ('0200','0220','0420') 
          AND dcb.vldtrans = pr_vldtrans 
          AND(dcb.nrseqarq = 1 OR ( dcb.nrseqarq < pr_nrseqarq AND dcb.dtdtrgmt = pr_dtdtrgmt )) -- considerar caso venha mais de uma vez a conciliacao
          ORDER BY dcb.tpmensag ASC;
      rw_crapdcb cr_crapdcb%ROWTYPE;
      
      CURSOR cr_crapdcb_hr (pr_cdcooper crapdcb.cdcooper%TYPE
                           ,pr_nrdconta crapdcb.nrdconta%TYPE
                           ,pr_nrnsucap crapdcb.nrnsucap%TYPE
                           ,pr_dtdtrgmt crapdcb.dtdtrgmt%TYPE
                           ,pr_tpmansag crapdcb.tpmensag%TYPE) IS
        SELECT MAX(dcb.hrdtrgmt) + 1 AS HRDTRGMT FROM crapdcb dcb
         WHERE dcb.cdcooper = pr_cdcooper
           AND dcb.nrdconta = pr_nrdconta
           AND dcb.nrnsucap = pr_nrnsucap
           AND dcb.dtdtrgmt = pr_dtdtrgmt
           AND upper(tpmensag) = upper(pr_tpmansag);
      rw_crapdcb_hr cr_crapdcb_hr%ROWTYPE;           

      -- Cursor para retornar cooperativa com base agencia bancoob
      CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.flgativo
        FROM crapcop cop
       WHERE cop.cdagebcb = pr_cdagebcb;
      rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;

       -- cursor para busca dos vinculos da transacao bancoob
      CURSOR cr_craphcb (pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE) IS
      SELECT hcb.flgdebcc
            ,hcb.cdtrnbcb
            ,hcb.dstrnbcb
            ,tbcrd.cdhistor
            ,tbcrd.tphistorico
        FROM craphcb hcb,
             tbcrd_his_vinculo_bancoob tbcrd
       WHERE hcb.cdtrnbcb = pr_cdtrnbcb
         AND tbcrd.cdtrnbcb = hcb.cdtrnbcb;
      rw_craphcb cr_craphcb%ROWTYPE;
      
      -- cursor para busca dos vinculos da transacao bancoob de estorno
      CURSOR cr_craphcb_est (pr_cdtrnbcb IN craphcb.cdtrnbcb%TYPE) IS
      SELECT hcb.flgdebcc
            ,hcb.cdtrnbcb
            ,hcb.dstrnbcb
            ,tbcrd.cdhistor
            ,tbcrd.tphistorico
        FROM craphcb hcb,
             tbcrd_his_vinculo_bancoob tbcrd
       WHERE hcb.cdtrnbcb = pr_cdtrnbcb
         AND tbcrd.cdtrnbcb = hcb.cdtrnbcb
         AND tbcrd.tphistorico = 1; -- Offline
      rw_craphcb_est cr_craphcb_est%ROWTYPE;
      
      -- Busca de historicos
      CURSOR cr_craphis(pr_cdhistor IN craphis.cdhistor%TYPE) IS
      SELECT his.cdhistor
            ,his.dshistor
            ,his.indebcre
        FROM craphis his
       WHERE his.cdcooper = 3
         AND his.cdhistor = pr_cdhistor;
     rw_craphis cr_craphis%ROWTYPE;

      -- Buscar informações do associado
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%type,
                         pr_nrdconta crapass.nrdconta%type) IS
        SELECT ass.nrdconta,
               ass.cdagenci,
               ass.inpessoa,
               age.nmresage
          FROM crapass ass, crapage age
         WHERE ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%rowtype;
      
      -- Buscar informações do associado na nova coop (para incorporacao/migracao)
      CURSOR cr_crapass_dest (pr_cdcooper crapcop.cdcooper%type,
                              pr_nrdconta crapass.nrdconta%type) IS
        SELECT ass.cdcooper,
               ass.nrdconta,
               ass.cdagenci,
               ass.inpessoa,
               age.nmresage,
               cop.nmrescop,
               cop.cdagebcb
          FROM crapass ass, crapcop cop, crapage age
         WHERE ass.cdcooper = cop.cdcooper 
           AND ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass_dest cr_crapass_dest%rowtype;

      -- Verifica se houve lançamento no dia
      CURSOR cr_craplcm_dia(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_cdpesqbb IN VARCHAR2,
                        pr_nsuredec IN VARCHAR2,
                        pr_cdhistor IN crapdcb.cdhistor%TYPE,
                        pr_datamovt IN DATE,
                        pr_vldtrans IN craplcm.vllanmto%TYPE) IS
        SELECT lcm.nrdocmto,
               lcm.cdorigem,
               lcm.dtmvtolt
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.dtmvtolt = pr_datamovt
           AND lcm.cdbccxlt = 100
           AND lcm.nrdolote = 6902
           AND lcm.cdhistor = pr_cdhistor
           AND lcm.cdpesqbb = pr_cdpesqbb -- NUM CARTÃO
           AND TRIM(substr(lcm.nrdocmto,4,6))= pr_nsuredec --NSU REDE
           AND lcm.vllanmto = pr_vldtrans;
      rw_craplcm_dia cr_craplcm_dia%ROWTYPE;

       -- Verifica se houve lançamento
      CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_cdpesqbb IN VARCHAR2,
                        pr_nsuredec IN VARCHAR2,
                        --pr_tpmensag IN crapdcb.nrnsucap%TYPE,
                        pr_cdhistor IN crapdcb.cdhistor%TYPE,
                        pr_vldtrans IN craplcm.vllanmto%TYPE) IS
        SELECT lcm.nrdocmto,
               lcm.vllanmto,
               lcm.cdhistor,
               lcm.cdorigem,
               lcm.dtmvtolt
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdbccxlt = 100
           AND lcm.nrdolote = 6902
           AND lcm.cdhistor = pr_cdhistor
           AND TRIM(lcm.cdpesqbb) = TRIM(pr_cdpesqbb) --NUM CARTÃO
           AND TRIM(substr(lcm.nrdocmto,4,6)) = LPAD(pr_nsuredec,6,0)--NSU REDE
          AND lcm.vllanmto = pr_vldtrans;
      rw_craplcm cr_craplcm%ROWTYPE;
      
      -- Checagem de transferencia de contas
      CURSOR cr_craptco (pr_cdcopant IN crapcop.cdcooper%TYPE,
                         pr_nrctaant IN craptco.nrctaant%TYPE) IS
        SELECT tco.nrdconta,
               tco.cdcooper
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcopant
           AND tco.nrctaant = pr_nrctaant;
      rw_craptco cr_craptco%ROWTYPE;

      -- Gerar dados para o relatório
      procedure pc_insere_relato(pr_idxdados in varchar2,
                                 pr_cdcopreg in crapcop.cdcooper%TYPE,
                                 pr_nmrescop in crapcop.nmrescop%TYPE,
                                 pr_cdagenci in crapage.cdagenci%TYPE,
                                 pr_nmresage in crapage.nmresage%TYPE,
                                 pr_nrdconta in VARCHAR2,
                                 pr_cdtrnbcb in craphcb.cdtrnbcb%type,
                                 pr_dstrnbcb in craphcb.dstrnbcb%type,
                                 pr_cdhistor in craphis.cdhistor%type,
                                 pr_dshistor in VARCHAR2,
                                 pr_inpessoa in crapass.inpessoa%TYPE,
                                 pr_cdorigem in craplcm.cdorigem%TYPE,
                                 pr_dtdtrans in crapdcb.dtdtrans%TYPE,
                                 pr_dtmvtooo in crapdcb.dtmvtolt%TYPE,
                                 pr_flgdebcc in craphcb.flgdebcc%TYPE,
                                 pr_vldtrans NUMBER,
                                 pr_dscritic out varchar2) is 
        
      begin
        insert into tbgen_batch_relatorio_wrk(cdcooper
                                             ,cdprograma
                                             ,dsrelatorio
                                             ,dtmvtolt
                                             ,dschave
                                             ,nrdconta
                                             ,cdagenci
                                             ,dscritic)
                                       values(pr_cdcooper
                                             ,vr_cdprogra
                                             ,'DADOS_RELAT'
                                             ,pr_dtmvtolt
                                             ,pr_idxdados
                                             ,pr_cdcopreg
                                             ,pr_cdagenci
                                             ,pr_nmrescop||';'||     
                                              pr_nmresage||';'||
                                              pr_nrdconta||';'||
                                              pr_cdtrnbcb||';'||
                                              pr_dstrnbcb||';'||
                                              pr_cdhistor||';'||
                                              pr_dshistor||';'||
                                              pr_inpessoa||';'||
                                              pr_cdorigem||';'||
                                              to_char(pr_dtdtrans,'ddmmrrrr')||';'||
                                              to_char(pr_dtmvtooo,'ddmmrrrr')||';'||
                                              pr_flgdebcc||';'||
                                              to_char(pr_vldtrans,'fm999g999g999g999g990d00')||';');
                                   
      exception
        when others then
          pr_dscritic := 'Erro na rotina pc_insere_relato --> '||sqlerrm;
      end;


      -- Guardar registro para posteriormente inserir
      PROCEDURE pc_insert_craplcm(pr_cdcooper IN  craplcm.cdcooper%TYPE,
                                   pr_dtmvtolt IN  craplcm.dtmvtolt%type,
                                   pr_cdagenci IN  craplcm.cdagenci%type,
                                   pr_cdbccxlt IN  craplcm.cdbccxlt%type,
                                   pr_nrdolote IN  craplcm.nrdolote%type,
                                   pr_nrdctabb IN  craplcm.nrdctabb%type,
                                   pr_nrdocmto IN  craplcm.nrdocmto%type,
                                   pr_dtrefere IN  craplcm.dtrefere%type,
                                   pr_hrtransa IN  craplcm.hrtransa%type,
                                   pr_vllanmto IN  craplcm.vllanmto%type,
                                   pr_nrdconta IN  craplcm.nrdconta%type,
                                   pr_cdhistor IN  craplcm.cdhistor%type,
                                   pr_nrseqdig IN  craplcm.nrseqdig%type,
                                   pr_cdpesqbb IN  craplcm.cdpesqbb%TYPE,
                                   pr_dscritic OUT VARCHAR2) IS

      BEGIN

        -- definir index da temptable
        vr_idxlcm := lpad(pr_cdcooper,10,0) || to_char(pr_dtmvtolt,'rrrrmmdd')|| lpad(pr_cdagenci,5,'0') ||
                     lpad(pr_cdbccxlt,5,'0') || lpad(pr_nrdolote,10,'0') || lpad(pr_nrdctabb,10,'0')||
                     lpad(pr_nrdocmto,25,'0');

        IF vr_tab_craplcm.exists(vr_idxlcm) THEN
          pr_dscritic := 'Registro para craplcm ja existe: nrdctabb ->'|| pr_nrdctabb ||' nrdocmto -> '|| pr_nrdocmto;
        ELSE
          vr_tab_craplcm(vr_idxlcm).cdcooper :=  pr_cdcooper;
          vr_tab_craplcm(vr_idxlcm).dtmvtolt :=  pr_dtmvtolt;
          vr_tab_craplcm(vr_idxlcm).cdagenci :=  pr_cdagenci;
          vr_tab_craplcm(vr_idxlcm).cdbccxlt :=  pr_cdbccxlt;
          vr_tab_craplcm(vr_idxlcm).nrdolote :=  pr_nrdolote;
          vr_tab_craplcm(vr_idxlcm).nrdctabb :=  pr_nrdctabb;
          vr_tab_craplcm(vr_idxlcm).nrdocmto :=  pr_nrdocmto;
          vr_tab_craplcm(vr_idxlcm).dtrefere :=  pr_dtrefere;
          vr_tab_craplcm(vr_idxlcm).hrtransa :=  pr_hrtransa;
          vr_tab_craplcm(vr_idxlcm).vllanmto :=  pr_vllanmto;
          vr_tab_craplcm(vr_idxlcm).nrdconta :=  pr_nrdconta;
          vr_tab_craplcm(vr_idxlcm).cdhistor :=  pr_cdhistor;
          vr_tab_craplcm(vr_idxlcm).nrseqdig :=  pr_nrseqdig;
          vr_tab_craplcm(vr_idxlcm).cdpesqbb :=  pr_cdpesqbb;
          vr_tab_craplcm(vr_idxlcm).cdorigem :=  7; /* Origem do lançamento feito pelo programa*/
        END IF;
      END pc_insert_craplcm;

      -- Gravar registro para posteriormente realizar o insert
      PROCEDURE pc_insert_crapdcb(pr_tpmensag IN  crapdcb.tpmensag%TYPE,
                                  pr_nrnsucap IN  crapdcb.nrnsucap%TYPE,
                                  pr_dtdtrgmt IN  crapdcb.dtdtrgmt%type,
                                  pr_hrdtrgmt IN  crapdcb.hrdtrgmt%type,
                                  pr_cdcooper IN  crapdcb.cdcooper%type,
                                  pr_nrdconta IN  crapdcb.nrdconta%type,
                                  pr_nrseqarq IN  crapdcb.nrseqarq%type,
                                  pr_nrinstit IN  crapdcb.nrinstit%type,
                                  pr_cdprodut IN  crapdcb.cdprodut%type,
                                  pr_nrcrcard IN  crapdcb.nrcrcard%type,
                                  pr_tpdtrans IN  crapdcb.tpdtrans%type,
                                  pr_cddtrans IN  crapdcb.cddtrans%type,
                                  pr_cdhistor IN  crapdcb.cdhistor%type,
                                  pr_dtdtrans IN  crapdcb.dtdtrans%type,
                                  pr_dtpostag IN  crapdcb.dtpostag%type,
                                  pr_dtcnvvlr IN  crapdcb.dtcnvvlr%type,
                                  pr_vldtrans IN  crapdcb.vldtrans%type,
                                  pr_vldtruss IN  crapdcb.vldtruss%type,
                                  pr_cdautori IN  crapdcb.cdautori%type,
                                  pr_dsdtrans IN  crapdcb.dsdtrans%type,
                                  pr_cdcatest IN  crapdcb.cdcatest%type,
                                  pr_cddmoeda IN  crapdcb.cddmoeda%type,
                                  pr_vlmoeori IN  crapdcb.vlmoeori%type,
                                  pr_cddreftr IN  crapdcb.cddreftr%type,
                                  pr_cdagenci IN  crapdcb.cdagenci%type,
                                  pr_nridvisa IN  crapdcb.nridvisa%type,
                                  pr_cdtrresp IN  crapdcb.cdtrresp%type,
                                  pr_incoopon IN  crapdcb.incoopon%type,
                                  pr_txcnvuss IN  crapdcb.txcnvuss%type,
                                  pr_cdautban IN  crapdcb.cdautban%type,
                                  pr_idtrterm IN  crapdcb.idtrterm%type,
                                  pr_tpautori IN  crapdcb.tpautori%type,
                                  pr_cdproces IN  crapdcb.cdproces%type,
                                  pr_dstrorig IN  crapdcb.dstrorig%type,
                                  pr_nrnsuori IN  crapdcb.nrnsuori%TYPE,
                                  pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE,
                                  pr_rowid_dcb IN ROWID,
                                  pr_operacao IN VARCHAR2,
                                  pr_dscritic OUT VARCHAR2) IS
      BEGIN

        -- definir index da temptable
        vr_idxdcb := lpad(pr_tpmensag,4,'0')        || lpad(pr_nrnsucap,6,'0')||
                      to_char(pr_dtdtrgmt,'rrrrmmdd')|| lpad(pr_hrdtrgmt,6,'0')||
                     lpad(pr_cdcooper,10,'0')       || lpad(pr_nrdconta,12,'0');

        IF pr_operacao = 'A' THEN
          vr_tab_crapdcb(vr_idxdcb).rowid_dcb := pr_rowid_dcb;
        ELSIF vr_tab_crapdcb.exists(vr_idxdcb) THEN
            RETURN;
          END IF;

        -- Criar registro na pltable
        vr_tab_crapdcb(vr_idxdcb).operacao := pr_operacao;
        vr_tab_crapdcb(vr_idxdcb).det.tpmensag := pr_tpmensag;
        vr_tab_crapdcb(vr_idxdcb).det.nrnsucap := pr_nrnsucap;
        vr_tab_crapdcb(vr_idxdcb).det.dtdtrgmt := pr_dtdtrgmt;
        vr_tab_crapdcb(vr_idxdcb).det.hrdtrgmt := pr_hrdtrgmt;
        vr_tab_crapdcb(vr_idxdcb).det.cdcooper := pr_cdcooper;
        vr_tab_crapdcb(vr_idxdcb).det.nrdconta := pr_nrdconta;
        vr_tab_crapdcb(vr_idxdcb).det.nrseqarq := pr_nrseqarq;
        vr_tab_crapdcb(vr_idxdcb).det.nrinstit := pr_nrinstit;
        vr_tab_crapdcb(vr_idxdcb).det.cdprodut := pr_cdprodut;
        vr_tab_crapdcb(vr_idxdcb).det.nrcrcard := pr_nrcrcard;
        vr_tab_crapdcb(vr_idxdcb).det.tpdtrans := pr_tpdtrans;
        vr_tab_crapdcb(vr_idxdcb).det.cddtrans := pr_cddtrans;
        vr_tab_crapdcb(vr_idxdcb).det.cdhistor := pr_cdhistor;
        vr_tab_crapdcb(vr_idxdcb).det.dtdtrans := pr_dtdtrans;
        vr_tab_crapdcb(vr_idxdcb).det.dtpostag := pr_dtpostag;
        vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr := pr_dtcnvvlr;
        vr_tab_crapdcb(vr_idxdcb).det.vldtrans := pr_vldtrans;
        vr_tab_crapdcb(vr_idxdcb).det.vldtruss := pr_vldtruss;
        vr_tab_crapdcb(vr_idxdcb).det.cdautori := pr_cdautori;
        vr_tab_crapdcb(vr_idxdcb).det.dsdtrans := pr_dsdtrans;
        vr_tab_crapdcb(vr_idxdcb).det.cdcatest := pr_cdcatest;
        vr_tab_crapdcb(vr_idxdcb).det.cddmoeda := pr_cddmoeda;
        vr_tab_crapdcb(vr_idxdcb).det.vlmoeori := pr_vlmoeori;
        vr_tab_crapdcb(vr_idxdcb).det.cddreftr := pr_cddreftr;
        vr_tab_crapdcb(vr_idxdcb).det.cdagenci := pr_cdagenci;
        vr_tab_crapdcb(vr_idxdcb).det.nridvisa := pr_nridvisa;
        vr_tab_crapdcb(vr_idxdcb).det.cdtrresp := pr_cdtrresp;
        vr_tab_crapdcb(vr_idxdcb).det.incoopon := pr_incoopon;
        vr_tab_crapdcb(vr_idxdcb).det.txcnvuss := pr_txcnvuss;
        vr_tab_crapdcb(vr_idxdcb).det.cdautban := pr_cdautban;
        vr_tab_crapdcb(vr_idxdcb).det.idtrterm := pr_idtrterm;
        vr_tab_crapdcb(vr_idxdcb).det.tpautori := pr_tpautori;
        vr_tab_crapdcb(vr_idxdcb).det.cdproces := pr_cdproces;
        vr_tab_crapdcb(vr_idxdcb).det.dstrorig := pr_dstrorig;
        vr_tab_crapdcb(vr_idxdcb).det.nrnsuori := pr_nrnsuori;
        vr_tab_crapdcb(vr_idxdcb).det.dtmvtolt := pr_dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro na rotina pc_insert_crapdcb --> '||SQLERRM;
      END pc_insert_crapdcb;

        

      BEGIN
        -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => vr_cdprogra
                                  ,pr_action => 'CCRD0003.pc_crps670_process');                                  
        -- Caso execucao paralela
        IF pr_idparale <> 0 THEN 
          -- Grava controle de batch por agência
          gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper      -- Codigo da Cooperativa
                                          ,pr_cdprogra    => vr_cdprogra      -- Codigo do Programa
                                          ,pr_dtmvtolt    => pr_dtmvtolt      -- Data de Movimento
                                          ,pr_tpagrupador => 1                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                          ,pr_cdagrupador => pr_nrseqexe      -- Codigo do agrupador conforme (tpagrupador)
                                          ,pr_cdrestart   => null             -- Controle do registro de restart em caso de erro na execucao
                                          ,pr_nrexecucao  => 1                -- Numero de identificacao da execucao do programa
                                          ,pr_idcontrole  => vr_idcontrole    -- ID de Controle
                                          ,pr_cdcritic    => pr_cdcritic      -- Codigo da critica
                                          ,pr_dscritic    => vr_dscritic);    -- Descricao da critica
          -- Testar saida com erro
          if vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;    
        end if;
                 
        -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I'  
                       ,pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe          
                       ,pr_cdcooper   => pr_cdcooper 
                       ,pr_tpexecucao => 2    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_idprglog   => vr_idlog_ini_par); 

        -- Buscar data base para transacoes com contas migradas no periodo da migracao
        vr_dtcxtmig := to_date(pr_dtcxtmig,'dd/mm/rrrr');

        -- Ler todas as linhas da tabela direcionadas para essa execução
        FOR rw_arq in cr_work_arq(pr_cdcooper
                                 ,pr_nrseqexe
                                 ,vr_cdprogra
                                 ,'DADOS_ARQ' 
                                 ,pr_dtmvtolt) LOOP
              BEGIN
                vr_nrdlinha:= vr_nrdlinha + 1;

                -- busca a cooperativa com base na agencia bancoob
            OPEN cr_crapcop_cdagebcb(pr_cdagebcb => substr(rw_arq.des_text,165,6));
                FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;

                IF cr_crapcop_cdagebcb%NOTFOUND THEN
                  -- Fechar o cursor pois havera raise
                  CLOSE cr_crapcop_cdagebcb;
                  -- Montar mensagem de critica
              vr_dscritic := 'Cod. Agencia da Bancoob ' || substr(rw_arq.des_text,165,6) ||
                                 ' nao possui Cooperativa correspondente.';
                  RAISE vr_exc_rejeitado;
                END IF;

                -- Fecha cursor cooperativa
                CLOSE cr_crapcop_cdagebcb;

                --limpar rowtype
                rw_craphcb := NULL;
                
                -- limpar variaveis para controle de debito
                vr_cdtrnbcb_ori := 0;
                vr_flgdebcc := 0;
                vr_dstrnbcb := '';
                vr_cdhistor_on := 0;
                vr_cdhistor_off := 0;
                
                -- não buscar historico qaundo for movimento de consulta
            IF  nvl(trim(substr(rw_arq.des_text,27,1)),' ') <> 'M' THEN
                    
              vr_cdtrnbcb_ori := TO_NUMBER(substr(rw_arq.des_text,28,3));
                  
                  -- busca vinculo dos historicos com transacao bancoob
              FOR rw_craphcb IN cr_craphcb(pr_cdtrnbcb => TO_NUMBER(substr(rw_arq.des_text,28,3))) LOOP                   
                    
                    vr_flgdebcc := rw_craphcb.flgdebcc;
                    vr_dstrnbcb := rw_craphcb.dstrnbcb;
                  
                    IF rw_craphcb.tphistorico = 0 THEN -- Historico Online
                      vr_cdhistor_on := rw_craphcb.cdhistor;
                    ELSIF rw_craphcb.tphistorico = 1 THEN -- Historico Offline
                      vr_cdhistor_off := rw_craphcb.cdhistor;                
                    END IF;                            
                                
                    
                    -- Buscar descricao dos historicos
                    OPEN cr_craphis (pr_cdhistor => rw_craphcb.cdhistor);
                      FETCH cr_craphis INTO rw_craphis;

                      -- Se nao encontrar histórico
                      IF cr_craphis%NOTFOUND THEN
                         -- fechar o cursor
                         CLOSE cr_craphis;   
                         -- Montar mensagem de critica
                         vr_dscritic := 'Historico ' || rw_craphcb.cdhistor ||
                                        ' nao encontrado.';
                         RAISE vr_exc_rejeitado;                       
                      ELSE
                        -- fechar o cursor
                        CLOSE cr_craphis;
                         
                        IF rw_craphcb.tphistorico = 0 THEN -- Historico Online
                          vr_dshistor_on := rw_craphis.cdhistor || ' - ' || rw_craphis.dshistor;
                          vr_indebcre_on := rw_craphis.indebcre;
                        ELSIF rw_craphcb.tphistorico = 1 THEN -- Historico Offline
                          vr_dshistor_off := rw_craphis.cdhistor || ' - ' || rw_craphis.dshistor;
                          vr_indebcre_off := rw_craphis.indebcre;
                        END IF;
                         
                      END IF;
                  END LOOP;
                  
                  -- Validar se historicos Online/Offline sao validos
                  IF vr_cdhistor_on = 0 THEN
                vr_dscritic := 'Historico Online para a Transacao ' || TO_NUMBER(substr(rw_arq.des_text,28,3)) ||
                                   ' nao cadastrado.';
                    RAISE vr_exc_rejeitado;
                  END IF;
                    
                  IF vr_cdhistor_off = 0 THEN
                vr_dscritic := 'Historico Offline para a Transacao ' || TO_NUMBER(substr(rw_arq.des_text,28,3)) ||
                                   ' nao cadastrado.';
                    RAISE vr_exc_rejeitado;
                  END IF;    
                END IF;

                vr_nrdconta := NULL;
                
                --reseta as variaveis
                vr_cdorigem := 0;
                vr_dtmovtoo := NULL;                 
                
                -- EXTRAIR NUMERO DA CONTA
                BEGIN
              vr_nrdconta := to_number(substr(rw_arq.des_text,171,12));
                EXCEPTION
                  WHEN OTHERS THEN
                vr_dscritic := 'Numero de conta invalido nrdconta: '||substr(rw_arq.des_text,171,12)||' !';
                    RAISE vr_exc_rejeitado;
                END;                                
                
                -- verifica se eh uma cooperativa inativa
                IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                  
                  OPEN cr_craptco (pr_cdcopant => rw_crapcop_cdagebcb.cdcooper,
                                   pr_nrctaant => vr_nrdconta);
                  FETCH cr_craptco INTO rw_craptco;
                  
                  IF cr_craptco%NOTFOUND THEN
                    vr_dscritic := 'Associado migrado nrdconta: '||vr_nrdconta||' não encontrado!';
                    CLOSE cr_craptco;
                    RAISE vr_exc_rejeitado;                                      
                  END IF;
                  
                  CLOSE cr_craptco;
                                    
                  /* precisamos pegar a nova coop e nova conta para usar na hora de fazer o lancamento,
                     se necessario */                                                                        
                  -- Buscar informações dos associados
                  OPEN cr_crapass_dest (pr_cdcooper => rw_craptco.cdcooper,
                                        pr_nrdconta => rw_craptco.nrdconta);
                  FETCH cr_crapass_dest into rw_crapass_dest;
                  -- caso não encontrar, levantar exception
                  IF cr_crapass_dest%NOTFOUND THEN
                    vr_dscritic := 'Associado nrdconta: '||rw_craptco.nrdconta||' não encontrado!';
                    CLOSE cr_crapass_dest;
                    RAISE vr_exc_rejeitado;
                  END IF;

                  CLOSE cr_crapass_dest;
                  
                  /* se a data transacao eh a partir de 31/12 <parametro> 
                     entao nao pode mais buscar na coop antiga */
              IF to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmRRRR') >= vr_dtcxtmig THEN
                    vr_nrdconta := nvl(rw_craptco.nrdconta,0);                                                                                                               
                  
                    IF cr_crapcop_cdagebcb%ISOPEN THEN
                      CLOSE cr_crapcop_cdagebcb;
                    END IF;
                  
                    -- busca os dados da cooperativa incorporadora (nova coop)
                    OPEN cr_crapcop_cdagebcb(pr_cdagebcb => rw_crapass_dest.cdagebcb);
                    FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;

                    IF cr_crapcop_cdagebcb%NOTFOUND THEN
                      -- Fechar o cursor pois havera raise
                      CLOSE cr_crapcop_cdagebcb;
                      -- Montar mensagem de critica
                      vr_dscritic := 'Cod. Agencia do Bancoob ' || rw_crapass_dest.cdagebcb ||
                                     ' nao possui Cooperativa correspondente.';
                      RAISE vr_exc_rejeitado;
                    END IF;

                    -- Fecha cursor cooperativa
                    CLOSE cr_crapcop_cdagebcb;
                  END IF;
                END IF;
                
                -- Buscar informações dos associados
                OPEN cr_crapass (pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                 pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass into rw_crapass;
                -- caso não encontrar, levantar exception
                IF cr_crapass%NOTFOUND THEN
                  vr_dscritic := 'Associado nrdconta: '||vr_nrdconta||' não encontrado!';
                  CLOSE cr_crapass;
                  RAISE vr_exc_rejeitado;
                END IF;

                CLOSE cr_crapass; 
                 
                -- CÓDIGO DA TRANSAÇÃO
            vr_cdtrnbcb := gene0002.fn_char_para_number(nvl(trim(substr(rw_arq.des_text,28,3)),0));
                               
                /*******************************/
                -- verifica se deve debitar C/C
                IF vr_flgdebcc = 1 THEN
                    --DATA E HORA DA TRANSAÇÃO GMT
              vr_dthstran := gene0002.fn_char_para_number(nvl(trim(substr(rw_arq.des_text,204,10)),0));
                    -- TIPO DE TRANSAÇÃO
              vr_indebcre := trim(substr(rw_arq.des_text,27,1));
                                     
                    -- NUMERO DO CARTAO
              vr_cdpesqbb := trim(substr(rw_arq.des_text,7,19));
                    -- NSU DA REDE DE CAPTURA
              vr_nsuredec := trim(substr(rw_arq.des_text,198,6));
                    -- DATA DO LANCAMENTO
              vr_dtmvtolt := pr_dtmvtolt;

                    -- COOPERATIVA BANCOOB
                    vr_cdcopban :=  rw_crapcop_cdagebcb.cdcooper;

              vr_cdcrimsg := substr(rw_arq.des_text,214,2);
              vr_vldtrans := (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100);

                    --resetar as variaveis
                    vr_tpmsg200 := FALSE;
                    vr_tpmsg220 := FALSE;
                    vr_tpmsg420 := FALSE;                   

                    -- validar nsu, para utilizar no numero de documento
              vr_nrdocmto := nvl(trim(substr(rw_arq.des_text,198,6)),0);                                       
                 
                    -- se estiver zerado usar i cod. autorização
                    IF nvl(vr_nrdocmto,0) = 0 THEN
                       -- Chamar a rotina de geração do NSU
                vr_nrdocmto := CCRD0002.fn_busca_nsu_transacao(pr_tpmensag => trim(substr(rw_arq.des_text,254, 4))
                                                              ,pr_nrnsucap => trim(substr(rw_arq.des_text,77,6))
                                                              ,pr_dtdtrgmt => trim(substr(rw_arq.des_text,204,10)));
                    ELSE
                        -- Chamar a rotina de geração do NSU
                vr_nrdocmto := CCRD0002.fn_busca_nsu_transacao(pr_tpmensag => trim(substr(rw_arq.des_text,254, 4))
                                                              ,pr_nrnsucap => trim(substr(rw_arq.des_text,198, 6))
                                                              ,pr_dtdtrgmt => trim(substr(rw_arq.des_text,204,10)));
                    END IF;

                    -- verifica se já existe debito de cartão bancoob
                    OPEN cr_crapdcb(pr_nrnsucap => vr_nsuredec,
                                    pr_cdcooper => vr_cdcopban,
                                    pr_nrdconta => rw_crapass.nrdconta,
                                    pr_vldtrans => vr_vldtrans,
                              pr_nrseqarq => pr_nrseqarq,
                              pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'));
                    FETCH cr_crapdcb INTO rw_crapdcb;

                    IF cr_crapdcb%NOTFOUND THEN

                       OPEN cr_craplcm_dia(vr_cdcopban,
                                           rw_crapass.nrdconta,
                                           vr_cdpesqbb,
                                           vr_nsuredec,
                                           vr_cdhistor_on,
                                    to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                                           vr_vldtrans);
                        FETCH cr_craplcm_dia INTO rw_craplcm_dia;

                        IF cr_craplcm_dia%NOTFOUND THEN
                           OPEN cr_craplcm(vr_cdcopban,
                                           rw_crapass.nrdconta,
                                           vr_cdpesqbb,
                                           vr_nsuredec,
                                           vr_cdhistor_on,
                                           vr_vldtrans);
                           FETCH cr_craplcm INTO rw_craplcm;
                           IF cr_craplcm%NOTFOUND THEN
                               IF vr_cdcrimsg = '00' THEN
                                  vr_crialcmt := TRUE;
                               ELSE
                                  vr_crialcmt := FALSE;
                               END IF;
                            ELSE
                              vr_crialcmt := FALSE;
                            END IF;
                            CLOSE cr_craplcm;
                         ELSE
                              vr_crialcmt := FALSE;                             
                         END IF;
                    
                         CLOSE cr_craplcm_dia;
                         CLOSE cr_crapdcb;

                    ELSE  --SE ACHOU MENSAGENS
                        CLOSE cr_crapdcb;
                        --  PERCORRE OS debitos de cartão bancoob
                        FOR rw_crapdcb IN cr_crapdcb (pr_nrnsucap => vr_nsuredec,
                                                      pr_cdcooper => vr_cdcopban,
                                                      pr_nrdconta => rw_crapass.nrdconta,
                                                      pr_vldtrans => vr_vldtrans,
                                              pr_nrseqarq => pr_nrseqarq,
                                              pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd')) LOOP

                         vr_tpmensag := rw_crapdcb.tpmensag;
                vr_cdcrimsg := substr(rw_arq.des_text,214,2);
                         vr_vldtrans :=  rw_crapdcb.vldtrans;
                           -- verifica se existe lancamento correpondente no dia
                           OPEN cr_craplcm_dia(vr_cdcopban,
                                               rw_crapass.nrdconta,
                                               vr_cdpesqbb,
                                               rw_crapdcb.nrnsucap,
                                               rw_crapdcb.cdhistor,
                                               rw_crapdcb.dtmvtolt,
                                               vr_vldtrans);
                           FETCH cr_craplcm_dia INTO rw_craplcm_dia;

                           IF cr_craplcm_dia%NOTFOUND THEN -- se não encontrar NO DIA, verifica se existe outro lancamento correspondente ao nsu
                              OPEN cr_craplcm(vr_cdcopban,
                                           rw_crapass.nrdconta,
                                           vr_cdpesqbb,
                                           rw_crapdcb.nrnsucap,
                                           rw_crapdcb.cdhistor,
                                           vr_vldtrans);
                              FETCH cr_craplcm INTO rw_craplcm;

                              IF cr_craplcm%NOTFOUND THEN -- se não encontrar lancamento verifica se é necessário fazê-lo
                                 IF vr_tpmensag = '0200' AND vr_cdcrimsg <> '00' THEN
                                    vr_crialcmt := FALSE;
                                 ELSIF vr_tpmensag = '0220' AND vr_tpmsg200  THEN
                                    vr_crialcmt := FALSE;
                                 ELSIF vr_tpmensag = '0420' AND vr_tpmsg200 AND vr_cdcrimsg = '00' AND vr_indebcre = 'C' THEN
                                    vr_crialcmt := TRUE;
                                 ELSIF vr_tpmensag = '0420' AND NOT vr_tpmsg200 AND NOT vr_tpmsg220 AND vr_cdcrimsg <> '00' THEN
                                    vr_crialcmt := FALSE;
                                 ELSIF vr_tpmensag = '0420' AND vr_tpmsg220  AND vr_cdcrimsg = '00' AND vr_indebcre = 'C' THEN
                                    vr_crialcmt := TRUE;
                                 ELSIF vr_tpmensag = '0420' AND  vr_cdcrimsg = '00' THEN
                                    vr_crialcmt := FALSE;
                                 ELSE
                                    vr_crialcmt := TRUE;
                                 END IF;
                                 CLOSE cr_craplcm;
                              ELSE -- se encontrar verifica se há necessidade de fazê-lo
                                 vr_cdorigem := rw_craplcm.cdorigem;
                                 vr_dtmovtoo := rw_craplcm.dtmvtolt;
                                 IF vr_indebcre = rw_craphis.indebcre AND vr_cdtrnbcb = vr_cdtrnbcb_ori THEN
                                    /*SE FOR UM CREDITO EFETUA O LANÇAMENTO*/
                                    IF vr_indebcre = 'C' AND vr_cdcrimsg = '00' AND vr_tpmensag <> '0420' THEN
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmsg200 AND vr_tpmsg420 AND vr_cdcrimsg = '00' THEN -- tem a 200 e a 420 mas veio sem critica no arquivo
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmensag = '0200' AND (vr_cdcrimsg <> '00' OR vr_cdcrimsg <> nvl(TRIM(rw_crapdcb.cdtrresp),'00')) THEN
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmensag = '0220' AND vr_cdcrimsg <> '00'  THEN
                                       vr_crialcmt := TRUE;
                                    ELSIF vr_tpmensag = '0420' AND vr_tpmsg200  AND vr_tpmsg220 AND NOT vr_tpmsg420 AND vr_cdcrimsg <> '00'  THEN
                                       vr_crialcmt := TRUE;
                                    ELSE
                                       vr_crialcmt := FALSE;
                                    END IF;
                                  ELSE
                                    vr_crialcmt := TRUE;
                                  END IF;

                                  --seta o tipo de mensagem encontrada
                                  IF vr_tpmensag = '0200' THEN
                                     vr_tpmsg200 := TRUE;
                                  ELSIF vr_tpmensag = '0220' THEN
                                     vr_tpmsg220 := TRUE;
                                  ELSIF vr_tpmensag = '0420' THEN
                                     vr_tpmsg420 := TRUE;
                                  END IF;
                               CLOSE cr_craplcm;

                              END IF;
                            ELSE -- se encontrar o lançamento no dia, verifica se há necessidade de fazê-lo
                               vr_cdorigem := rw_craplcm_dia.cdorigem; -- Grava a origem do lancamento para o relatorio
                               vr_dtmovtoo := rw_craplcm_dia.dtmvtolt;
                               IF vr_indebcre = rw_craphis.indebcre AND vr_cdtrnbcb = vr_cdtrnbcb_ori THEN
                                  /*SE FOR UM CREDITO EFETUA O LANÇAMENTO*/
                                  IF vr_indebcre = 'C'AND vr_cdcrimsg = '00' AND vr_tpmensag <> '0420' THEN   
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmsg200 AND vr_tpmsg420 AND vr_cdcrimsg = '00' THEN -- tem a 200 e a 420 mas veio sem critica no arquivo
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmensag = '0200' AND (vr_cdcrimsg <> '00' OR vr_cdcrimsg <> nvl(TRIM(rw_crapdcb.cdtrresp),'00')) THEN
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmensag = '0220' AND vr_cdcrimsg <> '00'  THEN
                                     vr_crialcmt := TRUE;
                                  ELSIF vr_tpmensag = '0420' AND vr_tpmsg200  AND vr_tpmsg220 AND NOT vr_tpmsg420 AND vr_cdcrimsg <> '00'  THEN
                                     vr_crialcmt := TRUE;
                                  ELSE
                                     vr_crialcmt := FALSE;
                                  END IF;

                                ELSE
                                  vr_crialcmt := TRUE;
                                END IF;

                                --seta o tipo de mensagem encontrada
                                IF vr_tpmensag = '0200' THEN
                                   vr_tpmsg200 := TRUE;
                                ELSIF vr_tpmensag = '0220' THEN
                                   vr_tpmsg220 := TRUE;
                                ELSIF vr_tpmensag = '0420' THEN
                                   vr_tpmsg420 := TRUE;
                                END IF;
                            END IF;
                            CLOSE cr_craplcm_dia;
                        END LOOP;
                   END IF;
                   
                  /* EFETUA DÉBITOS*/
            IF substr(rw_arq.des_text,214,2)  = '00'  THEN

                     IF vr_crialcmt THEN
                       
                       -- se a coop do registro esta inativa, usa coop e conta nova
                       IF rw_crapcop_cdagebcb.flgativo = 0 THEN                         
                         vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapass_dest.cdcooper||';'||
                                                                                  to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                  rw_crapass_dest.cdagenci||';'||
                                                                                  vr_cdbccxlt||';'||
                                                                                  vr_nrdolote||'');

                          -- se marcado para debitar
                          -- cria registro na tabela de lançamentos
                          -- Guardar registro para posteriormente inserir
                          pc_insert_craplcm( pr_cdcooper  => rw_crapass_dest.cdcooper,
                                             pr_dtmvtolt  => vr_dtmvtolt,
                                             pr_cdagenci  => rw_crapass_dest.cdagenci,
                                             pr_cdbccxlt  => vr_cdbccxlt,
                                             pr_nrdolote  => vr_nrdolote,
                                     pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                             pr_nrdocmto  => vr_nrdocmto,
                                     pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                     pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                     pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                             pr_nrdconta  => nvl(rw_crapass_dest.nrdconta,0), -- nrdconta nova
                                             pr_cdhistor  => vr_cdhistor_off,
                                             pr_nrseqdig  => vr_nrseqdig_lot,
                                             pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                             pr_dscritic  => vr_dscritic );

                          IF vr_dscritic IS NOT NULL THEN
                            RAISE vr_exc_rejeitado;
                          END IF;
                       ELSE                       
                          vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapcop_cdagebcb.cdcooper||';'||
                                                                                  to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                  rw_crapass.cdagenci||';'||
                                                                                  vr_cdbccxlt||';'||
                                                                                  vr_nrdolote||'');

                          -- se marcado para debitar
                          -- cria registro na tabela de lançamentos
                          -- Guardar registro para posteriormente inserir
                          pc_insert_craplcm( pr_cdcooper  => vr_cdcopban,
                                             pr_dtmvtolt  => vr_dtmvtolt,
                                             pr_cdagenci  => rw_crapass.cdagenci,
                                             pr_cdbccxlt  => vr_cdbccxlt,
                                             pr_nrdolote  => vr_nrdolote,
                                     pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                             pr_nrdocmto  => vr_nrdocmto,
                                     pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                     pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                     pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                             pr_nrdconta  => nvl(rw_crapass.nrdconta,0), -- nrdconta
                                             pr_cdhistor  => vr_cdhistor_off,
                                             pr_nrseqdig  => vr_nrseqdig_lot,
                                             pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                             pr_dscritic  => vr_dscritic );

                          IF vr_dscritic IS NOT NULL THEN
                            RAISE vr_exc_rejeitado;
                          END IF;                        
                        END IF;
                      END IF;

                   ELSE --ESTORNO DA CONTA = CRÉDITO NA CONTA
              IF substr(rw_arq.des_text,214,2)  <> '00' THEN

                         IF vr_crialcmt THEN

                  vr_cdhistor := TO_NUMBER(substr(rw_arq.des_text,28,3)) ;
                            
                              IF (vr_cdhistor < 100) THEN
                                  -- busca histórico do Estorno
                    OPEN cr_craphcb_est (pr_cdtrnbcb => (TO_NUMBER(substr(rw_arq.des_text,28,3))+100));
                                  FETCH cr_craphcb_est INTO rw_craphcb_est;

                                  -- Se nao encontrar histórico
                                  IF cr_craphcb_est%NOTFOUND THEN
                                     -- fechar o cursor
                                     CLOSE cr_craphcb_est;
                                     -- Montar mensagem de critica
                       vr_dscritic := 'Historico para a Transacao ' || TO_NUMBER(substr(rw_arq.des_text,28,3)) ||
                                                    ' nao encontrado.';
                                     RAISE vr_exc_rejeitado;
                                  ELSE
                                     -- fechar o cursor
                                     CLOSE cr_craphcb_est;
                                  END IF;
                               END IF;
                               
                              -- se a coop do registro esta inativa, usa coop e conta nova 
                              IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                                vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapass_dest.cdcooper||';'||
                                                                                        to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                        rw_crapass_dest.cdagenci||';'||
                                                                                        vr_cdbccxlt||';'||
                                                                                        vr_nrdolote||'');
                                                             
                                -- Guardar registro para posteriormente inserir
                                pc_insert_craplcm( pr_cdcooper  => rw_crapass_dest.cdcooper,
                                                   pr_dtmvtolt  => vr_dtmvtolt,
                                                   pr_cdagenci  => rw_crapass_dest.cdagenci,
                                                   pr_cdbccxlt  => vr_cdbccxlt,
                                                   pr_nrdolote  => vr_nrdolote,
                                       pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                                   pr_nrdocmto  => vr_nrdocmto,
                                       pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                       pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                       pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                                   pr_nrdconta  => nvl(rw_crapass_dest.nrdconta,0), -- nrdconta
                                                   pr_cdhistor  => rw_craphcb_est.cdhistor,
                                                   pr_nrseqdig  => vr_nrseqdig_lot,
                                                   pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                                   pr_dscritic  => vr_dscritic );

                                IF vr_dscritic IS NOT NULL THEN
                                  RAISE vr_exc_rejeitado;
                                END IF;
                              ELSE
                                vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_crapcop_cdagebcb.cdcooper||';'||
                                                                                        to_char(vr_dtmvtolt,'dd/mm/yyyy')||';'||
                                                                                        rw_crapass.cdagenci||';'||
                                                                                        vr_cdbccxlt||';'||
                                                                                        vr_nrdolote||'');
                                -- Guardar registro para posteriormente inserir
                                pc_insert_craplcm( pr_cdcooper  => vr_cdcopban,
                                                   pr_dtmvtolt  => vr_dtmvtolt,
                                                   pr_cdagenci  => rw_crapass.cdagenci,
                                                   pr_cdbccxlt  => vr_cdbccxlt,
                                                   pr_nrdolote  => vr_nrdolote,
                                       pr_nrdctabb  => nvl(trim(substr(rw_arq.des_text,171,12)),0),
                                                   pr_nrdocmto  => vr_nrdocmto,
                                       pr_dtrefere  => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                       pr_hrtransa  => nvl(trim(substr(rw_arq.des_text,208,6)),0),
                                       pr_vllanmto  => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                                   pr_nrdconta  => nvl(rw_crapass.nrdconta,0), -- nrdconta
                                                   pr_cdhistor  => rw_craphcb_est.cdhistor,
                                                   pr_nrseqdig  => vr_nrseqdig_lot,
                                                   pr_cdpesqbb  => nvl(vr_cdpesqbb,' '),
                                                   pr_dscritic  => vr_dscritic );

                                IF vr_dscritic IS NOT NULL THEN
                                  RAISE vr_exc_rejeitado;
                                END IF;
                              END IF;
                          END IF;
                      END IF;
                   END IF;
                ELSE
                  -- ALTERACAO JMD                   
                  IF vr_cdtrnbcb IN('14','50','56') THEN
                    IF vr_cdtrnbcb = '14' THEN
                      vr_tipostaa := 4;
                    ELSIF vr_cdtrnbcb = '50' THEN
                      vr_tipostaa := 2;
                    ELSE
                      vr_tipostaa := 3;
                    END IF;
                    -- se coop do registro esta inativa, temos que ver na coop destino
                    IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapass_dest.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => nvl(rw_crapass_dest.nrdconta,0)
                                                          ,pr_tipotari => 1
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    ELSE
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop_cdagebcb.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => vr_nrdconta
                                                          ,pr_tipotari => 1
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    END IF;
                    
                    IF vr_dscritic IS NOT NULL OR
                       vr_cdcritic <> 0 THEN
                       RAISE vr_exc_saida;
                    END IF;
                  ELSIF vr_cdtrnbcb IN('15','52','64') THEN
                    
                    IF vr_cdtrnbcb = '15' THEN
                      vr_tipostaa := 4;
                    ELSIF vr_cdtrnbcb = '52' THEN
                      vr_tipostaa := 2;
                    ELSE
                      vr_tipostaa := 3;
                    END IF;
                    
                    -- se coop do registro esta inativa, temos que ver na coop destino
                    IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapass_dest.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => nvl(rw_crapass_dest.nrdconta,0)
                                                          ,pr_tipotari => 2
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    ELSE
                      TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => rw_crapcop_cdagebcb.cdcooper
                                                          ,pr_cdoperad => 1
                                                          ,pr_cdagenci => 1
                                                          ,pr_cdbccxlt => 100
                                                    ,pr_dtmvtolt => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                                                          ,pr_cdprogra => vr_cdprogra
                                                          ,pr_idorigem => 4
                                                          ,pr_nrdconta => vr_nrdconta
                                                          ,pr_tipotari => 2
                                                          ,pr_tipostaa => vr_tipostaa
                                                          ,pr_qtoperac => 0
                                                          ,pr_qtacobra => vr_qtacobra
                                                          ,pr_fliseope => vr_fliseope
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                    END IF;
                    
                    IF vr_dscritic IS NOT NULL OR
                       vr_cdcritic <> 0 THEN
                       RAISE vr_exc_saida;
                    END IF;  
                  END IF;
                  -- FIM ALTERACAO JMD                          
                END IF;

               -- verifica se já existe debito de cartão bancoob msg 0200 (historico online)
          OPEN cr_crapdcb_200 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                               pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                               pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                     pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                     pr_nrdconta => rw_crapass.nrdconta,
                                     pr_cdhistor => vr_cdhistor_on);
                FETCH cr_crapdcb_200 INTO rw_crapdcb_200;
                IF cr_crapdcb_200%NOTFOUND THEN
                  CLOSE cr_crapdcb_200;
                  -- verifica se já existe debito de cartão bancoob msg 0200 (historico offline)
            OPEN cr_crapdcb_200 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                                 pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                 pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                       pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                       pr_nrdconta => rw_crapass.nrdconta,
                                       pr_cdhistor => vr_cdhistor_off);
                  FETCH cr_crapdcb_200 INTO rw_crapdcb_200;
                END IF;

                -- Se nao existir vai criar registro de débito
                IF cr_crapdcb_200%NOTFOUND THEN                    
                   -- Se for crédito insere com o tipo 0400 - Cancelamento de Compra ou Saque em ATM com cartão na função débito
            IF nvl(trim(substr(rw_arq.des_text,27,1)),0) = 'C' AND substr(rw_arq.des_text,214,2) = '00' THEN
                      vr_tpmensag := '0400';
                      -- verifica se já existe Credito de cartão bancoob msg 0400 (historico online)
              OPEN cr_crapdcb_400 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                                   pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                   pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                           pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                           pr_nrdconta => rw_crapass.nrdconta,
                                           pr_cdhistor => vr_cdhistor_on);
                      FETCH cr_crapdcb_400 INTO rw_crapdcb_400;
                      IF cr_crapdcb_400%NOTFOUND THEN
                        CLOSE cr_crapdcb_400;
                        -- verifica se já existe Credito de cartão bancoob msg 0400 (historico online)
                OPEN cr_crapdcb_400 (pr_nrnsucap => substr(rw_arq.des_text,198,6),
                                     pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                     pr_hrdtrgmt => substr(rw_arq.des_text,208,6),
                                             pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                             pr_nrdconta => rw_crapass.nrdconta,
                                             pr_cdhistor => vr_cdhistor_off);
                        FETCH cr_crapdcb_400 INTO rw_crapdcb_400;
                      END IF;
                      IF cr_crapdcb_400%NOTFOUND THEN
                         vr_criardcb := TRUE;
                      ELSE
                         vr_criardcb := FALSE; 
                      END IF;
                      CLOSE cr_crapdcb_400;  
                   ELSE
              vr_tpmensag := nvl(trim(substr(rw_arq.des_text,254,4)),' ');
                      vr_criardcb := TRUE;
                   END IF;
                   
                   IF vr_criardcb THEN
                      -- se coop do registro esta inativa, temos que ver na coop destino
                      IF rw_crapcop_cdagebcb.flgativo = 0 THEN
                        pc_insert_crapdcb(pr_tpmensag => vr_tpmensag,
                                  pr_nrnsucap => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                  pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                  pr_hrdtrgmt => nvl(substr(rw_arq.des_text,208,6),0),
                                          pr_cdcooper => rw_crapass_dest.cdcooper,
                                          pr_nrdconta => nvl(rw_crapass_dest.nrdconta,0), -- nrdconta
                                  pr_nrseqarq => nvl(pr_nrseqarq,0),
                                  pr_nrinstit => nvl(trim(substr(rw_arq.des_text,1,3)),0),
                                  pr_cdprodut => nvl(trim(substr(rw_arq.des_text,4,3)),0),
                                  pr_nrcrcard => nvl(trim(substr(rw_arq.des_text,7,19)),' '),
                                  pr_tpdtrans => nvl(trim(substr(rw_arq.des_text,27,1)),' '),
                                  pr_cddtrans => nvl(trim(substr(rw_arq.des_text,28,3)),0),
                                          pr_cdhistor => vr_cdhistor_off,
                                  pr_dtdtrans => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                  pr_dtpostag => to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                                  pr_dtcnvvlr => to_date(trim(substr(rw_arq.des_text,47,8)),'ddmmyyyy'),
                                  pr_vldtrans => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                  pr_vldtruss => (nvl(trim(substr(rw_arq.des_text,66,11)),0) / 100),
                                  pr_cdautori => nvl(trim(substr(rw_arq.des_text,77,6)),0), -- cdautori
                                  pr_dsdtrans => nvl(trim(substr(rw_arq.des_text,83,40)),' '),
                                  pr_cdcatest => nvl(trim(substr(rw_arq.des_text,123,5)),0) ,
                                  pr_cddmoeda => nvl(trim(substr(rw_arq.des_text,128,3)),' '),
                                  pr_vlmoeori => (nvl(trim(substr(rw_arq.des_text,131,11)),0) / 100),
                                  pr_cddreftr => nvl(trim(substr(rw_arq.des_text,142,23)),' '),
                                          pr_cdagenci => nvl(rw_crapass_dest.cdagenci,0), -- cdagenci
                                  pr_nridvisa => nvl(trim(substr(rw_arq.des_text,183,15)),0),
                                  pr_cdtrresp => nvl(trim(substr(rw_arq.des_text,214,2)),' '),
                                  pr_incoopon => nvl(trim(substr(rw_arq.des_text,216,1)),0),
                                  pr_txcnvuss => nvl(trim(substr(rw_arq.des_text,217,8)),0),
                                  pr_cdautban => nvl(trim(substr(rw_arq.des_text,225,6)),0),
                                  pr_idtrterm => nvl(trim(substr(rw_arq.des_text,231,16)),' '),
                                  pr_tpautori => nvl(trim(substr(rw_arq.des_text,247,1)),' '),
                                  pr_cdproces => nvl(trim(substr(rw_arq.des_text,248,6)),' '),
                                  pr_dstrorig => nvl(trim(substr(rw_arq.des_text,258,42)),' '),
                                  pr_nrnsuori => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                          pr_dtmvtolt => vr_dtmvtolt,
                                          pr_rowid_dcb=> NULL,
                                          pr_operacao => 'I',
                                          pr_dscritic => vr_dscritic);
                      ELSE
                        pc_insert_crapdcb(pr_tpmensag => vr_tpmensag,
                                  pr_nrnsucap => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                  pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                                  pr_hrdtrgmt => nvl(substr(rw_arq.des_text,208,6),0),
                                          pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                          pr_nrdconta => nvl(rw_crapass.nrdconta,0), -- nrdconta
                                  pr_nrseqarq => nvl(pr_nrseqarq,0),
                                  pr_nrinstit => nvl(trim(substr(rw_arq.des_text,1,3)),0),
                                  pr_cdprodut => nvl(trim(substr(rw_arq.des_text,4,3)),0),
                                  pr_nrcrcard => nvl(trim(substr(rw_arq.des_text,7,19)),' '),
                                  pr_tpdtrans => nvl(trim(substr(rw_arq.des_text,27,1)),' '),
                                  pr_cddtrans => nvl(trim(substr(rw_arq.des_text,28,3)),0),
                                          pr_cdhistor => vr_cdhistor_off,
                                  pr_dtdtrans => to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy'),
                                  pr_dtpostag => to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                                  pr_dtcnvvlr => to_date(trim(substr(rw_arq.des_text,47,8)),'ddmmyyyy'),
                                  pr_vldtrans => (nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100),
                                  pr_vldtruss => (nvl(trim(substr(rw_arq.des_text,66,11)),0) / 100),
                                  pr_cdautori => nvl(trim(substr(rw_arq.des_text,77,6)),0), -- cdautori
                                  pr_dsdtrans => nvl(trim(substr(rw_arq.des_text,83,40)),' '),
                                  pr_cdcatest => nvl(trim(substr(rw_arq.des_text,123,5)),0) ,
                                  pr_cddmoeda => nvl(trim(substr(rw_arq.des_text,128,3)),' '),
                                  pr_vlmoeori => (nvl(trim(substr(rw_arq.des_text,131,11)),0) / 100),
                                  pr_cddreftr => nvl(trim(substr(rw_arq.des_text,142,23)),' '),
                                          pr_cdagenci => nvl(rw_crapass.cdagenci,0), -- cdagenci
                                  pr_nridvisa => nvl(trim(substr(rw_arq.des_text,183,15)),0),
                                  pr_cdtrresp => nvl(trim(substr(rw_arq.des_text,214,2)),' '),
                                  pr_incoopon => nvl(trim(substr(rw_arq.des_text,216,1)),0),
                                  pr_txcnvuss => nvl(trim(substr(rw_arq.des_text,217,8)),0),
                                  pr_cdautban => nvl(trim(substr(rw_arq.des_text,225,6)),0),
                                  pr_idtrterm => nvl(trim(substr(rw_arq.des_text,231,16)),' '),
                                  pr_tpautori => nvl(trim(substr(rw_arq.des_text,247,1)),' '),
                                  pr_cdproces => nvl(trim(substr(rw_arq.des_text,248,6)),' '),
                                  pr_dstrorig => nvl(trim(substr(rw_arq.des_text,258,42)),' '),
                                  pr_nrnsuori => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                                          pr_dtmvtolt => vr_dtmvtolt,
                                          pr_rowid_dcb=> NULL,
                                          pr_operacao => 'I',
                                          pr_dscritic => vr_dscritic);
                      END IF;
      
                      IF vr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_saida;
                      END IF;
                 END IF; 
                -- caso encontre registro de débito, atualiza campos
                ELSE

                  -- se ja existe o registro deve atualizar a mensagem 200
                  pc_insert_crapdcb(pr_tpmensag => '0200',
                              pr_nrnsucap => nvl(trim(substr(rw_arq.des_text,198,6)),0),
                              pr_dtdtrgmt => to_date(trim(substr(rw_arq.des_text,204,4)),'mmdd'),
                              pr_hrdtrgmt => nvl(substr(rw_arq.des_text,208,6),0),
                                    pr_cdcooper => rw_crapcop_cdagebcb.cdcooper,
                                    pr_nrdconta => nvl(rw_crapass.nrdconta,0), -- nrdconta
                              pr_nrseqarq => nvl(pr_nrseqarq,0),
                              pr_nrinstit => nvl(trim(substr(rw_arq.des_text,1,3)),0),
                              pr_cdprodut => nvl(trim(substr(rw_arq.des_text,4,3)),0),
                              pr_nrcrcard => nvl(trim(substr(rw_arq.des_text,7,19)),' '),
                              pr_tpdtrans => nvl(trim(substr(rw_arq.des_text,27,1)),' '),
                                    pr_cddtrans => NULL,
                                    pr_cdhistor => rw_crapdcb_200.cdhistor,
                                    pr_dtdtrans => NULL,
                              pr_dtpostag => to_date(trim(substr(rw_arq.des_text,39,8)),'ddmmyyyy'),
                              pr_dtcnvvlr => to_date(trim(substr(rw_arq.des_text,47,8)),'ddmmyyyy'),
                                    pr_vldtrans => NULL,
                              pr_vldtruss => (nvl(trim(substr(rw_arq.des_text,66,11)),0) / 100),
                              pr_cdautori => nvl(trim(substr(rw_arq.des_text,77,6)),0),
                                    pr_dsdtrans => NULL,
                              pr_cdcatest => nvl(trim(substr(rw_arq.des_text,123,5)),0),
                                    pr_cddmoeda => NULL,
                              pr_vlmoeori => (nvl(trim(substr(rw_arq.des_text,131,11)),0) / 100),
                              pr_cddreftr => nvl(trim(substr(rw_arq.des_text,142,23)),' '),
                                    pr_cdagenci => nvl(rw_crapass.cdagenci,0), -- cdagenci
                              pr_nridvisa => nvl(trim(substr(rw_arq.des_text,183,15)),0),
                              pr_cdtrresp => nvl(trim(substr(rw_arq.des_text,214,2)),' '),
                              pr_incoopon => nvl(trim(substr(rw_arq.des_text,216,1)),0),
                              pr_txcnvuss => nvl(trim(substr(rw_arq.des_text,217,8)),0),
                              pr_cdautban => nvl(trim(substr(rw_arq.des_text,225,6)),0),
                                    pr_idtrterm => NULL,
                              pr_tpautori => nvl(trim(substr(rw_arq.des_text,247,1)),' '),
                              pr_cdproces => nvl(trim(substr(rw_arq.des_text,248,6)),' '),
                                    pr_dstrorig => NULL,
                                    pr_nrnsuori => NULL,
                                    pr_dtmvtolt => vr_dtmvtolt,
                                    pr_rowid_dcb=> rw_crapdcb_200.rowid,
                                    pr_operacao => 'A',
                                    pr_dscritic => vr_dscritic);

                  IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;
                END IF;

                -- fecha cursor de registro de débitos
                CLOSE cr_crapdcb_200;
                
                --verifica se efetua o lancamento offline ou é tarifa
                IF vr_crialcmt OR vr_flgdebcc = 0 THEN
                    vr_cdorigem := 7;
            vr_dtmovtoo := pr_dtmvtolt;
                    vr_cdhistor_ori := vr_cdhistor_off;
                    vr_dshistor_ori := vr_dshistor_off;
	              ELSE 
                  vr_cdorigem := 8;                 
                  vr_cdhistor_ori := vr_cdhistor_on;
                  vr_dshistor_ori := vr_dshistor_on;
                END IF;

                -- não buscar historico qaundo for de consulta
          IF  nvl(trim(substr(rw_arq.des_text,27,1)),' ') <> 'M' THEN

                  -- verificar se for efetivada/aprovada
            IF substr(rw_arq.des_text,214,2)  = '00' THEN
                    vr_flgrejei := 1; -- efetivada******/
                  ELSE
                    vr_flgrejei := 0; --reprovado
                  END IF;
                  
                -- se coop do registro esta inativa, temos que ver na coop destino
                IF rw_crapcop_cdagebcb.flgativo = 0 THEN
              -- gerar index                           
                    vr_index:= lpad(rw_crapass_dest.cdcooper,5,'0') || -- cdcooper(5)
                               lpad(rw_crapass_dest.cdagenci,5,'0')||--cdagenci(5)
                               rw_crapass_dest.inpessoa ||
                               lpad(vr_cdtrnbcb_ori,3,'0')||
                               lpad(vr_cdhistor_ori,5,'0')||
                               vr_cdorigem||
                               lpad(to_char(vr_dtmovtoo,'ddmmyyyy'),8,0)||
                         lpad(trim(substr(rw_arq.des_text,31,8)),8,0);                
                   --incluir informações na temptable para o relatorio
              pc_insere_relato(vr_index
                              ,rw_crapass_dest.cdcooper
                              ,rw_crapass_dest.nmrescop
                              ,rw_crapass_dest.cdagenci
                              ,rw_crapass_dest.nmresage
                              ,rw_crapass_dest.nrdconta               
                              ,vr_cdtrnbcb_ori
                              ,vr_dstrnbcb
                              ,vr_cdhistor_ori
                              ,vr_dshistor_ori
                              ,rw_crapass_dest.inpessoa
                              ,vr_cdorigem
                              ,to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                              ,vr_dtmovtoo 
                              ,vr_flgdebcc
                              ,(nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100)
                              ,vr_dscritic);
                ELSE                
                   --gerar index                           
                    vr_index:= lpad(rw_crapcop_cdagebcb.cdcooper,5,'0') || -- cdcooper(5)
                               lpad(rw_crapass.cdagenci,5,'0')||--cdagenci(5)
                               rw_crapass.inpessoa ||
                               lpad(vr_cdtrnbcb_ori,3,'0')||
                               lpad(vr_cdhistor_ori,5,'0')||
                               vr_cdorigem||
                               lpad(to_char(vr_dtmovtoo,'ddmmyyyy'),8,0)||
                         lpad(trim(substr(rw_arq.des_text,31,8)),8,0);
                    --Atribuir valores a temptable
              pc_insere_relato(vr_index
                              ,rw_crapcop_cdagebcb.cdcooper
                              ,rw_crapcop_cdagebcb.nmrescop
                              ,rw_crapass.cdagenci
                              ,rw_crapass.nmresage
                              ,rw_crapass.nrdconta               
                              ,vr_cdtrnbcb_ori
                              ,vr_dstrnbcb
                              ,vr_cdhistor_ori
                              ,vr_dshistor_ori
                              ,rw_crapass.inpessoa
                              ,vr_cdorigem
                              ,to_date(trim(substr(rw_arq.des_text,31,8)),'ddmmyyyy')
                              ,vr_dtmovtoo
                              ,vr_flgdebcc
                              ,(nvl(trim(substr(rw_arq.des_text,55,11)),0) / 100)
                              ,vr_dscritic);
                END IF;
                
            -- Se houve erro
            if vr_dscritic is not null then
              raise vr_exc_saida;
            end if;
                
            -- reseta as variaveis
                vr_cdorigem := 0;
                vr_dtmovtoo := NULL;
                
                END IF;
              EXCEPTION
                WHEN vr_exc_rejeitado THEN
                  
                  --verifica se efetua o lancamento offline ou é tarifa
                  IF vr_crialcmt OR vr_flgdebcc = 0 THEN                      
                      vr_cdhistor_ori := vr_cdhistor_off;
                      vr_dshistor_ori := vr_dshistor_off;
                  ELSE 
                    vr_cdhistor_ori := vr_cdhistor_on;
                    vr_dshistor_ori := vr_dshistor_on;
                  END IF;
                
            vr_dsmsglog := to_char(pr_dtmvtolt, 'dd/mm/yy') || ' as ' || to_char(sysdate,'hh24:mi:ss') || ' -> ' ||
                                    ' ERRO - ' ||
                                    ' cdcooper: '|| LPAD(rw_crapcop_cdagebcb.cdcooper,2,0) ||
                           ' nrdconta: '|| nvl(trim(gene0002.fn_mask_conta(vr_nrdconta)),substr(rw_arq.des_text,171,12)) ||
                           ' cdtrnbcb: '|| nvl(vr_cdtrnbcb_ori,TO_NUMBER(substr(rw_arq.des_text,28,3))) ||
                                    ' dstrnbcb: '|| vr_dstrnbcb ||
                                    ' cdhistor: '|| vr_cdhistor_ori ||
                                    ' dshistor: '|| vr_dshistor_ori ||
                                    ' dscritic: '||vr_dscritic || '.';
                           
              -- cria aqrqu
              IF vr_dsmsglog IS NOT NULL THEN

                 -- Incluir log de execução.
                 BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                           ,pr_ind_tipo_log => 1
                                           ,pr_des_log      => vr_dsmsglog
                                           ,pr_nmarqlog     => 'pc_crps670'
                                           ,pr_flnovlog     => 'N');
              END IF;
                 -- processar o proximo
                  vr_dscritic := null;

                WHEN no_data_found THEN -- não encontrar mais linhas
                  EXIT;
                WHEN OTHERS THEN

            pc_internal_exception(3, 'Linha do arquivo: ' || rw_arq.des_text);
                
                  IF vr_dscritic IS NULL THEN
              vr_dscritic := 'Erro arquivo ['|| rw_arq.nmarquiv ||']: '||SQLERRM;
                  END IF;
                  RAISE vr_exc_saida;
              END;

            END LOOP;

            -- Varrer registros da lcm para inserir
            BEGIN
              vr_idxlcm := vr_tab_craplcm.first;

              WHILE vr_idxlcm IS NOT NULL LOOP

                    BEGIN

                  INSERT INTO craplcm
                      (cdcooper,
                       dtmvtolt,
                       cdagenci,
                       cdbccxlt,
                       nrdolote,
                       nrdctabb,
                       nrdocmto,
                       dtrefere,
                       hrtransa,
                       vllanmto,
                       nrdconta,
                       cdhistor,
                       nrseqdig,
                       cdpesqbb,
                       cdorigem)
                  VALUES
                      (vr_tab_craplcm(vr_idxlcm).cdcooper,
                       vr_tab_craplcm(vr_idxlcm).dtmvtolt,
                       vr_tab_craplcm(vr_idxlcm).cdagenci,
                       vr_tab_craplcm(vr_idxlcm).cdbccxlt,
                       vr_tab_craplcm(vr_idxlcm).nrdolote,
                       vr_tab_craplcm(vr_idxlcm).nrdctabb,
                       vr_tab_craplcm(vr_idxlcm).nrdocmto,
                       vr_tab_craplcm(vr_idxlcm).dtrefere,
                       vr_tab_craplcm(vr_idxlcm).hrtransa,
                       vr_tab_craplcm(vr_idxlcm).vllanmto,
                       vr_tab_craplcm(vr_idxlcm).nrdconta,
                       vr_tab_craplcm(vr_idxlcm).cdhistor,
                       vr_tab_craplcm(vr_idxlcm).nrseqdig,
                       vr_tab_craplcm(vr_idxlcm).cdpesqbb,
                       vr_tab_craplcm(vr_idxlcm).cdorigem);

                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir craplcm: ' || vr_tab_craplcm(vr_idxlcm).nrdconta || SQLERRM;
                    RAISE vr_exc_saida;
                END;

                 vr_dsmsglog := to_char(vr_tab_craplcm(vr_idxlcm).dtmvtolt, 'dd/mm/yy') ||
                                ' LCMT - ' ||
                                ' cdcooper: '|| LPAD(vr_tab_craplcm(vr_idxlcm).cdcooper,2,0) ||
                                ' nrdconta: '|| LPAD(vr_tab_craplcm(vr_idxlcm).nrdconta,12,0) ||
                                ' cdpesqbb: '|| vr_tab_craplcm(vr_idxlcm).cdpesqbb ||
                                ' nrdocmto: '|| vr_tab_craplcm(vr_idxlcm).nrdocmto ||
                                ' nrnsucap: '|| substr(vr_tab_craplcm(vr_idxlcm).nrdocmto,4,6) ||
                                ' cdhistor: '|| vr_tab_craplcm(vr_idxlcm).cdhistor ||
                                ' vllanmto: '|| vr_tab_craplcm(vr_idxlcm).vllanmto || '.';

              -- cria aqrqu
              IF vr_dsmsglog IS NOT NULL THEN

                 -- Incluir log de execução.
                 BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                           ,pr_ind_tipo_log => 1
                                           ,pr_des_log      => vr_dsmsglog
                                           ,pr_nmarqlog     => 'pc_crps670'
                                           ,pr_flnovlog     => 'N');
              END IF;

          -- Inicializar vetor de lote caso nao exista para a coop
          vr_idx_lot := lpad(vr_tab_craplcm(vr_idxlcm).cdcooper,3,'0')||lpad(vr_tab_craplcm(vr_idxlcm).cdagenci,5,'0');
          if not vr_tab_craplot.exists(vr_idx_lot) then
            vr_tab_craplot(vr_idx_lot).nrseqdig := 0;
            vr_tab_craplot(vr_idx_lot).qtcompln := 0;
            vr_tab_craplot(vr_idx_lot).qtinfoln := 0;
            vr_tab_craplot(vr_idx_lot).vlcompdb := 0;
            vr_tab_craplot(vr_idx_lot).vlinfodb := 0;
          end if;

          -- Acumular
          vr_tab_craplot(vr_idx_lot).cdcooper := vr_tab_craplcm(vr_idxlcm).cdcooper;
          vr_tab_craplot(vr_idx_lot).cdagenci := vr_tab_craplcm(vr_idxlcm).cdagenci;
          vr_tab_craplot(vr_idx_lot).nrseqdig := greatest(vr_tab_craplot(vr_idx_lot).nrseqdig,vr_tab_craplcm(vr_idxlcm).nrseqdig);
          vr_tab_craplot(vr_idx_lot).qtcompln := vr_tab_craplot(vr_idx_lot).qtcompln + 1;
          vr_tab_craplot(vr_idx_lot).qtinfoln := vr_tab_craplot(vr_idx_lot).qtinfoln + 1;
          vr_tab_craplot(vr_idx_lot).vlcompdb := vr_tab_craplot(vr_idx_lot).vlcompdb + vr_tab_craplcm(vr_idxlcm).vllanmto;
          vr_tab_craplot(vr_idx_lot).vlinfodb := vr_tab_craplot(vr_idx_lot).vlinfodb + vr_tab_craplcm(vr_idxlcm).vllanmto;

          -- Buscar o proximo
                vr_idxlcm := vr_tab_craplcm.next(vr_idxlcm);
              END LOOP;
            END;

            -- Varrer registros da temptable da crapdcb para inserir
            BEGIN
              vr_idxdcb := vr_tab_crapdcb.first;

              WHILE vr_idxdcb IS NOT NULL LOOP
                IF vr_tab_crapdcb(vr_idxdcb).operacao = 'I' THEN
                  BEGIN
                    INSERT INTO crapdcb
                       (tpmensag
                       ,nrnsucap
                       ,dtdtrgmt
                       ,hrdtrgmt
                       ,cdcooper
                       ,nrdconta
                       ,nrseqarq
                       ,nrinstit
                       ,cdprodut
                       ,nrcrcard
                       ,tpdtrans
                       ,cddtrans
                       ,cdhistor
                       ,dtdtrans
                       ,dtpostag
                       ,dtcnvvlr
                       ,vldtrans
                       ,vldtruss
                       ,cdautori
                       ,dsdtrans
                       ,cdcatest
                       ,cddmoeda
                       ,vlmoeori
                       ,cddreftr
                       ,cdagenci
                       ,nridvisa
                       ,cdtrresp
                       ,incoopon
                       ,txcnvuss
                       ,cdautban
                       ,idtrterm
                       ,tpautori
                       ,cdproces
                       ,dstrorig
                       ,nrnsuori
                       ,dtmvtolt
                       )
                    VALUES
                      (vr_tab_crapdcb(vr_idxdcb).det.tpmensag
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrnsucap
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtdtrgmt
                      ,vr_tab_crapdcb(vr_idxdcb).det.hrdtrgmt
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdcooper
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrdconta
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrseqarq
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrinstit
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdprodut
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrcrcard
                      ,vr_tab_crapdcb(vr_idxdcb).det.tpdtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.cddtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdhistor
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtdtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtpostag
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr
                      ,vr_tab_crapdcb(vr_idxdcb).det.vldtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.vldtruss
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdautori
                      ,vr_tab_crapdcb(vr_idxdcb).det.dsdtrans
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdcatest
                      ,vr_tab_crapdcb(vr_idxdcb).det.cddmoeda
                      ,vr_tab_crapdcb(vr_idxdcb).det.vlmoeori
                      ,vr_tab_crapdcb(vr_idxdcb).det.cddreftr
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdagenci
                      ,vr_tab_crapdcb(vr_idxdcb).det.nridvisa
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdtrresp
                      ,vr_tab_crapdcb(vr_idxdcb).det.incoopon
                      ,vr_tab_crapdcb(vr_idxdcb).det.txcnvuss
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdautban
                      ,vr_tab_crapdcb(vr_idxdcb).det.idtrterm
                      ,vr_tab_crapdcb(vr_idxdcb).det.tpautori
                      ,vr_tab_crapdcb(vr_idxdcb).det.cdproces
                      ,vr_tab_crapdcb(vr_idxdcb).det.dstrorig
                      ,vr_tab_crapdcb(vr_idxdcb).det.nrnsuori
                      ,vr_tab_crapdcb(vr_idxdcb).det.dtmvtolt
                     );
                  EXCEPTION
                    WHEN dup_val_on_index THEN
                       -- tentar inserir novamente porém com hrgmt + 1 segundo
                       BEGIN
                        rw_crapdcb_hr.hrdtrgmt := 1;
                        
                        OPEN cr_crapdcb_hr(vr_tab_crapdcb(vr_idxdcb).det.cdcooper,
                                           vr_tab_crapdcb(vr_idxdcb).det.nrdconta,
                                           vr_tab_crapdcb(vr_idxdcb).det.nrnsucap,
                                           vr_tab_crapdcb(vr_idxdcb).det.dtdtrgmt,
                                           vr_tab_crapdcb(vr_idxdcb).det.tpmensag);
                         FETCH cr_crapdcb_hr INTO rw_crapdcb_hr;
                        CLOSE cr_crapdcb_hr;                                                 
                                                 
                        INSERT INTO crapdcb
                           (tpmensag
                           ,nrnsucap
                           ,dtdtrgmt
                           ,hrdtrgmt
                           ,cdcooper
                           ,nrdconta
                           ,nrseqarq
                           ,nrinstit
                           ,cdprodut
                           ,nrcrcard
                           ,tpdtrans
                           ,cddtrans
                           ,cdhistor
                           ,dtdtrans
                           ,dtpostag
                           ,dtcnvvlr
                           ,vldtrans
                           ,vldtruss
                           ,cdautori
                           ,dsdtrans
                           ,cdcatest
                           ,cddmoeda
                           ,vlmoeori
                           ,cddreftr
                           ,cdagenci
                           ,nridvisa
                           ,cdtrresp
                           ,incoopon
                           ,txcnvuss
                           ,cdautban
                           ,idtrterm
                           ,tpautori
                           ,cdproces
                           ,dstrorig
                           ,nrnsuori
                           ,dtmvtolt
                           )
                        VALUES
                          (vr_tab_crapdcb(vr_idxdcb).det.tpmensag
                          ,vr_tab_crapdcb(vr_idxdcb).det.nrnsucap
                          ,vr_tab_crapdcb(vr_idxdcb).det.dtdtrgmt
                          ,rw_crapdcb_hr.hrdtrgmt
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdcooper
                          ,vr_tab_crapdcb(vr_idxdcb).det.nrdconta
                          ,vr_tab_crapdcb(vr_idxdcb).det.nrseqarq
                          ,vr_tab_crapdcb(vr_idxdcb).det.nrinstit
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdprodut
                          ,vr_tab_crapdcb(vr_idxdcb).det.nrcrcard
                          ,vr_tab_crapdcb(vr_idxdcb).det.tpdtrans
                          ,vr_tab_crapdcb(vr_idxdcb).det.cddtrans
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdhistor
                          ,vr_tab_crapdcb(vr_idxdcb).det.dtdtrans
                          ,vr_tab_crapdcb(vr_idxdcb).det.dtpostag
                          ,vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr
                          ,vr_tab_crapdcb(vr_idxdcb).det.vldtrans
                          ,vr_tab_crapdcb(vr_idxdcb).det.vldtruss
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdautori
                          ,vr_tab_crapdcb(vr_idxdcb).det.dsdtrans
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdcatest
                          ,vr_tab_crapdcb(vr_idxdcb).det.cddmoeda
                          ,vr_tab_crapdcb(vr_idxdcb).det.vlmoeori
                          ,vr_tab_crapdcb(vr_idxdcb).det.cddreftr
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdagenci
                          ,vr_tab_crapdcb(vr_idxdcb).det.nridvisa
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdtrresp
                          ,vr_tab_crapdcb(vr_idxdcb).det.incoopon
                          ,vr_tab_crapdcb(vr_idxdcb).det.txcnvuss
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdautban
                          ,vr_tab_crapdcb(vr_idxdcb).det.idtrterm
                          ,vr_tab_crapdcb(vr_idxdcb).det.tpautori
                          ,vr_tab_crapdcb(vr_idxdcb).det.cdproces
                          ,vr_tab_crapdcb(vr_idxdcb).det.dstrorig
                          ,vr_tab_crapdcb(vr_idxdcb).det.nrnsuori
                          ,vr_tab_crapdcb(vr_idxdcb).det.dtmvtolt
                         );
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapdcb dup_val: '||SQLERRM 
                          || 'nsu: '|| vr_tab_crapdcb(vr_idxdcb).det.nrnsucap
                          || 'aut: '|| vr_tab_crapdcb(vr_idxdcb).det.cdautori
                          || 'cop: '|| vr_tab_crapdcb(vr_idxdcb).det.cdcooper
                          || 'con: '|| vr_tab_crapdcb(vr_idxdcb).det.nrdconta;
                          RAISE vr_exc_saida;
                      END;  -- fim dup_val
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir crapdcb: '||SQLERRM 
                      || 'nsu: '|| vr_tab_crapdcb(vr_idxdcb).det.nrnsucap
                      || 'aut: '|| vr_tab_crapdcb(vr_idxdcb).det.cdautori
                      || 'cop: '|| vr_tab_crapdcb(vr_idxdcb).det.cdcooper
                      || 'con: '|| vr_tab_crapdcb(vr_idxdcb).det.nrdconta;
                      RAISE vr_exc_saida;
                  END;
                ELSE
                  BEGIN
                    UPDATE crapdcb
                       SET nrseqarq = vr_tab_crapdcb(vr_idxdcb).det.nrseqarq,
                           nrinstit = vr_tab_crapdcb(vr_idxdcb).det.nrinstit,
                           cdprodut = vr_tab_crapdcb(vr_idxdcb).det.cdprodut,
                           nrcrcard = vr_tab_crapdcb(vr_idxdcb).det.nrcrcard,
                           tpdtrans = vr_tab_crapdcb(vr_idxdcb).det.tpdtrans,
                           cdhistor = vr_tab_crapdcb(vr_idxdcb).det.cdhistor,
                           dtpostag = vr_tab_crapdcb(vr_idxdcb).det.dtpostag,
                           dtcnvvlr = vr_tab_crapdcb(vr_idxdcb).det.dtcnvvlr,
                           vldtruss = vr_tab_crapdcb(vr_idxdcb).det.vldtruss,
                           cdautori = vr_tab_crapdcb(vr_idxdcb).det.cdautori,
                           cdcatest = vr_tab_crapdcb(vr_idxdcb).det.cdcatest,
                           vlmoeori = vr_tab_crapdcb(vr_idxdcb).det.vlmoeori,
                           cddreftr = vr_tab_crapdcb(vr_idxdcb).det.cddreftr,
                           cdagenci = vr_tab_crapdcb(vr_idxdcb).det.cdagenci,
                           nridvisa = vr_tab_crapdcb(vr_idxdcb).det.nridvisa,
                           cdtrresp = vr_tab_crapdcb(vr_idxdcb).det.cdtrresp,
                           incoopon = vr_tab_crapdcb(vr_idxdcb).det.incoopon,
                           txcnvuss = vr_tab_crapdcb(vr_idxdcb).det.txcnvuss,
                           cdautban = vr_tab_crapdcb(vr_idxdcb).det.cdautban,
                           tpautori = vr_tab_crapdcb(vr_idxdcb).det.tpautori,
                           cdproces = vr_tab_crapdcb(vr_idxdcb).det.cdproces
                     WHERE ROWID = vr_tab_crapdcb(vr_idxdcb).rowid_dcb;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar crapdcb: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END if;
                
                vr_idxdcb := vr_tab_crapdcb.next(vr_idxdcb);
              END LOOP;
            END;

      -- Alimentar tabela temporia com dados de LOTE
      vr_idx_lot := vr_tab_craplot.first;
      loop
        exit when vr_idx_lot is null;
        -- Gerar dados
            BEGIN
          insert into tbgen_batch_relatorio_wrk(cdcooper
                                               ,cdprograma
                                               ,dsrelatorio
                                               ,dtmvtolt
                                               ,dschave
                                               ,cdagenci
                                               ,dscritic)
                                         values(pr_cdcooper
                                               ,vr_cdprogra
                                               ,'CRAPLOT_CET'
                                               ,pr_dtmvtolt
                                               ,vr_tab_craplot(vr_idx_lot).cdcooper
                                               ,vr_tab_craplot(vr_idx_lot).cdagenci
                                               ,';'||vr_tab_craplot(vr_idx_lot).nrseqdig||';'||     
                                                     vr_tab_craplot(vr_idx_lot).qtcompln||';'||
                                                     vr_tab_craplot(vr_idx_lot).qtinfoln||';'||
                                                     vr_tab_craplot(vr_idx_lot).vlcompdb||';'||
                                                     vr_tab_craplot(vr_idx_lot).vlinfodb||';');

            EXCEPTION
              WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir tbgen_batch_relatorio_wrk LOT: '||sqlerrm;  
            raise vr_exc_saida; 
            END;
        vr_idx_lot := vr_tab_craplot.next(vr_idx_lot);
      end loop;

      -- Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F'  
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe           
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par
                     ,pr_flgsucesso => 1); 

      -- Caso execucao paralela
      IF pr_idparale <> 0 THEN
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                           ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                           ,pr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_nrseqexe
                                    ,pr_des_erro => vr_dscritic);  
        -- Salvar informacoes no banco de dados
           COMMIT;
        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- loga a mensagem de critica
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;        

        -- Na execução paralela
        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_nrseqexe,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  

          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => pr_nrseqexe
                                      ,pr_des_erro => vr_dscritic);
        end if;   

        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS670: ' || SQLERRM;
        pc_internal_exception(3, pr_dscritic);

        -- Na execução paralela
        if nvl(pr_idparale,0) <> 0 then 
          -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
          pc_log_programa(PR_DSTIPLOG           => 'E',
                          PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_nrseqexe,
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 2,
                          pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                   'pr_dscritic:'||pr_dscritic,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
          --Grava data fim para o JOB na tabela de LOG 
          pc_log_programa(pr_dstiplog   => 'F',    
                          pr_cdprograma => vr_cdprogra||'_'||pr_nrseqexe,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_par,
                          pr_flgsucesso => 0);  

          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => pr_nrseqexe
                                      ,pr_des_erro => vr_dscritic);
        end if; 

        ROLLBACK;
    END;

  END pc_proces_arq_cet_bancoob;

  /* Rotina com a os procedimentos para o CRPS670 */
  PROCEDURE pc_recebe_arq_cet_bancoob(pr_cdcooper IN NUMBER                --> Cooperativa Central
                                     ,pr_nmdatela IN VARCHAR2              --> Rotina acionadora
                                     ,pr_qtdejobs IN INTEGER DEFAULT 0     --> Quantidade de Jobs para execução paralela
                                     ,pr_qtregjob IN INTEGER DEFAULT 0     --> Quantidade de Registros por Jobs de execução paralela
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
  BEGIN
    /* .............................................................................

    Programa: pc_recebe_arq_cet_bancoob
    Sistema : Cartoes de Credito - Cooperativa de Credito
    Sigla   : CRRD
    Autor   : Lucas Lunelli
    Data    : Maio/14.                    Ultima atualizacao: 23/08/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado.
                ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB e CRON.

    Objetivo  : Conciliar débitos dos Cartões de Crédito BANCOOB/CABAL.

    Observacao: -----

    Alteracoes: 12/08/2014 - Criação do relatorio crrl685 para apresentar a
                             consiliação dos debitos. (Odirlei-Amcom)

                22/08/2014 - Alteração da busca do diretorio do bancoob(Odirlei/AMcom)

                26/08/2014 - Alteração no criterio para criar a craplcm(Odirlei/AMcom)

                27/08/2014 - Realizar commit a cada processamento de arquivo(Odirlei/Amcom)

                28/08/2014 - Ajuste na composição do numero do documento da craplcm e
                            e não gerar lançamento para os registros de movimento de consulta
                            (Odirlei/Amcom)

                05/09/2014 - Devido mudança no envio das transações de débito, onde o NSU
                             (número sequencial único) pode se repetir, será necessário efetuar
                             a gravação do número do documento (craplcm.nrdocmto) com uma
                             composição de valores (Tipo de mensagem, NSU da rede, Data e hora
                             da transação), evitando desta forma registros com chave duplicada.
                             (Renato - Supero - SD 197146)

                25/09/2014 - Alterações na pc_crps670 para o lancamento (Vanessa)

                20/11/2014 - Tratamento do arquivo CEXT tratando a mensagem 0420 (Vanessa)

                16/12/2014 - Incluido tratamento para gravar os registros para insert da craplcm
                             e crapbdc em temptable e executar apenas no final do arquivo, para que as
                             tabelas não fiquem muito tempo lockadas.(Odirlei/AMcom)

                17/12/2014 - Ajustes para melhorar a performance da cr_crapdcb e cr_craplcm (Vanessa)

                19/12/2014 - Criação de um arquivo de log das inserções na craplcm (Vanessa)

                06/01/2015 - Alteração do cursor craplcm e craplcm_dia para procurar tambem pelo valor
                             e pelo histórico da crapdcb (Vanessa) SD240363

                09/01/2015 - Alteração para atualizar os campos pr_vlmoeori e pr_vldtruss dividido por 100
                             na atualização da DCB (Vanessa)

                19/01/2015 - Correção no lançamento quando a a mensagem for 420, não tiver o lançamento e
                             tiver critica (Vanessa)
                             
                30/04/2015 - Correção para fazer a inserção da mensagem 0200 na crapdcb quando vier um 
                             credito no arquivo CEXT, inserindo a mesma com codico 0400, fazer a busca 
                             no cursor cr_crapdcb_200 com o historico passado no arquivo, assim como 
                             efetuar o credito da lcm (Vanessa e Ranghetti #278251) 
                             
                15/05/2015 - Melhoria de performace cursor cr_crapdcb SD285341 (Odirlei-AMcom)            
                
                26/05/2015 - Ajustes critica lcm (odirlei-Amcom)
                
                26/05/2015 - Alteração do Relatorio gerado e insercao da origem 7 na lcm (Vanessa)
                
                10/06/2015 - Ajuste para gravar arquivo de controle para o BI. (James)
                
                17/07/2015 - #307701 Alterado o cursor cr_crapdcb para verificar os débitos de mensagem 0200 ainda não 
                             processados (Carlos)
                             
                03/09/2015 - Incluido tratamento para tarifacao de saques e consultas, Prj. Tarifas - 218
                             (Jean Michel) 
               
                30/09/2015 - Ajuste para verificar se já existem mensagens 0400 na crapdcb , caso exista não 
                             inserir a mesma, foi identificado que estão ocorrendo creditos online, o que não ocorria (Vanessa)

                11/11/2015 - Ajustada para manter o cdhistor vindo no arquivo na operação de alteração da crapcdb, 
                             e ajustado para se vir novamente um registro de conciliação em outro arquivo, consiga processar
                             a conciliação e gerar o debito corretamente SD356767 (Odirlei-AMcom) 
                             
                16/02/2016 - Ajustes referentes ao projeto melhoria 157(Lucas Ranghetti #330322)
                             
                22/06/2016 - Ajustes em relação a situacao de ja existir o lancamento de debito/credito
                             na conta do cooperado e verificarmos a necessidade de refaze-las com base
                             nas mensagens ja existentes na dcb, comparado com a linha do CEXT que
                             esta sendo processado. (Chamados 452889/454367) - (Fabricio)
                             
                04/08/2016 - Nao gerar mais arquivo para inicio do BI. Ao inves disso, sera inserido / alterado
                             registro na CRAPPRM. (495821 - Andrino - RKAM)
                             
                07/12/2016 - Tratamento Incorporacao Transposul. (Fabricio)
                
                16/12/2016 - Ajustes para incorporacao/migracao. (Fabricio)
                             
                03/02/2017 - #601772 Inclusão de verificação e log de erros de execução através do 
                             procedimento pc_internal_exception no procedimento pc_crps670 (Carlos)

                09/03/2017 - Ao verificar se ja existe a 0200 na dcb, olhar tambem com o historico
                             offline da transacao, caso nao encontre com o historico online.
                             (problemas com chave duplicada no indice #1). (Fabricio)
                             
                18/05/2017 - Ajuste na busca do sequencial do arquivo CEXT em virtude da
                             informacao de data acrescentada ao nome do arquivo pelo Bancoob.
                             (Fabricio)
                             
                13/06/2017 - Tratar para abrir chamado quando ocorrer algum erro no 
                             processamento da conciliacao do cartao Bancoob/Cabal (Lucas Ranghetti #680746)
                
                04/07/2017 - Melhoria na busca dos arquivos que irão ser processador, conforme
                             solicitado no chamado 703589. (Kelvin)
                             
                02/08/2017 - Incluir validacao para o trailer do arquivo CEXT, caso o arquivo venha 
                             incompleto vamos abrir chamado e rejeitar o arquivo. (Lucas Ranghetti #727623)
                             
                02/02/2018 - Ajuste para quando recebemos uma transacao de credito aprovada onde nao
                             houve estorno na conta do cooperado de forma online precisamos lancar
                             o credito em conta. (Chamado 836129) - (Fabricio)
                             
                23/08/2018 - Projeto Revitalização Sistemas - Renomeação para melhor entendimento
                             da função da rotina + paralelização por Porções do Arquivo - Andreatta (MOUTs)               
                             
    ....................................................................................................*/
    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   VARCHAR2(19) := 'CRPS670';
      vr_dsdireto   VARCHAR2(2000);                                    --> Caminho para receber
      vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_nmrquivo   VARCHAR2(2000);                                    --> Nome do arquivo
      vr_des_text   VARCHAR2(2000);                                    --> Conteúdo da Linha do Arquivo
      vr_nrseqarq   INTEGER;                                           --> Sequencial do Arquivo
      vr_maior_seq  INTEGER;                                           --> Maior Sequencial do Arquivo
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX para Mover arquivo lido
      
      vr_ind_arquiv utl_file.file_type;                                --> declarando handle do arquivo
      
      vr_flgrejei   NUMBER;
      vr_flrestar   boolean;
      
      vr_cdbccxlt   constant INTEGER := 100;
      vr_nrdolote   constant INTEGER := 6902;
      
      vr_qtdejobs   integer;
      vr_qtregjob   INTEGER;
      vr_nrexepar   INTEGER := 1;
      vr_nrdlinha   INTEGER := 0;
      vr_nmarqimp   VARCHAR2(100);
      vr_listarq    VARCHAR2(2000);                                    
      vr_saida_so   VARCHAR2(1000);
      
      vr_dsdircop crapcop.dsdircop%TYPE;      
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_exc_rejeitado EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dsretorn   VARCHAR2(6000);
      vr_typ_saida  VARCHAR2(4000);

      /* Variaveis Prj421 */
      -- Data do movimento no formato yymmdd
      vr_dtmvtolt_yymmdd     varchar2(6);
      
      -- Nome do diretório
      vr_nom_diretorio       varchar2(200);
      vr_dsdircop_contab     varchar2(200);

      -- Nome do arquivo que será gerado
      vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
      vr_nmarqdat            varchar2(50);

      -- Arquivo texto
      vr_arquivo_txt         utl_file.file_type;
      vr_linhadet            varchar2(200);

      -- Tratamento de erros
      vr_typ_said            VARCHAR2(4);

      --index da temp-table do relatorio
      vr_idxcop     VARCHAR2(46);  
      
      -- data base para transacoes no periodo da migracao
      vr_dtcxtmig VARCHAR2(100);

      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      -- Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_texto_completo  VARCHAR2(32600);
      -- diretorio de geracao do relatorio
      vr_nom_direto  VARCHAR2(100);
      -- variavel para controlar se retorna o erro
      vr_flgerro     BOOLEAN := FALSE;
      
      
    
      -- ID para o paralelismo
      vr_idparale      INTEGER;
      -- Job name dos processos criados
      vr_jobname       varchar2(30);
      -- Bloco PLSQL para chamar a execução paralela do pc_crps750
      vr_dsplsql       varchar2(4000);
      
      -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle 
      vr_idlog_ini_ger tbgen_prglog.idprglog%type;
      vr_qterro        number := 0; 

      
      ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
      
      -- Vetor para armazenar os arquivos para processamento
      vr_vet_nmarquiv gene0002.typ_split := gene0002.typ_split();
        

      ------------------------------- CURSORES ---------------------------------
      
      -- busca registro de HEADER conciliacao de debito
      CURSOR cr_crapccb IS
        SELECT ccb.rowid
          FROM crapccb ccb;
      rw_crapccb cr_crapccb%ROWTYPE;
      
      -- Cursor para buscar dados de execução anterior  
      cursor cr_work_arq(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
        select a.dschave  nmarquiv
              ,a.cdagenci nrseqarq
              ,a.nrdconta qtregjob
              ,a.nrctremp nrexepar
          from tbgen_batch_relatorio_wrk a
         where a.cdcooper    = pr_cdcooper
           and a.cdprograma  = pr_cdprograma
           and a.dsrelatorio = pr_dsrelatorio
           and a.dtmvtolt    = pr_dtmvtolt;
      rw_work_arq cr_work_arq%rowtype;
      
      -- cursor para verificar a existência de lote
      CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                         pr_cdagenci IN crapass.cdagenci%TYPE) IS
        SELECT lot.nrseqdig
              ,lot.qtcompln
              ,lot.qtinfoln
              ,lot.vlcompdb
              ,lot.ROWID
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper             
           AND lot.dtmvtolt = pr_dtmvtolt             
           AND lot.cdagenci = pr_cdagenci             
           AND lot.cdbccxlt = 100                     
           AND lot.nrdolote = 6902;
      rw_craplot cr_craplot%ROWTYPE;

      -- Informações arquivo bancoob
      CURSOR cr_crapscb IS
        SELECT crapscb.Dsdirarq,
               crapscb.nrseqarq
          FROM crapscb
         WHERE crapscb.tparquiv = 2; -- Arquivo CEXT
      rw_crapscb cr_crapscb%ROWTYPE;
      
      -- Cursor para buscar valores e atualizar a capa do lote na tabela l            
      cursor cr_work_lot(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
        select a.dschave cdcooper,
               a.cdagenci cdagenci,
               max(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) nrseqdig,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) qtcompln,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) qtinfoln,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vlcompdb,
               sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))) vlinfodb
          from tbgen_batch_relatorio_wrk a
         where a.cdcooper    = pr_cdcooper
           and a.cdprograma  = pr_cdprograma
           and a.dsrelatorio = pr_dsrelatorio
           and a.dtmvtolt    = pr_dtmvtolt
         group by a.dschave  
                 ,a.cdagenci;
      
      -- Buscar informação de execução anterior
      cursor cr_exec_ant(pr_cdcooper    tbgen_batch_controle.cdcooper%type  
                        ,pr_cdprograma  tbgen_batch_controle.cdprogra%type 
                        ,pr_cdagrupador tbgen_batch_controle.cdagrupador%type
                        ,pr_dtmvtolt    tbgen_batch_controle.dtmvtolt%type) is
        select insituacao
          from tbgen_batch_controle
         where tbgen_batch_controle.cdcooper    = pr_cdcooper
           and tbgen_batch_controle.cdprogra    = vr_cdprogra
           and tbgen_batch_controle.tpagrupador = 1
           and tbgen_batch_controle.cdagrupador = pr_cdagrupador
           and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt;
      rw_exec_ant cr_exec_ant%rowtype;
              
      CURSOR cr_bancoob_tarifa IS
        SELECT b.cdcooper
             , e.nrctabcb
             , b.cdagenci
             , b.cdhistor
             , c.dscontabil
             , d.inpessoa
             , DECODE(d.inpessoa,1,c.nrctadeb_pf,c.nrctadeb_pj) nrctadeb
             , DECODE(d.inpessoa,1,c.nrctacrd_pf,c.nrctacrd_pj) nrctacrd
             , sum(b.vldtrans) vldtrans
             , Row_Number() OVER (PARTITION BY b.cdcooper, b.cdhistor, d.inpessoa ORDER BY b.cdcooper, b.cdhistor, d.inpessoa) nrseqreghis
             , Count(1) OVER (PARTITION BY b.cdcooper) qtdreg
             , Row_Number() OVER (PARTITION BY b.cdcooper ORDER BY b.cdcooper) nrseqreg
             , SUM(SUM(b.vldtrans)) OVER (PARTITION BY b.cdcooper, b.cdhistor, d.inpessoa) AS vltotal
          FROM crapcop e
             , crapass d
             , tbcontab_prm_his_tarifa c
             , (select x.dschave
                     , x.nrdconta cdcooper
                     , x.cdagenci
                     , gene0002.fn_busca_entrada(01,dscritic,';') nmrescop
                     , gene0002.fn_busca_entrada(02,dscritic,';') nmresage
                     , gene0002.fn_busca_entrada(03,dscritic,';') nrdconta
                     , to_number(gene0002.fn_busca_entrada(04,dscritic,';')) cdtrnbcb
                     , gene0002.fn_busca_entrada(05,dscritic,';') dstrnbcb
                     , to_number(gene0002.fn_busca_entrada(06,dscritic,';')) cdhistor
                     , gene0002.fn_busca_entrada(07,dscritic,';') dshistor
                     , to_number(gene0002.fn_busca_entrada(08,dscritic,';')) inpessoa
                     , to_number(gene0002.fn_busca_entrada(09,dscritic,';')) cdorigem
                     , to_date(gene0002.fn_busca_entrada(10,dscritic,';'),'fmddmmrrrr') dtdtrans
                     , to_date(gene0002.fn_busca_entrada(11,dscritic,';'),'fmddmmrrrr') dtmvtolt
                     , to_number(gene0002.fn_busca_entrada(12,dscritic,';')) flgdebcc
                     , to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g990d00') vldtrans
                  from tbgen_batch_relatorio_wrk x
                     , crapdat y
                 where x.cdcooper    = pr_cdcooper
                   and x.cdprograma  = 'CRPS670'
                   and x.dsrelatorio = 'DADOS_RELAT'
                   and x.dtmvtolt    = y.dtmvtolt
                   AND y.cdcooper    = pr_cdcooper) b
         WHERE e.cdcooper = b.cdcooper
           AND d.cdcooper = b.cdcooper
           AND d.nrdconta = b.nrdconta
           AND c.cdhistor = b.cdhistor
         GROUP
            BY b.cdcooper
             , e.nrctabcb
             , b.cdhistor
             , c.dscontabil
             , b.cdagenci
             , d.inpessoa
             , DECODE(d.inpessoa,1,c.nrctadeb_pf,c.nrctadeb_pj)
             , DECODE(d.inpessoa,1,c.nrctacrd_pf,c.nrctacrd_pj)
         ORDER
            BY b.cdcooper
             , b.cdhistor
             , d.inpessoa
             , b.cdagenci;

      -- Subrotina para escrever críticas no LOG do processo
      PROCEDURE pc_log_batch(pr_flgerro BOOLEAN) IS
      BEGIN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
          -- Armazenar as criticas que foram geradas no log para retornar a tela ARQBCB
          vr_dsretorn := vr_dsretorn || vr_dscritic||'<br/>';
          -- Controlar se algum dos logs é um erro
          IF pr_flgerro THEN
            vr_flgerro := pr_flgerro;
          END IF;
          vr_cdcritic := 0;
          vr_dscritic := '';
        END IF;
      END pc_log_batch;


      -- Rotina para gerar relatorio crrl685
      PROCEDURE pc_relatorio_crrl685(pr_dscritic OUT VARCHAR2) IS

        -- variaveis de controle
        vr_cdcooper  crapage.cdcooper%type;
        vr_cdagenci  crapage.cdcooper%type;
        vr_flgrejei  NUMBER;
        vr_vltotonn  craplcm.vllanmto%TYPE;
        vr_vltotoff  craplcm.vllanmto%TYPE; 
        vr_dsorigem  VARCHAR2(20); 
        vr_dspessoa  VARCHAR2(2)  ; 
        
        -- Cursor para buscar valores para relatorio      
        cursor cr_work_rel(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                          ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                          ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                          ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
          select a.dschave               
                ,a.nrdconta cdcooper
                ,a.cdagenci
                ,gene0002.fn_busca_entrada(01,dscritic,';') nmrescop
                ,gene0002.fn_busca_entrada(02,dscritic,';') nmresage
                ,gene0002.fn_busca_entrada(03,dscritic,';') nrdconta
                ,to_number(gene0002.fn_busca_entrada(04,dscritic,';')) cdtrnbcb
                ,gene0002.fn_busca_entrada(05,dscritic,';') dstrnbcb
                ,to_number(gene0002.fn_busca_entrada(06,dscritic,';')) cdhistor
                ,gene0002.fn_busca_entrada(07,dscritic,';') dshistor
                ,to_number(gene0002.fn_busca_entrada(08,dscritic,';')) inpessoa
                ,to_number(gene0002.fn_busca_entrada(09,dscritic,';')) cdorigem
                ,to_date(gene0002.fn_busca_entrada(10,dscritic,';'),'fmddmmrrrr') dtdtrans
                ,to_date(gene0002.fn_busca_entrada(11,dscritic,';'),'fmddmmrrrr') dtmvtolt
                ,to_number(gene0002.fn_busca_entrada(12,dscritic,';')) flgdebcc
                ,to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g990d00') vldtrans
            from tbgen_batch_relatorio_wrk a
           where a.cdcooper    = pr_cdcooper
             and a.cdprograma  = pr_cdprograma
             and a.dsrelatorio = pr_dsrelatorio
             and a.dtmvtolt    = pr_dtmvtolt
           order by a.dschave;

        --temptable para armazenar informações para o relatorio
        TYPE typ_tab_reg_relat IS RECORD
            (cdcooper crapcop.cdcooper%TYPE,
             nmrescop crapcop.nmrescop%TYPE,
             cdagenci crapage.cdagenci%TYPE,
             nmresage crapage.nmresage%TYPE,
             nrdconta VARCHAR2(20),
             cdtrnbcb craphcb.cdtrnbcb%type,
             dstrnbcb craphcb.dstrnbcb%type,
             cdhistor craphis.cdhistor%type,
             dshistor VARCHAR2(100),
             inpessoa crapass.inpessoa%TYPE,
             cdorigem craplcm.cdorigem%TYPE,
             dtdtrans crapdcb.dtdtrans%TYPE,
             dtmvtolt crapdcb.dtmvtolt%TYPE,
             flgdebcc craphcb.flgdebcc%TYPE,
             qtdtrans NUMBER,
             vldtrans NUMBER);

        TYPE typ_tab_relat IS
          TABLE OF typ_tab_reg_relat
            INDEX BY varchar2(38);  --cdcooper(5) + cdagenci(5) + nrdconta(10) + cdhistor(5) +  nsuredec(6) + vr_nrdocmto(6) + vr_vldtrans(10) + dtmvtolt(8)
       
        -- resumo cooperativa
        vr_tab_relat_rescop typ_tab_relat;
        
        -- Procedimento para incluir o resumo da cooperativa no xml
        PROCEDURE pc_resumo_coop IS
        BEGIN
          vr_vltotoff := 0; 
          vr_vltotonn := 0;          
          --gerar resumo por cooperativa
          vr_idxcop := vr_tab_relat_rescop.first;
          gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'<rescop>');

          WHILE vr_idxcop is not null LOOP
            IF vr_tab_relat_rescop(vr_idxcop).cdorigem = 7 THEN
               vr_dsorigem := 'Offline';
               vr_vltotoff := vr_vltotoff + vr_tab_relat_rescop(vr_idxcop).vldtrans;
            ELSIF vr_tab_relat_rescop(vr_idxcop).cdorigem = 8 THEN
               vr_dsorigem := 'Online';
               vr_vltotonn := vr_vltotonn + vr_tab_relat_rescop(vr_idxcop).vldtrans;
            ELSE
               vr_dsorigem := 'Critica';
            END IF;      
            
            IF vr_tab_relat_rescop(vr_idxcop).inpessoa = 1 THEN 
                vr_dspessoa := 'PF';               
            ELSE 
                vr_dspessoa := 'PJ';
            END IF;
            -- incluir tags de dados
            gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,
                        '<detalhes>
                          <cdtrnbcb>'|| lpad(vr_tab_relat_rescop(vr_idxcop).cdtrnbcb,3,'0') || '</cdtrnbcb>
                          <dstrnbcb>'|| lpad(vr_tab_relat_rescop(vr_idxcop).cdtrnbcb,3,'0')||' - '||
                                        vr_tab_relat_rescop(vr_idxcop).dstrnbcb || '</dstrnbcb>
                          <dshistor>'|| vr_tab_relat_rescop(vr_idxcop).dshistor || '</dshistor>
                          <inpessoa>'|| vr_tab_relat_rescop(vr_idxcop).inpessoa ||'</inpessoa>
                          <dspessoa>'|| vr_dspessoa ||'</dspessoa>
                          <cdorigem>'|| vr_tab_relat_rescop(vr_idxcop).cdorigem  ||'</cdorigem>
                          <dsorigem>'|| vr_dsorigem ||'</dsorigem>
                          <flgdebcc>'|| vr_tab_relat_rescop(vr_idxcop).flgdebcc ||'</flgdebcc>                          
                          <dtdtrans>'|| to_char(vr_tab_relat_rescop(vr_idxcop).dtdtrans,'dd/mm/yyyy') ||'</dtdtrans>
                          <dtmvtolt>'|| to_char(vr_tab_relat_rescop(vr_idxcop).dtmvtolt,'dd/mm/yyyy') ||'</dtmvtolt>
                          <vldtrans>'|| vr_tab_relat_rescop(vr_idxcop).vldtrans ||'</vldtrans>                           
                        </detalhes>');
            -- buscar proximo
            vr_idxcop := vr_tab_relat_rescop.next(vr_idxcop);
          END LOOP;
          gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</rescop>');
        END pc_resumo_coop;  


      BEGIN

        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;
        gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><crrl685>');

        -- Inicializar variaveis de controle
        vr_cdcooper := -1;
        vr_cdagenci := -1;     
        vr_vltotonn := 0;
        vr_vltotoff := 0;

        -- buscar dados da execução
        for rw_rel in cr_work_rel(pr_cdcooper
                                 ,vr_cdprogra
                                 ,'DADOS_RELAT' 
                                 ,rw_crapdat.dtmvtolt) loop

          -- Verificar se mudou a cooperativa para gerar novo nó da cooper
          IF rw_rel.cdcooper <> vr_cdcooper THEN
            -- se não for a primeiro registro , fechar nós abertos
            IF vr_cdcooper <> -1 THEN
              gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</agenci>');
              -- gerar resumo por cooperativa
              pc_resumo_coop;

              gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</cooper>');

            END IF;

            -- criar nó
            gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,
                             '<cooper  cdcooper="'||rw_rel.cdcooper
                           ||'" nmrescop="'||rw_rel.nmrescop||'">');
            vr_cdcooper := rw_rel.cdcooper;
            -- inicializar nós encerrados
            vr_cdagenci := -1;
            vr_flgrejei := -1;
            vr_vltotonn := 0;
            vr_vltotoff := 0;
            -- limpar temptable
            vr_tab_relat_rescop.delete;

          END IF;

          -- Verificar se mudou a agencia para gerar novo nó da agenci
          IF rw_rel.cdagenci <> vr_cdagenci THEN
            
            -- se não for a primeiro registro , fechar nós abertos
            IF vr_cdagenci <> -1 THEN             
              gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</agenci>');
            END IF;
            -- criar nó
            gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,
                                   '<agenci cdagenci="'||rw_rel.cdagenci||'"
                                    nmresage="'||rw_rel.cdagenci||' - '
                                               ||NVL(rw_rel.nmresage,'Nao Cadastrada')||'">');
            vr_cdagenci := rw_rel.cdagenci;
            -- inicializar nós encerrados
            vr_flgrejei := -1;
          END IF;
          
          IF rw_rel.cdorigem = 7 THEN
            vr_dsorigem := 'Offline';
            vr_vltotoff := vr_vltotoff + rw_rel.vldtrans;
          ELSIF rw_rel.cdorigem = 8 THEN
            vr_dsorigem := 'Online';
            vr_vltotonn := vr_vltotonn + rw_rel.vldtrans;
          ELSE
            vr_dsorigem := 'Critica';
          END IF;      
           
          IF rw_rel.inpessoa = 1 THEN 
            vr_dspessoa := 'PF';               
          ELSE 
            vr_dspessoa := 'PJ';
          END IF;
          
          -- incluir tags de dados
          gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,
                         '<detalhes>
                            <cdtrnbcb>'|| lpad(rw_rel.cdtrnbcb,3,'0') || '</cdtrnbcb>
                            <dstrnbcb>'|| lpad(rw_rel.cdtrnbcb,3,'0')||' - '||
                                          rw_rel.dstrnbcb || '</dstrnbcb>
                            <dshistor>'|| rw_rel.dshistor || '</dshistor>
                            <inpessoa>'|| rw_rel.inpessoa ||'</inpessoa>
                            <dspessoa>'|| vr_dspessoa ||'</dspessoa>
                            <cdorigem>'|| rw_rel.cdorigem  ||'</cdorigem>
                            <dsorigem>'|| vr_dsorigem ||'</dsorigem>
                            <flgdebcc>'|| rw_rel.flgdebcc ||'</flgdebcc>                          
                            <dtdtrans>'|| to_char(rw_rel.dtdtrans,'dd/mm/yyyy') ||'</dtdtrans>
                            <dtmvtolt>'|| to_char(rw_rel.dtmvtolt,'dd/mm/yyyy') ||'</dtmvtolt>
                            <vldtrans>'|| rw_rel.vldtrans ||'</vldtrans>                           
                          </detalhes>');
            
       
      
          -- resumo cooperativa
          vr_idxcop := lpad(rw_rel.cdcooper,5,'0') || -- cdcooper(5)
                       rw_rel.inpessoa ||
                       lpad(rw_rel.cdtrnbcb,3,'0')||
                       lpad(rw_rel.cdhistor,5,'0')||
                       rw_rel.cdorigem ||
                       to_char(rw_rel.dtdtrans,'ddmmyyyy') ||
                       to_char(rw_rel.dtmvtolt,'ddmmyyyy');

          --Atribuir valores
          vr_tab_relat_rescop(vr_idxcop).cdcooper := rw_rel.cdcooper;
          vr_tab_relat_rescop(vr_idxcop).nmrescop := rw_rel.nmrescop;
          vr_tab_relat_rescop(vr_idxcop).cdtrnbcb := rw_rel.cdtrnbcb;
          vr_tab_relat_rescop(vr_idxcop).dstrnbcb := rw_rel.dstrnbcb;
          vr_tab_relat_rescop(vr_idxcop).cdhistor := rw_rel.cdhistor;
          vr_tab_relat_rescop(vr_idxcop).dshistor := rw_rel.dshistor;
          vr_tab_relat_rescop(vr_idxcop).inpessoa := rw_rel.inpessoa;
          vr_tab_relat_rescop(vr_idxcop).cdorigem := rw_rel.cdorigem ;
          vr_tab_relat_rescop(vr_idxcop).flgdebcc := rw_rel.flgdebcc;
          vr_tab_relat_rescop(vr_idxcop).dtdtrans := rw_rel.dtdtrans;
          vr_tab_relat_rescop(vr_idxcop).dtmvtolt := rw_rel.dtmvtolt;
          vr_tab_relat_rescop(vr_idxcop).vldtrans := nvl(vr_tab_relat_rescop(vr_idxcop).vldtrans,0) + rw_rel.vldtrans;
                          
        END LOOP;
        
        -- Se não achou ninguem
        IF vr_cdcooper = -1 THEN   
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
          RETURN;
        END IF;
        
        -- Fechar as tags e descarregar o buffer        
        gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</agenci>');

        -- GERAR RESUMO POR COOPERATIVA
        pc_resumo_coop;
        gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</cooper>');        
        gene0002.pc_escreve_xml(vr_des_xml,vr_texto_completo,'</crrl685>',TRUE);

        -- Busca do diretório base da cooperativa para PDF
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'     --> /usr/coop
                                              ,pr_cdcooper => 3       --> /*CECRED*/
                                              ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
        
        -- Efetuar solicitação de geração de relatório --
        gene0002.pc_solicita_relato(pr_cdcooper  => 3 -- CECRED       --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl685/cooper' --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl685.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem parametros
                                   ,pr_dsarqsaid => vr_nom_direto||'/crrl685_'||lpad(nvl(vr_nrseqarq,0),7,'0')||'.lst' --> Arquivo final com código da agência
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                   --> Número de cópias
                                   ,pr_flg_gerar => 'N'                 --> gerar na hora
                                   ,pr_des_erro  => pr_dscritic);       --> Saída com erro
                                   
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao gerar relatorio crrl685: '||SQLerrm;
      END pc_relatorio_crrl685;

      -- Gerar LOG dos dados dos Arquivos
      PROCEDURE pc_log_dados_arquivo(pr_tipodreg IN NUMBER  -- Tipo de registro: 1 - Dados conta cartao / 2- Dados do cartao
                                    ,pr_nmdarqui IN VARCHAR2 
                                    ,pr_nrdlinha IN NUMBER
                                    ,pr_dscritic IN VARCHAR2) IS
        vr_dstpdreg VARCHAR2(50);
        vr_dstexto VARCHAR2(2000);
        vr_titulo VARCHAR2(1000);
        vr_destinatario_email VARCHAR2(500);
        vr_idprglog   tbgen_prglog.idprglog%TYPE;                         
      BEGIN
        -- verificar qual o tipo de registro do arquivo
        IF pr_tipodreg = 1 THEN
          vr_dstpdreg:= 'Conciliacao de debito dos Cartoes Bancoob Cabal';
        ELSE
          vr_dstpdreg:= 'Nao definido';
        END IF;

        -- Texto para utilizar na abertura do chamado e no email enviado
        vr_dstexto:= to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' ||
                     'Erro na ' || nvl(vr_dstpdreg,' ') || 
                     '. ' ||  ' Linha '  || nvl(pr_nrdlinha,0) ||
                     ', arquivo: ' || pr_nmdarqui || ', Critica: ' || nvl(pr_dscritic,' ');

        -- Parte inicial do texto do chamado e do email        
        vr_titulo:= '<b>Abaixo os erros encontrados no processo de conciliacao dos'||
                    ' arquivos com as transacoes de debitos dos cartoes BANCOOB CABAL</b><br><br>';
                    
        -- Buscar e-mails dos destinatarios do produto cartoes
        vr_destinatario_email := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRD_RESPONSAVEL');
                   
        -- Gerar log do erro encontrado
        cecred.pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                              ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                              ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               -- Parametros para Ocorrencia
                              ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                              ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                              ,pr_dsmensagem    => vr_dstexto    --> dscritic       
                              ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                              ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
                              ,pr_texto_chamado => vr_titulo
                              ,pr_destinatario_email => vr_destinatario_email
                              ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
                              ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)
        
        -- Finalizar a execução
        cecred.pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                              ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                              ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               -- Parametros para Ocorrencia
                              ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)  
        vr_dscritic := vr_dstexto;
      END pc_log_dados_arquivo;


    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra
                                ,pr_action => 'CCRD0003.pc_crps670');
                                  
      -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      vr_idlog_ini_ger := null;
      pc_log_programa(pr_dstiplog   => 'I'    
                     ,pr_cdprograma => vr_cdprogra          
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 1    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger);
        
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
        
      vr_dsdircop := rw_crapcop.dsdircop;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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
      
      -- buscar informações do arquivo a ser processado
      OPEN cr_crapscb;
      FETCH cr_crapscb INTO rw_crapscb;
      IF cr_crapscb%NOTFOUND  THEN
        vr_dscritic := 'Registro crapscb não encontrado!';
        CLOSE cr_crapscb;
         --levantar excecao
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapscb;

      -- buscar caminho de arquivos do Bancoob/CABAL
      vr_dsdireto := rw_crapscb.dsdirarq;
      vr_direto_connect := vr_dsdireto || '/recebe';
        
      -- Inicializar variaveis
      vr_qtdejobs := pr_qtdejobs;
        
      -- Buscar data base para transacoes com contas migradas no periodo da migracao
      vr_dtcxtmig := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DT_CEXT_CTA_MIGRADA');
      -- Se nao encontrou parametro
      IF vr_dtcxtmig IS NULL THEN
        --Montar mensagem de erro
        vr_dscritic:= 'Não foi encontrado parametro de data base para transacoes debito contas migradas.';
        --Levantar Exceção
        RAISE vr_exc_saida;
      END IF;
      -- Tentar converter o texto para data
      declare
        vr_dtcxtcnv date;
      begin
        vr_dtcxtcnv := to_date(vr_dtcxtmig,'dd/mm/rrrr');
      exception
        when others then
          vr_dscritic := 'Não foi possivel converter parametro de data base para transacoes debito contas migradas.';
          --Levantar Exceção
          RAISE vr_exc_saida;
      end;

      -- monta nome do arquivo
      vr_nmrquivo := 'CEXT_756' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '_%.%';
        
      -- Trazer todos os arquivos da pasta
      gene0001.pc_lista_arquivos(pr_path     => vr_direto_connect 
                                ,pr_pesq     => vr_nmrquivo  
                                ,pr_listarq  => vr_listarq 
                                ,pr_des_erro => vr_dscritic); 

      --Ocorreu um erro no lista_arquivos
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;

      -- Nao encontrou nenhuma arquivo para processar
      IF TRIM(vr_listarq) IS NULL THEN
        vr_cdcritic := 182;
        vr_dscritic := NULL;
        RAISE vr_exc_fimprg;
      ELSE
        vr_vet_nmarquiv := gene0002.fn_quebra_string(pr_string  => vr_listarq,pr_delimit => ',');
        -- Nenhum arquivo?
        IF vr_vet_nmarquiv.count = 0 THEN
          vr_cdcritic := 182;
          vr_dscritic := NULL;
          RAISE vr_exc_fimprg;
        END IF;
      END IF;
        
      -- Grava LOG de ocorrência final
      pc_log_programa(PR_DSTIPLOG           => 'O'
                     ,PR_CDPROGRAMA         => vr_cdprogra 
                     ,pr_cdcooper           => pr_cdcooper
                     ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia       => 4
                     ,pr_dsmensagem         => 'Iniciando processamento de arquivos. Encontrado '||vr_vet_nmarquiv.count||' arquivo(s).'
                     ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
        
      -- Guardar a maior sequencia processada
      vr_maior_seq := rw_crapscb.nrseqarq;

      -- Percorre cada arquivo encontrado
      FOR i IN 1..vr_vet_nmarquiv.count() LOOP
            
        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Iniciando processamento do arquivo '||vr_vet_nmarquiv(i)
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 

        vr_nrdlinha := 1; -- Linha por arquivo
        vr_nmarqimp:= vr_vet_nmarquiv(i);
          
        -- adquire sequencial do arquivo atraves de seu nome
        vr_nrseqarq  := to_number(substr(vr_nmarqimp,23,7));

        -- Verificar se sequencial já foi importado
        IF nvl(rw_crapscb.nrseqarq,0) >= nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Sequencial do arquivo '|| vr_nmarqimp ||
                         ' deve ser maior que o ultimo ja processado (seq arq.: ' ||vr_nrseqarq||
                         ', Ult. seq.: ' || rw_crapscb.nrseqarq|| '), arquivo nao sera processado.';
           -- Chamar rotina para enviar E-mail e abrir chamado
          pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                              ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                              ,pr_nrdlinha => vr_nrdlinha
                              ,pr_dscritic => vr_dscritic);
          -- gravar log do erro
          pc_log_batch(true);
           
          CONTINUE;
        -- Verificar se não pulou algum sequencial
        ELSIF nvl(vr_maior_seq,0) + 1 <> nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Falta sequencial de arquivo ' ||
                         '(seq arq.: ' ||vr_nrseqarq|| ', Ult. seq.: ' || vr_maior_seq||
                         '), arquivo '|| vr_nmarqimp ||' nao sera processado.';
           -- Chamar rotina para enviar E-mail e abrir chamado
          pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                              ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                              ,pr_nrdlinha => vr_nrdlinha
                              ,pr_dscritic => vr_dscritic);
          -- gravar log do erro
          pc_log_batch(true);
           
          CONTINUE;
        END IF;
          
        -- Checar se não houve execução paralela anterior com erro e que precisa ser resumida
        open cr_work_arq(pr_cdcooper
                        ,vr_cdprogra
                        ,'CTRL_ARQ'
                        ,rw_crapdat.dtmvtolt);
        fetch cr_work_arq
         into rw_work_arq;
        -- Se encontrou
        if cr_work_arq%found then
          close cr_work_arq;
          -- Restart
          vr_flrestar := true;
          -- Testar se o nome do arquivo processamento anteriormente e parcialmente é o mesmo de agora
          if rw_work_arq.nmarquiv <> vr_nmarqimp then
            -- Montar mensagem de critica
            vr_dscritic := 'Houve execucao parcial anterior para o arquivo ' ||rw_work_arq.nmarquiv
                        || 'e agora esta sendo processado outro arquivo '|| vr_nmarqimp ||'.';
            -- Chamar rotina para enviar E-mail e abrir chamado
            pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                                ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                                ,pr_nrdlinha => vr_nrdlinha
                                ,pr_dscritic => vr_dscritic);
            -- Levantar Exceção
            RAISE vr_exc_saida;
          -- Testar sequencia
          elsif rw_work_arq.nrseqarq <> vr_nrseqarq then
            -- Montar mensagem de critica
            vr_dscritic := 'Houve execucao parcial anterior para a sequencia ' ||rw_work_arq.nrseqarq
                        || 'e agora esta sendo processado outra sequencia '|| vr_nrseqarq ||'.';
            -- Chamar rotina para enviar E-mail e abrir chamado
            pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                                ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                                ,pr_nrdlinha => vr_nrdlinha
                                ,pr_dscritic => vr_dscritic);
            -- Levantar Exceção
            RAISE vr_exc_saida;
          end if;
          -- Tudo ok, restauremos dados para controle dos Jobs
          vr_qtregjob := rw_work_arq.qtregjob;
          vr_nrexepar := rw_work_arq.nrexepar;
          -- Caso a quantidade de paralelos agora estiver zero, altermos para 1, para evitar problemas de processamento
          if vr_qtdejobs = 0 then
            vr_qtdejobs := 1;
          end if;
        else
          close cr_work_arq;
          -- Não é restador
          vr_flrestar := false;
        end if;
          
        -- Somente quando não for um re-execução
        if not vr_flrestar then
          
          -- Buscar o Header do arquivo          
          vr_comando:= 'head -n 1 '||vr_direto_connect||'/'||vr_nmarqimp;

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_saida_so);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_saida;
          END IF;
            
          -- Verificar se a primeira linha é o Header
          IF SUBSTR(vr_saida_so,1,5) <> 'CEXT0' THEN  
            vr_dscritic:= 'Arquivo incompleto - Sem Header';   
            -- Chamar rotina para enviar E-mail e abrir chamado
            pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                                ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                                ,pr_nrdlinha => 1
                                ,pr_dscritic => vr_dscritic); 
            CONTINUE; -- Proximo arquivo
          ELSE
            -- verifica se sequencial do arquivo é diferente ao procurado
            IF substr(vr_saida_so,17,7) <> vr_nrseqarq THEN
              -- Montar mensagem de critica
              vr_dscritic := 'Erro na sequencia do arquivo CEXT.';
              RAISE vr_exc_saida;
            END IF;

            -- Grava registro com informações do HEADER na crapccb
            BEGIN
              INSERT INTO crapccb
                (nrseqarq,
                 nmarquiv,
                 cddbanco,
                 dtarquiv)
              VALUES
                (nvl(vr_nrseqarq,0),
                 vr_nmarqimp,
                 nvl(trim(substr(vr_saida_so,6,3)),0),
                 to_date(trim(substr(vr_saida_so,9,8)),'YYYYMMDD'))
               RETURNING ROWID INTO rw_crapccb.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir crapccb: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            
          END IF;
            

          /* o comando abaixo ignora quebras de linha atraves do 'grep -v' e o 'tail -1' retorna
             a ultima linha do resultado do grep */
          vr_comando:= 'grep -v '||'''^$'' '||vr_direto_connect||'/'||vr_nmarqimp||'| tail -1';

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_saida_so);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_saida;
          END IF;
                   
          -- Verificar se a ultima linha é o Trailer
          IF SUBSTR(vr_saida_so,1,5) <> 'CEXT9' THEN  
            vr_dscritic:= 'Arquivo incompleto - Sem Trailler.';   
            -- Chamar rotina para enviar E-mail e abrir chamado
            pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                                ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                                ,pr_nrdlinha => vr_nrdlinha
                                ,pr_dscritic => vr_dscritic); 
            CONTINUE; -- Proximo arquivo
          ELSE
            -- Atualiza a valores do cabeçalho
            BEGIN
              UPDATE crapccb
                 SET qtregarq = substr(vr_saida_so,6,7),
                     vltttran = (substr(vr_saida_so,13,18) / 100)
               WHERE ROWID = rw_crapccb.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar crapccb: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
            
          -- Caso habilitado execução paralela
          if vr_qtdejobs > 0 then
            -- Dividar a quantidade total de linhas pela de Jobs arredondando
            vr_qtregjob := round(substr(vr_saida_so,6,7) / vr_qtdejobs);  
            -- Se esta quantidade for superior a máxima parametrizada por Jobs
            if pr_qtregjob > 0 and vr_qtregjob > pr_qtregjob then
              -- Assumir a parametrizada
              vr_qtregjob := pr_qtregjob;
            end if;
          end if;
            
          -- Grava LOG de ocorrência final
          pc_log_programa(PR_DSTIPLOG           => 'O'
                         ,PR_CDPROGRAMA         => vr_cdprogra 
                         ,pr_cdcooper           => pr_cdcooper
                         ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         ,pr_tpocorrencia       => 4
                         ,pr_dsmensagem         => 'Iniciando leitura de linhas para tabela'
                         ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
            
          -- Varrer o arquivo para transformar suas informações em dados da tabela
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect||'/'        --> Diretorio do arquivo
                                  ,pr_nmarquiv => vr_nmarqimp          --> Nome do arquivo
                                  ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                                  ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);      --> erro
          -- em caso de crítica
          IF vr_dscritic IS NOT NULL THEN
            -- levantar excecao
            vr_dscritic := 'Erro ao abrir o arquivo ' || vr_nmarqimp || ' no dir do Bancoob.';
            RAISE vr_exc_saida;
          END IF;

          -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
          IF utl_file.IS_OPEN(vr_ind_arquiv) THEN
            -- Ler todas as linhas do arquivo
            LOOP
              BEGIN
                vr_nrdlinha:= vr_nrdlinha + 1;
                -- Se execução paralela 
                IF vr_qtdejobs > 0 THEN
                  -- De acordo com a quantidade maxima de registros por JOB
                  -- verifique o enquadramento do registro perante os jobs
                  vr_nrexepar := TRUNC(vr_nrdlinha/vr_qtregjob)+1; 
                END IF;
                -- Lê a linha do arquivo aberto
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                            ,pr_des_text => vr_des_text); --> Texto lido
                -- Gravar em tabela
                begin
                  insert into tbgen_batch_relatorio_wrk(cdcooper
                                                       ,cdprograma
                                                       ,dsrelatorio
                                                       ,dtmvtolt
                                                       ,dschave
                                                       ,cdagenci
                                                       ,nrdconta
                                                       ,dscritic)
                                                 values(pr_cdcooper
                                                       ,vr_cdprogra
                                                       ,'DADOS_ARQ'
                                                       ,rw_crapdat.dtmvtolt
                                                       ,vr_nmarqimp
                                                       ,vr_nrexepar
                                                       ,vr_nrdlinha
                                                       ,vr_des_text);
                exception
                  when others then
                    vr_dscritic := 'Erro ao gerar tabela temporaria com dados arquivo -> '||sqlerrm;
                    raise vr_exc_saida;
                end;        
              EXCEPTION

                WHEN no_data_found THEN -- não encontrar mais linhas
                  EXIT;
                WHEN vr_exc_saida THEN
                  raise vr_exc_saida;
                WHEN OTHERS THEN
                  pc_internal_exception(3, 'Linha do arquivo: ' || vr_des_text);
                  IF vr_dscritic IS NULL THEN
                    vr_dscritic := 'Erro arquivo ['|| vr_nmarqimp ||']: '||SQLERRM;
                  END IF;
                  RAISE vr_exc_saida;
              END;

            END LOOP;
          END IF;

          -- Fechar o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
            
          -- Caso habilitado execução paralela
          if vr_qtdejobs > 0 then
            -- Gravar em tabela de controle dados para indicar qual arquivo, sequencia, e opções
            -- utilizadas para em casos de resumo de execuções termos as informações necessárias
            begin
              insert into tbgen_batch_relatorio_wrk(cdcooper
                                                   ,cdprograma
                                                   ,dsrelatorio
                                                   ,dtmvtolt
                                                   ,dschave
                                                   ,cdagenci
                                                   ,nrdconta
                                                   ,nrctremp)
                                             values(pr_cdcooper
                                                   ,vr_cdprogra
                                                   ,'CTRL_ARQ'
                                                   ,rw_crapdat.dtmvtolt
                                                   ,vr_nmarqimp
                                                   ,vr_nrseqarq
                                                   ,vr_qtregjob
                                                   ,vr_nrexepar);
            exception
              when others then
                vr_dscritic := 'Erro ao gerar tabela temporaria com dados controle arquivo -> '||sqlerrm;
                raise vr_exc_saida;
            end;  
          end if;
            
          -- Grava LOG de ocorrência final
          pc_log_programa(PR_DSTIPLOG           => 'O'
                         ,PR_CDPROGRAMA         => vr_cdprogra 
                         ,pr_cdcooper           => pr_cdcooper
                         ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         ,pr_tpocorrencia       => 4
                         ,pr_dsmensagem         => 'Finalizou leitura de linhas para tabela'
                         ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
            
        end if;
          
        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Iniciando processamento de linhas'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
            
        -- Caso execução paralela ou resumo de execução
        if vr_flrestar or vr_qtdejobs > 0 then 
            
          -- Precisamos commitar para que os processos filhos enxerguem os dados gerados acima
          commit;
          
          -- Gerar o ID para o paralelismo
          vr_idparale := gene0001.fn_gera_ID_paralelo;
                         
          -- Se houver algum erro, o id vira zerado
          IF vr_idparale = 0 THEN
            -- Levantar exceção
            vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
            RAISE vr_exc_saida;
          END IF;
                                                               
          -- Verifica se algum job paralelo executou com erro
          vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                       ,pr_cdprogra    => vr_cdprogra
                                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                       ,pr_tpagrupador => 1
                                                       ,pr_nrexecucao  => 1);     
          
          -- Efetuar laço de 1 a N execuções (De acordo com o maior Job definido)
          for vr_idx in 1..vr_nrexepar loop              
            -- Caso houve erro
            if vr_qterro > 0 then                
              -- Checar se este agrupador é um dos que deram erro
              open cr_exec_ant(pr_cdcooper    => pr_cdcooper
                              ,pr_cdprograma  => vr_cdprogra
                              ,pr_cdagrupador => vr_idx
                              ,pr_dtmvtolt    => rw_crapdat.dtmvtolt);
              fetch cr_exec_ant
               into rw_exec_ant;
              -- Se encontrou e o mesmo rodou com sucesso
              if cr_exec_ant%found and rw_exec_ant.insituacao = 2 then
                close cr_exec_ant;
                -- Ignorar este
                continue;
              else
                close cr_exec_ant;
              end if;      
            end if;
            
            -- Montar o prefixo do código do programa para o jobname
            vr_jobname := vr_cdprogra ||'_'|| vr_idx || '$';  
           
            -- Cadastra o programa paralelo
            gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                      ,pr_idprogra => vr_idx     --> Utiliza a agência como id programa
                                      ,pr_des_erro => vr_dscritic);
                                       
            -- Testar saida com erro
            if vr_dscritic is not null then
              -- Levantar exceçao
              raise vr_exc_saida;
            end if;     
             
            -- Montar o bloco PLSQL que será executado
            -- Ou seja, executaremos a geração dos dados
            -- para a agência atual atraves de Job no banco
            vr_dsplsql := 'DECLARE' || chr(13) 
                       || '  wpr_cdcritic NUMBER;' || chr(13) 
                       || '  wpr_dscritic VARCHAR2(1500);' || chr(13) 
                       || 'BEGIN' || chr(13) 
                       || '  ccrd0003.pc_proces_arq_cet_bancoob('||pr_cdcooper||chr(13)
                       || '                                    ,to_date('''||to_char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||''',''dd/mm/rrrr'')'||chr(13)
                       || '                                    ,'''||vr_dtcxtmig||''''||chr(13)
                       || '                                    ,'||vr_nrseqarq||chr(13)
                       || '                                    ,'||vr_idx||chr(13)
                       || '                                    ,'||vr_idparale||chr(13)
                       || '                                    ,wpr_cdcritic,wpr_dscritic);'||chr(13)
                       || 'END;'; 
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
                                         ,pr_qtdproce => vr_qtdejobs --> Máximo de 10 jobs neste processo
                                         ,pr_des_erro => vr_dscritic);
         
             -- Testar saida com erro
             if  vr_dscritic is not null then 
               -- Levantar exceçao
               raise vr_exc_saida;
             end if;
              
          end loop;
          -- Chama rotina de aguardo agora passando 0, para esperarmos
          -- até que todos os Jobs tenha finalizado seu processamento
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => 0
                                      ,pr_des_erro => vr_dscritic);
                                       
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;    
         
          -- Verifica se algum job executou com erro
          vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                       ,pr_cdprogra    => vr_cdprogra
                                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                       ,pr_tpagrupador => 1
                                                       ,pr_nrexecucao  => 1);
          if vr_qterro > 0 then 
            vr_cdcritic := 0;
            vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
            raise vr_exc_saida;
          end if;  
        else
          -- Executar diretamente e uma única vez
          ccrd0003.pc_proces_arq_cet_bancoob(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_dtcxtmig => vr_dtcxtmig
                                            ,pr_nrseqarq => vr_nrseqarq
                                            ,pr_nrseqexe => 1
                                            ,pr_idparale => 0
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
          -- Em caso de erro
          if vr_cdcritic > 0 or vr_dscritic is not null then
            raise vr_exc_saida;
          end if;
        end if;
           
        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Finalizou processamento de linhas Iniciou processamento lotes'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
          
        -- Retornar os dados para gravação de LOTE  
        for rw_work_lot in cr_work_lot(pr_cdcooper    => pr_cdcooper
                                      ,pr_cdprograma  => vr_cdprogra
                                      ,pr_dsrelatorio => 'CRAPLOT_CET' 
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt) loop
          -- verifica se já existe lote correpondente
          OPEN cr_craplot(pr_cdcooper => rw_work_lot.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                          pr_cdagenci => rw_work_lot.cdagenci);
          FETCH cr_craplot INTO rw_craplot;

          -- Se nao existir vai criar a capa de lote
          IF cr_craplot%NOTFOUND THEN
            close cr_craplot;
            BEGIN
              INSERT INTO craplot
                (dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrseqdig,
                 tplotmov,
                 tpdmoeda,
                 qtcompln,
                 qtinfoln,
                 vlcompdb,
                 vlinfodb,
                 cdoperad,
                 cdcooper)
              VALUES
                (rw_crapdat.dtmvtolt,
                 rw_work_lot.cdagenci,
                 vr_cdbccxlt,
                 vr_nrdolote,
                 rw_craplot.nrseqdig,
                 17,
                 1,
                 rw_work_lot.qtcompln,
                 rw_work_lot.qtinfoln,
                 rw_work_lot.vlcompdb,
                 rw_work_lot.vlcompdb,
                 '1',
                 rw_work_lot.cdcooper)
               RETURNING craplot.ROWID INTO rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          ELSE
            close cr_craplot;
            -- Atualizar
            BEGIN
              UPDATE craplot
                 -- Se o numero for maior que o ja existente atualiza
                 SET nrseqdig = greatest(nrseqdig,rw_craplot.nrseqdig),
                     qtcompln = qtcompln + rw_craplot.qtcompln,
                     qtinfoln = qtinfoln + rw_craplot.qtinfoln,
                     vlcompdb = vlcompdb + rw_craplot.vlcompdb,
                     vlinfodb = vlcompdb + rw_craplot.vlcompdb
               WHERE ROWID = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
            
        end loop; 

        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Finalizou processamento lotes e iniciando movimentacao do arquivo'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 

            -- Montar Comando para copiar o arquivo lido para o diretório recebidos do CONNECT
        vr_comando:= 'cp '|| vr_direto_connect || '/' || vr_nmarqimp ||
                         ' '  || vr_dsdireto || '/recebidos/ 2> /dev/null';

            -- Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);

            -- Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
              RAISE vr_exc_saida;
            END IF;

            -- Montar Comando para mover o arquivo lido para o diretório salvar
        vr_comando:= 'mv '|| vr_direto_connect || '/' || vr_nmarqimp ||
                         ' /usr/coop/' || vr_dsdircop || '/salvar/ 2> /dev/null';

            -- Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
            -- Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
              RAISE vr_exc_saida;
            END IF;

            -- Verifica o maior sequencial entre todos os arquivos abertos para armazenar na crapscb
            IF vr_maior_seq < vr_nrseqarq THEN
              vr_maior_seq := vr_nrseqarq;
            END IF;

            -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
            BEGIN
              UPDATE crapscb
              SET nrseqarq = vr_maior_seq,
                  dtultint = SYSDATE
              WHERE crapscb.tparquiv = 2; -- Arquivo CEXT - Conciliação dos Débitos

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

        -- Eliminar informações temporárias (Menos do relatório)
        begin    
          delete from tbgen_batch_relatorio_wrk
           where cdcooper    = pr_cdcooper
             and cdprograma  = vr_cdprogra
             AND dsrelatorio IN('CRAPLOT_CET','CTRL_ARQ','DADOS_ARQ')
             and dtmvtolt    = rw_crapdat.dtmvtolt;    
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
            raise vr_exc_saida;            
        end;

            -- Apos processar o arquivo, deve realizar o commit,
            -- pois já moveu para a pasta recebidos

           COMMIT;
           
        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Inicio geracao Crrl685'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
          
           -- gerar relatorio contendo informações sobre os registros processados
              pc_relatorio_crrl685(pr_dscritic => vr_dscritic);
        
        -- Busca o diretório final para copiar arquivos
        vr_dsdircop_contab := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => 0
                                                       ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

        vr_dtmvtolt_yymmdd := to_char(rw_crapdat.dtmvtoan, 'yymmdd');
        vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_TARIFAS_CARTOES.txt';

        /* Prj421 - Melhorias nas ferramentas contabeis e fiscais */
        FOR rw_bancoob_tarifa IN cr_bancoob_tarifa LOOP
          --Primeiro registro da cooperativa deve abrir o arquivo
          IF rw_bancoob_tarifa.nrseqreg = 1 THEN
            vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                      pr_cdcooper => rw_bancoob_tarifa.cdcooper,
                                                      pr_nmsubdir => 'contab');

            -- Abre o arquivo para escrita
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                                     pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                                     pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                                     pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                                     pr_des_erro => vr_dscritic);

            if vr_dscritic is not null then
              vr_cdcritic := 0;
              RAISE vr_exc_saida;
            end if;
          END IF;
          
          --Primeiro registro do historico deve gerar a linha contabil
          IF rw_bancoob_tarifa.nrseqreghis = 1 THEN
            /* Escrita arquivo */
            vr_linhadet := trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(rw_crapdat.dtmvtoan,'ddmmyy'))||','||
                           rw_bancoob_tarifa.nrctadeb||','||
                           rw_bancoob_tarifa.nrctacrd||','||
                           trim(to_char(rw_bancoob_tarifa.vltotal, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','||
                           '5210,'||
                           '"VALOR REF. DEBITO C/C '||gene0002.fn_mask(rw_bancoob_tarifa.nrctabcb,'zzz.zzz.zzz-z')||
                           ' BANCOOB REF. '||rw_bancoob_tarifa.dscontabil||CASE WHEN rw_bancoob_tarifa.inpessoa = 1 THEN ' - PF' ELSE ' - PJ' END||'"';

            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          END IF;

          --Todas as linhas geram rateio
          vr_linhadet := lpad(rw_bancoob_tarifa.cdagenci,3,'0')||','||trim(to_char(rw_bancoob_tarifa.vldtrans, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          --Ultimo registro de cada cooperativa deve fechar o arquivo contabil e transferilo
          IF rw_bancoob_tarifa.nrseqreg = rw_bancoob_tarifa.qtdreg THEN
            gene0001.pc_fecha_arquivo(vr_arquivo_txt);

            vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(rw_bancoob_tarifa.cdcooper),2,0)||'_TARIFAS_CARTOES.txt';                        

            -- Copia o arquivo gerado para o diretório final convertendo para DOS
            gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop_contab||'/'||vr_nmarqnov||' 2>/dev/null',
                                        pr_typ_saida   => vr_typ_said,
                                        pr_des_saida   => vr_dscritic);
            -- Testar erro
            IF vr_typ_said = 'ERR' THEN
               vr_cdcritic := 1040;
               gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
            END IF;
          END IF;
        END LOOP;
        /* Fim Prj421 */

        -- Eliminar informações temporárias do relatório
        begin    
          delete from tbgen_batch_relatorio_wrk
           where cdcooper    = pr_cdcooper
             and cdprograma  = vr_cdprogra
             AND dsrelatorio = 'DADOS_RELAT'
             and dtmvtolt    = rw_crapdat.dtmvtolt;    
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
            raise vr_exc_saida;            
        end;
           
        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Fim geracao Crrl685'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 

            -- Montar mensagem de critica
        vr_dscritic := 'Arquivo '|| vr_nmarqimp|| ' importado com sucesso!';
            -- gravar log do erro
            pc_log_batch(false);
            
        -- Grava LOG de ocorrência final
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra 
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Terminou de processar arquivo -> ' ||vr_nmarqimp
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger); 

        -- Gravação final por arquivo
        Commit;

                END LOOP;

      -- Grava LOG de ocorrência final
      pc_log_programa(PR_DSTIPLOG           => 'O'
                     ,PR_CDPROGRAMA         => vr_cdprogra 
                     ,pr_cdcooper           => pr_cdcooper
                     ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia       => 4
                     ,pr_dsmensagem         => 'Iniciando gravacoes finais.'
                     ,PR_IDPRGLOG           => vr_idlog_ini_ger); 
      
                -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
                BEGIN
        UPDATE crapscb
        SET nrseqarq = vr_maior_seq,
                        dtultint = SYSDATE
        WHERE crapscb.tparquiv = 2; -- Arquivo CEXT - Conciliação dos Débitos
                EXCEPTION
                    WHEN OTHERS THEN
                        -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                        vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
                        RAISE vr_exc_saida;
                END;

        --Caso identificar alguma falha retorna critica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Apaga o arquivo pc_crps670.txt no unix
        vr_comando:= 'rm ' || vr_direto_connect || '/pc_crps670.txt 2> /dev/null';
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_saida;
        END IF;

        -- retonar a mesma critica gerada no log se for a tela ARQBCB
        -- e gerou algum erro, do contrario a tela irá apresentar a mensagem de sucesso
      IF TRIM(vr_dsretorn) IS NOT NULL AND upper(pr_nmdatela) = 'ARQBCB' AND vr_flgerro THEN
        pr_dscritic := vr_dsretorn;
        END IF;
        
        --  Nao deve-se mais gerar o arquivo para o BI. 
        --  Ao inves disso, sera alterado o registro na CRAPPRM                                              
        BEGIN
          UPDATE crapprm a
             SET a.dsvlrprm = 1
           WHERE a.nmsistem = 'CRED'
             AND a.cdcooper = 3
             AND a.cdacesso = 'PC_CRPS670';
        EXCEPTION
          WHEN OTHERS THEN
             -- DESCRICAO DO ERRO NA ALTERACAO DE REGISTRO
             vr_dscritic := 'Problema ao atualizar registro na tabela CRAPPRM: ' || sqlerrm;
             RAISE vr_exc_saida;
        END;
        -- Se nao encontrou registro para alterar, insere registro
        IF SQL%ROWCOUNT = 0 THEN
          BEGIN
            INSERT INTO crapprm
              (nmsistem,
               cdcooper,
               cdacesso,
               dstexprm,
               dsvlrprm)
             VALUES
              ('CRED',
               3,
               'PC_CRPS670',
               'Controle de termino do processo do PC_CRPS670, para inicio do processo BI',
               1);
          EXCEPTION
               WHEN OTHERS THEN 
                 -- DESCRICAO DO ERRO NA INCLUSAO DE REGISTRO
                 vr_dscritic := 'Problema ao inserir registro na tabela CRAPPRM: ' || sqlerrm;
                 RAISE vr_exc_saida;
          END;
        END IF;
                                
      --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 1); 
      -- Efetuar commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- loga a mensagem de critica
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;        

        -- Chamar rotina para enviar E-mail e abrir chamado
        pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                            ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                            ,pr_nrdlinha => vr_nrdlinha
                            ,pr_dscritic => vr_dscritic);

        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 2, --> erro tratado 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || pr_dscritic, 
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        ROLLBACK;
      WHEN vr_exc_fimprg THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- loga a mensagem de critica
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;   

        -- Chamar rotina para enviar E-mail e abrir chamado
        pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                            ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                            ,pr_nrdlinha => vr_nrdlinha
                            ,pr_dscritic => pr_dscritic);

        -- Desfaz as alterações da base
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS670: ' || SQLERRM;

        pc_internal_exception(3, pr_dscritic);

        -- Chamar rotina para enviar E-mail e abrir chamado
        pc_log_dados_arquivo(pr_tipodreg => 1 -- Conciliacao Cartao Bancoob/Cabal
                            ,pr_nmdarqui => nvl(vr_nmarqimp,' ')
                            ,pr_nrdlinha => vr_nrdlinha
                            ,pr_dscritic => pr_dscritic);
        ROLLBACK;
    END;

  END pc_recebe_arq_cet_bancoob;
  
/* Rotina com a os procedimentos para o CRPS670 */
  PROCEDURE pc_crps670_web(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_crps670_web
    Sistema : Cartoes de Credito - Cooperativa de Credito
    Sigla   : CRRD
    Autor   : Lucas Lunelli
    Data    : Maio/14.                    Ultima atualizacao: 13/12/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado.
                ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB e CRON.

    Objetivo  : Direcionar para a conciliaçãp débitos dos Cartões de Crédito BANCOOB/CABAL.

    Observacao: -----

    Alteracoes: 16/07/2018 - Projeto Revitalização Sistemas - Novos parametros passados nas chamadas
                             devido paralelismo criado - Andreatta (MOUTs) 
                             
                13/12/2018 - Limitar em 8 solicitacoes de cartoes para a mesma conta no mesmo 
                             arquivo (Lucas Ranghetti INC0027563)
    ....................................................................................................*/
    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      -- Extração dados XML
      vr_cdcooper   NUMBER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);
      
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
    BEGIN

      -- extrai dados do XML (para uso Ayllos WEB)
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Acionar rotina para processamento
      pc_recebe_arq_cet_bancoob(pr_cdcooper => vr_cdcooper
                               ,pr_nmdatela => vr_nmdatela
                               ,pr_qtdejobs => 0
                               ,pr_qtregjob => 0
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
      -- Em caso de erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF; 
          
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro><![CDATA[' || vr_dscritic ||']]></Erro><TpException>1</TpException></Root>');
   
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS670: ' || SQLERRM;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro><![CDATA[' || pr_dscritic ||']]></Erro></Root>');
    END;

  END pc_crps670_web;  
  
  
  /* Rotina com a os procedimentos para o CRPS671 */
  PROCEDURE pc_crps671(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
     Programa: pc_crps671
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : CRRD
     Autor   : Lucas Lunelli
     Data    : Maio/14.                    Ultima atualizacao: 30/04/2019

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado/Diário
                 ATENÇÃO! Esse procedimento é chamado pelo Ayllos WEB e CRON.

     Objetivo  : procedimento para a geração do arquivo de Interface Cadastral
                 dos Cartões de Crédito BANCOOB/CABAL.

     Observacao: -----

     Alteracoes: 18/07/2014 - Incluso tratamento para quando tpdpagto = 3 enviar 000
                              no perc. deb. aut., ajustado busca data nasc. representante
                              Incluso regra para não permitir tipo de operação 2 no caso de
                              cartão com insitcrd igual a 0,1,2 (Daniel) SD 179666.

                13/08/2014 - Ajuste para converter arquivo para DOS ao final da criação
                             (Odirlei/AMcom)

                22/08/2014 - Alteração da busca do diretorio do bancoob e remover
                             arquivo TMP(Odirlei/AMcom)

                28/08/2014 - Alterado para enviar o crawcdr.nrcctitg quando realizado
                             operação de alteração ou upgrade/downgrase(Odirlei/Amcom)

                03/09/2014 - Limpar as informações dos telefones residencial, comercial
                             e celular do cooperado, antes de buscar os novos dados.
                             Conforme problema relatado no SoftDesk 196220 ( Renato - Supero )
                           - Alterar o ponto onde é definido a variável Conta Cartão
                             para que a mesma seja redefinida a cada iteração do cr_crawcrd,
                             e não mais antes dele. SoftDesk 196032 ( Renato - Supero )

                09/09/2014 - Incluir a conta do titular quando as informações forem de um
                             cartão adicional

                25/09/2014 - Retirado pois os valores serão retornados no cursor, da
                             tabela crapttl ( Renato - Supero )

                02/10/2014 - Alterado o cursor cr_crawcrd_flgprcrd, para também validar
                             conforme a bandeira do cartão. ( Renato - Supero )
                           - Alterado para enviar também as alterações de cartões
                             liberados, não só em uso ( Renato - Supero )

                09/10/2014 - Retirado condição para que o arquivo sempre envie o registro
                             tipo 2  para pessoa juridica como 04  ( Renato - Supero )
                           - Gerar gera_linha_registro_tipo1 para pessoa juridica, somente
                             quando for o primeiro cartão ( Renato - Supero )

                15/10/2014 - Alterado para enviar a solicitação de cartão adicional com
                             operação 0201 quando o mesmo for solicitado no mesmo dia que
                             o cartão do titular, conforme SD 211272 ( Renato - Supero ).

                16/10/2014 - Ajustado para preencher o documento com zeros a esquerda ( Renato - Supero )

                17/10/2014 - Ajustar os controles de transação incluindo Rollbacks em caso
                             de erros na execução ( Renato - Supero )

                21/10/2014 - Alteração no tamanho dos campos de endereço, numero e complemento
                             conforme SD 204641 (Vanessa)

                03/11/2014 - Alterar a busca de alterações pela dtmvtolt pela dtmvtoan, pois
                             os registros não estavam sendo buscados corretamente ( Renato - Supero )

                04/11/2014 - Alterar tratamento para envio de registro com operação 04, de forma
                             a enviar a solicitação de adicional, apenas quando o registro do
                             titular já tenha sido processado e aprovado pelo bancoob.
                             Situação ocorre quando titular e adicional são enviados no mesmo dia,
                             mas em arquivos diferentes. ( Renato - Supero )

                06/11/2014 - Preencher data de solicitação quanto alterar o cartão para
                             situação 2 - Solicitado. ( Renato - Supero )

                01/12/2014 - Ajustado para ao enviar registros de alteração de telefone.
                             ( Odirlei/AMcom )

                09/01/2015 - Alterado para gerar arquivo TMP fora da pasta envia,
                             e no final mover para a envia SD241651 (Odirlei-AMcom)
                             
    20/07/2015 - #309876 Tratamento no procedure crps671 para, quando não encontrar o titular da conta (PF) ou o representante 
                (PJ), não abortar o programa e registrar em log (proc_batch) a conta, cpf e cooperativa (Carlos)
                
                14/10/2015 - Desenvolvimento do projeto 126. (James)
                
                04/11/2015 - Tratar alteracao de endereco PJ. (Chamados 327475 / 328055) - (Fabricio)
                
                11/11/2015 - Alterado cursores que envolvem o envio de informações de alterações
                             nas contas para o SIPAG (cr_crapcrd_loop_alt), a fim de sanar a situação
                             que causou os problemas relatados nos chamados 333541 e 333541 ( Renato - Supero )

                02/05/2016 - Adicionado validacao na solicitacao de UPGRADE/DOWNGRADE para nao gerar
                             solicitacao de cartao adicional nessa situacao (Douglas - Chamado 441407)             
                
                20/06/2017 - Alterar a ordem que as informações são enviadas no arquivo CCR3.
                             Primeiro vamos enviar as linhas de Alteração Cadastral e depois as linhas
                             de UPGRADE/DOWNGRADE (Douglas - Chamado 662595)

                14/07/2017 - Ajuste na validação de alteração do PA, pois da forma que estava o cooperado
                             teve alteração nos dados de emprestimo, com a inclusão de um veículo PAMPA
                             e o programa entendeu que houve troca de PA, enviando um solicitação de cartão
                             (Douglas - Chamado 708661)
                             
                24/07/2017 - Alterar cdoedptl para idorgexp.
                             PRJ339-CRM  (Odirlei-AMcom)

                23/08/2017 - Alterar o envio de alterações para que sejam enviadas as informações de 
                             alteração de limites. (Renato Darosci - Projeto 360)
                             
                10/07/2018 - Validar valores nulos na geracao das linhas do arquivo ccb3 e 
                             enviar e-mail caso nao gere arquivo (Lucas Ranghetti PRB0040160)
                             
                08/03/2019 - Verificar se processo batch ainda está rodando na central
                             pois vamos rodar o programa mesmo com a central rodando
                             (Lucas Ranghetti PRB0040618)
                             
                29/03/2019 - Ajustar cursor cr_nrctaitg para buscar somente cartoes em uso
                             (Lucas Ranghetti PRB0040697)
                             
                30/04/2019 - Incluir insitdec 8 na leitura do cursor cr_crawcrd
                             (Lucas Ranghettu PRB0041606)
                           - No Cursor cr_nrctaitg vamos utilizar o and w.nrcctitg > 0 ao 
                             invés de usar o insitcrd = 4, assim garantimos que só vamos
                             pegar a conta cartã correta (Lucas Ranghetti PRB0041677)
                
                15/05/2019 - Inclusão de envio de email ao cair no Erro geral.
                             Alcemir Mouts (PRB0041487).

	            24/05/2019 - Ajuste para quando não encontrar o endereço do cooperado
                             gerar critica e pular para o proximo registro e enviar
                             as criticas por email.
                             Alcemir Jr. (PRB0041782).
                             
                        
     ..............................................................................*/
    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_dsdireto   VARCHAR2(2000);                                    --> Caminho para gerar
      vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_nmrquivo   VARCHAR2(2000);                                    --> Nome do arquivo
      vr_dsheader   VARCHAR2(2000);                                    --> HEADER  do arquivo
      vr_dsdettp1   VARCHAR2(2000)  := 0;                              --> DETALHE do arquivo (Tipo 1)
      vr_dsdettp2   VARCHAR2(2000)  := 0;                              --> DETALHE do arquivo (Tipo 2)
      vr_dstraile   VARCHAR2(2000);                                    --> TRAILER do arquivo
      vr_nrctacrd   VARCHAR2(2000)  := 0;                              --> Nr. Conta Cartão para DETALHE (Tipo 1)
      vr_tpcntdeb   VARCHAR2(1)     := 0;                              --> Tipo de Contra Deb. para DETALHE (Tipo 1)
      vr_dstelres   VARCHAR2(2000)  := 0;                              --> Nr. Telefone Residencial
      vr_dstelcel   VARCHAR2(2000)  := 0;                              --> Nr. Telefone Celular
      vr_dstelcom   VARCHAR2(2000)  := 0;                              --> Nr. Telefone Comercial
      vr_dddresid   VARCHAR2(2000)  := 0;                              --> DDD Residencial
      vr_dddcelul   VARCHAR2(2000)  := 0;                              --> DDD Celular
      vr_dddcomer   VARCHAR2(2000)  := 0;                              --> DDD Comercial
      vr_titulari   VARCHAR2(4)     := 0;                              --> Titularidade
      vr_tipooper   VARCHAR2(4)     := 0;                              --> Tp. Operac
      vr_nrdocttl   VARCHAR2(200)   := 0;                              --> CI
      vr_idorgexp   INTEGER         := 0;                              --> Orgão Emissor da CI
      vr_cdufdttl   VARCHAR2(4)     := 0;                              --> UF da CI
      vr_nmdavali   VARCHAR2(2000);                                    --> Nome Avalista/Representante
      vr_conttip1   PLS_INTEGER     := 0;                              --> Contador de linhas DETALHES Tipo 1
      vr_conttip2   PLS_INTEGER     := 0;                              --> Contador de linhas DETALHES Tipo 2
      vr_ind_arquiv utl_file.file_type;                                --> declarando handle do arquivo
      vr_nrseqarq   INTEGER;                                           --> Sequencia de Arquivo
      vr_flgprcrd   PLS_INTEGER;                                       --> Primeiro cartão da empresa (indiferente de cdadmcrd)
      vr_nrctarg1   NUMBER;                                            --> Número da conta do registro 1
      vr_tpdpagto   INTEGER;
      vr_dtnascto   DATE;
      vr_flaltafn   BOOLEAN := FALSE;
      vr_flalttpe   BOOLEAN := FALSE;
      vr_flaltcep   BOOLEAN := FALSE;
      vr_flctacrd   BOOLEAN := FALSE;
      vr_flalttfc   BOOLEAN := FALSE;
      vr_vllimalt   NUMBER  := NULL;
      vr_dtultenv   DATE;
      vr_sexbancoob crapttl.cdsexotl%TYPE;
      vr_cdestcvl   crapavt.cdestcvl%TYPE;
      vr_nrcpfcgc   crapavt.nrcpfcgc%TYPE;
      vr_inpessoa   crapavt.inpessoa%TYPE;      
      vr_qtdconta   pls_integer; -- Contar quantidade de registros por conta no arquivo
      vr_cdprogra   VARCHAR2(19) := 'CCRD0003.PC_CRPS671';
      vr_dtmvtolt   DATE;
      vr_dtmvtoan   DATE;
      -- Upgrade no cartao do TITULAR 1
      vr_flupgrad   BOOLEAN := FALSE;
      vr_nrctaant   crapass.nrdconta%TYPE;
      
      -- Extração dados XML
      vr_cdcooper   NUMBER;
      vr_cdoperad   VARCHAR2(100);
      vr_nmdatela   VARCHAR2(100);
      vr_nmeacao    VARCHAR2(100);
      vr_cdagenci   VARCHAR2(100);
      vr_nrdcaixa   VARCHAR2(100);
      vr_idorigem   VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_loop_detalhe EXCEPTION;
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dsderro    VARCHAR2(4000);

      -- Comando completo
      vr_dscomando VARCHAR2(4000);
      -- Saida da OS Command
      vr_typ_saida VARCHAR2(4000);

      -- criticas 
      vr_criticas CLOB;
      
      ------------------------------- CURSORES ---------------------------------
      -- Busca listagem das cooperativas
      CURSOR cr_crapcol IS
       SELECT cop.cdcooper
             ,cop.cdagectl
             ,cop.cdagebcb
       FROM crapcop cop
      WHERE cop.cdcooper <> 3;

      -- Cursor genérico de calendário da Cooperativa em operação
      rw_crapdatc btch0001.cr_crapdat%ROWTYPE;

      -- cursor para busca de cartões Bancoob por conta
      CURSOR cr_crapcrd (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_nrdconta IN crapcrd.nrdconta%TYPE) IS
      SELECT crd.cdadmcrd
            ,crd.nrcrcard
            ,crd.cdcooper
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper  AND
             crd.nrdconta = pr_nrdconta  AND
             (crd.cdadmcrd >= 10          AND
             crd.cdadmcrd <= 80)         AND
             crd.dtcancel IS NULL;
      rw_crapcrd cr_crapcrd%ROWTYPE;

      -- cursor para busca de proposta de cartões do bancoob por conta
      -- para verificar se é o primeiro cartão bancoob adquirido pela empresa
      -- excluindo a proposta de cartão sendo processada em si
      CURSOR cr_crawcrd_flgprcrd (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                  pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE,
                                  pr_nmbandei IN crapadc.nmbandei%TYPE) IS
        SELECT pcr.flgprcrd
          FROM crawcrd pcr
             , crapadc adc
         WHERE adc.cdcooper = pcr.cdcooper
           AND adc.cdadmcrd = pcr.cdadmcrd
           AND pcr.cdcooper =  pr_cdcooper
           AND pcr.nrdconta =  pr_nrdconta
           AND(pcr.cdadmcrd >= 10
           AND pcr.cdadmcrd <= 80)
           AND pcr.flgprcrd = 1
           AND pcr.nrctrcrd <> pr_nrctrcrd
           AND adc.nmbandei = pr_nmbandei;
      rw_crawcrd_flgprcrd cr_crawcrd_flgprcrd%ROWTYPE;
      
      -- cursor para busca de proposta de cartão aprovado e associado
      CURSOR cr_crawcrd (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT pcr.cdcooper
             , pcr.nrdconta
             , pcr.nrctrcrd
             , pcr.flgdebcc
             , pcr.tpdpagto
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.cdadmcrd
             , pcr.flgprcrd
             , pcr.nrcpftit
             , pcr.nmempcrd
             , pcr.nrcrcard
             , pcr.insitcrd
             , pcr.nmtitcrd
             , pcr.rowid
             , pcr.nrcctitg
             , pcr.cdgraupr
             , pcr.dtnasccr
             , pcr.flgdebit
             , ass.cdagenci
             , ass.nrempcrd
             , ass.inpessoa
             , ass.nrcpfcgc
             , age.cdagebcb
             , pcr.nrseqcrd
          FROM crawcrd pcr
              ,crapass ass
              ,crapage age
       WHERE pcr.cdcooper = pr_cdcooper  AND
             pcr.dtcancel IS NULL        AND
            (pcr.cdadmcrd >= 10          AND
             pcr.cdadmcrd <= 80)         AND
             pcr.insitcrd = 1            AND -- APROVADO
             ass.cdcooper = pcr.cdcooper AND
             ass.nrdconta = pcr.nrdconta AND
             ass.dtdemiss IS NULL        AND
             age.cdcooper = ass.cdcooper AND
             age.cdagenci = ass.cdagenci AND
             pcr.insitdec IN (2,3,8) /* Decisao esteira = 2 - Aprovado Auto, 3 - Aprovado Manual, 8 - Efetivada */
             -- Numero da conta utilizado para nao gerar linha de solicitacao de cartao adiciona quando eh 
             -- UPGRADE/DOWNGRADE, DEVE ficar como primeiro campo no ORDER BY (Douglas - Chamado 441407)             
             ORDER BY pcr.nrdconta   
                    , pcr.nrctrcrd;  -- Ordena por conta, para incluir no arquivo as contas agrupadas( Renato - Supero )
      
      -- cursor para busca de cartões ativos para verificação
      CURSOR cr_crapcrd_loop_alt (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT pcr.cdcooper
             , pcr.nrdconta
             , pcr.nrctrcrd
             , pcr.flgdebcc
             , pcr.tpdpagto
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.cdadmcrd
             , pcr.flgprcrd
             , pcr.nrcpftit
             , pcr.nmempcrd
             , pcr.nrcrcard
             , pcr.insitcrd
             , pcr.nmtitcrd
             , pcr.rowid
             , pcr.nrcctitg
             , pcr.cdgraupr
             , pcr.dtnasccr
             , pcr.flgdebit
             , ass.cdagenci
             , ass.nrempcrd
             , ass.inpessoa
             , ass.nrcpfcgc
             , age.cdagebcb
             , pcr.nrseqcrd
          FROM crawcrd pcr
              ,crapass ass
              ,crapage age
              ,crapcrd crd
         WHERE pcr.cdcooper = crd.cdcooper
           AND pcr.cdadmcrd = crd.cdadmcrd
           AND pcr.tpcartao = crd.tpcartao
           AND pcr.nrdconta = crd.nrdconta
           AND pcr.nrcrcard = crd.nrcrcard
           AND pcr.nrctrcrd = crd.nrctrcrd
           AND pcr.insitcrd IN (3,4) -- LIBERADOS E EM USO
           AND pcr.flgprcrd = 1 -- retorna apenas registro do cartao titular
           AND ass.cdcooper = pcr.cdcooper
           AND ass.nrdconta = pcr.nrdconta
           AND ass.dtdemiss IS NULL
           AND age.cdcooper = ass.cdcooper
           AND age.cdagenci = ass.cdagenci
           AND crd.dtcancel IS NULL
           AND crd.cdadmcrd BETWEEN 10 AND 80   -- somente o que foi BANCOOB ( MASTER )
           AND crd.cdcooper = pr_cdcooper
         ORDER BY pcr.nrctrcrd;
      --rw_crawcrd_loop_alt cr_crawcrd%ROWTYPE;

      
      -- cursor para cooperado PF
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                         pr_nrdconta IN crapttl.nrdconta%TYPE,
                         pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
      SELECT ttl.idseqttl
            ,ttl.nrcpfcgc
            ,ttl.vlsalari
            ,ttl.cdestcvl
            ,DECODE(ttl.cdsexotl,1,'2',2,'1','0') sexbancoob
            ,ttl.dtnasttl
            ,ttl.nrdocttl
            ,ttl.tpdocttl
            ,ttl.cdufdttl
            ,ttl.idorgexp
            ,ttl.nmextttl
            ,ttl.inpessoa
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper AND
             ttl.nrdconta = pr_nrdconta AND
             ttl.nrcpfcgc = pr_nrcpfcgc;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- cursor para cooperado PJ
      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE,
                         pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT jur.dtiniatv
            ,jur.nrinsest
            ,jur.nmextttl
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper AND
             jur.nrdconta = pr_nrdconta ;
      rw_crapjur cr_crapjur%ROWTYPE;

      -- cursor para encontrar dados de associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                         pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT ass.nmprimtl
            ,ass.tpdocptl
            ,ass.nrdocptl
            ,ass.idorgexp
            ,ass.cdufdptl
            ,ass.dtnasctl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper AND
             ass.nrcpfcgc = pr_nrcpfcgc ;
      rw_crapass cr_crapass%ROWTYPE;

      -- cursor para encontrar dados do avalista de PJ
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
                         pr_nrdconta IN crapavt.nrdconta%TYPE,
                         pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
      SELECT avt.nrdconta
            ,NVL(ttl.tpdocttl,avt.tpdocava) tpdocava
            ,NVL(ttl.nmextttl,avt.nmdavali) nmdavali
            ,NVL(ttl.cdestcvl,avt.cdestcvl) cdestcvl
            ,avt.nrcpfcgc
            ,NVL(ttl.nrdocttl,avt.nrdocava) nrdocava
            ,NVL(ttl.idorgexp,avt.idorgexp) idorgexp
            ,NVL(ttl.cdufdttl,avt.cdufddoc) cdufddoc
            ,NVL(ttl.dtnasttl,avt.dtnascto) dtnascto
            ,DECODE(NVL(ttl.cdsexotl,avt.cdsexcto),1,'2',2,'1','0') sexbancoob
            ,NVL(ttl.inpessoa,DECODE(avt.inpessoa,0,1,avt.inpessoa)) inpessoa
        FROM crapttl ttl
           , crapavt avt
       WHERE ttl.cdcooper(+) = avt.cdcooper
         AND ttl.nrdconta(+) = avt.nrdctato
         AND avt.tpctrato = 6 -- Contrato pessoa juridica
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrcpfcgc = pr_nrcpfcgc ;
      rw_crapavt cr_crapavt%ROWTYPE;

      -- cursor para adquirir informações da Administradora do Cartão de Crédito
      CURSOR cr_crapadc (pr_cdcooper IN crapadc.cdcooper%TYPE,
                         pr_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
      SELECT adc.nrctamae
            ,adc.cdclasse
            ,adc.nmbandei
        FROM crapadc adc
       WHERE adc.cdcooper = pr_cdcooper     AND
             adc.cdadmcrd = pr_cdadmcrd     ;
      rw_crapadc     cr_crapadc%ROWTYPE;
      rw_crapadc_crd cr_crapadc%ROWTYPE;

      -- cursor para Grupo de Afinidade
      CURSOR cr_crapacb (pr_cdcooper IN crapacb.cdcooper%TYPE,
                         pr_cdadmcrd IN crapacb.cdadmcrd%TYPE) IS
      SELECT acb.cdgrafin
        FROM crapacb acb
       WHERE acb.cdcooper = pr_cdcooper AND
             acb.cdadmcrd = pr_cdadmcrd ;
      rw_crapacb     cr_crapacb%ROWTYPE;

      -- cursor para adquirir telefones do cooperado
      CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE,
                         pr_nrdconta IN craptfc.nrdconta%TYPE,
                         pr_tptelefo IN craptfc.tptelefo%TYPE) IS
      SELECT tfc.nrtelefo
            ,tfc.nrdddtfc
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper     AND
             tfc.nrdconta = pr_nrdconta     AND
             tfc.tptelefo = pr_tptelefo;
      rw_craptfc cr_craptfc%ROWTYPE;

      -- cursor para endereco da agencia
			CURSOR cr_end_agencia(pr_cdcooper IN crapenc.cdcooper%TYPE
											     ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
				SELECT crapage.dsendcop
							,crapage.nrendere
							,crapage.dscomple
							,crapage.nmbairro
							,crapage.nmcidade
							,crapage.cdufdcop
							,crapage.cdagenci
							,crapage.idcidade
							,crapage.nrcepend
							,crapage.dsendcop||
							decode(crapage.nrendere,0,null,','||crapage.nrendere)||
							decode(crapage.dscomple, ' ', NULL, ','||crapage.dscomple) dsender_compl
					FROM crapage
				 WHERE crapage.cdcooper = pr_cdcooper
					 AND crapage.cdagenci = pr_cdagenci;
		  rw_end_agencia cr_end_agencia%ROWTYPE;			

      -- cursor para adquirir alterações da conta
      CURSOR cr_crapalt (pr_cdcooper IN crapalt.cdcooper%TYPE,
                         pr_nrdconta IN crapalt.nrdconta%TYPE,
                         pr_dtaltini IN crapalt.dtaltera%TYPE,
                         pr_dtaltfim IN crapalt.dtaltera%TYPE) IS
      SELECT alt.dsaltera,
             alt.dtaltera
        FROM crapalt alt
       WHERE alt.cdcooper = pr_cdcooper
         AND alt.nrdconta = pr_nrdconta
         AND alt.dtaltera BETWEEN pr_dtaltini AND pr_dtaltfim;
      rw_crapalt cr_crapalt%ROWTYPE;
      
      -- Cursor para buscar alterações de limite de crédito
      CURSOR cr_altlimit(pr_cdcooper IN tbcrd_limite_atualiza.cdcooper%TYPE
                        ,pr_nrdconta IN tbcrd_limite_atualiza.nrdconta%TYPE
                        ,pr_nrctacrd IN tbcrd_limite_atualiza.nrconta_cartao%TYPE) IS
        SELECT atu.vllimite_alterado   vllimite
             , ROWID                   dsdrowid
          FROM tbcrd_limite_atualiza atu
         WHERE atu.cdcooper       = pr_cdcooper
           AND atu.nrdconta       = pr_nrdconta
           AND atu.nrconta_cartao = pr_nrctacrd
           AND atu.tpsituacao     = 1      /* Pendente */
         ORDER BY atu.dtalteracao DESC;
        /*  O order by é para tratar caso exista mais registro de alteração para 
            a mesma conta. Não deveria acontecer, mas caso aconteça utilizaremos 
            a mais recente.   */
      rw_altlimit   cr_altlimit%ROWTYPE;
      
			CURSOR cr_endereco_entrega(pr_cdcooper IN tbcrd_endereco_entrega.cdcooper%TYPE,
                                 pr_nrdconta IN tbcrd_endereco_entrega.nrdconta%TYPE,
																 pr_nrctrcrd IN tbcrd_endereco_entrega.nrctrcrd%TYPE) IS
					SELECT tee.idtipoenvio
					      ,tee.cdagenci
					  FROM tbcrd_endereco_entrega tee
					 WHERE tee.cdcooper = pr_cdcooper
					   AND tee.nrdconta = pr_nrdconta
						 AND tee.nrctrcrd = pr_nrctrcrd;
			rw_endereco_entrega cr_endereco_entrega%ROWTYPE;
      
      -- cursor para adquirir endereço do cooperado
      CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%TYPE,
                         pr_nrdconta IN crapenc.nrdconta%TYPE,
                         pr_tpendass IN crapenc.tpendass%TYPE) IS
      SELECT enc.nrcepend
            ,enc.nmcidade
            ,enc.nmbairro
            ,enc.cdufende
            ,enc.dsendere
            ,decode(enc.nrendere,0,null,','||enc.nrendere) nrendere
						,enc.complend
            -- montar string com o endereço completo do associado
            ,enc.dsendere||
             decode(enc.nrendere,0,null,','||enc.nrendere)||
						 decode(enc.complend,' ',NULL,','||enc.complend) dsender_compl
            ,decode(nvl(trim(enc.cddbloco),'0'),'0',null,' bl-'||enc.cddbloco)||
             decode(nvl(trim(enc.nrdoapto),'0'),'0',null,' ap '||enc.nrdoapto) dsender_apbl

        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper     AND
             enc.nrdconta = pr_nrdconta     AND
             enc.tpendass = pr_tpendass;
      rw_crapenc cr_crapenc%ROWTYPE;

       -- Informações arquivo bancoob
      CURSOR cr_crapscb IS
        SELECT crapscb.dsdirarq
             , TRUNC(crapscb.dtultint) dtultint
          FROM crapscb
         WHERE crapscb.tparquiv = 3;
      rw_crapscb cr_crapscb%ROWTYPE;

      -- Buscar as informações da conta do titular para incluir no cartão do adicional
      CURSOR cr_nrctaitg(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                         pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
      SELECT c.nrcctitg
        FROM crapttl t, 
             crawcrd c, 
             crawcrd w
       WHERE w.nrcpftit = t.nrcpfcgc
         AND t.nrcpfcgc = c.nrcpftit
         AND t.idseqttl = 1 -- Titular
         AND t.nrdconta = c.nrdconta
         AND t.cdcooper = c.cdcooper
         AND c.cdadmcrd BETWEEN 10 AND 80
         AND c.cdadmcrd = w.cdadmcrd
         AND c.nrdconta = w.nrdconta
         AND c.cdcooper = w.cdcooper
         and c.insitcrd = w.insitcrd
         and c.flgprcrd = w.flgprcrd
         AND w.cdadmcrd = pr_cdadmcrd
         AND w.nrdconta = pr_nrdconta
         AND w.cdcooper = pr_cdcooper
         and w.nrcctitg > 0;
      rw_nrctaitg    cr_nrctaitg%ROWTYPE;

      -- Buscar as informações do primeiro cartão empresarial da conta
      CURSOR cr_nrctaitg_prcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                               pr_nrdconta IN crawcrd.nrdconta%TYPE,
                               pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
        SELECT w.nrcctitg
          FROM crawcrd  w
         WHERE w.cdadmcrd = pr_cdadmcrd
           AND w.nrdconta = pr_nrdconta
           AND w.cdcooper = pr_cdcooper
           AND w.flgprcrd = 1;

      ------------------------------- FUNCOES ---------------------------------
      FUNCTION fn_estado_civil_bancoob(pr_cdestcvl IN NUMBER) RETURN VARCHAR2 IS
        BEGIN
          DECLARE
          BEGIN
            CASE pr_cdestcvl
              WHEN 1 THEN RETURN '01'; /* Solteiro */
              WHEN 2 THEN RETURN '02'; /* Casado */
              WHEN 3 THEN RETURN '02'; /* Casado */
              WHEN 4 THEN RETURN '02'; /* Casado */
              WHEN 5 THEN RETURN '04'; /* Viuvo */
              WHEN 6 THEN RETURN '05'; /* Outros */
              WHEN 7 THEN RETURN '03'; /* Divorciado */
              WHEN 8 THEN RETURN '02'; /* Casado */
              ELSE        RETURN '00';
            END CASE;
           END;
      END fn_estado_civil_bancoob;

      ------------------------------ PROCEDURES --------------------------------
      PROCEDURE altera_sit_cartao_solicitado(rw_crawcrd  IN cr_crawcrd%ROWTYPE)IS

        BEGIN
        -- Limpar a variável de erros
        vr_dscritic := NULL;

        -- Atualiza registro de Proposta de Cartão de Crédito
          UPDATE crawcrd
             SET insitcrd = 2 -- Solicitado
               , nrseqcrd = rw_crawcrd.nrseqcrd
               , dtsolici = trunc(SYSDATE)
           WHERE ROWID = rw_crawcrd.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
      END altera_sit_cartao_solicitado;

      PROCEDURE gera_linha_registro_tipo1 (rw_crawcrd  IN OUT cr_crawcrd%ROWTYPE,
                                           rw_crapcol  IN cr_crapcol%ROWTYPE,
                                           rw_crapdat  IN btch0001.cr_crapdat%ROWTYPE,
                                           rw_crapadc  IN cr_crapadc%ROWTYPE,
                                           pr_nrctacrd IN VARCHAR2,
                                           pr_tipooper IN VARCHAR2,
                                           pr_inpessoa IN NUMBER,
                                           pr_nrctrcrd IN NUMBER,
                                           pr_canvenda IN VARCHAR2,
                                           pr_cdgrafin IN VARCHAR2,
                                           pr_flaltafn IN BOOLEAN DEFAULT FALSE,
                                           pr_flaltcep IN BOOLEAN DEFAULT FALSE,
                                           pr_flalttpe IN BOOLEAN DEFAULT FALSE,
                                           pr_flalttfc IN BOOLEAN DEFAULT FALSE,
                                           pr_vllimalt IN NUMBER  DEFAULT NULL) IS

          -- variáveis --
          vr_aux_cdgrafin  VARCHAR2( 7);
          vr_aux_canvenda  VARCHAR2( 8);
          vr_aux_tpendere  VARCHAR2( 1);
          vr_aux_dsendere  VARCHAR2(50);
          vr_aux_nmbairro  VARCHAR2(25);
          vr_aux_cdufende  VARCHAR2( 2);
          vr_aux_nmcidade  VARCHAR2(40);
          vr_aux_nrcepend  VARCHAR2( 8);
          vr_aux_dddebito  VARCHAR2( 2);
          vr_aux_vllimcrd  VARCHAR2( 9);
          vr_aux_dsendcom  VARCHAR2(50);
					vr_tpendass      crapenc.tpendass%TYPE;
					vr_cdagenci      tbcrd_endereco_entrega.cdagenci%TYPE := 0;
					
					-- variaveis de endereço
					vr_dsendere VARCHAR2(60) := '';
					vr_dsender_apbl VARCHAR2(200) := NULL;
					vr_dsender_compl VARCHAR2(200) := '';
					vr_nrendere VARCHAR2(20) := '';
					vr_ufendere VARCHAR2(5) := '';
					vr_nmcidade VARCHAR2(50) := '';
					vr_nmbairro VARCHAR2(50) := '';
					vr_nrcepend VARCHAR2(15) := '';
					vr_complend VARCHAR2(200) := '';

        BEGIN
          BEGIN
					  /*
						Validar se existe registro na tbcrd_endereco_entrega pelo rw_crawcrd.nrctrcrd
						Se não houver segue a vida c/ cr_crapenc
						Se houver, enviamos o endereço da crapenc com crapenc.tpendass baseado na tbcrd_endereco_entrega.idtipoenvio
						*/
						
						IF pr_inpessoa = 1 THEN
							vr_tpendass := 10;
						ELSIF pr_inpessoa = 2 THEN
							vr_tpendass := 9;
						END IF;
						--
						OPEN cr_endereco_entrega(pr_cdcooper => rw_crawcrd.cdcooper,
                                     pr_nrdconta => rw_crawcrd.nrdconta,
																		 pr_nrctrcrd => pr_nrctrcrd);
						FETCH cr_endereco_entrega INTO rw_endereco_entrega;
						--
						IF cr_endereco_entrega%FOUND THEN
							vr_tpendass := rw_endereco_entrega.idtipoenvio;
							IF vr_tpendass IN (90, 91) THEN
							   vr_cdagenci := nvl(rw_endereco_entrega.cdagenci, 0);
						END IF;
						END IF;
						--
						CLOSE cr_endereco_entrega;
						
						
						IF vr_cdagenci > 0 THEN
							-- Busca endereço do PA
							OPEN cr_end_agencia(pr_cdcooper => rw_crawcrd.cdcooper,
																	pr_cdagenci => vr_cdagenci);
							FETCH cr_end_agencia INTO rw_end_agencia;
							CLOSE cr_end_agencia;

							vr_dsender_compl := rw_end_agencia.dsender_compl;
							vr_ufendere := rw_end_agencia.cdufdcop;
							vr_nmcidade := rw_end_agencia.nmcidade;
							vr_nmbairro := rw_end_agencia.nmbairro;
							vr_nrcepend := rw_end_agencia.nrcepend;
							vr_complend := rw_end_agencia.dscomple;					
							
						ELSE

            -- Busca Endereço do Cooperado
            OPEN cr_crapenc(pr_cdcooper => rw_crawcrd.cdcooper,
                            pr_nrdconta => rw_crawcrd.nrdconta,
                            pr_tpendass => vr_tpendass);
            FETCH cr_crapenc INTO rw_crapenc;

            -- Se nao encontrar Endereço
            IF cr_crapenc%NOTFOUND THEN

              -- Fechar o cursor pois efetuaremos raise
              CLOSE cr_crapenc;
              -- Montar mensagem de critica
              vr_dscritic := 'Endereco nao encontrado. '                     ||
                             'Cooperativa: ' || TO_CHAR(rw_crawcrd.cdcooper) ||
                             ' Conta: ' || TO_CHAR(rw_crawcrd.nrdconta)      || '.';
              RAISE vr_exc_loop_detalhe;
            ELSE
              -- Apenas fechar o cursor
              CLOSE cr_crapenc;
								
								vr_dsender_apbl := rw_crapenc.dsender_apbl;
								vr_dsender_compl := rw_crapenc.dsender_compl;
								vr_dsendere := rw_crapenc.dsendere;
								vr_nrendere := rw_crapenc.nrendere; 
								vr_ufendere := rw_crapenc.cdufende;
								vr_nmcidade := rw_crapenc.nmcidade;
								vr_nmbairro := rw_crapenc.nmbairro;
								vr_nrcepend := rw_crapenc.nrcepend;
								vr_complend := rw_crapenc.complend;
								
            END IF;
						
						END IF;


       -- VERIFICAR QUANTOS CARACTERES SERÃO DESTINADOS AO ENDEREÇO SD204641
            IF vr_dsender_apbl IS NULL THEN
              --USA OS 50 CARACTERES PARA O ENDEREÇO
              vr_aux_dsendcom := rpad(substr(nvl(vr_dsender_compl,' '),1,50),50,' ');
            ELSE
              -- SEPARA 30 CARACTERES PARA ENDEREÇO E 20 PARA COMPLEMENTO
              vr_aux_dsendcom := rpad(nvl((TRIM(substr(nvl(vr_dsendere,' '),1,24)) || 
                                           TRIM(substr(nvl(vr_nrendere,' '),1,6)||
																					 substr(nvl(vr_complend, ' '),1,10)||
                                           substr(nvl(vr_dsender_apbl,' '),1,10))),' '),50,' ');
            END IF;

      -- Gerar código sequencial de controle para o contrato (Renato-Supero)
            -- Se o nrseqcrd é null ou zero
            IF NVL(rw_crawcrd.nrseqcrd,0) = 0 THEN
              -- Buscar o próximo número da sequencia
              rw_crawcrd.nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(rw_crawcrd.cdcooper);
            END IF;

            -- Limpar as informações de telefone   ( Renato - Supero - SD 196220 )
            vr_dstelres := NULL;
            vr_dddresid := NULL;
            vr_dstelcel := NULL;
            vr_dddcelul := NULL;
            vr_dstelcom := NULL;
            vr_dddcomer := NULL;

            -- Se a operação não for de alteração
            IF pr_tipooper <> 2 THEN

              -- Busca Telefone Residencial do Cooperado
              OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                              pr_nrdconta => rw_crawcrd.nrdconta,
                              pr_tptelefo => 1 /* Residencial */);
              FETCH cr_craptfc INTO rw_craptfc;

              -- Se encontrar Telefone Residencial
              IF cr_craptfc%FOUND THEN
                vr_dstelres := rw_craptfc.nrtelefo;
                vr_dddresid := rw_craptfc.nrdddtfc;
              END IF;

              -- fechar o cursor
              CLOSE cr_craptfc;

              -- Busca Telefone Celular do Cooperado
              OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                              pr_nrdconta => rw_crawcrd.nrdconta,
                              pr_tptelefo => 2 /* Celular */);
              FETCH cr_craptfc INTO rw_craptfc;

              -- Se encontrar Telefone Celular
              IF cr_craptfc%FOUND THEN
                vr_dstelcel := rw_craptfc.nrtelefo;
                vr_dddcelul := rw_craptfc.nrdddtfc;
              END IF;

              -- fechar o cursor
              CLOSE cr_craptfc;

              -- Busca Telefone Comercial do Cooperado
              OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                              pr_nrdconta => rw_crawcrd.nrdconta,
                              pr_tptelefo => 3 /* Comercial */);
              FETCH cr_craptfc INTO rw_craptfc;

              -- Se encontrar Comercial Celular
              IF cr_craptfc%FOUND THEN
                vr_dstelcom := rw_craptfc.nrtelefo;
                vr_dddcomer := rw_craptfc.nrdddtfc;
              END IF;

              -- fechar o cursor
              CLOSE cr_craptfc;

              -- Tp. Conta Debt.
              IF rw_crawcrd.flgdebcc = 0 THEN
                vr_tpcntdeb := '0';  /* Não Debita */
              ELSE
                vr_tpcntdeb := '1';  /* Debita C/C */
              END IF;

              -- Regra para quando o campo crawcrd.tpdpagto = 3 enviar "000".
              vr_tpdpagto := 0;

              IF rw_crawcrd.tpdpagto <> 3 THEN
                vr_tpdpagto := rw_crawcrd.tpdpagto;
              END IF;

              -- monta registro de DETALHE (Tipo 1)
              vr_dsdettp1 := ('CCB3'                                  /* Pedido */                                                   ||
                              '01'                                    /* Dados Conta Cartão (Tipo 1 ) */                             ||
                              pr_tipooper                             /* Tp. Operac.                  */                             ||
                              lpad(rw_crawcrd.nrseqcrd,8,'0')         /* Nrd. Operac.                 */                             ||
                              TO_CHAR(vr_dtmvtolt,'DDMMYYYY')                                                                ||
                              rpad(pr_nrctacrd,13,'0')                /* Nr. Conta Cart.              */                             ||
                              lpad(nvl(rw_crawcrd.nrempcrd,0),4,'0')  /* Nr. da Empresa               */                             ||
                              lpad(nvl(pr_cdgrafin,0),7,'0')          /* Nr. Grupo de Afinidade       */                             ||
                              lpad(nvl(rw_crapadc.nrctamae,0),6,'0')  /* BIN                          */                             ||
                              lpad(nvl(rw_crapadc.cdclasse,0),2,'0')  /* Classe de Cartão             */                             ||
                              '  '                                    /* Uso Futuro                   */                             ||
                              '1'                                     /* Tp. Endere. - Residencial    */                             ||
                              vr_aux_dsendcom                /* Endereço Completo            */                             ||
                              rpad(nvl(vr_ufendere,' '),2,' ' )        /* UF                           */                             ||
                              rpad(nvl(vr_nmcidade,' '),40,' ')        /* Cidade                       */                             ||
                              rpad(nvl(vr_nmbairro,' '),25,' ')        /* Bairro                       */                             ||
                              lpad(nvl(vr_nrcepend,'0'),8,'0' )        /* CEP                          */                             ||
                              lpad(NVL(vr_dstelres,'0'),9,'0' )       /* Telefone Residencial         */                             ||
                              ' '                                     /* Uso Futuro                   */                             ||
                              ' '                                     /* Uso Futuro                   */                             ||
                              '  '                                    /* Uso Futuro                   */                             ||
                              vr_tpcntdeb                             /* Tp. Conta Deb.               */                             ||
                              '756'                                   /* Banco da Conta Debitar       */                             ||
                              lpad(nvl(rw_crapcol.cdagebcb,'0'),4,'0' )        /* Agencia da Conta Debitar     */                             ||
                              lpad(nvl(rw_crawcrd.nrdconta,'0'),12,'0')        /* Nr. Conta a Debitar          */                             ||
                              lpad(vr_tpdpagto,3,'0' )                /* Porc. Deb. Autom             */                             ||
                              lpad(nvl(rw_crawcrd.nrdconta,'0'),8,'0' )        /* Nr. Conta Socio              */                             ||
                              lpad('0',12,'0')                        /* Renda Titular                */                             ||
                              '  '                                    /* Uso Futuro                   */                             ||
                              lpad(nvl(rw_crawcrd.dddebito,0),2,'0')  /* Venc. Validos do Emiss.     */                             ||
                              lpad('0',5,'0')                         /* Bonificação                  */                             ||
                              lpad(nvl(rw_crawcrd.vllimcrd,0),9,'0')  /* Vl. Limite                   */                             ||
                              '         '                             /* Uso Futuro                   */                             ||
                              '0'                                     /* Qtd. cartões                 */                             ||
                              '1'                                     /* Gerar Nv. Cartão             */                             ||
                              '0'                                     /* Orig. de Anulação            */                             ||
                              ' '                                     /* Uso Futuro                   */                             ||
                              '0'                                     /* Indicador de Mud. Estadoq    */                             ||
                              '00'                                    /* Situação da Conta            */                             ||
                              '000'                                   /* Cod. Rejeição                */                             ||
                              lpad('0',8,'0')                         /* Promoção                     */                             ||
                              lpad(nvl(pr_canvenda,' '), 8,' ')                /* Canal de Vendas              */                             ||
                              lpad(' ',8,' ')                         /* Vendedor                     */                             ||
                              '0'                                     /* Cliente Normal               */                             ||
                              '0'                                     /* Entrega Normal               */                             ||
                              'N'                                     /* Não é retorno                */                             ||
                              lpad(nvl(vr_dddresid,'0'),3,0)          /* DDD Residencial              */                             ||
                              lpad(nvl(vr_dddcomer,'0'),3,0)          /* DDD Comercial                */                             ||
                              lpad(nvl(vr_dstelcom,'0'),9,0)          /* Telefone Comercial           */                             ||
                              lpad(nvl(vr_dddcelul,'0'),3,0)          /* DDD Celular                  */                             ||
                              lpad(nvl(vr_dstelcel,'0'),9,0)          /* Telefone Celular             */                             ||
                              lpad('0',12,'0')                        /* Patrimônio Titular           */                             ||
                              '       '                               /* Uso Futuro                   */                             );

            ELSE

              -- No momento os telefones serão enviados sempre nulos, devido
              -- à incapacidade do sistema de verificar quais informações
              -- sofreram alterações.
              vr_dstelres := '_________';
              vr_dddresid := '___';
              vr_dstelcel := '_________';
              vr_dddcelul := '___';
              vr_dstelcom := '_________';
              vr_dddcomer := '___';

              -- Dia de vencimento e limite também não sofrerão envio de informações no momento
              vr_aux_dddebito := '__';
              
              -- Verificar se há novo limite de crédito proposto
              IF pr_vllimalt IS NOT NULL THEN
                vr_aux_vllimcrd := lpad(pr_vllimalt,9,'0');
              ELSE
                vr_aux_vllimcrd := '_________';
              END IF;

              -- Verifica se deve enviar a informação de grupo de afinidade e canal de vendas
              IF pr_flaltafn THEN
                vr_aux_cdgrafin := lpad(nvl(pr_cdgrafin,0),7,'0');
                vr_aux_canvenda := lpad(pr_canvenda, 8,' ');
              ELSE
                vr_aux_cdgrafin := LPAD('_',7,'_');
                vr_aux_canvenda := LPAD('_',8,'_');
              END IF;

              -- Se alterou o endereço: bairro ou rua
              IF pr_flalttpe THEN
                vr_aux_tpendere := '1';
                vr_aux_dsendere := vr_aux_dsendcom;
                vr_aux_nmbairro := rpad(vr_nmbairro,25,' ');
              ELSE
                vr_aux_tpendere := '_';
                vr_aux_dsendere := LPAD('_',50,'_');
                vr_aux_nmbairro := LPAD('_',25,'_');
              END IF;

              -- Se alterou o cep, estado ou cidade
              IF pr_flaltcep THEN
                vr_aux_cdufende := rpad(vr_ufendere, 2,' ');
                vr_aux_nmcidade := rpad(vr_nmcidade,40,' ');
                vr_aux_nrcepend := lpad(vr_nrcepend, 8,'0');
              ELSE
                vr_aux_cdufende := '__';
                vr_aux_nmcidade := LPAD('_',40,'_');
                vr_aux_nrcepend := LPAD('_',8,'_');
              END IF;

              -- Tratar alteração de telefone
              IF pr_flalttfc THEN
                -- Busca Telefone Residencial do Cooperado
                OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                                pr_nrdconta => rw_crawcrd.nrdconta,
                                pr_tptelefo => 1 /* Residencial */);
                FETCH cr_craptfc INTO rw_craptfc;

                -- Se encontrar Telefone Residencial
                IF cr_craptfc%FOUND THEN
                  vr_dstelres := rw_craptfc.nrtelefo;
                  vr_dddresid := rw_craptfc.nrdddtfc;
                END IF;

                -- fechar o cursor
                CLOSE cr_craptfc;

                -- Busca Telefone Celular do Cooperado
                OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                                pr_nrdconta => rw_crawcrd.nrdconta,
                                pr_tptelefo => 2 /* Celular */);
                FETCH cr_craptfc INTO rw_craptfc;

                -- Se encontrar Telefone Celular
                IF cr_craptfc%FOUND THEN
                  vr_dstelcel := rw_craptfc.nrtelefo;
                  vr_dddcelul := rw_craptfc.nrdddtfc;
                END IF;

                -- fechar o cursor
                CLOSE cr_craptfc;

                -- Busca Telefone Comercial do Cooperado
                OPEN cr_craptfc(pr_cdcooper => rw_crawcrd.cdcooper,
                                pr_nrdconta => rw_crawcrd.nrdconta,
                                pr_tptelefo => 3 /* Comercial */);
                FETCH cr_craptfc INTO rw_craptfc;

                -- Se encontrar Comercial Celular
                IF cr_craptfc%FOUND THEN
                  vr_dstelcom := rw_craptfc.nrtelefo;
                  vr_dddcomer := rw_craptfc.nrdddtfc;
                END IF;

                -- fechar o cursor
                CLOSE cr_craptfc;
              END IF;

              -- monta registro de DETALHE (Tipo 1)
              vr_dsdettp1 := ('CCB3'                                  /* Pedido */                                                   ||
                              '01'                                    /* Dados Conta Cartão (Tipo 1 ) */                             ||
                              pr_tipooper                             /* Tp. Operac.                  */                             ||
                              lpad(rw_crawcrd.nrseqcrd,8,'0')         /* Nrd. Operac.                 */                             ||
                              TO_CHAR(vr_dtmvtolt,'DDMMYYYY') /* Data da operação             */                             ||
                              rpad(pr_nrctacrd,13,'0')                /* Nr. Conta Cart.              */                             ||
                              '____'                                  /* Nr. da Empresa               */                             ||
                              vr_aux_cdgrafin                         /* Nr. Grupo de Afinidade       */                             ||
                              '______'                                /* BIN                          */                             ||
                              '__'                                    /* Classe de Cartão             */                             ||
                              '  '                                    /* Uso Futuro                   */                             ||
                              vr_aux_tpendere                         /* Tp. Endere. - Residencial    */                             ||
                              vr_aux_dsendere                         /* Endereço Completo            */                             ||
                              vr_aux_cdufende                         /* UF                           */                             ||
                              vr_aux_nmcidade                         /* Cidade                       */                             ||
                              vr_aux_nmbairro                         /* Bairro                       */                             ||
                              vr_aux_nrcepend                         /* CEP                          */                             ||
                              lpad(NVL(vr_dstelres,'0'),9,'0' )       /* Telefone Residencial         */                             ||
                              ' '                                     /* Uso Futuro                   */                             ||
                              ' '                                     /* Uso Futuro                   */                             ||
                              '  '                                    /* Uso Futuro                   */                             ||
                              '_'                                     /* Tp. Conta Deb.               */                             ||
                              '___'                                   /* Banco da Conta Debitar       */                             ||
                              '____'                                  /* Agencia da Conta Debitar     */                             ||
                              '____________'                          /* Nr. Conta a Debitar          */                             ||
                              '___'                                   /* Porc. Deb. Autom             */                             ||
                              '________'                              /* Nr. Conta Socio              */                             ||
                              '____________'                          /* Renda Titular                */                             ||
                              '  '                                    /* Uso Futuro                   */                             ||
                              vr_aux_dddebito                         /* Venc. Validos do Emiss.     */                              ||
                              '_____'                                 /* Bonificação                  */                             ||
                              vr_aux_vllimcrd                         /* Vl. Limite                   */                             ||
                              '         '                             /* Uso Futuro                   */                             ||
                              '_'                                     /* Qtd. cartões                 */                             ||
                              '_'                                     /* Gerar Nv. Cartão             */                             ||
                              '_'                                     /* Orig. de Anulação            */                             ||
                              ' '                                     /* Uso Futuro                   */                             ||
                              '_'                                     /* Indicador de Mud. Estadoq    */                             ||
                              '__'                                    /* Situação da Conta            */                             ||
                              '___'                                   /* Cod. Rejeição                */                             ||
                              lpad('_',8,'_')                         /* Promoção                     */                             ||
                              vr_aux_canvenda                         /* Canal de Vendas              */                             ||
                              lpad('_',8,'_')                         /* Vendedor                     */                             ||
                              '_'                                     /* Cliente Normal               */                             ||
                              '_'                                     /* Entrega Normal               */                             ||
                              '_'                                     /* Não é retorno                */                             ||
                              lpad(nvl(vr_dddresid,'0'),3,0)          /* DDD Residencial              */                             ||
                              lpad(nvl(vr_dddcomer,'0'),3,0)          /* DDD Comercial                */                             ||
                              lpad(nvl(vr_dstelcom,'0'),9,0)          /* Telefone Comercial           */                             ||
                              lpad(nvl(vr_dddcelul,'0'),3,0)          /* DDD Celular                  */                             ||
                              lpad(nvl(vr_dstelcel,'0'),9,0)          /* Telefone Celular             */                             ||
                              lpad('_',12,'_')                        /* Patrimônio Titular           */                             ||
                              '       '                               /* Uso Futuro                   */                             );

            END IF;
            -- grava registro de DETALHE Tipo 1 no arquivo
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsdettp1);

            -- incremente contador de Linhas Tipo 1
            vr_conttip1 := vr_conttip1 + 1;

           END;
      END gera_linha_registro_tipo1;

      PROCEDURE gera_linha_registro_tipo2 (rw_crawcrd  IN OUT cr_crawcrd%ROWTYPE,
                                           rw_crapcol  IN cr_crapcol%ROWTYPE,
                                           rw_crapdat  IN btch0001.cr_crapdat%ROWTYPE,
                                           pr_tipooper IN VARCHAR2,
                                           pr_nrctacrd IN VARCHAR2,
                                           pr_nmextttl IN VARCHAR2,
                                           pc_nmtitcrd IN VARCHAR2,
                                           pr_dtnasttl IN VARCHAR2,
                                           pr_dssexotl IN VARCHAR2,
                                           pr_cdestcvl IN VARCHAR2,
                                           pr_nrcpfcgc IN VARCHAR2,
                                           pr_titulari IN VARCHAR2,
                                           pr_nrdocttl IN VARCHAR2,
                                           pr_idorgexp IN INTEGER,
                                           pr_cdufdttl IN VARCHAR2,
                                           pr_inpessoa IN crapass.inpessoa%TYPE) IS
        BEGIN
          DECLARE

            vr_inpessoa VARCHAR2(2);
            vr_dscpfcgc VARCHAR2(20);
            vr_cdbcobcb NUMBER(10);
            vr_cdagebcb crapcop.cdagebcb%TYPE;
            vr_nrdconta crapass.nrdconta%TYPE;
            vr_cdorgexp VARCHAR2(200);
            vr_nmorgexp VARCHAR2(200);

          BEGIN

            IF pr_inpessoa = 1 THEN
              vr_inpessoa := '01';
              vr_dscpfcgc := LPAD(pr_nrcpfcgc,11,'0');
            ELSE
              vr_inpessoa := '03';
              vr_dscpfcgc := LPAD(pr_nrcpfcgc,14,'0');
            END IF;

            -- Gerar código sequencial de controle para o contrato (Renato-Supero)
            -- Se o nrseqcrd é null ou zero
            IF NVL(rw_crawcrd.nrseqcrd,0) = 0 THEN
              -- Buscar o próximo número da sequencia
              rw_crawcrd.nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(rw_crawcrd.cdcooper);
            END IF;
            
            -- Cartao for Representantes "OUROS" ou for somente credito
            IF rw_crawcrd.cdgraupr = 9 OR rw_crawcrd.flgdebit = 0 THEN
              vr_cdbcobcb := '000';
              vr_cdagebcb := 0;
              vr_nrdconta := 0;
              
            ELSE                            
              vr_cdbcobcb := '756';
              vr_cdagebcb := rw_crapcol.cdagebcb;
              vr_nrdconta := rw_crawcrd.nrdconta;
            
            END IF;

            --> Buscar orgão expedidor
            vr_cdorgexp := NULL;
            vr_nmorgexp := NULL; 
            IF nvl(pr_idorgexp,0) > 0 THEN
              cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => pr_idorgexp, 
                                                pr_cdorgao_expedidor => vr_cdorgexp, 
                                                pr_nmorgao_expedidor => vr_nmorgexp, 
                                                pr_cdcritic          => vr_cdcritic, 
                                                pr_dscritic          => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR 
                 TRIM(vr_dscritic) IS NOT NULL THEN
                vr_cdorgexp := NULL;
                vr_nmorgexp := NULL; 
            END IF;
            END IF;


            -- monta registro de DETALHE (Tipo 2)
            vr_dsdettp2 := ('CCB3'                           /* Pedido */                                                  ||
                            '02'                             /* Dados do Cartão                    */                      ||
                            pr_tipooper                      /* Tp. Operac.                        */                      ||
                            lpad(rw_crawcrd.nrseqcrd,8,'0')  /* Nrd. Operac.                       */                      ||
                            TO_CHAR(vr_dtmvtolt,'DDMMYYYY')                                                        ||
                            rpad(pr_nrctacrd,13,'0')         /* Nr. Conta Cart.                    */                      ||
                            rpad('0',19,'0')                 /* Número do Cartão (Nao Informar)    */                      ||
                            rpad(pc_nmtitcrd,23,' ')         /* Nome Embossado no Cartão           */                      ||
                            lpad(nvl(pr_dtnasttl,'0'),8,'0') /* Data Nasc                          */                      ||
                            pr_dssexotl                      /* Sexo                               */                      ||
                            pr_cdestcvl                      /* Estado Civil                       */                      ||
                            '00'                             /* Componente do Cartão               */                      ||
                            vr_inpessoa                      /* CPF                                */                      ||
                            rpad(nvl(vr_dscpfcgc,' '),15,' ') /* Nrd. CPF Titular                  */                      ||
                            '1'                              /* Gera Novo Cartão                   */                      ||
                            '0'                              /* Origem do Cancelamento             */                      ||
                            '0'                              /* Ind. Mud. Estado                   */                      ||
                            pr_titulari                      /* Titularidade                       */                      ||
                            '00'                             /* Sit. Cartão                        */                      ||
                            lpad(' ',95,' ')                 /* Filler                             */                      ||
                            '000'                            /* Cod. Rejeição                      */                      ||
                            lpad(' ',16,' ')                 /* PIN                                */                      ||
                            lpad(nvl(pr_nrdocttl,' '),15,' ') /* Identidade RG                     */                      ||
                            lpad(substr(nvl(vr_cdorgexp,' '),1,3), 3, ' ') /* Orgão Emissor        */                      ||
                            lpad(nvl(pr_cdufdttl,' '),2,' ')  /* UF Emissora                       */                      ||
                            rpad(nvl(pr_nmextttl,' '),80,' ') /* Nome Completo da Identidade       */                      ||
                            LPAD(vr_cdbcobcb,3,'0')          /* Banco da Conta Vinculada           */                      ||
                            lpad(vr_cdagebcb,4,'0' )         /* Agencia da Conta Vinculada         */                      ||
                            lpad(vr_nrdconta,12,'0')         /* Nr. Conta Vinculada                */                      ||
                            'N'                              /* Retorno de Evento Interno          */                      );
                            
            -- grava registro de DETALHE Tipo 2 no arquivo
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsdettp2);

            -- incremente contador de Linhas Tipo 2
            vr_conttip2 := vr_conttip2 + 1;

           END;
      END gera_linha_registro_tipo2;

      BEGIN
        -- extrai dados do XML (para uso Ayllos WEB)
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_saida;
        END IF;
            
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop (pr_cdcooper => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;

        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;

        -- Leitura do calendario da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;

        -- Se nao encontrar
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

        -- Verificar se cooperativa esta no processo ainda
        if rw_crapdat.inproces > 1 AND 
           trunc(sysdate) > rw_crapdat.dtmvtolt THEN
           vr_dtmvtolt := rw_crapdat.dtmvtopr;
           vr_dtmvtoan := rw_crapdat.dtmvtolt;
        ELSE
           vr_dtmvtolt := rw_crapdat.dtmvtolt;
           vr_dtmvtoan := rw_crapdat.dtmvtoan;
        END IF;

        -- Busca sequencial do arquivo
        CCRD0003.pc_ult_seq_arq(pr_tparquiv => 3
                               ,pr_nrseqinc => TRUE
                               ,pr_nrseqarq => vr_nrseqarq
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
        -- Se a variavel nao for 0
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          RAISE vr_exc_saida;
        END IF;

        -- buscar informações do arquivo a ser processado
        OPEN cr_crapscb;
        FETCH cr_crapscb INTO rw_crapscb;
        IF cr_crapscb%NOTFOUND  THEN
          vr_dscritic := 'Registro crapscb não encontrado!';
          CLOSE cr_crapscb;
           --levantar excecao
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapscb;

        -- buscar caminho de arquivos do Bancoob/CABAL
        vr_dsdireto := rw_crapscb.dsdirarq;
        vr_dtultenv := NVL(rw_crapscb.dtultint, vr_dtmvtoan);

        -- buscar caminho de arquivos do Bancoob/CABAL
        vr_direto_connect := vr_dsdireto;

        -- monta nome do arquivo
        vr_nmrquivo := 'CCB3756' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '_' || lpad(vr_nrseqarq,7,0) || '.CCB';

        -- criar handle de arquivo de Saldo Disponível dos Associados
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect  --> Diretorio do arquivo
                                ,pr_nmarquiv => 'TMP_'||vr_nmrquivo        --> Nome do arquivo
                                ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                                ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);      --> erro
        -- em caso de crítica
        IF vr_dscritic IS NOT NULL THEN
          -- levantar excecao
          RAISE vr_exc_saida;
        END IF;

        -- monta HEADER do arquivo
        vr_dsheader := 'CCB3'                                       ||
                       '00'                                         ||
                       '0756'                                       ||
                       TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0'))     ||
                       lpad(vr_nrseqarq,7,0)                        ||
                       TO_CHAR(vr_dtmvtolt,'DDMMYYYY')      ||
                       '1'                                          ||
                       lpad('0',70,'0');

        -- escrever HEADER do arquivo
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsheader);
        
        -- Executa LOOP para cada Cooperativa
        FOR rw_crapcol IN cr_crapcol LOOP

          -- Leitura do calendario da cooperativa do LOOP
          OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcol.cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdatc;

          -- Se nao encontrar
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

          -- Processar alterações de dados dos Cooperados que possuem Cartão de Crédito
          FOR rw_crapcrd_loop_alt IN cr_crapcrd_loop_alt(rw_crapcol.cdcooper) LOOP
            BEGIN  
             /*OPEN cr_crawcrd_loop_alt (pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                                      pr_cdadmcrd => rw_crapcrd_loop_alt.cdadmcrd,
                                      pr_tpcartao => rw_crapcrd_loop_alt.tpcartao,
                                      pr_nrdconta => rw_crapcrd_loop_alt.nrdconta,
                                      pr_nrcrcard => rw_crapcrd_loop_alt.nrcrcard,
                                      pr_nrctrcrd => rw_crapcrd_loop_alt.nrctrcrd);
            FETCH cr_crawcrd_loop_alt INTO rw_crawcrd_loop_alt;

            IF cr_crawcrd_loop_alt%NOTFOUND THEN

              CLOSE cr_crawcrd_loop_alt;
              CONTINUE;
            END IF;

            CLOSE cr_crawcrd_loop_alt;*/

            -- Só Permitir Operação 2 quando cartão já emitido SD 179666
            /*IF rw_crawcrd_loop_alt.insitcrd IN (0,1,2) THEN
              CONTINUE;
            END IF;*/     -- Código desnecessário, pois o select já filtra por INSITCRD = 3 OU 4
            
            -- Importante limpar os registros, para evitar dados inválidos
            rw_crapalt  := NULL;
            rw_altlimit := NULL;
            
            -- Busca alterações, após processar todas as inclusões
            OPEN cr_crapalt(pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                            pr_nrdconta => rw_crapcrd_loop_alt.nrdconta,
                            pr_dtaltini => vr_dtultenv,   -- Desde a data do ultimo envio do arquivo
                            pr_dtaltfim => vr_dtmvtoan);
            FETCH cr_crapalt INTO rw_crapalt;
            
            -- Busca alterações de limite ainda pendentes de processamento
            OPEN  cr_altlimit(rw_crapcrd_loop_alt.cdcooper    -- pr_cdcooper
                             ,rw_crapcrd_loop_alt.nrdconta    -- pr_nrdconta
                             ,rw_crapcrd_loop_alt.nrcctitg);  -- pr_nrctacrd
            FETCH cr_altlimit INTO rw_altlimit;
            
            -- Se encontrar registro de alteração ou alteração de limite
            IF cr_crapalt%FOUND OR cr_altlimit%FOUND THEN
              
              -- Setar as variáveis de controle para FALSE
              vr_flaltafn := FALSE;
              vr_flalttpe := FALSE;
              vr_flaltcep := FALSE;
              vr_flalttfc := FALSE;  
              
              -- Busca Administradora de Cartões
              OPEN cr_crapadc(pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                              pr_cdadmcrd => rw_crapcrd_loop_alt.cdadmcrd);
              FETCH cr_crapadc INTO rw_crapadc;

              -- Se nao encontrar
              IF cr_crapadc%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapadc;
                CLOSE cr_crapalt;            
                CLOSE cr_altlimit;
                -- Montar mensagem de critica
                vr_cdcritic := 605;
                RAISE vr_exc_saida;
              ELSE
                -- fechar o cursor
                CLOSE cr_crapadc;
              END IF;

              -- Busca Grupo de Afinidade
              OPEN cr_crapacb(pr_cdcooper => rw_crapcrd_loop_alt.cdcooper,
                              pr_cdadmcrd => rw_crapcrd_loop_alt.cdadmcrd);
              FETCH cr_crapacb INTO rw_crapacb;

              -- Se nao encontrar
              IF cr_crapacb%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapacb;
                CLOSE cr_crapalt;            
                CLOSE cr_altlimit;
                -- Montar mensagem de critica
                vr_dscritic := 'Grupo de Afinidade nao encontrado para administradora ' ||
                               to_char(rw_crapcrd_loop_alt.cdadmcrd) || '.';
                RAISE vr_exc_saida;
              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_crapacb;
              END IF;
              
              /*
                IF comentado por não haver mais a necessidade do mesmo. Foi incluso
                o tratamento antes da chamada da rotina gera_linha_registro_tipo1, dessa
                forma não é necessário buscar alterações antes.   ( Renato Darosci - Prj360 )
                
              -- procura por alteração de Endereço PF
              IF upper(rw_crapalt.dsaltera) LIKE '%END.RES. 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%ENDERECO 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%NRO.END. 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%NR.END. 1.TTL%'    OR
                 upper(rw_crapalt.dsaltera) LIKE '%COMPLEM. 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%COMPL.END. 1.TTL%' OR
                 upper(rw_crapalt.dsaltera) LIKE '%APTO. 1.TTL%'      OR
                 upper(rw_crapalt.dsaltera) LIKE '%CEP 1.TTL%'        OR
                 upper(rw_crapalt.dsaltera) LIKE '%BAIRRO 1.TTL%'     OR
                 upper(rw_crapalt.dsaltera) LIKE '%CIDADE 1.TTL%'     OR
                 upper(rw_crapalt.dsaltera) LIKE '%UF 1.TTL%'         OR
                 upper(rw_crapalt.dsaltera) LIKE '%END.RES.,%'        OR
                 upper(rw_crapalt.dsaltera) LIKE '%BAIRRO,%'          OR
                 upper(rw_crapalt.dsaltera) LIKE '%CIDADE,%'          OR
                 upper(rw_crapalt.dsaltera) LIKE '%UF,%'              OR
                 upper(rw_crapalt.dsaltera) LIKE '%CEP,%'             OR
              -- procura por alteracao de endereco PJ
                 upper(rw_crapalt.dsaltera) LIKE '%END.RES. COM.,%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%NR.END. COM.,%'    OR
                 upper(rw_crapalt.dsaltera) LIKE '%COMPLEM. COM.,%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%CEP COM.,%'        OR
                 upper(rw_crapalt.dsaltera) LIKE '%BAIRRO COM.,%'     OR
                 upper(rw_crapalt.dsaltera) LIKE '%CIDADE COM.,%'     OR
                 upper(rw_crapalt.dsaltera) LIKE '%UF COM.,%'         OR
              -- procura por alteração de PAC
              -- a alteracao de PA deve ser a primeira, 
              -- ou separado por virgula
                 upper(rw_crapalt.dsaltera) LIKE 'PAC %'              OR
                 upper(rw_crapalt.dsaltera) LIKE 'PA %'               OR
                 upper(rw_crapalt.dsaltera) LIKE '%,PAC %'            OR
                 upper(rw_crapalt.dsaltera) LIKE '%,PA %'             OR
                 upper(rw_crapalt.dsaltera) LIKE '%, PAC %'           OR
                 upper(rw_crapalt.dsaltera) LIKE '%, PA %'            OR
                 -- procura por alteração de telefone
                 upper(rw_crapalt.dsaltera) LIKE '%TELEF.%'
              THEN*/

              -- Verificar se houve alteração no grupo de afinidade - por PA
              -- a alteracao de PA deve ser a primeira, ou separado por virgula
              IF upper(rw_crapalt.dsaltera) LIKE 'PAC %'             OR
                 upper(rw_crapalt.dsaltera) LIKE 'PA %'              OR
                 upper(rw_crapalt.dsaltera) LIKE '%,PAC %'           OR
                 upper(rw_crapalt.dsaltera) LIKE '%,PA %'            OR
                 upper(rw_crapalt.dsaltera) LIKE '%, PAC %'          OR
                 upper(rw_crapalt.dsaltera) LIKE '%, PA %'           THEN
                vr_flaltafn := TRUE;
              END IF;

              -- verificar se houve alteração no Bairro ou Rua
              IF upper(rw_crapalt.dsaltera) LIKE '%END.RES. 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%ENDERECO 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%NRO.END. 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%NR.END. 1.TTL%'    OR
                 upper(rw_crapalt.dsaltera) LIKE '%COMPLEM. 1.TTL%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%COMPL.END. 1.TTL%' OR
                 upper(rw_crapalt.dsaltera) LIKE '%APTO. 1.TTL%'      OR
                 upper(rw_crapalt.dsaltera) LIKE '%BAIRRO 1.TTL%'     OR								 
                 upper(rw_crapalt.dsaltera) LIKE '%END.RES.,%'        OR
                 upper(rw_crapalt.dsaltera) LIKE '%BAIRRO,%'          OR 
                 upper(rw_crapalt.dsaltera) LIKE '%END.RES. COM.,%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%NR.END. COM.,%'    OR
                 upper(rw_crapalt.dsaltera) LIKE '%COMPLEM. COM.,%'   OR
                 upper(rw_crapalt.dsaltera) LIKE '%BAIRRO COM.,%'     THEN
                vr_flalttpe := TRUE;
              END IF;

              -- Verificar se foi alterado Estado, cidade ou CEP
              IF upper(rw_crapalt.dsaltera) LIKE '%CEP 1.TTL%'        OR
                 upper(rw_crapalt.dsaltera) LIKE '%CIDADE 1.TTL%'     OR
                 upper(rw_crapalt.dsaltera) LIKE '%UF 1.TTL%'         OR
								 
                 upper(rw_crapalt.dsaltera) LIKE '%CIDADE,%'          OR
                 upper(rw_crapalt.dsaltera) LIKE '%UF,%'              OR								 
                 upper(rw_crapalt.dsaltera) LIKE '%CEP,%'             OR
								 
                 upper(rw_crapalt.dsaltera) LIKE '%CEP COM.,%'        OR
                 upper(rw_crapalt.dsaltera) LIKE '%CIDADE COM.,%'     OR
                 upper(rw_crapalt.dsaltera) LIKE '%UF COM.,%'         THEN
                vr_flaltcep := TRUE;
              END IF;
							
							
							
							
							

              -- Verificar se houve alteração do telefone do cooperado
              IF upper(rw_crapalt.dsaltera) LIKE '%TELEF.%' THEN
                vr_flalttfc := TRUE;
              END IF;
                
              /*  END IF;  -- Condição IF comentada conforme comentário anterior */
              
              -- Se há alteração de limite
              IF cr_altlimit%FOUND THEN
                -- Popula a variável com o novo limite proposto
                vr_vllimalt := rw_altlimit.vllimite;
              ELSE 
                -- Envia nulo
                vr_vllimalt := NULL;
              END IF;
              
              -- Irá chamar a rotina para envio do registro, apenas se houver alguma alteração
              IF vr_flaltafn OR                 -- Alterado grupo de afinidade
                 vr_flaltcep OR                 -- Alterado Estado, cidade ou CEP
                 vr_flalttpe OR                 -- Alterado Bairro ou Rua
                 vr_flalttfc OR                 -- Alterado telefone 
                 vr_vllimalt IS NOT NULL THEN   -- Alterado Limite
              
                -- Tp. Operac.: Modificação de Conta Cartão (ENDEREÇO/PA/TELEFONE/LIMITE)
                vr_tipooper := '02';
                  
                -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (Tipo 1)
                gera_linha_registro_tipo1 (rw_crapcrd_loop_alt,
                                           rw_crapcol,
                                           rw_crapdat,
                                           rw_crapadc,
                                           rw_crapcrd_loop_alt.nrcctitg,
                                           vr_tipooper,
                                           rw_crapcrd_loop_alt.inpessoa,
                                           rw_crapcrd_loop_alt.nrctrcrd,
                                           rw_crapcrd_loop_alt.cdagenci, -- Canal de Venda
                                           rw_crapacb.cdgrafin,
                                           vr_flaltafn,    -- pr_flaltafn
                                           vr_flaltcep,    -- pr_flaltcep
                                           vr_flalttpe,    -- pr_flalttpe
                                           vr_flalttfc,    -- pr_flalttfc
                                           vr_vllimalt);   -- pr_vllimalt
              
              END IF;
              
              -- Se há registro de alteração de limite
              IF cr_altlimit%FOUND THEN
                BEGIN
                  -- Deve atualizar a situação do aumento de limite
                  UPDATE tbcrd_limite_atualiza  t
                     SET tpsituacao = 2 /* Enviado ao Bancoob */
                   WHERE ROWID = rw_altlimit.dsdrowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Montar mensagem de critica
                    vr_dscritic := 'Erro ao atualizar solicitação de alteração de limite: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;
              
            END IF;

            -- fecha cursores
            CLOSE cr_crapalt;            
            CLOSE cr_altlimit;
            
            EXCEPTION 
              WHEN vr_exc_loop_detalhe THEN
                
                -- fecha cursores
                CLOSE cr_crapalt;            
                CLOSE cr_altlimit;
            
                IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); -- Buscar a descrição
                END IF;

                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                  -- Envio centralizado de log de erro
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Programa roda para todas as coops. Por isto fixo cecred (3)
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                              || vr_cdprogra || ' --> '
                                                                              || vr_dscritic );
                END IF;
                
                vr_criticas := nvl(vr_criticas,'') || '<br>' || vr_dscritic || '<br>';
            END;
            
          END LOOP;

          -- Zerar variável de conta
		  vr_nrctarg1 := 0;

          -- Executa LOOP em registro de Cartões para gravar DETALHE
          FOR rw_crawcrd IN cr_crawcrd(rw_crapcol.cdcooper) LOOP
            BEGIN
              
              -- Define Conta Cartão a cada iteração do cr_crawcrd ( Renato - Supero - SD 196032 )
              vr_nrctacrd := '756' || TO_CHAR(lpad(rw_crapcol.cdagebcb,4,'0'));
              vr_flctacrd := FALSE; -- Não tem conta cartão, pois apenas definiu com a numeração padrão

              -- Zerar vars
              vr_nrdocttl := ' ';
              vr_idorgexp := NULL;
              vr_cdufdttl := ' ';
              vr_titulari := 0;
              vr_tipooper := ' ';
              
              -- Solicitacao de upgrade/downgrade no cartao do primeiro titular
              IF NVL(vr_nrctaant,0) <> rw_crawcrd.nrdconta THEN
                vr_flupgrad := FALSE;
                vr_nrctaant := rw_crawcrd.nrdconta;
               vr_qtdconta := 0; -- Limpar contagem por conta
              END IF;
              
              -- Contar quantidade de registros por conta no arquivo
              vr_qtdconta := vr_qtdconta + 1;

              -- Limitar em 8 solicitacoes de cartoes para a mesma conta no mesmo arquivo
              -- as que nao forem nesse arquivo vao no arquivo do dia seguinte
              if vr_qtdconta > 8 then                
                continue;
              end if;
              
              -- Busca Administradora de Cartões
              OPEN cr_crapadc(pr_cdcooper => rw_crawcrd.cdcooper,
                              pr_cdadmcrd => rw_crawcrd.cdadmcrd);
              FETCH cr_crapadc INTO rw_crapadc;

              -- Se nao encontrar
              IF cr_crapadc%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapadc;
                -- Montar mensagem de critica
                vr_cdcritic := 605;
                RAISE vr_exc_saida;
              ELSE
                -- fechar o cursor
                CLOSE cr_crapadc;
              END IF;

              -- Busca Grupo de Afinidade
              OPEN cr_crapacb(pr_cdcooper => rw_crawcrd.cdcooper,
                              pr_cdadmcrd => rw_crawcrd.cdadmcrd);
              FETCH cr_crapacb INTO rw_crapacb;

              -- Se nao encontrar
              IF cr_crapacb%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE cr_crapacb;
                -- Montar mensagem de critica
                vr_dscritic := 'Grupo de Afinidade nao encontrado para administradora ' ||
                               to_char(rw_crawcrd.cdadmcrd) || '.';
                RAISE vr_exc_saida;
              ELSE
                -- Apenas fechar o cursor
                CLOSE cr_crapacb;
              END IF;

              -- se tratamos pessoa física
              IF rw_crawcrd.inpessoa = 1 THEN

                -- Busca registro pessoa física
                OPEN cr_crapttl(pr_cdcooper => rw_crawcrd.cdcooper,
                                pr_nrdconta => rw_crawcrd.nrdconta,
                                pr_nrcpfcgc => rw_crawcrd.nrcpftit);
                FETCH cr_crapttl INTO rw_crapttl;

                -- Se nao encontrar
                IF cr_crapttl%NOTFOUND THEN
                  -- Fechar o cursor pois efetuaremos raise
                  CLOSE cr_crapttl;
                  -- Montar mensagem de critica
                  vr_dscritic := 'Titular da conta nao encontrado: ' || rw_crawcrd.nrdconta ||
                                 ' CPF: '                            || rw_crawcrd.nrcpftit ||
                                 ' Coop: ' ||                           rw_crawcrd.cdcooper;
                  RAISE vr_exc_loop_detalhe;                
                ELSE
                  -- Apenas fechar o cursor
                  CLOSE cr_crapttl;
                END IF;

                -- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
                IF rw_crapttl.tpdocttl = 'CI' THEN
                  vr_nrdocttl := rw_crapttl.nrdocttl;
                  vr_idorgexp := rw_crapttl.idorgexp;
                  vr_cdufdttl := rw_crapttl.cdufdttl;
                ELSE
                  vr_nrdocttl := ' ';
                  vr_idorgexp := NULL;
                  vr_cdufdttl := ' ';
                END IF;

                -- Se for primeiro titular, cria registro de Conta Cartão
                IF rw_crapttl.idseqttl = 1 THEN

                  -- Titularidade: Titular para Tp Registro 2.
                  vr_titulari := '1';

                  -- Tp. Operac.: Inclusão
                  vr_tipooper := '01';
                  -- Setar variável que indica alteração
                  vr_flaltafn := FALSE;

                  -- Upgrade/Downgrade
                  FOR rw_crapcrd IN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                               pr_nrdconta => rw_crawcrd.nrdconta) LOOP

                    -- Busca dados da Administradora com mesma bandeira
                    OPEN cr_crapadc(pr_cdcooper => rw_crapcrd.cdcooper,
                                    pr_cdadmcrd => rw_crapcrd.cdadmcrd);
                    FETCH cr_crapadc INTO rw_crapadc_crd;

                    -- Se nao encontrar
                    IF cr_crapadc%NOTFOUND THEN
                      -- Fechar o cursor pois efetuaremos raise
                      CLOSE cr_crapadc;
                      -- Montar mensagem de critica
                      vr_cdcritic := 605;
                      RAISE vr_exc_saida;
                    ELSE
                      -- fechar o cursor
                      CLOSE cr_crapadc;
                    END IF;

                    -- Compara a bandeira do Cartão da proposta com a dos Cartões efetivados;
                    IF rw_crapadc_crd.nmbandei = rw_crapadc.nmbandei THEN

                      -- Tp. Operac.: Modificação de Conta Cartão (UPGRADE/DOWNGRADE)
                      vr_tipooper := '02';

                      -- Enviar informação indicando que o Grupo de afinidade foi alterado
                      vr_flaltafn := TRUE;

                      -- se for realizado operação de upgrade/downgrade
                      --deve mandar numero já existente
                      vr_nrctacrd := rw_crawcrd.nrcctitg;
                      
                      -- Solicitacao de upgrade/downgrade no cartao do primeiro titular
                      vr_flupgrad := TRUE;

                    END IF;

                  END LOOP;

                  -- Guarda o número da conta informado no registro tipo 1
                  vr_nrctarg1 := rw_crawcrd.nrdconta;

                  -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (Tipo 1)
                  gera_linha_registro_tipo1 (rw_crawcrd,
                                             rw_crapcol,
                                             rw_crapdat,
                                             rw_crapadc,
                                             vr_nrctacrd,
                                             vr_tipooper,
                                             rw_crawcrd.inpessoa,
                                             rw_crawcrd.nrctrcrd,
                                             rw_crawcrd.cdagenci, -- Canal de Venda
                                             rw_crapacb.cdgrafin,
                                             vr_flaltafn,
                                             FALSE,
                                             FALSE);

                  -- Em caso de Upgrade/Downgrade, interrompe e passa para o próximo
                  IF vr_tipooper = '02' THEN

                    -- Altera a situação do Cartão para 2 (Solicitado)
                    altera_sit_cartao_solicitado(rw_crawcrd);

                    rw_crapadc_crd := NULL;
                    CONTINUE;
                  END IF;

                ELSE -- outros titulares
                  
                  -- Adicionar tratamento para quando for realizado Upgrade/Downgrade
                  -- nao gerar as informacoes dos cartoes adicionais
                  -- Verificar se o Tipo de Operacao eh a Modificacao de Conta Cartao (UPGRADE/DOWNGRADE)
                  IF vr_flupgrad THEN
                    -- Ignorar as informacoes e processar o proximo cartao
                    CONTINUE;
                  END IF;

                  -- Renato Darosci - Supero - Será incluída regra abaixo juntamente com as alterações
                  -- referentes ao chamado 197160   (09/09/2014)
                  -- Incluir a conta do titular quando as informações forem de um cartão adicional

                  -- Buscar a conta integração do titular
                  OPEN  cr_nrctaitg(rw_crawcrd.cdcooper
                                   ,rw_crawcrd.nrdconta
                                   ,rw_crawcrd.cdadmcrd);
                  FETCH cr_nrctaitg INTO rw_nrctaitg;
                  -- Se encontrar registros
                  IF cr_nrctaitg%FOUND AND NVL(rw_nrctaitg.nrcctitg,0) <> 0  THEN
                    -- Usar a conta integração do titular
                    vr_nrctacrd := rw_nrctaitg.nrcctitg;
                    vr_flctacrd := TRUE; -- Indica que possui conta cartão
                  END IF;
                  CLOSE cr_nrctaitg;

                  -- Se o registro anterior nao foi o primeiro titular e se
                  -- possui número de conta cartão, muda o Tp. operação
                  IF vr_titulari <> 1 AND vr_flctacrd THEN

                    -- Tp. Operac.: Inclusão de Cartão Adicional
                    vr_tipooper := '04';

                  ELSE

                    -- Se não for a mesma conta do registro 01 enviado, deve pular o registro
                    IF NVL(vr_nrctarg1,0) <> NVL(rw_crawcrd.nrdconta,-1) THEN
                      CONTINUE;
                    END IF;

                    -- Tp. Operac.: Inclusão de Cartão
                    vr_tipooper := '01';

                  END IF;

                  -- Titularidade: Dependentes (idseqttl <> 1) para Tp Registro 2.
                  vr_titulari := '2';

                END IF;

                -- LINHA RELATIVA AOS DADOS DO CARTAO (Tipo 2)
                gera_linha_registro_tipo2 (rw_crawcrd,
                                           rw_crapcol,
                                           rw_crapdat,
                                           vr_tipooper,
                                           vr_nrctacrd,
                                           rw_crapttl.nmextttl,
                                           rw_crawcrd.nmtitcrd, -- Nome embossado no cartão
                                           TO_CHAR(rw_crapttl.dtnasttl,'DDMMYYYY'),
                                           rw_crapttl.sexbancoob,
                                           fn_estado_civil_bancoob(rw_crapttl.cdestcvl),
                                           rw_crawcrd.nrcpftit,
                                           vr_titulari,
                                           vr_nrdocttl,
                                           vr_idorgexp,
                                           vr_cdufdttl,
                                           rw_crapttl.inpessoa);

              ELSE -- se tratamos pessoa jurídica

                -- Busca registro de pessoa jurídica
                OPEN cr_crapjur(pr_cdcooper => rw_crawcrd.cdcooper,
                                pr_nrdconta => rw_crawcrd.nrdconta);
                FETCH cr_crapjur INTO rw_crapjur;

                -- Se nao encontrar
                IF cr_crapjur%NOTFOUND THEN
                  -- Fechar o cursor pois efetuaremos raise
                  CLOSE cr_crapjur;
                  -- Montar mensagem de critica
                  vr_dscritic := 'Empresa nao encontrada. Conta/DV: ' || rw_crawcrd.nrdconta;
                  RAISE vr_exc_saida;
                ELSE
                  -- Apenas fechar o cursor
                  CLOSE cr_crapjur;
                END IF;
                
                -- Representante do tipo OUTROS
                IF rw_crawcrd.cdgraupr = 9 THEN
                  vr_dtnascto   := rw_crawcrd.dtnasccr;
                  vr_nrdocttl   := ' ';
                  vr_idorgexp   := NULL;
                  vr_cdufdttl   := ' ';
                  vr_nmdavali   := rw_crawcrd.nmtitcrd;                
                  vr_sexbancoob := 0;
                  vr_cdestcvl   := 0;
                  vr_nrcpfcgc   := rw_crawcrd.nrcpftit;
                  vr_inpessoa   := 1;
                  
                ELSE
                  -- Busca registro de representante para pessoa jurídica
                  OPEN cr_crapavt(pr_cdcooper => rw_crawcrd.cdcooper,
                                  pr_nrdconta => rw_crawcrd.nrdconta,
                                  pr_nrcpfcgc => rw_crawcrd.nrcpftit);
                  FETCH cr_crapavt INTO rw_crapavt;

                  -- Se nao encontrar
                  IF cr_crapavt%NOTFOUND THEN
                    -- Fechar o cursor pois efetuaremos raise
                    CLOSE cr_crapavt;
                    -- Montar mensagem de critica
                    vr_dscritic := 'Representante nao encontrado. Conta/DV: ' || rw_crawcrd.nrdconta ||
                                   ' CPF: '                                   || rw_crawcrd.nrcpftit ||
                                   ' Coop: '                                  || rw_crawcrd.cdcooper ;
                    RAISE vr_exc_loop_detalhe;
                  ELSE
                    -- Data nascimento representante
                    vr_dtnascto := rw_crapavt.dtnascto;

                    -- Apenas fechar o cursor
                    CLOSE cr_crapavt;
                  END IF;

                  -- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
                  IF rw_crapavt.tpdocava = 'CI' THEN
                    vr_nrdocttl := rw_crapavt.nrdocava;
                    vr_idorgexp := rw_crapavt.idorgexp;
                    vr_cdufdttl := rw_crapavt.cdufddoc;
                    vr_nmdavali := rw_crapavt.nmdavali;
                  ELSE
                    vr_nrdocttl := ' ';
                    vr_idorgexp := NULL;
                    vr_cdufdttl := ' ';
                    vr_nmdavali := rw_crapavt.nmdavali;
                  END IF;

                  -- Assume a data de nascimento
                  vr_dtnascto   := rw_crapavt.dtnascto;
                  vr_sexbancoob := rw_crapavt.sexbancoob;
                  vr_cdestcvl   := rw_crapavt.cdestcvl;
                  vr_nrcpfcgc   := rw_crapavt.nrcpfcgc;
                  vr_inpessoa   := rw_crapavt.inpessoa;
                  
                END IF;              

                -- Buscar a conta integração do titular
                OPEN  cr_nrctaitg_prcrd(rw_crawcrd.cdcooper
                                       ,rw_crawcrd.nrdconta
                                       ,rw_crawcrd.cdadmcrd);
                FETCH cr_nrctaitg_prcrd INTO rw_nrctaitg;
                -- Se encontrar registros
                IF cr_nrctaitg_prcrd%FOUND AND NVL(rw_nrctaitg.nrcctitg,0) <> 0 THEN
                  -- Usar a conta integração do titular
                  vr_nrctacrd := rw_nrctaitg.nrcctitg;
                  vr_flctacrd := TRUE; -- Indica que possui conta cartão
                END IF;
                CLOSE cr_nrctaitg_prcrd;

                /* Retirado pois os valores serão retornados no cursor, da tabela crapttl ( Renato - Supero )

                -- Verifica se representante encontrado é cooperado
                OPEN cr_crapass(pr_cdcooper => rw_crawcrd.cdcooper,
                                pr_nrcpfcgc => rw_crapavt.nrcpfcgc);
                FETCH cr_crapass INTO rw_crapass;

                -- Se nao for cooperado, pega os dados da tabela de representantes
                IF cr_crapass%NOTFOUND THEN
                  -- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
                  IF rw_crapavt.tpdocava = 'CI' THEN
                    vr_nrdocttl := rw_crapavt.nrdocava;
                    vr_cdoedttl := rw_crapavt.cdoeddoc;
                    vr_cdufdttl := rw_crapavt.cdufddoc;
                    vr_nmdavali := rw_crapavt.nmdavali;
                  ELSE
                    vr_nrdocttl := ' ';
                    vr_cdoedttl := ' ';
                    vr_cdufdttl := ' ';
                    vr_nmdavali := rw_crapavt.nmdavali;
                  END IF;
                ELSE -- Se for cooperado, pega os dados da conta
                  -- Somente alimenta varíaveis com informações de Documento for Carteira de Identidade
                  IF rw_crapass.tpdocptl = 'CI' THEN
                    vr_nrdocttl := rw_crapass.nrdocptl;
                    vr_cdoedttl := rw_crapass.cdoedptl;
                    vr_cdufdttl := rw_crapass.cdufdptl;
                    vr_nmdavali := rw_crapass.nmprimtl;
                  ELSE
                    vr_nrdocttl := ' ';
                    vr_cdoedttl := ' ';
                    vr_cdufdttl := ' ';
                    vr_nmdavali := rw_crapass.nmprimtl;
                  END IF;

                  -- Assume Data Nascimento CRAPASS quando associado
                  vr_dtnascto := rw_crapass.dtnasctl;

                END IF;
                -- fechar o cursor
                CLOSE cr_crapass;*/

                -- Verifica se é o primeiro cartão bancoob da empresa (indiferente da adminsitradora)
                OPEN cr_crawcrd_flgprcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                         pr_nrdconta => rw_crawcrd.nrdconta,
                                         pr_nrctrcrd => rw_crawcrd.nrctrcrd,
                                         pr_nmbandei => rw_crapadc.nmbandei);
                FETCH cr_crawcrd_flgprcrd INTO rw_crawcrd_flgprcrd;

                IF cr_crawcrd_flgprcrd%FOUND THEN
                   vr_flgprcrd := 0; -- Não é o primeiro
                ELSE
                   vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                END IF;

                -- fecha cursor
                CLOSE cr_crawcrd_flgprcrd;

                -- Verifica se é o primeiro cartão Bancoob adquirido
                IF vr_flgprcrd = 1 THEN

                  -- Tp. Operac.: Inclusão de Cartão
                  vr_tipooper := '01';

                  -- Guarda o número da conta informado no registro tipo 1
                  vr_nrctarg1 := rw_crawcrd.nrdconta;

                  -- LINHA RELATIVA AOS DADOS DA CONTA CARTAO (Tipo 1)
                  gera_linha_registro_tipo1 (rw_crawcrd,
                                             rw_crapcol,
                                             rw_crapdat,
                                             rw_crapadc,
                                             vr_nrctacrd,
                                             vr_tipooper,
                                             rw_crawcrd.inpessoa,
                                             rw_crawcrd.nrctrcrd,
                                             rw_crawcrd.cdagenci, -- Canal de Venda
                                             rw_crapacb.cdgrafin);

                  -- Titularidade: Titular para Tp Registro 2
                  vr_titulari := '1';

                  -- Tp. Operac.: Inclusão de Cartão
                  vr_tipooper := '01';

                  -- Envia registro tipo 2 com dados da empresa uma única vez
                  -- LINHA RELATIVA AOS DADOS DO CARTAO (Tipo 2)
                  gera_linha_registro_tipo2 (rw_crawcrd,
                                             rw_crapcol,
                                             rw_crapdat,
                                             vr_tipooper,
                                             vr_nrctacrd,
                                             rw_crapjur.nmextttl,
                                             rw_crawcrd.nmempcrd,  -- Nome embossado no cartão
                                             TO_CHAR(rw_crapjur.dtiniatv,'DDMMYYYY'),
                                             '0',  -- Não informado
                                             '00', -- Não informado
                                             rw_crawcrd.nrcpfcgc,
                                             vr_titulari,
                                             rw_crapjur.nrinsest,
                                             NULL,
                                             ' ',
                                             2); -- Pessoa Juridica
                END IF;

                -- Sempre enviar o registro tipo 2, para pessoa juridica como 04
                -- Quando possui número de conta cartão   ( Renato - Supero )
                IF vr_flctacrd THEN
                -- Tp. Operac.: Inclusão de Cartão Adicional
                vr_tipooper := '04';
                ELSE
                  -- Se não for a mesma conta do registro 01 enviado, deve pular o registro
				  IF NVL(vr_nrctarg1,0) <> NVL(rw_crawcrd.nrdconta,-1) THEN
					CONTINUE;
				  END IF;									
								
                  vr_tipooper := '01';
                END IF;

                -- Titularidade: Dependentes para Tp Registro 2
                vr_titulari := '2';

                -- Envia registro tipo 2 com dados do solicitante do cartão
                -- LINHA RELATIVA AOS DADOS DO CARTAO (Tipo 2)
                gera_linha_registro_tipo2 (rw_crawcrd,
                                           rw_crapcol,
                                           rw_crapdat,
                                           vr_tipooper,
                                           vr_nrctacrd,
                                           vr_nmdavali,
                                           rw_crawcrd.nmtitcrd, -- Nome embossado no cartão
                                           TO_CHAR(vr_dtnascto,'DDMMYYYY'),
                                           vr_sexbancoob,
                                           fn_estado_civil_bancoob(vr_cdestcvl),
                                           vr_nrcpfcgc,
                                           vr_titulari,
                                           vr_nrdocttl,
                                           vr_idorgexp,
                                           vr_cdufdttl,
                                           vr_inpessoa);

              END IF;

            -- Altera a situação do Cartão para 2 (Solicitado)
            altera_sit_cartao_solicitado(rw_crawcrd);

            EXCEPTION
              WHEN vr_exc_loop_detalhe THEN
                IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); -- Buscar a descrição
                END IF;

                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                  -- Envio centralizado de log de erro
                  btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Programa roda para todas as coops. Por isto fixo cecred (3)
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                              || vr_cdprogra || ' --> '
                                                                              || vr_dscritic );
                END IF;
                
                vr_criticas := nvl(vr_criticas,'') || '<br>' || vr_dscritic || '<br>';
                
              WHEN OTHERS THEN
                CECRED.pc_internal_exception;
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                vr_dscritic := 'Problema ao montar arquivo de cartoes solicitados - ' || sqlerrm;
                
                gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                          ,pr_cdprogra        => vr_cdprogra
                                          ,pr_des_destino     => gene0001.fn_param_sistema('CRED',vr_cdcooper,'CRD_RESPONSAVEL')
                                          ,pr_des_assunto     => 'ERRO - Arquivo CCB3'
                                          ,pr_des_anexo       => NULL
                                          ,pr_des_corpo       => 'Erro ao gerar arquivo '|| vr_nmrquivo||
                                                                 '<br><br>'||'Critica: ' || vr_dscritic
                                          ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                          ,pr_des_erro        => vr_dsderro);
                --Se ocorreu erro
                IF trim(vr_dsderro) IS NOT NULL THEN
                  vr_dscritic:= vr_dsderro;
                  --Levantar Excecao
                RAISE vr_exc_saida;
                END IF;
                
                RAISE vr_exc_saida;
            END;

          END LOOP;

        END LOOP;

        -- monta TRAILER do arquivo
        vr_dstraile := ('CCB3'                         /* Pedido         */      ||
                        '09'                           /* Trailer        */      ||
                        lpad(nvl(vr_conttip1,0),7,'0') /* Qtd. Reg Tp 1  */      ||
                        lpad(nvl(vr_conttip2,0),7,'0') /* Qtd. Reg Tp 2  */      ||
                        lpad(' ',80,' ')               /* Filler         */      );

        -- escrever TRAILER do arquivo
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dstraile);

        -- fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> handle do arquivo aberto;

        -- Executa comando UNIX para converter arq para Dos
        vr_dscomando := 'ux2dos ' || vr_direto_connect|| '/TMP_'||vr_nmrquivo||' > '
                                  || vr_direto_connect ||'/envia'||'/'||vr_nmrquivo || ' 2>/dev/null';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_saida;
        END IF;

        -- Remover arquivo tmp
        vr_dscomando := 'rm ' || vr_direto_connect|| '/TMP_'||vr_nmrquivo;

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_dscomando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- verifica criticas para enviar por email
        
        IF TRIM(vr_criticas) IS NOT NULL THEN
          gene0003.pc_solicita_email(pr_cdcooper              => vr_cdcooper
                                          ,pr_cdprogra        => vr_cdprogra
                                          ,pr_des_destino     => 'cartoes@ailos.coop.br'
                                          ,pr_des_assunto     => 'Criticas - Arquivo CCB3'
                                          ,pr_des_anexo       => NULL
                                          ,pr_des_corpo       => 'As solicitacoes listadas abaixo nao foram enviadas no arquivo:  '|| vr_nmrquivo||
                                                                 '<br><br>'|| vr_criticas
                                          ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                          ,pr_des_erro        => vr_dsderro);
                                          
          IF trim(vr_dsderro) IS NOT NULL THEN
            vr_dscritic:= vr_dsderro;
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
                
        END IF;
        
        -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
        BEGIN
          UPDATE
            crapscb
          SET
            nrseqarq = vr_nrseqarq,
            dtultint = SYSDATE,
            flgretpr = 0
          WHERE
            crapscb.tparquiv = 3; -- Arquivo CBB3 - Interface Cadastral

        -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
        EXCEPTION
          WHEN OTHERS THEN
            -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
            vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
            RAISE vr_exc_saida;
        END;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>1</TpException></Root>');
      WHEN vr_exc_fimprg THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>2</TpException></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em ARQBCB/CRPS671: ' || SQLERRM;

        gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => gene0001.fn_param_sistema('CRED',vr_cdcooper,'CRD_RESPONSAVEL')
                                  ,pr_des_assunto     => 'Erro geral em ARQBCB/CRPS671'
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_corpo       => 'Erro ao gerar arquivo '|| vr_nmrquivo||
                                                         '<br><br>'||'Critica: ' || pr_dscritic 
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dsderro);

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_crps671;

  PROCEDURE pc_crps672 ( pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo                 
  BEGIN
/* ..........................................................................

       Programa: pc_crps672
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Abril/2014.                     Ultima atualizacao: 30/04/2019

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao 01, Ordem 36.
                   Tratar arquivo de retorno da Solicitação de Cartão (Bancoob/CABAL).
                   Relatório crrl676 - Rejeições Processamento Arq. Retorno

       Alteracoes: 22/08/2014 - Ajustes para validação do processamento do arquivo,
                               alteração para buscar leitura do arquivo conforme cadastro.(Odirlei-AMcom)
                               
                   27/08/2014 - Realizar commit a cada processamento de arquivo(Odirlei/Amcom)
                   
                   08/09/2014 - Retirar código da Versão temporária, devido a solicitação via 
                                chamado SD 197307 (Renato - Supero)
                                
                   25/09/2014 - Incluir regra para buscar cartão em uso no cursor
                                cr_crawcrd_cdgrafin  ( Renato - Supero )
                                
                   30/09/2014 - Alterado as regras para tratamento de arquivo e
                                ajustada ordenação do relatório de rejeitados
                                (Renato - Supero)
                                
                   14/10/2014 - Alterações no formato do relatório conforme SD 204500 (Vanessa)

                   04/11/2014 - Quando inserir um novo CRAWCRD, deverá incluir o valor
                                do flgprcrd, conforme o valor do cartão encerrado ( Renato - Supero )
                                
                   11/11/2014 - Ajustar programa para gravar as datas relacionadas a solicitação
                                de segunda via de cartão, conforme chamado 217188 e ajuste nos 
                                selects do grupo de afinidade, afim de filtrar apenas por 
                                administradoras do Bancoob ( Renato - Supero )
                                
                   13/11/2014 - Alteração para não exibir as criticas menores que 10 e maiores 
                                que 900 (Vanessa)
                                
                   10/03/2015 - Alterado para gravar corretamente as datas de solicitação de 
                                segunda via de cartão, conforme chamado 251387 ( Renato - Supero )
                                
                   21/07/2015 - Realizado ajuste para ignorar linhas com crítica, onde a conta(posição 337)
                                esteja com valor igual a zero. Alteração realizada devido a erros ocorridos
                                no processo batch. (Renato - Supero)
                                
                   15/10/2015 - Desenvolvimento do projeto 126. (James)
                   
                   02/12/2015 - Ajuste para mostrar a Administradora no relatorio. (James)
                   
                   07/12/2015 - Resolução do chamado 370195.
                                Ajuste para gravar o codigo da administradora para os cartoes solicitados apartir do
                                Bancoob. (James)
                                
                   15/02/2016 - Ajuste para gerar no relatorio de criticas 676 retorno de solicitacao
                                criticado que vier com os dados do CNPJ. (Chamado 389699) - (Fabricio)
                                
                   10/03/2016 - Feita a troca de log do batch para o proc_message conforme
                                solicitado no chamado 405441 (Kelvin).
                                
                   12/05/2016 - Ajustado situacao de Cancelado para 6 no cursor cr_crawcrd_cdgrafin_conta
                                pois esse eh o indicador de cartao cancelado quando trata-se de
                                Cartao Cecred (Bancoob). (Chamado 433197 entre outros...) - (Fabricio)
                                
                   22/06/2016 - Ajuste no ELSE que verifica a existencia de registro na leitura do
                                cursor cr_crapacb para nao gerar mais RAISE, mas sim, gravar log
                                e continuar processando o arquivo. (Fabricio)
                                
                   29/06/2016 - Ajuste no cursor cr_crawcrd_cdgrafin_conta para contemplar a busca
                                tanto por cartoes Bloqueados quanto Cancelados (insitcrd = 5,6).
                                (Chamados 478655, 478680 entre outros...) - (Fabricio)
                                
                   14/07/2016 - Ajustado a identificacao dos dados da conta e controle na leitura do
                                numero da conta quando o valor recebido eh zero
                                (Douglas - Chamado 465010, 478018)

                   04/10/2016 - Ajustado para gravar o nome da empresa do plastico quando criar uma
                                nova proposta de cartao (Douglas - Chamado 488392)
                                
                   10/10/2016 - Ajuste para nao voltar para Aprovado uma solicitacao que
                                retornar com critica 80 do Bancoob (pessoa ja tem cartao nesta conta).
                                (Chamado 532712) - (Fabrício)

                           01/11/2016 - Ajustes quando ocorre integracao de cartao via Upgrade/Downgrade.
                                (Chamado 532712) - (Fabricio)
                                
                   11/11/2016 - Adicionado validação de CPF do primeiro cartão da administradora
                                para que os cartões solicitados como reposição também tenham a mesma
                                flag de primeiro cartão (Douglas - Chamado 499054 / 541033)
                                
                   24/11/2016 - Ajuste para alimentar o campo de indicador de funcao debito (flgdebit)
                                com a informacao que existe na linha do arquivo referente a
                                funcao habilitada ou nao. (Fabricio)
                              - Quando tipo de operacao for 10 (desbloqueio) e for uma reposicao de cartao,
                                chamar a procedure atualiza_situacao_cartao para cancelar o cartao
                                anterior. (Chamado 559710) - (Fabricio)
                                
                   05/12/2016 - Correcao no cursor cr_crapcrd para buscar cartoes atraves do indice da tabela
                                e inclusao da validacao da existencia de cartoes sem proposta gerando log 
                                no proc_message. SD 569619 (Carlos Rafael Tanholi)
                                
                   02/01/2017 - Ajuste na leitura dos registros de cartoes ja existentes.
                                (Fabricio)
                                
                   06/02/2017 - Ajuste para nao atualizar a wcrd em cima de um cartao ja existente
                                quando se trata de reposicao/2a via. (Fabricio)
                                
                   12/04/2017 - Ajustes para gravar tabela tbcrd_conta_cartao.
                                PRJ343-Cessao de Credito (Odirlei-AMcom)
                                
                   17/04/2017 - Tratamento para abrir chamado e enviar email caso ocorra
                                algum erro na importacao do arquivo ccr3 (Lucas Ranghetti #630298)

                   19/06/2017 - Tratamento para validar se o arquivo foi recebido completo.
                                Caso o arquivo CCR3 tenha sido recebido incompleto, enviamos
                                e-mail e abrimos chamado (Douglas - Chamado 647872)


                   29/06/2017 - Alterado o cursor do primeiro grupo de afinidade, para buscar um cartao
                                em uso/liberado, e que a conta ainda nao tenha uma solicitacao de cartao
                                (Douglas - Chamado 637487)
                   
                   04/07/2017 - Melhoria na busca dos arquivos que irão ser processador, conforme
                                solicitado no chamado 703589. (Kelvin)

                   18/07/2017 - Utilizar o nome do titular do cartão na importação do arquivo CCR3
                                para atualizar no Ayllos, a fim de manter as informalçoes identicas
                                com o SIPAG (Douglas - Chamado 709215) 
                                
                   21/09/2017 - Validar ultima linha do arquivo corretamente (Lucas Ranghetti #753170)
                   
                   25/09/2017 - Ajustado importação do arquivo CCR3, para integrar os cartões PURO CREDITO
                                quando o titular do cartão não possuir vinculo com a conta
                              - Ajustado a flgdebit para verificar na linha do arquivo se o cartão possui
                                conta para debitar
                              (Douglas - Chamado 746057)

                   23/08/2017 - Alterar o recebimento de informações de alteração de limites. 
                                (Renato Darosci - Projeto 360)
                                
                   23/02/2018 - Criar no relatorio 676 a critica Representante nao encontrado
                                (Lucas Ranghetti #847282)
                                
                   07/05/2018 - Ajuste realizado para que a criação do lote seja separado
                                por cooperativa para solucionar o problema do incidente
                                INC0013534. (Kelvin)
                   
                   30/05/2018 - Tratamento para Grupo de afinidade zerado 
                                (Lucas Ranghetti SCTASK0014662)
                                
                   09/07/2018 - Validar critica 080 apos a criacao da critica no
                                relatorio (Lucas Ranghetti INC0018668)
				   
                   23/10/2018 - Adicionado cursor para encontrar cooperado pelo cpf 
                                (Bruno Mouts INC0024859 )
				   
                   13/11/2018 - Criado uma nova regra onde gera lote a cada mil mensagem sms 
                                (Douglas Mouts PRB0040381)
				   
				   10/12/2018 - foi feito a validação do codigo de administrador, caso o mesmo esteja zerado
                                será usado o cdgrafin do arquivo para fazer a validação (Bruno Cardoso,PRB0040377, Mout'S).
                                
                   21/12/2018 - Efetuado ajuste para caso seja efetuado um upgrade ele atualize
                                todos os cartões que vieram no arquivo com o tipo 4 do ccr3
                                (Lucas Ranghetti #INC0029505)
                              - Incluir a critica 143 - conta duplicada junto da critica 080
                                para não prosseguirmos com a inclusão do cartão pois o mesmo
                                ja possui cartão (Lucas Ranghetti #PRB0040493)

				   16/01/2019 - Adicionar ordenacao no cursor cr_crawcrd (Anderson).
                   
                   11/02/2019 - Tratamento para flgprcrd quando incluir segunda via 
                                (Lucas Ranghetti #PRB0040597)
                              - Limpar data de rejeicao ao alterar a situação para 
                                3 - liberado (Lucas Ranghetti PRB0040596)
                                
                   08/03/2019 - Verificar se processo batch ainda está rodando na central
                                pois vamos rodar o programa mesmo com a central rodando
                                (Lucas Ranghetti PRB0040618)
                                
                   30/04/2019 - Utilizar o vr_nrcctitg no lugar do rw_crawcrd.nrcctitg 
                                no insert do crawcrd da segunda via dos cartões (Lucas Ranghetti PRB0041609)

                   15/05/2019 - Retirado a restrição de código de critica, com isso todas 
							    as criticas saíram no relatório. Alcemir Mouts (PRB0041490).

                   15/05/2019 - Incluido validação para quando a proposta é via WMS.
					            Alcemir Mouts (PRB0041673).

	               15/05/2019 - Ajuste na lógica da criação do lote sms e no envio.
								Alcemir Mouts (PRB0041487)			
    ............................................................................ */

    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS672';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdirarq   VARCHAR2(200);                                     --> Caminho e nome do arquivo      
      vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
      vr_nmrquivo   VARCHAR2(200);                                     --> Nome do arquivo
      vr_nmarquiv   VARCHAR2(4000);                                    --> Nome do(s) arqs em Diretório
      vr_des_text   VARCHAR2(2000);                                    --> Conteúdo da Linha do Arquivo
      vr_contador   NUMBER:= 0;                                        --> Conta qtd. arquivos
      vr_ind_arquiv utl_file.file_type;                                --> declarando handle do arquivo
      vr_tipooper   VARCHAR2(4)     := 0;                              --> Tp. Operac
      vr_nroperac   NUMBER          := 0;                              --> Nr. Operação
      vr_cdgrafin   NUMBER          := 0;                              --> Cd. Grupo de Afinidade
      vr_nrdconta   NUMBER          := 0;                              --> Nr. Conta a Debitar
      vr_cdagebcb   NUMBER          := 0;                              --> Cd. Agencia do Bancoob da Cooperativa
      vr_cdcooper   NUMBER          := 0;                              --> Cd. Coopertaiva identificada
      vr_nrcanven   VARCHAR2(200)   := 0;                              --> Nr. Canal de Venda (PA)
      vr_dddebito   NUMBER          := 0;                              --> Dia Déb. em Conta-corrente
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX para Mover arquivo lido
      vr_nrseqarq   INTEGER;                                           --> Sequencia de Arquivo
      vr_nrseqarq_max INTEGER := 0;                                    --> Maior Sequencia de Arquivo
      vr_vllimcrd   crawcrd.vllimcrd%TYPE;                             --> Valor de limite de credito
      vr_tpdpagto   NUMBER          := 0;                              --> Tp de Pagto do cartão
      vr_flgdebcc   NUMBER          := 0;                              --> flg para debitar em conta
			vr_flgprovi   BOOLEAN;                                           --> flg para cartão provisorio
			vr_flgproviint crapcrd.flgprovi%TYPE;                            --> flg para cartão provisorio (usado para o insert)
      vr_flgprcrd   NUMBER          := 0;                              --> Primeiro cartão dessa Modalidade
      vr_nmextttl   crapttl.nmextttl%TYPE;                             --> Nome Titular
      vr_vlsalari   crapttl.vlsalari%TYPE;                             --> Salario
      vr_dtnasccr   crapass.dtnasctl%TYPE;                             --> Dt. Nasc.
      vr_nrctrcrd   crawcrd.nrctrcrd%TYPE;                             --> Nr. Contrato
      vr_nrseqcrd   crawcrd.nrseqcrd%TYPE;                             --> Nr. Sequencial do Contrato para o Bancoob
      vr_nrdctitg   NUMBER;
      vr_nmtitcrd   VARCHAR2(50);                                      --> Nome do Titular do cartão
      vr_dtentr2v   DATE;                                              --> Data de entrada do registro de segunda via
      vr_valida_avt BOOLEAN;                                           --> Identifica se devemos validar o avalista
      vr_dsvlrmsg   VARCHAR2(50);                                      --> Valores dinâmicos da mensagem SMS
      vr_dsmsgsms   VARCHAR2(500);                                     --> Mensagem SMS a ser enviada
      vr_idlotsms   tbgen_sms_lote.idlote_sms%TYPE;                    --> Lote do SMS
      vr_idsms      tbgen_sms_controle.idsms%TYPE;                     --> ID do SMS gerado para envio
      -- Tratamento de registros do arquivo
      vr_nrctatp1   NUMBER          := 0;                              --> Número da conta do registro Tipo 1
      vr_nrctatp2   NUMBER          := 0;                              --> Número da conta do registro Tipo 2
      vr_cdlimcrd   crawcrd.cdlimcrd%TYPE;                             --> Codigo da linha do valor de credito
      vr_flgdebit   crawcrd.flgdebit%TYPE;                             --> Verifica se o cartao possui funcao de debito habilitada
      vr_codrejei   NUMBER;                                            --> codigo da rejeicao
      vr_dtoperac   DATE;                                              --> data da operacao
      vr_nrcrcard   NUMBER;                                            --> Numro do cartao
      vr_tpdocmto   NUMBER;                                            --> Tipo de documento
      vr_sitcarta   NUMBER;                                            --> Situacao do cartao
      vr_nrcpfcgc   NUMBER;                                            --> CPF
      vr_dtdonasc   DATE;                                              --> Data do Nascimento
      vr_chamado    VARCHAR2(200);                                     --> Numero do chamado
      vr_linha      NUMBER          := 0;                              --> Linha do arquivo
      vr_idprglog   tbgen_prglog.idprglog%TYPE;                         
      vr_destinatario_email VARCHAR2(500);                             --> Destinatario E-mail 
      vr_saida_tail VARCHAR2(1000);                                    --> Retorno do tail -2
      vr_conarqui   NUMBER:= 0;                                        
      vr_listarq    VARCHAR2(2000);                                    
      vr_split      gene0002.typ_split := gene0002.typ_split(); 
      vr_indice     NUMBER;
      vr_limitsms   NUMBER;
      vr_cpf        NUMBER;                                           --> Recebe o CPF do cooperado 
      vr_dtmvtolt   DATE;

      vr_tplimcrd   NUMBER(1) :=  0; -- 0=concessao, 1=alteracao
      vr_origemws   boolean;         -- Solicitacao por WS
      vr_final_cartao_aimaro VARCHAR(4);
      vr_final_cartao_cabal  VARCHAR(4);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);
      vr_typ_saida     VARCHAR2(4000);
      vr_des_erro      VARCHAR2(3);

      -- Extração dados XML
      vr_cdcooper_ori   NUMBER;
      vr_cdoperad       VARCHAR2(100);
      vr_nmdatela       VARCHAR2(100);
      vr_nmeacao        VARCHAR2(100);
      vr_cdagenci       VARCHAR2(100);
      vr_nrdcaixa       VARCHAR2(100);
      vr_idorigem       VARCHAR2(100);
      
      -- Variáveis locais do bloco
      vr_xml_clobxml       CLOB;
      vr_xml_lim_cartao    CLOB;
      vr_xml_des_erro      VARCHAR2(4000);
      vr_pa_anterior       NUMBER          := 0;
      vr_pa_proximo        BOOLEAN; 

      -- Definicao do tipo de arquivo para processamento
      TYPE typ_tab_nmarquiv IS
       TABLE OF VARCHAR2(100)
       INDEX BY BINARY_INTEGER;

      -- Vetor para armazenar os arquivos para processamento
      vr_vet_nmarquiv typ_tab_nmarquiv;

       -- Definicao do vetor com os códigos e os nomes das solicitações
        TYPE typ_vet_nmtipsol IS
          TABLE OF VARCHAR2(150)
          INDEX BY BINARY_INTEGER;
        
        vr_vet_nmtipsol  typ_vet_nmtipsol;
      
      -- Definicao do vetor com os códigos de lote de SMS criado por cooperativa
     TYPE typ_reg_nrdlote IS
     RECORD (lsnrdlote   VARCHAR2(4000),
             vrlimtsms   NUMBER(5) := 0,
             vrultlote   NUMBER);
                   
      TYPE typ_tab_nrdlote IS
       TABLE OF typ_reg_nrdlote
       INDEX BY BINARY_INTEGER;

      -- Vetor para armazenar os códigos de lote de SMS criado por cooperativa
      vr_vet_nrdlote typ_tab_nrdlote;
      
      -- armazenar os lotes de sms para envio
      vr_vet_lsnrdlote gene0002.typ_split;
      
      -- Armazena o indicador de envio de SMS para o produto, por cooperativa
      TYPE typ_tab_enviasms IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      vr_tab_enviasms      typ_tab_enviasms;
      
      -- Dados para upgrade
      TYPE typ_tab_reg_upgrade IS 
      TABLE OF VARCHAR2(100) 
      INDEX BY varchar2(100);
      
      vr_tab_reg_upgrade typ_tab_reg_upgrade;
      
      ------------------------------- CURSORES ---------------------------------
     -- Faz a procura do cartão pelo CPF do cooperado
	 CURSOR cr_crawcrd_cpf (pr_cdcooper IN crawcrd.cdcooper%TYPE,pr_nrcpftit IN crawcrd.nrcpftit%TYPE) IS
        SELECT crd.nrdconta
          FROM crawcrd crd
         WHERE crd.cdcooper = pr_cdcooper
           AND crd.nrcpftit = pr_nrcpftit 
           AND crd.nrcrcard = 0
           AND crd.insitcrd= 2;    -- Situação 2-solicitado
           
      rw_crawcrd_cpf cr_crawcrd_cpf%ROWTYPE;
     
      -- Busca as cooperativas
      CURSOR cr_crapcop_todas IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
              ,cop.dsdircop
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper <> 3
           AND cop.flgativo = 1;
      rw_crapcop_todas cr_crapcop_todas%ROWTYPE;

     -- Cursor para retornar cooperativa com base na conta da central
      CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdagebcb = pr_cdagebcb;
      rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;

      -- cursor para Grupo de Afinidade
      CURSOR cr_crapacb (pr_cdgrafin IN crapacb.cdgrafin%TYPE) IS
      SELECT acb.cdadmcrd
        FROM crapacb acb
       WHERE acb.cdgrafin = pr_cdgrafin;
      rw_crapacb cr_crapacb%ROWTYPE;

      -- Busca status de retorno do arquivo
      CURSOR cr_crapscb IS
        SELECT scb.flgretpr,
               scb.nrseqarq,
               scb.dsarquiv,
               scb.dsdirarq,
               scb.rowid
          FROM crapscb scb
         WHERE scb.tparquiv = 7;-- CCR3
      rw_crapscb cr_crapscb%ROWTYPE;

      -- cursor para Rejeições no Processamento do Arq. de Retorno CABAL (CCR3)
      CURSOR cr_craprej (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT rej.cdcooper
              ,rej.cdagenci
              ,age.nmextage
              ,rej.nrdconta
              ,rej.nrdocmto
              ,DECODE(NVL(to_number(substr(rej.cdpesqbb,0,19)),0),0,NULL,substr(rej.cdpesqbb,0,19)) cdpesqbb
              ,rej.nrdctitg nrdctitg            
              ,LISTAGG(rej.cdcritic || '-' || NVL(crc.dscritic, 'CRITICA NAO CADASTRADA'), ',') WITHIN GROUP (ORDER BY cdcritic) cdcritic
              ,SUBSTR(LISTAGG (substr(rej.cdpesqbb,20,23), ', ') WITHIN GROUP (ORDER BY substr(rej.cdpesqbb,20,23) ),0,23) nmtitcrd 
              ,NVL(to_number(substr(rej.cdpesqbb,43,2)),0) AS cdtipope

        FROM craprej rej
                
        INNER JOIN crapage age ON
                   age.cdcooper = rej.cdcooper
              AND  age.cdagenci = rej.cdagenci 
        
        LEFT JOIN crapcrc crc ON 
                  crc.cdcodigo = rej.cdcritic
              
         
        WHERE rej.dshistor = 'CCR3'        
          AND rej.dtmvtolt = pr_dtmvtolt
          AND rej.cdcooper = pr_cdcooper                  
                  
       GROUP BY rej.cdcooper
                ,rej.cdagenci
                ,age.nmextage
                ,rej.nrdconta
                ,rej.nrdocmto
                ,DECODE(NVL(to_number(substr(rej.cdpesqbb,0,19)),0),0,NULL,substr(rej.cdpesqbb,0,19))
                ,rej.nrdctitg
                ,crc.dscritic
                ,to_number(substr(rej.cdpesqbb,43,2))                          
        ORDER BY rej.cdagenci, rej.nrdconta;


      rw_craprej cr_craprej%ROWTYPE;
      
      -- cursor para busca de proposta de cartão
      CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE,
                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                         pr_nrcpftit IN crawcrd.nrcpftit%TYPE,
                         pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE,
                         pr_rowid    IN ROWID := NULL) IS
      SELECT pcr.cdcooper
            ,pcr.nrdconta
            ,pcr.nrcrcard
            ,pcr.nrcpftit
            ,pcr.nmtitcrd
            ,pcr.dddebito
            ,pcr.cdlimcrd
            ,pcr.dtvalida
            ,pcr.nrctrcrd
            ,pcr.cdmotivo
            ,pcr.nrprotoc
            ,pcr.cdadmcrd
            ,pcr.tpcartao
            ,pcr.nrcctitg
            ,pcr.vllimcrd
            ,pcr.flgctitg
            ,pcr.dtmvtolt
            ,pcr.nmextttl
            ,pcr.flgprcrd
            ,pcr.tpdpagto
            ,pcr.flgdebcc
            ,pcr.tpenvcrd
            ,pcr.vlsalari
            ,pcr.insitcrd
            ,pcr.dtnasccr
            ,pcr.nrdoccrd
            ,pcr.dtcancel
            ,pcr.flgdebit
            ,pcr.nmempcrd
            ,pcr.rowid
        FROM crawcrd pcr
       WHERE pcr.cdcooper = pr_cdcooper  AND
             pcr.nrdconta = pr_nrdconta  AND
             pcr.nrcpftit = pr_nrcpftit  AND
             pcr.cdadmcrd = pr_cdadmcrd  AND
             (pcr.rowid <> pr_rowid OR pr_rowid IS NULL) AND
             pcr.dtcancel IS NULL
    /* Dar preferencia para os cartoes insitcrd = [2 - solicitado] pois acabou
       pegando propostas de cartoes cancelados e outras situacoes indevidas */
    ORDER BY DECODE(pcr.insitcrd,2,0,9);
      rw_crawcrd cr_crawcrd%ROWTYPE;

      -- cursor para busca de proposta de cartões do bancoob por conta
      -- para verificar se é o primeiro cartão bancoob adquirido pela empresa
      -- desta administradora
      CURSOR cr_crawcrd_flgprcrd (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                  pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
      SELECT pcr.flgprcrd
            ,pcr.nrcpftit
        FROM crawcrd pcr
       WHERE pcr.cdcooper = pr_cdcooper AND
             pcr.nrdconta = pr_nrdconta AND
             pcr.cdadmcrd = pr_cdadmcrd AND
             pcr.flgprcrd = 1;
      rw_crawcrd_flgprcrd cr_crawcrd_flgprcrd%ROWTYPE;

      CURSOR cr_crawcrd_rowid (pr_rowid IN ROWID) IS
      SELECT pcr.cdcooper
            ,pcr.nrdconta
            ,pcr.nrcrcard
            ,pcr.nrcpftit
            ,pcr.nmtitcrd
            ,pcr.dddebito
            ,pcr.cdlimcrd
            ,pcr.dtvalida
            ,pcr.nrctrcrd
            ,pcr.cdmotivo
            ,pcr.nrprotoc
            ,pcr.cdadmcrd
            ,pcr.tpcartao
            ,pcr.nrcctitg
            ,pcr.vllimcrd
            ,pcr.flgctitg
            ,pcr.dtmvtolt
            ,pcr.nmextttl
            ,pcr.flgprcrd
            ,pcr.tpdpagto
            ,pcr.flgdebcc
            ,pcr.tpenvcrd
            ,pcr.vlsalari
            ,pcr.insitcrd
            ,pcr.dtnasccr
            ,pcr.nrdoccrd
            ,pcr.dtcancel
            ,pcr.flgdebit
            ,pcr.nmempcrd
            ,pcr.rowid
        FROM crawcrd pcr
       WHERE ROWID = pr_rowid;

      -- cursor para busca de cartão
      CURSOR cr_crapcrd (pr_cdcooper IN crapcrd.cdcooper%TYPE,
                         pr_nrdconta IN crapcrd.nrdconta%TYPE,
                         pr_nrcrcard IN crapcrd.nrcrcard%TYPE) IS
      SELECT crd.nrcrcard
            ,crd.rowid
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper  AND
             crd.nrdconta = pr_nrdconta  AND
             crd.nrcrcard = pr_nrcrcard  AND
             crd.dtcancel IS NULL;
      rw_crapcrd cr_crapcrd%ROWTYPE;

      -- cursor para cooperado PF
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                         pr_nrdconta IN crapttl.nrdconta%TYPE,
                         pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
      SELECT ttl.idseqttl
            ,ttl.nrcpfcgc
            ,ttl.vlsalari
            ,ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper AND
             ttl.nrdconta = pr_nrdconta AND
             ttl.nrcpfcgc = pr_nrcpfcgc;
      rw_crapttl cr_crapttl%ROWTYPE;
      
      -- Buscar o código do grupo de afinidade, ignorando os parametros
      -- que estejam sendo passados como null
      CURSOR cr_crawcrd_cdgrafin(pr_cdcooper IN crawcrd.cdcooper%TYPE
                                ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                                ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE
                                ,pr_insitcrd IN crawcrd.insitcrd%TYPE
                                ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE) IS 
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND (pcr.nrcctitg = pr_nrcctitg OR pr_nrcctitg IS NULL)
           AND (pcr.nrcpftit = pr_nrcpftit OR pr_nrcpftit IS NULL)
           AND pcr.dtcancel IS NULL
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           -- Se o parametro vir nulo, deve considerar as situações 3 e 4
           AND (pcr.insitcrd = pr_insitcrd OR (pr_insitcrd IS NULL AND pcr.insitcrd IN (3,4)))
           AND (pcr.flgprcrd = pr_flgprcrd OR pr_flgprcrd IS NULL);

      -- Buscar o código do grupo de afinidade, ignorando os parametros
      -- que estejam sendo passados como null
      CURSOR cr_crawcrd_em_uso(pr_cdcooper IN crawcrd.cdcooper%TYPE
                              ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                              ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                              ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE
                              ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE) IS 
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND (pcr.nrcctitg = pr_nrcctitg OR pr_nrcctitg IS NULL)
           AND (pcr.nrcpftit = pr_nrcpftit OR pr_nrcpftit IS NULL)
           AND pcr.dtcancel IS NULL
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           -- Se o parametro vir nulo, deve considerar as situações 3 e 4
           AND pcr.insitcrd IN (3,4)
           AND (pcr.flgprcrd = pr_flgprcrd OR pr_flgprcrd IS NULL)
           -- Para o cartao em uso, não pode existir um cartão solicitado
           AND NOT EXISTS (SELECT 1
                         FROM crawcrd t
                        WHERE t.cdcooper = pcr.cdcooper
                          AND t.nrdconta = pcr.nrdconta
                          AND t.nrcctitg = pcr.nrcctitg
                          AND t.nrcpftit = pcr.nrcpftit
                          AND t.insitcrd = 2 -- Solicitado
                          AND t.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
                          );

      CURSOR cr_crawcrd_cdgrafin_conta(pr_cdcooper IN crawcrd.cdcooper%TYPE
                                      ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                      ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                                      ,pr_dtmvtolt IN crawcrd.dtcancel%TYPE) IS 
        SELECT max(pcr.dtpropos) dtpropos,
               pcr.cdadmcrd,
               pcr.dddebito,
               pcr.vllimcrd,
               pcr.tpdpagto,
               pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND (pcr.dtcancel = pr_dtmvtolt OR pcr.insitcrd IN (5,6))
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           AND pcr.flgprcrd = 1
      GROUP BY pcr.cdadmcrd,
               pcr.dddebito,
               pcr.vllimcrd,
               pcr.tpdpagto,
               pcr.flgdebcc;
      rw_crawcrd_cdgrafin_conta cr_crawcrd_cdgrafin_conta%ROWTYPE;
               
      -- Buscar cartão liberado que tenha um outro cancelado na mesma data ( Ou seja: Up/Downgrade)
      CURSOR cr_crawcrd_cancel(pr_cdcooper IN crawcrd.cdcooper%TYPE
                              ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                              ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                              ,pr_insitcrd IN crawcrd.insitcrd%TYPE
                              ,pr_dtmvtolt IN crawcrd.dtcancel%TYPE ) IS
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND pcr.insitcrd = pr_insitcrd 
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob 
           AND EXISTS (SELECT 1
                         FROM crawcrd t
                        WHERE t.cdcooper = pcr.cdcooper
                          AND t.nrdconta = pcr.nrdconta
                          AND t.nrcctitg = pcr.nrcctitg
                          AND t.insitcrd = 6 -- Encerrado
                          AND t.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
                          AND t.dtcancel = pr_dtmvtolt);
      
      -- Buscar o código do grupo de afinidade de cartão solicitado, em uso ou liberado
      CURSOR cr_crawcrd_ativo(pr_cdcooper IN crawcrd.cdcooper%TYPE
                             ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                             ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                             ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE
                             ,pr_rowid    IN ROWID) IS 
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND pcr.nrcpftit = pr_nrcpftit
           AND pcr.rowid <> pr_rowid
           AND pcr.dtcancel IS NULL
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           AND pcr.insitcrd IN (2,3,4);
      
      -- cursor para encontrar dados de associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtnasctl
            ,ass.cdagenci
            ,crapage.nmextage
        FROM crapass ass
        JOIN crapage
          ON crapage.cdcooper = ass.cdcooper
         AND crapage.cdagenci = ass.cdagenci
       WHERE ass.cdcooper = pr_cdcooper AND
             ass.nrdconta = pr_nrdconta ;
      rw_crapass cr_crapass%ROWTYPE;

      -- cursor para encontrar dados de representanta
      CURSOR cr_crapass_avt (pr_cdcooper IN crapass.cdcooper%TYPE,
                             pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nmprimtl
            ,ttl.vlsalari
            ,ass.cdagenci
        FROM crapass ass,
             crapttl ttl
       WHERE ass.cdcooper = pr_cdcooper  AND
             ass.nrcpfcgc = pr_nrcpfcgc  AND
             ttl.cdcooper = ass.cdcooper AND
             ttl.nrcpfcgc = ass.nrcpfcgc;
      rw_crapass_avt cr_crapass_avt%ROWTYPE;

      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE,
                         pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT jur.dtiniatv
            ,jur.nrinsest
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper AND
             jur.nrdconta = pr_nrdconta ;
      rw_crapjur cr_crapjur%ROWTYPE;

      -- cursor para encontrar dados do avalista de PJ
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
                         pr_nrdconta IN crapavt.nrdconta%TYPE,
                         pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
      SELECT avt.nrdconta
            ,avt.tpdocava
            ,avt.nmdavali
            ,avt.cdestcvl
            ,avt.nrcpfcgc
            ,avt.nrdocava
            ,avt.idorgexp
            ,avt.cdufddoc
            ,avt.dtnascto
            ,DECODE(avt.cdsexcto,1,'2',2,'1','0') sexbancoob
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper AND
             avt.nrdconta = pr_nrdconta AND
             avt.nrcpfcgc = pr_nrcpfcgc ;
      rw_crapavt cr_crapavt%ROWTYPE;
      
      -- Buscar informação de cartão verificando se o mesmo já foi cancelado
      CURSOR cr_crawcrd_encerra(pr_cdcooper     crawcrd.cdcooper%TYPE
                               ,pr_nrdconta     crawcrd.nrdconta%TYPE
                               ,pr_nrcctitg     crawcrd.nrcctitg%TYPE
                               ,pr_nrcrcard     crawcrd.nrcrcard%TYPE) IS
        SELECT 1
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND pcr.nrcrcard = pr_nrcrcard
           AND pcr.insitcrd = 6;
      rw_crawcrd_encerra   cr_crawcrd_encerra%ROWTYPE;
      
      -- Busca as informacoes de Cartao do tipo Outros pela sequencia
      CURSOR cr_crawcrd_outros(pr_cdcooper crawcrd.cdcooper%TYPE
                              ,pr_nrseqcrd crawcrd.nrseqcrd%TYPE) IS
        SELECT crawcrd.nrdconta
          FROM crawcrd
         WHERE crawcrd.cdcooper = pr_cdcooper  
           AND crawcrd.cdadmcrd >= 10
           AND crawcrd.cdadmcrd <= 80
           AND crawcrd.nrseqcrd = pr_nrseqcrd
           AND ROWNUM = 1;
      rw_crawcrd_outros cr_crawcrd_outros%ROWTYPE;
      
      -- Busca as informacoes de Cartao do tipo Outros pela conta cartao
      CURSOR cr_crawcrd_outros_nrcctitg(pr_cdcooper crawcrd.cdcooper%TYPE
                                       ,pr_nrcctitg crawcrd.nrcctitg%TYPE) IS
      
      SELECT crawcrd.nrdconta
        FROM crawcrd
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.cdadmcrd >= 10
         AND crawcrd.cdadmcrd <= 80
         AND crawcrd.nrcctitg = pr_nrcctitg
         AND ROWNUM = 1;
      rw_crawcrd_outros_nrcctitg cr_crawcrd_outros_nrcctitg%ROWTYPE;
      
      -- Tabela de Limite de Credito
      CURSOR cr_craptlc(pr_cdcooper craptlc.cdcooper%TYPE,
                        pr_cdadmcrd craptlc.cdadmcrd%TYPE,
                        pr_vllimcrd craptlc.vllimcrd%TYPE) IS
        SELECT craptlc.cdlimcrd
          FROM craptlc
         WHERE craptlc.cdcooper = pr_cdcooper
           AND craptlc.cdadmcrd = pr_cdadmcrd
           AND craptlc.vllimcrd = pr_vllimcrd
           AND craptlc.dddebito = 0           
           AND ROWNUM = 1;
      rw_craptlc cr_craptlc%ROWTYPE;
      
      -- Tabela de Limite de Credito CECRED
      CURSOR cr_craptlc_cecred(pr_cdcooper TBCRD_CONFIG_CATEGORIA.cdcooper%TYPE
                              ,pr_cdadmcrd TBCRD_CONFIG_CATEGORIA.cdadmcrd%TYPE
                              ,pr_vllimcrd TBCRD_CONFIG_CATEGORIA.vllimite_minimo%TYPE
                              ,pr_tplimcrd TBCRD_CONFIG_CATEGORIA.tplimcrd%TYPE) IS
        SELECT     1 AS cdlimcrd
        FROM       TBCRD_CONFIG_CATEGORIA tbcc
        WHERE      tbcc.cdcooper = pr_cdcooper
        AND        tbcc.cdadmcrd = pr_cdadmcrd
           AND tbcc.tplimcrd = nvl(pr_tplimcrd, 0)
        AND        pr_vllimcrd between tbcc.vllimite_minimo AND tbcc.vllimite_maximo;
      rw_craptlc_cecred cr_craptlc_cecred%ROWTYPE;
      
      -- Buscar o telefone celular do cooperado
      CURSOR cr_craptfc(pr_cdcooper craptfc.cdcooper%TYPE 
                       ,pr_nrdconta craptfc.nrdconta%TYPE ) IS
        SELECT tfc.nrdddtfc
             , tfc.nrtelefo 
      	  FROM craptfc tfc 
      	 WHERE tfc.cdcooper = pr_cdcooper 
      	   AND tfc.nrdconta = pr_nrdconta 
	         AND tfc.tptelefo = 2  -- Celular 
           AND tfc.idseqttl = 1
           AND tfc.idsittfc = 1 /* Ativo */
         ORDER BY tfc.cdseqtfc DESC;  -- Para o caso de mais de um telefone cadastrado, utilizar o último
      rw_craptfc   cr_craptfc%ROWTYPE;
	  --cursor para validar código administrador na crawcrd
	   CURSOR cr_cdadmcrd(pr_cdgrafin IN crawcrd.cdadmcrd%TYPE) IS
        SELECT crapacb.cdadmcrd
          from crapacb crapacb
         where crapacb.cdgrafin = pr_cdgrafin; --será alimentado pela substr
      rw_cdadmcrd cr_cdadmcrd%rowtype;
    --cursor para validar código administrador na crapcrd
      CURSOR cr_crapcrd_cdadmcrd(pr_rowid IN ROWID) IS
        SELECT crd.cdadmcrd FROM crapcrd crd WHERE ROWID = pr_rowid;
      rw_crapcrd_cdadmcrd cr_crapcrd_cdadmcrd%ROWTYPE;
            
      -- Buscar atualizações de limite provenientes do SAS
      CURSOR cr_atulimi(pr_cdcooper IN tbcrd_limite_atualiza.cdcooper%TYPE
                       ,pr_nrdconta IN tbcrd_limite_atualiza.nrdconta%TYPE
                       ,pr_nrctacrd IN tbcrd_limite_atualiza.nrconta_cartao%TYPE
                       ,pr_vllimalt IN tbcrd_limite_atualiza.vllimite_alterado%TYPE) IS
        SELECT ROWID dsdrowid
              ,atu.cdadmcrd
          FROM tbcrd_limite_atualiza  atu
         WHERE atu.cdcooper          = pr_cdcooper
           AND atu.nrdconta          = pr_nrdconta
           AND atu.nrconta_cartao    = pr_nrctacrd
           AND atu.vllimite_alterado = pr_vllimalt
           AND atu.tpsituacao        = 2    /* Enviado ao Bancoob */
           AND atu.cdcanal           = 14;  /* SAS */
      rw_atulimi   cr_atulimi%ROWTYPE;
      
      -- Buscar o parametro de envio de SMS de cada cooperativa para o produto CARTAO DE CREDITO
      CURSOR cr_enviasms  IS 
        SELECT par.cdcooper
             , par.flgenvia_sms 
          FROM tbgen_sms_param par
             , crapcop         cop
          WHERE par.cdproduto   = 21  -- CARTAO CREDITO CECRED 
            AND par.cdcooper    = cop.cdcooper(+)
            AND cop.flgativo(+) = 1; -- Coops ativas
      
      -------------------- PROCEDIMENTOS INTERNOS ------------------------------
      /* Função para mascarar do numero do cartao */
      FUNCTION fn_mask_cartao(pr_nrcrcard VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        RETURN SUBSTR(pr_nrcrcard, 1, 4) || '.****.****.' || SUBSTR(pr_nrcrcard, length(pr_nrcrcard) -3, 4);
      END;
                   
      PROCEDURE altera_sit_cartao_aprovado(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                           pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                           pr_nrseqcrd IN crawcrd.nrseqcrd%TYPE)IS
        -- Atualiza registro de Proposta de Cartão de Crédito novamente para aprovado
        BEGIN
          UPDATE crawcrd
             SET insitcrd = 1 -- Aprovado
           WHERE crawcrd.cdcooper = pr_cdcooper
             AND crawcrd.nrdconta = pr_nrdconta
             --AND crawcrd.nrctrcrd = pr_nrctrcrd; Não deve mais utilizar o código do contrato
             AND crawcrd.nrseqcrd = pr_nrseqcrd; -- Código do contrato enviado ao Bancoob
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
      END altera_sit_cartao_aprovado;
      
      PROCEDURE altera_data_rejeicao(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                     pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                     pr_nrseqcrd IN crawcrd.nrseqcrd%TYPE,
                                     pr_dtmvtolt IN crawcrd.dtmvtolt%TYPE)IS
        -- Atualiza a data de Rejeicao da proposta
        BEGIN
            UPDATE crawcrd
               SET dtrejeit = pr_dtmvtolt
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.nrseqcrd = pr_nrseqcrd -- Código do contrato enviado ao Bancoob
               AND ((crawcrd.dtrejeit IS NULL) OR (pr_dtmvtolt IS NULL));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
            
      END altera_data_rejeicao;

      -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
      PROCEDURE atualiza_nmtitcrd(pr_cdcooper IN craprej.cdcooper%TYPE,
                                  pr_cdagenci IN craprej.cdagenci%TYPE,
                                  pr_nrdconta IN craprej.nrdconta%TYPE,
                                  pr_dtmvtolt IN craprej.dtmvtolt%TYPE,
                                  pr_cdpesqbb IN craprej.cdpesqbb%TYPE)IS
        
        BEGIN
           UPDATE craprej rej
            SET rej.cdpesqbb = pr_cdpesqbb
           WHERE rej.cdcooper = pr_cdcooper
            AND rej.cdagenci = pr_cdagenci
            AND rej.nrdconta = pr_nrdconta
            AND rej.dtmvtolt = pr_dtmvtolt
            AND rej.cdpesqbb IS NULL;


        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar craprej: '||SQLERRM;

      END atualiza_nmtitcrd;
      
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_xml_clobxml IN OUT CLOB,
                               pr_des_dados   IN VARCHAR2) IS
        BEGIN
          -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
          dbms_lob.writeappend(pr_xml_clobxml, length(pr_des_dados), pr_des_dados);
        END;
      
      -- Atualiza os dados do cartao de credito
      PROCEDURE atualiza_dados_cartao(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                      pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                      pr_cdagenci IN crapass.cdagenci%TYPE,
                                      pr_nrdctitg IN crawcrd.nrcctitg%TYPE,
                                      pr_vllimcrd IN crawcrd.vllimcrd%TYPE,
                                      pr_dddebito IN crawcrd.dddebito%TYPE,
                                      pr_flgdebcc IN INTEGER,
                                      pr_tpdpagto IN INTEGER,
                                      pr_nmrescop IN crapcop.nmrescop%TYPE,
                                      pr_nmextage IN crapage.nmextage%TYPE,
                                      pr_nmprimtl IN crapass.nmprimtl%TYPE,
                                      pr_rwatulim IN cr_atulimi%ROWTYPE,
                                      pr_xml_lim_cartao IN OUT CLOB,
                                      pr_des_erro OUT VARCHAR2,
                                      pr_cdcritic OUT INTEGER,
                                      pr_dscritic OUT VARCHAR2) IS
                        
        -- Buscar todos os cartao da conta integracao
        CURSOR cr_crawcrd_limite(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                 pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                 pr_nrcctitg IN crawcrd.nrcctitg%TYPE) IS
          SELECT crawcrd.cdadmcrd,
                 crawcrd.vllimcrd,
                 crawcrd.nrcrcard,
                 crawcrd.nrcpftit,
                 crawcrd.nrcctitg,
                 crawcrd.nrdconta,
                 crawcrd.cdcooper,
                 row_number() over(partition by crawcrd.cdcooper, crawcrd.nrdconta, crawcrd.cdadmcrd
                                       order by crawcrd.cdcooper, crawcrd.nrdconta, crawcrd.cdadmcrd) nrseqreg,
                 progress_recid
            FROM crawcrd
           WHERE crawcrd.cdcooper = pr_cdcooper
             AND crawcrd.nrdconta = pr_nrdconta
             AND crawcrd.nrcctitg = pr_nrcctitg;
        
        -- Busca o Bandeira da Administradora
        CURSOR cr_crapadc(pr_cdcooper IN crapadc.cdcooper%TYPE,
                          pr_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
          SELECT nmbandei,
                 cdadmcrd,
                 nmresadm
            FROM crapadc
           WHERE crapadc.cdcooper = pr_cdcooper
             AND crapadc.cdadmcrd = pr_cdadmcrd;
        rw_crapadc cr_crapadc%ROWTYPE;
      
        --Variaveis de Excecao
        vr_exc_erro   EXCEPTION;
        vr_craptlc    BOOLEAN := FALSE;
        vr_cdlimcrd   crawcrd.cdlimcrd%TYPE; --> Codigo da linha do valor de credito
        vr_nrcrcard   VARCHAR2(19);
        vr_primvez    BOOLEAN := TRUE;
          
        PROCEDURE atualiza_historico_limite(pr_cdcooper  IN crawcrd.cdcooper%TYPE,
                                            pr_nrdconta  IN crawcrd.nrdconta%TYPE,
                                            pr_nrdctitg  IN crawcrd.nrcctitg%TYPE,                                          
                                            pr_rwatulim  IN cr_atulimi%ROWTYPE,
                                            pr_rwcrawcrd IN cr_crawcrd_limite%ROWTYPE,
                                            pr_cdcritic OUT INTEGER,
                                            pr_dscritic OUT VARCHAR2) IS
        
          vr_idlotaux   tbgen_sms_lote.idlote_sms%TYPE; --> Lote do SMS auxiliar
        
            BEGIN
          -- zerar lote
          vr_idlotsms := 0;
          
              -- Se foi informado o rowid da alteração de limite
          IF pr_rwatulim.dsdrowid IS NOT NULL THEN
                
            -- Atualizaremos a alteração do limite se for o mesmo cartão da atualização
            -- e se for o primeiro cartao (para nao enviar sms para os adicionais).
            IF pr_rwatulim.cdadmcrd  = pr_rwcrawcrd.cdadmcrd AND 
               pr_rwcrawcrd.nrseqreg = 1 THEN
                
                -- verifica se deve enviar SMS
                IF NVL(vr_tab_enviasms(pr_cdcooper),0) = 1 THEN
                  -- Buscar o cadastro do celular do cooperado
                  OPEN  cr_craptfc(pr_cdcooper -- pr_cdcooper
                                  ,pr_nrdconta); -- pr_nrdconta 
                  FETCH cr_craptfc INTO rw_craptfc;
                  
                  -- Se encontrar cadastro de celular
                  IF cr_craptfc%FOUND THEN

                    -- Popular a variável com os valores dinâmicos para a rotina
                    vr_dsvlrmsg := '#DescricaoCartao#='||rw_crapadc.nmresadm;

                    -- Montar a mensagem a ser enviada
                    vr_dsmsgsms := GENE0003.fn_buscar_mensagem(pr_cdcooper          => pr_cdcooper
                                                              ,pr_cdproduto         => 21 -- CARTAO CREDITO CECRED
                                                              ,pr_cdtipo_mensagem   => 22 -- Tipo de mensagem 
                                                              ,pr_sms               => 1  -- Indicador de SMS 
                                                              ,pr_valores_dinamicos => vr_dsvlrmsg);
                    
                    -- Se não há lote de SMS criado na cooperativa
                    IF NOT vr_vet_nrdlote.EXISTS(pr_cdcooper) THEN
                      -- Cria o lote de sms
                      esms0001.pc_cria_lote_sms(pr_cdproduto     => 21 -- CARTAO CREDITO CECRED
                                               ,pr_idtpreme      => 'SMSCRDBCB'
                                               ,pr_dsagrupador   => pr_nmrescop
                                               ,pr_idlote_sms    => vr_idlotsms
                                               ,pr_dscritic      => pr_dscritic);
                      
                      -- Se retornar erro 
                      IF pr_dscritic IS NOT NULL THEN
                        RAISE vr_exc_erro;
                      END IF;

                       vr_vet_nrdlote(pr_cdcooper).vrlimtsms := 0;
                      
                    END IF;
                      
                    --Se existe e se tiver mais de um registro no lote
                    IF  vr_vet_nrdlote.EXISTS(pr_cdcooper) AND  vr_vet_nrdlote(pr_cdcooper).vrlimtsms > 1  THEN
                      
                        --Se no lote ter mais de mil registro, criar outro lote.
                      	IF mod(nvl(vr_vet_nrdlote(pr_cdcooper).vrlimtsms,0), 1000) = 0 THEN
                            -- Cria o lote de sms
                       		esms0001.pc_cria_lote_sms(pr_cdproduto     => 21 -- CARTAO CREDITO CECRED
                                               ,pr_idtpreme      => 'SMSCRDBCB'
                                               ,pr_dsagrupador   => pr_nmrescop
                                               ,pr_idlote_sms    => vr_idlotsms
                                               ,pr_dscritic      => pr_dscritic);
                      
                            -- Se retornar erro                       
                        	IF pr_dscritic IS NOT NULL THEN
                         	 RAISE vr_exc_erro;
                        	END IF;
                      	END IF;  
                    END IF; -- vr_idlotsms IS NULL
                    
                    vr_vet_nrdlote(pr_cdcooper).vrlimtsms := nvl(vr_vet_nrdlote(pr_cdcooper).vrlimtsms,0) + 1;
                    
                    IF vr_idlotsms > 0 THEN                    
                      IF NOT (INSTR(vr_vet_nrdlote(pr_cdcooper).lsnrdlote || ';',';' || vr_idlotsms ||';') > 0) THEN
                        vr_vet_nrdlote(pr_cdcooper).lsnrdlote := TRIM(vr_vet_nrdlote(pr_cdcooper).lsnrdlote) || ';' || vr_idlotsms;  
                        --setar ultimo lote 
                        vr_vet_nrdlote(pr_cdcooper).vrultlote := vr_idlotsms;
                      END IF;
                    END IF;
                                                              
                    -- Gerar registro do SMS a ser enviado
                    esms0001.pc_escreve_sms(pr_idlote_sms => vr_vet_nrdlote(pr_cdcooper).vrultlote
                                           ,pr_cdcooper   => pr_cdcooper
                                           ,pr_nrdconta   => pr_nrdconta
                                           ,pr_idseqttl   => 1
                                           ,pr_dhenvio    => SYSDATE
                                         ,pr_nrddd      => rw_craptfc.nrdddtfc
                                         ,pr_nrtelefone => rw_craptfc.nrtelefo
                                           ,pr_cdtarifa   => NULL
                                           ,pr_dsmensagem => vr_dsmsgsms
                                           ,pr_idsms      => vr_idsms
                                           ,pr_dscritic   => pr_dscritic);
                    
                    -- Se retornar erro 
                    IF pr_dscritic IS NOT NULL THEN
                      RAISE vr_exc_erro;
                    END IF;
                    
                  END IF; -- cr_craptfc%FOUND
                  
                  -- Fechar o cursor
                  CLOSE cr_craptfc;
                  
                vr_idlotaux := vr_vet_nrdlote(pr_cdcooper).vrultlote; -- Carrega o id do lote na var auxiliar
              ELSE
                vr_idlotaux := null;        -- Esvazia o id do lote na var auxiliar
                END IF;  -- NVL(vr_enviasms,0) = 1 -- Se envia SMS
                
              -- Atualiza os dados do registro de controle de alteração de limite
              BEGIN
                UPDATE tbcrd_limite_atualiza atu
                   SET atu.dtretorno  = SYSDATE
                     , atu.tpsituacao = 3   /* Concluido com Sucesso */
                     , atu.idlote_sms = vr_idlotaux
                 WHERE ROWID = pr_rwatulim.dsdrowid;
              EXCEPTION 
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao atualizar tbcrd_limite_atualiza: ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;
                
            END IF; -- IF pr_rwatulim.cdadmcrd = rw_crawcrd_limite.cdadmcrd THEN
                
              ELSE  -- Se não foi informado
                
            -- Soh entraremos se for a primeira vez por conta cartao, para nao criar historicos excessivos
            IF vr_primvez THEN
                -- Verifica se houve alteração do limite
              IF pr_vllimcrd <> pr_rwcrawcrd.vllimcrd THEN
                  
                  -- Insere o registro de atualização de limite
                  BEGIN
                    INSERT INTO tbcrd_limite_atualiza
                                   (cdcooper
                                   ,nrdconta
                                   ,nrconta_cartao
                                   ,dtalteracao
                                   ,dtretorno
                                   ,tpsituacao
                                   ,vllimite_anterior
                                   ,vllimite_alterado
                                   ,cdcanal
                                 ,cdcribcb
                                 ,cdadmcrd)
                          VALUES (pr_cdcooper                 -- cdcooper
                                 ,pr_nrdconta                 -- nrdconta
                                 ,pr_nrdctitg                 -- nrconta_cartao
                                 ,SYSDATE                     -- dtalteracao
                                 ,SYSDATE                     -- dtretorno
                                 ,3 -- Concluído com Sucesso  -- tpsituacao 
                                 ,pr_rwcrawcrd.vllimcrd       -- vllimite_anterior
                                 ,pr_vllimcrd                 -- vllimite_alterado
                                 ,15 -- Sipagnet              -- cdcanal
                                 ,NULL                        -- cdcribcb
                                 ,pr_rwcrawcrd.cdadmcrd);-- cdadmcrd                     
                  EXCEPTION 
                    WHEN OTHERS THEN
                      pr_dscritic := 'Erro ao inserir tbcrd_limite_atualiza: ' || SQLERRM;
                      RAISE vr_exc_erro;
                  END;              
                vr_primvez := FALSE;
                                  
              END IF;  --  pr_vllimcrd <> rw_crawcrd_limite.vllimcrd 
            END IF;  -- IF vr_primvez THEN
          END IF;  -- pr_rwatulim IS NOT NULL
          
        EXCEPTION
          WHEN vr_exc_erro THEN
            pr_des_erro := 'NOK';
          WHEN OTHERS THEN
            pr_des_erro := 'NOK';
            --Variavel de erro recebe erro ocorrido
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao atualizar os dados do cartao. Rotina PC_CRPS672.atualiza_historico_limite. '||sqlerrm;
        END atualiza_historico_limite;
          
      BEGIN
        
        pr_des_erro := 'NOK';
        vr_cdlimcrd := 0;
        
        /* Vamos atualizar todos os cartoes de acordo com a conta integracao que veio no arquivo */
        FOR rw_crawcrd_limite IN cr_crawcrd_limite(pr_cdcooper => pr_cdcooper,
                                                   pr_nrdconta => pr_nrdconta,
                                                   pr_nrcctitg => pr_nrdctitg) LOOP
          
          -- Para cada Administradora vamos buscar o Limite de Credito
          IF rw_crawcrd_limite.nrseqreg = 1 THEN
            
            -- Vamos buscar a Bandeira da Administradora
            OPEN cr_crapadc(pr_cdcooper => pr_cdcooper,
                            pr_cdadmcrd => rw_crawcrd_limite.cdadmcrd);
            FETCH cr_crapadc INTO rw_crapadc;
            IF cr_crapadc%NOTFOUND THEN
              CLOSE cr_crapadc;
              pr_dscritic := 'Administradora nao encontrada. Codigo: ' || TO_CHAR(rw_crawcrd_limite.cdadmcrd);
              RAISE vr_exc_erro;              
              
            ELSE
              CLOSE cr_crapadc;
            END IF;          
            
            -- Somente a administadora diferente de MAESTRO que ira ter Limite cadastrado
            IF UPPER(rw_crapadc.nmbandei) <> 'MAESTRO' THEN
			        vr_cdlimcrd := 0;

              -- Para cada cartao, vamos buscar o valor de limite de credito cadastrado
              OPEN cr_craptlc(pr_cdcooper => pr_cdcooper,
                              pr_cdadmcrd => rw_crawcrd_limite.cdadmcrd,
                              pr_vllimcrd => pr_vllimcrd);
              FETCH cr_craptlc INTO rw_craptlc;
              vr_craptlc := cr_craptlc%FOUND;
              CLOSE cr_craptlc;
              
              -- Se nao encontrou, vamos tentar buscar os limites na nova tabela
              IF NOT vr_craptlc THEN
                -- CECRED
                OPEN cr_craptlc_cecred(pr_cdcooper => pr_cdcooper
                                      ,pr_cdadmcrd => rw_crawcrd_limite.cdadmcrd
                                      ,pr_vllimcrd => pr_vllimcrd
                                      ,pr_tplimcrd => vr_tplimcrd);
                FETCH cr_craptlc_cecred INTO rw_craptlc_cecred;
                vr_craptlc := cr_craptlc_cecred%FOUND;
                CLOSE cr_craptlc_cecred;
              ELSE
              vr_cdlimcrd := rw_craptlc.cdlimcrd;
              END IF;
            ELSE
              vr_craptlc := TRUE;  
            END IF;  
            
          END IF; /* END IF rw_crawcrd_limite.nrseqreg = 1 THEN */
          
          if vr_tab_reg_upgrade.exists(rw_crawcrd_limite.nrcpftit||
                                       rw_crawcrd_limite.nrcctitg||
                                       rw_crawcrd_limite.nrcrcard) then
                                    
            -- Administradora dos cartões   
            OPEN cr_cdadmcrd(pr_cdgrafin => vr_cdgrafin);
            FETCH cr_cdadmcrd
            INTO rw_cdadmcrd;
          
            CLOSE cr_cdadmcrd;
            
            BEGIN
              UPDATE crawcrd
                 SET cdadmcrd = nvl(rw_cdadmcrd.cdadmcrd, 0)
               where crawcrd.progress_recid = rw_crawcrd_limite.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar crawcrd[1]: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;      
            
            BEGIN
              UPDATE crapcrd
                 SET cdadmcrd = nvl(rw_cdadmcrd.cdadmcrd, 0)
               where crapcrd.cdcooper = rw_crawcrd_limite.cdcooper
                 and crapcrd.nrdconta = rw_crawcrd_limite.nrdconta
                 and crapcrd.nrcrcard = rw_crawcrd_limite.nrcrcard;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar crapcrd[1]: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;                                    
          end if;
          
          -- Vamos verificar se o Limite existe
       /* Anderson - conforme INC0022475 e orientação negócio devemos importar 
          o limite do Sipagnet mesmo que superior ao configurado no Aimaro 
          IF NOT vr_craptlc THEN
            vr_nrcrcard := TO_CHAR(rw_crawcrd_limite.nrcrcard);
            vr_nrcrcard := fn_mask_cartao(vr_nrcrcard);
            
            -- Caso nao achou o Limite de Credito, vamos armazenar no XML para a geracao do relatorio
            pc_escreve_xml(pr_xml_lim_cartao,'<Dados>'||
                                                 '<cdcooper>'||pr_cdcooper||'</cdcooper>'||
                                                 '<nmrescop>'||pr_nmrescop||'</nmrescop>'||
                                                 '<cdagenci>'||pr_cdagenci||'</cdagenci>'||
                                                 '<nmextage>'||pr_nmextage||'</nmextage>'||
                                                 '<nrdconta>'||LTrim(gene0002.fn_mask_conta(pr_nrdconta))||'</nrdconta>'||
                                                 '<nrcrcard>'|| vr_nrcrcard ||'</nrcrcard>'||                                                 
                                                 '<nmprimtl>'||pr_nmprimtl||'</nmprimtl>'||
                                                 '<cdadmcrd>'||rw_crapadc.cdadmcrd||'</cdadmcrd>'||
                                                 '<nmresadm>'||rw_crapadc.nmresadm||'</nmresadm>'||
                                                 '<limite_bancoob>'||to_char(pr_vllimcrd,'fm999g999g990d00')||'</limite_bancoob>'||
                                                 '<limite_ayllos>'||to_char(rw_crawcrd_limite.vllimcrd,'fm999g999g990d00')||'</limite_ayllos>'||
                                             '</Dados>');
          ELSE */
            -- Atualiza os dados do cartao de credito
            BEGIN
              UPDATE crawcrd SET 
                     dddebant = crawcrd.dddebito,
                     dddebito = pr_dddebito,
                     flgdebcc = pr_flgdebcc,
                     tpdpagto = pr_tpdpagto,
                     vllimcrd = pr_vllimcrd,
                     cdlimcrd = vr_cdlimcrd
               WHERE crawcrd.progress_recid = rw_crawcrd_limite.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar crawcrd: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;    
                
            /* Procedimento responsavel por atualizar o historico de limites da conta cartao,
               bem como, por atualizar o status das majoracoes de limite, quando for o caso.
               Tambem cria as mensagens de SMS para envio para o cooperado. */
            atualiza_historico_limite(pr_cdcooper  => pr_cdcooper,
                                      pr_nrdconta  => pr_nrdconta,
                                      pr_nrdctitg  => pr_nrdctitg,
                                      pr_rwatulim  => pr_rwatulim,
                                      pr_rwcrawcrd => rw_crawcrd_limite,
                                      pr_cdcritic  => pr_cdcritic,
                                      pr_dscritic  => pr_dscritic);
            IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
                
          --END IF;                    
                      
        END LOOP; /* END FOR rw_crawcrd_limite */
        
        pr_des_erro := 'OK';
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'NOK';
        WHEN OTHERS THEN
          pr_des_erro := 'NOK';
          --Variavel de erro recebe erro ocorrido
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar os dados do cartao. Rotina PC_CRPS672.atualiza_dados_cartao. '||sqlerrm;

      END atualiza_dados_cartao;
      
      -- Atualiza a situacao do cartao de credito
      PROCEDURE atualiza_situacao_cartao(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                         pr_nrcrcard IN crawcrd.nrcrcard%TYPE,
                                         pr_insitcrd IN crawcrd.insitcrd%TYPE,
                                         pr_dtmvtolt IN DATE,
                                         pr_des_erro OUT VARCHAR2,
                                         pr_cdcritic OUT INTEGER,
                                         pr_dscritic OUT VARCHAR2) IS
        
        -- Tabela de Limite de Credito
        CURSOR cr_tbcrd_situacao(pr_cdsitadm tbcrd_situacao.cdsitadm%TYPE) IS
          SELECT cdsitcrd,
                 cdmotivo
            FROM tbcrd_situacao
           WHERE tbcrd_situacao.cdsitadm = pr_cdsitadm;
        rw_tbcrd_situacao cr_tbcrd_situacao%ROWTYPE;
             
		    CURSOR cr_primeiro_cartao_ativo(pr_cdcooper crawcrd.cdcooper%TYPE
																			 ,pr_nrdconta crawcrd.nrdconta%TYPE
																			 ,pr_cdadmcrd crawcrd.cdadmcrd%TYPE) IS
					SELECT d.nrctrcrd
						FROM crawcrd d
					 WHERE d.cdcooper = pr_cdcooper
						 AND d.nrdconta = pr_nrdconta
						 AND d.cdadmcrd = pr_cdadmcrd
						 AND d.insitcrd NOT IN (5,6) -- bloqueado,cancelado
				ORDER BY d.dtpropos ASC;
				rw_primeiro_cartao_ativo cr_primeiro_cartao_ativo%ROWTYPE;				
             
        -- Buscar os dados do cartao de credito
        CURSOR cr_crawcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                          pr_nrdconta IN crawcrd.nrdconta%TYPE,
                          pr_nrcrcard IN crawcrd.nrcrcard%TYPE) IS                          
          SELECT crawcrd.insitcrd,
                 crawcrd.dtcancel,
                 crawcrd.cdmotivo,
								 crawcrd.flgprcrd
            FROM crawcrd
           WHERE crawcrd.cdcooper = pr_cdcooper
             AND crawcrd.nrdconta = pr_nrdconta
             AND crawcrd.nrcrcard = pr_nrcrcard;
        rw_crawcrd cr_crawcrd%ROWTYPE;
             
        vr_insitcrd crawcrd.insitcrd%TYPE;
        vr_dtcancel crawcrd.dtcancel%TYPE;
        vr_cdmotivo crawcrd.cdmotivo%TYPE;
				vr_cdadmcrd crawcrd.cdadmcrd%TYPE;
        vr_nrdrowid ROWID;
        --Variaveis de Excecao
        vr_exc_erro EXCEPTION;
             
      BEGIN
        
        pr_des_erro := 'NOK';
        
        -- Vamos buscar os dados do cartao
        OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrcrcard => pr_nrcrcard);
        FETCH cr_crawcrd
         INTO rw_crawcrd;
        -- Verifica se existe a situacao cadastrada
        IF cr_crawcrd%NOTFOUND THEN
          CLOSE cr_crawcrd;          
          pr_dscritic := 'Cartao nao encontrado. Conta: ' || TO_CHAR(pr_nrdconta) || '. Cartao: ' || fn_mask_cartao(TO_CHAR(pr_nrcrcard));
          RAISE vr_exc_erro;
        END IF; 
        CLOSE cr_crawcrd;
        
        -- Vamos buscar a situacao do cartao
        OPEN cr_tbcrd_situacao(pr_cdsitadm => pr_insitcrd);
        FETCH cr_tbcrd_situacao 
         INTO rw_tbcrd_situacao;
        -- Verifica se existe a situacao cadastrada
        IF cr_tbcrd_situacao%NOTFOUND THEN
          CLOSE cr_tbcrd_situacao;          
          pr_dscritic := 'Situacao nao encontrada. Conta: ' || TO_CHAR(pr_nrdconta) || '. Situacao: ' || TO_CHAR(pr_insitcrd);
          RAISE vr_exc_erro;            
        END IF;    
        CLOSE cr_tbcrd_situacao;
        
        /* Cancelado */
        IF rw_tbcrd_situacao.cdsitcrd = 6 THEN
          
          BEGIN
            UPDATE crawcrd SET
                   insitcrd = rw_tbcrd_situacao.cdsitcrd,
                   dtcancel = pr_dtmvtolt,
                   cdmotivo = rw_tbcrd_situacao.cdmotivo
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.nrcrcard = pr_nrcrcard
            RETURNING insitcrd,
                      dtcancel,
                      cdmotivo,
											cdadmcrd
                 INTO vr_insitcrd,
                      vr_dtcancel,
                      vr_cdmotivo,
											vr_cdadmcrd;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar crawcrd: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
					
					-- Se o cartao recem cancelado era titular, devemos repassar a titularidade
					IF rw_crawcrd.flgprcrd = 1 THEN
						OPEN cr_primeiro_cartao_ativo(pr_cdcooper => pr_cdcooper,
																		      pr_nrdconta => pr_nrdconta,
																		      pr_cdadmcrd => vr_cdadmcrd);
						FETCH cr_primeiro_cartao_ativo INTO rw_primeiro_cartao_ativo;
						--
						IF cr_primeiro_cartao_ativo%FOUND THEN
							 --
							 BEGIN
								 UPDATE crawcrd d
										SET d.flgprcrd = 1
									WHERE d.cdcooper = pr_cdcooper
										AND d.nrdconta = pr_nrdconta
										AND d.nrctrcrd = rw_primeiro_cartao_ativo.nrctrcrd;
							 EXCEPTION
							 WHEN OTHERS THEN
									CLOSE cr_primeiro_cartao_ativo;
									pr_dscritic := 'Erro ao vincular novo titular. Erro: '||SQLERRM;
									RAISE vr_exc_erro;
							 END;
						END IF;
						--
						CLOSE cr_primeiro_cartao_ativo;
					END IF;
          
        ELSE
          
          BEGIN
            UPDATE crawcrd SET
                   insitcrd = rw_tbcrd_situacao.cdsitcrd,
                   dtcancel = NULL,
                   cdmotivo = 0
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.nrcrcard = pr_nrcrcard
            RETURNING insitcrd,
                      dtcancel,
                      cdmotivo
                 INTO vr_insitcrd,
                      vr_dtcancel,
                      vr_cdmotivo;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar crawcrd: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        
        END IF;
        
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                                     pr_cdoperad => '1',
                                                       pr_dscritic => '',
                                                       pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(1)),
                                                       pr_dstransa => 'Alterar Situacao Cartao de Credito',
                                                       pr_dttransa => TRUNC(SYSDATE),
                                                       pr_flgtrans => 1,
                                                       pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
                                                       pr_idseqttl => 0,
                                                       pr_nmdatela => 'PC_CRPS672',
                                                       pr_nrdconta => pr_nrdconta,
                                                       pr_nrdrowid => vr_nrdrowid);

        -- Numero do Cartao
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                                                  pr_nmdcampo => 'Cartao',
                                                                  pr_dsdadant => '',
                                                                  pr_dsdadatu => pr_nrcrcard);
                                  
        -- Situacao do Cartao
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                                                  pr_nmdcampo => 'Situacao',
                                                                  pr_dsdadant => rw_crawcrd.insitcrd,
                                                                  pr_dsdadatu => vr_insitcrd);
        
        -- Data de Cancelamento
        IF rw_crawcrd.dtcancel <> vr_dtcancel THEN
           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'Data Canc.',
                                     pr_dsdadant => rw_crawcrd.dtcancel,
                                     pr_dsdadatu => vr_dtcancel);
        END IF;
        
        -- Motivo
        IF rw_crawcrd.cdmotivo <> vr_cdmotivo THEN
           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'Motivo',
                                     pr_dsdadant => rw_crawcrd.cdmotivo,
                                     pr_dsdadatu => vr_cdmotivo);
        END IF;
                                
        pr_des_erro := 'OK';
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'NOK';
        WHEN OTHERS THEN
          pr_des_erro := 'NOK';
          --Variavel de erro recebe erro ocorrido
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar a situacao do cartao. Rotina PC_CRPS672.atualiza_situacao_cartao. '||sqlerrm;

      END atualiza_situacao_cartao;      

      -- Subrotina para escrever críticas no LOG do processo
      PROCEDURE pc_log_message IS
        BEGIN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper_ori
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',vr_cdcooper_ori,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_dscritic );
            vr_cdcritic := 0;
            vr_dscritic := '';
          END IF;
        END pc_log_message;
      
      PROCEDURE pc_log_dados_arquivo(pr_tipodreg IN NUMBER  -- Tipo de registro: 1 - Dados conta cartao / 2- Dados do cartao
                                    ,pr_nmdarqui IN VARCHAR2 
                                    ,pr_nrdlinha IN NUMBER
                                    ,pr_cdmensagem IN INTEGER
                                    ,pr_dscritic IN VARCHAR2) IS
        vr_dstpdreg VARCHAR2(50);
        vr_dstexto VARCHAR2(2000);
        vr_texto_email VARCHAR2(5000);
        vr_texto_chamado VARCHAR2(5000);
        vr_titulo VARCHAR2(1000);
      BEGIN
        -- verificar qual o tipo de registro do arquivo
        IF pr_tipodreg = 1 THEN
          vr_dstpdreg:= 'Dados da Conta Cartao';
        ELSIF pr_tipodreg = 2 THEN
          vr_dstpdreg:= 'Dados do Cartao';
        ELSE
          vr_dstpdreg:= 'Nao definido';
        END IF;

        -- Texto para utilizar na abertura do chamado e no email enviado
        vr_dstexto:= to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' ||
                     'Erro no tipo de registro ' || nvl(vr_dstpdreg,' ') || '. ' || 
                     gene0001.fn_busca_critica(pr_cdcritic => pr_cdmensagem) || ' Linha '  ||
                     nvl(pr_nrdlinha,0) ||', arquivo: ' || pr_nmdarqui || ', Critica: ' || nvl(pr_dscritic,' ');

        -- Parte inicial do texto do chamado e do email        
        vr_titulo:= '<b>Abaixo os erros encontrados no processo de importacao do arquivo de retorno'||
                    ' da Solicitacao de Cartao Bancoob CABAL</b><br><br>';
                  
        -- Buscar e-mails dos destinatarios do produto cartoes
        vr_destinatario_email:= gene0001.fn_param_sistema('CRED',vr_cdcooper_ori,'CRD_RESPONSAVEL');
                 
        cecred.pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                              ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                              ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               -- Parametros para Ocorrencia
                              ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                              ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                              ,pr_cdmensagem    => pr_cdmensagem
                              ,pr_dsmensagem    => vr_dstexto    --> dscritic       
                              ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                              ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
                              ,pr_texto_chamado => vr_titulo
                              ,pr_destinatario_email => vr_destinatario_email
                              ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
                              ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

        cecred.pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                              ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                              ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               -- Parametros para Ocorrencia
                              ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)  
        
        vr_dscritic := vr_dstexto;
        
      END pc_log_dados_arquivo;

      PROCEDURE pc_log_arq_invalido(pr_nmdarqui IN VARCHAR2) IS
        vr_dstpdreg VARCHAR2(50);
        vr_dstexto VARCHAR2(2000);
        vr_titulo VARCHAR2(1000);
      BEGIN
        -- Texto para utilizar na abertura do chamado e no email enviado
        vr_dstexto:= to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' ||
                     'Arquivo ' || pr_nmdarqui || ' foi recebido incompleto.';

        -- Parte inicial do texto do chamado e do email        
        vr_titulo:= '<b>O arquivo de retorno da Solicitacao de Cartao Bancoob CABAL foi recebido incompleto.</b><br>';
                  
        -- Buscar e-mails dos destinatarios do produto cartoes
        vr_destinatario_email:= gene0001.fn_param_sistema('CRED',vr_cdcooper_ori,'CRD_RESPONSAVEL');
                 
        cecred.pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
                              ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
                              ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               -- Parametros para Ocorrencia
                              ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
                              ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                              ,pr_cdmensagem    => 0             --> pr_cdmensagem
                              ,pr_dsmensagem    => vr_dstexto    --> dscritic       
                              ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
                              ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
                              ,pr_texto_chamado => vr_titulo
                              ,pr_destinatario_email => vr_destinatario_email
                              ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
                              ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

        cecred.pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
                              ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                              ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               -- Parametros para Ocorrencia
                              ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)  
        
        
      END pc_log_arq_invalido;
            
      -- ROTINA RESPONSÁVEL PELA ATUALIZAÇÃO DO REGISTRO DE MAJORAÇÃO
      PROCEDURE pc_atualiza_majoracao(pr_cdcooper  IN  NUMBER
                                     ,pr_nrdconta  IN  NUMBER
                                     ,pr_nrctacrd  IN  NUMBER
                                     ,pr_cdcodigo  IN  VARCHAR2
                                     ,pr_dscritic OUT  VARCHAR2) IS
        
        -- CURSORES
        -- Buscar a descrição do código de erro
        CURSOR cr_crapcrc IS
          SELECT crc.dscritic
            FROM crapcrc crc
           WHERE crc.cdcodigo = pr_cdcodigo;
           
        -- VARIÁVEIS
        vr_cdmajora  NUMBER;
        vr_dscritic  VARCHAR2(500);
        
      BEGIN
        
        -- Se tem código de erro 
        IF pr_cdcritic IS NOT NULL OR pr_cdcodigo IS NOT NULL THEN
          -- Coloca o código de Majoração como REJEITADO
          vr_cdmajora := 2;
          
          -- Buscar a descrição da mensagem de erro
          OPEN  cr_crapcrc;
          FETCH cr_crapcrc INTO vr_dscritic;
          
          -- Se não encontrar o código de erro
          IF cr_crapcrc%NOTFOUND THEN
            vr_dscritic := 'CÓDIGO DE REJEIÇÃO '||pr_cdcodigo||' NÃO ENCONTRADO.';
          END IF;
          
          -- Fecha o cursor
          CLOSE cr_crapcrc;
        ELSE
          -- Coloca o código de Majoração como MAJORADO
          vr_cdmajora := 1;
          -- Não tem mensagem de erro
          vr_dscritic := NULL;
        END IF;
        
        IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',pr_cdcooper,'DB_NAME_PRODUC') THEN --> Produção
    
          -- Atualizar os registros de majoração
          UPDATE integradados.sasf_majoracaocartao@sasp maj
             SET maj.cdmajorado        = vr_cdmajora
               , maj.dtmajoracaocartao = SYSTIMESTAMP
               , maj.dsexclusao        = vr_dscritic
           WHERE maj.cdcooper          = pr_cdcooper
             AND maj.nrdconta          = pr_nrdconta
             AND maj.nrcontacartao     = pr_nrctacrd
             AND maj.cdmajorado        = 4; -- Pendente
        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao atualizar majoracao: '||SQLERRM;
      END pc_atualiza_majoracao;
      
      
    BEGIN
    
      -- extrai dados do XML 
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper_ori
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN 
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => vr_cdcooper_ori);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper_ori);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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
 
      -- Verificar se cooperativa esta no processo ainda
      if rw_crapdat.inproces > 1 AND 
         trunc(sysdate) > rw_crapdat.dtmvtolt THEN
         vr_dtmvtolt := rw_crapdat.dtmvtopr;
      ELSE
         vr_dtmvtolt := rw_crapdat.dtmvtolt;
      END IF;

      -- buscar informações do arquivo a ser processado
      OPEN cr_crapscb;
      FETCH cr_crapscb INTO rw_crapscb;
      CLOSE cr_crapscb;


         /*Popula o vetor com as informações do tipo de solicitação*/
          vr_vet_nmtipsol(0) := 'ERR - TIPO DE SOLICITAÇAO EM BRANCO';
          vr_vet_nmtipsol(1) := 'INCLUSAO DE CARTAO';
          vr_vet_nmtipsol(2) := 'MODIFICACAO DE CONTA CARTAO';
          vr_vet_nmtipsol(3) := 'CANCELAMENTO DE CARTAO';
          vr_vet_nmtipsol(4) := 'INCLUSAO DE CARTAO ADICIONAL/REPOSICAO DE CARTAO';
          vr_vet_nmtipsol(5) := 'MODIFICACAO DE CARTAO';
          vr_vet_nmtipsol(6) := 'MODIFICACAO DE DOCUMENTO';
          vr_vet_nmtipsol(7) := 'REATIVACAO DE CARTAO';
          vr_vet_nmtipsol(8) := 'REIMPRESSAO DE PIN';
          vr_vet_nmtipsol(9) := 'BAIXA DE PARCELADOS';
          vr_vet_nmtipsol(10) := 'DESBLOQUEIO DE CARTAO';
          vr_vet_nmtipsol(11) := 'ENTREGA DE CARTAO';
          vr_vet_nmtipsol(12) := 'TROCA DE ESTADO DE CARTAO';
          vr_vet_nmtipsol(13) := 'ALTERACAO DE CONTA CARTAO';
          vr_vet_nmtipsol(14) := 'CAD. DEB. AUTOMATICO';
          vr_vet_nmtipsol(16) := 'BAIXA DE PARCELAS';
          vr_vet_nmtipsol(25) := 'REATIVAR CARTAO DO ADICIONAL';
          vr_vet_nmtipsol(50) := 'MODIFICACAO DE PIN';
          vr_vet_nmtipsol(99) := 'EXCLUSAO DE CARTAO';
          
      
      -- buscar caminho de arquivos do Bancoob/CABAL
      vr_direto_connect := rw_crapscb.dsdirarq || '/recebe';

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                          ,pr_cdcooper => vr_cdcooper_ori
                                          ,pr_nmsubdir => null);

      -- monta nome do arquivo
      vr_nmrquivo := 'CCR3756' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '_%.%';

      gene0001.pc_lista_arquivos(pr_path     => vr_direto_connect 
                                ,pr_pesq     => vr_nmrquivo  
                                ,pr_listarq  => vr_listarq 
                                ,pr_des_erro => vr_des_erro); 
      
      --Ocorreu um erro no lista_arquivos
      IF TRIM(vr_des_erro) IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := vr_des_erro;
          RAISE vr_exc_saida;
        END IF;

      --Nao encontrou nenhuma arquivo para processar
      IF TRIM(vr_listarq) IS NULL THEN
        vr_cdcritic := 182;
        vr_dscritic := NULL;
        RAISE vr_exc_fimprg;
          END IF;

      vr_split := gene0002.fn_quebra_string(pr_string  => vr_listarq
									                         ,pr_delimit => ',');

      IF vr_split.count = 0 THEN
        vr_cdcritic := 182;
        vr_dscritic := NULL;
        RAISE vr_exc_fimprg;
        END IF;

        FOR vr_conarqui IN vr_split.FIRST..vr_split.LAST LOOP
          vr_vet_nmarquiv(vr_conarqui) := vr_split(vr_conarqui);    
          vr_contador :=  vr_conarqui; 
        END LOOP;

      -- Se o contador está zerado
      IF vr_contador = 0 THEN
        vr_cdcritic:= 182;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_fimprg;
      END IF;

      -- Guardar a maior sequencia processada
      vr_nrseqarq_max := rw_crapscb.nrseqarq;
      
      -- Guardar parametros de envio SMS por cooperativa
      FOR rw_enviasms IN cr_enviasms LOOP
        vr_tab_enviasms(rw_enviasms.cdcooper) := rw_enviasms.flgenvia_sms;
      END LOOP;
      
      dbms_lob.createtemporary(vr_xml_lim_cartao, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_lim_cartao, dbms_lob.lob_readwrite);
      pc_escreve_xml(vr_xml_lim_cartao, '<?xml version="1.0" encoding="utf-8"?><crrl707>');

      -- Percorre cada arquivo encontrado
      FOR i IN 1..vr_contador LOOP

        -- adquire sequencial do arquivo
        vr_nrseqarq  := to_number(substr(vr_vet_nmarquiv(i),13,7));

        -- Verificar se sequencial já foi importado
        IF nvl(rw_crapscb.nrseqarq,0) >= nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Sequencial do arquivo '|| vr_vet_nmarquiv(i) ||
                         ' deve ser maior que o ultimo já processado (seq arq.: ' ||vr_nrseqarq||
                         ', Ult. seq.: ' || rw_crapscb.nrseqarq|| '), arquivo não será processado.';
          -- gravar log do erro
          pc_log_message;
          CONTINUE;
        -- verificar se não pulou algum sequencial
        ELSIF nvl(vr_nrseqarq_max,0) + 1 <> nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Falta sequencial de arquivo ' ||
                         '(seq arq.: ' ||vr_nrseqarq|| ', Ult. seq.: ' || vr_nrseqarq_max||
                         '), arquivo '|| vr_vet_nmarquiv(i) ||' não será processado.';
          -- gravar log do erro
          pc_log_message;
          CONTINUE;
        END IF;

        /* o comando abaixo ignora quebras de linha atraves do 'grep -v' e o 'tail -1' retorna
             a ultima linha do resultado do grep */
        vr_comando:= 'grep -v '||'''^$'' '||vr_direto_connect||'/'||vr_vet_nmarquiv(i)||'| tail -1';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_saida_tail);
                             
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
          pc_log_message;
          CONTINUE;
        END IF;
                              
        --Verificar se a ultima linha é o Trailer
        IF SUBSTR(vr_saida_tail,1,6) <> 'CCR309' THEN  
          vr_cdcritic:= 999;
          vr_dscritic:= 'Arquivo incompleto.';  
          -- gerar o log
          pc_log_arq_invalido(pr_nmdarqui => vr_vet_nmarquiv(i));
            
          CONTINUE; -- Proximo arquivo
        END IF;

        -- Guardar a maior sequencia processada
        vr_nrseqarq_max := greatest(vr_nrseqarq_max,vr_nrseqarq);

        gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect  --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_vet_nmarquiv(i) --> Nome do arquivo
                                ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                                ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);      --> erro
        -- em caso de crítica
        IF vr_dscritic IS NOT NULL THEN
          -- levantar excecao
          RAISE vr_exc_saida;
        END IF;
        
        -- Zerar sequencia da linha do arquivo
        vr_linha:=0;
        
        -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
        IF  utl_file.IS_OPEN(vr_ind_arquiv) THEN
          -- Ler todas as linhas do arquivo
          LOOP
            BEGIN
              -- Lê a linha do arquivo aberto
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                          ,pr_des_text => vr_des_text); --> Texto lido
              
              -- Somar linha do arquivo
              vr_linha := vr_linha + 1;
              
              -- se for HEADER
              IF substr(vr_des_text,5,2) = '00'  THEN
                CONTINUE;
              END IF;

              -- se for DADOS CONTA CARTÃO
              IF substr(vr_des_text,5,2) = '01'  THEN

                 BEGIN 
                     vr_tipooper := to_number(substr(vr_des_text,7,2));
                 EXCEPTION 
                   WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1004
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                 END;
                
                 /*
                1 - Inclusao de Cartao
                2 - Modificacao de Conta Cartao
                3 - Cancelamento de Cartao
                4 - Inclusao de Adicional
                7 - Reativacao de Contas
                12 - Alteracao de Estado
                13 - Alteracao de Estado Conta
                */                
               
                IF vr_tipooper NOT IN (1,2,3,4,7,12,13) THEN
                   CONTINUE;
                END IF;
                
                -- Guardar contas do arquivo para verificação
                BEGIN 
                  vr_nrctatp1 := to_number(TRIM(substr(vr_des_text,221,8)));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1005
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                vr_nrctatp2 := 0;
                
                -- Se o numero da conta chegou com zero
                -- Pegar o campo "Numero da Conta a Debitar"
                IF NVL(vr_nrctatp1,0) = 0 THEN
                  BEGIN 
                    vr_nrctatp1 := to_number(TRIM(substr(vr_des_text,206,12)));
                  EXCEPTION 
                    WHEN OTHERS THEN
                     pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                          ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo
                                          ,pr_nrdlinha => vr_linha
                                          ,pr_cdmensagem => 1006
                                          ,pr_dscritic => SQLERRM);
                     --Levantar Excecao
                     RAISE vr_exc_saida;
                  END;

                END IF;
                
                -- Buscar informações do arquivo
                BEGIN 
                  vr_cdgrafin := to_number(substr(vr_des_text,42,7));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1007
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                BEGIN 
                  vr_nroperac := to_number(substr(vr_des_text,9,8));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1008
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                vr_nrdconta := vr_nrctatp1;
                
                BEGIN 
                  vr_nrcanven := to_char(substr(vr_des_text,286,8));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1009
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                BEGIN 
                  vr_dddebito := to_number(substr(vr_des_text,243,2));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1010
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_vllimcrd := substr(vr_des_text,250,9);
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1011
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_tpdpagto := TO_NUMBER(substr(vr_des_text,218,3));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1012
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_flgdebcc := TO_NUMBER(substr(vr_des_text,198,1));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1013
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_cdagebcb := to_number(substr(vr_des_text,202,4));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1014
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_nrdctitg := to_number( substr(vr_des_text,25,13));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1015
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                                
                -- Se vier agencia bancoob zerada, obtem do Nr. da Conta Cartão
                IF vr_cdagebcb = 0 THEN
                  BEGIN 
                    vr_cdagebcb := to_number(substr(vr_des_text,28,4));
                  EXCEPTION 
                    WHEN OTHERS THEN
                     pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                          ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                     
                                          ,pr_nrdlinha => vr_linha
                                          ,pr_cdmensagem => 1016
                                          ,pr_dscritic => SQLERRM);
                     --Levantar Excecao
                     RAISE vr_exc_saida;
                  END;
                  
                END IF;
                
                BEGIN 
                  vr_codrejei := TO_NUMBER(substr(vr_des_text,275,3));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1017
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_dtoperac := TO_DATE(substr(vr_des_text,17,8),'DDMMYYYY');
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 1 -- Dados conta cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1018
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                -- Debito em Conta Corrente
                IF vr_flgdebcc = 1 OR vr_flgdebcc = 2 THEN
                  vr_flgdebcc := 1;
                ELSE
                  vr_flgdebcc := 0;                
                END IF;
                
                -- Tipo de Pagamento
                IF vr_tpdpagto = 0 THEN
                  vr_tpdpagto := 3;
                END IF;
        
                -- busca a cooperativa com base no cod. da agencia central do arquivo
                OPEN cr_crapcop_cdagebcb(pr_cdagebcb => vr_cdagebcb);
                FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;

                IF cr_crapcop_cdagebcb%NOTFOUND THEN
                  -- Fechar o cursor pois havera raise
                  CLOSE cr_crapcop_cdagebcb;
                  -- Montar mensagem de critica
                  vr_dscritic := 'Codigo da agencia do Bancoob ' || to_char(vr_cdagebcb) ||
                                 ' nao possui Cooperativa correspondente.';
                  
                  -- gravar log do erro
                  pc_log_message;
                  -- Próxima linha
                  CONTINUE;
                END IF;

                -- Fecha cursor cooperativa
                CLOSE cr_crapcop_cdagebcb;

                -- faz associação da variavel cod cooperativa;
                vr_cdcooper := rw_crapcop_cdagebcb.cdcooper;
                
                -- Busca dados da agencia cooperado
                OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                CLOSE cr_crapass;

                -- Verificar se o retorno é referente à alguma carga do SAS
                OPEN  cr_atulimi(vr_cdcooper   -- pr_cdcooper
                                ,vr_nrdconta   -- pr_nrdconta
                                ,vr_nrdctitg   -- pr_nrctacrd
                                ,vr_vllimcrd); -- pr_vllimalt
                FETCH cr_atulimi INTO rw_atulimi;
                
                -- Se não encontrar registro
                IF cr_atulimi%NOTFOUND THEN
                  rw_atulimi := NULL;
                END IF;              
                
                -- Fecha o cursor
                CLOSE cr_atulimi;

                -- Verifica se houve rejeição do Tipo de Registro 1
                IF substr(vr_des_text,275,3) <> '000' THEN
                  
                  -- Somente os registros d Inclusao sera gravado na tabela craprej
                  IF substr(vr_des_text,7,2) = '01' THEN
                  
                     BEGIN
                        INSERT INTO craprej
                          (cdcooper,
                           cdagenci,
                           cdpesqbb,
                           dshistor,
                           dtmvtolt,
                           cdcritic,
                           dtrefere,
                           nrdconta,
                           nrdctitg,
                           nrdocmto)
                        VALUES
                          (vr_cdcooper,
                           rw_crapass.cdagenci,
                           '',
                           'CCR3',
                           vr_dtmvtolt,
                           vr_codrejei,
                           vr_dtoperac,
                           vr_nrdconta,
                           vr_nrdctitg,
                           vr_nroperac);
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                         RAISE vr_exc_saida;
                     END;

                     -- Altera a situação da Proposta de Cartão para 1 (Aprovado)
                     altera_sit_cartao_aprovado(pr_cdcooper => vr_cdcooper,
                                                pr_nrdconta => vr_nrdconta,
                                                pr_nrseqcrd => vr_nroperac);
                                                 
                     -- Limpa a data de rejeicao da proposta do cartao
                     altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                          pr_nrdconta => vr_nrdconta,
                                          pr_nrseqcrd => vr_nroperac,
                                          pr_dtmvtolt => vr_dtmvtolt);
                  
                  END IF;
                  
                  -- Se encotrou registro e possui o rowid
                  IF rw_atulimi.dsdrowid IS NOT NULL THEN
                    -- Atualizar a situação do controle de atualizacoes de limites de conta cartao
                    BEGIN
                      UPDATE tbcrd_limite_atualiza  atu
                         SET atu.tpsituacao = 4           -- CRITICA
                           , atu.cdcribcb   = vr_codrejei -- Código da rejeição
                           , atu.dtretorno  = TRUNC(SYSDATE)
                       WHERE atu.rowid      = rw_atulimi.dsdrowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao atualizar tbcrd_limite_atualiza: '||SQLERRM;
                        pc_log_message;
                    END;
                     
                  -- Atualizar o registro de majoração
                  pc_atualiza_majoracao(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => vr_nrdconta
                                       ,pr_nrctacrd => vr_nrdctitg
                                       ,pr_cdcodigo => vr_codrejei
                                       ,pr_dscritic => vr_dscritic);
                      
                  -- Se ocorreu algum erro
                  IF vr_dscritic IS NOT NULL THEN
                      pc_log_message;
                    END IF;
                    
                  END IF;
                                                 
                  CONTINUE;
                  
                ELSE
				--verifica p código de administrador da crawcrd
				IF rw_crawcrd.cdadmcrd = 0 THEN
                    OPEN cr_cdadmcrd(pr_cdgrafin => vr_cdgrafin);
                    FETCH cr_cdadmcrd
                      INTO rw_cdadmcrd;
                    CLOSE cr_cdadmcrd;
                    BEGIN
                      UPDATE crawcrd
                         SET cdadmcrd = nvl(rw_cdadmcrd.cdadmcrd, 0)
                       where ROWID = rw_crawcrd.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro2 ao atualizar crawcrd:';
                        RAISE vr_exc_saida;
                    END;
                  END IF;--fim da validação do codigo de administrador crawcrd
                  OPEN cr_crapcrd_cdadmcrd(pr_rowid => rw_crapcrd.rowid);
                  FETCH cr_crapcrd_cdadmcrd
                    INTO rw_crapcrd_cdadmcrd;
                  CLOSE cr_crapcrd_cdadmcrd;
                
                  IF rw_crapcrd_cdadmcrd.cdadmcrd = 0 THEN
                    OPEN cr_cdadmcrd(pr_cdgrafin => vr_cdgrafin);
                    FETCH cr_cdadmcrd
                      INTO rw_cdadmcrd;
                    CLOSE cr_cdadmcrd;
                    BEGIN
                      UPDATE crapcrd
                         SET cdadmcrd = nvl(rw_cdadmcrd.cdadmcrd, 0)
                       WHERE ROWID = rw_crapcrd.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro2 ao atualizar crapcrd:'; 
                        RAISE vr_exc_saida;
                    END;
                  
                  END IF;--fim da validação do codigo de administrador crapcrd
                  -- Limpa a data de rejeicao da proposta do cartao
                  altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => vr_nrdconta,
                                       pr_nrseqcrd => vr_nroperac,
                                       pr_dtmvtolt => NULL);
                                       
                  -- Atualiza os dados do cartao de credito
                  atualiza_dados_cartao(pr_cdcooper       => vr_cdcooper,
                                        pr_nrdconta       => vr_nrdconta,
                                        pr_cdagenci       => rw_crapass.cdagenci,
                                        pr_nrdctitg       => vr_nrdctitg,
                                        pr_vllimcrd       => vr_vllimcrd,
                                        pr_dddebito       => vr_dddebito,
                                        pr_flgdebcc       => vr_flgdebcc,
                                        pr_tpdpagto       => vr_tpdpagto,
                                        pr_nmrescop       => rw_crapcop_cdagebcb.nmrescop,
                                        pr_nmextage       => rw_crapass.nmextage,
                                        pr_nmprimtl       => rw_crapass.nmprimtl,
                                        pr_rwatulim       => rw_atulimi,
                                        pr_xml_lim_cartao => vr_xml_lim_cartao,
                                        pr_des_erro       => vr_des_erro,
                                        pr_cdcritic       => vr_cdcritic,
                                        pr_dscritic       => vr_dscritic);
                                      
                  IF vr_des_erro <> 'OK' THEN
                    pc_log_message;
                    vr_des_erro := '';
                  ELSE                  
                    -- Se deu certo, vamos atualizar o status da majoracao
                    IF rw_atulimi.dsdrowid IS NOT NULL THEN
                  -- Atualizar o registro de majoração
                  pc_atualiza_majoracao(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => vr_nrdconta
                                          ,pr_nrctacrd => vr_nrdctitg
                                          ,pr_cdcodigo => NULL
                                          ,pr_dscritic => vr_dscritic);
                  
                  -- Se ocorreu algum erro
                  IF vr_dscritic IS NOT NULL THEN
                        pc_log_message;
                      END IF;
                    END IF;
                    
                  END IF;
                  
                END IF; /* END IF substr(vr_des_text,275,3) <> '000'  THEN */
                
              END IF;

              -- se for DADOS DO CARTÃO
              IF substr(vr_des_text,5,2) = '02'  THEN
                
                BEGIN 
                  vr_tipooper := to_number(substr(vr_des_text,7,2));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1004
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                 /*
                1 - Inclusao de Cartao
                3 - Cancelamento de Cartao
                4 - Inclusao de Adicional
								5 - Modificação de Cartão
                7 - Reativacao de Contas
                10 - Desbloqueio (exclusivo p/ tratamento de reposicao)
                12 - Alteracao de Estado
                13 - Alteracao de Estado Conta
                25 - Reativar Cartao do Adicional                
                */                
                IF vr_tipooper NOT IN (1,3,4,5,7,10,12,13,25) THEN
                   CONTINUE;
                END IF;
                
                -- Guardar contas do arquivo para verificação                
                BEGIN 
                  vr_nrctatp2 := to_number(TRIM(substr(vr_des_text,337,12)));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1019
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                vr_cdlimcrd := 0;
								vr_flgprovi := FALSE; -- Inicialmente definimos como não provisorio
                -- Agencia do banco
                BEGIN 
                  vr_cdagebcb := to_number(substr(vr_des_text,333,4));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1020
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                -- Se vier agencia bancoob zerada, obtem do Nr. da Conta Cartão
                IF vr_cdagebcb = 0 THEN                  
                  BEGIN 
                    vr_cdagebcb := to_number(substr(vr_des_text,28,4));
                  EXCEPTION 
                    WHEN OTHERS THEN
                     pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                          ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                     
                                          ,pr_nrdlinha => vr_linha
                                          ,pr_cdmensagem => 1016
                                          ,pr_dscritic => SQLERRM);
                     --Levantar Excecao
                     RAISE vr_exc_saida;
                  END;
                END IF;                
                
                -- Buscar as informações de operação e conta
                BEGIN 
                  vr_nroperac := to_number(substr(vr_des_text,9,8));                
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1008
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                BEGIN 
                  vr_nrdctitg:= TO_NUMBER(substr(vr_des_text,25,13));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1021
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_nrcrcard := TO_NUMBER(substr(vr_des_text,38,19));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1022
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;

                BEGIN 
                  vr_tpdocmto := TO_NUMBER(substr(vr_des_text,93,02));     
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1023
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                BEGIN 
                  vr_codrejei := TO_NUMBER(substr(vr_des_text,211,3));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1017
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                BEGIN 
                  vr_dtoperac:= TO_DATE(substr(vr_des_text,17,8),'DDMMYYYY');
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1018
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;
                
                BEGIN 
                  vr_sitcarta := TO_NUMBER(substr(vr_des_text,114,2));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1024
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;                            

                BEGIN 
                  vr_dtdonasc := TO_DATE(substr(vr_des_text,80,8), 'DDMMYYYY');
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1026
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;  
                
               
                
                -- busca a cooperativa com base no cod. da agencia central do arquivo
                OPEN cr_crapcop_cdagebcb(pr_cdagebcb => vr_cdagebcb);
                FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;
                IF cr_crapcop_cdagebcb%NOTFOUND THEN
                  -- Fechar o cursor pois havera raise
                  CLOSE cr_crapcop_cdagebcb;
                  -- Montar mensagem de critica
                  vr_dscritic := 'Codigo da agencia do Bancoob ' || to_char(vr_cdagebcb) ||
                                 ' nao possui Cooperativa correspondente.';
                  
                  -- gravar log do erro
                  pc_log_message;
                  -- Próxima linha
                  CONTINUE;
                ELSE
                  -- Fecha cursor cooperativa
                  CLOSE cr_crapcop_cdagebcb;
                END IF;                

                -- faz associação da variavel cod cooperativa;
                vr_cdcooper := rw_crapcop_cdagebcb.cdcooper;                
                
                -- Caso o numero da conta for igual a 0, vamos buscar o numero da conta pelo CPF
                IF NVL(vr_nrctatp2,0) = 0 THEN
                  OPEN cr_crawcrd_outros_nrcctitg(pr_cdcooper => vr_cdcooper,
                                                  pr_nrcctitg => vr_nrdctitg);                                         
                  FETCH cr_crawcrd_outros_nrcctitg INTO rw_crawcrd_outros_nrcctitg;

                  IF cr_crawcrd_outros_nrcctitg%FOUND THEN
                    CLOSE cr_crawcrd_outros_nrcctitg;                    
                    vr_nrctatp2 := rw_crawcrd_outros_nrcctitg.nrdconta;
                  ELSE
                    CLOSE cr_crawcrd_outros_nrcctitg;                    
                  OPEN cr_crawcrd_outros(pr_cdcooper => vr_cdcooper,
                                         pr_nrseqcrd => vr_nroperac);                                         
                  FETCH cr_crawcrd_outros INTO rw_crawcrd_outros;
                 
                  IF cr_crawcrd_outros%NOTFOUND THEN
                    CLOSE cr_crawcrd_outros;                    
				 IF nvl(vr_tpdocmto,0) = 1 THEN --> se o Documento é um CPF ira buscar pelo cursor
                 
				 vr_cpf := TO_NUMBER(nvl(substr(vr_des_text,95,11),0));   --> CPF é extraido
                 
				 OPEN cr_crawcrd_cpf(pr_cdcooper => vr_cdcooper,pr_nrcpftit => vr_cpf);
                 FETCH cr_crawcrd_cpf INTO rw_crawcrd_cpf;
                 IF cr_crawcrd_cpf%FOUND THEN
				 
                   vr_nrctatp2 := rw_crawcrd_cpf.nrdconta;
                 
				 END IF;
                 IF cr_crawcrd_cpf%NOTFOUND THEN
                    CLOSE cr_crawcrd_cpf;
                    CONTINUE;
                    END IF;
                 END IF;
                    if cr_crawcrd_cpf%isopen then
                    CLOSE cr_crawcrd_cpf; 
                    end if;
                  ELSE

     			   vr_nrctatp2 := rw_crawcrd_outros.nrdconta;
                   if cr_crawcrd_outros%isopen then
                    CLOSE cr_crawcrd_outros;                    
                   end if;             
                  END IF;
                  END IF;
                END IF;                
                
                -- Se não veio conta
                IF NVL(vr_nrctatp2,0) = 0 THEN                  
                  -- Ignora a linha
                  CONTINUE; 
                END IF;
                
                vr_nrdconta := vr_nrctatp2;
                
								vr_nmtitcrd := substr(vr_des_text, 57, 23);
								-- Validamos se o nome do titular é 'CARTAO PROVISORIO'
								IF nvl(TRIM(upper(vr_nmtitcrd)), ' ') = 'CARTAO PROVISORIO' THEN
									vr_flgprovi := TRUE; -- Caso for, definimos o flag como provisorio
								END IF;
                
                IF vr_tipooper IN (1,4) THEN
                  -- Buscar informação do cartão verificando se o mesmo está encerrado (cancelado)
                  OPEN  cr_crawcrd_encerra(vr_cdcooper                            --pr_cdcooper
                                          ,vr_nrdconta                            --pr_nrdconta
                                          ,vr_nrdctitg                            --pr_nrcctitg
                                          ,vr_nrcrcard);                          --pr_nrcrcard
                  FETCH cr_crawcrd_encerra INTO rw_crawcrd_encerra;
                  -- Se encontrar o cartão como encerrado (cancelado)
                  IF cr_crawcrd_encerra%FOUND THEN
                    -- fecha o cursor
                    CLOSE cr_crawcrd_encerra;
                    CONTINUE; -- Ignora o registro
                  END IF;                
                  CLOSE cr_crawcrd_encerra;
                  
                END IF;
                
                -- Busca dados da agencia cooperado
                OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                CLOSE cr_crapass;
                
                -- Se for dados do cartão, e os dados forem de um CNPJ (pos93 = 3)
                IF vr_tpdocmto = '03' THEN                  

                  
                  vr_nmtitcrd := substr(vr_des_text,38,19)||substr(vr_des_text,250,23)||substr(vr_des_text,7,2);
                  
                  -- Verifica se houve rejeição do Tipo de Registro 2
                  IF vr_codrejei <> '000'  THEN                    
                    BEGIN
                      INSERT INTO craprej
                         (cdcooper,
                          cdagenci,
                          cdpesqbb,
                          dshistor,
                          dtmvtolt,
                          cdcritic,
                          dtrefere,
                          nrdconta,
                          nrdctitg,
                          nrdocmto)
                      VALUES
                          (vr_cdcooper,
                           rw_crapass.cdagenci,
                           vr_nmtitcrd,
                           'CCR3',
                           vr_dtmvtolt,
                           vr_codrejei,
                           vr_dtoperac,
                           vr_nrdconta,
                           vr_nrdctitg,
                           vr_nroperac);
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                        RAISE vr_exc_saida;
                      END;

                    /* nao deve solicitar cartao novamente caso retorne critica 
                       080 - pessoa ja tem cartao nesta conta 
                       143 - conta duplicada */
                    IF substr(vr_des_text, 211, 3) in( '080','143') THEN
                      continue;
                    END IF;

                    -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
                    atualiza_nmtitcrd(vr_cdcooper,
                                      rw_crapass.cdagenci,
                                      vr_nrdconta,
                                      vr_dtmvtolt,
                                      vr_nmtitcrd); 
                        
                    -- Altera a situação da Proposta de Cartão para 1 (Aprovado)
                    altera_sit_cartao_aprovado(pr_cdcooper => vr_cdcooper,
                                               pr_nrdconta => vr_nrdconta,
                                               pr_nrseqcrd => vr_nroperac);
                                                  
                    altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                         pr_nrdconta => vr_nrdconta,
                                         pr_nrseqcrd => vr_nroperac,
                                         pr_dtmvtolt => vr_dtmvtolt);
                    
                    CONTINUE;
                  ELSE
                    -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
                    atualiza_nmtitcrd(vr_cdcooper,
                                      rw_crapass.cdagenci,
                                      vr_nrdconta,
                                      vr_dtmvtolt,
                                      vr_nmtitcrd);
                                         
                    CONTINUE;                      
                  END IF;
                END IF;
                
                /* Tratamento especifico para casos de operacao 10 (desbloqueio), porem, onde a
                   informacao que vem no arquivo informa que o cartao esta sendo REPOSTO (deve cancelar).
                   Fabricio - chamado 559710 */
                IF vr_tipooper = 10 THEN
                  IF vr_sitcarta = 10 OR vr_flgprovi THEN --reposicao
                    -- Atualiza os dados da situacao do cartao
                    atualiza_situacao_cartao(pr_cdcooper => vr_cdcooper,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_nrcrcard => vr_nrcrcard,                                           
                                             pr_insitcrd => vr_sitcarta,                                    
                                             pr_dtmvtolt => vr_dtmvtolt,
                                             pr_des_erro => vr_des_erro,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
                                             
                    -- Verifica se ocorreu erro                          
                    IF vr_des_erro <> 'OK' THEN
                      pc_log_message;
                      vr_des_erro := '';
					END IF;
				   else  -- Workaround para desbloqueio de cartao via 0800 (arquivo CCB retona operacao 02 e novidade 10  issue/INC0023924/develop
                    -- Atualiza os dados da situacao do cartao
                    atualiza_situacao_cartao(pr_cdcooper => vr_cdcooper,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_nrcrcard => vr_nrcrcard,                                           
                                             pr_insitcrd => 1,                                    
                                             pr_dtmvtolt => vr_dtmvtolt,
                                             pr_des_erro => vr_des_erro,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
                    -- Verifica se ocorreu erro                          
                    IF vr_des_erro <> 'OK' THEN
                      pc_log_message;
                      vr_des_erro := '';
                    END IF; 
                   END IF; 

                  -- tipo de operacao 10 (desbloqueio) nao deve fazer mais nada alem disto (Fabricio).
                  CONTINUE;
                END IF;
                
                /* 
                3 - Cancelamento de Cartao
								5 - Modificação de Cartão
                7 - Reativacao de Contas
                12 - Alteracao de Estado
                13 - Alteracao de Estado Conta
                25 - Reativar Cartao do Adicional                
                */                
                IF vr_tipooper IN (3,5,7,12,13,25) THEN
                  -- Atualiza os dados da situacao do cartao
                  atualiza_situacao_cartao(pr_cdcooper => vr_cdcooper,
                                           pr_nrdconta => vr_nrdconta,
                                           pr_nrcrcard => vr_nrcrcard,                                           
                                           pr_insitcrd => vr_sitcarta,                                    
                                           pr_dtmvtolt => vr_dtmvtolt,
                                           pr_des_erro => vr_des_erro,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
                                           
                  -- Verifica se ocorreu erro                          
                  IF vr_des_erro <> 'OK' THEN
                    pc_log_message;
                    vr_des_erro := '';
                  END IF;

                  CONTINUE;
                END IF;                                
                
                -- Validar se CPF está valido
                BEGIN 
                  vr_nrcpfcgc:= TO_NUMBER(substr(vr_des_text,95,15));
                EXCEPTION 
                  WHEN OTHERS THEN
                   pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                        ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                        ,pr_nrdlinha => vr_linha
                                        ,pr_cdmensagem => 1025
                                        ,pr_dscritic => SQLERRM);
                   --Levantar Excecao
                   RAISE vr_exc_saida;
                END;   
                
                if vr_tipooper = 4 then -- adicional
                  -- cpf + conta cartao + cartao
                  vr_tab_reg_upgrade(vr_nrcpfcgc||vr_nrdctitg||vr_nrcrcard):= vr_nrdconta;
                end if;
                
                -- Verifica se a operação é de inclusão de adicional, ou seja,
                -- verifica se a linha anterior processada refere-se a linha atual
                IF NVL(vr_nrctatp1,0) <> NVL(vr_nrctatp2,0) THEN
                  
                  -- Limpar as variáveis para evitar valores da iteração anterior
                  rw_crapacb.cdadmcrd := 0;
                  vr_cdgrafin := 0;
                  vr_dddebito := 0;
                  vr_vllimcrd := 0;
                  vr_tpdpagto := 0;
                  vr_flgdebcc := 0;
                  
                  -- Busca dados da agencia cooperado
                  OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                  pr_nrdconta => vr_nrdconta);
                  FETCH cr_crapass INTO rw_crapass;
                  CLOSE cr_crapass;
                  
                  -- Verificar se o cursor está aberto
                  IF cr_crawcrd_em_uso%ISOPEN THEN
                    CLOSE cr_crawcrd_em_uso;
                  END IF;
                  
                  -- Buscar o contrato que esteja em uso
                  OPEN cr_crawcrd_em_uso(pr_cdcooper => vr_cdcooper -- pr_cdcooper
                                        ,pr_nrdconta => vr_nrdconta -- pr_nrdconta
                                        ,pr_nrcctitg => vr_nrdctitg -- pr_nrcctitg
                                        ,pr_nrcpftit => vr_nrcpfcgc -- pr_nrcpftit
                                        ,pr_flgprcrd => 1 );        -- pr_flgprcrd
                  
                  FETCH cr_crawcrd_em_uso INTO rw_crapacb.cdadmcrd
                                              ,vr_dddebito
                                              ,vr_vllimcrd
                                              ,vr_tpdpagto
                                              ,vr_flgdebcc;
                  -- Se não encontrar registros
                  IF cr_crawcrd_em_uso%NOTFOUND THEN
                    -- Fechar o cursor
                    CLOSE cr_crawcrd_em_uso;                    
                    
                    -- Buscar registro de solicitacao
                    OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                             ,vr_nrdconta                 -- pr_nrdconta
                                             ,NULL                        -- pr_nrcctitg
                                             ,vr_nrcpfcgc                 -- pr_nrcpftit
                                             ,2                             -- pr_insitcrd -- SOLICITADO
                                             ,NULL);                        -- pr_flgprcrd
                    FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                 , vr_dddebito
                                                 , vr_vllimcrd
                                                 , vr_tpdpagto
                                                 , vr_flgdebcc;
                    -- Se não encontrar registros
                    IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                      -- Fechar o cursor
                      CLOSE cr_crawcrd_cdgrafin;                                     
                    
                      -- Buscar pelo CPF do titular
                      OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                          -- pr_cdcooper
                                               ,vr_nrdconta                          -- pr_nrdconta
                                               ,NULL                                 -- pr_nrcctitg
                                               ,vr_nrcpfcgc                          -- pr_nrcpftit
                                               ,3                                    -- pr_insitcrd -- LIBERADO
                                               ,NULL );                              -- pr_flgprcrd
                      FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                   , vr_dddebito
                                                   , vr_vllimcrd
                                                   , vr_tpdpagto
                                                   , vr_flgdebcc;  
                    
                      -- Se não encontrar registros
                      IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crawcrd_cdgrafin;
                        
                        -- Buscar cartão liberado do próprio
                        OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                          -- pr_cdcooper
                                                 ,vr_nrdconta                          -- pr_nrdconta
                                                 ,NULL                                 -- pr_nrcctitg
                                                 ,NULL                                 -- pr_nrcpftit
                                                 ,3                                    -- pr_insitcrd -- LIBERADO
                                                 ,NULL );                              -- pr_flgprcrd
                        FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                     , vr_dddebito
                                                     , vr_vllimcrd
                                                     , vr_tpdpagto
                                                     , vr_flgdebcc;  
                        
                        -- Se não encontrar registros
                        IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                          -- Buscar cartão liberado que tenha um outro cancelado na mesma data ( Ou seja: Up/Downgrade)
                          OPEN  cr_crawcrd_cancel(vr_cdcooper                 -- pr_cdcooper
                                                 ,vr_nrdconta                 -- pr_nrdconta
                                                 ,vr_nrdctitg   -- pr_nrcctitg
                                                 ,3                           -- pr_insitcrd
                                                 ,vr_dtmvtolt);       -- pr_dtmvtolt
                          FETCH cr_crawcrd_cancel INTO rw_crapacb.cdadmcrd
                                                     , vr_dddebito
                                                     , vr_vllimcrd
                                                     , vr_tpdpagto
                                                     , vr_flgdebcc;
                          -- Se não encontrar registros
                          IF cr_crawcrd_cancel%NOTFOUND THEN
                            CLOSE cr_crawcrd_cancel;                          
                            -- Buscar os dados do cartao
                            OPEN cr_crawcrd_cdgrafin_conta(vr_cdcooper               -- pr_cdcooper
                                                          ,vr_nrdconta               -- pr_nrdconta
                                                          ,vr_nrdctitg               -- pr_nrcctitg
                                                          ,vr_dtmvtolt);     -- pr_dtmvtolt
                            -- Buscar os dados                              
                            FETCH cr_crawcrd_cdgrafin_conta INTO rw_crawcrd_cdgrafin_conta;
                            IF cr_crawcrd_cdgrafin_conta%FOUND THEN
                              CLOSE cr_crawcrd_cdgrafin_conta;
                              -- Carrega os dados do cartao
                              rw_crapacb.cdadmcrd := rw_crawcrd_cdgrafin_conta.cdadmcrd;
                              vr_dddebito         := rw_crawcrd_cdgrafin_conta.dddebito;
                              vr_vllimcrd         := rw_crawcrd_cdgrafin_conta.vllimcrd;
                              vr_tpdpagto         := rw_crawcrd_cdgrafin_conta.tpdpagto;
                              vr_flgdebcc         := rw_crawcrd_cdgrafin_conta.flgdebcc;                          
                            ELSE
                              CLOSE cr_crawcrd_cdgrafin_conta;
                              
                              IF cr_crawcrd_cdgrafin%ISOPEN THEN
                                CLOSE cr_crawcrd_cdgrafin;
                              END IF;
                              
                              OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                                       ,vr_nrdconta                 -- pr_nrdconta
                                                       ,vr_nrdctitg                 -- pr_nrcctitg
                                                       ,NULL                        -- pr_nrcpftit
                                                       ,NULL                        -- pr_insitcrd -- EM USO
                                                       ,1);                         -- pr_flgprcrd
                              FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                           , vr_dddebito
                                                           , vr_vllimcrd
                                                           , vr_tpdpagto
                                                           , vr_flgdebcc;                                                                                         
                            END IF;
                            
                          ELSE
                            CLOSE cr_crawcrd_cancel;
                          END IF;
                                                     
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                  
                  
                  -- Verificar se o cursor está aberto
                  IF cr_crawcrd_em_uso%ISOPEN THEN
                    CLOSE cr_crawcrd_em_uso;
                  END IF;
                  
                  -- Fecha o cursor
                  IF cr_crawcrd_cdgrafin%ISOPEN THEN
                  CLOSE cr_crawcrd_cdgrafin;
                  END IF;
                
                ELSE
                  
                  if vr_cdgrafin = 0 then         
                    -- Limpar as variáveis para evitar valores da iteração anterior
                    rw_crapacb.cdadmcrd := 0;
                    vr_cdgrafin := 0;
                    vr_dddebito := 0;
                    vr_vllimcrd := 0;
                    vr_tpdpagto := 0;
                    vr_flgdebcc := 0;
                    
                    -- Busca dados da agencia cooperado
                    OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                    pr_nrdconta => vr_nrdconta);
                    FETCH cr_crapass INTO rw_crapass;
                    CLOSE cr_crapass;
                    
                    -- Verificar se o cursor está aberto
                    IF cr_crawcrd_em_uso%ISOPEN THEN
                      CLOSE cr_crawcrd_em_uso;
                    END IF;
                    
                    -- Buscar o contrato que esteja em uso
                    OPEN cr_crawcrd_em_uso(pr_cdcooper => vr_cdcooper -- pr_cdcooper
                                          ,pr_nrdconta => vr_nrdconta -- pr_nrdconta
                                          ,pr_nrcctitg => vr_nrdctitg -- pr_nrcctitg
                                          ,pr_nrcpftit => vr_nrcpfcgc -- pr_nrcpftit
                                          ,pr_flgprcrd => 1 );        -- pr_flgprcrd
                    
                    FETCH cr_crawcrd_em_uso INTO rw_crapacb.cdadmcrd
                                                ,vr_dddebito
                                                ,vr_vllimcrd
                                                ,vr_tpdpagto
                                                ,vr_flgdebcc;
                    -- Se não encontrar registros
                    IF cr_crawcrd_em_uso%NOTFOUND THEN
                      -- Fechar o cursor
                      CLOSE cr_crawcrd_em_uso;                    
                      
                      -- Buscar registro de solicitacao
                      OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                               ,vr_nrdconta                 -- pr_nrdconta
                                               ,NULL                        -- pr_nrcctitg
                                               ,vr_nrcpfcgc                 -- pr_nrcpftit
                                               ,2                             -- pr_insitcrd -- SOLICITADO
                                               ,NULL);                        -- pr_flgprcrd
                      FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                   , vr_dddebito
                                                   , vr_vllimcrd
                                                   , vr_tpdpagto
                                                   , vr_flgdebcc;
                      -- Se não encontrar registros
                      IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crawcrd_cdgrafin;                                     
                      
                        -- Buscar pelo CPF do titular
                        OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                          -- pr_cdcooper
                                                 ,vr_nrdconta                          -- pr_nrdconta
                                                 ,NULL                                 -- pr_nrcctitg
                                                 ,vr_nrcpfcgc                          -- pr_nrcpftit
                                                 ,3                                    -- pr_insitcrd -- LIBERADO
                                                 ,NULL );                              -- pr_flgprcrd
                        FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                     , vr_dddebito
                                                     , vr_vllimcrd
                                                     , vr_tpdpagto
                                                     , vr_flgdebcc;  
                      
                        -- Se não encontrar registros
                        IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                          -- Fechar o cursor
                          CLOSE cr_crawcrd_cdgrafin;
                          
                          -- Buscar cartão liberado do próprio
                          OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                          -- pr_cdcooper
                                                   ,vr_nrdconta                          -- pr_nrdconta
                                                   ,NULL                                 -- pr_nrcctitg
                                                   ,NULL                                 -- pr_nrcpftit
                                                   ,3                                    -- pr_insitcrd -- LIBERADO
                                                   ,NULL );                              -- pr_flgprcrd
                          FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                       , vr_dddebito
                                                       , vr_vllimcrd
                                                       , vr_tpdpagto
                                                       , vr_flgdebcc;  
                          
                          -- Se não encontrar registros
                          IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                            -- Buscar cartão liberado que tenha um outro cancelado na mesma data ( Ou seja: Up/Downgrade)
                            OPEN  cr_crawcrd_cancel(vr_cdcooper                 -- pr_cdcooper
                                                   ,vr_nrdconta                 -- pr_nrdconta
                                                   ,vr_nrdctitg   -- pr_nrcctitg
                                                   ,3                           -- pr_insitcrd
                                                   ,vr_dtmvtolt);       -- pr_dtmvtolt
                            FETCH cr_crawcrd_cancel INTO rw_crapacb.cdadmcrd
                                                       , vr_dddebito
                                                       , vr_vllimcrd
                                                       , vr_tpdpagto
                                                       , vr_flgdebcc;
                            -- Se não encontrar registros
                            IF cr_crawcrd_cancel%NOTFOUND THEN
                              CLOSE cr_crawcrd_cancel;                          
                              -- Buscar os dados do cartao
                              OPEN cr_crawcrd_cdgrafin_conta(vr_cdcooper               -- pr_cdcooper
                                                            ,vr_nrdconta               -- pr_nrdconta
                                                            ,vr_nrdctitg               -- pr_nrcctitg
                                                            ,vr_dtmvtolt);     -- pr_dtmvtolt
                              -- Buscar os dados                              
                              FETCH cr_crawcrd_cdgrafin_conta INTO rw_crawcrd_cdgrafin_conta;
                              IF cr_crawcrd_cdgrafin_conta%FOUND THEN
                                CLOSE cr_crawcrd_cdgrafin_conta;
                                -- Carrega os dados do cartao
                                rw_crapacb.cdadmcrd := rw_crawcrd_cdgrafin_conta.cdadmcrd;
                                vr_dddebito         := rw_crawcrd_cdgrafin_conta.dddebito;
                                vr_vllimcrd         := rw_crawcrd_cdgrafin_conta.vllimcrd;
                                vr_tpdpagto         := rw_crawcrd_cdgrafin_conta.tpdpagto;
                                vr_flgdebcc         := rw_crawcrd_cdgrafin_conta.flgdebcc;                          
                              ELSE
                                CLOSE cr_crawcrd_cdgrafin_conta;
                                
                                IF cr_crawcrd_cdgrafin%ISOPEN THEN
                                  CLOSE cr_crawcrd_cdgrafin;
                  END IF;
                
                                OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                                         ,vr_nrdconta                 -- pr_nrdconta
                                                         ,vr_nrdctitg                 -- pr_nrcctitg
                                                         ,NULL                        -- pr_nrcpftit
                                                         ,NULL                        -- pr_insitcrd -- EM USO
                                                         ,1);                         -- pr_flgprcrd
                                FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                             , vr_dddebito
                                                             , vr_vllimcrd
                                                             , vr_tpdpagto
                                                             , vr_flgdebcc;                                                                                         
                              END IF;
                              
                ELSE
                              CLOSE cr_crawcrd_cancel;
                            END IF;
                                                       
                          END IF;
                        END IF;
                      END IF;
                    END IF;                    
                    
                    -- Verificar se o cursor está aberto
                    IF cr_crawcrd_em_uso%ISOPEN THEN
                      CLOSE cr_crawcrd_em_uso;
                    END IF;
                    
                    -- Fecha o cursor
                    IF cr_crawcrd_cdgrafin%ISOPEN THEN
                    CLOSE cr_crawcrd_cdgrafin;
                    END IF;
                  
                  else                    
                  -- busca Codigo da Adminstradora com base no Cod. do Grupo de Afinidade
                  OPEN cr_crapacb(pr_cdgrafin => vr_cdgrafin);
                  FETCH cr_crapacb INTO rw_crapacb;

                  IF cr_crapacb%NOTFOUND THEN
                    -- Fechar o cursor pois havera raise
                    CLOSE cr_crapacb;
                    -- Montar mensagem de critica
                    vr_dscritic := 'Cod. de Grupo de Afinidade ' || vr_cdgrafin || ' ' ||
                                   'nao encontrado. '||vr_nrdctitg;
                                   
                    -- gravar log do erro
                    pc_log_message;
                    -- Próxima linha
                    CONTINUE;
                  END IF;
                  -- Fecha cursor de Grupo de Afinidade
                  CLOSE cr_crapacb;
                  end if;
                END IF;
                
                -- Verifica se houve rejeição do Tipo de Registro 2
                IF vr_codrejei <> '000'  THEN
                  
                  BEGIN                  
                    vr_nmtitcrd := substr(vr_des_text,38,19)||substr(vr_des_text,57,23)||substr(vr_des_text,7,2);
                    INSERT INTO craprej
                       (cdcooper,
                        cdagenci,
                        cdpesqbb,
                        dshistor,
                        dtmvtolt,
                        cdcritic,
                        dtrefere,
                        nrdconta,
                        nrdctitg,
                        nrdocmto)
                    VALUES
                        (vr_cdcooper,
                         rw_crapass.cdagenci,
                         vr_nmtitcrd,
                         'CCR3',
                         vr_dtmvtolt,
                         vr_codrejei,
                         vr_dtoperac,
                         vr_nrdconta,
                         vr_nrdctitg,
                         vr_nroperac);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                      RAISE vr_exc_saida;
                    END;

                  /* nao deve solicitar cartao novamente caso retorne critica 
                     080 - pessoa ja tem cartao nesta conta 
                     143 - conta duplicada */
                  IF substr(vr_des_text, 211, 3) in( '080','143') THEN
                    continue;
                  END IF;

                  -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
                  atualiza_nmtitcrd(vr_cdcooper,
                                    rw_crapass.cdagenci,
                                    vr_nrdconta,
                                    vr_dtmvtolt,
                                    vr_nmtitcrd); 
                      
                  -- Altera a situação da Proposta de Cartão para 1 (Aprovado)
                  altera_sit_cartao_aprovado(pr_cdcooper => vr_cdcooper,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_nrseqcrd => vr_nroperac);
                                                
                  altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => vr_nrdconta,
                                       pr_nrseqcrd => vr_nroperac,
                                       pr_dtmvtolt => vr_dtmvtolt);
                  
                  CONTINUE;
                ELSE
                  -- Atualiza a data de Rejeicao do contrato de Emprestimo
                  altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => vr_nrdconta,
                                       pr_nrseqcrd => vr_nroperac,
                                       pr_dtmvtolt => NULL);
                    
                END IF;
                
                -- Para cada cartao, vamos buscar o valor de limite de credito cadastrado
                OPEN cr_craptlc(pr_cdcooper => vr_cdcooper,
                                pr_cdadmcrd => rw_crapacb.cdadmcrd,
                                pr_vllimcrd => vr_vllimcrd);
                FETCH cr_craptlc INTO rw_craptlc;
                IF cr_craptlc%FOUND THEN
                  CLOSE cr_craptlc;
                  vr_cdlimcrd := rw_craptlc.cdlimcrd;
                ELSE
                  CLOSE cr_craptlc;
                  vr_cdlimcrd := 0;
                  
                END IF;  

                -- Se o cursor estiver aberto
                IF cr_crawcrd%ISOPEN THEN
                  -- Fechar cursor
                  CLOSE cr_crawcrd;
                END IF;

                -- buscar proposta de cartão
                OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta,
                                pr_nrcpftit => vr_nrcpfcgc,
                                pr_cdadmcrd => rw_crapacb.cdadmcrd);
                FETCH cr_crawcrd INTO rw_crawcrd;

                -- se não encontrar proposta de cartão de crédito
                IF cr_crawcrd%NOTFOUND THEN
                  -- Busca dados do cooperado
                  OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                  pr_nrdconta => vr_nrdconta);
                  FETCH cr_crapass INTO rw_crapass;

                  IF cr_crapass%FOUND THEN
                    IF rw_crapass.inpessoa = 1 THEN

                      -- Busca registro pessoa física
                      OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_nrcpfcgc => vr_nrcpfcgc);
                      FETCH cr_crapttl INTO rw_crapttl;

                      -- Se nao encontrar
                      IF cr_crapttl%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crapttl;
                        -- Montar mensagem de critica
                        vr_dscritic := 'Titular nao encontrado da conta: ' || rw_crawcrd.nrdconta;
                        -- gravar log do erro
                        pc_log_message;

                        -- fecha cursor
                        CLOSE cr_crapass;
                        CLOSE cr_crawcrd;
                        CONTINUE;
                      ELSE
                        vr_nmextttl := rw_crapttl.nmextttl;
                        vr_vlsalari := rw_crapttl.vlsalari;
                        vr_dtnasccr := rw_crapass.dtnasctl;
                        -- Apenas fechar o cursor
                        CLOSE cr_crapttl;
                      END IF;
                    ELSE
                      -- Busca registro de pessoa jurídica
                      OPEN cr_crapjur(pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta);
                      FETCH cr_crapjur INTO rw_crapjur;

                      -- Se nao encontrar
                      IF cr_crapjur%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crapjur;
                        -- Montar mensagem de critica
                        vr_dscritic := 'Empresa nao encontrada. Conta/DV: ' || rw_crapass.nrdconta;
                        -- gravar log do erro
                        pc_log_message;

                        -- fecha cursor 
                        CLOSE cr_crapass;
                        CLOSE cr_crawcrd;
                        CONTINUE;
                      ELSE
                        -- Apenas fechar o cursor
                        CLOSE cr_crapjur;
                      END IF;

                      -- A regra de negócio da área de Cartões é que cartão múltiplo ou 
                      -- puro débito somente poderá ser solicitado para o representante legal 
                      -- que assine isoladamente pela empresa. 
                      -- E o cartão puro crédito para pessoas vinculadas a empresa e 
                      -- não necessariamente a conta corrente.

                      -- Inicialmente vamos validar o REPRESENTANTE
                      vr_valida_avt := TRUE;
                      --  Verificar o cartão que estamos processando possui uma conta de débito vinculada
                      IF to_number(TRIM(substr(vr_des_text,337,12))) = 0 THEN
                        -- Se o cartão for PURO CREDITO, não validamos o representante
                        vr_valida_avt := FALSE;
                      END IF;

                      -- Busca registro de representante para pessoa jurídica
                      OPEN cr_crapavt(pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_nrcpfcgc => vr_nrcpfcgc);
                      FETCH cr_crapavt INTO rw_crapavt;

                      -- Se nao encontrar
                      IF cr_crapavt%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crapavt;
                        
                        -- Se não encontramos o representante, e conforme regra acima 
                        -- para cartão PURO CREDITO não validamos o representante 
                        IF vr_valida_avt THEN
                          -- Se o cartão possui conta vinculada e nao encontramos o 
                          -- representante, vamos levantar a exceção

                        -- Montar mensagem de critica
                        vr_dscritic := 'Representante nao encontrado. Conta/DV: ' || rw_crapass.nrdconta ||
                                       ' CPF: '                                   || vr_nrcpfcgc;
                        -- gravar log do erro
                        pc_log_message;

                        -- fecha cursor 
                        CLOSE cr_crapass;
                        CLOSE cr_crawcrd;
                         vr_nmtitcrd :=substr(vr_des_text,38,19)||substr(vr_des_text,57,23)||substr(vr_des_text,7,2); 
                          BEGIN
                            INSERT INTO craprej
                                       (cdcooper,
                                        cdagenci,
                                        cdpesqbb,
                                        dshistor,
                                        dtmvtolt,
                                        cdcritic,
                                        dtrefere,
                                        nrdconta,
                                        nrdctitg,
                                        nrdocmto)
                                    VALUES
                                        (vr_cdcooper,
                                         rw_crapass.cdagenci,
                                         vr_nmtitcrd,
                                         'CCR3',
                                         vr_dtmvtolt,
                                         999, -- Representante nao encontrado
                                         vr_dtoperac,
                                         vr_nrdconta,
                                         vr_nrdctitg,
                                         vr_nroperac);
                          EXCEPTION
                            WHEN OTHERS THEN
                              vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                            RAISE vr_exc_saida;
                          END;  
                        
                        CONTINUE;
                        END IF;
                      ELSE
                        -- Apenas fechar o cursor
                        CLOSE cr_crapavt;
                        -- Se encontramos o avalista vamos utilizar para carregar 
                        -- os dados de saldo
                        vr_valida_avt := TRUE;
                      END IF;

                      IF vr_valida_avt THEN
                      -- Verifica se representante encontrado é cooperado
                      OPEN cr_crapass_avt(pr_cdcooper => rw_crapass.cdcooper,
                                          pr_nrcpfcgc => rw_crapavt.nrcpfcgc);
                      FETCH cr_crapass_avt INTO rw_crapass_avt;

                      -- Se nao for cooperado, pega os dados da tabela de representantes
                      IF cr_crapass_avt%NOTFOUND THEN
                        vr_nmextttl := rw_crapavt.nmdavali;
                        vr_vlsalari := 0;
                      ELSE -- Se for cooperado, pega os dados da conta
                        vr_nmextttl := rw_crapass_avt.nmprimtl;
                        vr_vlsalari := rw_crapass_avt.vlsalari;
                      END IF;

                      -- fechar o cursor
                      CLOSE cr_crapass_avt;
                      ELSE
                        -- Se não encontramos o avalista, vamos utilizar os dados do 
                        -- arquivo
                        -- Buscar o nome embossado no plastico do cartao 
                        vr_nmextttl := TRIM(substr(vr_des_text,57,23));
                        vr_vlsalari := 0;
                      END IF;
                    END IF;
                  ELSE
                    -- fechar os cursores
                    CLOSE cr_crapass;
                    CLOSE cr_crawcrd;
                    CONTINUE;
                  END IF;
                  -- fechar o cursor
                  CLOSE cr_crapass;

                  -- obter numero do contrato (sequencial)
                  vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', vr_cdcooper);

                  -- Verifica se é o primeiro cartão bancoob da empresa desta administradora
                  OPEN cr_crawcrd_flgprcrd(pr_cdcooper => vr_cdcooper,
                                           pr_nrdconta => vr_nrdconta,
                                           pr_cdadmcrd => rw_crapacb.cdadmcrd);
                  FETCH cr_crawcrd_flgprcrd INTO rw_crawcrd_flgprcrd;
                  IF cr_crawcrd_flgprcrd%FOUND THEN
                    -- Verificar se o CPF do titular do primeiro cartão é o mesmo que esta sendo validado
                    IF rw_crawcrd_flgprcrd.nrcpftit = vr_nrcpfcgc THEN
                      vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                    ELSE
                      vr_flgprcrd := 0; -- Não é o primeiro
                    END IF;
                  ELSE
                     vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                  END IF;
                  -- fecha cursor
                  CLOSE cr_crawcrd_flgprcrd;
                  
                  /* Caso a Conta vinculada estiver 0, significa que o cartao eh do tipo OUTROS,
                     para os cartoes do tipo OUTROS sera puro CREDITO... */
                  IF to_number(TRIM(substr(vr_des_text,337,12))) = 0 THEN
                     vr_flgdebit := 0;
                  ELSE
                     vr_flgdebit := 1;
                  END IF;                  
                  
                  -- Deve buscar o contrato para inserir
                  vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(pr_cdcooper => vr_cdcooper);
                  
                  -- Cria nova proposta de cartão de crédito
                  BEGIN
                    INSERT INTO crawcrd
                       (nrdconta,
                        nrcrcard,
                        nrcctitg,
                        nrcpftit,
                        vllimcrd,
                        flgctitg,
                        dtmvtolt,
                        nmextttl,
                        flgprcrd,
                        tpdpagto,
                        flgdebcc,
                        tpenvcrd,
                        vlsalari,
                        dddebito,
                        cdlimcrd,
                        tpcartao,
                        dtnasccr,
                        nrdoccrd,
                        nmtitcrd,
                        nrctrcrd,
                        cdadmcrd,
                        cdcooper,
                        nrseqcrd,
                        dtpropos,
                        dtsolici,
                        flgdebit)
                    VALUES
                       (vr_nrdconta,                                      -- nrdconta
                        vr_nrcrcard,                                      -- nrcrcard
                        vr_nrdctitg,                                      -- nrcctitg
                        vr_nrcpfcgc,                                      -- nrcpftit
                        vr_vllimcrd,                                      -- vllimcrd
                        3,                                                -- flgctitg
                        vr_dtmvtolt,                                      -- dtmvtolt
                        vr_nmextttl,                                      -- nmextttl
                        vr_flgprcrd,                                      -- flgprcrd
                        vr_tpdpagto,                                      -- tpdpagto
                        vr_flgdebcc,                                      -- flgdebcc
                        0,                                                -- tpenvcrd
                        vr_vlsalari,                                      -- vlsalari
                        vr_dddebito,                                      -- dddebito
                        vr_cdlimcrd,                                      -- cdlimcrd
                        2,                                                -- tpcartao
                        vr_dtdonasc,                                      -- dtnasccr
                        substr(vr_des_text,230,15),                       -- nrdoccrd
                        TRIM(substr(vr_des_text,57,23)),                  -- nmtitcrd
                        vr_nrctrcrd,                                      -- nrctrcrd
                        rw_crapacb.cdadmcrd,                              -- cdadmcrd
                        vr_cdcooper,                                      -- cdcooper
                        vr_nrseqcrd,                                      -- nrseqcrd
                        vr_dtmvtolt,                                      -- dtpropos
                        vr_dtmvtolt,                                      -- dtsolici
                        vr_flgdebit)                                      -- flgdebit
                        RETURNING ROWID INTO rw_crawcrd.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;                  
                  
                  IF cr_crawcrd_rowid%ISOPEN THEN
                    CLOSE cr_crawcrd_rowid;
                  END IF;

                  -- Obtem ponteiro do registro de proposta recém criado
                  OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
                  FETCH cr_crawcrd_rowid INTO rw_crawcrd;

                  IF cr_crapcrd%ISOPEN THEN
                    CLOSE cr_crapcrd;
                  END IF;
                  
                  -- buscar registro do cartão de crédito
                  OPEN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                  pr_nrdconta => rw_crawcrd.nrdconta,
                                  pr_nrcrcard => rw_crawcrd.nrcrcard);
                  FETCH cr_crapcrd INTO rw_crapcrd;

                  -- Se encontrar registro do cartão, cria log e continua
                  IF cr_crapcrd%FOUND THEN
                    -- LOGA NO PROC_MESSAGE
                    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper_ori
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '
                                                               || 'CARTAO JA EXISTENTE - NR: ' || rw_crawcrd.nrcrcard || ' '
                                                               || 'CONTA: ' || rw_crawcrd.nrdconta || ' COOP.: ' || rw_crawcrd.cdcooper
                                                               || ' ARQ.: ' || vr_nmarquiv
                                              ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                    CONTINUE;
                  ELSE      
                    BEGIN
											vr_flgproviint := 0;
											IF vr_flgprovi THEN
											   vr_flgproviint := 1;
											END IF;
                      INSERT INTO crapcrd
                         (cdcooper,
                          nrdconta,
                          nrcrcard,
                          nrcpftit,
                          nmtitcrd,
                          dddebito,
                          cdlimcrd,
                          dtvalida,
                          nrctrcrd,
                          cdmotivo,
                          nrprotoc,
                          cdadmcrd,
                          tpcartao,
                          dtcancel,
                          flgdebit,
													flgprovi)
                      VALUES
                         (rw_crawcrd.cdcooper,
                          rw_crawcrd.nrdconta,
                          rw_crawcrd.nrcrcard,
                          rw_crawcrd.nrcpftit,
                          rw_crawcrd.nmtitcrd,
                          rw_crawcrd.dddebito,
                          rw_crawcrd.cdlimcrd,
                          rw_crawcrd.dtvalida,
                          rw_crawcrd.nrctrcrd,
                          rw_crawcrd.cdmotivo,
                          rw_crawcrd.nrprotoc,
                          rw_crawcrd.cdadmcrd,
                          rw_crawcrd.tpcartao,
                          rw_crawcrd.dtcancel,
                          rw_crawcrd.flgdebit,
													vr_flgproviint)
                          RETURNING ROWID INTO rw_crapcrd.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir crapcrd: '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  END IF;
                    
                  -- fecha ponteiro do registro de proposta recém criado
                  CLOSE cr_crawcrd_rowid;

                  -- Fecha cursor de Cartão de crédito
                  CLOSE cr_crapcrd;

                ELSE -- se encontrar proposta de cartão de crédito   
                    
                  /* Identifica se a solicitacao foi efetuada via WebService 
                    (Pelo WS carrega a conta cartão, o número do cartão (mascarado) e a situação fica como 2 - Solicitado)  */
                  vr_origemws := false;
                  
                  BEGIN
                    vr_final_cartao_aimaro := substr(lpad(cast(nvl(rw_crawcrd.nrcrcard,0) as varchar),16,'0'),13,4);
                    vr_final_cartao_cabal  := substr(lpad(cast(nvl(vr_nrcrcard        ,0) as varchar),16,'0'),13,4);
                    
                    IF (rw_crawcrd.nrcctitg = vr_nrdctitg AND              /* Mesma conta cartao */
                        rw_crawcrd.nrcrcard > 0 AND                        /* Numeracao de cartao preenchida */
                        vr_final_cartao_aimaro = vr_final_cartao_cabal AND /* Mesmo final de cartao */
                        ((rw_crawcrd.insitcrd = 2) or (SUBSTR(rw_crawcrd.nrcrcard,7,5) = '00000' AND rw_crawcrd.insitcrd = 1))) THEN    /* Solicitado ou Aprovado*/ 
						 /*
                          OR (SUBSTR(rw_crawcrd.nrcrcard,7,5) = '00000' AND rw_crawcrd.insitcrd = 1)
                          
                          Esta condição foi colocada devido ao arquivo vir com dois registros
                          um com Nr. cartão zerado porem com crítica (rejeitado), fazendo com que o 
                          campo insitcrd fosse atualizado de 2 - solicitado para 1 - aprovado.
                          e outro com o Nr. cartão completo, onde não caia neste IF, pois o registro anterior que 
                          foi rejeitado estava jogando o insitcrd para 1 - aprovado.
                        */
                       vr_origemws := true;  
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                     pc_log_dados_arquivo( pr_tipodreg => 2 -- Dados do cartao
                                          ,pr_nmdarqui => vr_vet_nmarquiv(i) -- Arquivo                   
                                          ,pr_nrdlinha => vr_linha
                                          ,pr_cdmensagem => 1255
                                          ,pr_dscritic => 'Erro verificando WS' || SQLERRM);
                     --Levantar Excecao
                     RAISE vr_exc_saida;
                  END;

                  /* Se número do Cartão for zerado ou
                   a proposta do cartão está previamente preenchida pelo WebService */
                  IF (rw_crawcrd.nrcrcard = 0) OR
                     (vr_origemws) THEN
                      
                    -- Atualiza registro de proposta de cartão se operação retornada for 01 ou 04
                    BEGIN
                      UPDATE crawcrd
                         SET nrcctitg = vr_nrdctitg,
                             nrcrcard = vr_nrcrcard
                       WHERE ROWID = rw_crawcrd.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;

                    IF cr_crawcrd_rowid%ISOPEN THEN
                      CLOSE cr_crawcrd_rowid;
                    END IF;

                    -- Obtem ponteiro do registro de proposta recém atualizado para alimentar a CRAPCRD corretamente
                    OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
                    FETCH cr_crawcrd_rowid INTO rw_crawcrd;

                    IF cr_crapcrd%ISOPEN THEN
                      CLOSE cr_crapcrd;
                    END IF;

                    -- buscar registro do cartão de crédito
                    OPEN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                    pr_nrdconta => rw_crawcrd.nrdconta,
                                    pr_nrcrcard => rw_crawcrd.nrcrcard);
                    FETCH cr_crapcrd INTO rw_crapcrd;

                    -- Se não encontrar registro do cartão de crédito,
                    IF cr_crapcrd%NOTFOUND THEN
                      -- Cria registro de Cartão de Crédito
                      BEGIN
												vr_flgproviint := 0;
												IF vr_flgprovi THEN
													 vr_flgproviint := 1;
												END IF;
                        INSERT INTO crapcrd
                           (cdcooper,
                            nrdconta,
                            nrcrcard,
                            nrcpftit,
                            nmtitcrd,
                            dddebito,
                            cdlimcrd,
                            dtvalida,
                            nrctrcrd,
                            cdmotivo,
                            nrprotoc,
                            cdadmcrd,
                            tpcartao,
                            dtcancel,
                            flgdebit,
														flgprovi)
                        VALUES
                           (rw_crawcrd.cdcooper,
                            rw_crawcrd.nrdconta,
                            rw_crawcrd.nrcrcard,
                            rw_crawcrd.nrcpftit,
                            rw_crawcrd.nmtitcrd,
                            rw_crawcrd.dddebito,
                            rw_crawcrd.cdlimcrd,
                            rw_crawcrd.dtvalida,
                            rw_crawcrd.nrctrcrd,
                            rw_crawcrd.cdmotivo,
                            rw_crawcrd.nrprotoc,
                            rw_crawcrd.cdadmcrd,
                            rw_crawcrd.tpcartao,
                            rw_crawcrd.dtcancel,
                            rw_crawcrd.flgdebit,
														vr_flgproviint)
                            RETURNING ROWID INTO rw_crapcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                      
                    ELSE -- se encontrar registro do cartão de crédito,

                      -- Atualiza registro de cartão de crédito
                      BEGIN
                        UPDATE crapcrd
                           SET nrcrcard = vr_nrcrcard
                         WHERE ROWID = rw_crapcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao atualizar crapcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;

                    END IF;

                    -- Fecha cursor de Cartão de crédito
                    CLOSE cr_crapcrd;

                    -- fecha ponteiro do registro de proposta recém atualizada
                    CLOSE cr_crawcrd_rowid;

                  ELSE -- Se o número do Cartão não for zerado (tratamento 2a. via)

                    -- Ignora registro caso o cartão obtido no arquivo já estiver
                    -- cadastrado na base de dados
                    IF (vr_nrcrcard = rw_crawcrd.nrcrcard) THEN
                      CLOSE cr_crawcrd;
                      CONTINUE;
                    END IF;
                    
                    -- Limpar variáveis
                    rw_crapacb.cdadmcrd := NULL;
                    
                    -- Buscar operadora do cartão solicitado via Upgrade/Downgrade
                    OPEN  cr_crawcrd_ativo(vr_cdcooper                 --pr_cdcooper
                                          ,vr_nrdconta                 --pr_nrdconta
                                          ,vr_nrdctitg                 --pr_nrcctitg
                                          ,vr_nrcpfcgc
                                          ,rw_crawcrd.rowid);
                    FETCH cr_crawcrd_ativo INTO rw_crapacb.cdadmcrd
                                              , vr_dddebito
                                              , vr_vllimcrd
                                              , vr_tpdpagto
                                              , vr_flgdebcc;

                    IF cr_crawcrd_ativo%NOTFOUND OR 
                       (cr_crawcrd_ativo%FOUND AND 
                        vr_nrcrcard <> rw_crawcrd.nrcrcard AND 
                        rw_crawcrd.nrcrcard <> 0) THEN
                      vr_dtentr2v := vr_dtmvtolt;
                    ELSE
                      vr_dtentr2v := NULL;
                    END IF;                    
                    
                    CLOSE cr_crawcrd_ativo;
                   
                    -- Se o cursor estiver aberto
                    IF cr_crawcrd%ISOPEN THEN
                      -- Fechar cursor
                      CLOSE cr_crawcrd;
                    END IF;
                    
                    -- buscar proposta de cartão
                    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper,
                                    pr_nrdconta => vr_nrdconta,
                                    pr_nrcpftit => vr_nrcpfcgc,
                                    pr_cdadmcrd => rw_crapacb.cdadmcrd,
                                    pr_rowid    => rw_crawcrd.rowid);
                    FETCH cr_crawcrd INTO rw_crawcrd;
                    
                    -- Se não encontrar o cartão solicitado
                    IF cr_crawcrd%NOTFOUND 
                      OR (cr_crawcrd%FOUND 
                          AND (vr_nrcrcard <> rw_crawcrd.nrcrcard) 
                          AND rw_crawcrd.nrcrcard <> 0) THEN
                      
                      -- obter numero do contrato (sequencial)
                      vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', vr_cdcooper);
                      
                      -- Deve buscar o contrato para inserir
                      vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(pr_cdcooper => vr_cdcooper);
                      
                      -- olha o indicador de funcao debito direto na linha que esta sendo processada
                      IF to_number(TRIM(substr(vr_des_text,337,12))) = 0 THEN
                        vr_flgdebit := 0;
                      ELSE
                        vr_flgdebit := 1;
                      END IF;
                  
                      -- Verifica se é o primeiro cartão bancoob da empresa desta administradora
                      OPEN cr_crawcrd_flgprcrd(pr_cdcooper => vr_cdcooper,
                                               pr_nrdconta => vr_nrdconta,
                                               pr_cdadmcrd => rw_crawcrd.cdadmcrd);
                      FETCH cr_crawcrd_flgprcrd INTO rw_crawcrd_flgprcrd;
                      IF cr_crawcrd_flgprcrd%FOUND THEN
                        -- Verificar se o CPF do titular do primeiro cartão é o mesmo que esta sendo validado
                        IF rw_crawcrd_flgprcrd.nrcpftit = rw_crawcrd.nrcpftit THEN
                          vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                        ELSE
                          vr_flgprcrd := 0; -- Não é o primeiro
                        END IF;
                      ELSE
                         vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                      END IF;
                      
                      IF cr_crawcrd_flgprcrd%ISOPEN THEN                        
                        -- fecha cursor
                        CLOSE cr_crawcrd_flgprcrd;
                      END IF;
                  
                      -- cria nova proposta com número do cartão vindo no arquivo
                      BEGIN
                        INSERT INTO crawcrd
                           (nrdconta,
                            nrcrcard,
                            nrcctitg,
                            nrcpftit,
                            vllimcrd,
                            flgctitg,
                            dtmvtolt,
                            nmextttl,
                            flgprcrd,
                            tpdpagto,
                            flgdebcc,
                            tpenvcrd,
                            vlsalari,
                            dddebito,
                            cdlimcrd,
                            tpcartao,
                            dtnasccr,
                            nrdoccrd,
                            nmtitcrd,
                            nrctrcrd,
                            cdadmcrd,
                            cdcooper,
                            nrseqcrd,
                            dtentr2v,
                            dtpropos,
                            flgdebit,
                            nmempcrd)
                        VALUES
                           (rw_crawcrd.nrdconta,
                            vr_nrcrcard, -- número cartão vindo do arquivo
                            vr_nrdctitg, -- Conta cartão vindo do arquivo
                            rw_crawcrd.nrcpftit,
                            rw_crawcrd.vllimcrd,
                            rw_crawcrd.flgctitg,
                            rw_crawcrd.dtmvtolt,
                            rw_crawcrd.nmextttl,
                            vr_flgprcrd, 
                            rw_crawcrd.tpdpagto,
                            rw_crawcrd.flgdebcc,
                            rw_crawcrd.tpenvcrd,
                            rw_crawcrd.vlsalari,
                            rw_crawcrd.dddebito,
                            rw_crawcrd.cdlimcrd,
                            rw_crawcrd.tpcartao,
                            rw_crawcrd.dtnasccr,
                            rw_crawcrd.nrdoccrd,
                            rw_crawcrd.nmtitcrd,
                            vr_nrctrcrd, --rw_crawcrd.nrctrcrd,
                            rw_crawcrd.cdadmcrd,
                            rw_crawcrd.cdcooper,
                            vr_nrseqcrd,
                            vr_dtentr2v,
                            vr_dtmvtolt,
                            vr_flgdebit,
                            rw_crawcrd.nmempcrd)
                            RETURNING ROWID INTO rw_crawcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    ELSE
                      
                      -- Atualiza registro de proposta de cartão se operação retornada for 01 ou 04
                      BEGIN
                        UPDATE crawcrd
                           SET nrcrcard = vr_nrcrcard
                         WHERE ROWID = rw_crawcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro[2] ao atualizar crawcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    
                    END IF; 

                    IF cr_crawcrd_rowid%ISOPEN THEN
                      CLOSE cr_crawcrd_rowid;
                    END IF;

                    -- Obtem ponteiro do registro de proposta recém criado
                    OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
                    FETCH cr_crawcrd_rowid INTO rw_crawcrd;

                    IF cr_crapcrd%ISOPEN THEN
                      CLOSE cr_crapcrd;
                    END IF;

                    -- buscar registro do cartão de crédito
                    OPEN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                    pr_nrdconta => rw_crawcrd.nrdconta,
                                    pr_nrcrcard => rw_crawcrd.nrcrcard);
                    FETCH cr_crapcrd INTO rw_crapcrd;

                    -- Se encontrar registro do cartão, cria log e continua
                    IF cr_crapcrd%FOUND THEN
                      -- LOGA NO PROC_MESSAGE
                      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper_ori
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                 || vr_cdprogra || ' --> '
                                                                 || 'CARTAO JA EXISTENTE - NR: ' || rw_crawcrd.nrcrcard || ' '
                                                                 || 'CONTA: ' || rw_crawcrd.nrdconta || ' COOP.: ' || rw_crawcrd.cdcooper
                                                                 || ' ARQ.: ' || vr_nmarquiv
                                                ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                      CONTINUE;
                    ELSE
                      -- cria novo registro de cartão de crédito
                      BEGIN
												vr_flgproviint := 0;
												IF vr_flgprovi THEN
													 vr_flgproviint := 1;
												END IF;
                        INSERT INTO crapcrd
                           (cdcooper,
                            nrdconta,
                            nrcrcard,
                            nrcpftit,
                            nmtitcrd,
                            dddebito,
                            cdlimcrd,
                            dtvalida,
                            nrctrcrd,
                            cdmotivo,
                            nrprotoc,
                            cdadmcrd,
                            tpcartao,
                            dtcancel,
                            flgdebit,
                            flgprovi)
                        VALUES
                           (rw_crawcrd.cdcooper,
                            rw_crawcrd.nrdconta,
                            rw_crawcrd.nrcrcard,
                            rw_crawcrd.nrcpftit,
                            rw_crawcrd.nmtitcrd,
                            rw_crawcrd.dddebito,
                            rw_crawcrd.cdlimcrd,
                            rw_crawcrd.dtvalida,
                            rw_crawcrd.nrctrcrd,
                            rw_crawcrd.cdmotivo,
                            rw_crawcrd.nrprotoc,
                            rw_crawcrd.cdadmcrd,
                            rw_crawcrd.tpcartao,
                            rw_crawcrd.dtcancel,
                            rw_crawcrd.flgdebit,
                            vr_flgproviint)
                            RETURNING ROWID INTO rw_crapcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    
                    END IF;                    
                    
                    -- Fecha cursor de Cartão de crédito
                    CLOSE cr_crapcrd;
                                        
                    -- fecha ponteiro do registro de proposta recém criado
                    CLOSE cr_crawcrd_rowid;

                  END IF;
                END IF;

                -- Fecha cursor de proposta de cartão de crédito
                CLOSE cr_crawcrd;

                -- Atualiza situação da proposta de cartão de crédito
                BEGIN
                  UPDATE crawcrd
                     SET insitcrd = 3 -- Liberado
                       , dtentreg = NULL
                       , inanuida = 0
                       , qtanuida = 0
                       , dtlibera = trunc(SYSDATE)
                       , dtrejeit = NULL
                       -- cdoperad = pr_cdoperad  -- Não deve sobrescrever o operador ( Renato - Supero )
                   WHERE ROWID = rw_crawcrd.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar situacao da crawcrd: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

                --> Gravar registro de conta cartão
                CCRD0003.pc_insere_conta_cartao(rw_crawcrd.cdcooper,                  --> cdcooper
                                                rw_crawcrd.nrdconta,                  --> nrdconta
                                                TO_NUMBER(substr(vr_des_text,25,13)), --> nrcctitg
                                                vr_cdcritic,
                                                vr_dscritic);
                IF (nvl(vr_cdcritic,0) > 0) or
                   (nvl(vr_dscritic,' ') <> ' ') THEN
                   -- LOGA NO PROC_MESSAGE
                   btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper_ori
                                             ,pr_ind_tipo_log => 2 -- Erro tratato
                                             ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || 'Nao foi possivel gravar tabela relac. conta e conta cartao. '||' - '
                                                              || 'COOP.: '   || rw_crawcrd.cdcooper || ' - '
                                                              || 'CONTA: '   || rw_crawcrd.nrdconta || ' - '
                                                              || 'Critica: ' || vr_dscritic || ' - '
                                                              || ' ARQ.: '   || vr_nmarquiv
                                             ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                   CONTINUE;
              END IF;

              END IF;
            EXCEPTION
              WHEN no_data_found THEN -- não encontrar mais linhas
                EXIT;
              WHEN OTHERS THEN
                IF vr_dscritic IS NULL THEN
                  vr_dscritic := 'Erro arquivo ['|| vr_vet_nmarquiv(i) ||']: '||SQLERRM;
                END IF;
                RAISE vr_exc_saida;
            END;
          END LOOP;

          -- Fechar o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;

          -- Montar Comando para copiar o arquivo lido para o diretório recebidos do CONNECT
          vr_comando:= 'cp '|| vr_direto_connect || '/' || vr_vet_nmarquiv(i) ||
                       ' '  || rw_crapscb.dsdirarq || '/recebidos/ 2> /dev/null';

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);

          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_saida;
          END IF;

          -- Montar Comando para mover o arquivo lido para o diretório salvar
          vr_comando:= 'mv '|| vr_direto_connect || '/' || vr_vet_nmarquiv(i) ||
                       ' '|| vr_dsdireto || '/salvar/ 2> /dev/null';

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);

          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_saida;
          END IF;

          -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
          IF nvl(vr_nrseqarq_max,0) > nvl(rw_crapscb.nrseqarq,0) THEN
            BEGIN
              UPDATE crapscb
                 SET dtultint = SYSDATE,
                     nrseqarq = vr_nrseqarq_max
              WHERE crapscb.rowid = rw_crapscb.rowid;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;

          -- Apos processar o arquivo, deve realizar o commit,
          -- pois já moveu para a pasta recebidos
          COMMIT;

        END IF;

      END LOOP;
      
      IF  vr_vet_nrdlote.COUNT > 0 THEN
        
        vr_indice := vr_vet_nrdlote.FIRST;
        vr_vet_lsnrdlote := gene0002.fn_quebra_string(vr_vet_nrdlote(vr_indice).lsnrdlote,';');
        
        LOOP  
          
          FOR idx IN 1..vr_vet_lsnrdlote.count() LOOP
            
            -- se for nulo pular para o proximo
            IF TRIM(vr_vet_lsnrdlote(idx)) IS NULL THEN
              continue;
            END IF;
                  
            -- Após processar os arquivos, deve verificar se foi gerado lote de envio de SMS
            --> Enviar lote de SMS para o Aymaru
            pc_enviar_lote_SMS(pr_cdcooper => vr_cdcooper_ori
                              ,pr_idlotsms => vr_vet_lsnrdlote(idx)
                              ,pr_dscritic => vr_dscritic
                              ,pr_cdcritic => vr_cdcritic);
                          
            -- Se houve retorno de algum erro      
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              -- Em caso de erro deve setar o lote como FALHA
             /* BEGIN
                UPDATE tbgen_sms_lote lot
                   SET lot.idsituacao = 'F' -- Falha
                 WHERE lot.idlote_sms = vr_idlotsms;
              EXCEPTION 
                WHEN OTHERS THEN
                  -- Não irá alterar a mensagem de erro, para que mostre a mensagem de retorno do AYMARU
                  RAISE vr_exc_saida;
              END;  */
              
              pc_log_message;
            END IF;
          
          END LOOP;
          
          -- Fechar a situação do lote
         /* ESMS0001.pc_conclui_lote_sms(pr_idlote_sms  => vr_idlotsms
                                       ,pr_dscritic   => vr_dscritic);
            
          -- Se houve retorno de algum erro      
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;*/
          EXIT WHEN vr_vet_nrdlote.LAST = vr_indice;

          vr_indice := vr_vet_nrdlote.NEXT(vr_indice);

          vr_vet_lsnrdlote := gene0002.fn_quebra_string(vr_vet_nrdlote(vr_indice).lsnrdlote,';');
          
        END LOOP;   
      END IF;
      -- Adiciona a linha ao XML
      pc_escreve_xml(vr_xml_lim_cartao,'</crrl707>');

      -- Apaga o arquivo pc_crps672.txt no unix
      vr_comando:= 'rm ' || vr_direto_connect || '/pc_crps672.txt 2> /dev/null';
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;

      -- GERAÇÃO DE RELATÓRIO DE REJEIÇÕES DA LEITURA DO ARQUIVO DE RETORNO

      -- Percorre todos os registros retornados pelo cursor
      FOR rw_crapcop_todas IN cr_crapcop_todas LOOP
        -- Preparar o CLOB para armazenar as infos do arquivo
        dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
        pc_escreve_xml(vr_xml_clobxml, '<?xml version="1.0" encoding="utf-8"?>'||chr(10)||'<crrl676>'||chr(10));

        vr_pa_anterior  := 0;
       
        vr_pa_proximo   := false;
        FOR rw_craprej IN cr_craprej(pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_cdcooper => rw_crapcop_todas.cdcooper) LOOP          
         
          
          IF vr_pa_anterior <> rw_craprej.cdagenci THEN
             IF vr_pa_proximo THEN 
                pc_escreve_xml(vr_xml_clobxml,'</agencia>');
             END IF ;            
             pc_escreve_xml (vr_xml_clobxml,'<agencia cdagenci="'||rw_craprej.cdagenci||'" nmextage="'||rw_craprej.nmextage||'">');
             vr_pa_proximo := true;      
            
          END IF;  
          
          vr_pa_anterior  := rw_craprej.cdagenci;
          

        -- Adiciona a linha ao XML
        pc_escreve_xml (vr_xml_clobxml,'<rejeitados>'
               ||chr(10)||'<cdcooper>'||rw_craprej.cdcooper||'</cdcooper>'
               ||chr(10)||'<nmtitcrd>'||NVL(TRIM(rw_craprej.nmtitcrd), ' ') ||'</nmtitcrd>'
               ||chr(10)||'<cdpesqbb>'||TRIM(rw_craprej.cdpesqbb)||'</cdpesqbb>'
               ||chr(10)||'<nrdocmto>'||TRIM(gene0002.fn_mask(rw_craprej.nrdocmto,'zz.zzz.zzz'))||'</nrdocmto>'
               ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(rw_craprej.nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
               ||chr(10)||'<nrdctitg>'||TRIM(to_char(rw_craprej.nrdctitg))||'</nrdctitg>'
               ||chr(10)||'<cdtipope>'||TRIM(rw_craprej.cdtipope) || '-' ||  vr_vet_nmtipsol(rw_craprej.cdtipope) ||'</cdtipope>'
               ||chr(10)||'<cdcritic>'||TRIM(REPLACE(rw_craprej.cdcritic,',',chr(10))) ||'</cdcritic>'
               ||chr(10)||'</rejeitados>');

        IF vr_pa_anterior <> rw_craprej.cdagenci THEN             
             pc_escreve_xml (vr_xml_clobxml,'</agencia>');
             vr_pa_proximo := FALSE;
          END IF;  

        END LOOP;
        
       IF vr_pa_anterior > 0 AND  vr_pa_proximo = TRUE THEN
         pc_escreve_xml (vr_xml_clobxml,'</agencia>');
       END IF;
       
        
      -- Adiciona a linha ao XML
       pc_escreve_xml(vr_xml_clobxml,'</crrl676>');

     -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M'         --> /usr/micros
                                          ,pr_cdcooper => rw_crapcop_todas.cdcooper
                                          ,pr_nmsubdir => null); 
                                          
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => rw_crapcop_todas.cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
      
      vr_dsdirarq := vr_dsdireto||'/cecred_cartoes/crrl676_'||to_char(vr_dtmvtolt,'DDMMYYYY')||'.pdf';                                
      
      -- Submeter o relatório 676
      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop_todas.cdcooper            --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt                          --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl676/agencia   '                --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl676.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 234 colunas
                                 ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '676'                               --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_clobxml);
      dbms_lob.freetemporary(vr_xml_clobxml);
      
      END LOOP;

      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M'         --> /usr/micros
                                          ,pr_cdcooper => vr_cdcooper_ori
                                          ,pr_nmsubdir => null); 
                                          
      vr_dsdirarq := vr_dsdireto || '/cecred_cartoes/crrl707_'||to_char(vr_dtmvtolt,'DDMMYYYY');
      
      -- Submeter o relatório 676
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper_ori     --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_lim_cartao   --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl707/Dados'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl707.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdirarq ||'.lst'--> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                 --> 134 colunas
                                 ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '707'               --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_lim_cartao);
      dbms_lob.freetemporary(vr_xml_lim_cartao);
      
      -- Gera a impressao pelo SCRIPT para ficar formatado a margen no PDF
      GENE0002.pc_gera_pdf_impressao(pr_cdcooper => vr_cdcooper_ori
                                    ,pr_nmarqimp => vr_dsdirarq ||'.lst'
                                    ,pr_nmarqpdf => vr_dsdirarq ||'.pdf'
                                    ,pr_des_erro => vr_dscritic);
                                    
      -- Se existir arquivo, limpar pcl
      IF GENE0001.fn_exis_arquivo(vr_dsdirarq ||'.lst') THEN
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq ||'.lst 2>/dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
      END IF;                                  

      BEGIN
        -- Excluir registros
        DELETE craprej
         WHERE craprej.dtmvtolt = vr_dtmvtolt
           AND craprej.dshistor = 'CCR3';

      EXCEPTION
        WHEN OTHERS THEN
          -- Buscar descricão do erro
          vr_dscritic := 'Erro ao excluir craprej: '||SQLERRM;
          -- Envio centralizado de log de erro
          RAISE vr_exc_saida;
      END;

    EXCEPTION
       WHEN vr_exc_saida THEN
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>1</TpException></Root>');
      WHEN vr_exc_fimprg THEN
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Desfaz as alterações da base
        ROLLBACK;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || vr_dscritic || '</Erro><TpException>2</TpException></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'Erro geral em CCR3/CRPS672: ' || SQLERRM;

        pc_internal_exception(3, pr_dscritic);
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        -- Desfaz as alterações da base
        ROLLBACK;

    END;

  END pc_crps672;
  
  /*.......................................................................................

   Programa: CCDR0003
   Sigla   : APLI
   Autor   : Tiago
   Data    : Junho/2015                          Ultima atualizacao: 26/05/2017

   Dados referentes ao programa:

   Objetivo  : Procedure para realizar lancamentos da fatura dos cartoes - logica extraida
               do programa PC_CRPS674.

   Alteracoes:  
   
   09/10/2015 - #344590 Retirada a mudança de situação para "não efetuado" pois iria parar o repique das 
                contas que não tinham o valor mínimo parametrizado na primeira tentativa de pagamento (Carlos)
                  
   23/02/2016 - Quando for verificar o saldo retirar a subtracao do valor do bloqueio judicial
                da somatoria (Tiago/Rodrigo SD405466)
                
   01/09/2016 - Qdo o ultimo dia de repique da fatura for feriado mudar a situacao da
                fatura pra Nao Efetivado pois esta gerando um problema
                (Tiago/Quisinski #506917).
                
   13/03/2017 - Ajuste no tratamento acima descrito para contemplar tambem o feriado de carnaval.
                (Chamado 624482) - (Fabricio)
                
   15/05/2017 - Incluido parenteses no IF que valida se deve terminar o repique (Tiago/Fabricio)                
   
   15/05/2017 - Correções para repique contando 1 dia util para repique ao inves de dias corridos
                (Tiago/Fabricio).
                
   26/05/2017 - Tratado para pegar uma data de referencia que sirva para todas as situações de
                vencimento de fatura contando que os dias de repique agora são dias uteis
                (Tiago/Fabricio #677702)
  .......................................................................................*/
  PROCEDURE pc_debita_fatura(pr_cdcooper  IN crapcop.cdcooper%TYPE
                            ,pr_cdprogra  IN crapprg.cdprogra%TYPE
                            ,pr_cdoperad  IN crapope.cdoperad%TYPE                             
                            ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                            ,pr_fatrowid  IN ROWID DEFAULT NULL
                            ,pr_cdcritic  OUT crapcri.cdcritic%TYPE
                            ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE    
    
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
			
      -- cursor para retornar faturas pendentes de debito
      CURSOR cr_tbcrd_fatura(pr_cdcooper   IN crapcop.cdcooper%TYPE,
                             pr_insituacao IN tbcrd_fatura.insituacao%TYPE,
                             pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE,
                             pr_dtmvtoan   IN crapdat.dtmvtoan%TYPE,
                             pr_fatrowid   IN ROWID) IS
        SELECT *
          FROM tbcrd_fatura fat
         WHERE fat.cdcooper     = pr_cdcooper
           AND fat.insituacao   = pr_insituacao
           AND (trunc(fat.dtvencimento)  BETWEEN trunc(pr_dtmvtoan) AND trunc(pr_dtmvtolt))
           AND fat.rowid = DECODE(pr_fatrowid,NULL,fat.rowid,pr_fatrowid);                            

      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT *
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_crawcrd(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
        SELECT *
          FROM crawcrd crd
         WHERE crd.cdcooper = pr_cdcooper
           AND crd.nrdconta = pr_nrdconta
           AND crd.nrctrcrd = pr_nrctrcrd;
      rw_crawcrd cr_crawcrd%ROWTYPE;     

      
      --Variáveis locais
      vr_dstransa   VARCHAR2(100);
      vr_tab_sald   EXTR0001.typ_tab_saldos;     --> Temp-Table com o saldo do dia
      vr_ind_sald   PLS_INTEGER;                 --> Indice sobre a temp-table vr_tab_sald
      vr_vlsddisp   NUMBER(17,2);                --> Valor de saldo disponivel			
      vr_vlpagmto   NUMBER(17,2);                --> Valor de pagamento
      vr_dtmvante   DATE;                        --> Data anterior, usada para pegar fatura uam qtd x de dias
      vr_vlminpag   NUMBER(17,2);                --> Parametro de valor minimo de pagamento para fatura
      vr_qtddiapg   INTEGER;                     --> Qtd de dias corridos que vai tentar debitar a fatura por meio de repique
      vr_flrepccr   VARCHAR2(1);                 --> Deve efetuar repique ou nao (S/N)
      vr_idpagamento_fatura NUMBER(25);          --> Id pagamento da fatura
      vr_tporigem   tbcrd_pagamento_fatura.tporigem%TYPE; --> Origem do processo
      vr_vlsomsld   NUMBER(17,2) := 0;           --> Valor pago da fatura que ira somar no saldo do dia
      vr_dtultsld   DATE;                        --> Ultimo dia que foi recomposto o saldo do dia da fatura
      vr_flmuddia   INTEGER := 0;                --> Flag para mudar data do saldo da fatura
      vr_prmrowid   ROWID;
      
      vr_dsconteu   VARCHAR(100);                --> Auxiliar para retornar da funcao de busca de parametro
      
      vr_idxrel     INTEGER := 0;  
      
      -- Objetos para armazenar as variáveis da notificação
      vr_variaveis_notif NOTI0001.typ_variaveis_notif;
      vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE;
      vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE; 

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_exc_erro   EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);  
	    vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro; 
      
      ct_hispgfat CONSTANT INTEGER := 1545;
      
      -- controle execuções programa
      vr_flultexe     INTEGER;
      vr_qtdexec      INTEGER;
      
      FUNCTION fn_inicia_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN ROWID IS
      BEGIN
        DECLARE
          CURSOR cr_crapprm(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
            SELECT ROWID,
                   dsvlrprm 
              FROM crapprm
             WHERE cdcooper = pr_cdcooper
               AND crapprm.nmsistem = 'CRED'
               AND crapprm.cdacesso = 'FL_EXECUTADO_674';
               
          rw_crapprm cr_crapprm%ROWTYPE;     
          
          vr_prmrowid ROWID;
        BEGIN
          
          OPEN cr_crapprm(pr_cdcooper => pr_cdcooper);
          FETCH cr_crapprm INTO rw_crapprm;
          
          IF cr_crapprm%NOTFOUND THEN
             CLOSE cr_crapprm;
             RETURN NULL;
          ELSE
             CLOSE cr_crapprm;   
          END IF;
             
          IF rw_crapprm.dsvlrprm = 'S' THEN
            BEGIN
              UPDATE crapprm
                 SET crapprm.dsvlrprm = 'N'
               WHERE cdcooper = pr_cdcooper
                 AND crapprm.nmsistem = 'CRED'
                 AND crapprm.cdacesso = 'FL_EXECUTADO_674'
               RETURN ROWID INTO vr_prmrowid;
            EXCEPTION
              WHEN OTHERS THEN
                RETURN NULL;
            END; 
          ELSE
            RETURN NULL;   
          END IF;  
          
          RETURN vr_prmrowid;          
        EXCEPTION
          WHEN OTHERS THEN
            RETURN NULL;          
        END;    
      END fn_inicia_exec;
      
      FUNCTION fn_encerra_exec(pr_prmrowid IN ROWID) RETURN BOOLEAN IS
      BEGIN
        BEGIN
          UPDATE crapprm
             SET crapprm.dsvlrprm = 'S'
           WHERE crapprm.rowid = pr_prmrowid;
           
          RETURN TRUE; 
        EXCEPTION
          WHEN OTHERS THEN
            RETURN FALSE;
        END;
      EXCEPTION        
        WHEN OTHERS THEN
          RETURN FALSE;  
      END fn_encerra_exec;
      
    BEGIN
      -- Verifica se o programa que chamou é o CRPS674
      -- para verificar a quantidade de execução programada no debitador
      -- Faz o controle de execução para saber quando é a última execução
      -- Projeto debitador único
      if pr_cdprogra = 'CRPS674' then
         -- Verifica quantidade de execuções do programa durante o dia no Debitador Único
         gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper    => pr_cdcooper   --Cooperativa
                                                     ,pr_cdprocesso => 'PC_'||pr_cdprogra --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)
                                                     ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica
         IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
         END IF;

         -- registrar a quantidade de execução
         -- Projeto debitador unico
         SICR0001.pc_controle_exec_deb (pr_cdcooper   => pr_cdcooper         --> Código da coopertiva
                                        ,pr_cdtipope  => 'I'                 --> Tipo de operacao I-incrementar e C-Consultar
                                        ,pr_dtmvtolt  => pr_dtmvtolt         --> Data do movimento
                                        ,pr_cdprogra  => pr_cdprogra         --> Codigo do programa
                                        ,pr_flultexe  => vr_flultexe         --> Retorna se é a ultima execução do procedimento
                                        ,pr_qtdexec   => vr_qtdexec          --> Retorna a quantidade
                                        ,pr_cdcritic  => vr_cdcritic         --> Codigo da critica de erro
                                        ,pr_dscritic  => vr_dscritic);       --> descrição do erro se ocorrer

           IF nvl(vr_cdcritic,0) > 0 OR
              TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;

           --Commit para garantir o
           --controle de execucao do programa
           COMMIT;
      end if;

     
      --funcao que starta execucao dos debitos somente se os debito anteriores
      --estiverem ok de acordo com parametro da prm
      vr_prmrowid := fn_inicia_exec(pr_cdcooper => pr_cdcooper);
      
      IF vr_prmrowid IS NULL THEN
         vr_dscritic := 'Execucao dos debitos das Faturas esta pendente, programa nao executado.';
         RAISE vr_exc_saida;
      END IF;        
    
      vr_dscritic := '';
      --Buscar Transacao
      vr_dstransa:= 'Debito fatura';

      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'DIASREPCCR'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_tab_erro => vr_tab_erro);
                                            
      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro = 'NOK' THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Fescrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || pr_cdprogra || ' --> '  ||
                                                        vr_dscritic || ' - DIASREPCCR');
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          
          -- Quantidade Isento
          vr_qtddiapg := 0;
        END IF;
      ELSE
        -- Quantidade dias que pode ser feito repique
        vr_qtddiapg := to_number(vr_dsconteu);  
      END IF;                                            
                                            
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'VMINREPCCR'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_tab_erro => vr_tab_erro);

      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro = 'NOK' THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Fescrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || pr_cdprogra || ' --> '  ||
                                                        vr_dscritic || ' - VMINREPCCR');
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          
          -- Valor minimo para pagamento de fatura qdo houver repique
          vr_vlminpag := 0;
        END IF;
      ELSE
        -- Valor minimo para pagamento de fatura qdo houver repique
        vr_vlminpag := to_number(vr_dsconteu);  
      END IF;

      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'FLAGREPCCR'
                                            ,pr_dsconteu => vr_dsconteu 
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_tab_erro => vr_tab_erro);
                                            
      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro = 'NOK' THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Fescrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || pr_cdprogra || ' --> '  ||
                                                        vr_dscritic || ' - FLAGREPCCR');
          -- Efetua Limpeza das variaveis de critica
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          
          -- Realiza repique
          vr_flrepccr := 'N';
        END IF;
      ELSE
        -- Flag que indica se a coop realiza ou n S/N
        vr_flrepccr := vr_dsconteu;  
      END IF;

      -- Pegar a data de referencia do periodo    
      vr_dtmvante:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => pr_dtmvtolt - vr_qtddiapg, pr_tipo => 'A');
      vr_dtmvante:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => vr_dtmvante - 1, pr_tipo => 'A');
      
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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
      
      -- Percorre os registros de lancamentos fatura
      FOR rw_tbcrd_fatura IN cr_tbcrd_fatura(pr_cdcooper   => pr_cdcooper,
                                             pr_dtmvtolt   => pr_dtmvtolt,
                                             pr_dtmvtoan   => vr_dtmvante,
                                             pr_insituacao => 1          ,
                                             pr_fatrowid   => pr_fatrowid) LOOP
                                         
        -- se for no dia do vencimento e nao for processo
        -- noturno nao deve realizar debito    
        IF gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => rw_tbcrd_fatura.dtvencimento, pr_tipo => 'P') = pr_dtmvtolt AND
           upper(pr_cdprogra) <> 'CRPS674' THEN
           CONTINUE;
        END IF;

        -- busca informacoes da conta
        OPEN cr_crapass(pr_cdcooper => rw_tbcrd_fatura.cdcooper,
                        pr_nrdconta => rw_tbcrd_fatura.nrdconta);                        
        FETCH cr_crapass INTO rw_crapass;
        
        IF cr_crapass%NOTFOUND THEN
           CLOSE cr_crapass;
           
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> ' 
                                                      || 'COOP '||rw_tbcrd_fatura.cdcooper||' '
                                                      || 'CONTA '||rw_tbcrd_fatura.nrdconta||' '
                                                      || 'IDFATURA '||rw_tbcrd_fatura.idfatura||' ,cooperado nao encontrado!');           
           CONTINUE;  
        END IF;

        --Fecha cursor
        CLOSE cr_crapass;
        
        OPEN cr_crawcrd(pr_cdcooper => rw_tbcrd_fatura.cdcooper,
                        pr_nrdconta => rw_tbcrd_fatura.nrdconta,
                        pr_nrctrcrd => rw_tbcrd_fatura.nrcontrato);
            
        FETCH cr_crawcrd INTO rw_crawcrd;
                    
        IF cr_crawcrd%NOTFOUND THEN
           CLOSE cr_crawcrd;
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                     ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                      || pr_cdprogra || ' --> '
                                                      || 'COOP '||rw_tbcrd_fatura.cdcooper||' '
                                                      || 'CONTA '||rw_tbcrd_fatura.nrdconta||' '
                                                      || 'NRCONTRATO '||rw_tbcrd_fatura.nrcontrato||' '
                                                      || 'IDFATURA '||rw_tbcrd_fatura.idfatura||' ,cartao nao encontrado!');
           CONTINUE;  
        END IF;                        
                                             
        --Fecha cursor
        CLOSE cr_crawcrd;
                                             
				-- Obter valores de saldos diários
				extr0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_tbcrd_fatura.cdcooper,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci   => rw_crapass.cdagenci, 
                                    pr_nrdcaixa   => 0,
                                    pr_cdoperad   => pr_cdoperad,
                                    pr_nrdconta   => rw_tbcrd_fatura.nrdconta,
                                    pr_vllimcre   => rw_crapass.vllimcre,
                                    pr_dtrefere   => rw_crapdat.dtmvtolt,
                                    pr_tipo_busca => 'A', --Usar data do dia anterior na crapsda
                                    pr_des_reto   => vr_des_erro,
                                    pr_tab_sald   => vr_tab_sald,
                                    pr_tab_erro   => vr_tab_erro);

				-- se encontrar erro	                                   
				IF vr_des_erro = 'NOK' THEN
					-- presente na tabela de erros
					IF vr_tab_erro.count > 0 THEN
						-- adquire descrição 
						vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
						-- grava log
						btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
																			 pr_ind_tipo_log => 2, -- Erro tratato
																			 pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss') || ' -'    || 
																																					 pr_cdprogra  || ' --> ' || vr_dscritic);
					END IF;					
					-- Volta para o inicio do loop
					CONTINUE;
				END IF;																		
									
				-- alimenta indice da temp-table				
				vr_ind_sald := vr_tab_sald.last;
        
        -- inicializa o valor de pagamento
        vr_vlpagmto := 0;

				-- adquire saldo disponível total da conta (saldo + cheque especial + limite de crédito)
				vr_vlsddisp := vr_tab_sald(vr_ind_sald).vlsddisp + vr_tab_sald(vr_ind_sald).vlsdchsl +											 
											 vr_tab_sald(vr_ind_sald).vllimcre;	
        

        IF upper(pr_cdprogra) = 'DEBCCR' THEN
           vr_tporigem := 4; --debito manual efetuado pela tela DEBCCR
        ELSE
           IF upper(pr_cdprogra) = 'REPIQUE' THEN
              vr_tporigem := 3; --Repique diario   
           ELSE
              IF upper(pr_cdprogra) = 'CRPS674' THEN
                 vr_tporigem := 2; --Repique noturno                      
              END IF;                     
           END IF;   
        END IF;          
                       
        -- Identifica se eh uma situacao normal de pagamento
        -- no dia do vencimento ou eh repique de fatura
        IF rw_tbcrd_fatura.vlfatura     = rw_tbcrd_fatura.vlpendente AND 
           gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => rw_tbcrd_fatura.dtvencimento, pr_tipo => 'P') = pr_dtmvtolt                THEN           
           -- Situacao de primeiro pagamento da fatura          
           
           -- Tem o valor total da fatura para pagto
           IF vr_vlsddisp >= rw_tbcrd_fatura.vlfatura THEN
              vr_vlpagmto := rw_tbcrd_fatura.vlfatura;
              
              IF upper(pr_cdprogra) = 'CRPS674' THEN
                 vr_tporigem := 1; --Processo noturno
              END IF;  

           ELSE             

              --Tem apenas o valor minimo para pagamento              
              IF vr_vlsddisp >= vr_vlminpag /* rw_tbcrd_fatura.vlminimo_pagamento */ AND 
                 vr_flrepccr = 'S' THEN
                 vr_vlpagmto := vr_vlsddisp;                
              ELSE                 
                 CONTINUE;   
              END IF;                         
              
           END IF;  
        
        ELSE                 
           -- Situacao de repique, repique so pode ser feito 
           -- apos o dia do vencimento da fatura e a flag de
           -- parametro estiver marcada para processar repique
           IF rw_tbcrd_fatura.dtvencimento > pr_dtmvtolt OR             
              vr_flrepccr = 'N' THEN   
              
              --Se for uma situacao de repique e a coop nao realiza
              --repique mudar situacao da fatura para nao realizar 
              --nova tentativa de debito
              BEGIN
                UPDATE tbcrd_fatura
                   SET tbcrd_fatura.insituacao = 4 
                 WHERE tbcrd_fatura.idfatura = rw_tbcrd_fatura.idfatura;
              EXCEPTION
                WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar tbcrd_fatura: '||SQLERRM;
                     RAISE vr_exc_saida;
              END;                 
                         
              CONTINUE;
           END IF;           
           
           -- Ja houve pelo menos pagamento do minimo da fatura
           --IF (rw_tbcrd_fatura.vlfatura - rw_tbcrd_fatura.vlpendente) >= rw_tbcrd_fatura.vlminimo_pagamento THEN
              
          -- Ultimo pagamento fatura via repique
          IF rw_tbcrd_fatura.vlpendente < vr_vlminpag  AND
             vr_vlsddisp >= rw_tbcrd_fatura.vlpendente THEN
             vr_vlpagmto := rw_tbcrd_fatura.vlpendente;
          END IF;
              
          IF vr_vlsddisp >= vr_vlminpag                AND
             rw_tbcrd_fatura.vlpendente >= vr_vlminpag THEN
                 
             IF vr_vlsddisp >= rw_tbcrd_fatura.vlpendente THEN
                vr_vlpagmto := rw_tbcrd_fatura.vlpendente;
             ELSE                   
                vr_vlpagmto := vr_vlsddisp;
             END IF;
                 
          END IF;
          
           /*   
           ELSE
             
             -- Se ainda nao houve pelo menos pagamento minimo da fatura tenta efetuar primeiro
             -- pelo menos este pagamento para comecar a realizar o repique   
             -- Tem o valor total da fatura para pagto
             IF vr_vlsddisp >= rw_tbcrd_fatura.vlfatura THEN
                vr_vlpagmto := rw_tbcrd_fatura.vlfatura;
             ELSE
                --Tem apenas o valor minimo para pagamento
                IF vr_vlsddisp >= rw_tbcrd_fatura.vlminimo_pagamento THEN
                   vr_vlpagmto := vr_vlsddisp;  
                END IF;                
             END IF;       
           
              
           END IF;        */
           
        END IF;
        
        -- Realiza lancamento conforme o vr_vlpagmto mesmo se estiver zerado
        -- só nao gera LCM se valor estiver zerado.
        BEGIN 
          INSERT INTO tbcrd_pagamento_fatura
                 (idpagamento_fatura
                 ,idfatura
                 ,dtpagamento
                 ,cdhistor
                 ,vlpagamento
                 ,vlsaldo_conta
                 ,tporigem
                 ,dtreferencia)
           VALUES(seq_crd_idpagamento_fatura.nextval
                 ,rw_tbcrd_fatura.idfatura
                 ,pr_dtmvtolt
                 ,ct_hispgfat -- Historico de pgto fatura cartao
                 ,vr_vlpagmto
                 ,vr_vlsddisp
                 ,vr_tporigem
                 ,SYSDATE)
           RETURN tbcrd_pagamento_fatura.idpagamento_fatura INTO vr_idpagamento_fatura;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir tbcrd_pagamento_fatura: '||SQLERRM;
            RAISE vr_exc_saida;
        END;        

/* Regra comentado pois validava os dias de repique como dias corridos e passou a ser dias uteis
        IF (((gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_tbcrd_fatura.dtvencimento
                                        ,pr_tipo => 'P') = (pr_dtmvtolt - vr_qtddiapg) AND 
            (rw_tbcrd_fatura.vlpendente - vr_vlpagmto) > 0)  OR           
            -- valida se eh penultimo dia, antipenultimo... 
            -- (contempla feriado de carnaval com esta mudanca no IF)
           ((gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_tbcrd_fatura.dtvencimento
             ,pr_tipo => 'P') -  (pr_dtmvtolt - vr_qtddiapg)) < (rw_crapdat.dtmvtopr - pr_dtmvtolt) AND
            (gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => pr_dtmvtolt + 1
                                        , pr_tipo => 'P') > (pr_dtmvtolt + 1))))               AND 
           pr_cdprogra = 'CRPS674') THEN        */


        --Mudar situacao da fatura para nao efetuado qdo 
        --for o ultimo dia do repique e nao conseguiu realizar o pagamento total        
        IF pr_cdprogra = 'CRPS674' AND          
           vr_flultexe = 1 AND -- somente quando for a última execução do debitador  - Projeto Debitador Unico    
          (rw_tbcrd_fatura.vlpendente - vr_vlpagmto) > 0 AND
           gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => rw_tbcrd_fatura.dtvencimento
                                      ,pr_tipo => 'P') = 
           gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => (pr_dtmvtolt - vr_qtddiapg)
                                      ,pr_tipo => 'A') THEN
          BEGIN            
            UPDATE tbcrd_fatura
               SET tbcrd_fatura.insituacao = 4
             WHERE tbcrd_fatura.idfatura   = rw_tbcrd_fatura.idfatura;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tbcrd_fatura: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;        
        
        IF vr_vlpagmto > 0 THEN
          
          -- cria registro na tabela de lançamentos
          BEGIN
            INSERT INTO craplcm
                (cdcooper,
                 dtmvtolt,
                 cdagenci,
                 cdbccxlt,
                 nrdolote,
                 nrdctabb,
                 nrdocmto,
                 vllanmto,
                 nrdconta,
                 cdhistor,
                 nrseqdig,
                 cdpesqbb,
                 dtrefere,
                 hrtransa)
            VALUES
                (pr_cdcooper,
                 pr_dtmvtolt,
                 rw_crapass.cdagenci,
                 100,
                 0, -- Lote nao sera usado
                 rw_crapass.nrdconta, -- nrdctabb
                 rw_tbcrd_fatura.dsdocumento || TO_CHAR(SYSDATE, 'hh24mmss'),
                 vr_vlpagmto, -- Valor Total ou definido pelo logica de repique
                 rw_tbcrd_fatura.nrdconta,
                 ct_hispgfat, -- Historico
                 vr_idpagamento_fatura, -- Alterado por Renato devido a erro no processo noturno 
                 rw_crawcrd.nrcrcard, -- Num cartao
                 trunc(SYSDATE), -- Data referencia
                 gene0002.fn_busca_time); -- Hora transacao 
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir craplcm: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          --
          vr_notif_origem   := 10;
          vr_notif_motivo   := 1;
          vr_variaveis_notif('#valordebito') := TRIM(TO_CHAR(vr_vlpagmto,'fm999G999G999G990D00'));
          vr_variaveis_notif('#datadebito')  := TO_CHAR(pr_dtmvtolt,'dd/mm/yyyy');
          vr_variaveis_notif('#tipodebito')  := vr_dstransa;
          -- Cria uma notificação
          noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                      ,pr_cdmotivo_mensagem => vr_notif_motivo
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_tbcrd_fatura.nrdconta
                                      ,pr_variaveis => vr_variaveis_notif);
            
          --Pega os valores para atualizar no sld do dia das faturas
          vr_vlsomsld := vr_vlpagmto;
          vr_dtultsld := pr_dtmvtolt;
          vr_flmuddia := 0;
          
          IF nvl(TRUNC(rw_tbcrd_fatura.dtref_pagodia),TO_DATE('01/01/0001','DD/MM/RRRR')) <>
             TRUNC(pr_dtmvtolt) THEN
             vr_flmuddia := 1;
          END IF;             
          
          -- Fatura totalmente paga   
          IF (vr_vlpagmto - rw_tbcrd_fatura.vlpendente) = 0 THEN
            -- Encerra fatura mudando situacao e atualizando valor pendente para 0
            BEGIN              
              UPDATE tbcrd_fatura
                 SET tbcrd_fatura.vlpendente = 0,
                     tbcrd_fatura.dtpagamento = pr_dtmvtolt,
                     tbcrd_fatura.insituacao = 2,
                     tbcrd_fatura.dtref_pagodia = decode(vr_flmuddia,1,vr_dtultsld,tbcrd_fatura.dtref_pagodia),
                     tbcrd_fatura.vlpagodia = decode(vr_flmuddia,1,vr_vlsomsld,tbcrd_fatura.vlpagodia + vr_vlsomsld)
               WHERE tbcrd_fatura.idfatura   = rw_tbcrd_fatura.idfatura;              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar craplau: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
              
          ELSE   
            -- Atualiza apenas o valor pendente
            BEGIN            
              UPDATE tbcrd_fatura
                 SET tbcrd_fatura.vlpendente  = rw_tbcrd_fatura.vlpendente - vr_vlpagmto,
                     tbcrd_fatura.dtpagamento = pr_dtmvtolt,                      
                     tbcrd_fatura.dtref_pagodia = decode(vr_flmuddia,1,vr_dtultsld,tbcrd_fatura.dtref_pagodia),
                     tbcrd_fatura.vlpagodia = decode(vr_flmuddia,1,vr_vlsomsld,tbcrd_fatura.vlpagodia + vr_vlsomsld)
               WHERE tbcrd_fatura.idfatura    = rw_tbcrd_fatura.idfatura;
               
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar tbcrd_fatura: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
               
          END IF;         
          
        END IF;
      END LOOP;
      
      IF NOT fn_encerra_exec(pr_prmrowid => vr_prmrowid) THEN
         vr_dscritic := 'Problemas no final da execucao do debito de faturas, tabela de parametros nao atualizada.';
         RAISE vr_exc_saida;
      END IF;   
      
    EXCEPTION
      WHEN vr_exc_saida THEN

        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 2, --> erro tratado 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - ' || pr_cdprogra ||
                                                      ' --> ' || pr_dscritic, 
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));

        -- Efetuar rollback
        ROLLBACK;
              
      WHEN OTHERS THEN
        -- Monta mensagem de erro
        pr_cdcritic := NULL;
        pr_dscritic := 'Erro na CCRD0003.pc_debita_fatura --> '|| SQLERRM;
       
        -- Efetuar rollback
        ROLLBACK;               
    END;
                                                                 
  END pc_debita_fatura;    

  /*
    Alterações: 29/06/2017 - Incluido GENE0001.pc_informa_acesso pois ocasionava
                             problemas de conversao de numericos (Tiago/Fabricio);
  */
  PROCEDURE pc_debita_fatura_job IS  
  BEGIN

    DECLARE 
      CURSOR cr_crapcop IS
        SELECT crapcop.cdcooper
          FROM crapcop
         WHERE crapcop.cdcooper <> 3
           AND crapcop.flgativo = 1;
           
      -- Registro sobre as cooperativas      
      type typ_tab_crapcop IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
      vr_crapcop  typ_tab_crapcop;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      
         
      vr_cdcritic NUMBER;
      vr_dscritic VARCHAR(4000);
       
      vr_cdprogra    VARCHAR2(40) := 'PC_DEBITA_FATURA_JOB';
      vr_nomdojob    VARCHAR2(40) := 'JBCRD_DEBITA_FATURA';
      vr_flgerlog    BOOLEAN := FALSE;
      vr_contador    pls_integer := 0;
      vr_exc_saida   EXCEPTION;
      vr_dsdiautil   VARCHAR2(45) := 'Processo deve rodar apenas em dia util';

      --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        --> Controlar geração de log de execução dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
      END pc_controla_log_batch;

    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra
                                ,pr_action => NULL);      
      
      -- Log de inicio de execucao
      pc_controla_log_batch(pr_dstiplog => 'I');
      
      FOR rw_crapcop IN cr_crapcop LOOP
         vr_contador := vr_contador + 1;
         vr_crapcop(vr_contador) := rw_crapcop.cdcooper;
      END LOOP;

      FOR i IN 1..vr_contador LOOP

        -- Leitura do calendario da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_crapcop(i));
        FETCH btch0001.cr_crapdat INTO rw_crapdat;

        -- Se nao encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          CONTINUE;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF; 
        
        -- Call the procedure
        ccrd0003.pc_debita_fatura(pr_cdcooper => vr_crapcop(i),
                                         pr_cdprogra => 'REPIQUE',
                                         pr_cdoperad => 1,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_fatrowid => NULL,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);
                                         
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN

           IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
              -- Buscar a descrição
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           
           -- SD 579741
           IF vr_dscritic <> vr_dsdiautil THEN        
           -- Envio centralizado de log de erro
           pc_controla_log_batch(pr_dstiplog => 'E',
                                pr_dscritic => 'Coop: ' || vr_crapcop(i) || 
                                                ' - ' || vr_dscritic);
           END IF;                                                  

          CONTINUE; -- vai para a próxima cooperativa
        END IF;   
      
        COMMIT;
        
      END LOOP;   
      
      -- Log de fim de execucao
      pc_controla_log_batch(pr_dstiplog => 'F');
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        
        -- Efetuar rollback        
        ROLLBACK;
        
      WHEN OTHERS THEN
        btch0001.pc_log_internal_exception(3);
      
        ROLLBACK;
    END;                                                                 
  END pc_debita_fatura_job;    

  PROCEDURE pc_debita_fatura_web(pr_dtmvtolt IN VARCHAR2
                                ,pr_fatrowid IN ROWID DEFAULT NULL                                
                                ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    -- ........................................................................
    --
    --  Programa : pc_debita_fatura_web
    --  Sistema  : Cred
    --  Sigla    : CCRD0003
    --  Autor    : Tiago Machado Flor
    --  Data     : 27/07/2015.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Consulta por:                                       
    --                 Busca faturas pendentes de acordo com os parametros passados
    --
    --.............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);      

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);    

      vr_dtmvtolt DATE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;
      vr_vltottar NUMBER(25,2):= 0;
      
  BEGIN 

      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro 
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;      
      
      vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
      
      pc_debita_fatura(pr_cdcooper  => vr_cdcooper
                      ,pr_cdprogra  => vr_nmdatela
                      ,pr_cdoperad  => vr_cdoperad
                      ,pr_dtmvtolt  => vr_dtmvtolt
                      ,pr_fatrowid  => pr_fatrowid
                      ,pr_cdcritic  => vr_cdcritic
                      ,pr_dscritic  => vr_dscritic);       

      -- Verifica se houve erro 
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;      

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CCRD0003.pc_debita_fatura_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_debita_fatura_web;

  /*.......................................................................................

   Programa: CCDR0003
   Sigla   : APLI
   Autor   : Tiago
   Data    : Junho/2015                          Ultima atualizacao: 10/06/2015

   Dados referentes ao programa:

   Objetivo  : Procedure para geracao do relatorio 693(nao efetuados) - logica extraida
               do programa PC_CRPS674.

   Alteracoes:  
                  
  .......................................................................................*/
  PROCEDURE pc_rel_nao_efetuados(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_cdprogra  IN crapprg.cdprogra%TYPE
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                ,pr_cdcritic  OUT crapcri.cdcritic%TYPE
                                ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
        
      CURSOR cr_tbcrd_fatura(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN DATE) IS
        SELECT *
          FROM (SELECT decode(fat.vlfatura,fat.vlpendente,'DÉBITOS NÃO EFETIVADOS','DÉBITOS EFETIVADOS PARCIALMENTE') quebra,
                       FAT.ROWID,
                       FAT.CDCOOPER,
                       FAT.NRDCONTA,
                       FAT.IDFATURA,
                       FAT.NRCONTA_CARTAO,
                       FAT.NRCONTRATO,
                       FAT.VLFATURA,
                       FAT.VLMINIMO_PAGAMENTO,
                       FAT.VLPENDENTE,
                       PAG.VLSALDO_CONTA,
                       PAG.VLPAGAMENTO,
                       PAG.DTREFERENCIA,
                       ASS.VLLIMCRE,
                       ASS.NMPRIMTL,
                       ASS.INPESSOA,
                       ASS.CDAGENCI,
                       ROW_NUMBER() OVER(PARTITION BY FAT.IDFATURA ORDER BY FAT.IDFATURA, PAG.DTREFERENCIA DESC) SEQ
                  FROM TBCRD_PAGAMENTO_FATURA PAG, TBCRD_FATURA FAT, CRAPASS ASS
                 WHERE PAG.IDFATURA = FAT.IDFATURA
                   AND FAT.VLPENDENTE > 0
                   AND PAG.DTPAGAMENTO = pr_dtmvtolt
                   AND FAT.CDCOOPER = nvl(NULLIF(pr_cdcooper,3),FAT.CDCOOPER)
                   AND ASS.CDCOOPER = FAT.CDCOOPER
                   AND ASS.NRDCONTA = FAT.NRDCONTA) T
          WHERE T.SEQ = 1
          ORDER BY quebra DESC, cdagenci ASC, nrdconta ASC;               
      rw_tbcrd_fatura cr_tbcrd_fatura%ROWTYPE;
      
      CURSOR cr_crawcrd(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE,
                        pr_inpessoa IN crapass.inpessoa%TYPE) IS
        SELECT crd.cdcooper,
               crd.nrdconta,
               crd.cdadmcrd,
               adc.nmresadm AS nmadmcrd,
               crd.tpdpagto,
               CASE crd.tpdpagto
                 WHEN 1 THEN 'Deb CC Total'
                 WHEN 2 THEN 'Deb CC Minimo'
                 WHEN 3 THEN 'Boleto'
               END AS dsformpg,
               '(' || lpad(tfc.nrdddtfc,2,0) || ')' || TO_CHAR(tfc.nrtelefo) AS nrtelefo      
              FROM crawcrd crd, 
                   craptfc tfc,
                   crapadc adc
              WHERE crd.cdcooper = tfc.cdcooper
                AND crd.nrdconta = tfc.nrdconta
                AND crd.cdcooper = adc.cdcooper
                AND crd.cdadmcrd = adc.cdadmcrd
                AND crd.cdcooper = pr_cdcooper 
                AND crd.nrdconta = pr_nrdconta
                AND crd.nrctrcrd = pr_nrctrcrd
               ORDER BY  CASE pr_inpessoa
                 WHEN 1 THEN  Row_Number() over(order by tfc.tptelefo ASC)
                 WHEN 2 THEN  Row_Number() over(order by tfc.tptelefo DESC)
                 ELSE Row_Number() over(order by tfc.tptelefo ASC)
               END;    
      rw_crawcrd cr_crawcrd%ROWTYPE;           
      
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdcooper, ass.nrdconta,
               ass.vllimcre, ass.nmprimtl,
               ass.inpessoa, ass.cdagenci
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      --Variáveis locais
      vr_dstransa   VARCHAR2(100);
      
      -- Variáveis locais do bloco
      vr_xml_clobxml       CLOB;
      vr_xml_des_erro      VARCHAR2(4000);

      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdirarq   VARCHAR2(200);                                     --> Caminho e nome do arquivo      
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_exc_erro   EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);  
	    vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro; 
      
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
        dbms_lob.writeappend(vr_xml_clobxml, length(pr_des_dados), pr_des_dados);
      END;      
      
    BEGIN
      
      --Buscar Transacao
      vr_dstransa:= 'relatorio fatura nao efetuados';

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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

      dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||chr(10)||'<crrl674>'||chr(10));

      FOR rw_tbcrd_fatura IN cr_tbcrd_fatura(pr_cdcooper => pr_cdcooper
                                            ,pr_dtmvtolt => pr_dtmvtolt) LOOP
            /*
          OPEN cr_crapass(pr_cdcooper => rw_tbcrd_fatura.cdcooper
                         ,pr_nrdconta => rw_tbcrd_fatura.nrdconta);                         
          FETCH cr_crapass INTO rw_crapass;               
          
          IF cr_crapass%NOTFOUND THEN
             CLOSE cr_crapass;
             continue;
          ELSE
             CLOSE cr_crapass;
          END IF;  */

          -- Adiciona a linha ao XML
          pc_escreve_xml ('<rejeitados>'
                 ||chr(10)||'<quebra>'||rw_tbcrd_fatura.quebra||'</quebra>'
                 ||chr(10)||'<cdcooper>'||rw_tbcrd_fatura.cdcooper||'</cdcooper>'
                 ||chr(10)||'<cdagenci>'||TRIM(rw_tbcrd_fatura.cdagenci)||'</cdagenci>'
                 ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(rw_tbcrd_fatura.nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
                 ||chr(10)||'<nrdctabb>'||TRIM(rw_tbcrd_fatura.nrconta_cartao)||'</nrdctabb>'
                 ||chr(10)||'<nrdocmto>'||TRIM(gene0002.fn_mask(rw_tbcrd_fatura.nrcontrato,'zz.zzz.zzz'))||'</nrdocmto>'
                 ||chr(10)||'<nmprimtl>'||TRIM(rw_tbcrd_fatura.nmprimtl)||'</nmprimtl>'
                 ||chr(10)||'<vlfatura>R$ '||TRIM(TO_CHAR(rw_tbcrd_fatura.vlfatura,'99g999g990d00'))||'</vlfatura>'
                 ||chr(10)||'<vllanaut>R$ '||TRIM(TO_CHAR((rw_tbcrd_fatura.vlfatura - rw_tbcrd_fatura.vlpendente),'99g999g990d00'))||'</vllanaut>'
                 ||chr(10)||'<vlsddisp>R$ '||TRIM(TO_CHAR(rw_tbcrd_fatura.vlsaldo_conta,'99g999g990d00'))||'</vlsddisp>'
                 ||chr(10)||'<vllimcre>R$ '||TRIM(TO_CHAR(rw_tbcrd_fatura.vllimcre,'99g999g990d00'))||'</vllimcre>');
                 
          OPEN cr_crawcrd(pr_cdcooper => rw_tbcrd_fatura.cdcooper
                         ,pr_nrdconta => rw_tbcrd_fatura.nrdconta
                         ,pr_nrctrcrd => rw_tbcrd_fatura.nrcontrato
                         ,pr_inpessoa => rw_tbcrd_fatura.inpessoa);
          FETCH cr_crawcrd INTO rw_crawcrd;
          
          IF cr_crawcrd%NOTFOUND THEN	                
             pc_escreve_xml(chr(10)||'<nrtelefo>NAO CADASTRADO</nrtelefo>'
                           ||chr(10)||'<cdadmcrd>0</cdadmcrd>'
                           ||chr(10)||'<nmadmcrd>NAO CADASTRADO</nmadmcrd>'
                           ||chr(10)||'<dsformpg>NAO CADASTRADO</dsformpg>');
          ELSE                    
             pc_escreve_xml(chr(10)||'<nrtelefo>'||TRIM(rw_crawcrd.nrtelefo)||'</nrtelefo>'
                           ||chr(10)||'<cdadmcrd>'||TRIM(rw_crawcrd.cdadmcrd)||'</cdadmcrd>'
                           ||chr(10)||'<nmadmcrd>'||TRIM(rw_crawcrd.nmadmcrd)||'</nmadmcrd>'
                           ||chr(10)||'<dsformpg>'||TRIM(rw_crawcrd.dsformpg)||'</dsformpg>');
          END IF;
          
          CLOSE cr_crawcrd;      
                 
          pc_escreve_xml(chr(10)||'</rejeitados>');
          
      END LOOP;
        
      -- Adiciona a linha ao XML
      pc_escreve_xml('</crrl674>');

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null); 
                                            
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
            
      vr_dsdirarq := vr_dsdireto||'/rl/crrl693_'|| to_char( gene0002.fn_busca_time )||'.lst';
            
      -- Submeter o relatório 693
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                                    --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl674/rejeitados'                --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl693.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '693'                               --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_clobxml);
      dbms_lob.freetemporary(vr_xml_clobxml);

    EXCEPTION
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
                  
        -- Monta mensagem de erro
        pr_cdcritic := NULL;
        pr_dscritic := 'Erro na CCRD0003.pc_rel_nao_efetuados --> '|| SQLERRM;
        
        -- Efetuar rollback
        ROLLBACK;               
    END;
                                                                 
  END pc_rel_nao_efetuados;    

  PROCEDURE pc_busca_fatura_pend(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                ,pr_dscritic OUT VARCHAR2
                                ,pr_tab_fat_pend OUT typ_tab_fatura_pend) IS
  BEGIN
    DECLARE
    
      
      CURSOR cr_tbcrd_fatura(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT fat.dtvencimento
              ,fat.dsdocumento
              ,fat.nrconta_cartao
              ,fat.vlpendente               
              ,fat.rowid
          FROM tbcrd_fatura fat
         WHERE fat.cdcooper = pr_cdcooper
           AND fat.nrdconta = pr_nrdconta
           AND fat.vlpendente > 0
           AND fat.insituacao <> 4 --Cancelada
           AND fat.dtvencimento >= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => (pr_dtmvtolt - 31), pr_tipo => 'A');
       
      vr_contador INTEGER;
      vr_exc_saida EXCEPTION;
      
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
                           
    BEGIN


      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
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

      pr_tab_fat_pend.delete;
      vr_contador := 0;
      
      FOR rw_tbcrd_fatura IN cr_tbcrd_fatura(pr_cdcooper => pr_cdcooper 
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
                                            
        vr_contador := vr_contador + 1;                                    
                                            
        pr_tab_fat_pend(vr_contador).dtvencimento   := rw_tbcrd_fatura.dtvencimento;
        pr_tab_fat_pend(vr_contador).dsdocumento    := rw_tbcrd_fatura.dsdocumento;
        pr_tab_fat_pend(vr_contador).nrconta_cartao := rw_tbcrd_fatura.nrconta_cartao;
        pr_tab_fat_pend(vr_contador).vlpendente     := rw_tbcrd_fatura.vlpendente;
        pr_tab_fat_pend(vr_contador).fatrowid       := rw_tbcrd_fatura.rowid;
        
      END LOOP;
      
      IF pr_tab_fat_pend.count() = 0 THEN
         vr_dscritic := 'Nao foram encontradas faturas pendentes possiveis de debito.';
         RAISE vr_exc_saida;           
      END IF;  
      
      pr_dscritic := '';
    EXCEPTION
      WHEN vr_exc_saida THEN
        
        IF vr_cdcritic > 0 THEN           
           pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE 
           pr_dscritic := vr_dscritic;
        END IF;   
        
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CCRD0003.pc_busca_fatura_pend: ' || SQLERRM;
        
    END;
  END pc_busca_fatura_pend;                                

  PROCEDURE pc_busca_fatura_pend_web(pr_cdcopatu IN  crapcop.cdcooper%TYPE                                    
                                    ,pr_nrdconta IN  crapass.nrdconta%TYPE
                                    ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    -- ........................................................................
    --
    --  Programa : pc_busca_fatura_pend_web
    --  Sistema  : Cred
    --  Sigla    : CCRD0003
    --  Autor    : Tiago Machado Flor
    --  Data     : 24/07/2015.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Consulta por:                                       
    --                 Busca faturas pendentes de acordo com os parametros passados
    --
    --.............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);    


      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;
      vr_vltottar NUMBER(25,2):= 0;

      -- Temp Table
      vr_tab_fat_pend typ_tab_fatura_pend;
      
  BEGIN 

      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;      

      -- Leitura 
      pc_busca_fatura_pend(pr_cdcooper      =>  pr_cdcopatu, 
                           pr_nrdconta      =>  pr_nrdconta,
                           pr_dscritic      =>  vr_dscritic,
                           pr_tab_fat_pend  =>  vr_tab_fat_pend);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_fat_pend.count() > 0 THEN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Leitura da tabela temporaria para retornar XML para a WEB
        FOR vr_contador IN vr_tab_fat_pend.FIRST..vr_tab_fat_pend.LAST LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtvencimento', pr_tag_cont => TO_CHAR(vr_tab_fat_pend(vr_contador).dtvencimento,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdocumento', pr_tag_cont => TO_CHAR(vr_tab_fat_pend(vr_contador).dsdocumento ), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrconta_cartao', pr_tag_cont => TO_CHAR(vr_tab_fat_pend(vr_contador).nrconta_cartao) , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlpendente', pr_tag_cont => TO_CHAR(vr_tab_fat_pend(vr_contador).vlpendente ), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'rowid', pr_tag_cont => TO_CHAR(vr_tab_fat_pend(vr_contador).fatrowid ), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
          --vr_vltottar := vr_vltottar + vr_tab_fat_pend(vr_contador).vltarifa;
        END LOOP;

      ELSE
        vr_dscritic := 'Nao foram encontradas faturas pendentes possiveis de debito.';
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CCRD0003.pc_busca_fatura_pend_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_fatura_pend_web;

  PROCEDURE pc_insere_conta_cartao(pr_cdcooper       IN  crapcop.cdcooper%TYPE                 --> Cooperativa                                    
                                  ,pr_nrdconta       IN  crapass.nrdconta%TYPE                 --> Numero da conta
                                  ,pr_nrconta_cartao IN tbcrd_conta_cartao.nrconta_cartao%TYPE --> Conta cartao
                                  ,pr_cdcritic OUT PLS_INTEGER                                 --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2) IS                                --> Erros do processo
  BEGIN

    -- ........................................................................
    --
    --  Programa : pc_insere_conta_cartao
    --  Sistema  : Cred
    --  Sigla    : CCRD0003
    --  Autor    : Anderson Fossa
    --  Data     : 31/05/2017.                      Ultima atualizacao: -
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Insere o registro da conta cartao, na tabela de relacionamento
    --               de conta x conta cartao (tbcrd_conta_cartao).                 
    --
    --.............................................................................*/
    DECLARE
      -- Variável de críticas
      vr_cdcritic  crapcri.cdcritic%TYPE := 0;
      vr_dscritic  VARCHAR2(10000)       := '';
      vr_exc_saida EXCEPTION;
    BEGIN
      
      BEGIN  
        INSERT INTO tbcrd_conta_cartao
                    (cdcooper, 
                     nrdconta, 
                     nrconta_cartao)
             VALUES (pr_cdcooper,        --> cdcooper
                     pr_nrdconta,        --> nrdconta
                     pr_nrconta_cartao); --> nrconta_cartao
      EXCEPTION
        WHEN dup_val_on_index THEN
          NULL; --> Caso ja exista nao deve apresentar critica
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir tbcrd_conta_cartao em CCRD0003.pc_insere_conta_cartao: '||SQLERRM;
          RAISE vr_exc_saida;
       END;
       
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CCRD0003.pc_insere_conta_cartao: ' || SQLERRM;
    END;
  END pc_insere_conta_cartao;

END CCRD0003;
/
