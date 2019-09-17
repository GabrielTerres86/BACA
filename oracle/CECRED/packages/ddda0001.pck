CREATE OR REPLACE PACKAGE CECRED."DDDA0001" AS

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
  
      03/08/2012 - Ajuste na informação de baixa operacional devido a aplicacao
                   do catalogo Bacen 3.06. (Rafael)
  
      12/11/2012 - Ajuste em proc. carrega-dados-titulo quando campo for
                   RepetDesctTit, adicionado condicional "or". (Jorge)
  
      03/01/2013 - Ajustes em campo "RepetDesctTit" da procedure
                   carrega-dados-titulo (Jorge)
  
      02/05/2013 - Ajuste em proc. carrega-dados-titulo, adicionado replace de
                   campos com nomes, retirando "," ";" e "#". (Jorge)
  
      09/07/2013 - Conversão Progress para Oracle (Alisson - AMcom)
  
      25/02/2014 - Ajuste na rotina que busca a confirmacao do registro do
                   titulo naJD (MS-SQL/Server) (Rafael).
                   
      29/10/2015 - Alterado tamanho do campo typ_reg_remessa_dda.dsinstru 
                   SD352398(Odirlei-Amcom)            
  
      13/06/2018 - Criado assinatura da fn_datamov para ser chamada no CRPS618.
                   Chamado SCTASK0015832 - Gabriel (Mouts).

      08/08/2018 - Adicionado o conveio de desconto de titulo para seguir a mesma regra do de emprestimo na definicao da data (Luis Fernando - GFT)
  ..............................................................................*/


  TYPE typ_reg_notif_dda IS RECORD(
    bancobeneficiario VARCHAR2(100)
   ,nomecooperado VARCHAR2(100)
   ,beneficiario VARCHAR2(100)
   ,datavencimento DATE
   ,situacao VARCHAR2(100)
   ,valor NUMBER
   ,codigobarras VARCHAR2(100)
   ,motivo tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
   ,quantidade INTEGER
  );
  
 MOTIVO_NOVO_TITULO_DDA  CONSTANT tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 2; 
 MOTIVO_NOVOS_TITULOS_DDA  CONSTANT tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 1; 


  /* Tipo de registro de Remessa DDA
     Origem: sistema/generico/includes/b1wgen0087tt.i >> tt-remessa-dda
     Observação: Toda alteração nesta pltable deve ser replicada
                 na temp-table acima declara e também na tabela
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
    ,nmfansia VARCHAR2(80)
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
    ,cdpartrc crapcob.cdbandoc%TYPE
    ,dhdbaixa VARCHAR2(20)
    ,dtdbaixa VARCHAR2(20)
    ,cdCanPgt INTEGER
    ,cdmeiopg INTEGER  
    ,cdcooper crapcop.cdcooper%TYPE  
    ,vldpagto crapcob.vldpagto%TYPE  
    );

  /* Tipo de tabela de Remessa DDA */
  TYPE typ_tab_remessa_dda IS TABLE OF typ_reg_remessa_dda INDEX BY PLS_INTEGER;

  /* Tipo de Registro de retorno DDA */
  /* Origem: sistema/generico/includes/b1wgen0087tt.i >> tt-retorno-dda
     Observação: Toda alteração nesta pltable deve ser replicada
                 na temp-table acima declara e também na tabela
                 wt_retorno_dda.
  */

  TYPE typ_reg_retorno_dda IS RECORD(
     idtitleg VARCHAR2(100)
    ,idopeleg INTEGER
    ,insitpro INTEGER
    ,nrdident NUMBER(19)
    ,nratutit NUMBER(19));
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
  
  vr_datetimeformat  CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS';
  vr_dateformat      CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';
  
  --> Ler as baixas operacionais
  CURSOR cr_baixaoperacional( pr_dsxml CLOB) IS
    WITH DATA AS (SELECT pr_dsxml xml FROM dual)
    SELECT ROWNUM  idregist
         , NPCB0001.fn_convert_number(NumIdentcBaixaOperac)  NumIdentcBaixaOperac    
         , NPCB0001.fn_convert_number(NumRefAtlBaixaOperac)  NumRefAtlBaixaOperac   
         , NPCB0001.fn_convert_number(NumSeqAtlzBaixaOperac) NumSeqAtlzBaixaOperac 
         , SitBaixaOperacional                               SitBaixaOperacional 
         , TO_DATE(DtProcBaixaOperac,vr_dateformat)          DtProcBaixaOperac      
         , TO_DATE(DtHrProcBaixaOperac,vr_datetimeformat)    DtHrProcBaixaOperac    
         , TO_DATE(DtHrSitBaixaOperac,vr_datetimeformat)     DtHrSitBaixaOperac     
         , NPCB0001.fn_convert_number(VlrBaixaOperacTit)     VlrBaixaOperacTit      
         , NumCodBarrasBaixaOperac                           NumCodBarrasBaixaOperac
         , TpOpBaixaOperac                                   TpOpBaixaOperac
      FROM DATA
         , XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "SOAP-ENV"
                                 ,'urn:JDNPCWS_RecebimentoPgtoTitIntf-IJDNPCWS_RecebimentoPgtoTit' AS "NS1")
                                 ,'/SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:ConsultarRetornoBaixaOperacionalResponse/return/RetornoBxOperac/BxOperac'
                    PASSING XMLTYPE(xml)
                    COLUMNS NumIdentcBaixaOperac    NUMBER       PATH 'NumIdentcBaixaOperac'
                          , NumRefAtlBaixaOperac    NUMBER       PATH 'NumRefAtlBaixaOperac'
                          , NumSeqAtlzBaixaOperac   NUMBER       PATH 'NumSeqAtlzBaixaOperac'
                          , SitBaixaOperacional     NUMBER       PATH 'SitBaixaOperacional'
                          , DtProcBaixaOperac       VARCHAR2(10) PATH 'DtProcBaixaOperac'
                          , DtHrProcBaixaOperac     VARCHAR2(30) PATH 'DtHrProcBaixaOperac'
                          , DtHrSitBaixaOperac      VARCHAR2(30) PATH 'DtHrSitBaixaOperac'
                          , VlrBaixaOperacTit       VARCHAR2(20) PATH 'VlrBaixaOperacTit'
                          , NumCodBarrasBaixaOperac VARCHAR2(44) PATH 'NumCodBarrasBaixaOperac'
                          , TpOpBaixaOperac         VARCHAR2(1) PATH 'TpOpBaixaOperac');    

  /* Buscar data de referencia da cabine JDNPC */
  FUNCTION fn_datamov RETURN NUMBER;

  /* Procedure para Atualizar Situacao */
  PROCEDURE pc_requis_atualizar_situacao(pr_cdlegado IN VARCHAR2 --> Codigo Legado
                                        ,pr_nrispbif IN VARCHAR2 --> Numero ISPB IF
                                        ,pr_idtitdda IN VARCHAR2 --> Identificador Titulo DDA
                                        ,pr_cdsittit IN INTEGER  --> Codigo Situacao Titulo
                                        ,pr_xml_frag OUT NOCOPY xmltype --> Fragmento do XML de retorno
                                        ,pr_des_erro OUT VARCHAR2 --> Indicador erro OK/NOK
                                        ,pr_dscritic OUT VARCHAR2); --> Descricao erro
                                        
  /* Procedure para atualizar situacao do titulo do sacado eletronico */
  PROCEDURE pc_atualz_situac_titulo_sacado(pr_cdcooper IN INTEGER  --Codigo da Cooperativa
                                          ,pr_cdagecxa IN INTEGER  --Codigo da Agencia
                                          ,pr_nrdcaixa IN INTEGER  --Numero do Caixa
                                          ,pr_cdopecxa IN VARCHAR2 --Codigo Operador Caixa
                                          ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                          ,pr_idorigem IN INTEGER  --Indicador Origem
                                          ,pr_nrdconta IN INTEGER  --Numero da Conta
                                          ,pr_idseqttl IN INTEGER  --Sequencial do titular
                                          ,pr_idtitdda IN VARCHAR2   --Indicador Titulo DDA
                                          ,pr_cdsittit IN INTEGER  --Situacao Titulo
                                          ,pr_flgerlog IN INTEGER  --Gerar Log(1-Sim 0-Nao)
                                          ,pr_dtmvtolt IN DATE DEFAULT NULL     --> data de movimento
                                          ,pr_dscodbar IN VARCHAR2 DEFAULT NULL --> Codigo de barra
                                          ,pr_cdctrlcs IN VARCHAR2 DEFAULT NULL --> Identificador da consulta
                                          ,pr_cdcritic OUT INTEGER              --> Codigo da critica
                                          ,pr_dscritic OUT VARCHAR2);           --> Descrição da critica

  /* Procedure para criar remessa DDA */
  PROCEDURE pc_cria_remessa_dda(pr_rowid_cob       IN ROWID --ROWID da Cobranca
                               ,pr_tpoperad        IN VARCHAR2 --Tipo operador   /* (B)aixa (I)nclusao (A)lteracao   */
                               ,pr_tpdbaixa        IN VARCHAR2 --Tipo de baixa
                               ,pr_dtvencto        IN DATE --Data vencimento
                               ,pr_vldescto        IN NUMBER --Valor Desconto
                               ,pr_vlabatim        IN NUMBER --Valor Abatimento
                               ,pr_flgdprot        IN BOOLEAN --Flag protecao
                               ,pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda --Tabela remessa
                               ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --Codigo de Erro
                               ,pr_dscritic        OUT VARCHAR2); --Descricao de Erro                                          

  /* Procedure para realizar a baixa efetiva NPC */
  PROCEDURE pc_baixa_efetiva_npc( pr_rowid_cob IN ROWID --ROWID da Cobranca
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                       ,pr_dscritic  OUT VARCHAR2); --Descricao de Erro

  /* Procedure para buscar codigo cedente do DDA */
  PROCEDURE pc_busca_cedente_DDA(pr_cdcooper IN INTEGER --Codigo Cooperativa
                                ,pr_idtitdda IN NUMBER --Identificador Titulo dda
                                ,pr_nrinsced OUT NUMBER --Numero inscricao cedente
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                ,pr_dscritic OUT VARCHAR2); --Descricao de Erro

  /* Procedure para verificar se foi sacado do DDA via WEB */
  PROCEDURE pc_verifica_sacado_DDA(pr_tppessoa IN VARCHAR2               -- Tipo de pessoa
                                  ,pr_nrcpfcgc IN NUMBER                 -- Cpf ou CNPJ
                                  ,pr_flgsacad OUT INTEGER               -- Indicador se foi sacado
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Codigo de Erro
                                  ,pr_dscritic OUT VARCHAR2);            -- Descricao de Erro
  
  /* Procedure para verificar se foi sacado do DDA */
  PROCEDURE pc_verifica_sacado_web(pr_tppessoa IN VARCHAR2               -- Tipo de pessoa
                                  ,pr_nrcpfcgc IN NUMBER                 -- Cpf ou CNPJ
                                  ,pr_xmllog   IN VARCHAR2              -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           -- Erros do processo

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


  /* Procedure para chamar a rotina pc_remessa_titulos_dda
  em PLSQL através da rotina Progress via DataServer */
  PROCEDURE pc_remessa_titulos_dda(pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT VARCHAR2);
 
  /* Procedure para Executar retorno da remessa da títulos da DDA diretamente do ORACLE
  --> Foi criado uma rotina para fazer o meio de campo pois não é permitido ter 
      sobrecarga de método, pois estraga o schema holder    */
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

  --> Rotina para verificar situação do cooperado na cabine e enviar email
  PROCEDURE pc_verifica_sit_JDBNF (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa
                                   pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                   pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                   pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                   pr_insitif  OUT VARCHAR2,               --> Retornar situação IF
                                   pr_insitcip OUT VARCHAR2,               --> Retorna situação na CIP
                                   pr_dscritic OUT VARCHAR2);              --> Retorna criticaIS                              
  
  --> Procedimento para retornar situação do bebeficioando na cabine JD
  PROCEDURE pc_ret_sit_beneficiario(pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                    pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                    pr_insitif  OUT VARCHAR2,               --> Retornar situação IF
                                    pr_insitcip OUT VARCHAR2,               --> Retorna situação na CIP
                                    pr_dscritic OUT VARCHAR2);              --> Retorna critica                                                                     

  --> Rotina para atualizar situação do cooperado na cabine JDBNF  
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

  /* Procedure para requisitar a consulta de retorno de dados da baixa operacional */
  PROCEDURE pc_ConsultarBaixaOperacional(pr_cdctrbxo IN VARCHAR2 --> Numero controle participante da baixa operacional
                                        ,pr_cdcodbar IN VARCHAR2 --> Codigo de barras do titulo
                                        ,pr_baixaope OUT cr_baixaoperacional%ROWTYPE --> retornar dados da baixa operacional
                                        ,pr_idbxapdn OUT NUMBER                      --> Indica comunicação de baixa pendente
                                        ,pr_des_erro OUT VARCHAR2                    --> Indicador erro OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);                  --> Descricao erro

  /* Procedure para Cancelar Baixa Operacional  - Demetrius Wolff - Mouts */
  PROCEDURE pc_cancelar_baixa_operac (pr_cdlegado IN VARCHAR2    --> Codigo Legado
                                     ,pr_idtitdda IN VARCHAR2    --> Identificador Titulo DDA
                                     ,pr_cdctrlcs IN VARCHAR2    --> Numero controle consulta NPC
                                     ,pr_cdcodbar IN VARCHAR2    --> Codigo de barras do titulo
                                     ,pr_idpenden IN OUT NUMBER  --> Indica o processamento da pendencia
                                     ,pr_des_erro OUT VARCHAR2   --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2); --> Descricao erro

  -- Procedure para criação de notificação e Push para DDA                                   
  PROCEDURE pc_notif_novo_dda (pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_notif_dda IN typ_reg_notif_dda);

  -- Procedure para processar pendencia de cancelamento de baixa operacional 
  PROCEDURE pc_pendencia_cancel_baixa(pr_dsrowid   IN VARCHAR2);   -- Rowid do registro a ser processado

END ddda0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED."DDDA0001" AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : ddda0001
  --  Sistema  : Procedimentos e funcoes da BO b1wgen0079.p
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 30/11/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funcoes da BO b1wgen0079.p
  --
  -- Alteracoes: 07/07/2014 - Remover do log a mensagem "DDDA0001 --> Falha na execucao do metodo 
  --                          DDA SOAP-ENV:-722 - Situação do Título não permite mais alterações. 
  --                          Comunique seu PA." (Douglas - Chamado 160064)
  --
  --             22/12/2015 - Cursor cr_dadostitulo era fechado em um momento que
  --                          dependendo da situacao ocasionava erro (Tiago/Elton). 
  -- 
  --             22/02/2016 - Ajustado rotina pc_chegada_titulos_DDA pois procedimento será chamado via job todos os dias, 
  --                          alterando filtro de data na busca dos novos titulos, e ajustado mensagem para
  --                          exibir corretamente no Internetbank
  --                          SD388026 (Odirlei-AMcom) 
  --
  --             22/11/2016 - Alterado para torcar a chamada das procedures PC_RETORNO_OPERACAO_TIT_DDA 
  --                          (pc_remessa_tit_tab_dda) e PC_REMESSA_TITULOS_DDA (pc_remessa_tit_tab_dda) 
  --                          como públicas. (Renato Darosci - Supero)
  --
  --             13/07/2017 - Retirado procedure pc_retorno_operacao_tit_DDA (antigo JDDDA) (Rafael)
  --
  --             29/08/2017 - Retirado mensagem de logs da proc_message.log e direcionado para o log
  --                          principal da NPC. (Rafael)
  --
  --             26/10/2017 - Incluir decode no campo tpdmulta do cursor cr_crapcob para garantir
  --                          que o código enviado para cip seja 1, 2 ou 3 (SD#769996 - AJFink)
  --             07/08/2018 - Luis Fernando (GFT)
  --
  --             30/11/2018 - Implementado UPPER na consulta da CRAPSAB na procedure pc_cria_remessa_dda
  --                          (Tiago - INC0026317)   
  --
  --             20/12/2018 - Chamado INC0028955 Erro de cursor invalido (Fabio - Amcom).   
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

  --Selecionar convenio de cobranca
  CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE,
                    pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT cco.dsorgarq,
           cco.qtdecate
      FROM crapcco cco
     WHERE cco.cdcooper = pr_cdcooper
       AND cco.nrconven = pr_nrconven;
  rw_crapcco cr_crapcco%ROWTYPE;
  
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
          ,crapcob.idopeleg
          ,crapcob.cdtpinav
          ,crapcob.nrinsava
          ,crapcob.nmdavali
          ,crapcob.dsdoccop
          ,crapcob.dtmvtolt
          ,crapcob.qtdiaprt
          ,crapcob.vljurdia
          ,decode(nvl(crapcob.tpdmulta,0),1,1,2,2,3) tpdmulta /*SD#769996*/
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
          ,crapcob.inregcip 
          ,crapcob.cdmensag
          ,crapcob.dtvctori
          ,crapcob.incobran
          ,crapcob.vldpagto
          ,crapcob.cdbanpag
      FROM crapcob
     WHERE crapcob.ROWID = pr_rowid;
  rw_crapcob cr_crapcob%ROWTYPE;
  
  --Selecionar registro convenio do cooperado
  CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE,
                    pr_nrdconta IN crapceb.nrdconta%TYPE,
                    pr_nrconven IN crapceb.nrconven%TYPE) IS
    SELECT ceb.qtdecprz 
      FROM crapceb ceb
     WHERE ceb.cdcooper = pr_cdcooper
       AND ceb.nrdconta = pr_nrdconta
       AND ceb.nrconven = pr_nrconven;
  rw_crapceb cr_crapceb%ROWTYPE;  
  
  vr_dsarqlg         CONSTANT VARCHAR2(20) := 'npc_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- nome do arquivo de log mensal  

  function fn_datamov return number is
    /******************************************************************************
      Programa: fn_datamov
      Sistema : Cobranca - Cooperativa de Credito
      Sigla   : CRED
      Autor   : AJFink SD#754622
      Data    : Outubro/2017.                     Ultima atualizacao: --/--/----
      Objetivo: Buscar data de referencia da cabine JDNPC

      Alteracoes: 

    ******************************************************************************/
    --
    cursor c_datamov is
      SELECT "DataMov" datamov
        FROM TBJDDDA_CTRL_ABERTURA@jdnpcsql
       WHERE "ISPBCliente" = 5463212
         AND "DataMov" IS NOT NULL
      ORDER BY "DataMov" DESC;
    --
    w_datamov number(8);
    --
  begin
    --
    open c_datamov;
    fetch c_datamov into w_datamov;
    close c_datamov;
    --
    return (w_datamov);
    --
  exception
    when others then
      raise_application_error(-20001,'ddda0001.fn_datamov',true);
  end fn_datamov;

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
  PROCEDURE pc_cria_tag(pr_dsnomtag IN VARCHAR2 --> Nome TAG que será criada
                       ,pr_dspaitag IN VARCHAR2 --> Nome TAG pai
                       ,pr_dsvaltag IN VARCHAR2 --> Valor TAG que será criada
                       ,pr_postag   IN PLS_INTEGER --> Posição da TAG criada no nodelist
                       ,pr_dstpdado IN VARCHAR2 --> Tipo de dado da TAG
                       ,pr_deftpdad IN VARCHAR2 --> Definição do tipo de dado
                       ,pr_xml      IN OUT NOCOPY XMLType --> Handle XMLType
                       ,pr_des_erro OUT VARCHAR2 --> Identificador erro OK/NOK
                       ,pr_dscritic OUT VARCHAR2) IS --> Descrição erro
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
    -- Alteracoes: 01/07/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_exc_erro EXCEPTION; --> Controle de erros
    
    BEGIN
      -- Gerar TAGs dos parâmetros para o método
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
  PROCEDURE pc_obtem_fault_packet(pr_xml      IN OUT NOCOPY xmltype --> XML de verificação
                                 ,pr_dsderror IN VARCHAR2 --> parâmetro para liberação de erros específicos
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
    -- Alteracoes: 01/08/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_cdderror   VARCHAR2(400) := ''; --> Código do erro de acesso
      vr_dsderror   VARCHAR2(400) := ''; --> Descrição do erro de acesso
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
    
      -- Faz processo de validação do erro retornado no XML
      IF vr_countfault > 0 THEN
        -- Recupera o código do erro
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
      
        -- Recupera a descrição do erro
        -- Recupera o código do erro
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
      
        -- Verifica se existe erro e se existe parâmetro para ignorar
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

  /* Procedure para Atualizar Situacao */
  PROCEDURE pc_requis_atualizar_situacao(pr_cdlegado IN VARCHAR2 --> Codigo Legado
                                        ,pr_nrispbif IN VARCHAR2 --> Numero ISPB IF
                                        ,pr_idtitdda IN VARCHAR2 --> Identificador Titulo DDA
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
    -- Alteracoes: 01/08/2013 - conversão Progress >> PL/SQL (Oracle). Petter - Supero.
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xml XMLType; --> XML de requisição
      vr_exc_erro EXCEPTION; --> Controle de exceção
      
      vr_xml_res XMLType; --> XML de resposta
      vr_tab_xml gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
      vr_ctrlpart VARCHAR2(20);
      
      vr_tbcampos      NPCB0003.typ_tab_campos_soap;
    
    BEGIN
    
      -- Limpa a tab de campos
      vr_tbcampos.DELETE();
      
      -- Chama rotina para fazer a inclusão das TAGS comuns
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
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumIdentcTit';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_idtitdda;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'JDNPCSitTitIF';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdsittit;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'JDNPCInfTitIF';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := '';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';      
     
    
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
    
      -- Enviar requisição para webservice
      soap0001.pc_cliente_webservice(pr_endpoint    => NPCB0003.fn_url_SendSoapNPC(pr_idservic => 3)
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
      
        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha na atualizacao da situacao.';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
      -- Retornar fragmento XML como novo documento XML
      --Valor não utilizado
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
    --
    -- Alteracoes : 20/12/2018 - Chamado INC0028955 Erro de cursor invalido (Fabio - Amcom).
  
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
      if cr_crapass%isopen then
      CLOSE cr_crapass;
      end if;   
      --Abrir arquivo modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdirlog --> Diretório do arquivo
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
  PROCEDURE pc_atualz_situac_titulo_sacado(pr_cdcooper IN INTEGER  --Codigo da Cooperativa
                                          ,pr_cdagecxa IN INTEGER  --Codigo da Agencia
                                          ,pr_nrdcaixa IN INTEGER  --Numero do Caixa
                                          ,pr_cdopecxa IN VARCHAR2 --Codigo Operador Caixa
                                          ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                          ,pr_idorigem IN INTEGER  --Indicador Origem
                                          ,pr_nrdconta IN INTEGER  --Numero da Conta
                                          ,pr_idseqttl IN INTEGER  --Sequencial do titular
                                          ,pr_idtitdda IN VARCHAR2 --Indicador Titulo DDA
                                          ,pr_cdsittit IN INTEGER  --Situacao Titulo
                                          ,pr_flgerlog IN INTEGER  --Gerar Log(1-Sim 0-Nao)
                                          ,pr_dtmvtolt IN DATE DEFAULT NULL     --> data de movimento
                                          ,pr_dscodbar IN VARCHAR2 DEFAULT NULL --> Codigo de barra
                                          ,pr_cdctrlcs IN VARCHAR2 DEFAULT NULL --> Identificador da consulta
                                          ,pr_cdcritic OUT INTEGER              --> Codigo da critica
                                          ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da critica
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
    -- Atualização: Ajustado mensagem de critica de falha DDA (Odirlei-Amcom)
    --
    -- Alteracoes: 07/07/2014 - Remover do log a mensagem "DDDA0001 --> Falha na execucao do metodo 
    --                          DDA SOAP-ENV:-722 - Situação do Título não permite mais alterações. 
    --                          Comunique seu PA." (Douglas - Chamado 160064)
    --
    --             04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir 
    --                          nomenclaturas Cedente por Beneficiário e  Sacado por Pagador  
    --                           Chamado 229313 (Jean Reddiga - RKAM).
    --
    --             01/07/2016 - Adicionado o valor do parametro pr_idtitdda no log de erros da 
    --                          atualização da situação do titulo (Douglas - Chamado 462368)
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
    
      --> Buscar dados da consulta
      CURSOR cr_cons_titulo (pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE ) IS
        SELECT con.dsxml,
               con.flgcontingencia
          FROM tbcobran_consulta_titulo con
         WHERE con.cdctrlcs = pr_cdctrlcs;
         
      rw_cons_titulo cr_cons_titulo%ROWTYPE;
      vr_tituloCIP   NPCB0001.typ_reg_TituloCIP;
      
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
      
      vr_idtitdda NUMBER;
    
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      
    BEGIN
      
      vr_idtitdda := TRIM(pr_idtitdda);      
      
      --Gerar log erro
      IF nvl(pr_flgerlog,0) = 1 THEN
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
      
      --Situacao titulo invalida
      IF pr_cdsittit < 1
         OR pr_cdsittit > 4 THEN
        --Descricao da Critica
        vr_dscritic := 'Situacao do titulo invalida.';
        --Sair
        RAISE vr_exc_erro;
      END IF;
      
      IF TRIM(pr_cdctrlcs) IS NOT NULL THEN
            
        --> Buscar dados da consulta
        OPEN cr_cons_titulo (pr_cdctrlcs => pr_cdctrlcs);
        FETCH cr_cons_titulo INTO rw_cons_titulo;
            
        IF cr_cons_titulo%NOTFOUND THEN
          CLOSE cr_cons_titulo;
          vr_dscritic := 'Não foi possivel localizar consulta NPC '||pr_cdctrlcs;    
          RAISE vr_exc_erro;  
        ELSE
          CLOSE cr_cons_titulo;
        END IF;
          
        --> Verificar se cip esta em contigencia
        --> e não é pagamento pelo menu DDA
        IF rw_cons_titulo.flgcontingencia = 1 AND vr_idtitdda IS NULL THEN
          --> Caso esteja deve sair do programa sem critica
          --> pois atualização da cabine e CIP ocorrerá quando for normalizado
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          RAISE vr_exc_erro;
            
        END IF;
            
        --> Se nao estiver em contigencia
        IF rw_cons_titulo.flgcontingencia = 0 THEN  
          --> Rotina para retornar dados do XML para temptable
          NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => rw_cons_titulo.dsxml
                                            ,pr_tbtitulo => vr_tituloCIP
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_dscritic => vr_dscritic);
            
          -- Se houve retorno de erro
          IF vr_dscritic IS NOT NULL OR vr_des_erro = 'NOK' THEN	  
            RAISE vr_exc_erro;       
          END IF; 
       
          vr_idtitdda := vr_tituloCIP.NumIdentcTit;
        END IF;
            
        
       
      END IF;
      
      --> Apenas atualizar situação para titulos DDAs submetidas pela tela DDA
      --> pois se tratam de titulo definido como o cooperado como pagador eletronico
      --> os demais não econtrara o titulo para o ISPB da coop
      IF nvl(TRIM(pr_idtitdda),0) <> 0 THEN
      
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
        
          --Atualizar Situação
          DDDA0001.pc_requis_atualizar_situacao(pr_cdlegado => vr_cdlegado --Codigo Legado
                                               ,pr_nrispbif => vr_nrispbif --Numero ISPB IF
                                               ,pr_idtitdda => vr_idtitdda --Identificador Titulo DDA
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
              --Se não for a crítica 722, geramos a informação no log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_nmarqlog     => vr_dsarqlg
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate
                                                                   ,'hh24:mi:ss') ||
                                                            ' - ' ||
                                                            'DDDA0001' ||
                                                            ' --> ' ||
                                                            vr_des_erro);
            END IF;
          ELSIF nvl(vr_cdcritic,0) <> 0 AND 
                vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                
          END IF;
          
        
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
          vr_dserrlog := vr_dserrlog || ' - ID Titulo DDA: ' || to_char(vr_idtitdda);
          
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
        IF nvl(pr_flgerlog,0) = 1 THEN
          --Transformar boolean em number
          IF vr_dsreturn = 'OK' THEN
            vr_indtrans := 1;
          ELSE
            vr_indtrans := 0;
          END IF;
          -- Chamar geração de LOG
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
      --Inicializar variaveis
      vr_cdcritic := 0;
      vr_dscritic := '';
      vr_cdderror := NULL;
      vr_dsderror := NULL;
    
      /* se título pago, realizar baixa operacional */
      IF pr_cdsittit IN (3, 4) AND 
         --> e Se nao estiver em contigencia
         rw_cons_titulo.flgcontingencia = 0 THEN 
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
          NPCB0003.pc_wscip_requisitar_baixa(pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                            ,pr_dtmvtolt => pr_dtmvtolt  --> Data de movimento
                                            ,pr_dscodbar => pr_dscodbar  --> Codigo de barra
                                            ,pr_cdctrlcs => pr_cdctrlcs  --> Identificador da consulta
                                            ,pr_idtitdda => vr_idtitdda  --> Identificador Titulo DDA
                                            ,pr_tituloCIP => vr_tituloCIP 
                                            ,pr_flmobile => 0
                                            --,pr_xml_frag => vr_xml --Documento XML referente ao fragmento do XML de resposta do SOAP
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
          ELSIF nvl(vr_cdcritic,0) <> 0 AND 
                vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;          
        
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
        IF nvl(pr_flgerlog,0) = 1 THEN
          --Transformar boolean em number
          IF vr_dsreturn = 'OK' THEN
            vr_indtrans := 1;
          ELSE
            vr_indtrans := 0;
          END IF;
          -- Chamar geração de LOG
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
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_atualz_situac_titulo_sacado. ' ||SQLERRM;
      
    END;
  END pc_atualz_situac_titulo_sacado;

  /* Procedure para calcular código barras */
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
    --  Sistema  : Procedure para calcular código barras
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 02/02/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para calcular código barras
    --
    -- Atualização: 02/02/2015 - Retirado to_number pois no oracle exite o limite de numerico em 38 digitos
    --                           e o numero do codbar é de 44, utilizado expressão regular para verificar numerivos
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
      vr_ftvencto INTEGER := 0;
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      
      IF pr_dtvencto >= to_date('22/02/2025','DD/MM/RRRR') THEN
         vr_ftvencto := (pr_dtvencto - to_date('22/02/2025','DD/MM/RRRR')) + 1000;
      ELSE
         vr_ftvencto := (pr_dtvencto - ct_dtini);
      END IF;      
    
      --Montar o Codigo Barrass
      vr_string := to_char(pr_cdbandoc, 'fm000') || '9' || /* moeda */
                   '1' || /* nao alterar - constante */
                   to_char(vr_ftvencto, 'fm0000') ||
                   to_char(pr_vltitulo * 100, 'fm0000000000') ||
                   to_char(pr_nrcnvcob, 'fm000000') ||
                   To_Char(pr_nrnosnum, 'fm00000000000000000') ||
                   To_Char(pr_cdcartei, 'fm00');
      
      -- Verificar se é só numeros
      IF REGEXP_INSTR( vr_string, '[^[:digit:]]') > 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
      --Calcular Digito Código barras Titulo
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
                               ,pr_tab_remessa_dda IN OUT DDDA0001.typ_tab_remessa_dda --Tabela remessa
                               ,pr_cdcritic        OUT crapcri.cdcritic%TYPE --Codigo de Erro
                               ,pr_dscritic        OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_remessa_dda    Antigo: procedures/b1wgen0088.p/cria-tt-dda
    --  Sistema  : Procedure para atualizar situacao do titulo do sacado eletronico
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 30/11/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para criar remessa DDA
    --
    -- Alterações: 04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir 
    --                          nomenclaturas Cedente por Beneficiário e  Sacado por Pagador  
    --                           Chamado 229313 (Jean Reddiga - RKAM).
    --
    --             16/03/2015 - Ajuste na busca do titular, caso não seja informado deve buscar o principal
    --                          (Odirlei-AMcom)
    --
    --             12/07/2017 - Ajuste na data de desconto, pois conforme documentação da CIP, a data de desconto 
    --                          só pode ser utilizada quando for menor que a data do vencimento. Portanto,
    --                          não será utilizada. (Rafael)
    --
    --             28/07/2017 - Ajuste para nao ler a tabela craptit a partir do codbarras, pois pode gerar segunda via
    --                          será lido a crapret, PRJ340-NPC (Odirlei-AMcom)
    -- 
    --             21/08/2017 - Fechar cursor cr_abertura após abri-lo. (Rafael)
    -- 
    --             20/10/2017 - Retirar cursor cr_abertura e utilizar função fn_datamov (SD#754622 - AJFink)
    --
    --             15/08/2018 - Alterar modelo de cálculo de 04 para 01 (SCTASK0025280 - AJFink)
    --
    --             05/09/2018 - Alterar modelo de cálculo de 01 para 04.
    --                          Mudança para 01 somente poderá ser realizada em 06/10/2018 (INC0023384 - AJFink)
    --
    --             20/09/2018 - Retirar o código fixo do modelo de cálculo e incluir um parâmetro
    --                          para que seja possível alterar o modelo de cálculo de forma on-line
    --                          sem necessidade de liberação do programa. (PRB0040338 - AJFink)
    --
    --             30/11/2018 - Algumas contas estao com o campo cdufsaca cadastrado na CRAPSAB como LOWERCASE
    --                          e este campo é usado para pesquisar em outras tabelas que estão esperando
    --                          como UPPERCASE e ocasiona erro. por isso na consulta da CRAPSAB foi implementado
    --                          o UPPER (Tiago - INC0026317).
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar informacoes sacado
      CURSOR cr_crapsab(pr_cdcooper IN crapsab.cdcooper%type
                       ,pr_nrdconta IN crapsab.nrdconta%type
                       ,pr_nrinssac IN crapsab.nrinssac%type) IS
        SELECT crapsab.cdtpinsc
              ,UPPER(crapsab.cdufsaca) cdufsaca
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
               -- se não foi informado titular, buscar o principal
               AND crapttl.idseqttl = decode(pr_idseqttl,0,1,pr_idseqttl);
      rw_crapttl cr_crapttl%ROWTYPE;
      
      --> buscar dados pessoa juridica
      CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                       ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
        SELECT jur.nmfansia 
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
      
      --> buscar titulo
      CURSOR cr_craptit (pr_cdcooper  craptit.cdcooper%TYPE,
                         pr_dtmvtolt  craptit.dtmvtolt%TYPE,
                         pr_dscodbar  craptit.dscodbar%TYPE ) IS
        SELECT tit.cdagenci,
               tit.nrdconta,
               tit.flgpgdda,
               tit.vldpagto
          FROM craptit tit
         WHERE tit.cdcooper = pr_cdcooper
           AND tit.dtmvtolt = pr_dtmvtolt
           AND tit.dscodbar = pr_dscodbar;
      rw_craptit cr_craptit%ROWTYPE;
      
      /*Rafael Ferreira (Mouts) - INC0022229
          Conforme informado por Deise Carina Tonn da area de Negócio, esta validação não é mais necessária
          pois agora Todas as cidades podem ter protesto*/
      /*-- Buscar praça não executante de protesto
      CURSOR cr_crappnp(pr_nmextcid  crappnp.nmextcid%TYPE
                       ,pr_cduflogr  crappnp.cduflogr%TYPE) IS
        SELECT 1
          FROM crappnp  pnp
         WHERE pnp.nmextcid = pr_nmextcid  
           AND pnp.cduflogr = pr_cduflogr;*/
                       
      --Selecionar informacoes dos bancos
      CURSOR cr_crapban_ispb (pr_nrispbif IN crapban.nrispbif%type) IS
        SELECT crapban.cdbccxlt
          FROM crapban
         WHERE crapban.nrispbif = pr_nrispbif;
      rw_crapban_ispb cr_crapban_ispb%ROWTYPE;           
                       
      --> Verificar motivo da baixa
      CURSOR cr_crapret (pr_dtdpagto crapret.dtocorre%TYPE,
                         pr_cdcooper crapret.cdcooper%TYPE,
                         pr_nrcnvcob crapret.nrcnvcob%TYPE,
                         pr_nrdconta crapret.nrdconta%TYPE,
                         pr_nrdocmto crapret.nrdocmto%TYPE) IS
        SELECT /*+ index (ret CRAPRET##CRAPRET2) */
               ret.cdmotivo
          FROM crapret ret
        WHERE ret.cdcooper = pr_cdcooper
          AND ret.nrcnvcob = pr_nrcnvcob
          AND ret.nrdconta = pr_nrdconta
          AND ret.nrdocmto = pr_nrdocmto
          AND ret.cdocorre IN (6,17,76,77)
          AND ret.dtocorre = pr_dtdpagto
          AND rownum       = 1;
      rw_crapret cr_crapret%ROWTYPE;
      
      --Variaveis Locais
      vr_index    INTEGER;
      vr_cdbarras VARCHAR2(100);
      vr_dsdjuros VARCHAR2(100);
      vr_cddespec VARCHAR2(100);
      vr_nmprimtl crapass.nmprimtl%type;
      vr_nmfansia crapjur.nmfansia%TYPE;
      vr_dsdinstr VARCHAR2(100);
      vr_cdCanPgt INTEGER;
      vr_cdmeiopg INTEGER;
      vr_vlrbaixa crapcob.vldpagto%TYPE;
      vr_flgdprot   crapcob.flgdprot%TYPE;
      vr_qtdiaprt   crapcob.qtdiaprt%TYPE;
      vr_indiaprt   crapcob.indiaprt%TYPE;
      vr_inauxreg   NUMBER;
      vr_dsmsglog   crapcol.dslogtit%TYPE;
      vr_data  VARCHAR2(20) := To_Char(SYSDATE, 'YYYYMMDDHH24MISS');
      vr_datamov number(8);
      vr_tpmodcal varchar2(100);
      
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      
      vr_datamov := fn_datamov;
          
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
      
      --Selecionar registro cobranca
      OPEN cr_crapcco(pr_cdcooper => rw_crapcob.cdcooper,
                      pr_nrconven => rw_crapcob.nrcnvcob);
                      
      --Posicionar no proximo registro
      FETCH cr_crapcco
       INTO rw_crapcco;
      --Se nao encontrar
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;                  
      
      --Selecionar registro convenio de cobranca do cooperado
      OPEN cr_crapceb(pr_cdcooper => rw_crapcob.cdcooper,
                      pr_nrdconta => rw_crapcob.nrdconta,
                      pr_nrconven => rw_crapcob.nrcnvcob);                      
      --Posicionar no proximo registro
      FETCH cr_crapceb
       INTO rw_crapceb;
      --Se nao encontrar
      IF cr_crapceb%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapceb;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapceb;                              
    
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
    
      IF pr_tpoperad = 'I' THEN    
      
        CASE nvl(rw_crapcob.inpagdiv,0)
          WHEN 0 THEN vr_dsmsglog := 'Nao autoriza pagamento divergente para este boleto';
          WHEN 1 THEN vr_dsmsglog := 'Autoriza pagamento minimo no valor de R$ ' || trim(to_char(rw_crapcob.vlminimo,'fm999g999g999d90')) || ' para este boleto';
          WHEN 2 THEN vr_dsmsglog := 'Autoriza pagamento de qualquer valor para este boleto';
        END CASE;
         
        -- Registro autorizacao de pagto divergente no log do boleto
        BEGIN
                      
          INSERT INTO crapcol(cdcooper
                             ,nrdconta
                             ,nrdocmto
                             ,nrcnvcob
                             ,dslogtit
                             ,cdoperad
                             ,dtaltera
                             ,hrtransa)
                       VALUES(rw_crapcob.cdcooper     -- cdcooper
                             ,rw_crapcob.nrdconta     -- nrdconta
                             ,rw_crapcob.nrdocmto     -- nrdocmto
                             ,rw_crapcob.nrcnvcob     -- nrcnvcob
                             ,vr_dsmsglog
                             ,'1'                        -- cdoperad
                             ,TRUNC(SYSDATE)             -- dtaltera
                             ,GENE0002.fn_busca_time()); -- hrtransa
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'PC_CRIA_REMESSA_DDA: Erro ao inserir CRAPCOL: '||SQLERRM;
            RETURN;
        END;
      
        -- Inicializa
        vr_flgdprot := NULL;
        vr_qtdiaprt := NULL;
        vr_indiaprt := NULL;
        
      
        /*Rafael Ferreira (Mouts) - INC0022229
          Conforme informado por Deise Carina Tonn da area de Negócio, esta validação não é mais necessária
          pois agora Todas as cidades podem ter protesto*/
        -- Buscar praça não executante de protesto
        /*OPEN  cr_crappnp(rw_crapsab.nmcidsac
                        ,rw_crapsab.cdufsaca);
        FETCH cr_crappnp INTO vr_inauxreg;*/

        -- Se encontrar registro    
        /*IF cr_crappnp%FOUND THEN
          -- Atribuir o valor as variáveis para atualizar os campos no update
          vr_flgdprot := 0; -- FALSE
          vr_qtdiaprt := 0;
          vr_indiaprt := 3;
        
          -- Inserir o cadastro de log do boleto
          BEGIN
            INSERT INTO crapcol(cdcooper
                               ,nrdconta
                               ,nrdocmto
                               ,nrcnvcob
                               ,dslogtit
                               ,cdoperad
                               ,dtaltera
                               ,hrtransa)
                         VALUES(rw_crapcob.cdcooper     -- cdcooper
                               ,rw_crapcob.nrdconta     -- nrdconta
                               ,rw_crapcob.nrdocmto     -- nrdocmto
                               ,rw_crapcob.nrcnvcob     -- nrcnvcob
                               ,'Obs.: Praca nao executante de protesto' -- dslogtit
                               ,'1'                        -- cdoperad
                               ,TRUNC(SYSDATE)             -- dtaltera
                               ,GENE0002.fn_busca_time()); -- hrtransa
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'PC_CRIA_TITULO: Erro ao inserir CRAPCOL: '||SQLERRM;
              RETURN;
          END;
        END IF;*/
        
        -- Atualizar informações de cobrança
        BEGIN
          UPDATE crapcob cob
             SET cob.flgdprot = NVL(vr_flgdprot,cob.flgdprot)
               , cob.qtdiaprt = NVL(vr_qtdiaprt,cob.qtdiaprt)
               , cob.indiaprt = NVL(vr_indiaprt,cob.indiaprt)
               , cob.idtitleg = seqcob_idtitleg.NEXTVAL
               , cob.idopeleg = seqcob_idopeleg.NEXTVAL
           WHERE ROWID = pr_rowid_cob
           RETURNING cob.idtitleg, cob.idopeleg 
                INTO rw_crapcob.idtitleg, rw_crapcob.idopeleg;
               
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'PC_CRIA_REMESSA_DDA: Erro ao atualizar CRAPCOB: '||SQLERRM;
            RETURN;
        END;
      ELSIF pr_tpoperad IN ('A','B') THEN        
        -- Atualizar informações de cobrança
        BEGIN
          UPDATE crapcob cob
             SET cob.ininscip = 1
               , cob.dhinscip = SYSDATE
               , cob.idopeleg = seqcob_idopeleg.NEXTVAL
           WHERE ROWID = pr_rowid_cob
           RETURNING cob.idtitleg, cob.idopeleg
                INTO rw_crapcob.idtitleg, rw_crapcob.idopeleg;               
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'PC_CRIA_REMESSA_DDA: Erro ao atualizar CRAPCOB: '||SQLERRM;
            RETURN;
        END;
      
      END IF;       
    
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
        
        OPEN cr_crapjur(pr_cdcooper => rw_crapcob.cdcooper
                       ,pr_nrdconta => rw_crapcob.nrdconta);
        FETCH cr_crapjur
         INTO rw_crapjur;        
        
        IF cr_crapjur%NOTFOUND THEN
           vr_nmfansia := substr(vr_nmprimtl,1,80);
        ELSE
           vr_nmfansia := nvl(trim(rw_crapjur.nmfansia),vr_nmprimtl);
        END IF;
        
        CLOSE cr_crapjur;
        
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
                                    ,pr_dtvencto => nvl(rw_crapcob.dtvctori, rw_crapcob.dtvencto) 
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
        vr_dsdinstr := REPLACE(upper(vr_dsdinstr)
                              ,upper('** Servico de protesto sera efetuado pelo Banco do Brasil **')
                              ,'');
      END IF;
      
      vr_cdCanPgt := NULL;
      vr_cdmeiopg := NULL;
      vr_vlrbaixa := NULL;
      
      --> Se for operacao de baixa
      IF pr_tpoperad = 'B' AND 
         rw_crapcob.incobran = 5 THEN 
         
        rw_crapret := NULL;
        --> Verificar motivo da baixa
        OPEN cr_crapret (pr_dtdpagto => rw_crapcob.dtdpagto,
                         pr_cdcooper => rw_crapcob.cdcooper,
                         pr_nrcnvcob => rw_crapcob.nrcnvcob,
                         pr_nrdconta => rw_crapcob.nrdconta,
                         pr_nrdocmto => rw_crapcob.nrdocmto);
        FETCH cr_crapret INTO rw_crapret;
        CLOSE cr_crapret;
               
        CASE rw_crapret.cdmotivo 
          WHEN '33' THEN vr_cdCanPgt := 8; --> DDA
          WHEN '03' THEN vr_cdCanPgt := 1; --> Agências- Postos Tradicionais
          WHEN '32' THEN vr_cdCanPgt := 2; --> Terminal de Auto-Atendimento
          WHEN '31' THEN vr_cdCanPgt := 1; --> Agências- Postos Tradicionais
          WHEN '37' THEN vr_cdCanPgt := 1; --> Agências- Postos Tradicionais
          WHEN '06' THEN vr_cdCanPgt := 3; --> Internet
        ELSE
          vr_cdCanPgt := 8; --> DDA
        END CASE;       
        
        IF nvl(vr_cdCanPgt,0) IN (2,3,8) THEN
          vr_cdmeiopg := 2; --> Débito em conta;
        ELSE
          vr_cdmeiopg := 1; --> Espécie
        END IF;        

        vr_vlrbaixa := rw_crapcob.vldpagto;
        
      END IF;
      
      --Pegar proximo indice remessa
      vr_index := pr_tab_remessa_dda.Count + 1;
      --Criar remessa
      pr_tab_remessa_dda(vr_index).cdcooper := rw_crapcob.cdcooper;
      pr_tab_remessa_dda(vr_index).rowidcob := pr_rowid_cob;
      pr_tab_remessa_dda(vr_index).cdlegado := 'LEG';
      pr_tab_remessa_dda(vr_index).nrispbif := rw_crapban.nrispbif;
      pr_tab_remessa_dda(vr_index).idopeleg := rw_crapcob.idopeleg;
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
      pr_tab_remessa_dda(vr_index).nmfansia := vr_nmfansia; -- nome fantasia
      
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
      
      -- Ajuste devido ao erro EDDA0395 - Data de emissao > Data de referencia
      IF To_Number(To_Char(rw_crapcob.dtmvtolt,'YYYYMMDD')) > to_number(nvl(vr_datamov,to_char(SYSDATE,'YYYYMMDD'))) THEN
        pr_tab_remessa_dda(vr_index).dtemissa := vr_datamov;
      ELSE
        pr_tab_remessa_dda(vr_index).dtemissa := To_Number(To_Char(rw_crapcob.dtmvtolt
                                                                  ,'YYYYMMDD')); 
      END IF;
      
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
      ELSIF rw_crapcco.dsorgarq IN ('EMPRESTIMO','DESCONTO DE TITULO') THEN
        pr_tab_remessa_dda(vr_index).dtlipgto := To_Number(To_Char(pr_dtvencto,'YYYYMMDD'));
        
      ELSIF rw_crapcco.dsorgarq = 'ACORDO' THEN
        pr_tab_remessa_dda(vr_index).dtlipgto := To_Number(To_Char(pr_dtvencto + nvl(rw_crapcco.qtdecate,0),'YYYYMMDD'));                
      ELSE
        pr_tab_remessa_dda(vr_index).dtlipgto := To_Number(To_Char(pr_dtvencto + rw_crapceb.qtdecprz,'YYYYMMDD'));        
      END IF;
      
      pr_tab_remessa_dda(vr_index).indnegoc := 'N';
      pr_tab_remessa_dda(vr_index).vlrabati := pr_vlabatim;
      
      IF rw_crapcob.vljurdia > 0 AND vr_dsdjuros <> '5' THEN
        pr_tab_remessa_dda(vr_index).dtdjuros := To_Number(To_Char(pr_dtvencto + 1
                                                                  ,'YYYYMMDD'));
      ELSE
        pr_tab_remessa_dda(vr_index).dtdjuros := NULL;
      END IF;
      pr_tab_remessa_dda(vr_index).dsdjuros := vr_dsdjuros;
      
      IF rw_crapcob.vljurdia > 0 AND vr_dsdjuros <> '5' THEN
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

      -- conforme documentação da CIP, a data de desconto só pode ser utilizada
      -- quando for menor que a data do vencimento
      -- Portanto, não será utilizada
      pr_tab_remessa_dda(vr_index).dtddesct := NULL;
      
      IF pr_vldescto > 0 THEN
        pr_tab_remessa_dda(vr_index).cdddesct := '1';
      ELSE
        pr_tab_remessa_dda(vr_index).cdddesct := '0';
      END IF;
      pr_tab_remessa_dda(vr_index).vlrdesct := pr_vldescto;
      pr_tab_remessa_dda(vr_index).dsinstru := vr_dsdinstr;
      /* regra nova da CIP - titulos emitidos apos 17/03/2012 sao
      registrados com tipo de calculo "01" (Rafael) */
      vr_tpmodcal := nvl(trim(gene0001.fn_param_sistema('CRED',0,'NPC_MODELO_CALCULO')),'04');--PRB0040338
      IF rw_crapcob.dtmvtolt >= To_Date('03/17/2012', 'MM/DD/YYYY') THEN
        pr_tab_remessa_dda(vr_index).tpmodcal := vr_tpmodcal; --PRB0040338
        --pr_tab_remessa_dda(vr_index).tpmodcal := '04'; -->INC0023384 - CIP calcula boletos a vencer e vencido.
        --pr_tab_remessa_dda(vr_index).tpmodcal := '01'; --SCTASK0025280 - Instituição Recebedora calcula
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
      pr_tab_remessa_dda(vr_index).cdCanPgt := vr_cdCanPgt;
      pr_tab_remessa_dda(vr_index).cdmeiopg := vr_cdmeiopg;
      pr_tab_remessa_dda(vr_index).vldpagto := vr_vlrbaixa;
      
      IF pr_tpoperad IN ('I') THEN
        IF nvl(rw_crapcob.inregcip,0) = 1 THEN
          pr_tab_remessa_dda(vr_index).flonline := 'S';
        ELSE
          pr_tab_remessa_dda(vr_index).flonline := 'N';
        END IF;
      END IF;
      
      IF pr_tpoperad = 'B' OR 
         pr_tpoperad = 'A' THEN
        -- se o tipo de operacao for baixa ou alteracao
        -- deverá ser passado o nr de identificacao NPC e 
        -- o numero de atualizacao NPC do titulo;         
        pr_tab_remessa_dda(vr_index).nrdident := rw_crapcob.nrdident;
        pr_tab_remessa_dda(vr_index).nratutit := rw_crapcob.nratutit;
        
        IF pr_tpoperad = 'B' AND 
           pr_tpdbaixa IN (2,3,4) THEN 
           -- 2 = Bx por solicitacao
           -- 3 = Bx por protesto
           -- 4 = Bx por decurso de prazo 
           pr_tab_remessa_dda(vr_index).nrispbrc := NULL;
           pr_tab_remessa_dda(vr_index).cdpartrc := NULL;
        ELSIF pr_tpoperad = 'B' AND 
              pr_tpdbaixa IN (0,1) THEN 
           -- 0 -- Bx por liquidacao intrabancaria
           -- 1 -- Bx por solicitacao
           pr_tab_remessa_dda(vr_index).nrispbrc := rw_crapcob.nrispbrc;
           
           --Selecionar Banco
           rw_crapban_ispb := NULL;
           OPEN cr_crapban_ispb (pr_nrispbif => rw_crapcob.nrispbrc);
           --Posicionar no proximo registro
           FETCH cr_crapban_ispb INTO rw_crapban_ispb;
           CLOSE cr_crapban_ispb;
           
           pr_tab_remessa_dda(vr_index).cdpartrc := nvl(rw_crapban_ispb.cdbccxlt,0);
        ELSE
           pr_tab_remessa_dda(vr_index).nrispbrc := NULL;
        END IF;  
       
      END IF;
      
      
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
    --  Data     : Novembro/2013.                   Ultima atualizacao: 14/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para verificacao de saque do DDA
    --
    -- Alteração : 26/01/2017 - Alterado tabela de consulta.
    --                          PRJ340 - NPC (Odirlei-AMcom)
    --
    --             04/07/2017 - Incluido Autonomous Transaction pois o select realizado no dblink
    --                          do SQL/Server JDNPC, abre uma transação. (Rafael)
    --
    --             13/07/2017 - Subsituido tabela de pesquisa de pagador DDA tbjdnpccip_pageletr pela
    --                          view VWJDNPCPAG_PAGADOR_ELETRONICO. Motivo: tabela contem menos 
    --                          pagadores DDA que a VIEW. (Rafael)
    --
    --             14/07/2017 - Retirado Autonomous Transacion por orientação dos DBAs. (Rafael)
    ---------------------------------------------------------------------------------------------------------------
    
    --Selecionar dados saque
/*    CURSOR cr_dadosaque(pr_cnpjcpfpagdr IN NUMBER,
                        pr_tppessoa     IN VARCHAR2) IS
      SELECT tbj."SitCliPagdrDDA" DDASitPagEletr
            ,tbj."QtdAdesCliPagdrDDA"      QtdAdesao
        FROM tbjdnpccip_pageletr@jdnpcsql  tbj
       WHERE tbj."CPFCNPJPagdr"  = pr_cnpjcpfpagdr
         AND tbj."TpPessoaPagdr" = pr_tppessoa; */
         
    --Selecionar dados saque
    CURSOR cr_dadosaque(pr_cnpjcpfpagdr IN NUMBER,
                        pr_tppessoa     IN VARCHAR2) IS
      SELECT 
         tbj."DDASitPagEletr" DDASitPagEletr
        ,tbj."QtdAdesao"      QtdAdesao
        FROM VWJDNPCPAG_PAGADOR_ELETRONICO@jdnpcbisql tbj
       WHERE tbj."CNPJCPFPagdr"  = pr_cnpjcpfpagdr
         AND tbj."TpPessoaPagdr" = pr_tppessoa;          
           
    rw_dadosaque cr_dadosaque%ROWTYPE;
  
  BEGIN
    
    --> verificar se as informações foram marcadas corretamente
    IF pr_tppessoa NOT IN ('J','F') OR
       nvl(pr_nrcpfcgc,0) = 0 THEN
      pr_flgsacad := 0; 
    END IF;
  
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
    
    IF cr_dadosaque%ISOPEN THEN
      CLOSE cr_dadosaque;
    END IF;
        
  EXCEPTION
    WHEN OTHERS THEN
      
      IF cr_dadosaque%ISOPEN THEN
        CLOSE cr_dadosaque;
      END IF;
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro gerar DDDA0001.pc_verifica_sacado_DDA: ' ||
                     SQLERRM;
  END pc_verifica_sacado_DDA;

  /* Procedure para verificar se foi sacado do DDA */
  PROCEDURE pc_verifica_sacado_web(pr_tppessoa IN VARCHAR2              -- Tipo de pessoa
                                  ,pr_nrcpfcgc IN NUMBER                -- Cpf ou CNPJ
                                  ,pr_xmllog   IN VARCHAR2              -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         -- Erros do processo

   BEGIN															 
	 /* .............................................................................

     Programa: pc_verifica_sacado_web
     Sistema : Cobrança
     Sigla   : COBR
     Autor   : Jean Michel
     Data    : Junho/17.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente as consultas de sacado DDA.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		
		DECLARE
	
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
	
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_flgsacad INTEGER := 0;
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
         
      DDDA0001.pc_verifica_sacado_DDA(pr_tppessoa => pr_tppessoa
                                     ,pr_nrcpfcgc => pr_nrcpfcgc
                                     ,pr_flgsacad => vr_flgsacad
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><flgsacad>' || TO_CHAR(vr_flgsacad) || '</flgsacad></Root>');

                
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

			  pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

        
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em DDA0001.pc_verifica_sacado_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;

	END pc_verifica_sacado_web;

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
    --                          nomenclaturas Cedente por Beneficiário e  Sacado por Pagador  
    --                          Chamado 229313 (Jean Reddiga - RKAM).
    --                         
    --             20/05/2015 - Alterado para chamar a pc_gerar_mensagem da package GENE0003 e
    --                          não mais da própria DDDA ( Renato - Supero )
    --              
    --             22/02/2016 - Ajustado rotina pois procedimento será chamado via job todos os dias, 
    --                          alterando filtro de data na busca dos novos titulos, e ajustado mensagem para
    --                          exibir corretamente no Internetbank
    --                          SD388026 (Odirlei-AMcom)               
    --
    --              
    --             16/11/2017 - Ajustado mascara no filtro de data para consulta no dblink
    --                          Criado chamada pra procedure de notificação / PUSH DDA
    --                          P356.4 (Ricardo Linhares)                 
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
            ,tit."CodBarras"            CodigoBarras
            ,tit."NomRzSocPagdr"        Pagador
            ,LPAD(ban.cdbccxlt,3,'0') || ' - ' || rtrim(ban.nmresbcc) Banco
        FROM tbjdnpcrcb_pag_agconta@Jdnpcsql pag
            ,tbjdnpcrcb_tit_dados@jdnpcsql   tit
            ,crapban ban
       WHERE tit."ISPBPartDestinatario" = pr_nrispbif
         AND tit."NumIdentcTit" >= to_char(pr_dtemiini, 'yyyymmdd')||'00000000000'
         AND tit."NumIdentcTit" <  to_char(pr_dtemifim, 'yyyymmdd')||'99999999999'         
         AND tit."SitTit" = 01 --> Em aberto
         AND pag."AgCliPagdr" = pr_cdagectl
         AND pag."ISPBPrincipal" = tit."ISPBPartDestinatario"
         AND pag."CPFCNPJPagdr" = tit."CNPJCPFPagdr"
         AND ban.cdbccxlt = tit."CodPartDestinatario"
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
  
    vr_notifi_dda DDDA0001.typ_reg_notif_dda;
  
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
                       
      -- Notificação / Push Mobile
      
      IF(rw_dadostitulo.qttotreg > 1) THEN
         vr_notifi_dda.motivo := MOTIVO_NOVOS_TITULOS_DDA;
      ELSE
           vr_notifi_dda.bancobeneficiario := rw_dadostitulo.banco;  
           vr_notifi_dda.beneficiario := rw_dadostitulo.NomRzSocBenfcrioOr;                    
         vr_notifi_dda.datavencimento := to_date(rw_dadostitulo.dtvenctit,'yyyymmdd');
         vr_notifi_dda.situacao := 'Em aberto';
         vr_notifi_dda.valor := rw_dadostitulo.valor;
         vr_notifi_dda.codigobarras := rw_dadostitulo.codigobarras;        
         vr_notifi_dda.motivo := MOTIVO_NOVO_TITULO_DDA;
      END IF;

         vr_notifi_dda.quantidade := rw_dadostitulo.qttotreg;
       vr_notifi_dda.nomecooperado := rw_dadostitulo.pagador;
       pc_notif_novo_dda(pr_cdcooper  => pr_cdcooper
                  ,pr_nrdconta  => rw_dadostitulo.ctclipagdr
                  ,pr_notif_dda => vr_notifi_dda);
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
                                    ,pr_nmarqlog     => vr_dsarqlg          
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
    
    
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_nmarqlog     => vr_dsarqlg    
                              ,pr_ind_tipo_log => 2
                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                  ' - DDDA0001 -> ' || vr_dscritic);                               
  
  END pc_trata_retorno_erro;   
  
  
  --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
  PROCEDURE pc_ret_inclusao_tit_npc ( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                     ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                     ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                     ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informaçcao
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
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 12/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
    --
    -- Alteracoes: 12/07/2017 - Atualizar motivo A4 na confirmação do boleto na crapret (Rafael)
    ---------------------------------------------------------------------------------------------------------------
  
    ---------->>> CURSORES <<<-----------
    --> buscar boleto
    CURSOR cr_crapcob IS
      SELECT  cob.rowid rowidcob
             ,cob.cdcooper       
             ,cob.nrdconta
             ,cob.nrcnvcob
             ,cob.nrdocmto            
             ,cob.inregcip            
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
    vr_inregcip   crapcob.inregcip%TYPE;
    
    
  BEGIN
  
    --> CDSTIOPE
    --> PJ - Processada no JDNPC
    --> EJ – Erro JDNPC
    --> RC – Operação registrada na CIP-NPC
    --> EC – Erro na CIP-NPC
    --> IC – Informação enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto não encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    vr_insitpro := NULL;
    vr_inenvcip := NULL;
    vr_flgcbdda := NULL;
    vr_dhenvcip := NULL;
    vr_dsmensag := NULL;
    vr_inregcip := NULL;
    
    IF pr_cdstiope = 'PJ' THEN
      vr_insitpro := 2; --> 2-RecebidoJD
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso
      vr_insitpro := 3; --> 3-RC registro CIP
      vr_inenvcip := 3; -- confirmado
      vr_flgcbdda := 1;
      vr_dhenvcip := SYSDATE;
      vr_dsmensag := 'Boleto registrado no Sistema Financeiro Nacional';
    ELSE
      vr_insitpro := 0; --> Sacado comun
      vr_inenvcip := 4; -- Rejeitadp
      vr_flgcbdda := 0;
      vr_dhenvcip := NULL;
      vr_dsmensag := 'Falha ao registrar boleto no Sistema Financeiro Nacional';
      vr_inregcip := 0; -- sem registro na CIP;
    END IF;
    
    --> Atualizar informações do boleto
    BEGIN
      UPDATE crapcob cob
         SET cob.insitpro =  nvl(vr_insitpro,cob.insitpro)
           , cob.flgcbdda =  nvl(vr_flgcbdda,cob.flgcbdda)
           , cob.inenvcip =  nvl(vr_inenvcip,cob.inenvcip)
           , cob.dhenvcip =  nvl(vr_dhenvcip,cob.dhenvcip)
           , cob.inregcip =  nvl(vr_inregcip,cob.inregcip)
           , cob.nrdident =  nvl(pr_idtitnpc,cob.nrdident)           
           , cob.nratutit =  nvl(pr_nratutit,cob.nratutit)
       WHERE cob.rowid    = rw_crapcob.rowidcob;
       
       IF pr_cdstiope = 'RC' THEN
         
         UPDATE crapret ret
            SET cdmotivo = 'A4' || cdmotivo
          WHERE ret.cdcooper = rw_crapcob.cdcooper
            AND ret.nrdconta = rw_crapcob.nrdconta
            AND ret.nrcnvcob = rw_crapcob.nrcnvcob
            AND ret.nrdocmto = rw_crapcob.nrdocmto
            AND ret.cdocorre = 2; -- 2=Confirmacao de registro de boleto
            
        END IF;
        
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
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
      pr_dscritic := 'Não foi possivel processar retorno de inclusao: '||SQLERRM;  
  END pc_ret_inclusao_tit_npc;
  
   --> Procedure para processar o retorno de alteração do titulo do NPC-CIP
  PROCEDURE pc_ret_alteracao_tit_npc( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                     ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                     ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                     ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informaçcao
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
    --> EJ – Erro JDNPC
    --> RC – Operação registrada na CIP-NPC
    --> EC – Erro na CIP-NPC
    --> IC – Informação enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto não encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;
    
    
    IF pr_cdstiope = 'PJ' THEN
      NULL;
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso      
      vr_dsmensag := 'Alteracao de vencimento registrada no Sistema Financeiro Nacional';
      
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
              ,cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;            
    ELSIF pr_cdstiope IN ('EJ','EC') THEN
      vr_dsmensag := 'Alteração de Titulo Rejeitado na CIP';      
    END IF;       
        
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
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
                             
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
              ,cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;                                                                      
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel processar retorno de alteracao: '||SQLERRM;  
  END pc_ret_alteracao_tit_npc;
  
   --> Procedure para processar o retorno de baixa do titulo do NPC-CIP
  PROCEDURE pc_ret_baixa_tit_npc( pr_idtitleg       IN  crapcob.idtitleg%TYPE --> Identificador do titulo no legado
                                 ,pr_idopeleg       IN  crapcob.idopeleg%TYPE --> Identificador da operadao do legado
                                 ,pr_iddopeJD       IN  VARCHAR2              --> Identificador da operadao da JD
                                 ,pr_cdstiope       IN  VARCHAR2              --> Situacao do envio da informaçcao
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
    --> EJ – Erro JDNPC
    --> RC – Operação registrada na CIP-NPC
    --> EC – Erro na CIP-NPC
    --> IC – Informação enviada pela CIP-NPC (Apenas para complemento)
    
    OPEN cr_crapcob;
    FETCH cr_crapcob INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      vr_dscritic := 'Boleto não encontrado';
      CLOSE cr_crapcob;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcob;    
    
    IF pr_cdstiope = 'PJ' THEN
      NULL;
    ELSIF pr_cdstiope = 'RC' THEN --Registrado com sucesso 
      
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.nratutit = nvl(pr_nratutit,cob.nratutit)
              ,cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;            
         
      vr_dsmensag := 'Boleto Baixado no Sistema Financeiro Nacional';                   
    ELSIF pr_cdstiope IN ('EJ','EC') THEN
      vr_dsmensag := 'Baixa de Titulo Rejeitado na CIP';      
    END IF;       
        
    --> Se conter mensagem deve gerar log
    IF trim(vr_dsmensag) IS NOT NULL THEN        
      -- Cria o log da cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowidcob
                                   ,pr_cdoperad => '1'
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
                             
      --> Atualizar informações do boleto
      BEGIN
        UPDATE crapcob cob
           SET cob.ininscip = 2
         WHERE cob.rowid    = rw_crapcob.rowidcob;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_erro;
      END;                                         
      
    END IF;
            
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel processar retorno de baixa: '||SQLERRM;  
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
    --  Data     : Janeiro/2017.                   Ultima atualizacao: 07/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para Executar retorno operacao Titulos NPC
    --
    -- Alteracoes: 07/07/2017 - Ajustado rotina para buscar confirmação/rejeição de títulos da CIP (Rafael)
    --
    ---------------------------------------------------------------------------------------------------------------
    --> Buscar retornos 
    CURSOR cr_retnpc (pr_cdlegado IN tbjdnpcdstleg_jd2lg_optit."CdLeg"@jdnpcbisql%type
                     ,pr_nrispbif IN tbjdnpcdstleg_jd2lg_optit."ISPBAdministrado"@jdnpcbisql%TYPE
                     ,pr_idtitleg IN tbjdnpcdstleg_jd2lg_optit."IdTituloLeg"@jdnpcbisql%TYPE) IS
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
        FROM tbjdnpcdstleg_jd2lg_optit@jdnpcbisql tit
       WHERE tit."CdLeg"            = pr_cdlegado
         AND tit."ISPBAdministrado" = pr_nrispbif
         AND tit."IdTituloLeg"      = pr_idtitleg
         AND tit."TpOpJD"           IN ('RI','RA','RB')
       ORDER BY tit."DtHrOpJD" DESC;
    rw_retnpc cr_retnpc%ROWTYPE;
    
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.cdbcoctl,
             dat.dtmvtolt,
             dat.dtmvtoan
        FROM crapcop cop,
             crapdat dat
       WHERE cop.cdcooper > 0
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1
         AND dat.cdcooper = cop.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    CURSOR cr_tit_pend (pr_cdcooper IN crapcob.cdcooper%TYPE,
                        pr_cdbandoc IN crapcob.cdbandoc%TYPE,
                        pr_dtmvtoan IN crapdat.dtmvtoan%TYPE,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS 
      SELECT cob.idtitleg,
             cob.inenvcip,
             cob.ininscip,
             ret.cdocorre
        FROM crapret ret, 
             crapcob cob, 
             crapcco cco
      WHERE cco.cdcooper = pr_cdcooper
        AND cco.cddbanco = pr_cdbandoc
        AND ret.cdcooper = cco.cdcooper
        AND ret.nrcnvcob = cco.nrconven
        AND ret.dtocorre BETWEEN pr_dtmvtoan AND pr_dtmvtolt
        AND cob.cdcooper = ret.cdcooper
        AND cob.nrcnvcob = ret.nrcnvcob
        AND cob.nrdconta = ret.nrdconta
        AND cob.nrdctabb = cco.nrdctabb
        AND cob.nrdocmto = ret.nrdocmto
        AND cob.cdbandoc = cco.cddbanco
        AND cob.idtitleg > 0
        AND ((cob.inenvcip = 2 AND cob.dtmvtolt BETWEEN pr_dtmvtoan AND pr_dtmvtolt) OR
             (cob.ininscip = 1 AND TRUNC(cob.dhinscip) BETWEEN pr_dtmvtoan AND pr_dtmvtolt));
    rw_tit_pend cr_tit_pend%ROWTYPE;
      
    --Variaveis Locais
    vr_index     INTEGER;
    vr_index_ret INTEGER;
    --Variaveis Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis Excecao
    vr_exc_erro EXCEPTION;   
      
  BEGIN  
    
    FOR rw_crapcop IN cr_crapcop LOOP
  
      FOR rw_tit_pend IN cr_tit_pend (pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_cdbandoc => rw_crapcop.cdbcoctl
                                     ,pr_dtmvtoan => rw_crapcop.dtmvtoan
                                     ,pr_dtmvtolt => rw_crapcop.dtmvtolt) LOOP
                                     
        --> buscar retornos disponibilizados
        FOR rw_retnpc IN cr_retnpc(pr_cdlegado => 'LEG'
                                  ,pr_nrispbif => '5463212'
                                  ,pr_idtitleg => rw_tit_pend.idtitleg ) LOOP
                      
          IF rw_retnpc.tpoperac = 'RI' AND rw_tit_pend.inenvcip = 2 THEN --> Retorno Inclusao          
              --> Procedure para processar o retorno de inclusaon do titulo do NPC-CIP
              pc_ret_inclusao_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                       
            ELSIF rw_retnpc.tpoperac = 'RA' AND rw_tit_pend.ininscip = 1 THEN --> Retorno Alteração
              pc_ret_alteracao_tit_npc (pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                       ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                       ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                       ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                       ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                       ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                       ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                       ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
            
            ELSIF rw_retnpc.tpoperac = 'RB' AND rw_tit_pend.ininscip = 1 THEN --> Retorno Baixa
               pc_ret_baixa_tit_npc ( pr_idtitleg  => rw_retnpc.idtitleg --> Identificador do titulo no legado
                                     ,pr_idopeleg  => rw_retnpc.idopeleg --> Identificador da operadao do legado
                                     ,pr_iddopeJD  => rw_retnpc.iddopeJD --> Identificador da operadao da JD
                                     ,pr_cdstiope  => rw_retnpc.cdstiope --> Situacao do envio da informaçcao
                                     ,pr_idtitnpc  => rw_retnpc.idtitnpc --> Identificador do titulo na CIP-NPC
                                     ,pr_nratutit  => rw_retnpc.nratutit --> Identificador do titulo alteracao na CIP-NPC
                                     ,pr_cdcritic  => vr_cdcritic        --> Codigo de Erro
                                     ,pr_dscritic  => vr_dscritic);      --> Descricao de Erro
                                     
            ELSIF rw_retnpc.tpoperac = 'CO' THEN --> Cancelamento da Baixa Operacional enviada pelo Banco Recebedor
              --> Acão ainda nao definida, será programada em segunda etapa
              NULL;
            ELSIF rw_retnpc.tpoperac = 'JB' THEN --> Baixa Efetiva feita diretamente no JDNPC(Contingência)
              --> Acão ainda nao definida, será programada em segunda etapa
              NULL;
            ELSIF rw_retnpc.tpoperac = 'DP' THEN --> Baixa por Decurso de Prazo
              --> Acão ainda nao definida, será programada em segunda etapa
              NULL; 
            ELSE
              -- Demais tipos de operacao serão ignoradas
              NULL;
          END IF;    
          
          --> verificar se transacao apresentou erro
          IF nvl(vr_cdcritic,0) > 0 OR
             vr_dscritic IS NOT NULL THEN         
            ROLLBACK;
            
            vr_dscritic := 'Erro ao processar retorno idtitleg: '||rw_retnpc.idtitleg||' -> '||
                           vr_dscritic;
                      
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_nmarqlog     => vr_dsarqlg            
                                      ,pr_ind_tipo_log => 2 
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                      ' - DDDA0001 -> ' || vr_dscritic);
             
          END IF; 
                    
          -- Commitar registro por registro processado
          COMMIT;    
        
        END LOOP; -- cr_retnpc
        
        -- Commitar por registro lido no sql server
        COMMIT;            
        
      END LOOP; -- cr_tit_pend
            
    END LOOP; -- cr_crapcop
    
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN    
      ROLLBACK; 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN     
      ROLLBACK;      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic || ' - ' || SQLERRM;      
  
  END pc_retorno_operacao_tit_NPC;

  /* Retorno da remessa da títulos da DDA */
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
    --             15/10/2015 - Alterado para realizar o substr das informações a serem inseridas 
    --                          na tabela TBJDDDALEG_LG2JD_OPTITULO, conforme o tamanho da tabela no SQLServer
    --                          para assim o registro não ser rejeitado no momento do insert SD343420  (Odirlei-AMcom)
    -- 
    --             20/10/2017 - Retirar cursor cr_abertura e utilizar função fn_datamov (SD#754622 - AJFink)
    --
    --             26/10/2017 - Incluir gravacao de log NPCB0001.pc_gera_log_npc no when others
    --                          dos inserts (SD#769996 - AJFink)
    --
    --             02/08/2018 - Alterado mensagem de erro ao gravar no LOG (Alcemir - Mouts / PRB0040064).
    --
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
    
      --Variaveis Locais
      vr_index INTEGER;
      vr_data  VARCHAR2(20) := To_Char(SYSDATE, 'YYYYMMDDHH24MISS');      
      vr_nmfansia_pag VARCHAR2(80);
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_datamov number(8);
      
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_des_erro VARCHAR2(100);
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      vr_flg_erro BOOLEAN;
    BEGIN
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      vr_datamov := fn_datamov;

      IF to_number(to_char(SYSDATE, 'YYYYMMDD')) <> vr_datamov THEN
        vr_data := to_char(vr_datamov)||'235900';
        END IF;
    
      --Percorrer as remessas
      vr_index := pr_tab_remessa_dda.FIRST;
      WHILE vr_index IS NOT NULL LOOP
        
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        vr_flg_erro := FALSE;
        vr_cdcooper := pr_tab_remessa_dda(vr_index).cdcooper;
                
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
        pr_tab_remessa_dda(vr_index).nmfansia := substr(pr_tab_remessa_dda(vr_index).nmfansia,1,40);
        pr_tab_remessa_dda(vr_index).tppessac := substr(pr_tab_remessa_dda(vr_index).tppessac,1,1);
        
        -- Quando pagador é PJ, necessario informar nome fantasia 
        -- É uma novidade pois essa informacao nunca precisou no DDA (Rafael)
        IF pr_tab_remessa_dda(vr_index).tppessac = 'J' THEN
          vr_nmfansia_pag := substr(pr_tab_remessa_dda(vr_index).nmdosaca,1,50);
        ELSE
          vr_nmfansia_pag := NULL;
        END IF;
        
        pr_tab_remessa_dda(vr_index).nrdocsac := substr(pr_tab_remessa_dda(vr_index).nrdocsac,1,14);
        pr_tab_remessa_dda(vr_index).nmdosaca := substr(pr_tab_remessa_dda(vr_index).nmdosaca,1,50);
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
        pr_tab_remessa_dda(vr_index).tpdBaixa := trim(pr_tab_remessa_dda(vr_index).tpdBaixa);
        pr_tab_remessa_dda(vr_index).tpmodcal := substr(pr_tab_remessa_dda(vr_index).tpmodcal,1,2);
        pr_tab_remessa_dda(vr_index).flavvenc := substr(pr_tab_remessa_dda(vr_index).flavvenc,1,1) ;  
        
        IF nvl(trim(substr(pr_tab_remessa_dda(vr_index).flonline,1,1)),'N') = 'N' THEN
          pr_tab_remessa_dda(vr_index).flonline := 'N';
        ELSE
          pr_tab_remessa_dda(vr_index).flonline := 'S'; 
        END IF;
        
        --> Indicador de pagto divergente
        CASE pr_tab_remessa_dda(vr_index).inpagdiv
          WHEN 0 THEN --> 0-nao autoriza
            pr_tab_remessa_dda(vr_index).inpagdiv := 3; --> 3-Não aceitar pagamento com o valor divergente
          WHEN 1 THEN --> 1-autoriza com valor minimo
            pr_tab_remessa_dda(vr_index).inpagdiv := 2; --> 2-Entre o mínimo e o máximo
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
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomFantsBenefcrioOr"
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
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."NomFantsPagdr"
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
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtLimPgto"
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
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CodPartRecbdr"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtHrProcBaixaEft"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."DtProcBaixaEft"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."VlrBaixaEft"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."CanPgto"
            ,TBJDNPCDSTLEG_LG2JD_OPTIT."MeioPagto"
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
            ,pr_tab_remessa_dda(vr_index).nmfansia               --> NomFantsBenefcrioOr
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
            ,vr_nmfansia_pag                                     --> NomFantsPagdr (obs.: obrigatorio para PJ)
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
            ,pr_tab_remessa_dda(vr_index).dtlipgto                   --> DtLimPgto
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
            ,pr_tab_remessa_dda(vr_index).cdpartrc   --> CodPartRecbdr
            ,pr_tab_remessa_dda(vr_index).dhdbaixa               --> DtHrProcBaixaEft
            ,pr_tab_remessa_dda(vr_index).dtdbaixa               --> DtProcBaixaEft
            ,pr_tab_remessa_dda(vr_index).vldpagto   --> VlrBaixaEft
            ,pr_tab_remessa_dda(vr_index).cdCanpgt   --> CanPgto
            ,pr_tab_remessa_dda(vr_index).cdmeiopg   --> MeioPagto
            --> ,pr_tab_remessa_dda(vr_index).   --> NumIdentBOpr
            --> ,pr_tab_remessa_dda(vr_index).   --> NumRefAtlBaixaEft
            );
            
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela TBJDNPCDSTLEG_LG2JD_OPTIT. ' ||
                           sqlerrm;

            --> Gerar log para facilitar identificação de erros SD#769996
            BEGIN
              NPCB0001.pc_gera_log_npc( pr_cdcooper => vr_cdcooper,
                                        pr_nmrotina => 'pc_remessa_titulos_dda',
                                        pr_dsdolog  => 'CodBar:'||pr_tab_remessa_dda(vr_index).dscodbar||'-'||vr_dscritic);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END; 

            pr_tab_remessa_dda(vr_index).cdcritic := vr_cdcritic;
            pr_tab_remessa_dda(vr_index).dscritic := vr_dscritic;
            
            PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_tab_remessa_dda(vr_index).rowidcob
                                         ,pr_cdoperad => '1'
                                         ,pr_dtmvtolt => SYSDATE
                                         ,pr_dsmensag => 'Erro ao integrar instrução na cabine JDNPC (OPTIT)'
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_dscritic => vr_dscritic);
            
            
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

              --> Gerar log para facilitar identificação de erros SD#769996
              BEGIN
                NPCB0001.pc_gera_log_npc( pr_cdcooper => vr_cdcooper,
                                          pr_nmrotina => 'pc_remessa_titulos_dda',
                                          pr_dsdolog  => 'CodBar:'||pr_tab_remessa_dda(vr_index).dscodbar||'-'||vr_dscritic);
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;

              pr_tab_remessa_dda(vr_index).cdcritic := vr_cdcritic;
              pr_tab_remessa_dda(vr_index).dscritic := vr_dscritic;                           
              
              PAGA0001.pc_cria_log_cobranca(pr_idtabcob => pr_tab_remessa_dda(vr_index).rowidcob
                                           ,pr_cdoperad => '1'
                                           ,pr_dtmvtolt => SYSDATE
                                           ,pr_dsmensag => 'Erro ao integrar instrução na cabine JDNPC (CTRL)'
                                           ,pr_des_erro => vr_des_erro
                                           ,pr_dscritic => vr_dscritic);                        
              --Levantar Excecao
              vr_flg_erro := TRUE;
          END;
        END IF;
        
        --Encontrar proximo registro
        vr_index := pr_tab_remessa_dda.NEXT(vr_index);
      END LOOP;
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina DDDA0001.pc_remessa_titulos_dda. ' ||
                       SQLERRM;

        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_nmarqlog     => vr_dsarqlg        
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                      ' - DDDA0001 -> ' || pr_dscritic);                       
    END;
  END pc_remessa_titulos_dda;
  
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

  /* SubRotina para converter as informações da global temporary table
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
        -- Varrer as informações da tabela
        FOR rw_retorno IN cr_wt_retorno_dda LOOP
          -- Guardar o contador para inserção
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

  /* SubRotina para converter as informações da global temporary table
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
        -- Varrer as informações da tabela
        FOR rw_remessa IN cr_wt_remessa_dda LOOP
          -- Guardar o contador para inserção
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
  em PLSQL através da rotina Progress via DataServer */
  /*PROCEDURE pc_retorno_operacao_tit_DDA(pr_cdcritic OUT crapcri.cdcritic%TYPE
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
  
    -- Objetivo  : O processo de comunicação com o JD-DDa não funciona corretamente em execucoes
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
      -- Após, faremos o mesmo esquema, so que dessa vez com os
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
        -- Se não houver critica
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
*/
  /* Procedure para chamar a rotina pc_remessa_titulos_dda
  em PLSQL através da rotina Progress via DataServer */
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
  
    -- Objetivo  : O processo de comunicação com o JD-DDa não funciona corretamente em execucoes
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
    
      -- Após, faremos o mesmo esquema, so que dessa vez com os
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
        -- Se não houver critica
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

  /* Procedure para realizar a baixa efetiva NPC */
  PROCEDURE pc_baixa_efetiva_npc( pr_rowid_cob IN ROWID --ROWID da Cobranca
                                       ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --Codigo de Erro
                                       ,pr_dscritic  OUT VARCHAR2) IS --Descricao de Erro
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_baixa_efetiva_npc    Antigo: procedures/b1wgen0088.p/liquidacao-intrabancaria-dda
    --  Sistema  : 
    --  Sigla    : CRED
    --  Autor    : Alisson C. Berrido - Amcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para realizar realizar a baixa efetiva NPC
    --
    -- Alteração : 28/07/2017 - Alterado o nome da rotina de pc_liquid_intrabancaria_dda para pc_baixa_efetiva_npc,
    --                          pois será utilizada tanto para intra quanto para interbancaria.
    --                          PRJ340 - NPC (Odirlei-AMcom)
    -- 
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
                                    ,pr_tpdbaixa        => CASE WHEN (rw_crapcob.cdbanpag = 85) OR 
                                                                     (rw_crapcob.cdbanpag = 11 AND rw_crapcob.indpagto <> 0) THEN '1' 
                                                           ELSE 
                                                             '0' 
                                                           END --Tipo de baixa
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
        pr_dscritic := 'Erro na rotina DDDA0001.pc_baixa_efetiva_npc. ' ||
                       SQLERRM;
    END;
  END pc_baixa_efetiva_npc;

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
      vr_dsAssunt := 'JD – Adesão cobrança BNF';
    ELSIF pr_tpalerta = 2 THEN
      vr_dsAssunt := 'JDBNF – Novo Cooperado – Tela MATRIC';
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
       
      
      vr_dsdcorpo := 'Favor verificar o status de convênios de cobrança do cooperado abaixo:<br>'||
                     'Nome/Razão social do Cooperado: '|| rw_crapass.nmprimtl            ||'<br>'||
                     'CPF/CNPJ: '                      || gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)     ||'<br>'|| 
                     'Número da Conta do Cooperado: '  || pr_nrdconta                    ||'<br>'||
                     'Número do convênio pendente: '   || pr_nrconven                    ||'<br>'||
                     'Data que houve a habilitação inicial: '|| to_char(rw_crapceb.dtcadast,'DD/MM/RRRR') ||'<br>'||                         
                     'Cooperativa: '|| nvl(rw_crapass.nmrescop,pr_cdcooper)                               ||'<br>';       
    
      -->  Buscar destinatario de email
      vr_dsdemail_dst := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                    pr_cdcooper => pr_cdcooper, 
                                                    pr_cdacesso => 'EMAIL_CONV_PENDENTE');                                                    
                                                    
      --> Enviar Email
      GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                ,pr_cdprogra        => 'COBRANCA'     --> Programa conectado
                                ,pr_des_destino     => nvl(vr_dsdemail_dst,'segurancacorporativa@ailos.coop.br')  --> Um ou mais detinatários separados por ';' ou ','
                                ,pr_des_assunto     => vr_dsAssunt    --> Assunto do e-mail
                                ,pr_des_corpo       => vr_dsdcorpo    --> Corpo (conteudo) do e-mail
                                ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
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
    --
    --            02/08/2018 - valida se ocorreu erro na pltable pr_tab_remessa_dda, depois de executar 
    --                         a proc pc_remessa_titulos_dda (Alcemir - Mout's / PRB0040064).
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
      
      IF pr_tab_remessa_dda.COUNT > 0 THEN         
        IF pr_tab_remessa_dda(pr_tab_remessa_dda.FIRST).dscritic IS NOT NULL THEN 
          
           vr_dscritic := 'Erro ao integrar instrução, tente novamente mais tarde.';           
           vr_cdcritic := pr_tab_remessa_dda(pr_tab_remessa_dda.FIRST).cdcritic;
                      
           RAISE vr_exc_erro;
        END IF;
      END IF;
                  
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

  --> Procedimento para retornar situação do beneficiario na cabine JD
  PROCEDURE pc_ret_sit_beneficiario(pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                    pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                    pr_insitif  OUT VARCHAR2,               --> Retornar situação IF
                                    pr_insitcip OUT VARCHAR2,               --> Retorna situação na CIP
                                    pr_dscritic OUT VARCHAR2) IS            --> Retorna critica
    /* .............................................................................
    
        Programa: pc_ret_sit_beneficiario
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana - AMcom
        Data    : Maio/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Procedimento para retornar situação do bebeficioando na cabine JD
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Cursor para buscar situacao do benificiario na cip
    CURSOR cr_DDA_Sit_Ben (pr_dspessoa VARCHAR2,
                           pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT b."SITIF",
             b."SITCIP"
        FROM cecredleg.VWJDDDABNF_Sit_Beneficiario@Jdnpcsql b
       WHERE b."TpPessoaBenfcrio" = pr_dspessoa
         AND b."CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
    rw_DDA_Sit_Ben cr_DDA_Sit_Ben%ROWTYPE; 
  BEGIN
    
    --> Buscar situação do beneficiario na cabine
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
  
  --> Rotina para verificar situação do cooperado na cabine e enviar email
  PROCEDURE pc_verifica_sit_JDBNF (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa
                                   pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                   pr_inpessoa  IN crapass.inpessoa%TYPE,  --> Tipo de pessoa
                                   pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,  --> CPF/CNPJ do beneficiario
                                   pr_insitif  OUT VARCHAR2,               --> Retornar situação IF
                                   pr_insitcip OUT VARCHAR2,               --> Retorna situação na CIP
                                   pr_dscritic OUT VARCHAR2) IS            --> Retorna criticaIS
  
  /* .............................................................................
    
        Programa: pc_verifica_sit_JDBNF
        Sistema : CECRED
        Sigla   : COBRAN
        Autor   : Odirlei Busana - AMcom
        Data    : Maio/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para verificar situação do cooperado na cabine e enviar email
    
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
  
    --> Retornar situação do beneficiario na cabine JD
    pc_ret_sit_beneficiario(pr_inpessoa  => pr_inpessoa,  --> Tipo de pessoa
                            pr_nrcpfcgc  => pr_nrcpfcgc,  --> CPF/CNPJ do beneficiario
                            pr_insitif   => pr_insitif,   --> Retornar situação IF
                            pr_insitcip  => pr_insitcip,  --> Retorna situação na CIP
                            pr_dscritic  => vr_dscritic); --> Retorna critica    
    
    IF vr_dscritic IS NOT NULL THEN
      NULL;
    END IF; 
    
    --> SITIF => “I” (Inapto) ou “E” (em análise), enviar e-mail para segurança corportativa;
    --> SITIF sem status e SITCIP = “I” ou “E”, enviar e-mail para segurança corportativa;
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

  --> Rotina para atualizar situação do cooperado na cabine JDBNF  
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
    
        Objetivo  : Rotina para atualizar situação do cooperado na cabine JDBNF 
    
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
        FROM cecredleg.TBJDDDABNF_BeneficiarioIF@jdnpcsql b
       WHERE b.ISPB_IF = '5463212'
         AND "TpPessoaBenfcrio" = pr_dspessoa
         AND "CNPJ_CPFBenfcrio" = pr_nrcpfcgc;
    rw_DDA_Benef cr_DDA_Benef%ROWTYPE;    
    
    --> Cursor para verificar se ja existe o convenio na cip
    CURSOR cr_DDA_Conven (pr_dspessoa VARCHAR2,
                          pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                          pr_nrconven VARCHAR2) IS      
      SELECT 1
        FROM cecredleg.TBJDDDABNF_Convenio@jdnpcsql b
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
      IF cr_DDA_Benef%ISOPEN THEN
        CLOSE cr_DDA_Benef;
      END IF;
      IF rw_crapass.inpessoa = 2 THEN
        --> Buscar dados pessoa juridica
        OPEN cr_crapjur (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        CLOSE cr_crapjur;
      END IF;  
                    
      BEGIN
        INSERT INTO cecredleg.TBJDDDABNF_BeneficiarioIF@jdnpcsql
              ( "ISPB_IF",
                "TpPessoaBenfcrio",
                "CNPJ_CPFBenfcrio",
                "Nom_RzSocBenfcrio", 
                "Nom_FantsBenfcrio", 
                "DtInicRelctPart",    
                "DtFimRelctPart")
        VALUES ('05463212'            -- ISPB_IF
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
    
      IF cr_DDA_Benef%ISOPEN THEN
        CLOSE cr_DDA_Benef;
      END IF;
    
      -- Atualizar convenio na CIP  
      BEGIN      
        vr_nrconven := to_char(pr_nrconven);
        UPDATE cecredleg.TBJDDDABNF_Convenio@jdnpcsql
           SET cecredleg.TBJDDDABNF_Convenio."SitConvBenfcrioPar" = 'A',
               cecredleg.TBJDDDABNF_Convenio."DtInicRelctConv"    = vr_dtativac,
               cecredleg.TBJDDDABNF_Convenio."DtFimRelctConv"     = vr_dtfimrel
         WHERE cecredleg.TBJDDDABNF_Convenio."ISPB_IF" = '05463212'
           AND cecredleg.TBJDDDABNF_Convenio."TpPessoaBenfcrio" = rw_crapass.dspessoa
           AND cecredleg.TBJDDDABNF_Convenio."CNPJ_CPFBenfcrio" = rw_crapass.dscpfcgc
           AND cecredleg.TBJDDDABNF_Convenio."CodCli_Conv"      = vr_nrconven
           AND cecredleg.TBJDDDABNF_Convenio."AgDest"           = rw_crapass.cdagectl
           AND cecredleg.TBJDDDABNF_Convenio."CtDest"           = rw_crapass.nrdconta;
        
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;
    
    IF cr_DDA_Benef%ISOPEN THEN
      CLOSE cr_DDA_Benef;
    END IF;
    
    --> Verificar se ja existe o convenio na cip
    OPEN cr_DDA_Conven (pr_dspessoa => rw_crapass.dspessoa,
                        pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                        pr_nrconven => to_char(pr_nrconven));
    FETCH cr_DDA_Conven INTO rw_DDA_Conven;
    IF cr_DDA_Conven%NOTFOUND THEN
      
      IF cr_DDA_Conven%ISOPEN THEN
        CLOSE cr_DDA_Conven;
      END IF;

      --> Gerar informação de adesão de convênio ao JDBNF                            
      BEGIN
        INSERT INTO cecredleg.TBJDDDABNF_Convenio@jdnpcsql
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
             VALUES('05463212',                             -- ISPB_IF
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
        
        IF cr_DDA_Conven%ISOPEN THEN
          CLOSE cr_DDA_Conven;
        END IF;
        
        UPDATE cecredleg.TBJDDDABNF_Convenio@jdnpcsql a
           SET a."SitConvBenfcrioPar" = vr_sitifcnv
              ,a."DtInicRelctConv"    = vr_dtativac
              ,a."DtFimRelctConv"     = vr_dtfimrel
         WHERE a."ISPB_IF"            = '05463212'
           AND a."TpPessoaBenfcrio"   = rw_crapass.dspessoa
           AND a."CNPJ_CPFBenfcrio"   = rw_crapass.dscpfcgc
           AND a."CodCli_Conv"        = vr_nrconven;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Nao foi possivel atualizar convenio na CIP: ' || SQLERRM;
            RAISE vr_exc_saida;              
        END;            
    END IF;
    
    IF cr_DDA_Conven%ISOPEN THEN
      CLOSE cr_DDA_Conven;
    END IF;
    
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

  /* Procedure para requisitar a consulta de retorno de dados da baixa operacional */
  PROCEDURE pc_ConsultarBaixaOperacional(pr_cdctrbxo IN VARCHAR2                     --> Numero controle participante da baixa operacional
                                        ,pr_cdcodbar IN VARCHAR2                     --> Codigo de barras do titulo
                                        ,pr_baixaope OUT cr_baixaoperacional%ROWTYPE --> retornar dados da baixa operacional
                                        ,pr_idbxapdn OUT NUMBER                      --> Indica comunicação de baixa pendente
                                        ,pr_des_erro OUT VARCHAR2                    --> Indicador erro OK/NOK
                                        ,pr_dscritic OUT VARCHAR2) IS                --> Descricao erro
    /*---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_ConsultarBaixaOperacional     
    --  Sistema  : CECRED
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Maio/2017.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure para requisitar a consulta de retorno de dados da baixa operacional
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      
      
      --------> CURSOR <-----------      
      rw_baixaoperacional cr_baixaoperacional%ROWTYPE;
      
      vr_xml XMLType; --> XML de requisição
      vr_exc_erro EXCEPTION; --> Controle de exceção
      
      vr_xml_res XMLType; --> XML de resposta
      vr_tab_xml gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
      vr_ctrlpart VARCHAR2(20);
      
      vr_tbcampos      NPCB0003.typ_tab_campos_soap;
      vr_dsxmlbxo      CLOB;
    
    BEGIN
    
      -- Inicializar com valor padrão de retorno
      pr_idbxapdn := 0; 
    
      -- Limpa a tab de campos
      vr_tbcampos.DELETE();
      
      -- Chama rotina para fazer a inclusão das TAGS comuns
      NPCB0003.pc_xmlsoap_tag_padrao(pr_tbcampos => vr_tbcampos
                                    ,pr_des_erro => pr_des_erro
                                    ,pr_dscritic => pr_dscritic );
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCtrlPart';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdctrbxo;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'int';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCodBarras';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := pr_cdcodbar;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
     
      NPCB0003.pc_xmlsoap_monta_requisicao( pr_cdservic => 4  --> RecebimentoPgtoTit
                                           ,pr_cdmetodo => 6  --> ConsultarRetornoBaixaOperacional
                                           ,pr_tbcampos => vr_tbcampos
                                           ,pr_xml      => vr_xml
                                           ,pr_des_erro => pr_des_erro
                                           ,pr_dscritic => pr_dscritic);
    
      -- Verifica se ocorreu erro
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF; 
    
      -- Enviar requisição para webservice
      soap0001.pc_cliente_webservice(pr_endpoint    => NPCB0003.fn_url_SendSoapNPC(pr_idservic => 4)
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
      
        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha na atualizacao da situacao.';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      -- Se passou pela validação de erros sem encontrar retorno do Fault Packet, deve retornar o XML
      vr_dsxmlbxo := REPLACE( REPLACE(vr_xml_res.getClobVal(),'&lt;','<') ,'&gt;','>');
      
      --> Ler as baixas operacionais
      OPEN cr_baixaoperacional( pr_dsxml => vr_dsxmlbxo);
      FETCH cr_baixaoperacional INTO rw_baixaoperacional;
      
      IF cr_baixaoperacional%NOTFOUND THEN
        CLOSE cr_baixaoperacional;        
        pr_dscritic := 'Dados da baixa operacional nao localizados.';
        RAISE vr_exc_erro;        
      END IF;
      CLOSE cr_baixaoperacional;
      
      pr_baixaope := rw_baixaoperacional;
      
      IF rw_baixaoperacional.SitBaixaOperacional <> 3 THEN
        pr_dscritic := 'Baixa operacional pendente de processamento, favor aguarde.';
        
        -- Se for encerrar porque a baixa ainda está pendente, deve retornar flag indicando
        pr_idbxapdn := 1; -- indica que baixa está pendente
        
        RAISE vr_exc_erro;   
      END IF;
      
      
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_ConsultarBaixaOperacional. ' ||
                       SQLERRM;
    END;
  END pc_ConsultarBaixaOperacional;


  /* Procedure para Cancelar Baixa Operacional  - Demetrius Wolff - Mouts */
  PROCEDURE pc_cancelar_baixa_operac (pr_cdlegado IN VARCHAR2   --> Codigo Legado
                                     ,pr_idtitdda IN VARCHAR2   --> Identificador Titulo DDA
                                     ,pr_cdctrlcs IN VARCHAR2   --> Numero controle consulta NPC
                                     ,pr_cdcodbar IN VARCHAR2   --> Codigo de barras do titulo
                                     ,pr_idpenden IN OUT NUMBER --> Indica o processamento da pendencia
                                     ,pr_des_erro OUT VARCHAR2  --> Indicador erro OK/NOK
                                     ,pr_dscritic OUT VARCHAR2) IS --> Descricao erro
  BEGIN
    DECLARE
    
      vr_xml         XMLType; --> XML de requisição      
      vr_exc_erro    EXCEPTION; --> Controle de exceção
      vr_xml_res     XMLType; --> XML de resposta
      vr_tab_xml     gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
      vr_cdcanal_npc INTEGER;                           
      vr_ctrlpart    VARCHAR2(20);
      
      vr_tbcampos      NPCB0003.typ_tab_campos_soap;
      vr_cdCanPgt      INTEGER;
      vr_cdmeiopg      INTEGER;
      vr_baixaope      cr_baixaoperacional%ROWTYPE;
      vr_idbxapdn      NUMBER;
      vr_cdctrbxo      VARCHAR2(100);
      
      -- Gravar o registro de pendencia da baixa operacional
      PROCEDURE pc_registra_pend_baixa(pr_cdlegado  IN VARCHAR2      --> Codigo Legado
                                      ,pr_cdctrlcs  IN VARCHAR2      --> Numero controle consulta NPC
                                      ,pr_cdcodbar  IN VARCHAR2      --> Codigo de barras do titulo
                                      ,pr_des_erro OUT VARCHAR2) IS --> Descricao erro
        PRAGMA AUTONOMOUS_TRANSACTION;
      
      BEGIN
        -- Inserir registro na tabela de pendencia de baixa
        INSERT INTO tbcobran_baixa_pendente(cdlegado
                                           ,cdctrlcs
                                           ,cdcodbar
                                           ,dhsolicita_baixa
                                           ,insituacao_solicitacao
                                           ,dhultima_solicitacao
                                           ,qttentativa_baixa)
                                     VALUES(pr_cdlegado   -- cdlegado
                                           ,pr_cdctrlcs   -- cdctrlcs
                                           ,pr_cdcodbar   -- cdcodbar
                                           ,SYSDATE       -- dhsolicita_baixa
                                           ,0 -- Pendente -- insituacao_solicitacao
                                           ,NULL          -- dhultima_solicitacao
                                           ,0);           -- qttentativa_baixa
            
        -- retornar o ok para rotina chamadora
        pr_des_erro := 'OK';
        
        -- Comitar a inclusão da pendencia de baixa
        COMMIT;
                                    
      EXCEPTION
        WHEN OTHERS THEN
          -- Ocorrendo erro de inclusão, deve retornar a mensagem padrão 
          pr_dscritic := 'NOK';
      END pc_registra_pend_baixa;
            
    BEGIN
    
      --> Consulta de retorno de dados da baixa operacional 
      pc_ConsultarBaixaOperacional(pr_cdctrbxo => pr_cdctrlcs   --> Numero controle participante da baixa operacional
                                  ,pr_cdcodbar => pr_cdcodbar   --> Codigo de barras do titulo
                                  ,pr_baixaope => vr_baixaope   --> retornar dados da baixa operacional
                                  ,pr_idbxapdn => vr_idbxapdn   --> Indica se a baixa operacional está pendente
                                  ,pr_des_erro => pr_des_erro   --> Indicador erro OK/NOK
                                  ,pr_dscritic => pr_dscritic); --> Descricao erro
    
      -- Verifica se ocorreu erro e .. se não for de baixa pendente ou for processamento de pendencia
      IF    pr_des_erro != 'OK' AND (NVL(vr_idbxapdn,0) = 0 OR pr_idpenden = 1 )  THEN
        
        -- Se o erro ocorreu devido a pendencia de baixa
        IF NVL(vr_idbxapdn,0) = 1 THEN
          -- Indica que o erro retornado é de pendencia de baixa
          pr_idpenden := 1;
        ELSE
          -- Indica que o erro retornado NÃO é de pendencia de baixa
          pr_idpenden := 0;
        END IF;
      
        RAISE vr_exc_erro;
      -- Se o erro retornado for referente a baixa pendente
      ELSIF pr_des_erro != 'OK' AND NVL(vr_idbxapdn,0) = 1 THEN
        pr_des_erro := NULL;  
      
        -- Rotina para registrar a pendencia de baixa
        pc_registra_pend_baixa(pr_cdlegado => pr_cdlegado
                              ,pr_cdctrlcs => pr_cdctrlcs
                              ,pr_cdcodbar => pr_cdcodbar
                              ,pr_des_erro => pr_des_erro);
      
        -- Se houver retorno de erro
      IF pr_des_erro != 'OK' THEN
          -- Deve seguir o processo criticando o estorno - Será apresentada a critica da pc_ConsultarBaixaOperacional
        RAISE vr_exc_erro;
      END IF;
    
        -- Se não houve erros, deve limpar as criticas e retornar
        pr_des_erro := 'OK';
        pr_dscritic := NULL;
        
        RETURN;
        
      END IF;
      
      -- Retornar zero, pois se houver algum erro não é da pendencia
      pr_idpenden := 0;
      
      --> NumCtrlPart
      vr_ctrlpart := fn_gera_ctrlpart('C');

      -- Limpa a tab de campos
      vr_tbcampos.DELETE();
      
      -- Chama rotina para fazer a inclusão das TAGS comuns
      NPCB0003.pc_xmlsoap_tag_padrao(pr_tbcampos => vr_tbcampos
                                    ,pr_des_erro => pr_des_erro
                                    ,pr_dscritic => pr_dscritic );
        
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'EnvioImediato';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := 'S';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumCtrlPart';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag :=  vr_ctrlpart;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'NumIdentcBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag :=  vr_baixaope.NumIdentcBaixaOperac;
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtHrCanceltBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE,'RRRRMMDDHH24MISS'); --> AAAAMMDDhhmmss
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      vr_tbcampos(vr_tbcampos.COUNT()+1).dsNomTag := 'DtProcCanceltBaixaOperac';
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsValTag := to_char(SYSDATE,'RRRRMMDD');
      vr_tbcampos(vr_tbcampos.COUNT()  ).dsTypTag := 'string';
      --
      -- Monta a estrutura principal do SOAP
      NPCB0003.pc_xmlsoap_monta_requisicao(pr_cdservic => 4 --> RecebimentoPgtoTit
                                          ,pr_cdmetodo => 5 --> CancelarBaixa
                                          ,pr_tbcampos => vr_tbcampos
                                          ,pr_xml      => vr_xml     
                                          ,pr_des_erro => pr_des_erro
                                          ,pr_dscritic => pr_dscritic);      
    
      -- Verifica se ocorreu erro
      IF pr_des_erro != 'OK' THEN
        RAISE vr_exc_erro;
      END IF;      
    
      -- Enviar requisição para webservice
      soap0001.pc_cliente_webservice(pr_endpoint    => NPCB0003.fn_url_SendSoapNPC(pr_idservic => 4)
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
      
        -- Verifica se retorno conteúdo na TAG
        IF nvl(vr_tab_xml(0).tag, ' ') = ' ' THEN
          pr_dscritic := 'Falha na atualizacao da situacao.';
          pr_des_erro := 'NOK';
        
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
      -- Retornar fragmento XML como novo documento XML
      --Valor não utilizado
      --pr_xml_frag := gene0007.fn_gera_xml_frag(vr_tab_xml(0).tag); 
    
      --Retornar OK
      pr_des_erro := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        pr_dscritic := pr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro na rotina DDDA0001.pc_cancelar_baixa_operac. ' ||
                       SQLERRM;
    END;
  END pc_cancelar_baixa_operac;

  PROCEDURE pc_notif_novo_dda (pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_notif_dda IN typ_reg_notif_dda) IS 
  BEGIN
    DECLARE
      ORIGEM_NOVO_DDA CONSTANT tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 4;
      vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    BEGIN

      vr_variaveis_notif('#nomecooperado') := pr_notif_dda.nomecooperado;
      vr_variaveis_notif('#quantidade') := pr_notif_dda.quantidade;

      IF(pr_notif_dda.motivo = MOTIVO_NOVO_TITULO_DDA) THEN
        vr_variaveis_notif('#bancobeneficiario') := pr_notif_dda.bancobeneficiario;
        vr_variaveis_notif('#beneficiario') := pr_notif_dda.beneficiario;
        vr_variaveis_notif('#datavencimento') := to_char(pr_notif_dda.datavencimento,'DD/MM/RRRR');
        vr_variaveis_notif('#situacao') := pr_notif_dda.situacao;      
        vr_variaveis_notif('#valorboleto') := to_char(pr_notif_dda.valor,'fm999G999G990D00'); 
        vr_variaveis_notif('#codbarras') := pr_notif_dda.codigobarras;
      END IF;
      
      NOTI0001.pc_cria_notificacao(pr_cdorigem_mensagem => ORIGEM_NOVO_DDA
                                  ,pr_cdmotivo_mensagem => pr_notif_dda.motivo
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_variaveis => vr_variaveis_notif);      


    END;
  END pc_notif_novo_dda;

  /* Procedure para processar pendencia de cancelamento de baixa operacional */
  PROCEDURE pc_pendencia_cancel_baixa(pr_dsrowid   IN VARCHAR2) IS     -- Rowid do registro a ser processado
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_pendencia_cancel_baixa
    --  Sistema  : Procedure para tentar processar a solicitação de cancelamento de baixa que está pendente
    --  Sigla    : CRED
    --  Autor    : Renato Darosci
    --  Data     : Julho/2018.                   Ultima atualizacao: --/--/----
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Tentar efetuar a comunicação do cancelamento da baixa do titulo e caso não seja possível 
    --             reagendar um job para tentar novamente depois de determinado tempo
    ---------------------------------------------------------------------------------------------------------------
    
    -- CONSTANTES
    vr_cdcooper   CONSTANT NUMBER := 3; -- Rodará sempre como CENTRAL
    vr_nrminuto   CONSTANT NUMBER := 1 / 24 / 60; -- Fator referente à 1 minuto
    
    -- Buscar os dados da requisição a ser processada
    CURSOR cr_pendencia IS
      SELECT tb.*
        FROM tbcobran_baixa_pendente tb
       WHERE tb.rowid = pr_dsrowid;
    rg_pendencia    cr_pendencia%ROWTYPE;
    
    -- Buscar parametro
    CURSOR cr_crappco IS 
      SELECT to_date(to_char(SYSDATE,'DD/MM/YYYY')||' '||t.dsconteu,'DD/MM/YYYY HH24:MI') dtlimite
        FROM crappco t
       WHERE t.cdcooper = vr_cdcooper -- Será cadastrado o parametro de forma geral para todas as coops
         AND t.cdpartar = 57;         -- Código do parametro
    
    -- VARIÁVEIS
    vr_exc_erro   EXCEPTION;
    
    vr_dtprxexc   DATE;
    vr_dtlimite   DATE;
    vr_nrdifere   NUMBER; 
    vr_idpenden   NUMBER;
    vr_insituac   NUMBER;
    vr_des_erro   VARCHAR2(10);
    vr_dscritic   VARCHAR2(1000);
    vr_dsnomjob   VARCHAR2(100);
    vr_dsdplsql   VARCHAR2(30000);
    
  BEGIN
    
    -- Buscar os dados da pendencia
    OPEN  cr_pendencia;
    FETCH cr_pendencia INTO rg_pendencia;
    
    -- Se a pendencia não foi encontrada
    IF cr_pendencia%NOTFOUND THEN
      CLOSE cr_pendencia;
      vr_dscritic := 'Pendência de baixa operacional não encontrada.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechamento do cursor
    CLOSE cr_pendencia;
  
    -- Verifica se a pendencia ainda não foi processada
    IF rg_pendencia.insituacao_solicitacao <> 0 THEN
      vr_dscritic := 'Pendência de baixa operacional já foi processada.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Na chamada da rotina de baixa, indicar que o processamento é de uma pendencia de baixa
    vr_idpenden := 1;
    
    -- Chama rotina de baixa operacional
    DDDA0001.pc_cancelar_baixa_operac(pr_cdlegado => rg_pendencia.cdlegado
                                     ,pr_idtitdda => '0'          
                                     ,pr_cdctrlcs => rg_pendencia.cdctrlcs
                                     ,pr_cdcodbar => rg_pendencia.cdcodbar
                                     ,pr_idpenden => vr_idpenden
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
    
    -- Se nenhuma crítica for retornada
    IF vr_des_erro = 'OK' THEN
      
      -- Atualizar os dados da pendencia com sucesso e encerrar a mesma
      BEGIN 
        UPDATE tbcobran_baixa_pendente tb
           SET tb.insituacao_solicitacao = 1 -- PROCESSADA COM SUCESSO
             , tb.dhultima_solicitacao   = SYSDATE
             , tb.qttentativa_baixa      = NVL(rg_pendencia.qttentativa_baixa,0) + 1
             , tb.dserro_pendencia       = NULL -- Sem ocorrencia de erro
         WHERE tb.rowid = pr_dsrowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Em caso de erros, apenas retornar e finalizar
          vr_dscritic := 'Erro ao finalizar pendência: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    -- Se ocorreu crítica 
    ELSE
      /* Deve reagendar o job para executar novamente 
      -- Calcular a próxima execução do job, conforme regra:
         -> Até a primeira hora, executar a cada 10 minutos
         -> Da primeira até a terceira hora executar a cada 30 minutos
         -> Após isto executar a cada 1 hora, obedecendo a hora limite */
      
      BEGIN
        -- Buscar a hora limite da execução do parametro
        OPEN  cr_crappco;
        FETCH cr_crappco INTO vr_dtlimite;
        
        -- Se não encontrar a hora no parametro
        IF cr_crappco%NOTFOUND THEN
          -- Será considerada a última hora do dia
          vr_dtlimite := to_date(to_char(SYSDATE,'DD/MM/YYYY')||' 23:00','DD/MM/YYYY HH24:MI');
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_crappco;
      EXCEPTION
        WHEN OTHERS THEN
          -- Em caso de erro na busca do parametro será considerada a última hora do dia
          vr_dtlimite := to_date(to_char(SYSDATE,'DD/MM/YYYY')||' 23:00','DD/MM/YYYY HH24:MI');
      END;
      
      -- Se a hora atual é maior que a data limite
      IF SYSDATE >= vr_dtlimite THEN
        
        -- Se o erro é de pendencia
        IF vr_idpenden = 1 THEN
          vr_dscritic := NULL;  -- Não gravar erro 
          vr_insituac := 2;     -- Gravar como EXPIRADA
        ELSE
          vr_insituac := 3;     -- Gravar como COM ERRO 
        END IF;
        
        -- Atualizar os dados da pendencia para expirada
        BEGIN 
          UPDATE tbcobran_baixa_pendente tb
             SET tb.insituacao_solicitacao = vr_insituac
               , tb.dhultima_solicitacao   = SYSDATE
               , tb.qttentativa_baixa      = NVL(rg_pendencia.qttentativa_baixa,0) + 1
               , tb.dserro_pendencia       = vr_dscritic
           WHERE tb.rowid = pr_dsrowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Em caso de erros, apenas retornar e finalizar
            vr_dscritic := 'Erro ao expirar pendência: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      
      ELSE  -- Se ainda não chegou na hora limite
        
        -- Calcular a diferença entre a hora atual e a hora da solicitação do cancelamento em segundos
        vr_nrdifere := GENE0002.fn_busca_time()
                     - TO_NUMBER( TO_CHAR(rg_pendencia.dhsolicita_baixa,'SSSSS') );
      
        -- Se a diferença for menor ou igual a uma hora (3600 segundos)
        IF vr_nrdifere <= 3600 THEN
          -- Deve executar novamente em 10 minutos
          vr_dtprxexc := SYSDATE + (vr_nrminuto * 10);
          
        -- Se a diferença for menor ou igual a três horas (10800 segundos)
        ELSIF vr_nrdifere <= 10800 THEN
          -- Deve executar novamente em 10 minutos
          vr_dtprxexc := SYSDATE + (vr_nrminuto * 30);
          
        ELSE 
          -- Deve executar novamente em 1 hora (60 minutos)
          vr_dtprxexc := SYSDATE + (vr_nrminuto * 60);
          
        END IF;
        
        -- Se a próxima execução ultrapassar a hora limite
        IF vr_dtprxexc > vr_dtlimite THEN
          -- Deve agendar a próxima execução para a hora limite
          vr_dtprxexc := vr_dtlimite;
        END IF;
        
        -- Define o prefixo do JOB
        vr_dsnomjob := 'JBCOBRAN_CNCL_BXA$'; 
        
        -- Define o código a ser executado pelo JOB
        vr_dsdplsql := 'BEGIN'||CHR(13)||
                       '  DDDA0001.pc_pendencia_cancel_baixa(pr_dsrowid  => '''||pr_dsrowid||''');'||CHR(13)||
                       'END;';                                                 
        
        -- Reagendar JOB para a próxima hora definida
        GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper
                              ,pr_cdprogra  => 'DDDA0001'
                              ,pr_dsplsql   => vr_dsdplsql
                              ,pr_dthrexe   => TO_TIMESTAMP_TZ(
                                                   TO_CHAR(vr_dtprxexc,'dd/mm/rrrr hh24:mi:ss')||' '|| to_char( SYSTIMESTAMP, 'TZH:TZM' )
                                              ,'dd/mm/rrrr hh24:mi:ss TZH:TZM')
                              ,pr_interva   => NULL
                              ,pr_jobname   => vr_dsnomjob          
                              ,pr_des_erro  => vr_dscritic);
        
        -- Tratamento Erro
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Falha no reagendamento do JOB. (Job: '||vr_dsnomjob||'). Erro: '||vr_dscritic;
          RAISE vr_exc_erro;              
        END IF;
        
        -- Atualizar os indicadores da pendencia 
        BEGIN 
          UPDATE tbcobran_baixa_pendente tb
             SET tb.dhultima_solicitacao   = SYSDATE
               , tb.qttentativa_baixa      = NVL(rg_pendencia.qttentativa_baixa,0) + 1
           WHERE tb.rowid = pr_dsrowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Em caso de erros, apenas retornar e finalizar
            vr_dscritic := 'Erro ao atualizar pendência: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
      END IF; -- IF SYSDATE >= vr_dtlimite 
    END IF; -- IF vr_des_erro = 'OK'
    
    -- Commitar a sessão ao final da execução
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Encerrar o job com erro
      RAISE_APPLICATION_ERROR(-20001,'Erro DDDA0001.pc_pendencia_cancel_baixa: '||vr_dscritic);
    WHEN OTHERS THEN
      -- Encerrar o job com erro
      vr_dscritic := 'Erro na rotina DDDA0001.pc_pendencia_cancel_baixa. '||SQLERRM;
      RAISE_APPLICATION_ERROR(-20000,vr_dscritic);
  END pc_pendencia_cancel_baixa;
  
END ddda0001;
/
