CREATE OR REPLACE PACKAGE CECRED.ddda0001 AS

  /*..............................................................................
  
     Programa: ddda0001                        Antigo: sistema/generico/procedures/b1wgen0079.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
      Autor     : David
      Data      : Dezembro/2010                Ultima Atualizacao: 02/05/2013
  
      Dados referentes ao programa:
  
      Objetivo  : BO para comunicacao com o aplicativo JDDDA.
                  Regras para o servico DDA (Debito Direto Autorizado).
  
      Alteracoes:
  
      26/11/2011 - Adicionado campo em tt-titulos-sacado-dda.vlliquid para
                   valor do titulo - abatimento e desconto.(Jorge)
  
      03/02/2012 - Adicionado campos em tt-titulos-sacado-dda: vldsccal,
                   vljurcal, vlmulcal e vltotcob (Jorge).
                 - Criado procedure baixa-operacional. (Jorge)
  
      27/02/2012 - Setar flag de titulo vencido pela data limite
                   de pagamento. (Rafael)
  
      06/03/2012 - Incluido rotina para desconsiderar juros/multa quando vencto
                   na praca do sacado for feriado. (Rafael)
  
      12/03/2012 - Repassado parametro de data limite de pagamento para a
                   tt-titulos-sacado-dda. (Jorge)
  
      20/03/2012 - Ajustes na rotina de baixa-operacional. (Rafael)
  
      13/04/2012 - Ajustes na procedure atualizar-situacao-titulo-sacado.
                   Estava provocando erro ao agendar titulos DDA. (Rafael)
  
      19/04/2012 - Verificar se data limite de pagto nao eh feriado. (Rafael)
  
      03/08/2012 - Ajuste na informa��o de baixa operacional devido a aplicacao
                   do catalogo Bacen 3.06. (Rafael)
  
      12/11/2012 - Ajuste em proc. carrega-dados-titulo quando campo for
                   RepetDesctTit, adicionado condicional "or". (Jorge)
  
      03/01/2013 - Ajustes em campo "RepetDesctTit" da procedure
                   carrega-dados-titulo (Jorge)
  
      02/05/2013 - Ajuste em proc. carrega-dados-titulo, adicionado replace de
                   campos com nomes, retirando "," ";" e "#". (Jorge)
  
      09/07/2013 - Convers�o Progress para Oracle (Alisson - AMcom)
  
      25/02/2014 - Ajuste na rotina que busca a confirmacao do registro do
                   titulo naJD (MS-SQL/Server) (Rafael).
                   
      29/10/2015 - Alterado tamanho do campo typ_reg_remessa_dda.dsinstru 
                   SD352398(Odirlei-Amcom)            
  
  ..............................................................................*/

  /* Tipo de registro de Remessa DDA
     Origem: sistema/generico/includes/b1wgen0087tt.i >> tt-remessa-dda
     Observa��o: Toda altera��o nesta pltable deve ser replicada
                 na temp-table acima declara e tamb�m na tabela
                 wt_remessa_dda.
  */
  TYPE typ_reg_remessa_dda IS RECORD(
     nrispbif INTEGER
    ,cdlegado VARCHAR2(100)
    ,idopeleg INTEGER
    ,idtitleg VARCHAR2(100)
    ,tpoperad VARCHAR2(100)
    ,dtoperac INTEGER
    ,hroperac INTEGER
    ,cdifdced INTEGER
    ,tppesced VARCHAR2(100)
    ,nrdocced INTEGER
    ,nmdocede VARCHAR2(100)
    ,cdageced INTEGER
    ,nrctaced INTEGER
    ,tppesori VARCHAR2(100)
    ,nrdocori INTEGER
    ,nmdoorig VARCHAR2(100)
    ,tppessac VARCHAR2(100)
    ,nrdocsac INTEGER
    ,nmdosaca VARCHAR2(100)
    ,dsendsac VARCHAR2(100)
    ,dscidsac VARCHAR2(100)
    ,dsufsaca VARCHAR2(100)
    ,Nrcepsac INTEGER
    ,tpdocava INTEGER
    ,nrdocava INTEGER
    ,nmdoaval VARCHAR2(100)
    ,cdcartei VARCHAR2(100)
    ,cddmoeda VARCHAR2(100)
    ,dsnosnum VARCHAR2(100)
    ,dscodbar VARCHAR2(100)
    ,dslindig VARCHAR2(100)
    ,dtvencto INTEGER
    ,vlrtitul NUMBER
    ,nrddocto VARCHAR2(100)
    ,cdespeci VARCHAR2(100)
    ,dtemissa INTEGER
    ,nrdiapro INTEGER
    ,tpdepgto INTEGER
    ,indnegoc VARCHAR2(100)
    ,vlrabati NUMBER
    ,dtdjuros INTEGER
    ,dsdjuros VARCHAR2(100)
    ,vlrjuros NUMBER
    ,dtdmulta INTEGER
    ,cddmulta VARCHAR2(100)
    ,vlrmulta NUMBER
    ,flgaceit VARCHAR2(100)
    ,dtddesct INTEGER
    ,cdddesct VARCHAR2(100)
    ,vlrdesct NUMBER
    ,dsinstru VARCHAR2(255)
    ,dtlipgto INTEGER
    ,tpdBaixa VARCHAR2(100)
    ,dssituac VARCHAR2(100)
    ,insitpro INTEGER
    ,tpmodcal VARCHAR2(100)
    ,dtvalcal INTEGER
    ,flavvenc VARCHAR2(100)
    ,vldsccal NUMBER
    ,vljurcal NUMBER
    ,vlmulcal NUMBER
    ,vltotcob NUMBER
    ,inpagdiv crapcob.inpagdiv%TYPE
    ,tpvlmini VARCHAR2(1) 
    ,vlminimo crapcob.vlminimo%TYPE
    ,dtbloque crapcob.dtbloque%TYPE   
    ,idbloque VARCHAR2(1) 
    ,flonline VARCHAR2(1)
    ,rowidcob ROWID
    ,cdcritic INTEGER
    ,dscritic VARCHAR2(4000)
    ,nrdident crapcob.nrdident%TYPE
    ,nratutit crapcob.nratutit%TYPE
    ,nrispbrc crapcob.nrispbrc%TYPE
    ,dhdbaixa VARCHAR2(20)
    ,dtdbaixa VARCHAR2(20)
    ,cdCanPgt INTEGER
    ,cdmeiopg INTEGER    
    );

  /* Tipo de tabela de Remessa DDA */
  TYPE typ_tab_remessa_dda IS TABLE OF typ_reg_remessa_dda INDEX BY PLS_INTEGER;

  /* Tipo de Registro de retorno DDA */
  /* Origem: sistema/generico/includes/b1wgen0087tt.i >> tt-retorno-dda
     Observa��o: Toda altera��o nesta pltable deve ser replicada
                 na temp-table acima declara e tamb�m na tabela
                 wt_retorno_dda.
  */

  TYPE typ_reg_retorno_dda IS RECORD(
     idtitleg VARCHAR2(100)
    ,idopeleg INTEGER
    ,insitpro INTEGER);
  /* Tipo de Tabela de retorno DDA */
  TYPE typ_tab_retorno_dda IS TABLE OF typ_reg_retorno_dda INDEX BY PLS_INTEGER;

  /* Tipo de Registro de verificacao de saque */
  TYPE typ_reg_verifica_sacado IS RECORD(
     tppessoa VARCHAR2(01)
    ,nrcpfcgc NUMBER
    ,flgsacad INTEGER);

  /* Tipo de Tabela de verificacao de saque */
  TYPE typ_tab_verifica_sacado IS TABLE OF typ_reg_verifica_sacado INDEX BY PLS_INTEGER;

  /* Tipo de Registro de titulos a pagar */
  TYPE typ_reg_tt_pagar IS RECORD(
     nmrescop crapcop.nmrescop%TYPE
    ,cdagenci crapass.cdagenci%TYPE
    ,nrdconta crapcob.nrdconta%TYPE
    ,cdbarras VARCHAR2(100)
    ,dtvencto crapcob.dtvencto%TYPE
    ,vltitulo crapcob.vltitulo%TYPE);
  /* Tipo de Tabela de titulos a pagar */
  TYPE typ_tab_tt_pagar IS TABLE OF typ_reg_tt_pagar INDEX BY PLS_INTEGER;

  /* Procedure para atualizar situacao do titulo do sacado eletronico */
  PROCEDURE pc_atualz_situac_titulo_sacado(pr_cdcooper IN INTEGER --Codigo da Cooperativa
                                          ,pr_cdagecxa IN INTEGER --Codigo da Agencia
                                          ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                          ,pr_cdopecxa IN VARCHAR2 --Codigo Operador Caixa
                                          ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                          ,pr_idorigem IN INTEGER --Indicador Origem
                                          ,pr_nrdconta IN INTEGER --Numero da Conta
                                          ,pr_idseqttl IN INTEGER --Sequencial do titular
                                          ,pr_idtitdda IN NUMBER --Indicador Titulo DDA
                                          ,pr_cdsittit IN INTEGER --Situacao Titulo
                                          ,pr_flgerlog IN BOOLEAN --Gerar Log
                                          ,pr_rowidtit IN ROWID DEFAULT NULL   --> Rowid da craptit para gerar a baixa operacional
                                          ,pr_des_erro OUT VARCHAR2 --Indicador erro OK/NOK
                                          ,pr_tab_erro OUT GENE0001.typ_tab_erro); --Tabela de memoria de erro

  /* Procedure para realizar a liquidacao intrabancaria do DDA */
  PROCEDURE pc_liquid_intrabancaria_dda(pr_rowid_cob IN ROWID --ROWID da Cobranca
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                       ,pr_dscritic  OUT VARCHAR2); --Descricao de Erro

  /* Procedure para buscar codigo cedente do DDA */
  PROCEDURE pc_busca_cedente_DDA(pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_idtitdda IN NUMBER --Identificador Titulo dda
                                ,pr_nrinsced OUT NUMBER --Numero inscricao cedente
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                ,pr_dscritic OUT VARCHAR2); --Descricao de Erro

  /* Procedure para verificar se foi sacado do DDA */
  PROCEDURE pc_verifica_sacado_DDA(pr_tppessoa IN VARCHAR2
                                  , -- Tipo de pessoa
                                   pr_nrcpfcgc IN NUMBER
                                  , -- Cpf ou CNPJ
                                   pr_flgsacad OUT INTEGER
                                  , -- Indicador se foi sacado
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  , -- Codigo de Erro
                                   pr_dscritic OUT VARCHAR2); -- Descricao de Erro

  /* Envio de mensagens atraves do site de chegada de novos titulos DDA */
  PROCEDURE pc_chegada_titulos_DDA(pr_cdcooper IN INTEGER -- Codigo cooperativa
                                  ,pr_cdprogra IN VARCHAR2 -- Codigo do programa
                                  ,pr_dtemiini IN DATE -- Data inicial de emissao
                                  ,pr_dtemifim IN DATE -- Data final de emissao
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Codigo de Erro
                                  ,pr_dscritic OUT VARCHAR2); -- Descricao de Erro

  /**
    Popula tt-pagar com os titulos a pagar a partir de R$ 250.000 de todas as
    cooperativas nos proximos 7 dias.
  */
  PROCEDURE pc_titulos_a_pagar(pr_dtvcnini IN DATE
                              ,pr_tt_pagar OUT typ_tab_tt_pagar);

  /* Procedure para executar os procedimentos DDA JD */
  PROCEDURE pc_procedimentos_dda_jd(pr_rowid_cob       IN ROWID --ROWID da Cobranca
                                   ,pr_tpoperad        IN VARCHAR2 --Tipo Operacao
                                   ,pr_tpdbaixa        IN VARCHAR2 --Tipo de Baixa
                                   ,pr_dtvencto        IN DATE --Data Vencimento
                                   ,pr_vldescto        IN NUMBER --Valor Desconto
                                   ,pr_vlabatim        IN NUMBER --Valor Abatimento
                                   ,pr_flgdprot        IN INTEGER --Flag Protesto
                                   ,pr_tab_remessa_dda OUT DDDA0001.typ_tab_remessa_dda --Tabela memoria Remessa DDA
                                   ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda --Tabela memoria retorno DDA
                                   ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --Codigo Critica
                                   ,pr_dscritic        OUT VARCHAR2); --Descricao Critica

  /* Procedure para gravar informacoes do DDA na crapgpr */
  PROCEDURE pc_grava_congpr_dda(pr_cdcooper IN INTEGER -- Codigo Cooperativa
                               ,pr_dataini  IN DATE -- Data inicial
                               ,pr_datafim  IN DATE -- Data final
                               ,pr_dtmvtolt IN DATE -- Data de movimentos
                               ,pr_dscritic OUT VARCHAR2); -- Descricao da critica

  /* Procedure para chamar a rotina pc_retorno_operacao_tit_dda
  em PLSQL atrav�s da rotina Progress via DataServer */
  PROCEDURE pc_retorno_operacao_tit_DDA(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2);

  /* Procedure para chamar a rotina pc_remessa_titulos_dda
  em PLSQL atrav�s da rotina Progress via DataServer */
  PROCEDURE pc_remessa_titulos_dda(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT VARCHAR2);

  /* Procedure para Executar retorno operacao Titulos DDA diretamente do ORACLE
  --> Foi criado uma rotina para fazer o meio de campo pois n�o � permitido ter 
      sobrecarga de m�todo, pois estraga o schema holder                     */
  PROCEDURE pc_retorno_tit_tab_DDA(pr_tab_remessa_dda  IN DDDA0001.typ_tab_remessa_dda  -- Remessa dda
                                  ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda  -- Retorno dda
                                  ,pr_cdcritic        OUT crapcri.cdcritic%type         -- Codigo de Erro
                                  ,pr_dscritic        OUT VARCHAR2);                    -- Descricao de Erro
 
  /* Procedure para Executar retorno da remessa da t�tulos da DDA diretamente do ORACLE
  --> Foi criado uma rotina para fazer o meio de campo pois n�o � permitido ter 
      sobrecarga de m�todo, pois estraga o schema holder    */
  PROCEDURE pc_remessa_tit_tab_dda(pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda -- Remessa dda
                                  ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda    -- Retorno dda
                                  ,pr_cdcritic        OUT crapcri.cdcritic%type           -- Codigo de Erro
                                  ,pr_dscritic        OUT VARCHAR2);                      -- Descricao de Erro

  --> Rotina para enviar email de alertas sobre beneficiarios/convenios
  PROCEDURE pc_email_alert_JDBNF( pr_cdcooper  IN crapceb.cdcooper%TYPE, --> Codigo da cooperativa
                                  pr_nrdconta  IN crapceb.nrdconta%TYPE, --> Numero da conta do cooperado
                                  pr_nrconven  IN crapceb.nrconven%TYPE, --> Numero do convenio
                                  pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE, --> numero CEB
                                  pr_tpalerta  IN INTEGER,               --> Tipo de alerta(1-convenio pendente, 2-Novo cooperado) 
                                  pr_cdcritic OUT NUMBER,
                                  pr_dscritic OUT VARCHAR2);

  --> Rotina para verificar situa��o do cooperado na cabine e enviar email
  PROCEDURE pc_verifica_sit_JDBNF (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa
                                   pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                   pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                   pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                   pr_insitif  OUT VARCHAR2,               --> Retornar situa��o IF
                                   pr_insitcip OUT VARCHAR2,               --> Retorna situa��o na CIP
                                   pr_dscritic OUT VARCHAR2);              --> Retorna criticaIS                              
  
  --> Procedimento para retornar situa��o do bebeficioando na cabine JD
  PROCEDURE pc_ret_sit_beneficiario(pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                    pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                    pr_insitif  OUT VARCHAR2,               --> Retornar situa��o IF
                                    pr_insitcip OUT VARCHAR2,               --> Retorna situa��o na CIP
                                    pr_dscritic OUT VARCHAR2);              --> Retorna critica                                                                     

  --> Rotina para atualizar situa��o do cooperado na cabine JDBNF  
  PROCEDURE pc_atualiza_sit_JDBNF (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa
                                   pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                   pr_nrconven  IN crapceb.nrconven%TYPE,  --> Numero do convenio de cobranca
                                   pr_insitceb  IN crapceb.insitceb%TYPE,  --> Situacao do convenio de cobranca
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE,  --> Codigo de critica
                                   pr_dscritic OUT VARCHAR2);
                                    
  --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
  PROCEDURE pc_trata_retorno_erro ( pr_cdcooper       IN  crapcob.cdcooper%TYPE   --> Codigo da cooperativa 
                                   ,pr_tpdopera       IN  VARCHAR2                --> Tipo de operacao
                                   ,pr_idtitleg       IN  crapcob.idtitleg%TYPE   --> Identificador do titulo no legado
                                   ,pr_idopeleg       IN  crapcob.idopeleg%TYPE   --> Identificador da operadao do legado
                                   ,pr_iddopeJD       IN  VARCHAR2);              --> Identificador da operadao da JD                                   
                                  
  /* Procedure para Executar retorno operacao Titulos NPC */
  PROCEDURE pc_retorno_operacao_tit_NPC(pr_cdcritic        OUT crapcri.cdcritic%type --> Codigo de Erro
                                       ,pr_dscritic        OUT VARCHAR2);            --> Descricao de Erro
END ddda0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ddda0001 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : ddda0001
  --  Sistema  : Procedimentos e funcoes da BO b1wgen0079.p
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 22/02/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funcoes da BO b1wgen0079.p
  --
  -- Alteracoes: 07/07/2014 - Remover do log a mensagem "DDDA0001 --> Falha na execucao do metodo 
  --                          DDA SOAP-ENV:-722 - Situa��o do T�tulo n�o permite mais altera��es. 
  --                          Comunique seu PA." (Douglas - Chamado 160064)
  --
  --             22/12/2015 - Cursor cr_dadostitulo era fechado em um momento que
  --                          dependendo da situacao ocasionava erro (Tiago/Elton). 
  -- 
  --             22/02/2016 - Ajustado rotina pc_chegada_titulos_DDA pois procedimento ser� chamado via job todos os dias, 
  --                          alterando filtro de data na busca dos novos titulos, e ajustado mensagem para
  --                          exibir corretamente no Internetbank
  --                          SD388026 (Odirlei-AMcom) 
  --
  --             22/11/2016 - Alterado para torcar a chamada das procedures PC_RETORNO_OPERACAO_TIT_DDA 
  --                          (pc_remessa_tit_tab_dda) e PC_REMESSA_TITULOS_DDA (pc_remessa_tit_tab_dda) 
  --                          como p�blicas. (Renato Darosci - Supero)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
          ,crapcop.cdagebcb
          ,crapcop.dssigaut
          ,crapcop.cdagesic
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
          ,crapban.cdbccxlt
          ,crapban.nrispbif
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cdbccxlt;
  rw_crapban cr_crapban%ROWTYPE;

  /* Busca dos dados do cadastro de itens de menu utilizados na internet */
  CURSOR cr_crapmni(pr_cdcooper IN crapmni.cdcooper%TYPE
                   ,pr_dsurlace IN crapmni.dsurlace%TYPE
                   ,pr_cditemmn IN crapmni.cditemmn%TYPE) IS
    SELECT cdsubitm
          ,cditemmn
          ,nrorditm
      FROM crapmni
     WHERE crapmni.cdcooper = pr_cdcooper
           AND crapmni.dsurlace = pr_dsurlace
           AND crapmni.cditemmn = nvl(pr_cditemmn, cditemmn);
  rw_crapmni cr_crapmni%ROWTYPE;

  --Selecionar registro cobranca
  CURSOR cr_crapcob(pr_rowid IN ROWID) IS
    SELECT crapcob.cdcooper
          ,crapcob.nrdconta
          ,crapcob.cdbandoc
          ,crapcob.nrdctabb
          ,crapcob.nrcnvcob
          ,crapcob.nrdocmto
          ,crapcob.flgregis
          ,crapcob.nrnosnum
          ,crapcob.vltitulo
          ,crapcob.flgcbdda
          ,crapcob.dtvencto
          ,crapcob.vldescto
          ,crapcob.vlabatim
          ,crapcob.flgdprot
          ,crapcob.nrinssac
          ,crapcob.idseqttl
          ,crapcob.tpjurmor
          ,crapcob.cddespec
          ,crapcob.dsdinstr
          ,crapcob.idtitleg
          ,crapcob.cdtpinav
          ,crapcob.nrinsava
          ,crapcob.nmdavali
          ,crapcob.dsdoccop
          ,crapcob.dtmvtolt
          ,crapcob.qtdiaprt
          ,crapcob.vljurdia
          ,crapcob.tpdmulta
          ,crapcob.vlrmulta
          ,crapcob.flgaceit
          ,crapcob.cdcartei
          ,crapcob.nrdident
          ,crapcob.nratutit
          ,crapcob.inpagdiv
          ,crapcob.vlminimo
          ,crapcob.dtbloque
          ,crapcob.nrispbrc
          ,crapcob.dtdpagto
          ,crapcob.indpagto
          
      FROM crapcob
     WHERE crapcob.ROWID = pr_rowid;
  rw_crapcob cr_crapcob%ROWTYPE;

  /* Procedure para buscar dados legado */
  PROCEDURE pc_obtem_dados_legado(pr_cdcooper IN INTEGER --Codigo Cooperativa
                                 ,pr_nrdconta IN INTEGER --Numero da Conta
                                 ,pr_idseqttl IN INTEGER --Identificador sequencial titular
                                 ,pr_cdagecxa IN INTEGER --Codigo Agencia Caixa
                                 ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                 ,pr_nmrescop OUT VARCHAR2 --Nome resumido cooperativa
                                 ,pr_cdlegado OUT VARCHAR2 --Codigo Legado
                                 ,pr_nmarqlog OUT VARCHAR2 --Nome Arquivo Log
                                 ,pr_nmdirlog OUT VARCHAR2 --Nome Diretorio Log
                                 ,pr_msgenvio OUT VARCHAR2 --Mensagem envio
                                 ,pr_msgreceb OUT VARCHAR2 --Mensagem Recebimento
                                 ,pr_nrispbif OUT VARCHAR2 --Numero ispb IF
                                 ,pr_des_erro OUT VARCHAR2 --Indicador de erro OK/NOK
                                 ,pr_dscritic OUT VARCHAR2) IS --Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_obtem_dados_legado    Antigo: procedures/b1wgen0079.p/obtem-dados-legado
    --  Sistema  : Procedure para atualizar situacao do titulo do sacado eletronico
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para buscar dados legado
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_datdodia DATE;
    
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 651;
        vr_dscritic := 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
    
      --Selecionar Banco
      OPEN cr_crapban(pr_cdbccxlt => rw_crapcop.cdbcoctl);
      --Posicionar no proximo registro
      FETCH cr_crapban
        INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        vr_cdcritic := 57;
        vr_dscritic := ' ';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;
    
      --Retornar nome cooperativa
      pr_nmrescop := rw_crapcop.nmrescop;
      pr_cdlegado := 'LEG';
      --Buscar diretorio padrao cooperativa
      pr_nmdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/log') || '/'; --> ir para diretorio log
      --Buscar data do dia
      vr_datdodia := trunc(sysdate); /*PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);*/
      --Nome arquivo log
      pr_nmarqlog := 'JDDDA_LogErros_' || to_char(vr_datdodia, 'DDMMRRRR') ||
                     '.log';
      --Mensagem de envio
      pr_msgenvio := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') || '/' ||
                     'SOAP.MESSAGE.ENVIO.' ||
                     to_char(vr_datdodia, 'DDMMRRRR') ||
                     To_Char(GENE0002.fn_busca_time, 'fm00000') ||
                     to_char(pr_nrdconta, 'fm00000000') || pr_idseqttl;
      --Mensagem recebimento
      pr_msgreceb := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') || '/' ||
                     'SOAP.MESSAGE.RECEBIMENTO.' ||
                     To_Char(vr_datdodia, 'DDMMRRRR') ||
                     To_Char(GENE0002.fn_busca_time, 'fm00000') ||
                     to_char(pr_nrdconta, 'fm00000000') || pr_idseqttl;
    
      --Numero ISPB IF
      pr_nrispbif := TO_CHAR(rw_crapban.nrispbif, 'fm00000000');
    
      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_obtem_dados_legado. ' ||
                       SQLERRM;
    END;
  END pc_obtem_dados_legado;


  /* Procedure para criar tags no XML */
  PROCEDURE pc_cria_tag(pr_dsnomtag IN VARCHAR2 --> Nome TAG que ser� criada
                       ,pr_dspaitag IN VARCHAR2 --> Nome TAG pai
                       ,pr_dsvaltag IN VARCHAR2 --> Valor TAG que ser� criada
                       ,pr_postag   IN PLS_INTEGER --> Posi��o da TAG criada no nodelist
                       ,pr_dstpdado IN VARCHAR2 --> Tipo de dado da TAG
                       ,pr_deftpdad IN VARCHAR2 --> Defini��o do tipo de dado
                       ,pr_xml      IN OUT NOCOPY XMLType --> Handle XMLType
                       ,pr_des_erro OUT VARCHAR2 --> Identificador erro OK/NOK
                       ,pr_dscritic OUT VARCHAR2) IS --> Descri��o erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_tag    Antigo: procedures/b1wgen0079.p/cria-tag
    --  Sistema  : Procedure para criar tags no XML
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para criar tags XML
    --
    -- Alteracoes: 01/07/2013 - convers�o Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_exc_erro EXCEPTION; --> Controle de erros
    
    BEGIN
      -- Gerar TAGs dos par�metros para o m�todo
      gene0007.pc_insere_tag(pr_xml      => pr_xml
                            ,pr_tag_pai  => pr_dspaitag
                            ,pr_posicao  => pr_postag
                            ,pr_tag_nova => pr_dsnomtag
                            ,pr_tag_cont => pr_dsvaltag
                            ,pr_des_erro => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Gera atributo com o tipo do dado
      gene0007.pc_gera_atributo(pr_xml      => pr_xml
                               ,pr_tag      => pr_dsnomtag
                               ,pr_atrib    => pr_deftpdad
                               ,pr_atval    => pr_dstpdado
                               ,pr_numva    => pr_postag
                               ,pr_des_erro => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_cria_tag. ' ||
                       pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_cria_tag. ' || SQLERRM;
    END;
  END pc_cria_tag;

  /* Procedure para analisar retorno de erros do webservice */
  PROCEDURE pc_obtem_fault_packet(pr_xml      IN OUT NOCOPY xmltype --> XML de verifica��o
                                 ,pr_dsderror IN VARCHAR2 --> par�metro para libera��o de erros espec�ficos
                                 ,pr_des_erro OUT VARCHAR2 --> Indicador erro OK/NOK
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_obtem_fault_packet     (Antigo: procedures/b1wgen0079.p/obtem-fault-packet)
    --  Sistema  : Procedure para Executar Baixa Operacional
    --  Sigla    : CRED
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para validar retorno do webservice
    --
    -- Alteracoes: 01/08/2013 - convers�o Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_cdderror   VARCHAR2(400) := ''; --> C�digo do erro de acesso
      vr_dsderror   VARCHAR2(400) := ''; --> Descri��o do erro de acesso
      vr_countfault PLS_INTEGER := 0; --> Contagem de fault-code
      vr_erro EXCEPTION; --> Controle de erros
      vr_tab_valores gene0007.typ_tab_tagxml; --> PL Table para armazenar valores das TAGs
    
    BEGIN
      -- Verifica se retornou fault-code
      gene0007.pc_lista_nodo(pr_xml      => pr_xml
                            ,pr_nodo     => 'Fault'
                            ,pr_cont     => vr_countfault
                            ,pr_des_erro => pr_dscritic);
    
      -- Verifica se retornou erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_erro;
      END IF;
    
      -- Faz processo de valida��o do erro retornado no XML
      IF vr_countfault > 0 THEN
        -- Recupera o c�digo do erro
        gene0007.pc_itera_nodos(pr_xpath      => '//faultcode'
                               ,pr_xml        => pr_xml
                               ,pr_list_nodos => vr_tab_valores
                               ,pr_des_erro   => pr_dscritic);
      
        -- Verifica se retornou erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_erro;
        END IF;
      
        -- Grava valor e limpa PL Table
        vr_cdderror := vr_tab_valores(0).tag;
        vr_tab_valores.delete;
      
        -- Recupera a descri��o do erro
        -- Recupera o c�digo do erro
        gene0007.pc_itera_nodos(pr_xpath      => '//faultstring'
                               ,pr_xml        => pr_xml
                               ,pr_list_nodos => vr_tab_valores
                               ,pr_des_erro   => pr_dscritic);
      
        -- Verifica se retornou erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_erro;
        END IF;
      
        -- Grava valor e limpa PL Table
        vr_dsderror := vr_tab_valores(0).tag;
        vr_tab_valores.delete;
      
        -- Verifica se existe erro e se existe par�metro para ignorar
        IF pr_dsderror IS NOT NULL
           AND vr_cdderror IS NOT NULL
           AND gene0002.fn_existe_valor(pr_base     => vr_cdderror
                                       ,pr_busca    => pr_dsderror
                                       ,pr_delimite => ',') = 'S' THEN
          pr_des_erro := 'OK';
        ELSE
          pr_des_erro := 'NOK';
          pr_dscritic := 'Falha na execucao do metodo DDA ' || vr_cdderror ||
                         ' - ' || vr_dsderror || '. Comunique seu PA.';
        
          return;
        END IF;
      END IF;
    
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro em DDDA0001.pc_obtem_fault_packet: ' ||
                       pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro em DDDA0001.pc_obtem_fault_packet: ' ||
                       SQLERRM;
    END;
  END pc_obtem_fault_packet;

  /* Function para montar a URL do Webservice DDA cfme tipo de Servi�o */
  FUNCTION fn_url_SendSoapDDA(pr_idservic IN PLS_INTEGER) RETURN VARCHAR2 IS --> ID Do servi�o
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : fn_url_SendSoapDDA     (Antigo trecho: /usr/local/bin/SendSoapDDA.pl)
    --  Sistema  : CRED
    --  Sigla    : CRED
    --  Autor    : Marcos Martini - Supero Tecnologia
    --  Data     : Abril/2014.                   Ultima atualizacao: 26/05/2014
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Fun��o para Retornar a URL do Werbservice da JD-DDA
    --
    -- Alteracoes: 
    -- 26/05/2014 - Remo��o de trecho de montagem de nome de par�metro conforme base
    --              pois agora os par�metros foram unificados (Marcos-Supero)
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_dssrdom VARCHAR2(1000); -- Var para retorno do Service Domain
      vr_nmservi VARCHAR2(1000); -- Var para armazenagem do servi�o
    BEGIN
      -- Busca o service domain conforme par�metro DDA_SERVICE_DOMAIN
      vr_dssrdom := gene0001.fn_param_sistema('CRED'
                                             ,0
                                             ,'DDA_SERVICE_DOMAIN');
      -- Montagem do servi�o conforme passagem
      IF pr_idservic = 1 THEN
        vr_nmservi := gene0001.fn_param_sistema('CRED'
                                               ,0
                                               ,'IJDDDA_SACAD_ELETR');
      ELSIF pr_idservic = 2 THEN
        vr_nmservi := gene0001.fn_param_sistema('CRED'
                                               ,0
                                               ,'IJDDDA_SACAD_ELETR_AGREG');
      ELSIF pr_idservic = 3 THEN
        vr_nmservi := gene0001.fn_param_sistema('CRED'
                                               ,0
                                               ,'IJDDDA_TITULO_SACAD_ELET');
      END IF;
      -- Por fim, retorna a URL completa, com o service domaind + nome do servi�o
      return 'http://' || vr_dssrdom || vr_nmservi;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END fn_url_SendSoapDDA;

  --> Rotina para geracao do numero de controle participante 
  FUNCTION fn_gera_ctrlpart (pr_idacao IN VARCHAR2) RETURN VARCHAR2 IS
    vr_ctrlpart VARCHAR2(20);
  BEGIN
    --> NumCtrlPart
    vr_ctrlpart := to_char(SYSTIMESTAMP,'DDMMRRRRHH24MISSFF5') || 'DDA'||pr_idacao;
    
    RETURN vr_ctrlpart;
    
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN  to_char(SYSTIMESTAMP,'DDMMRRRRHH24MISS') || 'DDA'||pr_idacao; 
  END;

  /* Procedure para Executar Baixa Operacional */
  PROCEDURE pc_exec_baixa_operacional(pr_cdlegado IN VARCHAR2 --> Codigo Legado
                                     ,pr_nrispbif IN VARCHAR2 --> Numero ISPB IF
                                     ,pr_idtitdda IN NUMBER --> Identificador Titulo DDA
                                     ,pr_rowidtit IN ROWID DEFAULT NULL   --> Rowid da craptit para gerar a baixa operacional
                                     ,pr_xml_frag OUT NOCOPY xmltype --> Fragmento do XML de retorno
                                     ,pr_des_erro OUT VARCHAR2 --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_exec_baixa_operacional     (Antigo: procedures/b1wgen0079.p/baixa-operacional)
    --  Sistema  : Procedure para Executar Baixa Operacional
    --  Sigla    : CRED
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Executar Baixa Operacional
    --
    -- Alteracoes: 01/08/2013 - convers�o Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml     XMLType; --> XML de requisi��o
      vr_exc_erro EXCEPTION; --> Controle de exce��o
      vr_xml_res XMLType; --> XML de resposta
      vr_tab_xml gene0007.typ_tab_tagxml; --> PL Table para armazenar conte�do XML
      vr_cdcanal_npc INTEGER;                           
      
      --> Buscar dados do titulo pago
      CURSOR cr_craptit IS
        SELECT tit.nrispbds,
               tit.cdagenci, 
               decode(tit.inpessoa,1,'F','J') dsinpess,
               tit.nrdident,
               tit.nrcpfcgc,
               tit.tpbxoper,
               tit.dscodbar,
               tit.vldpagto,
               decode(tit.flgconti,1,'S','N') flgconti,
               tit.nrdconta,
               tit.flgpgdda
          FROM craptit tit
         WHERE tit.nrdident = pr_idtitdda
           AND tit.rowid    = pr_rowidtit; 
      rw_craptit cr_craptit%ROWTYPE;
    
      vr_tbcampos      NPCB0003.typ_tab_campos_soap;
      vr_cdCanPgt      INTEGER;
      vr_cdmeiopg      INTEGER;
      
    
    BEGIN
    
      -- Limpa a tab de campos
      vr_tbcampos.DELETE();
      
      -- Chama rotina para fazer a inclus�o das TAGS comuns
      NPCB0003.pc_xmlsoap_tag_padrao(pr_tbcampos => vr_tbcampos
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);
    
    
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumIdentcTit';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_idtitdda;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'TpBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.tpbxoper;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'ISPBPartRecbdrBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_nrispbif;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'TpPessoaPort';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.dsinpess;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CPFCNPJPort';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.nrcpfcgc;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';          
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'VlrBaixaOperacTit';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.vldpagto;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'float';      
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtHrProcBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE,'RRRRMMDDHH24MISS'); --> AAAAMMDDhhmmss
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';      
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtProcBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE,'RRRRMMDD');
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';      
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCodBarrasBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.dscodbar;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';      
      --
      --> Rotina para retornar o codigo do canal de pagamento do NPC
      vr_cdcanal_npc := NPCB0001.fn_canal_pag_NPC( pr_cdagenci  => rw_craptit.cdagenci    --> Codigo da agencia
                                                  ,pr_idtitdda  => rw_craptit.nrdident ); --> Indicador se foi pago pelo sistema de DDDA
                            
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CanPgto';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdcanal_npc;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';            
    
      IF rw_craptit.flgpgdda = 1 THEN
        vr_cdCanPgt := 8; --> DDA
      ELSE
        CASE rw_craptit.cdagenci 
          WHEN 90 THEN
            vr_cdCanPgt := 3; --> Internet            
          WHEN 91 THEN
            vr_cdCanPgt := 2; --> Terminal de Auto-Atendimento
          ELSE
            vr_cdCanPgt := 1; --> Ag�ncias- Postos Tradicionai            
        END CASE;       
      END IF;
        
      IF nvl(rw_craptit.nrdconta,0) > 0 THEN
        vr_cdmeiopg := 2; --> D�bito em conta;
      ELSE
        vr_cdmeiopg := 1; --> Esp�cie
      END IF;
    
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'CanPgto';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdCanPgt;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';    
      
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'MeioPgto';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_cdmeiopg;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';    
    
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'IndrOpContg';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := rw_craptit.flgconti;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';      
      
      -- Monta a estrutura principal do SOAP
      NPCB0003.pc_xmlsoap_monta_requisicao(pr_cdservic => 4 --> RecebimentoPgtoTit
                                          ,pr_cdmetodo => 4 --> RequisitarBaixa
                                          ,pr_tbcampos => vr_tbcampos
                            ,pr_xml      => vr_xml
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_des_erro != 'OK' THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Enviar requisi��o para webservice
      soap0001.pc_cliente_webservice(pr_endpoint    => fn_url_SendSoapDDA(pr_idservic => 3)
                                    ,pr_acao        => NULL
                                    ,pr_wallet_path => NULL
                                    ,pr_wallet_pass => NULL
                                    ,pr_xml_req     => vr_xml
                                    ,pr_xml_res     => vr_xml_res
                                    ,pr_erro        => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF trim(pr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml_res
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => pr_dscritic);
    
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        -- Envio centralizado de log de erro 
        RAISE vr_exc_erro;
      ELSE
        -- Busca valor do nodo dado o xPath
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml_res
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_des_erro);
      
        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          pr_dscritic := 'Resposta SOAP invalida (Return).';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      
        -- Verifica se retorno conte�do na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha na atualizacao da situacao.';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
      -- Retornar fragmento XML como novo documento XML
      --Valor n�o utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag); 
    
      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_exec_baixa_operacional. ' ||
                       pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_exec_baixa_operacional. ' ||
                       SQLERRM;
    END;
  END pc_exec_baixa_operacional;

  /* Procedure para Atualizar Situacao */
  PROCEDURE pc_requis_atualizar_situacao(pr_cdlegado IN VARCHAR2 --> Codigo Legado
                                        ,pr_nrispbif IN VARCHAR2 --> Numero ISPB IF
                                        ,pr_idtitdda IN NUMBER --> Identificador Titulo DDA
                                        ,pr_cdsittit IN INTEGER --> Codigo Situacao Titulo
                                        ,pr_xml_frag OUT NOCOPY xmltype --> Fragmento do XML de retorno
                                        ,pr_des_erro OUT VARCHAR2 --> Indicador erro OK/NOK
                                        ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_requis_atualizar_situacao      (Antigo: procedures/b1wgen0079.p/requisicao-atualizar-situacao)
    --  Sistema  : Procedure para atualizar situacao do titulo do sacado eletronico
    --  Sigla    : CRED
    --  Autor    : Petter Rafael - Supero Tecnologia
    --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Atualizar Situacao
    --
    -- Alteracoes: 01/08/2013 - convers�o Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml XMLType; --> XML de requisi��o
      vr_exc_erro EXCEPTION; --> Controle de exce��o
      
      vr_xml_res XMLType; --> XML de resposta
      vr_tab_xml gene0007.typ_tab_tagxml; --> PL Table para armazenar conte�do XML
      vr_ctrlpart VARCHAR2(20);
      
      vr_tbcampos      NPCB0003.typ_tab_campos_soap;
      
    
    BEGIN
    
      -- Limpa a tab de campos
      vr_tbcampos.DELETE();
      
      -- Chama rotina para fazer a inclus�o das TAGS comuns
      NPCB0003.pc_xmlsoap_tag_padrao(pr_tbcampos => vr_tbcampos
                            ,pr_des_erro => pr_des_erro
                            ,pr_dscritic => pr_dscritic);
    
      --> NumCtrlPart
      vr_ctrlpart := fn_gera_ctrlpart('A');
      
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCtrlPart';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := vr_ctrlpart;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumIdentcNPC';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_idtitdda;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'JDNPCSitManutTitSac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdsittit;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
     
    
      NPCB0003.pc_xmlsoap_monta_requisicao( pr_cdservic => 3  --> TituloPagadorEletronico
                                           ,pr_cdmetodo => 13 --> AtualizarSituacao
                                           ,pr_tbcampos => vr_tbcampos
                 ,pr_xml      => vr_xml
                 ,pr_des_erro => pr_des_erro
                 ,pr_dscritic => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Enviar requisi��o para webservice
      soap0001.pc_cliente_webservice(pr_endpoint    => fn_url_SendSoapDDA(pr_idservic => 3)
                                    ,pr_acao        => NULL
                                    ,pr_wallet_path => NULL
                                    ,pr_wallet_pass => NULL
                                    ,pr_xml_req     => vr_xml
                                    ,pr_xml_res     => vr_xml_res
                                    ,pr_erro        => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Verifica se ocorreu retorno com erro no XML
      pc_obtem_fault_packet(pr_xml      => vr_xml_res
                           ,pr_dsderror => ''
                           ,pr_des_erro => pr_des_erro
                           ,pr_dscritic => pr_dscritic);
    
      -- Verifica o retorno de erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      ELSE
        -- Busca valor do nodo dado o xPath
        gene0007.pc_itera_nodos(pr_xpath      => '//return'
                               ,pr_xml        => vr_xml_res
                               ,pr_list_nodos => vr_tab_xml
                               ,pr_des_erro   => pr_des_erro);
      
        -- Verifica se a TAG existe
        IF vr_tab_xml.count = 0 THEN
          pr_dscritic := 'Resposta SOAP invalida (Return).';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      
        -- Verifica se retorno conte�do na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha na atualizacao da situacao.';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
      -- Retornar fragmento XML como novo documento XML
      --Valor n�o utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag);
    
      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_requis_atualizar_situacao. ' ||
                       SQLERRM;
    END;
  END pc_requis_atualizar_situacao;

  /* Procedure para gravar linha log */
  PROCEDURE pc_grava_linha_log(pr_cdcooper IN INTEGER --> Codigo Cooperativa
                              ,pr_nrdconta IN INTEGER --> Numero da Conta
                              ,pr_nmmetodo IN VARCHAR2 --> Nome metodo
                              ,pr_cdderror IN VARCHAR2 --> Codigo erro
                              ,pr_dsderror IN VARCHAR2 --> Descricao erro
                              ,pr_nmarqlog IN VARCHAR2 --> Nome arquivo log
                              ,pr_nmdirlog IN VARCHAR2 --> Diretorio do log
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --Codigo do erro
                              ,pr_dscritic OUT VARCHAR2) IS --Mensagem de erro
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_grava_linha_log    Antigo: procedures/b1wgen0079.p/retorna-linha-log
    --  Sistema  : Procedure para gravar linha log
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gravar linha log
  
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_datdodia DATE;
      vr_nmprimtl VARCHAR2(100);
      vr_dscpfcgc VARCHAR2(100);
      --Variaveis de Arquivo
      vr_input_file utl_file.file_type;
      vr_setlinha   VARCHAR2(4000);
      --Variaveis Erro
      vr_des_erro VARCHAR2(1000);
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
    BEGIN
    
      --Inicializar parametros de erro
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --Se o nome do arquivo de log estiver vazio
      IF pr_nmarqlog IS NULL
         OR pr_nmarqlog IS NULL THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;
      --Selecionar associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass
        INTO rw_crapass;
      --Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        vr_nmprimtl := NULL;
        vr_dscpfcgc := NULL;
      ELSE
        vr_nmprimtl := rw_crapass.nmprimtl;
        vr_dscpfcgc := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                                ,pr_inpessoa => rw_crapass.inpessoa);
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      --Abrir arquivo modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdirlog --> Diret�rio do arquivo
                              ,pr_nmarquiv => pr_nmarqlog --> Nome do arquivo
                              ,pr_tipabert => 'A' --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro); --> Erro
      IF vr_des_erro IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Buscar data do dia
      vr_datdodia := PAGA0001.fn_busca_datdodia(pr_cdcooper => pr_cdcooper);
      --Montar linha que sera gravada no log
      vr_setlinha := to_char(vr_datdodia, 'DD/MM/YYYY') || ' ' ||
                     To_Char(SYSDATE, 'HH24:MI:SS') || ' --> ' ||
                     GENE0002.fn_mask_conta(pr_nrdconta) || ' | ' ||
                     SUBSTR(vr_nmprimtl, 1, 50) || ' | ' ||
                     SUBSTR(vr_dscpfcgc, 1, 18) || ' | ' ||
                     SUBSTR(pr_nmmetodo, 1, 40) || ' | ' ||
                     SUBSTR(pr_cdderror, 1, 30) || ' | ' || pr_dsderror;
      --Escrever linha log
      gene0001.pc_escr_linha_arquivo(vr_input_file, vr_setlinha);
      --Fechar Arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        NULL;
      WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_des_erro;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao processar a rotina DDDA0001.pc_grava_linha_log ' ||
                       sqlerrm;
    END;
  END pc_grava_linha_log;

  /* Procedure para atualizar situacao do titulo do sacado eletronico */
  PROCEDURE pc_atualz_situac_titulo_sacado(pr_cdcooper IN INTEGER --Codigo da Cooperativa
                                          ,pr_cdagecxa IN INTEGER --Codigo da Agencia
                                          ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                          ,pr_cdopecxa IN VARCHAR2 --Codigo Operador Caixa
                                          ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                          ,pr_idorigem IN INTEGER --Indicador Origem
                                          ,pr_nrdconta IN INTEGER --Numero da Conta
                                          ,pr_idseqttl IN INTEGER --Sequencial do titular
                                          ,pr_idtitdda IN NUMBER --Indicador Titulo DDA
                                          ,pr_cdsittit IN INTEGER --Situacao Titulo
                                          ,pr_flgerlog IN BOOLEAN --Gerar Log
                                          ,pr_rowidtit IN ROWID DEFAULT NULL   --> Rowid da craptit para gerar a baixa operacional
                                          ,pr_des_erro OUT VARCHAR2 --Indicador erro OK/NOK
                                          ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de memoria de erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_atualz_situac_titulo_sacado    Antigo: procedures/b1wgen0079.p/atualizar-situacao-titulo-sacado
    --  Sistema  : Procedure para atualizar situacao do titulo do sacado eletronico
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 01/07/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para atualizar situacao do titulo do sacado eletronico
    --
    -- Atualiza��o: Ajustado mensagem de critica de falha DDA (Odirlei-Amcom)
    --
    -- Alteracoes: 07/07/2014 - Remover do log a mensagem "DDDA0001 --> Falha na execucao do metodo 
    --                          DDA SOAP-ENV:-722 - Situa��o do T�tulo n�o permite mais altera��es. 
    --                          Comunique seu PA." (Douglas - Chamado 160064)
    --
    --             04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir 
    --                          nomenclaturas Cedente por Benefici�rio e  Sacado por Pagador  
    --                           Chamado 229313 (Jean Reddiga - RKAM).
    --
    --             01/07/2016 - Adicionado o valor do parametro pr_idtitdda no log de erros da 
    --                          atualiza��o da situa��o do titulo (Douglas - Chamado 462368)
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_indtrans INTEGER;
      vr_nrdrowid ROWID;
      vr_dsreturn VARCHAR2(1000);
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_xml      xmltype;
      --Variaveis da pc_obtem_dados_legado
      vr_cdlegado VARCHAR2(1000);
      vr_nmarqlog VARCHAR2(1000);
      vr_nmdirlog VARCHAR2(1000);
      vr_msgenvio VARCHAR2(1000);
      vr_msgreceb VARCHAR2(1000);
      vr_nrispbif VARCHAR2(1000);
    
      --Variaveis Erro
      vr_cdderror VARCHAR2(100);
      vr_dsderror VARCHAR2(100);
      vr_des_erro VARCHAR2(1000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_cderrlog crapcri.cdcritic%TYPE;
      vr_dserrlog VARCHAR2(4000);
    
      --Tabela de memoria de erro
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_tab_erro.DELETE;
      --Gerar log erro
      IF pr_flgerlog THEN
        --Descricao Origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao transacao
        vr_dstransa := 'DDA - Atualizar Situacao do Titulo do Pagador';
      END IF;
      --Inicializar variaveis
      vr_cdcritic := 0;
      vr_dscritic := '';
      vr_cdderror := NULL;
      vr_dsderror := NULL;
      BEGIN
        --Obter dados legado
        DDDA0001.pc_obtem_dados_legado(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                      ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                      ,pr_idseqttl => pr_idseqttl --Identificador sequencial titular
                                      ,pr_cdagecxa => pr_cdagecxa --Codigo Agencia Caixa
                                      ,pr_nrdcaixa => pr_nrdcaixa --Numero do Caixa
                                       --Parametros saida
                                      ,pr_nmrescop => rw_crapcop.nmrescop --Nome resumido cooperativa
                                      ,pr_cdlegado => vr_cdlegado --Codigo Legado
                                      ,pr_nmarqlog => vr_nmarqlog --Nome Arquivo Log
                                      ,pr_nmdirlog => vr_nmdirlog --Nome Diretorio Log
                                      ,pr_msgenvio => vr_msgenvio --Mensagem envio
                                      ,pr_msgreceb => vr_msgreceb --Mensagem Recebimento
                                      ,pr_nrispbif => vr_nrispbif --Numero ispb IF
                                      ,pr_des_erro => vr_dsreturn --Indicador erro OK/NOK
                                      ,pr_dscritic => vr_des_erro); --Descricao erro
        --Situacao titulo invalida
        IF pr_cdsittit < 1
           OR pr_cdsittit > 4 THEN
          --Descricao da Critica
          vr_dscritic := 'Situacao do titulo invalida.';
          --Sair
          RAISE vr_exc_saida;
        END IF;
      
        --Atualizar Situa��o
        DDDA0001.pc_requis_atualizar_situacao(pr_cdlegado => vr_cdlegado --Codigo Legado
                                             ,pr_nrispbif => vr_nrispbif --Numero ISPB IF
                                             ,pr_idtitdda => pr_idtitdda --Identificador Titulo DDA
                                             ,pr_cdsittit => pr_cdsittit --Codigo Situacao Titulo
                                             ,pr_xml_frag => vr_xml --Documento XML do fragmento do retorno SOAP
                                             ,pr_des_erro => vr_dsreturn --Indicador erro OK/NOK
                                             ,pr_dscritic => vr_des_erro); --Descricao erro
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          NULL;
      END;
    
      --Se ocorreu eror
      IF vr_dsreturn = 'NOK' THEN
        IF vr_cdcritic = 0
           AND vr_dscritic IS NULL THEN
          vr_dscritic := 'Falha DDA: ' || substr(vr_des_erro, 1, 900);
          -- Verificar a mensagem de erro que retornou
          IF vr_des_erro NOT LIKE
             'Falha na execucao do metodo DDA SOAP-ENV:-722%' THEN
            --Se n�o for a cr�tica 722, geramos a informa��o no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate
                                                                 ,'hh24:mi:ss') ||
                                                          ' - ' ||
                                                          'DDDA0001' ||
                                                          ' --> ' ||
                                                          vr_des_erro);
          END IF;
        END IF;
      
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagecxa
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      
        --verificar qual mensagem sera logada
        IF vr_cdderror IS NOT NULL THEN
          vr_cderrlog := vr_cdderror;
          vr_dserrlog := vr_dsderror;
        ELSE
          vr_cderrlog := vr_cdcritic;
          vr_dserrlog := vr_dscritic;
        END IF;
      
        --Limpar variaveis erro
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        
        --Adicionar o idtitdda na mensagem do log
        vr_dserrlog := vr_dserrlog || ' - ID Titulo DDA: ' || to_char(pr_idtitdda);
        
        --Gravar Linha Log
        DDDA0001.pc_grava_linha_log(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                   ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                   ,pr_nmmetodo => 'AtualizarSituacao' --Nome metodo
                                   ,pr_cdderror => vr_cderrlog --Codigo erro
                                   ,pr_dsderror => vr_dserrlog --Descricao erro
                                   ,pr_nmarqlog => vr_nmarqlog --Nome arquivo log
                                   ,pr_nmdirlog => vr_nmdirlog --Diretorio do log
                                   ,pr_cdcritic => vr_cdcritic --Codigo do erro
                                   ,pr_dscritic => vr_dscritic); --Mensagem de erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          --Retornar erro
          RAISE vr_exc_erro;
        END IF;
      
        RAISE vr_exc_erro;
      END IF;
      --Se for para gerar log erro
      IF pr_flgerlog THEN
        --Transformar boolean em number
        IF vr_dsreturn = 'OK' THEN
          vr_indtrans := 1;
        ELSE
          vr_indtrans := 0;
        END IF;
        -- Chamar gera��o de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdopecxa
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => vr_indtrans
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
    
      --Inicializar variaveis
      vr_cdcritic := 0;
      vr_dscritic := '';
      vr_cdderror := NULL;
      vr_dsderror := NULL;
    
      /* se t�tulo pago, realizar baixa operacional */
      IF pr_cdsittit IN (3, 4) THEN
        BEGIN
          --Dado retorno
          vr_dsreturn := 'NOK';
          --Obter dados legado
          DDDA0001.pc_obtem_dados_legado(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                        ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                        ,pr_idseqttl => pr_idseqttl --Identificador sequencial titular
                                        ,pr_cdagecxa => pr_cdagecxa --Codigo Agencia Caixa
                                        ,pr_nrdcaixa => pr_nrdcaixa --Numero do Caixa
                                         --Parametros saida
                                        ,pr_nmrescop => rw_crapcop.nmrescop --Nome resumido cooperativa
                                        ,pr_cdlegado => vr_cdlegado --Codigo Legado
                                        ,pr_nmarqlog => vr_nmarqlog --Nome Arquivo Log
                                        ,pr_nmdirlog => vr_nmdirlog --Nome Diretorio Log
                                        ,pr_msgenvio => vr_msgenvio --Mensagem envio
                                        ,pr_msgreceb => vr_msgreceb --Mensagem Recebimento
                                        ,pr_nrispbif => vr_nrispbif --Numero ispb IF
                                        ,pr_des_erro => vr_dsreturn --Indicador erro OK/NOK
                                        ,pr_dscritic => vr_des_erro); --Descricao erro
          --Se retornou erro
          IF vr_dsreturn = 'NOK' THEN
            --sair
            RAISE vr_exc_saida;
          END IF;
          --Situacao titulo invalida
          IF pr_cdsittit < 1
             OR pr_cdsittit > 4 THEN
            --Descricao da Critica
            vr_dscritic := 'Situacao do titulo invalida.';
            --Sair
            RAISE vr_exc_saida;
          END IF;
          --Executar Baixa Operacional
          DDDA0001.pc_exec_baixa_operacional(pr_cdlegado => vr_cdlegado --Codigo Legado
                                            ,pr_nrispbif => vr_nrispbif --Numero ISPB IF
                                            ,pr_idtitdda => pr_idtitdda --Identificador Titulo DDA
                                            ,pr_rowidtit => pr_rowidtit --> Rowid do titulo para baixa operacional
                                            ,pr_xml_frag => vr_xml --Documento XML referente ao fragmento do XML de resposta do SOAP
                                            ,pr_des_erro => vr_dsreturn --Indicador erro OK/NOK
                                            ,pr_dscritic => vr_des_erro); --Descricao erro
        
        EXCEPTION
          WHEN vr_exc_saida THEN
            NULL;
        END;
        --Se ocorreu erro na baixa
        IF vr_dsreturn = 'NOK' THEN
          --Se nao ocorreu critica
          IF vr_cdcritic = 0
             AND vr_dscritic IS NULL THEN
            vr_dscritic := 'Falha DDA: ' || substr(vr_des_erro, 1, 900);
          END IF;
          --Gerar erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagecxa
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        
          --verificar qual mensagem sera logada
          IF vr_cdderror IS NOT NULL THEN
            vr_cderrlog := vr_cdderror;
            vr_dserrlog := vr_dsderror;
          ELSE
            vr_cderrlog := vr_cdcritic;
            vr_dserrlog := vr_dscritic;
          END IF;
          --Limpar Variaveis erro
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          --Gravar Linha Log
          DDDA0001.pc_grava_linha_log(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                     ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                     ,pr_nmmetodo => 'AtualizarSituacao' --Nome metodo
                                     ,pr_cdderror => vr_cderrlog --Codigo erro
                                     ,pr_dsderror => vr_dserrlog --Descricao erro
                                     ,pr_nmarqlog => vr_nmarqlog --Nome arquivo log
                                     ,pr_nmdirlog => vr_nmdirlog --Diretorio do log
                                     ,pr_cdcritic => vr_cdcritic --Codigo do erro
                                     ,pr_dscritic => vr_dscritic); --Mensagem de erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL
             OR vr_dscritic IS NOT NULL THEN
            --Retornar erro
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --Se for para gerar log erro
        IF pr_flgerlog THEN
          --Transformar boolean em number
          IF vr_dsreturn = 'OK' THEN
            vr_indtrans := 1;
          ELSE
            vr_indtrans := 0;
          END IF;
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdopecxa
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => vr_indtrans
                              ,pr_hrtransa => GENE0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
      END IF;
      --Retornar OK/NOK
      pr_des_erro := vr_dsreturn;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
      
        pr_tab_erro := vr_tab_erro;
      
        IF vr_dscritic is not null THEN
          pr_tab_erro(pr_tab_erro.count + 1).cdcritic := 0;
          pr_tab_erro(pr_tab_erro.count).dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_tab_erro(pr_tab_erro.count + 1).cdcritic := 0;
        pr_tab_erro(pr_tab_erro.count).dscritic := 'Erro na rotina DDDA0001.pc_atualz_situac_titulo_sacado. ' ||
                                                   SQLERRM;
    END;
  END pc_atualz_situac_titulo_sacado;

  /* Procedure para calcular c�digo barras */
  PROCEDURE pc_calc_codigo_barras(pr_cdbandoc IN crapcob.cdbandoc%TYPE --Codigo banco
                                 ,pr_vltitulo IN crapcob.vltitulo%TYPE --Valor Titulo
                                 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --Numero Convenvio Cobranca
                                 ,pr_nrnosnum IN crapcob.nrnosnum%TYPE --Nosso Numero
                                 ,pr_cdcartei IN crapcob.cdcartei%TYPE --Codigo Carteira
                                 ,pr_dtvencto IN DATE --Data vencimento
                                 ,pr_cdbarras OUT VARCHAR2) IS --Codigo barras
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_calc_codigo_barras    Antigo: procedures/b1wgen0088.p/p_calc_codigo_barras
    --  Sistema  : Procedure para calcular c�digo barras
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 02/02/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para calcular c�digo barras
    --
    -- Atualiza��o: 02/02/2015 - Retirado to_number pois no oracle exite o limite de numerico em 38 digitos
    --                           e o numero do codbar � de 44, utilizado express�o regular para verificar numerivos
    --                           SD241593 (Odirlei-AMcom)
    -- 
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Constante Local
      ct_dtini CONSTANT DATE := To_Date('10/07/1997', 'MM/DD/YYYY');
      --Variaveis Locais
      vr_string   VARCHAR2(100);
      vr_flgcbok  BOOLEAN;
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Montar o Codigo Barrass
      vr_string := to_char(pr_cdbandoc, 'fm000') || '9' || /* moeda */
                   '1' || /* nao alterar - constante */
                   to_char((pr_dtvencto - ct_dtini), 'fm0000') ||
                   to_char(pr_vltitulo * 100, 'fm0000000000') ||
                   to_char(pr_nrcnvcob, 'fm000000') ||
                   To_Char(pr_nrnosnum, 'fm00000000000000000') ||
                   To_Char(pr_cdcartei, 'fm00');
      
      -- Verificar se � s� numeros
      IF REGEXP_INSTR( vr_string, '[^[:digit:]]') > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
      --Calcular Digito C�digo barras Titulo
      CXON0000.pc_calc_digito_titulo(pr_valor   => vr_string --> Valor Calculado
                                    ,pr_retorno => vr_flgcbok); --> Retorno digito correto
      --Retornar Codigo Barras
      pr_cdbarras := gene0002.fn_mask(vr_string
                                    ,'99999999999999999999999999999999999999999999');
    EXCEPTION
      WHEN vr_exc_erro THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END;
  END pc_calc_codigo_barras;

  /* Procedure para criar remessa DDA */
  PROCEDURE pc_cria_remessa_dda(pr_rowid_cob       IN ROWID --ROWID da Cobranca
                               ,pr_tpoperad        IN VARCHAR2 --Tipo operador   /* (B)aixa (I)nclusao (A)lteracao   */
                               ,pr_tpdbaixa        IN VARCHAR2 --Tipo de baixa
                               ,pr_dtvencto        IN DATE --Data vencimento
                               ,pr_vldescto        IN NUMBER --Valor Desconto
                               ,pr_vlabatim        IN NUMBER --Valor Abatimento
                               ,pr_flgdprot        IN BOOLEAN --Flag protecao
                               ,pr_tab_remessa_dda OUT DDDA0001.typ_tab_remessa_dda --Tabela remessa
                               ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --Codigo de Erro
                               ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_remessa_dda    Antigo: procedures/b1wgen0088.p/cria-tt-dda
    --  Sistema  : Procedure para atualizar situacao do titulo do sacado eletronico
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 16/03/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para criar remessa DDA
    --
    -- Altera��es: 04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir 
    --                          nomenclaturas Cedente por Benefici�rio e  Sacado por Pagador  
    --                           Chamado 229313 (Jean Reddiga - RKAM).
    --
    --             16/03/2015 - Ajuste na busca do titular, caso n�o seja informado deve buscar o principal
    --                          (Odirlei-AMcom)
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar informacoes sacado
      CURSOR cr_crapsab(pr_cdcooper IN crapsab.cdcooper%type
                       ,pr_nrdconta IN crapsab.nrdconta%type
                       ,pr_nrinssac IN crapsab.nrinssac%type) IS
        SELECT crapsab.cdtpinsc
              ,crapsab.cdufsaca
              ,crapsab.nrcepsac
              ,crapsab.nmdsacad
              ,crapsab.dsendsac
              ,crapsab.nmcidsac
              ,crapsab.nrinssac
          FROM crapsab crapsab
         WHERE crapsab.cdcooper = pr_cdcooper
               AND crapsab.nrdconta = pr_nrdconta
               AND crapsab.nrinssac = pr_nrinssac;
      rw_crapsab cr_crapsab%ROWTYPE;
      --Selecionar titular
      CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%type
                       ,pr_nrdconta IN crapttl.nrdconta%type
                       ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT crapttl.nmextttl
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
               AND crapttl.nrdconta = pr_nrdconta
               -- se n�o foi informado titular, buscar o principal
               AND crapttl.idseqttl = decode(pr_idseqttl,0,1,pr_idseqttl);
      rw_crapttl cr_crapttl%ROWTYPE;
      
      --> buscar titulo
      CURSOR cr_craptit (pr_cdcooper  craptit.cdcooper%TYPE,
                         pr_dtmvtolt  craptit.dtmvtolt%TYPE,
                         pr_dscodbar  craptit.dscodbar%TYPE ) IS
        SELECT tit.cdagenci,
               tit.nrdconta,
               tit.flgpgdda
          FROM craptit tit
         WHERE tit.cdcooper = pr_cdcooper
           AND tit.dtmvtolt = pr_dtmvtolt
           AND tit.dscodbar = pr_dscodbar;
      rw_craptit cr_craptit%ROWTYPE;
      
      
      --Variaveis Locais
      vr_index    INTEGER;
      vr_cdbarras VARCHAR2(100);
      vr_dsdjuros VARCHAR2(100);
      vr_cddespec VARCHAR2(100);
      vr_nmprimtl crapass.nmprimtl%type;
      vr_dsdinstr VARCHAR2(100);
      vr_cdCanPgt INTEGER;
      vr_cdmeiopg INTEGER;
      
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --Limpar tabela memoria
      pr_tab_remessa_dda.DELETE;
    
      --Selecionar registro cobranca
      OPEN cr_crapcob(pr_rowid => pr_rowid_cob);
      --Posicionar no proximo registro
      FETCH cr_crapcob
        INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;
    
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => rw_crapcob.cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 651;
        vr_dscritic := 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
    
      /* tt-dados-sacado-blt */
      OPEN cr_crapsab(pr_cdcooper => rw_crapcob.cdcooper
                     ,pr_nrdconta => rw_crapcob.nrdconta
                     ,pr_nrinssac => rw_crapcob.nrinssac);
      --Posicionar no proximo registro
      FETCH cr_crapsab
        INTO rw_crapsab;
      --Se nao encontrar
      IF cr_crapsab%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapsab;
        vr_cdcritic := 0;
        vr_dscritic := 'Pagador nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapsab;
    
      --Selecionar associado
      OPEN cr_crapass(pr_cdcooper => rw_crapcob.cdcooper
                     ,pr_nrdconta => rw_crapcob.nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass
        INTO rw_crapass;
      --Se nao encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        vr_cdcritic := 0;
        vr_dscritic := 'Associado nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      --Se nao for pessoa fisica
      IF rw_crapass.inpessoa > 1 THEN
        --Nome titular
        vr_nmprimtl := REPLACE(rw_crapass.nmprimtl, Chr(38), '%26');
      ELSIF rw_crapass.inpessoa = 1 THEN
        --Selecionar titular
        OPEN cr_crapttl(pr_cdcooper => rw_crapcob.cdcooper
                       ,pr_nrdconta => rw_crapcob.nrdconta
                       ,pr_idseqttl => rw_crapcob.idseqttl);
        --Posicionar no proximo registro
        FETCH cr_crapttl
          INTO rw_crapttl;
        --Se nao encontrar
        IF cr_crapttl%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapttl;
          vr_cdcritic := 0;
          vr_dscritic := 'Titular nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Nome titular
          vr_nmprimtl := REPLACE(rw_crapttl.nmextttl, Chr(38), '%26');
        END IF;
        --Fechar Cursor
        CLOSE cr_crapttl;
      END IF;
    
      --Calcular Codigo Barras
      DDDA0001.pc_calc_codigo_barras(pr_cdbandoc => rw_crapcob.cdbandoc --Codigo banco
                                    ,pr_vltitulo => rw_crapcob.vltitulo --Valor Titulo
                                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob --Numero Convenvio Cobranca
                                    ,pr_nrnosnum => rw_crapcob.nrnosnum --Nosso Numero
                                    ,pr_cdcartei => rw_crapcob.cdcartei --Codigo Carteira
                                    ,pr_dtvencto => pr_dtvencto
                                    ,pr_cdbarras => vr_cdbarras);
      --Tipo Juros Mora
      CASE rw_crapcob.tpjurmor
        WHEN 1 THEN
          --Valor Dia
          vr_dsdjuros := '1';
        WHEN 2 THEN
          --Mensal
          vr_dsdjuros := '3';
        WHEN 3 THEN
          --Isento
          vr_dsdjuros := '5';
        ELSE
          NULL;
      END CASE;
    
      --Codigo Especie Bloqueto
      CASE rw_crapcob.cddespec
        WHEN 1 THEN
          vr_cddespec := '2';
        WHEN 2 THEN
          vr_cddespec := '4';
        WHEN 3 THEN
          vr_cddespec := '12';
        WHEN 4 THEN
          vr_cddespec := '21';
        WHEN 5 THEN
          vr_cddespec := '23';
        WHEN 6 THEN
          vr_cddespec := '17';
        WHEN 7 THEN
          vr_cddespec := '99';
        ELSE
          NULL;
      END CASE;
    
      --Selecionar Banco
      OPEN cr_crapban(pr_cdbccxlt => rw_crapcob.cdbandoc);
      --Posicionar no proximo registro
      FETCH cr_crapban
        INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro nrispbif nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;
      --Descricao da Instrucao
      vr_dsdinstr := substr(rw_crapcob.dsdinstr, 1, 100);
    
      IF NOT pr_flgdprot THEN
        vr_dsdinstr := REPLACE(vr_dsdinstr
                              ,'** Servico de protesto sera efetuado pelo Banco do Brasil **'
                              ,'');
      END IF;
      
      vr_cdCanPgt := NULL;
      vr_cdmeiopg := NULL;
      
      --> Se for operacao de baixa
      IF pr_tpoperad = 'B' AND 
         --> e foi pago na cooperativa(baixa intrabancaria)
         rw_crapcob.indpagto <> 0 THEN
         
        rw_craptit := NULL;
        --> buscar titulo
        OPEN cr_craptit (pr_cdcooper  => rw_crapcob.cdcooper,
                         pr_dtmvtolt  => rw_crapcob.dtdpagto,
                         pr_dscodbar  => vr_cdbarras);
         
        FETCH cr_craptit INTO rw_craptit;
        
        IF cr_craptit%FOUND THEN
        
          IF rw_craptit.flgpgdda = 1 THEN
            vr_cdCanPgt := 8; --> DDA
          ELSE
            CASE rw_craptit.cdagenci 
              WHEN 90 THEN
                vr_cdCanPgt := 3; --> Internet            
              WHEN 91 THEN
                vr_cdCanPgt := 2; --> Terminal de Auto-Atendimento
              ELSE
                vr_cdCanPgt := 1; --> Ag�ncias- Postos Tradicionai            
            END CASE;       
          END IF;
        
          IF nvl(rw_craptit.nrdconta,0) > 0 THEN
            vr_cdmeiopg := 2; --> D�bito em conta;
          ELSE
            vr_cdmeiopg := 1; --> Esp�cie
          END IF;
        
        END IF;
        CLOSE cr_craptit;
        
      END IF;
      
      
      --Pegar proximo indice remessa
      vr_index := pr_tab_remessa_dda.Count + 1;
      --Criar remessa
      pr_tab_remessa_dda(vr_index).cdlegado := 'LEG';
      pr_tab_remessa_dda(vr_index).nrispbif := rw_crapban.nrispbif;
      pr_tab_remessa_dda(vr_index).idopeleg := seqcob_idopeleg.NEXTVAL;
      pr_tab_remessa_dda(vr_index).idtitleg := rw_crapcob.idtitleg;
      pr_tab_remessa_dda(vr_index).tpoperad := pr_tpoperad;
      pr_tab_remessa_dda(vr_index).tpdbaixa := pr_tpdbaixa;
      pr_tab_remessa_dda(vr_index).cdifdced := 085;
      IF rw_crapass.inpessoa = 1 THEN
        pr_tab_remessa_dda(vr_index).tppesced := 'F';
        pr_tab_remessa_dda(vr_index).tppesori := 'F';
      ELSE
        pr_tab_remessa_dda(vr_index).tppesced := 'J';
        pr_tab_remessa_dda(vr_index).tppesori := 'J';
      END IF;
      pr_tab_remessa_dda(vr_index).nrdocced := rw_crapass.nrcpfcgc;
      pr_tab_remessa_dda(vr_index).nmdocede := vr_nmprimtl;
      pr_tab_remessa_dda(vr_index).cdageced := rw_crapcop.cdagectl;
      pr_tab_remessa_dda(vr_index).nrctaced := rw_crapcob.nrdconta;
      pr_tab_remessa_dda(vr_index).nrdocori := rw_crapass.nrcpfcgc;
      pr_tab_remessa_dda(vr_index).nmdoorig := vr_nmprimtl;
      IF rw_crapsab.cdtpinsc = 1 THEN
        pr_tab_remessa_dda(vr_index).tppessac := 'F';
      ELSE
        pr_tab_remessa_dda(vr_index).tppessac := 'J';
      END IF;
      pr_tab_remessa_dda(vr_index).nrdocsac := rw_crapsab.nrinssac;
      pr_tab_remessa_dda(vr_index).nmdosaca := REPLACE(rw_crapsab.nmdsacad
                                                      ,Chr(38)
                                                      ,'%26');
      pr_tab_remessa_dda(vr_index).dsendsac := REPLACE(rw_crapsab.dsendsac
                                                      ,Chr(38)
                                                      ,'%26');
      pr_tab_remessa_dda(vr_index).dscidsac := REPLACE(rw_crapsab.nmcidsac
                                                      ,Chr(38)
                                                      ,'%26');
      pr_tab_remessa_dda(vr_index).dsufsaca := rw_crapsab.cdufsaca;
      pr_tab_remessa_dda(vr_index).nrcepsac := rw_crapsab.nrcepsac;
      IF rw_crapcob.cdtpinav = 0 THEN
        pr_tab_remessa_dda(vr_index).tpdocava := 0;
      ELSE
        pr_tab_remessa_dda(vr_index).tpdocava := rw_crapcob.cdtpinav;
      END IF;
      IF rw_crapcob.cdtpinav = 0 THEN
        pr_tab_remessa_dda(vr_index).nrdocava := NULL;
      ELSE
        pr_tab_remessa_dda(vr_index).nrdocava := rw_crapcob.nrinsava;
      END IF;
      IF TRIM(rw_crapcob.nmdavali) IS NULL THEN
        pr_tab_remessa_dda(vr_index).nmdoaval := NULL;
      ELSE
        pr_tab_remessa_dda(vr_index).nmdoaval := TRIM(rw_crapcob.nmdavali);
      END IF;
      pr_tab_remessa_dda(vr_index).cdcartei := '1'; /* cobranca simples */
      pr_tab_remessa_dda(vr_index).cddmoeda := '09'; /* 9 = Real */
      pr_tab_remessa_dda(vr_index).dsnosnum := rw_crapcob.nrnosnum;
      pr_tab_remessa_dda(vr_index).dscodbar := vr_cdbarras;
      pr_tab_remessa_dda(vr_index).dtvencto := To_Number(To_Char(pr_dtvencto
                                                                ,'YYYYMMDD'));
      pr_tab_remessa_dda(vr_index).vlrtitul := rw_crapcob.vltitulo;
      pr_tab_remessa_dda(vr_index).nrddocto := rw_crapcob.dsdoccop;
      pr_tab_remessa_dda(vr_index).cdespeci := vr_cddespec;
      pr_tab_remessa_dda(vr_index).dtemissa := To_Number(To_Char(rw_crapcob.dtmvtolt
                                                                ,'YYYYMMDD'));
      IF pr_flgdprot = TRUE THEN
        pr_tab_remessa_dda(vr_index).nrdiapro := rw_crapcob.qtdiaprt;
      ELSE
        pr_tab_remessa_dda(vr_index).nrdiapro := NULL;
      END IF;
      pr_tab_remessa_dda(vr_index).tpdepgto := 3; /* vencto indeterminado */
      IF pr_flgdprot THEN
        pr_tab_remessa_dda(vr_index).dtlipgto := To_Number(To_Char(pr_dtvencto +
                                                                   rw_crapcob.qtdiaprt
                                                                  ,'YYYYMMDD'));
      ELSE
        pr_tab_remessa_dda(vr_index).dtlipgto := To_Number(To_Char(pr_dtvencto + 15
                                                                  ,'YYYYMMDD'));
      END IF;
      pr_tab_remessa_dda(vr_index).indnegoc := 'N';
      pr_tab_remessa_dda(vr_index).vlrabati := pr_vlabatim;
      IF rw_crapcob.vljurdia > 0 THEN
        pr_tab_remessa_dda(vr_index).dtdjuros := To_Number(To_Char(pr_dtvencto + 1
                                                                  ,'YYYYMMDD'));
      ELSE
        pr_tab_remessa_dda(vr_index).dtdjuros := NULL;
      END IF;
      pr_tab_remessa_dda(vr_index).dsdjuros := vr_dsdjuros;
      IF rw_crapcob.vljurdia > 0 THEN
        pr_tab_remessa_dda(vr_index).vlrjuros := rw_crapcob.vljurdia;
      ELSE
        pr_tab_remessa_dda(vr_index).vlrjuros := 0;
      END IF;
      IF rw_crapcob.tpdmulta = 3 THEN
        pr_tab_remessa_dda(vr_index).dtdmulta := NULL;
      ELSE
        pr_tab_remessa_dda(vr_index).dtdmulta := To_Number(To_Char(pr_dtvencto + 1
                                                                  ,'YYYYMMDD'));
      END IF;
      IF rw_crapcob.tpdmulta = 3 THEN
        pr_tab_remessa_dda(vr_index).cddmulta := '3';
      ELSE
        pr_tab_remessa_dda(vr_index).cddmulta := rw_crapcob.tpdmulta;
      END IF;
      IF rw_crapcob.tpdmulta = 3 THEN
        pr_tab_remessa_dda(vr_index).vlrmulta := 0;
      ELSE
        pr_tab_remessa_dda(vr_index).vlrmulta := rw_crapcob.vlrmulta;
      END IF;
      IF rw_crapcob.flgaceit = 1 THEN
        pr_tab_remessa_dda(vr_index).flgaceit := 'S';
      ELSE
        pr_tab_remessa_dda(vr_index).flgaceit := 'N';
      END IF;
      IF pr_vldescto > 0 THEN
        pr_tab_remessa_dda(vr_index).dtddesct := TO_NUMBER(To_Char(pr_dtvencto
                                                                  ,'YYYYMMDD'));
      ELSE
        pr_tab_remessa_dda(vr_index).dtddesct := NULL;
      END IF;
      IF pr_vldescto > 0 THEN
        pr_tab_remessa_dda(vr_index).cdddesct := '1';
      ELSE
        pr_tab_remessa_dda(vr_index).cdddesct := '0';
      END IF;
      pr_tab_remessa_dda(vr_index).vlrdesct := pr_vldescto;
      pr_tab_remessa_dda(vr_index).dsinstru := vr_dsdinstr;
      /* regra nova da CIP - titulos emitidos apos 17/03/2012 sao
      registrados com tipo de calculo "01" (Rafael) */
      IF rw_crapcob.dtmvtolt >= To_Date('03/17/2012', 'MM/DD/YYYY') THEN
        pr_tab_remessa_dda(vr_index).tpmodcal := '04'; -->  CIP calcula boletos a vencer e vencido.
      ELSE
        pr_tab_remessa_dda(vr_index).tpmodcal := '00';
      END IF;
      /* regra nova da CIP - titulos emitidos apos 17/03/2012 sao
      registrados Indicador Alteracao Valor "S" (Rafael) */
      IF rw_crapcob.dtmvtolt >= To_Date('03/17/2012', 'MM/DD/YYYY') THEN
        pr_tab_remessa_dda(vr_index).flavvenc := 'S';
      ELSE
        pr_tab_remessa_dda(vr_index).flavvenc := 'L';
      END IF;
      
      pr_tab_remessa_dda(vr_index).inpagdiv := rw_crapcob.inpagdiv;             
      pr_tab_remessa_dda(vr_index).vlminimo := rw_crapcob.vlminimo; 
      pr_tab_remessa_dda(vr_index).dtbloque := rw_crapcob.dtbloque;   
      pr_tab_remessa_dda(vr_index).nrispbrc := rw_crapcob.nrispbrc;
      pr_tab_remessa_dda(vr_index).cdCanPgt := vr_cdCanPgt;
      pr_tab_remessa_dda(vr_index).cdmeiopg := vr_cdmeiopg;
      
      
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_cria_remessa_dda. ' ||
                       SQLERRM;
    END;
  END pc_cria_remessa_dda;

  /* Procedure para buscar codigo cedente do DDA */
  PROCEDURE pc_busca_cedente_DDA(pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_idtitdda IN NUMBER --Identificador Titulo dda
                                ,pr_nrinsced OUT NUMBER --Numero inscricao cedente
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                ,pr_dscritic OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_cedente_DDA        Antigo: procedures/b1wgen0087.p/busca-cedente-DDA
    --  Sistema  : Procedure para buscar codigo cedente do DDA
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 22/12/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para buscar codigo cedente do DDA
    --            
    --             22/12/2015 - Cursor cr_dadostitulo era fechado em um momento que
    --                          dependendo da situacao ocasionava erro (Tiago/Elton).
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      /* Cursores Locais */
    
      --Selecionar dados titulo
      CURSOR cr_dadostitulo(pr_ispbcliente IN tbjdnpcrcb_tit_dados."ISPBPrincipal"@jdnpcsql%type) IS
        SELECT tbj."CNPJCPFBenfcrioOr" CNPJCPFBenfcrioOr
          FROM tbjdnpcrcb_tit_dados@jdnpcsql tbj
         WHERE tbj."ISPBPrincipal" = pr_ispbcliente
           AND tbj."SitTit" = 01 --> Em aberto
           AND tbj."NumIdentcTit" = pr_idtitdda;
      rw_dadostitulo cr_dadostitulo%ROWTYPE;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 651;
        vr_dscritic := 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Selecionar Banco
      OPEN cr_crapban(pr_cdbccxlt => rw_crapcop.cdbcoctl);
      --Posicionar no proximo registro
      FETCH cr_crapban
        INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        vr_cdcritic := 57;
        vr_dscritic := ' ';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;
      --Selecionar dados titulo
      OPEN cr_dadostitulo(pr_ispbcliente => rw_crapban.nrispbif);
      --Posicionar no proximo registro
      FETCH cr_dadostitulo
        INTO rw_dadostitulo;
      --Se nao encontrar
      IF cr_dadostitulo%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_dadostitulo;
        --Retornar numero inscricao cedente
        pr_nrinsced := 0;
      ELSE
        --Fechar Cursor
        CLOSE cr_dadostitulo;        
      
        --Retornar numero inscricao cedente
        pr_nrinsced := TO_NUMBER(SUBSTR(TO_CHAR(rw_dadostitulo.CNPJCPFBenfcrioOr
                                               ,'fm000000000000000')
                                       ,2
                                       ,14));
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_busca_cedente_DDA. ' ||
                       SQLERRM;
    END;
  END pc_busca_cedente_DDA;

  /* Procedure para verificar se foi sacado do DDA */
  -- A rotina original recebia uma temp table. Em conversa com o analista rafael foi definido que sera
  --   passado sempre apenas um registro de cada vez
  PROCEDURE pc_verifica_sacado_DDA(pr_tppessoa IN VARCHAR2,               -- Tipo de pessoa
                                   pr_nrcpfcgc IN NUMBER,                 -- Cpf ou CNPJ
                                   pr_flgsacad OUT INTEGER,               -- Indicador se foi sacado
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE, -- Codigo de Erro
                                   pr_dscritic OUT VARCHAR2) IS
    -- Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_verifica_sacado_DDA        Antigo: procedures/b1wgen0087.p/verifica-sacado-dda
    --  Sistema  : Procedure para verificacao de saque do DDA
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior - RKAM
    --  Data     : Novembro/2013.                   Ultima atualizacao: 26/01/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para verificacao de saque do DDA
    --
    -- Altera��o : 26/01/2017 - Alterado tabela de consulta.
    --                          PRJ340 - NPC (Odirlei-AMcom)
    --
    --
    ---------------------------------------------------------------------------------------------------------------
  
    --Selecionar dados saque
    CURSOR cr_dadosaque(pr_cnpjcpfpagdr IN NUMBER,
                        pr_tppessoa     IN VARCHAR2) IS
      SELECT tbj."DDASitPagEletr" DDASitPagEletr
            ,tbj."QtdAdesao"      QtdAdesao
        FROM VWJDNPCPAG_PAGADOR_ELETRONICO@JDNPCBISQL  tbj
       WHERE tbj."CNPJCPFPagdr"  = pr_cnpjcpfpagdr
         AND tbj."TpPessoaPagdr" = pr_tppessoa;
           
    rw_dadosaque cr_dadosaque%ROWTYPE;
  
  BEGIN
  
    -- Busca os dados do saque
    OPEN cr_dadosaque(pr_cnpjcpfpagdr => pr_nrcpfcgc,
                      pr_tppessoa     => pr_tppessoa);
    FETCH cr_dadosaque
      INTO rw_dadosaque;
  
    -- Verifica se encontrou dados do saque
    IF cr_dadosaque%FOUND THEN
      IF rw_dadosaque.DDASitPagEletr = 1
         AND rw_dadosaque.QtdAdesao >= 1 THEN
        pr_flgsacad := 1;
      ELSE
        pr_flgsacad := 0;
      END IF;
    ELSE
      pr_flgsacad := 0;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro gerar DDDA0001.pc_verifica_sacado_DDA: ' ||
                     SQLERRM;
  END pc_verifica_sacado_DDA;

  /* Envio de mensagens atraves do site de chegada de novos titulos DDA */
  PROCEDURE pc_chegada_titulos_DDA(pr_cdcooper IN INTEGER -- Codigo cooperativa
                                  ,pr_cdprogra IN VARCHAR2 -- Codigo do programa
                                  ,pr_dtemiini IN DATE -- Data inicial de emissao
                                  ,pr_dtemifim IN DATE -- Data final de emissao
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Codigo de Erro
                                  ,pr_dscritic OUT VARCHAR2) IS
    -- Descricao de Erro
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_chegada_titulos_DDA        Antigo: sistema/generico/procedures/b1wgen0087.p/chegada-titulos-dda
    --  Sistema  : Procedimentos e funcoes da BO b1wgen0087.p
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior - RKAM
    --  Data     : Dezembro/2013.                   Ultima atualizacao: 22/02/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Rotina responsavel pela verificacao de titulos a vencer e envio de mensagens no InternetBank.
    --
    -- Alteracoes: 11/02/2014 - Inicializar variaveis que serao enviadas a tabelas (Gabriel).
    --
    --             05/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir 
    --                          nomenclaturas Cedente por Benefici�rio e  Sacado por Pagador  
    --                          Chamado 229313 (Jean Reddiga - RKAM).
    --                         
    --             20/05/2015 - Alterado para chamar a pc_gerar_mensagem da package GENE0003 e
    --                          n�o mais da pr�pria DDDA ( Renato - Supero )
    --              
    --             22/02/2016 - Ajustado rotina pois procedimento ser� chamado via job todos os dias, 
    --                          alterando filtro de data na busca dos novos titulos, e ajustado mensagem para
    --                          exibir corretamente no Internetbank
    --                          SD388026 (Odirlei-AMcom)               
    ---------------------------------------------------------------------------------------------------------------
  
    /* Busca dos dados do associado */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.inpessoa
            ,crapass.cdagenci
            ,crapass.vllimcre
            ,crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    /* Busca dados do titulo */
    CURSOR cr_dadostitulo(pr_nrispbif IN crapban.nrispbif%TYPE
                         ,pr_dtemiini IN DATE
                         ,pr_dtemifim IN DATE
                         ,pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT pag."CtCliPagdr" ctclipagdr
            ,row_number() over(PARTITION BY pag."CtCliPagdr" ORDER BY pag."CtCliPagdr" ) AS nrcontador
            ,COUNT(1) over(PARTITION BY pag."CtCliPagdr" ) AS qttotreg
            ,tit."NomRzSocBenfcrioOr"   NomRzSocBenfcrioOr
            ,tit."NomRzSocBenfcrioFinl" NomRzSocBenfcrioFinl
            ,tit."NumDoc"               NumDoc
            ,tit."DtVencTit"            DtVencTit
            ,tit."Valor"                Valor
        FROM tbjdnpcrcb_pag_agconta@Jdnpcsql pag
            ,tbjdnpcrcb_tit_dados@jdnpcsql   tit
       WHERE tit."ISPBPartDestinatario" = pr_nrispbif
         AND tit."NumIdentcTit" >= to_char(pr_dtemiini, 'yyyymmdd')||'000000000'
         AND tit."NumIdentcTit" <  to_char(pr_dtemifim, 'yyyymmdd')||'999999999'         
         AND tit."SitTit" = 01 --> Em aberto
         AND pag."AgCliPagdr" = pr_cdagectl
         AND pag."ISPBPrincipal" = tit."ISPBPartDestinatario"
         AND pag."CPFCNPJPagdr" = tit."CNPJCPFPagdr"
       ORDER BY 1
               ,2;
    rw_dadostitulo cr_dadostitulo%ROWTYPE;
  
    -- Variaveis de uso geral
    vr_cdsubitm crapmni.cdsubitm%TYPE := 0;
    vr_cditemmn crapmni.cditemmn%TYPE := 0;
    vr_dsurlcpl VARCHAR2(100) := ' ';
    vr_dsdmensg VARCHAR2(32000) := ' ';
    vr_dscedent VARCHAR2(40) := ' ';
    vr_nrddocto VARCHAR2(14) := ' ';
    vr_dscritic VARCHAR2(500) := ' ';
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
  
  BEGIN
  
    -- Busca os dados da cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    CLOSE cr_crapcop;
  
    -- Busca informacoes do banco
    OPEN cr_crapban(pr_cdbccxlt => rw_crapcop.cdbcoctl);
    FETCH cr_crapban
      INTO rw_crapban;
    CLOSE cr_crapban;
  
    -- Busca informacoes do cadastro de menus utilizados na internet
    OPEN cr_crapmni(pr_cdcooper => pr_cdcooper
                   ,pr_dsurlace => 'dda_pagamento.php'
                   ,pr_cditemmn => NULL);
    FETCH cr_crapmni
      INTO rw_crapmni;
    IF cr_crapmni%FOUND THEN
      CLOSE cr_crapmni;
      vr_cdsubitm := rw_crapmni.cdsubitm;
      vr_cditemmn := rw_crapmni.cditemmn;
    
      -- Busca novamente informacoes de menus utlizados na internet
      OPEN cr_crapmni(pr_cdcooper => pr_cdcooper
                     ,pr_dsurlace => '#'
                     ,pr_cditemmn => rw_crapmni.cditemmn);
      FETCH cr_crapmni
        INTO rw_crapmni;
      IF cr_crapmni%FOUND THEN
        -- monta a variavel de url
        vr_dsurlcpl := '?menu=menu' || rw_crapmni.nrorditm || '%26sub=' ||
                       vr_cdsubitm;
      END IF;
    END IF;
  
    -- Fecha cursor crapmni
    CLOSE cr_crapmni;
  
    -- Efetuar LOOP sobre o cursor de dados do titulo
    FOR rw_dadostitulo IN cr_dadostitulo(pr_nrispbif => rw_crapban.nrispbif
                                        ,pr_dtemiini => pr_dtemiini
                                        ,pr_dtemifim => pr_dtemifim
                                        ,pr_cdagectl => rw_crapcop.cdagectl) LOOP
      -- Se for a primeira repeticao da conta
      IF rw_dadostitulo.nrcontador = 1 THEN
        vr_dsdmensg := '\c' || /* converte espacos para nbsp; */
                       'Aviso de chegada de novos boletos DDA:' || '\n\n' ||
                       'Beneficiario                            ' ||
                       'Documento      ' || 'Vencto     Valor (R$)           \n' ||
                       '----------------------------------------' ||
                       ' --------------' || ' ---------- --------------' || '\n';
      END IF;
    
      -- Busca o nome do cedente
      IF rw_dadostitulo.NomRzSocBenfcrioOr IS NOT NULL THEN
        vr_dscedent := rpad(substr(rw_dadostitulo.NomRzSocBenfcrioOr, 1, 40)
                           ,40
                           ,' ');
      ELSE
        vr_dscedent := rpad(substr(rw_dadostitulo.Nomrzsocbenfcriofinl, 1, 40)
                           ,40
                           ,' ');
      END IF;
    
      -- Atualiza os dados do documento, vencimento e valor
      vr_nrddocto := rpad(rw_dadostitulo.Numdoc, 14, ' ');
      vr_dsdmensg := vr_dsdmensg || vr_dscedent || ' ' || vr_nrddocto || ' ' ||
                     substr(rw_dadostitulo.dtvenctit, 7, 2) || '/' ||
                     substr(rw_dadostitulo.dtvenctit, 5, 2) || '/' ||
                     substr(rw_dadostitulo.dtvenctit, 1, 4) || ' ' ||
                     lpad(to_char(rw_dadostitulo.valor, 'fm999G999G990D00')
                         ,14
                         ,' ') || '\n';
    
      -- Se for o ultimo registro da conta
      IF rw_dadostitulo.nrcontador = rw_dadostitulo.qttotreg THEN
      
        -- Busca os dados do associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => rw_dadostitulo.ctclipagdr);
        FETCH cr_crapass
          INTO rw_crapass;
        CLOSE cr_crapass;
      
        /* ao usar HTML, utilizar %3C = '<', %3E = '>' */
        vr_dsdmensg := vr_dsdmensg || '\n' ||
                       'Acesse o link: %3Ca href=''dda_pagamento.php' ||
                       TRIM(nvl(vr_dsurlcpl, '')) ||
                       '''%3EPagamento DDA%3C/a%3E \n\n';
      
        -- Insere na tabela de mensagens (CRAPMSG)
        GENE0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                  ,pr_idseqttl => 0
                                  , /* Titular */pr_cdprogra => pr_cdprogra
                                  , /* Programa */pr_inpriori => 0
                                  ,pr_dsdmensg => vr_dsdmensg
                                  , /* corpo da mensagem */pr_dsdassun => 'Novo(s) boleto(s) DDA'
                                  , /* Assunto */pr_dsdremet => rw_crapcop.nmrescop
                                  ,pr_dsdplchv => 'Aviso Boletos DDA'
                                  ,pr_cdoperad => 1
                                  ,pr_cdcadmsg => 0
                                  ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      
        -- Se encontrou erro gera o log no arquivo batch
        IF vr_dscritic IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => to_char(sysdate
                                                               ,'hh24:mi:ss') ||
                                                        ' - ' || 'DDDA0001' ||
                                                        ' --> ' ||
                                                        'Conta: ' ||
                                                        rw_crapass.nrdconta ||
                                                        ' Erro ao gerar a mensagem.');
        END IF;
      
      END IF;
    
    END LOOP; -- Final da repeticao do cursor sobre os dados do titulo
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral rotina DDDA0001.pc_chegada_titulos_dda: ' ||
                     SQLERRM;
  END;

  /**
    Popula tt-pagar com os titulos a pagar a partir de R$ 250.000 de todas as
    cooperativas nos proximos 7 dias.
  */
  PROCEDURE pc_titulos_a_pagar(pr_dtvcnini IN DATE
                              ,pr_tt_pagar OUT typ_tab_tt_pagar) IS
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_titulos_a_pagar        Antigo: sistema/generico/procedures/b1wgen0087.p/titulos-a-pagar
    --  Sistema  : Procedimentos e funcoes da BO b1wgen0087.p
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior - RKAM
    --  Data     : Dezembro/2013.                   Ultima atualizacao: 11/02/2014
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Rotina responsavel por popular tt-pagar com os titulos a pagar a partir de R$ 250.000 de
    --             todas as cooperativas nos proximos 7 dias.
    --
    ---------------------------------------------------------------------------------------------------------------
  
    -- Cursor para buscar os titulos a pagar
    CURSOR cr_tt_pagar(pr_dtvcnini DATE, pr_dtvcnfim DATE) IS
      SELECT crapcop.cdcooper
            ,pag."CtCliPagdr" CtCliPagdr
            ,crapcop.nmrescop
            ,tit."CodBarras" CodBarras
            ,tit."DtVencTit" DtVencTit
            ,tit."Valor"     Valor
      
        FROM crapcop
            ,crapban
            ,tbjdnpcrcb_pag_agconta@Jdnpcsql pag
            ,tbjdnpcrcb_tit_dados@Jdnpcsql tit 
       WHERE crapcop.cdcooper <> 3
             AND crapban.cdbccxlt = crapcop.cdbcoctl
         AND tit."ISPBPartDestinatario" = crapban.nrispbif
         AND tit."DtVencTit" >= to_char(pr_dtvcnini, 'yyyymmdd')
         AND tit."DtVencTit" <= to_char(pr_dtvcnfim, 'yyyymmdd')
         AND tit."SitTit" = 01 --> Em aberto
         AND tit."Valor" >= 250000
         AND pag."AgCliPagdr"    = crapcop.cdagectl
         AND pag."ISPBPrincipal" = tit."ISPBPartDestinatario"
         AND pag."CPFCNPJPagdr"  = tit."CNPJCPFPagdr"
       ORDER BY crapcop.nmrescop
               ,tit."DtVencTit";
  
    vr_dtvcnfim DATE;
    vr_index    INTEGER;
  
  BEGIN
    -- Acrescenta 7 dias na data final
    vr_dtvcnfim := pr_dtvcnini + 7;
  
    -- Efetua o cursor sobre os titulos a pagar
    FOR rw_tt_pagar IN cr_tt_pagar(pr_dtvcnini => pr_dtvcnini
                                  ,pr_dtvcnfim => vr_dtvcnfim) LOOP
    
      -- Busca os dados dos associados
      OPEN cr_crapass(pr_cdcooper => rw_tt_pagar.cdcooper
                     ,pr_nrdconta => rw_tt_pagar.CtCliPagdr);
      FETCH cr_crapass
        INTO rw_crapass;
    
      -- Se encontrou o associado
      IF cr_crapass%FOUND THEN
        --Pegar proximo indice de titulos a pagar
        vr_index := pr_tt_pagar.Count + 1;
      
        -- Atualiza a tabela de titulos a pagar;
        pr_tt_pagar(vr_index).nmrescop := rw_tt_pagar.nmrescop;
        pr_tt_pagar(vr_index).cdagenci := rw_crapass.cdagenci;
        pr_tt_pagar(vr_index).nrdconta := rw_crapass.nrdconta;
        pr_tt_pagar(vr_index).cdbarras := rw_tt_pagar.codbarras;
        pr_tt_pagar(vr_index).dtvencto := to_date(rw_tt_pagar.dtvenctit
                                                 ,'yyyymmdd');
        pr_tt_pagar(vr_index).vltitulo := rw_tt_pagar.valor;
      
      END IF;
    
      --Fecha o cursor de associados
      CLOSE cr_crapass;
    END LOOP;
  END pc_titulos_a_pagar;

  /* Procedure para gravar informacoes do DDA na crapgpr */
  PROCEDURE pc_grava_congpr_dda(pr_cdcooper IN INTEGER -- Codigo Cooperativa
                               ,pr_dataini  IN DATE -- Data inicial
                               ,pr_datafim  IN DATE -- Data final
                               ,pr_dtmvtolt IN DATE -- Data de movimentos
                               ,pr_dscritic OUT VARCHAR2) IS
    -- Descricao da critica
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_grava_congpr_dda        Antigo: procedures/b1wgen0087.p/grava-congpr-dda
    --  Sistema  : Procedure para buscar codigo cedente do DDA
    --  Sigla    : CRED
    --  Autor    : Douglas Pagel
    --  Data     : Dezembro/2013.                   Ultima atualizacao: 10/02/2014
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para gravar informacoes do DDA na crapgpr
    --
    -- Alteracoes: 10/02/2014 - Ajuste para correta criacao da crapgpr (Gabriel)
    ---------------------------------------------------------------------------------------------------------------
    /* Cursores Locais */
  
    -- Buscar quantidade de dda por agencia da central
    CURSOR cr_dadosdda(pr_cdagectl IN NUMBER, pr_dtmvtolt IN DATE) IS
      SELECT count(*) as qtcoodda
        FROM tbjdnpcrcb_pag_agconta@Jdnpcsql tbj
       WHERE tbj."AgCliPagdr" = pr_cdagectl
         AND tbj."DtAdesCliPagdrDDA" <= to_char(pr_dtmvtolt, 'yyyymmdd') /* utilizar format YYYYMMDD */
         ;
    rw_dadosdda cr_dadosdda%ROWTYPE;
  
    -- buscas os titulos agrupado por agencia
    CURSOR cr_craptit(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dataini  IN craptit.dtmvtolt%TYPE
                     ,pr_datafim  IN craptit.dtmvtolt%TYPE) IS
      SELECT cdagenci
            ,COUNT(*) qt_registros
            ,SUM(craptit.vldpagto) vldpagto
        FROM craptit
       WHERE craptit.cdcooper = pr_cdcooper
             AND craptit.dtmvtolt >= pr_dataini
             AND craptit.dtmvtolt <= pr_datafim
             AND craptit.flgpgdda = 1
       GROUP BY craptit.cdagenci;
    rw_craptit cr_craptit%ROWTYPE;
  
  BEGIN
  
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
    
      -- Atualiza mensagem de erro para o retorno
      pr_dscritic := gene0001.fn_busca_critica(057);
    
      -- encerra a rotina
      RETURN;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
  
    -- Leitura da tabela de DDA do banco
    OPEN cr_dadosdda(rw_crapcop.cdagectl, pr_dtmvtolt);
    FETCH cr_dadosdda
      INTO rw_dadosdda;
  
    CLOSE cr_dadosdda;
  
    -- Se achou os dados do DDA
    IF rw_dadosdda.qtcoodda > 0 THEN
    
      -- Efetua a atualizacao com base no registro retornado do cursor
      BEGIN
        UPDATE crapgpr
           SET qtcoodda = nvl(rw_dadosdda.qtcoodda, 0)
         WHERE crapgpr.cdcooper = pr_cdcooper
               AND crapgpr.dtrefere = pr_datafim
               AND crapgpr.cdagenci = rw_crapcop.cdagectl
               AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          -- Atualiza campo de erro
          pr_dscritic := 'Erro ao atualizar dados na crapgpr: ' || sqlerrm;
          -- Encerra rotina
          RETURN;
      END;
    
      -- Se nao atualizou, faz o insert
      IF SQL%ROWCOUNT = 0 THEN
        BEGIN
          INSERT INTO crapgpr
            (cdcooper
            ,cdagenci
            ,dtrefere
            ,qtcoodda)
          VALUES
            (pr_cdcooper
            ,rw_crapcop.cdagectl
            ,pr_datafim
            ,nvl(rw_dadosdda.qtcoodda, 0));
        EXCEPTION
          WHEN OTHERS THEN
            -- Atualiza variavel de retorno de erro
            pr_dscritic := 'Erro ao inserir dados na crapgpr: ' || sqlerrm;
            -- Encerra a rotina
            RETURN;
        END;
      END IF;
    END IF;
  
    -- busca pelos titulos
    FOR rw_craptit IN cr_craptit(pr_cdcooper => pr_cdcooper
                                ,pr_dataini  => pr_dataini
                                ,pr_datafim  => pr_datafim) LOOP
      -- Atualiza tabela com base na quantidade de registros
      BEGIN
        UPDATE crapgpr
           SET crapgpr.qtbpgdda = rw_craptit.qt_registros
              ,crapgpr.vlbpgdda = rw_craptit.vldpagto
         WHERE crapgpr.cdagenci = rw_crapcop.cdagectl
               AND crapgpr.cdcooper = pr_cdcooper
               AND crapgpr.dtrefere = pr_datafim
               AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          -- Atualiza variavel de retorno
          pr_dscritic := 'Erro ao atualizar CRAPGPR: ' || SQLERRM;
          -- Encerra rotina
          RETURN;
      END;
    
      -- Se nao encontrou linhas para atualizar, entao efetua o insert
      IF SQL%ROWCOUNT = 0 THEN
        BEGIN
          INSERT INTO crapgpr
            (cdcooper
            ,dtrefere
            ,cdagenci
            ,qtbpgdda
            ,vlbpgdda)
          VALUES
            (pr_cdcooper
            ,pr_datafim
            ,rw_crapcop.cdagectl
            ,rw_craptit.qt_registros
            ,rw_craptit.vldpagto);
        EXCEPTION
          WHEN OTHERS THEN
            -- Atualiza variavel de retorno
            pr_dscritic := 'Erro ao inserir CRAPGPR: ' || SQLERRM;
            -- Encerra rotina
            RETURN;
        END;
      END IF;
    END LOOP; -- Fim da busca pelos titulos
  
  END pc_grava_congpr_dda; /* Procedure para retorno remessa DDA */

  /* Procedure para Executar retorno operacao Titulos DDA */
  PROCEDURE pc_retorno_operacao_tit_DDA(pr_tab_remessa_dda IN DDDA0001.typ_tab_remessa_dda --Remessa dda
                                       ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda --Retorno dda
                                       ,pr_cdcritic        OUT crapcri.cdcritic%type --Codigo de Erro
                                       ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_operacao_tit_DDA    Antigo: procedures/b1wgen0087.p/Retorno-Operacao-Titulos-DDA
    --  Sistema  : PProcedure para Executar retorno operacao Titulos DDA
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 05/02/2014
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Executar retorno operacao Titulos DDA
    --
    -- Alteracoes: 05/02/2014 - Ajuste no fechamento do cursor da cr_craptit (Gabriel)
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      CURSOR cr_craptit(pr_cdlegado IN TBJDDDALEG_JD2LG_OPTITULO.CdLegado@jdddasql%type
                       ,pr_nrispbif IN TBJDDDALEG_JD2LG_OPTITULO.ISPBIF@jdddasql%TYPE
                       ,pr_idtitleg IN TBJDDDALEG_JD2LG_OPTITULO.IdTitLeg@jdddasql%TYPE
                       ,pr_idopeleg IN TBJDDDALEG_JD2LG_OPTITULO.IdOperacaoLeg@jdddasql%type) IS
        SELECT TBJ."ISPBAdministrado" ISPBAdministrado
              ,TBJ."IdOpJD"   IdOpJD
              ,TBJ."DtHrOpJD" DtHrOpJD
              ,TBJ."SitOpJD"  SitOpJD
              ,TBJ."IdTituloLeg" IdTituloLeg
          FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql TBJ
         WHERE TBJ."CdLeg"            = pr_cdlegado
           AND TBJ."ISPBAdministrado" = pr_nrispbif
           AND TBJ."IdTituloLeg"      = pr_idtitleg
           AND TBJ."IdOpLeg"          = pr_idopeleg
         ORDER BY TBJ."DtHrOpJD" DESC;
      rw_craptit cr_craptit%ROWTYPE;
      --Variaveis Locais
      vr_index     INTEGER;
      vr_index_ret INTEGER;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Percorrer todas as remessas
      vr_index := pr_tab_remessa_dda.FIRST;
      WHILE vr_index IS NOT NULL LOOP
      
        --Encontrar Titulo
        OPEN cr_craptit(pr_cdlegado => pr_tab_remessa_dda(vr_index).cdlegado
                       ,pr_nrispbif => pr_tab_remessa_dda(vr_index).nrispbif
                       ,pr_idtitleg => pr_tab_remessa_dda(vr_index).idtitleg
                       ,pr_idopeleg => pr_tab_remessa_dda(vr_index).idopeleg);
        --Posicionar no proximo registro
        FETCH cr_craptit
          INTO rw_craptit;
        --Se encontrar
        IF cr_craptit%FOUND THEN
          --Fechar Cursor
          CLOSE cr_craptit;
          
            -- deletar registro de controle
            BEGIN
              
              DELETE tbjdnpcdstleg_jd2lg_optit_ctrl@jdnpcbisql
               WHERE "ISPBAdministrado"  = rw_craptit.ISPBAdministrado
                 AND "IdOpJD"            = rw_craptit.IdOpJD
                 AND "IdTituloLeg"       = rw_craptit.IdTituloLeg;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao deletar registro tbjdnpcdstleg_jd2lg_optit_ctrl. ' ||
                               'IdOpJD: '||rw_craptit.IdOpJD||' -> '||sqlerrm;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;

          --Criar retorno
          vr_index_ret := pr_tab_retorno_dda.Count + 1;
          pr_tab_retorno_dda(vr_index_ret).idtitleg := pr_tab_remessa_dda(vr_index)
                                                       .idtitleg;
          pr_tab_retorno_dda(vr_index_ret).idopeleg := pr_tab_remessa_dda(vr_index)
                                                       .idopeleg;
        
          CASE rw_craptit.SitOpJD
            WHEN 'PJ' THEN
              /* Recebido JD */
              pr_tab_retorno_dda(vr_index_ret).insitpro := 2;
            WHEN 'RC' THEN
              pr_tab_retorno_dda(vr_index_ret).insitpro := 3;
            WHEN 'EJ' THEN
              pr_tab_retorno_dda(vr_index_ret).insitpro := 4;
            WHEN 'EC' THEN
              pr_tab_retorno_dda(vr_index_ret).insitpro := 4;
            ELSE
              NULL;
          END CASE;
        ELSE
          --Fechar Cursor
          CLOSE cr_craptit;
        END IF;
        --Proximo registro
        vr_index := pr_tab_remessa_dda.NEXT(vr_index);
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_retorno_operacao_tit_DDA. ' ||
                       SQLERRM;
    END;
  END pc_retorno_operacao_tit_DDA;

  --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
  PROCEDURE pc_trata_retorno_erro ( pr_cdcooper       IN  crapcob.cdcooper%TYPE   --> Codigo da cooperativa 
                                   ,pr_tpdopera       IN  VARCHAR2                --> Tipo de operacao
                                   ,pr_idtitleg       IN  crapcob.idtitleg%TYPE   --> Identificador do titulo no legado
                                   ,pr_idopeleg       IN  crapcob.idopeleg%TYPE   --> Identificador da operadao do legado
                                   ,pr_iddopeJD       IN  VARCHAR2) IS            --> Identificador da operadao da JD                                   
                                   
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_trata_retorno_erro  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para tratar as criticas no retorno da CIP-NPC
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> Listar criticas da operacao
    CURSOR cr_optiterr IS
    SELECT err."CdErro"   codderro,
           err."NmColuna" nmcoluna,
           NVL(dsc1."DESCRICAO",dsc2."DSC_ERRO") dsdoerro
      FROM TBJDNPCDSTLEG_JD2LG_OpTit_ERR@Jdnpcbisql err,
           TBJDMSG_ERROGEN@Jdnpcsql dsc1,
           TBJDNPC_ERRO@Jdnpcsql    dsc2
     WHERE err."CdLeg" = 'LEG'
       AND err."IdTituloLeg" = pr_idtitleg
       AND err."IdOpLeg"     = pr_idopeleg
       AND err."IdOpJD"      = pr_iddopejd
       AND err."CdErro"      = dsc1."CODERRO"(+)
       AND err."CdErro"      = dsc2."CD_ERRO"(+); 
    
     ---------->>> VARIAVEIS <<<-----------   
    vr_dscritic   VARCHAR2(2000);   
    vr_dslogmes crapprm.dsvlrprm%TYPE;   
       
  BEGIN
    
    CASE pr_tpdopera
      WHEN 'I' THEN
        vr_dscritic := 'Inclusao';
      WHEN 'A' THEN
        vr_dscritic := 'Alteracao';
      WHEN 'B' THEN
        vr_dscritic := 'Baixa';    
      ELSE        
        vr_dscritic := 'Operacao';
    END CASE;    
  
    vr_dscritic := vr_dscritic ||
                   ' Rejeitada operacao de envio para a CIP ->'||
                   ' idtitleg: '||pr_idtitleg ||
                   ' idopeleg: '||pr_idopeleg ;
    
    --> Listar criticas por campo
    FOR rw_optiterr IN cr_optiterr LOOP
      vr_dscritic := vr_dscritic || chr(10)|| lpad(' ',11,' ')||'DDDA0001 -> ' || 
                     rw_optiterr.nmcoluna||': '|| 
                     rw_optiterr.codderro||' - '||rw_optiterr.dsdoerro;    
    END LOOP;  
    
    
    vr_dslogmes := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');    
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, 
                               pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                  ' - DDDA0001 -> ' || vr_dscritic,
                               pr_nmarqlog     => vr_dslogmes);
  
  END pc_trata_retorno_erro;   
  
  
  --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
  PROCEDURE pc_ret_inclusao_tit_npc ( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                     ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                     ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                     ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informa�cao
                                     ,pr_idtitnpc       IN  crapcob.nrdident%TYPE --> Identificador do titulo na CIP-NPC
                                     ,pr_nratutit       IN  crapcob.nratutit%TYPE --> Identificador do titulo alteracao na CIP-NPC
                                     ,pr_cdcritic      OUT crapcri.cdcritic%type --Codigo de Erro
                                     ,pr_dscritic      OUT VARCHAR2) IS          --Descricao de Erro
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ret_inclusao_tit_npc  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
        FROM crapcob cob
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob cr_crapcob%ROWTYPE;   
       
    ---------->>> VARIAVEIS <<<-----------   
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(200);
    vr_exc_erro   EXCEPTION;
    
    vr_insitpro   crapcob.insitpro%TYPE;
    vr_inenvcip   crapcob.inenvcip%TYPE;
    vr_flgcbdda   crapcob.flgcbdda%TYPE;
    vr_dhenvcip   crapcob.dhenvcip%TYPE;
    vr_dsmensag   crapcol.dslogtit%TYPE;
    
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ � Erro JDNPC
    --> RC � Opera��o registrada na CIP-NPC
    --> EC � Erro na CIP-NPC
    --> IC � Informa��o enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto n�o encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    vr_insitpro := NULL;
    vr_inenvcip := NULL;
    vr_flgcbdda := NULL;
    vr_dhenvcip := NULL;
    vr_dsmensag := NULL;
    
    IF pr_cdstiope = 'PJ' THEN
      vr_insitpro := 2; --> 2-RecebidoJD
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso
      vr_insitpro := 3; --> 3-RC registro CIP
      vr_inenvcip := 3; -- confirmado
      vr_flgcbdda := 1;
      vr_dhenvcip := SYSDATE;
      vr_dsmensag := 'Titulo Registrado - CIP';
    ELSE
      vr_insitpro := 0; --> Sacado comun
      vr_inenvcip := 4; -- Rejeitadp
      vr_flgcbdda := 0;
      vr_dhenvcip := NULL;
      vr_dsmensag := 'Titulo Rejeitado na CIP';
      
    END IF;
    
    --> Atualizar informa��es do boleto
    BEGIN
      UPDATE crapcob cob
         SET cob.insitpro =  nvl(vr_insitpro,cob.insitpro)
           , cob.flgcbdda =  nvl(vr_inenvcip,cob.flgcbdda)
           , cob.inenvcip =  nvl(vr_flgcbdda,cob.inenvcip)
           , cob.dhenvcip =  nvl(vr_dhenvcip,cob.dhenvcip)
           , cob.idtitleg =  nvl(pr_idtitnpc,cob.idtitleg)
           , cob.nratutit =  nvl(pr_nratutit,cob.nratutit)
       WHERE cob.rowid    = rw_crapcob.rowidcob;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    --> Se conter mensagem deve gerar log
    IF vr_dsmensag <> NULL THEN        
      -- Cria o log da cobran�a
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => ' '
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
        RAISE vr_exc_erro;
      END IF;
    
    END IF;  
    
    --> Se for registrado CIP
    IF vr_insitpro = 3 THEN  
      -- Atualizar a CRAPRET
      BEGIN
        UPDATE crapret ret
           SET ret.cdmotivo = 'A4'
         WHERE ret.cdcooper = rw_crapcob.cdcooper 
           AND ret.nrdconta = rw_crapcob.nrdconta 
           AND ret.nrcnvcob = rw_crapcob.nrcnvcob 
           AND ret.nrdocmto = rw_crapcob.nrdocmto 
           AND ret.cdocorre = 2
           AND TRIM(ret.cdmotivo) IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'PC_VERIFICA_TITULOS_DDA: Erro ao atualizar CRAPRET: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
    
    --> Gerar log de rejeicao
    IF pr_cdstiope IN ('EJ','EC') THEN
      pc_trata_retorno_erro ( pr_cdcooper   => rw_crapcob.cdcooper  --> Codigo da cooperativa 
                             ,pr_tpdopera   => 'I'                  --> Tipo de operacao
                             ,pr_idtitleg   => pr_idtitleg          --> Identificador do titulo no legado
                             ,pr_idopeleg   => pr_idopeleg          --> Identificador da operadao do legado
                             ,pr_iddopeJD   => pr_iddopeJD);        --> Identificador da operadao da JD                                   
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel processar retorno de inclusao: '||SQLERRM;  
  END pc_ret_inclusao_tit_npc;
  
   --> Procedure para processar o retorno de altera��o do titulo do NPC-CIP
  PROCEDURE pc_ret_alteracao_tit_npc( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                     ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                     ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                     ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informa�cao
                                     ,pr_idtitnpc       IN  crapcob.nrdident%TYPE --> Identificador do titulo na CIP-NPC
                                     ,pr_nratutit       IN  crapcob.nratutit%TYPE --> Identificador do titulo alteracao na CIP-NPC
                                     ,pr_cdcritic      OUT crapcri.cdcritic%type --Codigo de Erro
                                     ,pr_dscritic      OUT VARCHAR2) IS          --Descricao de Erro
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ret_alteracao_tit_npc  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de alteracao do titulo do NPC-CIP
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
        FROM crapcob cob
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob cr_crapcob%ROWTYPE;   
       
    ---------->>> VARIAVEIS <<<-----------   
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(200);
    vr_exc_erro   EXCEPTION;
    
    vr_insitpro   crapcob.insitpro%TYPE;
    vr_inenvcip   crapcob.inenvcip%TYPE;
    vr_flgcbdda   crapcob.flgcbdda%TYPE;
    vr_dhenvcip   crapcob.dhenvcip%TYPE;
    vr_dsmensag   crapcol.dslogtit%TYPE;
    
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ � Erro JDNPC
    --> RC � Opera��o registrada na CIP-NPC
    --> EC � Erro na CIP-NPC
    --> IC � Informa��o enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto n�o encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    
    IF pr_cdstiope = 'PJ' THEN
      NULL;
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso      
      vr_dsmensag := 'Altera��o de Titulo Registrado - CIP';
      
      --> Atualizar informa��es do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;            
    ELSIF pr_cdstiope IN ('EJ','EC') THEN
      vr_dsmensag := 'Altera��o de Titulo Rejeitado na CIP';      
    END IF;       
        
    --> Se conter mensagem deve gerar log
    IF vr_dsmensag <> NULL THEN        
      -- Cria o log da cobran�a
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => ' '
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
        RAISE vr_exc_erro;
      END IF;
    
    END IF;  
    
    --> Gerar log de rejeicao
    IF pr_cdstiope IN ('EJ','EC') THEN
      pc_trata_retorno_erro ( pr_cdcooper   => rw_crapcob.cdcooper  --> Codigo da cooperativa 
                             ,pr_tpdopera   => 'A'                  --> Tipo de operacao
                             ,pr_idtitleg   => pr_idtitleg          --> Identificador do titulo no legado
                             ,pr_idopeleg   => pr_idopeleg          --> Identificador da operadao do legado
                             ,pr_iddopeJD   => pr_iddopeJD);        --> Identificador da operadao da JD                                   
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel processar retorno de alteracao: '||SQLERRM;  
  END pc_ret_alteracao_tit_npc;
  
   --> Procedure para processar o retorno de baixa do titulo do NPC-CIP
  PROCEDURE pc_ret_baixa_tit_npc( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                 ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                 ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                 ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informa�cao
                                 ,pr_idtitnpc       IN  crapcob.nrdident%TYPE --> Identificador do titulo na CIP-NPC
                                 ,pr_nratutit       IN  crapcob.nratutit%TYPE --> Identificador do titulo alteracao na CIP-NPC
                                 ,pr_cdcritic      OUT crapcri.cdcritic%type --Codigo de Erro
                                 ,pr_dscritic      OUT VARCHAR2) IS          --Descricao de Erro
  
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ret_baixa_tit_npc  
    --  Sistema  : DDDA
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de baixa do titulo do NPC-CIP
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
        FROM crapcob cob
       WHERE cob.idtitleg = pr_idtitleg;
    rw_crapcob cr_crapcob%ROWTYPE;   
       
    ---------->>> VARIAVEIS <<<-----------   
    vr_cdcritic   INTEGER;
    vr_dscritic   VARCHAR2(2000);
    vr_des_erro   VARCHAR2(200);
    vr_exc_erro   EXCEPTION;
    
    vr_insitpro   crapcob.insitpro%TYPE;
    vr_inenvcip   crapcob.inenvcip%TYPE;
    vr_flgcbdda   crapcob.flgcbdda%TYPE;
    vr_dhenvcip   crapcob.dhenvcip%TYPE;
    vr_dsmensag   crapcol.dslogtit%TYPE;
    
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ � Erro JDNPC
    --> RC � Opera��o registrada na CIP-NPC
    --> EC � Erro na CIP-NPC
    --> IC � Informa��o enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto n�o encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    
    IF pr_cdstiope = 'PJ' THEN
      NULL;
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso      
      vr_dsmensag := 'Baixa de Titulo Registrado - CIP';                   
    ELSIF pr_cdstiope IN ('EJ','EC') THEN
      vr_dsmensag := 'Baixa de Titulo Rejeitado na CIP';      
    END IF;       
        
    --> Se conter mensagem deve gerar log
    IF vr_dsmensag <> NULL THEN        
      -- Cria o log da cobran�a
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => ' '
                                   ,pr_dtmvtolt => SYSDATE
                                   ,pr_dsmensag => vr_dsmensag
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
            
      -- Se ocorrer erro
      IF vr_des_erro <> 'OK' THEN        
        RAISE vr_exc_erro;
      END IF;
    
    END IF;  
    
    --> Gerar log de rejeicao
    IF pr_cdstiope IN ('EJ','EC') THEN
      pc_trata_retorno_erro ( pr_cdcooper   => rw_crapcob.cdcooper  --> Codigo da cooperativa 
                             ,pr_tpdopera   => 'B'                  --> Tipo de operacao
                             ,pr_idtitleg   => pr_idtitleg          --> Identificador do titulo no legado
                             ,pr_idopeleg   => pr_idopeleg          --> Identificador da operadao do legado
                             ,pr_iddopeJD   => pr_iddopeJD);        --> Identificador da operadao da JD                                   
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel processar retorno de baixa: '||SQLERRM;  
  END pc_ret_baixa_tit_npc;
  
  /* Procedure para Executar retorno operacao Titulos NPC */
  PROCEDURE pc_retorno_operacao_tit_NPC(pr_cdcritic        OUT crapcri.cdcritic%type --Codigo de Erro
                                       ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_operacao_tit_NPC    Antigo: procedures/b1wgen0087.p/Retorno-Operacao-Titulos-DDA
    --  Sistema  : PProcedure para Executar retorno operacao Titulos NPC
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Executar retorno operacao Titulos NPC
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    --> Buscar retornos 
    CURSOR cr_retnpc (pr_cdlegado IN TBJDDDALEG_JD2LG_OPTITULO.CdLegado@jdddasql%type
                     ,pr_nrispbif IN TBJDDDALEG_JD2LG_OPTITULO.ISPBIF@jdddasql%TYPE) IS
      SELECT tit."ISPBAdministrado" AS nrispbif
            ,tit."TpOpJD"           AS tpoperac
            ,tit."IdOpJD"           AS idoperac
            ,tit."DtHrOpJD"         AS dhoperac
            ,tit."SitOpJD"          AS cdstiope
            ,tit."IdTituloLeg"      AS idtitleg
            ,tit."NumIdentcTit"     AS idtitnpc
            ,tit."IdOpLeg"          AS idopeleg
            ,tit."IdOpJD"           AS iddopeJD
            ,tit."NumRefAtlCadTit"  AS nratutit
        FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql tit,
             tbjdnpcdstleg_jd2lg_optit_ctrl@jdnpcbisql ctl 
       WHERE ctl."ISPBAdministrado" = tit."ISPBAdministrado"
         AND ctl."IdOpJD"           = tit."IdOpJD"
         AND ctl."IdTituloLeg"      = tit."IdTituloLeg"
         AND tit."CdLeg"            = pr_cdlegado
         AND tit."ISPBAdministrado" = pr_nrispbif
       ORDER BY tit."DtHrOpJD" DESC;
    rw_retnpc cr_retnpc%ROWTYPE;
      
      
    --Variaveis Locais
    vr_index     INTEGER;
    vr_index_ret INTEGER;
    --Variaveis Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis Excecao
    vr_exc_erro EXCEPTION;
    
    vr_dslogmes VARCHAR2(200);
      
  BEGIN
  
    vr_dslogmes := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');    
  
    --> buscar retornos disponibilizados
    FOR rw_retnpc IN cr_retnpc(pr_cdlegado => 'LEG'
                              ,pr_nrispbif => '5463212' ) LOOP
                  
      CASE rw_retnpc.tpoperac
        WHEN 'RI' THEN --> Retorno Inclusao          
          --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
          pc_ret_inclusao_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                   ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                   ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                   ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informa�cao
                                   ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                   ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                   ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                   ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                   
        WHEN 'RA' THEN --> Retorno Altera��o

          pc_ret_alteracao_tit_npc (pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                   ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                   ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                   ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informa�cao
                                   ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                   ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                   ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                   ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
        WHEN 'RB' THEN --> Retorno Baixa
           pc_ret_baixa_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                 ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                 ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                 ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informa�cao
                                 ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                 ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                 ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                 ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                 
        WHEN 'CO' THEN --> Cancelamento da Baixa Operacional enviada pelo Banco Recebedor
          --> Ac�o ainda nao definida, ser� programada em segunda etapa
          continue;
        WHEN 'JB' THEN --> Baixa Efetiva feita diretamente no JDNPC(Conting�ncia)
          --> Ac�o ainda nao definida, ser� programada em segunda etapa
          continue;
        WHEN 'DP' THEN --> Baixa por Decurso de Prazo
          --> Ac�o ainda nao definida, ser� programada em segunda etapa
          continue;        
        ELSE
          -- Demais tipos de operacao ser�o ignoradas
          continue;
      END CASE;    
      
      --> verificar se transacao apresentou erro
      IF nvl(vr_cdcritic,0) > 0 OR
         vr_dscritic IS NOT NULL THEN         
        ROLLBACK;
        
        vr_dscritic := 'Erro ao processar retorno idtitleg: '||rw_retnpc.idtitleg||' -> '||
                       vr_dscritic;
                  
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, 
                                   pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                  ' - DDDA0001 -> ' || vr_dscritic,
                                   pr_nmarqlog     => vr_dslogmes);
         
         continue;
      END IF; 
      
      
      -- deletar registro de controle
     /* BEGIN
              
        DELETE tbjdnpcdstleg_jd2lg_optit_ctrl@jdnpcbisql
         WHERE "ISPBAdministrado"  = rw_retnpc.nrispbif
           AND "IdOpJD"            = rw_retnpc.iddopeJD
           AND "IdTituloLeg"       = rw_retnpc.idtitleg;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar registro tbjdnpcdstleg_jd2lg_optit_ctrl. ' ||
                         'IdOpJD: '||rw_retnpc.iddopeJD||' -> '||sqlerrm;
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2, 
                                   pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                  ' - DDDA0001 -> ' || vr_dscritic,
                                   pr_nmarqlog     => vr_dslogmes);
         
         ROLLBACK;
         continue;
      END;*/
      
      -- Commitar registro processado
     -- COMMIT;    
      
    END LOOP;              
    
  
  END pc_retorno_operacao_tit_NPC;

  /* Retorno da remessa da t�tulos da DDA */
  PROCEDURE pc_remessa_titulos_dda(pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda --Remessa dda
                                  ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda --Retorno dda
                                  ,pr_cdcritic        OUT crapcri.cdcritic%type --Codigo de Erro
                                  ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_remessa_titulos_dda    Antigo: procedures/b1wgen0087.p/remessa-titulos-DDA
    --  Sistema  : Procedure para retorno remessa DDA
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 15/10/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para retorno remessa DDA
    --
    -- Alteracoes: Validacao para verificar data da cabine se eh a mesma do
    --             sistema (Tiago SD1128)
    --
    --             15/10/2015 - Alterado para realizar o substr das informa��es a serem inseridas 
    --                          na tabela TBJDDDALEG_LG2JD_OPTITULO, conforme o tamanho da tabela no SQLServer
    --                          para assim o registro n�o ser rejeitado no momento do insert SD343420  (Odirlei-AMcom)
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
    
      CURSOR cr_abertura IS
        SELECT MAX("DataMov") datamov
          FROM TBJDDDA_CTRL_ABERTURA@jdddasql
         WHERE "ISPBCliente" = 5463212;
    
      rw_abertura cr_abertura%ROWTYPE;
    
      --Variaveis Locais
      vr_index INTEGER;
      vr_data  VARCHAR2(20) := To_Char(SYSDATE, 'YYYYMMDDHH24MISS');      
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      vr_flg_erro BOOLEAN := FALSE;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      OPEN cr_abertura;
      FETCH cr_abertura
        INTO rw_abertura;
    
      IF cr_abertura%FOUND THEN
      
        IF to_number(to_char(SYSDATE, 'YYYYMMDD')) <> rw_abertura.datamov THEN
          vr_data := to_char(rw_abertura.datamov)||'235900';
        END IF;
      
        CLOSE cr_abertura;
      
      ELSE
        CLOSE cr_abertura;
      END IF;
    
      --Percorrer as remessas
      vr_index := pr_tab_remessa_dda.FIRST;
      WHILE vr_index IS NOT NULL LOOP
        
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
                
        pr_tab_remessa_dda(vr_index).nrispbif := substr(pr_tab_remessa_dda(vr_index).nrispbif,1,8);
        pr_tab_remessa_dda(vr_index).cdlegado := substr(pr_tab_remessa_dda(vr_index).cdlegado,1,5);
        pr_tab_remessa_dda(vr_index).idopeleg := substr(pr_tab_remessa_dda(vr_index).idopeleg,1,20);
        pr_tab_remessa_dda(vr_index).idtitleg := substr(pr_tab_remessa_dda(vr_index).idtitleg,1,32);
        pr_tab_remessa_dda(vr_index).tpoperad := substr(pr_tab_remessa_dda(vr_index).tpoperad,1,1);


        pr_tab_remessa_dda(vr_index).cdifdced := substr(pr_tab_remessa_dda(vr_index).cdifdced,1,3);
        pr_tab_remessa_dda(vr_index).tppesced := substr(pr_tab_remessa_dda(vr_index).tppesced,1,1);
        pr_tab_remessa_dda(vr_index).nrdocced := substr(pr_tab_remessa_dda(vr_index).nrdocced,1,14);
        pr_tab_remessa_dda(vr_index).nmdocede := substr(pr_tab_remessa_dda(vr_index).nmdocede,1,80);
        pr_tab_remessa_dda(vr_index).cdageced := substr(pr_tab_remessa_dda(vr_index).cdageced,1,4);
        pr_tab_remessa_dda(vr_index).nrctaced := substr(pr_tab_remessa_dda(vr_index).nrctaced,1,13);
        pr_tab_remessa_dda(vr_index).tppesori := substr(pr_tab_remessa_dda(vr_index).tppesori,1,1);
        pr_tab_remessa_dda(vr_index).nrdocori := substr(pr_tab_remessa_dda(vr_index).nrdocori,1,14);
        pr_tab_remessa_dda(vr_index).nmdoorig := substr(pr_tab_remessa_dda(vr_index).nmdoorig,1,80);
        pr_tab_remessa_dda(vr_index).tppessac := substr(pr_tab_remessa_dda(vr_index).tppessac,1,1);
        pr_tab_remessa_dda(vr_index).nrdocsac := substr(pr_tab_remessa_dda(vr_index).nrdocsac,1,14);
        pr_tab_remessa_dda(vr_index).nmdosaca := substr(pr_tab_remessa_dda(vr_index).nmdosaca,1,80);
        pr_tab_remessa_dda(vr_index).dsendsac := substr(pr_tab_remessa_dda(vr_index).dsendsac,1,40);
        pr_tab_remessa_dda(vr_index).dscidsac := substr(pr_tab_remessa_dda(vr_index).dscidsac,1,50);
        pr_tab_remessa_dda(vr_index).dsufsaca := substr(pr_tab_remessa_dda(vr_index).dsufsaca,1,2);
        pr_tab_remessa_dda(vr_index).Nrcepsac := substr(pr_tab_remessa_dda(vr_index).Nrcepsac,1,8);
        pr_tab_remessa_dda(vr_index).tpdocava := substr(pr_tab_remessa_dda(vr_index).tpdocava,1,2);
        pr_tab_remessa_dda(vr_index).nrdocava := pr_tab_remessa_dda(vr_index).nrdocava;
        pr_tab_remessa_dda(vr_index).nmdoaval := substr(pr_tab_remessa_dda(vr_index).nmdoaval,1,80);
        pr_tab_remessa_dda(vr_index).cdcartei := substr(pr_tab_remessa_dda(vr_index).cdcartei,1,1);
        pr_tab_remessa_dda(vr_index).cddmoeda := substr(pr_tab_remessa_dda(vr_index).cddmoeda,1,2);
        pr_tab_remessa_dda(vr_index).dsnosnum := substr(pr_tab_remessa_dda(vr_index).dsnosnum,1,100);
        pr_tab_remessa_dda(vr_index).dscodbar := substr(pr_tab_remessa_dda(vr_index).dscodbar,1,44);
        pr_tab_remessa_dda(vr_index).dtvencto := substr(pr_tab_remessa_dda(vr_index).dtvencto,1,8);
        pr_tab_remessa_dda(vr_index).vlrtitul := pr_tab_remessa_dda(vr_index).vlrtitul;
        pr_tab_remessa_dda(vr_index).nrddocto := substr(pr_tab_remessa_dda(vr_index).nrddocto,1,15);
        pr_tab_remessa_dda(vr_index).cdespeci := substr(pr_tab_remessa_dda(vr_index).cdespeci,1,2);
        pr_tab_remessa_dda(vr_index).dtemissa := pr_tab_remessa_dda(vr_index).dtemissa;
        pr_tab_remessa_dda(vr_index).nrdiapro := substr(pr_tab_remessa_dda(vr_index).nrdiapro,1,6);
        pr_tab_remessa_dda(vr_index).tpdepgto := substr(pr_tab_remessa_dda(vr_index).tpdepgto,1,3);
        pr_tab_remessa_dda(vr_index).indnegoc := substr(pr_tab_remessa_dda(vr_index).indnegoc,1,1);
        pr_tab_remessa_dda(vr_index).vlrabati := pr_tab_remessa_dda(vr_index).vlrabati;
        pr_tab_remessa_dda(vr_index).dtdjuros := pr_tab_remessa_dda(vr_index).dtdjuros;
        pr_tab_remessa_dda(vr_index).dsdjuros := substr(pr_tab_remessa_dda(vr_index).dsdjuros,1,1);
        pr_tab_remessa_dda(vr_index).vlrjuros := pr_tab_remessa_dda(vr_index).vlrjuros;
        pr_tab_remessa_dda(vr_index).dtdmulta := pr_tab_remessa_dda(vr_index).dtdmulta;
        pr_tab_remessa_dda(vr_index).cddmulta := substr(pr_tab_remessa_dda(vr_index).cddmulta,1,1);
        pr_tab_remessa_dda(vr_index).vlrmulta := pr_tab_remessa_dda(vr_index).vlrmulta;
        pr_tab_remessa_dda(vr_index).flgaceit := substr(pr_tab_remessa_dda(vr_index).flgaceit,1,1);
        pr_tab_remessa_dda(vr_index).dtddesct := pr_tab_remessa_dda(vr_index).dtddesct;
        pr_tab_remessa_dda(vr_index).cdddesct := substr(pr_tab_remessa_dda(vr_index).cdddesct,1,1);
        pr_tab_remessa_dda(vr_index).vlrdesct := pr_tab_remessa_dda(vr_index).vlrdesct;
        pr_tab_remessa_dda(vr_index).dsinstru := pr_tab_remessa_dda(vr_index).dsinstru;
        pr_tab_remessa_dda(vr_index).dtlipgto := pr_tab_remessa_dda(vr_index).dtlipgto;
        pr_tab_remessa_dda(vr_index).tpdBaixa := substr(pr_tab_remessa_dda(vr_index).tpdBaixa,1,1);
        pr_tab_remessa_dda(vr_index).tpmodcal := substr(pr_tab_remessa_dda(vr_index).tpmodcal,1,2);
        pr_tab_remessa_dda(vr_index).flavvenc := substr(pr_tab_remessa_dda(vr_index).flavvenc,1,1) ;  
        
        --> Indicador de pagto divergente
        CASE pr_tab_remessa_dda(vr_index).inpagdiv
          WHEN 0 THEN --> 0-nao autoriza
            pr_tab_remessa_dda(vr_index).inpagdiv := 3; --> 3-N�o aceitar pagamento com o valor divergente
          WHEN 1 THEN --> 1-autoriza com valor minimo
            pr_tab_remessa_dda(vr_index).inpagdiv := 2; --> 2-Entre o m�nimo e o m�ximo
          WHEN 2 THEN -->  2-qualquer valor maior que zero
            pr_tab_remessa_dda(vr_index).inpagdiv := 1; --> 1-Qualquer Valor
        END CASE;   
        
        IF nvl(pr_tab_remessa_dda(vr_index).vlminimo,0) > 0 THEN
          pr_tab_remessa_dda(vr_index).tpvlmini := 'V';
        ELSE
          pr_tab_remessa_dda(vr_index).tpvlmini := NULL;
          pr_tab_remessa_dda(vr_index).vlminimo := NULL;
        END IF;
        
        
        IF pr_tab_remessa_dda(vr_index).dtbloque IS NULL THEN
          pr_tab_remessa_dda(vr_index).idbloque := 'N';
        ELSE
          pr_tab_remessa_dda(vr_index).idbloque := 'S';
        END IF; 
        
        --> Gerar linha digitavel
        cobr0005.pc_calc_linha_digitavel(pr_cdbarras => pr_tab_remessa_dda(vr_index).dscodbar , 
                                         pr_lindigit => pr_tab_remessa_dda(vr_index).dslindig);
         
        pr_tab_remessa_dda(vr_index).dslindig := REPLACE(REPLACE(pr_tab_remessa_dda(vr_index).dslindig,'.'),' ');
        

        IF pr_tab_remessa_dda(vr_index).tpoperad = 'B' THEN
          pr_tab_remessa_dda(vr_index).dhdbaixa   := to_char(SYSDATE,'RRRRMMDDHH24MISS');
          pr_tab_remessa_dda(vr_index).dtdbaixa   := to_char(SYSDATE,'RRRRMMDD');
        END IF;
        

        BEGIN
        
          INSERT INTO TBJDNPCDSTLEG_LG2JD_OPTIT@jdnpcbisql
            (TBJDNPCDSTLEG_LG2JD_OPTIT."CdLeg"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IdTituloLeg"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IdOpLeg"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."ISPBAdministrado"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."ISPBPrincipal"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpOperacao"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtHrOperacao"
            --> Beneficiario
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpPessoaBenfcrioOr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CNPJCPFBenfcrioOr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomRzSocBenfcrioOr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomFantsBenefcrioOr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."LogradBenefcrioOr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CidBenefcrioOr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."UFBenefcrioOr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CEPBenefcrioOr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpPessoaBenfcrioFinl"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CNPJCPFBenfcrioFinl"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomRzSocBenfcrioFinl"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomFantsBenfcrioFinl"
            --> PAGADOR
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpPessoaPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CNPJCPFPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomRzSocPagdr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomFantsPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."LogradPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CidPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."UFPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CEPPagdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpIdentcSacdrAvalst"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IdentcSacdrAvalst"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomRzSocSacdrAvalst"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodCarteira"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodMoedaCNAB"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NossoNum"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodBarras"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumLinhaDigtvl"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtVencTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."Valor"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumDoc"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodEspecie"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtEmissao"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."QtdDiasProtesto"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtLimPgto"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpPgto"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumParcl"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."QtdTotParcl"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IndrTitNegcd"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IndrBloqPgto"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IndrPgtoParcl"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."QtdPgtoParcl"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrAbatimento"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtJuros"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodJuros"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercJuros"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtMulta"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodMulta"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercMulta"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtDesconto1"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CdDesconto1"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercDesc1"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtDesconto2"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CdDesconto2"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercDesc2"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtDesconto3"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CdDesconto3"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercDesc3"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IndrNotaFisc"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpVlrPercMinTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercMinTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpVlrPercMaxTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrPercMaxTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpModeloCalculo"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpAutRecebtVlrDivegte"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."IndrCalculo"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."TxInfBenefcrio"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumIdentcTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumRefAtlCadTit"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumSeqAtlzCadTit"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."TpBaixaEft"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."ISPBPartRecbdr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodPartRecbdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtHrProcBaixaEft"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtProcBaixaEft"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrBaixaEft"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."CanPgto"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."MeioPagto"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumIdentBOpr"
            --> ,TBJDNPCDSTLEG_LG2JD_OPTIT."NumRefAtlBaixaEft"
            )
            
          VALUES
            (pr_tab_remessa_dda(vr_index).cdlegado               --> CdLeg
            ,pr_tab_remessa_dda(vr_index).idtitleg               --> IdTituloLeg
            ,pr_tab_remessa_dda(vr_index).idopeleg               --> IdOpLeg
            ,pr_tab_remessa_dda(vr_index).nrispbif               --> ISPBAdministrado
            ,pr_tab_remessa_dda(vr_index).nrispbif               --> ISPBPrincipal
            ,pr_tab_remessa_dda(vr_index).tpoperad               --> TpOperacao
            ,vr_data                                             --> DtHrOperacao                                     
            --> BENEFINIARIO
            ,pr_tab_remessa_dda(vr_index).tppesced               --> TpPessoaBenfcrioOr
            ,pr_tab_remessa_dda(vr_index).nrdocced               --> CNPJCPFBenfcrioOr
            ,pr_tab_remessa_dda(vr_index).nmdocede               --> NomRzSocBenfcrioOr
            --> ,pr_tab_remessa_dda(vr_index).               --> NomFantsBenefcrioOr
            --> ,pr_tab_remessa_dda(vr_index).               --> LogradBenefcrioOr
            --> ,pr_tab_remessa_dda(vr_index).               --> CidBenefcrioOr
            --> ,pr_tab_remessa_dda(vr_index).               --> UFBenefcrioOr
            --> ,pr_tab_remessa_dda(vr_index).               --> CEPBenefcrioOr
            --> ,pr_tab_remessa_dda(vr_index).               --> TpPessoaBenfcrioFinl
            --> ,pr_tab_remessa_dda(vr_index).               --> CNPJCPFBenfcrioFinl
            --> ,pr_tab_remessa_dda(vr_index).               --> NomRzSocBenfcrioFinl
            --> ,pr_tab_remessa_dda(vr_index).               --> NomFantsBenfcrioFinl
            --> PAGADOR
            ,pr_tab_remessa_dda(vr_index).tppessac               --> TpPessoaPagdr
            ,pr_tab_remessa_dda(vr_index).nrdocsac               --> CNPJCPFPagdr
            ,pr_tab_remessa_dda(vr_index).nmdosaca               --> NomRzSocPagdr
            --> ,pr_tab_remessa_dda(vr_index).               --> NomFantsPagdr
            ,pr_tab_remessa_dda(vr_index).dsendsac               --> LogradPagdr
            ,pr_tab_remessa_dda(vr_index).dscidsac               --> CidPagdr
            ,pr_tab_remessa_dda(vr_index).dsufsaca               --> UFPagdr
            ,pr_tab_remessa_dda(vr_index).Nrcepsac               --> CEPPagdr
            ,pr_tab_remessa_dda(vr_index).tpdocava               --> TpIdentcSacdrAvalst
            ,pr_tab_remessa_dda(vr_index).nrdocava               --> IdentcSacdrAvalst
            ,pr_tab_remessa_dda(vr_index).nmdoaval               --> NomRzSocSacdrAvalst
            ,pr_tab_remessa_dda(vr_index).cdcartei               --> CodCarteira
            ,pr_tab_remessa_dda(vr_index).cddmoeda               --> CodMoedaCNAB
            ,pr_tab_remessa_dda(vr_index).dsnosnum               --> NossoNum
            ,pr_tab_remessa_dda(vr_index).dscodbar               --> CodBarras
            ,pr_tab_remessa_dda(vr_index).dslindig               --> NumLinhaDigtvl
            ,pr_tab_remessa_dda(vr_index).dtvencto               --> DtVencTit
            ,pr_tab_remessa_dda(vr_index).vlrtitul               --> Valor
            ,pr_tab_remessa_dda(vr_index).nrddocto               --> NumDoc
            ,pr_tab_remessa_dda(vr_index).cdespeci               --> CodEspecie
            ,pr_tab_remessa_dda(vr_index).dtemissa               --> DtEmissao
            ,pr_tab_remessa_dda(vr_index).nrdiapro               --> QtdDiasProtesto
            --> ,pr_tab_remessa_dda(vr_index).               --> DtLimPgto
            ,pr_tab_remessa_dda(vr_index).tpdepgto               --> TpPgto
            --> ,pr_tab_remessa_dda(vr_index).               --> NumParcl
            --> ,pr_tab_remessa_dda(vr_index).               --> QtdTotParcl
            ,pr_tab_remessa_dda(vr_index).indnegoc               --> IndrTitNegcd
            ,pr_tab_remessa_dda(vr_index).idbloque               --> IndrBloqPgto
            ,'N'                                             --> IndrPgtoParcl
            --> ,pr_tab_remessa_dda(vr_index).               --> QtdPgtoParcl
            ,pr_tab_remessa_dda(vr_index).vlrabati               --> VlrAbatimento
            ,pr_tab_remessa_dda(vr_index).dtdjuros               --> DtJuros
            ,pr_tab_remessa_dda(vr_index).dsdjuros               --> CodJuros
            ,pr_tab_remessa_dda(vr_index).vlrjuros               --> VlrPercJuros
            ,pr_tab_remessa_dda(vr_index).dtdmulta               --> DtMulta
            ,pr_tab_remessa_dda(vr_index).cddmulta                --> CodMulta
            ,pr_tab_remessa_dda(vr_index).vlrmulta                --> VlrPercMulta
            ,pr_tab_remessa_dda(vr_index).dtddesct   --> DtDesconto1
            ,pr_tab_remessa_dda(vr_index).cdddesct   --> CdDesconto1
            ,pr_tab_remessa_dda(vr_index).vlrdesct   --> VlrPercDesc1
            --> ,pr_tab_remessa_dda(vr_index).   --> DtDesconto2
            --> ,pr_tab_remessa_dda(vr_index).   --> CdDesconto2
            --> ,pr_tab_remessa_dda(vr_index).   --> VlrPercDesc2
            --> ,pr_tab_remessa_dda(vr_index).   --> DtDesconto3
            --> ,pr_tab_remessa_dda(vr_index).   --> CdDesconto3
            --> ,pr_tab_remessa_dda(vr_index).   --> VlrPercDesc3
            ,'N'                                     --> IndrNotaFisc
            ,pr_tab_remessa_dda(vr_index).tpvlmini               --> TpVlrPercMinTit
            ,pr_tab_remessa_dda(vr_index).vlminimo   --> VlrPercMinTit
            ,'V' /*v-valor*/                         --> TpVlrPercMaxTit
            ,pr_tab_remessa_dda(vr_index).vlrtitul   --> VlrPercMaxTit
            ,pr_tab_remessa_dda(vr_index).tpmodcal   --> TpModeloCalculo
            ,pr_tab_remessa_dda(vr_index).inpagdiv   --> TpAutRecebtVlrDivegte
            ,'N'                                     --> IndrCalculo
            --> ,pr_tab_remessa_dda(vr_index).   --> TxInfBenefcrio
            ,pr_tab_remessa_dda(vr_index).nrdident               --> NumIdentcTit
            ,pr_tab_remessa_dda(vr_index).nratutit               --> NumRefAtlCadTit
            --> ,pr_tab_remessa_dda(vr_index).   --> NumSeqAtlzCadTit
            ,pr_tab_remessa_dda(vr_index).tpdBaixa               --> TpBaixaEft
            ,pr_tab_remessa_dda(vr_index).nrispbrc               --> ISPBPartRecbdr
            --> ,pr_tab_remessa_dda(vr_index).   --> CodPartRecbdr
            ,pr_tab_remessa_dda(vr_index).dhdbaixa               --> DtHrProcBaixaEft
            ,pr_tab_remessa_dda(vr_index).dtdbaixa               --> DtProcBaixaEft
            --> ,pr_tab_remessa_dda(vr_index).   --> VlrBaixaEft
            --> ,pr_tab_remessa_dda(vr_index).   --> CanPgto
            --> ,pr_tab_remessa_dda(vr_index).   --> MeioPagto
            --> ,pr_tab_remessa_dda(vr_index).   --> NumIdentBOpr
            --> ,pr_tab_remessa_dda(vr_index).   --> NumRefAtlBaixaEft
            );
            
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela TBJDNPCDSTLEG_LG2JD_OPTIT. ' ||
                           sqlerrm;
            pr_tab_remessa_dda(vr_index).cdcritic := vr_cdcritic;
            pr_tab_remessa_dda(vr_index).dscritic := vr_dscritic;                           
            
            --Levantar Excecao
            vr_flg_erro := TRUE;
        END;
        
        
        IF vr_flg_erro = FALSE THEN
        -- Inserir na tabela de controle
        BEGIN
          INSERT INTO TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL@jdnpcbisql
                 ( TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL."CdLeg"
                  ,TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL."IdTituloLeg"
                  ,TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL."IdOpLeg"
                  ,TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL."ISPBAdministrado"
                  ,TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL."EnvioImediato")
           VALUES( pr_tab_remessa_dda(vr_index).cdlegado        --> CdLeg
                  ,pr_tab_remessa_dda(vr_index).idtitleg        --> IdTituloLeg
                  ,pr_tab_remessa_dda(vr_index).idopeleg        --> IdOpLeg
                  ,pr_tab_remessa_dda(vr_index).nrispbif        --> ISPBAdministrado
                  ,pr_tab_remessa_dda(vr_index).flonline);      --> EnvioImediato
        
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela TBJDNPCDSTLEG_LG2JD_OPTIT_CTRL. '||SQLERRM;

            pr_tab_remessa_dda(vr_index).cdcritic := vr_cdcritic;
            pr_tab_remessa_dda(vr_index).dscritic := vr_dscritic;                           
            
            --Levantar Excecao
            vr_flg_erro := TRUE;
        END;
        END IF;
        
        --Encontrar proximo registro
        vr_index := pr_tab_remessa_dda.NEXT(vr_index);
      END LOOP;
    
      IF vr_flg_erro THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na tabela TBJDDDALEG_LG2JD_OPTITULO.';
          RAISE vr_exc_erro;
      END IF;
    
      /* Nao ha mais necessidade de buscar a confirmacao do registro
       logo apos o momento da inclusao, pois o processamento da Cabine da JD
       eh lento
      --Executar retorno operacao Titulos DDA
      DDDA0001.pc_retorno_operacao_tit_DDA (pr_tab_remessa_dda => pr_tab_remessa_dda --Remessa dda
                                           ,pr_tab_retorno_dda => pr_tab_retorno_dda --Retorno dda
                                           ,pr_cdcritic        => vr_cdcritic        --Codigo de Erro
                                           ,pr_dscritic        => vr_dscritic);      --Descricao de Erro */
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_remessa_titulos_dda. ' ||
                       SQLERRM;
    END;
  END pc_remessa_titulos_dda;
  
  --###########################################################################################################--
  -- PROCEDIMENTO PARA CHAMAR A ROTINA PC_RETORNO_OPERACAO_TIT_DDA DIRETAMENTE NO ORACLE
  PROCEDURE pc_retorno_tit_tab_DDA(pr_tab_remessa_dda  IN DDDA0001.typ_tab_remessa_dda  -- Remessa dda
                                  ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda  -- Retorno dda
                                  ,pr_cdcritic        OUT crapcri.cdcritic%type         -- Codigo de Erro
                                  ,pr_dscritic        OUT VARCHAR2) IS                  -- Descricao de Erro
  
  BEGIN
    
    -- Chamar a rotina interna
    pc_retorno_operacao_tit_DDA(pr_tab_remessa_dda => pr_tab_remessa_dda
                               ,pr_tab_retorno_dda => pr_tab_retorno_dda
                               ,pr_cdcritic        => pr_cdcritic
                               ,pr_dscritic        => pr_dscritic);
                                
  END pc_retorno_tit_tab_DDA;
  --###########################################################################################################--
  -- PROCEDIMENTO PARA CHAMAR A ROTINA PC_RETORNO_OPERACAO_TIT_DDA DIRETAMENTE NO ORACLE
  PROCEDURE pc_remessa_tit_tab_dda(pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda  -- Remessa dda
                                  ,pr_tab_retorno_dda    OUT DDDA0001.typ_tab_retorno_dda  -- Retorno dda
                                  ,pr_cdcritic           OUT crapcri.cdcritic%type         -- Codigo de Erro
                                  ,pr_dscritic           OUT VARCHAR2) IS                  -- Descricao de Erro
  
  BEGIN
    
    -- Chamar a rotina interna
    pc_remessa_titulos_dda(pr_tab_remessa_dda => pr_tab_remessa_dda
                          ,pr_tab_retorno_dda => pr_tab_retorno_dda
                          ,pr_cdcritic        => pr_cdcritic
                          ,pr_dscritic        => pr_dscritic);

  END pc_remessa_tit_tab_dda;
  --###########################################################################################################--

  /* SubRotina para converter as informa��es da global temporary table
  wt_retorno_dda para PLTABLE e vice-versa */
  PROCEDURE pc_converte_retorno_ddda(pr_tporigem        IN VARCHAR2 --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                                    ,pr_tab_retorno_dda IN OUT DDDA0001.typ_tab_retorno_dda --Retorno dda
                                    ,pr_dscritic        OUT VARCHAR2) IS
  BEGIN
    DECLARE
      -- Cursor para leitura da Work Table wt_remessa_dda
      CURSOR cr_wt_retorno_dda IS
        SELECT * FROM wt_retorno_dda;
      -- Controle de erros
      vr_exc_erro exception;
      vr_des_erro varchar2(4000);
      -- Indice para a pltable
      vr_index INTEGER;
    BEGIN
      -- Para origem T (Tabela para PLTable)
      IF pr_tporigem = 'T' THEN
        -- Limpar a pltable
        pr_tab_retorno_dda.delete;
        -- Varrer as informa��es da tabela
        FOR rw_retorno IN cr_wt_retorno_dda LOOP
          -- Guardar o contador para inser��o
          vr_index := pr_tab_retorno_dda.COUNT;
          -- Gravar da tabela para PLtable
          pr_tab_retorno_dda(vr_index).idtitleg := rw_retorno.idtitleg;
          pr_tab_retorno_dda(vr_index).idopeleg := rw_retorno.idopeleg;
          pr_tab_retorno_dda(vr_index).insitpro := rw_retorno.insitpro;
        END LOOP;
        -- Limpar a tabela
        BEGIN
          DELETE FROM wt_retorno_dda;
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Erro ao limpar a tabela wt_retorno_dda: ' ||
                           sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        --> Origem P (PLTable para Tabela)
        -- Limpar a tabela
        BEGIN
          DELETE FROM wt_retorno_dda;
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Erro ao limpar a tabela wt_retorno_dda: ' ||
                           sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Efetuar leitura da PLTable
        IF pr_tab_retorno_dda.COUNT > 0 THEN
          FOR vr_cont IN 1 .. pr_tab_retorno_dda.LAST LOOP
            -- Inserir na tabela
            BEGIN
              INSERT INTO wt_retorno_dda
                (idtitleg
                ,idopeleg
                ,insitpro)
              VALUES
                (pr_tab_retorno_dda(vr_cont).idtitleg
                ,pr_tab_retorno_dda(vr_cont).idopeleg
                ,pr_tab_retorno_dda(vr_cont).insitpro);
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'Erro ao inserir na tabela wt_retorno_dda: ' ||
                               sqlerrm;
                RAISE vr_exc_erro;
            END;
          END LOOP;
        END IF;
        -- Por fim, limpar a pltable
        pr_tab_retorno_dda.DELETE;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := 'Erro na rotina DDDA0001.pc_converte_retorno_ddda: ' ||
                       vr_des_erro;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina DDDA0001.pc_converte_retorno_ddda: ' ||
                       sqlerrm;
    END;
  END;

  /* SubRotina para converter as informa��es da global temporary table
  wt_remessa_dda para PLTABLE e vice-versa */
  PROCEDURE pc_converte_remessa_ddda(pr_tporigem        IN VARCHAR2 --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                                    ,pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda --Remessa dda
                                    ,pr_dscritic        OUT VARCHAR2) IS
  BEGIN
    DECLARE
      -- Cursor para leitura da Work Table wt_remessa_dda
      CURSOR cr_wt_remessa_dda IS
        SELECT * FROM wt_remessa_dda;
      -- Controle de erros
      vr_exc_erro exception;
      vr_des_erro varchar2(4000);
      -- Indice para a pltable
      vr_index INTEGER;
    BEGIN
      -- Para origem T (Tabela para PLTable)
      IF pr_tporigem = 'T' THEN
        -- Limpar a pltable
        pr_tab_remessa_dda.delete;
        -- Varrer as informa��es da tabela
        FOR rw_remessa IN cr_wt_remessa_dda LOOP
          -- Guardar o contador para inser��o
          vr_index := pr_tab_remessa_dda.COUNT;
          -- Gravar da tabela para PLtable
          pr_tab_remessa_dda(vr_index).nrispbif := rw_remessa.nrispbif;
          pr_tab_remessa_dda(vr_index).cdlegado := rw_remessa.cdlegado;
          pr_tab_remessa_dda(vr_index).idopeleg := rw_remessa.idopeleg;
          pr_tab_remessa_dda(vr_index).idtitleg := rw_remessa.idtitleg;
          pr_tab_remessa_dda(vr_index).tpoperad := rw_remessa.tpoperad;
          pr_tab_remessa_dda(vr_index).dtoperac := rw_remessa.dtoperac;
          pr_tab_remessa_dda(vr_index).hroperac := rw_remessa.hroperac;
          pr_tab_remessa_dda(vr_index).cdifdced := rw_remessa.cdifdced;
          pr_tab_remessa_dda(vr_index).tppesced := rw_remessa.tppesced;
          pr_tab_remessa_dda(vr_index).nrdocced := rw_remessa.nrdocced;
          pr_tab_remessa_dda(vr_index).nmdocede := rw_remessa.nmdocede;
          pr_tab_remessa_dda(vr_index).cdageced := rw_remessa.cdageced;
          pr_tab_remessa_dda(vr_index).nrctaced := rw_remessa.nrctaced;
          pr_tab_remessa_dda(vr_index).tppesori := rw_remessa.tppesori;
          pr_tab_remessa_dda(vr_index).nrdocori := rw_remessa.nrdocori;
          pr_tab_remessa_dda(vr_index).nmdoorig := rw_remessa.nmdoorig;
          pr_tab_remessa_dda(vr_index).tppessac := rw_remessa.tppessac;
          pr_tab_remessa_dda(vr_index).nrdocsac := rw_remessa.nrdocsac;
          pr_tab_remessa_dda(vr_index).nmdosaca := rw_remessa.nmdosaca;
          pr_tab_remessa_dda(vr_index).dsendsac := rw_remessa.dsendsac;
          pr_tab_remessa_dda(vr_index).dscidsac := rw_remessa.dscidsac;
          pr_tab_remessa_dda(vr_index).dsufsaca := rw_remessa.dsufsaca;
          pr_tab_remessa_dda(vr_index).Nrcepsac := rw_remessa.Nrcepsac;
          pr_tab_remessa_dda(vr_index).tpdocava := rw_remessa.tpdocava;
          pr_tab_remessa_dda(vr_index).nrdocava := rw_remessa.nrdocava;
          pr_tab_remessa_dda(vr_index).nmdoaval := rw_remessa.nmdoaval;
          pr_tab_remessa_dda(vr_index).cdcartei := rw_remessa.cdcartei;
          pr_tab_remessa_dda(vr_index).cddmoeda := rw_remessa.cddmoeda;
          pr_tab_remessa_dda(vr_index).dsnosnum := rw_remessa.dsnosnum;
          pr_tab_remessa_dda(vr_index).dscodbar := rw_remessa.dscodbar;
          pr_tab_remessa_dda(vr_index).dtvencto := rw_remessa.dtvencto;
          pr_tab_remessa_dda(vr_index).vlrtitul := rw_remessa.vlrtitul;
          pr_tab_remessa_dda(vr_index).nrddocto := rw_remessa.nrddocto;
          pr_tab_remessa_dda(vr_index).cdespeci := rw_remessa.cdespeci;
          pr_tab_remessa_dda(vr_index).dtemissa := rw_remessa.dtemissa;
          pr_tab_remessa_dda(vr_index).nrdiapro := rw_remessa.nrdiapro;
          pr_tab_remessa_dda(vr_index).tpdepgto := rw_remessa.tpdepgto;
          pr_tab_remessa_dda(vr_index).indnegoc := rw_remessa.indnegoc;
          pr_tab_remessa_dda(vr_index).vlrabati := rw_remessa.vlrabati;
          pr_tab_remessa_dda(vr_index).dtdjuros := rw_remessa.dtdjuros;
          pr_tab_remessa_dda(vr_index).dsdjuros := rw_remessa.dsdjuros;
          pr_tab_remessa_dda(vr_index).vlrjuros := rw_remessa.vlrjuros;
          pr_tab_remessa_dda(vr_index).dtdmulta := rw_remessa.dtdmulta;
          pr_tab_remessa_dda(vr_index).cddmulta := rw_remessa.cddmulta;
          pr_tab_remessa_dda(vr_index).vlrmulta := rw_remessa.vlrmulta;
          pr_tab_remessa_dda(vr_index).flgaceit := rw_remessa.flgaceit;
          pr_tab_remessa_dda(vr_index).dtddesct := rw_remessa.dtddesct;
          pr_tab_remessa_dda(vr_index).cdddesct := rw_remessa.cdddesct;
          pr_tab_remessa_dda(vr_index).vlrdesct := rw_remessa.vlrdesct;
          pr_tab_remessa_dda(vr_index).dsinstru := rw_remessa.dsinstru;
          pr_tab_remessa_dda(vr_index).dtlipgto := rw_remessa.dtlipgto;
          pr_tab_remessa_dda(vr_index).tpdBaixa := rw_remessa.tpdBaixa;
          pr_tab_remessa_dda(vr_index).dssituac := rw_remessa.dssituac;
          pr_tab_remessa_dda(vr_index).insitpro := rw_remessa.insitpro;
          pr_tab_remessa_dda(vr_index).tpmodcal := rw_remessa.tpmodcal;
          pr_tab_remessa_dda(vr_index).dtvalcal := rw_remessa.dtvalcal;
          pr_tab_remessa_dda(vr_index).flavvenc := rw_remessa.flavvenc;
          pr_tab_remessa_dda(vr_index).vldsccal := rw_remessa.vldsccal;
          pr_tab_remessa_dda(vr_index).vljurcal := rw_remessa.vljurcal;
          pr_tab_remessa_dda(vr_index).vlmulcal := rw_remessa.vlmulcal;
          pr_tab_remessa_dda(vr_index).vltotcob := rw_remessa.vltotcob;
        END LOOP;
        -- Limpar a tabela
        BEGIN
          DELETE FROM wt_remessa_dda;
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Erro ao limpar a tabela wt_remessa_dda: ' ||
                           sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        --> Origem P (PLTable para Tabela)
        -- Limpar a tabela
        BEGIN
          DELETE FROM wt_remessa_dda;
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Erro ao limpar a tabela wt_remessa_dda: ' ||
                           sqlerrm;
            RAISE vr_exc_erro;
        END;
        -- Efetuar leitura da PLTable
        IF pr_tab_remessa_dda.COUNT > 0 THEN
          FOR vr_cont IN 1 .. pr_tab_remessa_dda.LAST LOOP
            -- Inserir na tabela
            BEGIN
              INSERT INTO wt_remessa_dda
                (nrispbif
                ,cdlegado
                ,idopeleg
                ,idtitleg
                ,tpoperad
                ,dtoperac
                ,hroperac
                ,cdifdced
                ,tppesced
                ,nrdocced
                ,nmdocede
                ,cdageced
                ,nrctaced
                ,tppesori
                ,nrdocori
                ,nmdoorig
                ,tppessac
                ,nrdocsac
                ,nmdosaca
                ,dsendsac
                ,dscidsac
                ,dsufsaca
                ,Nrcepsac
                ,tpdocava
                ,nrdocava
                ,nmdoaval
                ,cdcartei
                ,cddmoeda
                ,dsnosnum
                ,dscodbar
                ,dtvencto
                ,vlrtitul
                ,nrddocto
                ,cdespeci
                ,dtemissa
                ,nrdiapro
                ,tpdepgto
                ,indnegoc
                ,vlrabati
                ,dtdjuros
                ,dsdjuros
                ,vlrjuros
                ,dtdmulta
                ,cddmulta
                ,vlrmulta
                ,flgaceit
                ,dtddesct
                ,cdddesct
                ,vlrdesct
                ,dsinstru
                ,dtlipgto
                ,tpdBaixa
                ,dssituac
                ,insitpro
                ,tpmodcal
                ,dtvalcal
                ,flavvenc
                ,vldsccal
                ,vljurcal
                ,vlmulcal
                ,vltotcob)
              VALUES
                (pr_tab_remessa_dda(vr_cont).nrispbif
                ,pr_tab_remessa_dda(vr_cont).cdlegado
                ,pr_tab_remessa_dda(vr_cont).idopeleg
                ,pr_tab_remessa_dda(vr_cont).idtitleg
                ,pr_tab_remessa_dda(vr_cont).tpoperad
                ,pr_tab_remessa_dda(vr_cont).dtoperac
                ,pr_tab_remessa_dda(vr_cont).hroperac
                ,pr_tab_remessa_dda(vr_cont).cdifdced
                ,pr_tab_remessa_dda(vr_cont).tppesced
                ,pr_tab_remessa_dda(vr_cont).nrdocced
                ,pr_tab_remessa_dda(vr_cont).nmdocede
                ,pr_tab_remessa_dda(vr_cont).cdageced
                ,pr_tab_remessa_dda(vr_cont).nrctaced
                ,pr_tab_remessa_dda(vr_cont).tppesori
                ,pr_tab_remessa_dda(vr_cont).nrdocori
                ,pr_tab_remessa_dda(vr_cont).nmdoorig
                ,pr_tab_remessa_dda(vr_cont).tppessac
                ,pr_tab_remessa_dda(vr_cont).nrdocsac
                ,pr_tab_remessa_dda(vr_cont).nmdosaca
                ,pr_tab_remessa_dda(vr_cont).dsendsac
                ,pr_tab_remessa_dda(vr_cont).dscidsac
                ,pr_tab_remessa_dda(vr_cont).dsufsaca
                ,pr_tab_remessa_dda(vr_cont).Nrcepsac
                ,pr_tab_remessa_dda(vr_cont).tpdocava
                ,pr_tab_remessa_dda(vr_cont).nrdocava
                ,pr_tab_remessa_dda(vr_cont).nmdoaval
                ,pr_tab_remessa_dda(vr_cont).cdcartei
                ,pr_tab_remessa_dda(vr_cont).cddmoeda
                ,pr_tab_remessa_dda(vr_cont).dsnosnum
                ,pr_tab_remessa_dda(vr_cont).dscodbar
                ,pr_tab_remessa_dda(vr_cont).dtvencto
                ,pr_tab_remessa_dda(vr_cont).vlrtitul
                ,pr_tab_remessa_dda(vr_cont).nrddocto
                ,pr_tab_remessa_dda(vr_cont).cdespeci
                ,pr_tab_remessa_dda(vr_cont).dtemissa
                ,pr_tab_remessa_dda(vr_cont).nrdiapro
                ,pr_tab_remessa_dda(vr_cont).tpdepgto
                ,pr_tab_remessa_dda(vr_cont).indnegoc
                ,pr_tab_remessa_dda(vr_cont).vlrabati
                ,pr_tab_remessa_dda(vr_cont).dtdjuros
                ,pr_tab_remessa_dda(vr_cont).dsdjuros
                ,pr_tab_remessa_dda(vr_cont).vlrjuros
                ,pr_tab_remessa_dda(vr_cont).dtdmulta
                ,pr_tab_remessa_dda(vr_cont).cddmulta
                ,pr_tab_remessa_dda(vr_cont).vlrmulta
                ,pr_tab_remessa_dda(vr_cont).flgaceit
                ,pr_tab_remessa_dda(vr_cont).dtddesct
                ,pr_tab_remessa_dda(vr_cont).cdddesct
                ,pr_tab_remessa_dda(vr_cont).vlrdesct
                ,pr_tab_remessa_dda(vr_cont).dsinstru
                ,pr_tab_remessa_dda(vr_cont).dtlipgto
                ,pr_tab_remessa_dda(vr_cont).tpdBaixa
                ,pr_tab_remessa_dda(vr_cont).dssituac
                ,pr_tab_remessa_dda(vr_cont).insitpro
                ,pr_tab_remessa_dda(vr_cont).tpmodcal
                ,pr_tab_remessa_dda(vr_cont).dtvalcal
                ,pr_tab_remessa_dda(vr_cont).flavvenc
                ,pr_tab_remessa_dda(vr_cont).vldsccal
                ,pr_tab_remessa_dda(vr_cont).vljurcal
                ,pr_tab_remessa_dda(vr_cont).vlmulcal
                ,pr_tab_remessa_dda(vr_cont).vltotcob);
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'Erro ao inserir na tabela wt_remessa_dda: ' ||
                               sqlerrm;
                RAISE vr_exc_erro;
            END;
          END LOOP;
        END IF;
        -- Por fim, limpar a pltable
        pr_tab_remessa_dda.DELETE;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := 'Erro na rotina DDDA0001.pc_converte_remessa_DDDA: ' ||
                       vr_des_erro;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina DDDA0001.pc_converte_remessa_DDDA: ' ||
                       sqlerrm;
    END;
  END;

  /* Procedure para chamar a rotina pc_retorno_operacao_tit_dda
  em PLSQL atrav�s da rotina Progress via DataServer */
  PROCEDURE pc_retorno_operacao_tit_DDA(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_operacao_tit_DDA
    --  Sistema  : CRED
    --  Sigla    :
    --  Autor    : Marcos - Supero
    --  Data     : Dezembro/2013.                   Ultima atualizacao: --/--/----
    --
    -- Frequencia: Ssempre que acionado pela procedure sistema/generico/procedures/b1wgen0087.p/remessa-titulos-DDA
  
    -- Objetivo  : O processo de comunica��o com o JD-DDa n�o funciona corretamente em execucoes
    --             via DataServer Progress. Com isso, precisamos alterar todas as rotinas Progress
    --             que utilizavam essa conexao a JD para chamar as procedures convertidas em PLSQL.
    --             Entretanto, ha um porem com relacao a procedimento que recebem/devolvem tt-tables
    --             pois isso nao funciona em chamadas pelo DataServer ao PLSQL, entao definimos a tabela
    --             wt_remessa_dda e wt_retorno_dda que serao gravadas no Progress antes da chamada
    --             desta rotina e entao quando chegamos no PLSQL, lemos a tabela e gravamos seus dados
    --             para a pltable, chamando entao a rotina convertida. No termino da execucao, faremos
    --             o caminho inverso, lendo a pltable e gravando nas tabelas para entao o Progress
    --             ler as tabelas e devolver suas informacoes as tt-tables.
    ---------------------------------------------------------------------------------------------------------------
  
    DECLARE
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_des_erro VARCHAR2(4000);
      -- Instancias das pltables de informacoes
      vr_tab_remessa_dda typ_tab_remessa_dda;
      vr_tab_retorno_dda typ_tab_retorno_dda;
    BEGIN
      -- Primeiramente chama a rotina pc_converte_remessa_ddda
      -- para gravar os dados da tabela wt_remessa_dda para a pltable
      pc_converte_remessa_ddda(pr_tporigem        => 'T' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_remessa_dda => vr_tab_remessa_dda --Remessa dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Ap�s, faremos o mesmo esquema, so que dessa vez com os
      -- dados da wt_retorno_dda que serao copiados para a vr_tab_retorno_dda
      pc_converte_retorno_ddda(pr_tporigem        => 'T' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_retorno_dda => vr_tab_retorno_dda --Retorno dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Finalmente chamamos a rotina convertida
      pc_retorno_operacao_tit_DDA(pr_tab_remessa_dda => vr_tab_remessa_dda -- Remessa dda
                                 ,pr_tab_retorno_dda => vr_tab_retorno_dda -- Retorno dda
                                 ,pr_cdcritic        => vr_cdcritic -- Codigo de Erro
                                 ,pr_dscritic        => vr_des_erro); -- Descricao de Erro
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL
         OR vr_cdcritic > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      -- Ao final, temos de copiar os registros das Pltables para as tabelas
      -- Primeiro para Remessa
      pc_converte_remessa_ddda(pr_tporigem        => 'P' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_remessa_dda => vr_tab_remessa_dda --Remessa dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Por fim, para o retorno
      pc_converte_retorno_ddda(pr_tporigem        => 'P' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_retorno_dda => vr_tab_retorno_dda --Retorno dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se n�o houver critica
        vr_cdcritic := NVL(vr_cdcritic, 0);
        -- Copiar das work para saida
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_retorno_operacao_tit_DDA: ' ||
                       vr_des_erro;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_retorno_operacao_tit_DDA: ' ||
                       sqlerrm;
    END;
  END;

  /* Procedure para chamar a rotina pc_remessa_titulos_dda
  em PLSQL atrav�s da rotina Progress via DataServer */
  PROCEDURE pc_remessa_titulos_dda(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_remessa_titulos_dda
    --  Sistema  : CRED
    --  Sigla    :
    --  Autor    : Marcos - Supero
    --  Data     : Dezembro/2013.                   Ultima atualizacao: --/--/----
    --
    -- Frequencia: Ssempre que acionado pela procedure sistema/generico/procedures/b1wgen0087.p/remessa-titulos-DDA
  
    -- Objetivo  : O processo de comunica��o com o JD-DDa n�o funciona corretamente em execucoes
    --             via DataServer Progress. Com isso, precisamos alterar todas as rotinas Progress
    --             que utilizavam essa conexao a JD para chamar as procedures convertidas em PLSQL.
    --             Entretanto, ha um porem com relacao a procedimento que recebem/devolvem tt-tables
    --             pois isso nao funciona em chamadas pelo DataServer ao PLSQL, entao definimos a tabela
    --             wt_remessa_dda e wt_retorno_dda que serao gravadas no Progress antes da chamada
    --             desta rotina e entao quando chegamos no PLSQL, lemos a tabela e gravamos seus dados
    --             para a pltable, chamando entao a rotina convertida. No termino da execucao, faremos
    --             o caminho inverso, lendo a pltable e gravando nas tabelas para entao o Progress
    --             ler as tabelas e devolver suas informacoes as tt-tables.
    ---------------------------------------------------------------------------------------------------------------
  
    DECLARE
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_des_erro VARCHAR2(4000);
      -- Instancias das pltables de informacoes
      vr_tab_remessa_dda typ_tab_remessa_dda;
      vr_tab_retorno_dda typ_tab_retorno_dda;
    
    BEGIN
      -- Primeiramente chama a rotina pc_converte_remessa_ddda
      -- para gravar os dados da tabela wt_remessa_dda para a pltable
      pc_converte_remessa_ddda(pr_tporigem        => 'T' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_remessa_dda => vr_tab_remessa_dda --Remessa dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Ap�s, faremos o mesmo esquema, so que dessa vez com os
      -- dados da wt_retorno_dda que serao copiados para a vr_tab_retorno_dda
      pc_converte_retorno_ddda(pr_tporigem        => 'T' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_retorno_dda => vr_tab_retorno_dda --Retorno dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Finalmente chamamos a rotina convertida
      pc_remessa_titulos_dda(pr_tab_remessa_dda => vr_tab_remessa_dda -- Remessa dda
                            ,pr_tab_retorno_dda => vr_tab_retorno_dda -- Retorno dda
                            ,pr_cdcritic        => vr_cdcritic -- Codigo de Erro
                            ,pr_dscritic        => vr_des_erro); -- Descricao de Erro
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL
         OR vr_cdcritic > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      -- Ao final, temos de copiar os registros das Pltables para as tabelas
      -- Primeiro para Remessa
      pc_converte_remessa_ddda(pr_tporigem        => 'P' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_remessa_dda => vr_tab_remessa_dda --Remessa dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
      -- Por fim, para o retorno
      pc_converte_retorno_ddda(pr_tporigem        => 'P' --> Tipo da Origem: T[tb para pltable] OU P[pltable para tb]
                              ,pr_tab_retorno_dda => vr_tab_retorno_dda --Retorno dda
                              ,pr_dscritic        => vr_des_erro);
      -- Sair ao encontrar problemas
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se n�o houver critica
        vr_cdcritic := NVL(vr_cdcritic, 0);
        -- Copiar das work para saida
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_remessa_titulos_dda: ' ||
                       vr_des_erro;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_remessa_titulos_dda: ' ||
                       sqlerrm;
    END;
  END;

  /* Procedure para realizar a liquidacao intrabancaria do DDA */
  PROCEDURE pc_liquid_intrabancaria_dda(pr_rowid_cob IN ROWID --ROWID da Cobranca
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                       ,pr_dscritic  OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_liquid_intrabancaria_dda    Antigo: procedures/b1wgen0088.p/liquidacao-intrabancaria-dda
    --  Sistema  : Procedure para atualizar situacao do titulo do sacado eletronico
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para realizar a liquidacao intrabancaria do DDA
  
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
    
      --Tabela de memoria de remessa DDA
      vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
      --Tabela de memoria de retorno DDA
      vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Selecionar registro cobranca
      OPEN cr_crapcob(pr_rowid => pr_rowid_cob);
      --Posicionar no proximo registro
      FETCH cr_crapcob
        INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcob;
    
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => rw_crapcob.cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic := 651;
        vr_dscritic := 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
    
      /* se titulo DDA e pago fora da compe,
      entao realizar liq intrabancaria na JD/CIP */
      IF rw_crapcob.flgregis = 1
         AND rw_crapcob.flgcbdda = 1
         AND rw_crapcob.cdbandoc = rw_crapcop.cdbcoctl THEN
        /* Cria Temp-Table do DDA - JD */
        DDDA0001.pc_cria_remessa_dda(pr_rowid_cob       => pr_rowid_cob --ROWID da Cobranca
                                    ,pr_tpoperad        => 'B' --Tipo operador   /* Baixa */
                                    ,pr_tpdbaixa        => '1' --Tipo de baixa
                                    ,pr_dtvencto        => rw_crapcob.dtvencto --Data vencimento
                                    ,pr_vldescto        => rw_crapcob.vldescto --Valor Desconto
                                    ,pr_vlabatim        => rw_crapcob.vlabatim --Valor Abatimento
                                    ,pr_flgdprot        => rw_crapcob.flgdprot = 1 --Flag protecao
                                    ,pr_tab_remessa_dda => vr_tab_remessa_dda --Tabela remessa dda
                                    ,pr_cdcritic        => vr_cdcritic --Codigo de Erro
                                    ,pr_dscritic        => vr_dscritic); --Descricao de Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        /* Remessa titulos DDA */
        DDDA0001.pc_remessa_titulos_dda(pr_tab_remessa_dda => vr_tab_remessa_dda --Remessa dda
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Retorno dda
                                       ,pr_cdcritic        => vr_cdcritic --Codigo de Erro
                                       ,pr_dscritic        => vr_dscritic); --Descricao de Erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL
           OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_liquid_intrabancaria_dda. ' ||
                       SQLERRM;
    END;
  END pc_liquid_intrabancaria_dda;

  --> Rotina para enviar email de alertas sobre beneficiarios/convenios
  PROCEDURE pc_email_alert_JDBNF( pr_cdcooper  IN crapceb.cdcooper%TYPE, --> Codigo da cooperativa
                                  pr_nrdconta  IN crapceb.nrdconta%TYPE, --> Numero da conta do cooperado
                                  pr_nrconven  IN crapceb.nrconven%TYPE, --> Numero do convenio
                                  pr_nrcnvceb  IN crapceb.nrcnvceb%TYPE, --> numero CEB
                                  pr_tpalerta  IN INTEGER,                --> Tipo de alerta(1-convenio pendente, 2-Novo cooperado) 
                                  pr_cdcritic OUT NUMBER,
                                  pr_dscritic OUT VARCHAR2) IS
  /* .............................................................................

    Programa: pc_email_alert_JDBNF           
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Abril/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para enviar email de alertas sobre beneficiarios/convenios

    Alteracoes:
  ..............................................................................*/  
  
    ---------> CURSORES <---------- 
    --> Buscar dados do cooperado
    CURSOR cr_crapass IS 
      SELECT ass.nmprimtl,
             ass.inpessoa,
             ass.nrcpfcgc,
             cop.nmrescop
        FROM crapass ass,
             crapcop cop
       WHERE ass.cdcooper = cop.cdcooper
         AND ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Buscar dados do convenio
    CURSOR cr_crapceb IS 
      SELECT ceb.insitceb,
             ceb.dtcadast,
             ass.nmprimtl,
             ass.inpessoa,
             ass.nrcpfcgc,
             cop.nmrescop
        FROM crapceb ceb,
             crapass ass,
             crapcop cop
       WHERE ceb.cdcooper = ass.cdcooper
         AND ceb.nrdconta = ass.nrdconta
         AND ceb.cdcooper = cop.cdcooper
         AND ceb.cdcooper = pr_cdcooper
         AND ceb.nrdconta = pr_nrdconta
         AND ceb.nrconven = pr_nrconven
         AND ceb.nrcnvceb = pr_nrcnvceb;
    rw_crapceb cr_crapceb%ROWTYPE;
    
    -----------> VARIAVEIS <----------
    vr_dsAssunt      VARCHAR2(100);
    vr_dsdcorpo      VARCHAR2(4000);
    vr_dsdemail_dst  VARCHAR2(4000);
    
    vr_exc_erro      EXCEPTION;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    
  BEGIN
    
    IF pr_tpalerta = 1 THEN
      vr_dsAssunt := 'JD � Ades�o cobran�a BNF';
    ELSIF pr_tpalerta = 2 THEN
      vr_dsAssunt := 'JDBNF � Novo Cooperado � Tela MATRIC';
    ELSE
      vr_dsAssunt := 'Alerta JBNF';  
    END IF;  
  
    --> Buscar cooperado
    rw_crapass := NULL;
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;  
    CLOSE cr_crapass;
    
    -- Email de convenio pendente
    IF pr_tpalerta = 1 THEN
      --> Buscar convenio
      OPEN cr_crapceb;
      FETCH cr_crapceb INTO rw_crapceb;
      
      IF cr_crapceb%NOTFOUND THEN
        CLOSE cr_crapceb;
        vr_cdcritic := 563; -- Convenio nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapceb;
      END IF;
    END IF;
    -- se estiver pendente
    IF rw_crapceb.insitceb = 3 OR 
       -- Ou for alerta de novo cooperado 
       pr_tpalerta = 2 THEN
       
      
      vr_dsdcorpo := 'Favor verificar o status de conv�nios de cobran�a do cooperado abaixo:<br>'||
                     'Nome/Raz�o social do Cooperado: '|| rw_crapass.nmprimtl            ||'<br>'||
                     'CPF/CNPJ: '                      || gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)     ||'<br>'|| 
                     'N�mero da Conta do Cooperado: '  || pr_nrdconta                    ||'<br>'||
                     'N�mero do conv�nio pendente: '   || pr_nrconven                    ||'<br>'||
                     'Data que houve a habilita��o inicial: '|| to_char(rw_crapceb.dtcadast,'DD/MM/RRRR') ||'<br>'||                         
                     'Cooperativa: '|| nvl(rw_crapass.nmrescop,pr_cdcooper)                               ||'<br>';       
    
      -->  Buscar destinatario de email
      vr_dsdemail_dst := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                    pr_cdcooper => pr_cdcooper, 
                                                    pr_cdacesso => 'EMAIL_CONV_PENDENTE');                                                    
                                                    
      --> Enviar Email
      GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                ,pr_cdprogra        => 'COBRANCA'     --> Programa conectado
                                ,pr_des_destino     => nvl(vr_dsdemail_dst,'segurancacorporativa@cecred.coop.br')  --> Um ou mais detinat�rios separados por ';' ou ','
                                ,pr_des_assunto     => vr_dsAssunt    --> Assunto do e-mail
                                ,pr_des_corpo       => vr_dsdcorpo    --> Corpo (conteudo) do e-mail
                                ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N'            --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                ,pr_des_email_reply => NULL           --> Endere�o para resposta ao e-mail
                                ,pr_flg_enviar      => 'N'            --> Enviar o e-mail na hora
                                ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;                                                    
    END IF; 
    
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN  
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel enviar email pc_email_alert_JDBNF: '||SQLERRM;
  END pc_email_alert_JDBNF;
  
  /* Procedure para executar os procedimentos DDA JD */
  PROCEDURE pc_procedimentos_dda_jd(pr_rowid_cob       IN ROWID --ROWID da Cobranca
                                   ,pr_tpoperad        IN VARCHAR2 --Tipo Operacao
                                   ,pr_tpdbaixa        IN VARCHAR2 --Tipo de Baixa
                                   ,pr_dtvencto        IN DATE --Data Vencimento
                                   ,pr_vldescto        IN NUMBER --Valor Desconto
                                   ,pr_vlabatim        IN NUMBER --Valor Abatimento
                                   ,pr_flgdprot        IN INTEGER --Flag Protesto
                                   ,pr_tab_remessa_dda OUT DDDA0001.typ_tab_remessa_dda --Tabela memoria Remessa DDA
                                   ,pr_tab_retorno_dda OUT DDDA0001.typ_tab_retorno_dda --Tabela memoria retorno DDA
                                   ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --Codigo Critica
                                   ,pr_dscritic        OUT VARCHAR2) IS --Descricao Critica
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_procedimentos_dda_jd    Antigo: procedures/b1wgen0088.p/procedimentos-dda-jd
    --  Sistema  : CRED
    --  Sigla    :
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Dezembro/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --               par_tpoperad = /* (B)aixa (I)nclusao (A)lteracao   */
    --               par_tpdbaixa   /*    (0)Liq Interbancaria          */
    --                              /*    (1)Liq Intrabancaria          */
    --                              /*    (2)Solicitacao Cedente        */
    --                              /*    (3)Envio p/ Protesto          */
    --                              /*    (4)Baixa por Decurso de Prazo */
    -- Frequencia: -----
    -- Objetivo  : Procedure para executar os procedimentos DDA-JD
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar Parametros Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      /* Cria Temp-Table do DDA - JD */
      DDDA0001.pc_cria_remessa_dda(pr_rowid_cob       => pr_rowid_cob --ROWID da Cobranca
                                  ,pr_tpoperad        => pr_tpoperad --Tipo operador   /* Baixa */
                                  ,pr_tpdbaixa        => pr_tpdbaixa --Tipo de baixa
                                  ,pr_dtvencto        => pr_dtvencto --Data vencimento
                                  ,pr_vldescto        => pr_vldescto --Valor Desconto
                                  ,pr_vlabatim        => pr_vlabatim --Valor Abatimento
                                  ,pr_flgdprot        => pr_flgdprot = 1 --Flag protecao
                                  ,pr_tab_remessa_dda => pr_tab_remessa_dda --Tabela remessa dda
                                  ,pr_cdcritic        => vr_cdcritic --Codigo de Erro
                                  ,pr_dscritic        => vr_dscritic); --Descricao de Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL
         OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    
      /* Remessa titulos DDA */
      DDDA0001.pc_remessa_titulos_dda(pr_tab_remessa_dda => pr_tab_remessa_dda --Remessa dda
                                     ,pr_tab_retorno_dda => pr_tab_retorno_dda --Retorno dda
                                     ,pr_cdcritic        => vr_cdcritic --Codigo de Erro
                                     ,pr_dscritic        => vr_dscritic); --Descricao de Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL
         OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_procedimentos_dda_jd. ' ||
                       SQLERRM;
    END;
  END pc_procedimentos_dda_jd;

  --> Procedimento para retornar situa��o do beneficiario na cabine JD
  PROCEDURE pc_ret_sit_beneficiario(pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                    pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                    pr_insitif  OUT VARCHAR2,               --> Retornar situa��o IF
                                    pr_insitcip OUT VARCHAR2,               --> Retorna situa��o na CIP
                                    pr_dscritic OUT VARCHAR2) IS            --> Retorna critica
    /* .............................................................................
    
        Programa: pc_ret_sit_beneficiario
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana - AMcom
        Data    : Maio/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Procedimento para retornar situa��o do bebeficioando na cabine JD
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Cursor para buscar situacao do benificiario na cip
    CURSOR cr_DDA_Sit_Ben (pr_dspessoa VARCHAR2,
                           pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT 1 SITIF, --b."SITIF", --> Ver Rafael
             1 SITCIP --b."SITCIP" --> Ver rafael
        FROM VWJDDDABNF_Sit_Beneficiario@Jdnpcsql b
       WHERE b."TpPessoaBenfcrio" = pr_dspessoa
         AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
    rw_DDA_Sit_Ben cr_DDA_Sit_Ben%ROWTYPE; 
  BEGIN
    
    --> Buscar situa��o do beneficiario na cabine
    OPEN cr_DDA_Sit_Ben(pr_dspessoa => (CASE pr_inpessoa 
                                          WHEN 1 THEN 'F'
                                          ELSE 'J'
                                        END),  
                        pr_nrcpfcgc => pr_nrcpfcgc);
    FETCH cr_DDA_Sit_Ben INTO rw_DDA_Sit_Ben;
    IF cr_DDA_Sit_Ben%NOTFOUND THEN
      CLOSE cr_DDA_Sit_Ben;
      pr_insitif  := NULL;
      pr_insitcip := NULL;
    ELSE
      CLOSE cr_DDA_Sit_Ben;
      -- popular variaveis com a situacao para retornar dados
      pr_insitif  := rw_DDA_Sit_Ben.Sitif;
      pr_insitcip := rw_DDA_Sit_Ben.Sitcip;      
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar situacao beneficiario: '||SQLERRM;
  END pc_ret_sit_beneficiario;
  
  --> Rotina para verificar situa��o do cooperado na cabine e enviar email
  PROCEDURE pc_verifica_sit_JDBNF (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa
                                   pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                   pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                   pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                   pr_insitif  OUT VARCHAR2,               --> Retornar situa��o IF
                                   pr_insitcip OUT VARCHAR2,               --> Retorna situa��o na CIP
                                   pr_dscritic OUT VARCHAR2) IS            --> Retorna criticaIS
  
  /* .............................................................................
    
        Programa: pc_verifica_sit_JDBNF
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana - AMcom
        Data    : Maio/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar situa��o do cooperado na cabine e enviar email
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    -----------> VARIAVEIS <----------
    vr_dsAssunt      VARCHAR2(100);
    vr_dsdcorpo      VARCHAR2(4000);
    vr_dsdemail_dst  VARCHAR2(4000);
    
    vr_exc_erro      EXCEPTION;
    vr_cdcritic      NUMBER;
    vr_dscritic      VARCHAR2(4000);
    
  BEGIN
  
    --> Retornar situa��o do beneficiario na cabine JD
    pc_ret_sit_beneficiario(pr_inpessoa  => pr_inpessoa,  --> Tipo de pessoa
                            pr_nrcpfcgc  => pr_nrcpfcgc,  --> CPF/CNPJ do beneficiario
                            pr_insitif   => pr_insitif,   --> Retornar situa��o IF
                            pr_insitcip  => pr_insitcip,  --> Retorna situa��o na CIP
                            pr_dscritic  => vr_dscritic); --> Retorna critica    
    
    IF vr_dscritic IS NOT NULL THEN
      NULL;
    END IF; 
    
    --> SITIF => �I� (Inapto) ou �E� (em an�lise), enviar e-mail para seguran�a corportativa;
    --> SITIF sem status e SITCIP = �I� ou �E�, enviar e-mail para seguran�a corportativa;
    IF upper(pr_insitif) IN ('I','E') OR
       (TRIM(pr_insitif) IS NULL AND pr_insitcip IN ('I','E') ) THEN
      
      --> Enviar email de Novo cooperado
      pc_email_alert_JDBNF( pr_cdcooper  => pr_cdcooper,
                            pr_nrdconta  => pr_nrdconta,
                            pr_nrconven  => 0,
                            pr_nrcnvceb  => 0,
                            pr_tpalerta  => 2, --> Novo cooperado
                            pr_cdcritic  => vr_cdcritic,
                            pr_dscritic  => vr_dscritic);
      --Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0  THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;           
    END IF;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN      
      IF vr_cdcritic <> 0 AND
         TRIM(vr_cdcritic) IS NOT NULL THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar situacao beneficiario: '||SQLERRM;
  END pc_verifica_sit_JDBNF;

  --> Rotina para atualizar situa��o do cooperado na cabine JDBNF  
  PROCEDURE pc_atualiza_sit_JDBNF (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa
                                   pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                   pr_nrconven  IN crapceb.nrconven%TYPE,  --> Numero do convenio de cobranca
                                   pr_insitceb  IN crapceb.insitceb%TYPE,  --> Situacao do convenio de cobranca
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE,  --> Codigo de critica
                                   pr_dscritic OUT VARCHAR2) IS            --> Retorna critica  
  /* .............................................................................
    
        Programa: pc_atualiza_sit_JDBNF
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Rafael Cechet
        Data    : Agosto/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para atualizar situa��o do cooperado na cabine JDBNF 
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    
    ------------> CURSORES <------------
    
    -- Cadastro de associados
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT to_char(crapass.nrdconta) nrdconta
            ,crapass.inpessoa
            ,decode(crapass.inpessoa,1,lpad(crapass.nrcpfcgc,11,'0'),
                                       lpad(crapass.nrcpfcgc,14,'0')) dscpfcgc
            ,decode(crapass.inpessoa,1,'F','J') dspessoa
            ,crapass.nmprimtl
            ,to_char(crapass.nrcpfcgc) nrcpfcgc
            ,to_char(crapcop.cdagectl) cdagectl
        FROM crapass,
             crapcop 
       WHERE crapass.cdcooper = crapcop.cdcooper
         AND crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    
    -- Cadastro de Bloquetos
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                     ,pr_nrdconta IN crapceb.nrdconta%TYPE
                     ,pr_nrconven IN crapceb.nrconven%TYPE) IS
      SELECT crapceb.insitceb,
             crapceb.dtcadast
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.nrconven = pr_nrconven;
    rw_crapceb cr_crapceb%ROWTYPE;
    
    --> Cursor para verificar se ja existe o beneficiario na cip
    CURSOR cr_DDA_Benef (pr_dspessoa VARCHAR2,
                         pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS      
      SELECT 1
        FROM TBJDDDABNF_BeneficiarioIF@jdbnfsql b
       WHERE b.ISPB_IF = '5463212'
         AND "TpPessoaBenfcrio" = pr_dspessoa
         AND "CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
    rw_DDA_Benef cr_DDA_Benef%ROWTYPE;    
    
    --> Cursor para verificar se ja existe o convenio na cip
    CURSOR cr_DDA_Conven (pr_dspessoa VARCHAR2,
                          pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                          pr_nrconven VARCHAR2) IS      
      SELECT 1
        FROM TBJDDDABNF_Convenio@jdbnfsql b
       WHERE b."ISPB_IF" = '5463212'
         AND b."TpPessoaBenfcrio" = pr_dspessoa
         AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc
         AND b."CodCli_Conv"      = pr_nrconven;
    rw_DDA_Conven cr_DDA_Conven%ROWTYPE;      
    
    --> Buscar dados pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper crapjur.cdcooper%TYPE,
                       pr_nrdconta crapjur.nrdconta%TYPE) IS
      SELECT jur.nmfansia
        FROM crapjur  jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta; 
    rw_crapjur cr_crapjur%ROWTYPE;        
    
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
    ------------> VARIAVEIS <-----------  
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(2000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;   
    
    vr_dtativac VARCHAR2(8);
    vr_nrconven VARCHAR2(10);
    vr_sitifcnv VARCHAR2(10) := 'A';
    vr_insitif  VARCHAR2(10);
    vr_insitcip VARCHAR2(10);
    vr_dtfimrel VARCHAR2(10) := NULL;    
    
  BEGIN        

    vr_nrconven := to_char(pr_nrconven);    
    
    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;    
    
    -- Cadastro de associados
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se NAO encontrou
    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      CLOSE cr_crapass;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;  
    
    -- Cadastro de bloquetos
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven);
    FETCH cr_crapceb INTO rw_crapceb;
    -- Fecha cursor
    CLOSE cr_crapceb;    
    
    --> se convenio ativo
    IF pr_insitceb = 1 THEN             
      vr_sitifcnv := 'A';      
      vr_dtativac := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
      vr_dtfimrel := NULL;
    ELSE 
      vr_sitifcnv := 'E';      
      vr_dtativac := to_char(rw_crapceb.dtcadast,'RRRRMMDD');
      vr_dtfimrel := to_char(rw_crapdat.dtmvtolt,'RRRRMMDD');
    END IF;    
      
    --> Verificar se ja existe o beneficiario na cip
    OPEN cr_DDA_Benef (pr_dspessoa => rw_crapass.dspessoa,
                       pr_nrcpfcgc => rw_crapass.nrcpfcgc);
    FETCH cr_DDA_Benef INTO rw_DDA_Benef;
    IF cr_DDA_Benef%NOTFOUND THEN
      IF rw_crapass.inpessoa = 2 THEN
        --> Buscar dados pessoa juridica
        OPEN cr_crapjur (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        CLOSE cr_crapjur;
      END IF;  
                    
      BEGIN
        INSERT INTO TBJDDDABNF_BeneficiarioIF@jdbnfsql
              ( "ISPB_IF",
                "TpPessoaBenfcrio",
                "CNPJ_CPFBenfcrio",
                "Nom_RzSocBenfcrio", 
                "Nom_FantsBenfcrio", 
                "DtInicRelctPart",    
                "DtFimRelctPart")
        VALUES ('5463212'            -- ISPB_IF
               ,rw_crapass.dspessoa  -- TpPessoaBenfcrio
               ,rw_crapass.dscpfcgc  -- CNPJ_CPFBenfcrio
               ,rw_crapass.nmprimtl  -- Nom_RzSocBenfcrio 
               ,rw_crapjur.nmfansia  -- Nom_FantsBenfcrio 
               ,vr_dtativac          -- DtInicRelctPart    
               ,NULL);               -- DtFimRelctPart    
            
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel cadastrar Beneficiario na CIP: ' || SQLERRM;
          RAISE vr_exc_saida;              
      END;

    ELSE    
    
      -- Atualizar convenio na CIP  
      BEGIN      
        vr_nrconven := to_char(pr_nrconven);
        UPDATE TBJDDDABNF_Convenio@jdbnfsql
           SET TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'A',
               TBJDDDABNF_Convenio."DtInicRelctConv"    = vr_dtativac,
               TBJDDDABNF_Convenio."DtFimRelctConv"     = vr_dtfimrel
         WHERE TBJDDDABNF_Convenio."ISPB_IF" = '5463212'
           AND TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
           AND TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
           AND TBJDDDABNF_Convenio."CodCli_Conv"      = vr_nrconven
           AND TBJDDDABNF_Convenio."AgDest"           = rw_crapass.cdagectl
           AND TBJDDDABNF_Convenio."CtDest"           = rw_crapass.nrdconta;
        
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;
    
    CLOSE cr_DDA_Benef;
    
    --> Verificar se ja existe o convenio na cip
    OPEN cr_DDA_Conven (pr_dspessoa => rw_crapass.dspessoa,
                        pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                        pr_nrconven => to_char(pr_nrconven));
    FETCH cr_DDA_Conven INTO rw_DDA_Conven;
    IF cr_DDA_Conven%NOTFOUND THEN
      --> Gerar informa��o de ades�o de conv�nio ao JDBNF                            
      BEGIN
        INSERT INTO TBJDDDABNF_Convenio@jdbnfsql 
                   ("ISPB_IF",
                    "ISPBPartIncorpd",
                    "TpPessoaBenfcrio",
                    "CNPJ_CPFBenfcrio",
                    "CodCli_Conv",
                    "SitConvBenfcrioPar",
                    "DtInicRelctConv",
                    "DtFimRelctConv",
                    "TpAgDest",
                    "AgDest",
                    "TpCtDest",
                    "CtDest",
                    "TpProdtConv",
                    "TpCartConvCobr" )
             VALUES(5463212,                                -- ISPB_IF
                    NULL,                                   -- ISPBPartIncorpd
                    rw_crapass.dspessoa,                    -- TpPessoaBenfcrio
                    rw_crapass.dscpfcgc,                    -- CNPJ_CPFBenfcrio
                    vr_nrconven,                            -- CodCli_Conv
                    vr_sitifcnv,                            -- SitConvBenfcrioPar
                    vr_dtativac,                            -- DtInicRelctConv
                    vr_dtfimrel,                            -- DtFimRelctConv
                    'F',                                    -- TpAgDest (F=Fisica)
                    rw_crapass.cdagectl,                    -- AgDest
                    'CC',                                   -- TpCtDest
                    rw_crapass.nrdconta,                    -- CtDest
                    '01', -- boleto de cobranca             -- TpProdtConv
                    '1' );-- com registro                   -- TpCartConvCobr
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel registrar convenio na CIP: ' || SQLERRM;
          RAISE vr_exc_saida;              
      END;
    ELSE
      BEGIN
        UPDATE TBJDDDABNF_Convenio@jdbnfsql a
           SET a."SitConvBenfcrioPar" = vr_sitifcnv
              ,a."DtInicRelctConv"    = vr_dtativac
              ,a."DtFimRelctConv"     = vr_dtfimrel
         WHERE a."ISPB_IF"            = '5463212'
           AND a."TpPessoaBenfcrio"   = rw_crapass.dspessoa
           AND a."CNPJ_CPFBenfcrio"   = rw_crapass.dscpfcgc
           AND a."CodCli_Conv"        = vr_nrconven;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
            RAISE vr_exc_saida;              
        END;            
    END IF;
    CLOSE cr_DDA_Conven;      
    
  EXCEPTION    
    WHEN vr_exc_saida THEN      
      IF vr_cdcritic <> 0 AND
         TRIM(vr_cdcritic) IS NOT NULL THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel atualizar situacao beneficiario: '||SQLERRM;
  
  END pc_atualiza_sit_JDBNF;

END ddda0001;
/
