/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+-------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                 |
  +------------------------------------+-------------------------------------+
  | procedures/b1wgen0046.p            | SSPB0001                            |
  |   proc_envia_vr_boleto             | SSPB0001.pc_proc_envia_vr_boleto    |
  |   gera_xml_vr_boleto               | SSPB0001.pc_gera_xml_vr_boleto      |
  |   proc_envia_tec_ted               | SSPB0001.pc_proc_envia_tec_ted      |
  |   gera_xml                         | SSPB0001.pc_gera_xml                |
  |   proc_pag0101                     | SSPB0001.pc_proc_pag0101            |
  |   proc_opera_str                   | SSPB0001.pc_proc_opera_str          |
  +------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/






/*..............................................................................

    Programa: b1wgen0046.p
    Autor   : David/Fernando/Guilherme
    Data    : Outubro/2009                    Ultima Atualizacao: 26/05/2018
           
    Dados referentes ao programa:
                
    Objetivo  : BO ref. a Mensageria do SPB.
                                    
    Alteracoes: 26/06/2010 - Alterada BO para tratar conta com digito verificador
                             X - Banco do Brasil (Fernando).
                             
                24/09/2010 - Incluido TAG <CodIdentdTransf> para as mensagens
                             PAG0109, STR0009, PAG0108 e STR0008 (Guilherme)
                                              
                02/12/2010 - Incluida procedure proc_opera_str (Diego).     
                
                15/02/2011 - Fazer a leitura da crapban atraves do 'nrispbif' 
                             quando processada a STR0019 (Gabriel).    
                             
                20/06/2011 - Efetuar leitura pelo campo crapban.cdbccxlt quando
                             for mensagem STR0019 (Diego).
                             
                19/09/2011 - Incluido novo parametro na procedure cria_gnmvspb    
                             para alimentar o novo campo da tabela gnmvspb
                             (Henrique).
                             
                02/12/2011 - Substituida critica 15 por "Banco nao operante no 
                             SPB"  (Diego).              
                            
                27/02/2012 - Tratamento novo catalogo de mensagens V. 3.05, 
                             eliminando mensagens STR0009/PAG0109 (Gabriel).
                             
                04/04/2012 - Alteraçao do campo cdfinmsg para dsfinmsg
                             (David Kruger).
                             
                11/04/2012 - Chamada da procedure grava-log-ted na procedure
                             gera_xml.
                             Inclusao do parametro par_cdorigem na procedure
                             proc_envia_tec_ted. (Fabricio)
                             
                14/05/2012 - Projeto TED Internet (David).            
                
                20/06/2012 - Alterado procedure proc_opera_str para quando for
                             mensagem STR0019 e já existir registro na crapban,
                             alterar nome e nome resumido do registro 
                             (Guilherme Maba).
                             
                30/07/2012 - Inclusao de novos parametros na procedure gera_xml
                             campos: cdagenci, nrdcaixa, cdoperad.(Lucas R).
                             
                22/11/2012 - Ajuste para utilizar campo crapdat.dtmvtocd no
                             lugar do crapdat.dtmvtolt. (Jorge)
                             
                19/03/2013 - Projeto VR Boleto (Rafael).
                
                19/07/2013 - Utilizar valor do pagto do VR Boleto ao gravar
                             registro na tabela gnmvcen. (Rafael)
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                
                09/04/2014 - Adicionado STR0007 e STR0020 'a procedure
                             gera_xml.
                             (PRJ Automatizacao TED pagto convenios repasse) - 
                            (Fabricio)
                            
                25/06/2014 - Removido do corpo da mensagem STR0007 os campos:
                             <TpPessoaRemet>, <CNPJ_CPFRemet> e <NomRemet>.
                             (Fabricio)
                             
                27/06/2014 - Quando for STR0007 e STR0020 alteramos o conteudo
                             da variavel aux_dtmvtolt de: crapdat.dtmvtocd 
                             para: crapdat.dtmvtolt. Motivo: a dtmvtocd ja
                             eh alterada no comeco do processo. (Fabricio)
                
                22/07/2014 - #179456 Campo CanPgto para informar o canal de 
                             pagamento correto. Caso idorigem =  2 entao 
                             CanPgto = 1. Senao CanPgto = 3 (Carlos)
                             
                13/08/2014 - Inclusao do parametro par_dshistor na proc_envia_tec_ted
                             em funçao da Obrigatoriedade do campo Histórico para TED/DOC  
                             com Finalidade "Outros" (Vanessa) 
                             
                24/10/2014 - Armazenar a hora no craplmt igual ao craplcm
                             (Jonata-RKAM).             
                
                19/01/2015 - Adição dos parâmetros "arq" e "coop" na chamada do
                            fonte mqcecred_envia.pl. (Dionathan)
                            
                10/04/2015 - Alteração na procedure proc_opera_st para tratar as alterações
                             solicitadas no SD271603 FDR041 (Vanessa)

                06/07/2015 - Alterado a procedure gera_xml, movendo a chamada do script 
                             mqcecred_envia.pl e do log do arquivo aux_nmarqlog para o 
                             final da procedure. Adicionado validação de erro na procedure 
                             grava-log-ted e tratamento de erro na chamada do gera_xml
                             quando aux_nmmsgenv = "STR0008" (Douglas - Chamado 294944).

                21/10/2015 - Incluir Chamada da procedure gera_arquivo_log_ted ao
                             enviar teds e tambem efetuar tratamento de return-value
                             (Lucas ranghetti/Elton #343312)

                29/10/2015 - Inclusao do indicador estado de crise. (Jaison/Andrino)
                             
                10/11/2015 - Adicionar verificacao de error:status na saida da
                             rotina de criar craplmt (Lucas Ranghetti #355418)
                             
                04/02/2016 - Ajustado Tags do STR0007 para ficarem de acordo com o 
                             catalogo 4.07 (Lucas Ranghetti #385390)
                             
                15/08/2016 - Conversao rotinas proc_pag0101 e proc_opera_str.
                             (Reinert)
                             
                29/08/2016 - #456682 Inclusao de validacao de fraude de TED na
                             rotina proc_envia_tec_ted (Carlos)
                             
                02/06/2017 - Ajustes referentes ao Novo Catalogo do SPB(Lucas Ranghetti #668207)

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

..............................................................................*/                                                                             
{ sistema/generico/includes/b1wgen0046tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }

DEFINE STREAM str_1.

DEFINE VARIABLE aux_cdcritic AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nrcalcul AS DECIMAL     NO-UNDO.
DEFINE VARIABLE aux_dsdctitg AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.

/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**  Procedure para verificar instituicoes financeiras operantes no momento  **/
/******************************************************************************/
PROCEDURE proc_pag0101:

    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqxml AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqlog AS CHAR                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-situacao-if.
    
    DEF VAR aux_xmlsitif AS LONGCHAR                                NO-UNDO. 
    DEF VAR aux_desretor AS CHAR                                    NO-UNDO.

    /* Abrir tag raiz do xml */
    ASSIGN aux_xmlsitif = "<root>".
    
        FOR EACH tt-situacao-if NO-LOCK:
      /* Monta xml da temp-table */
      ASSIGN aux_xmlsitif = aux_xmlsitif +
                            "<dados>" +
                              "<nrispbif>" + STRING(tt-situacao-if.nrispbif) + "</nrispbif>" +
                              "<cdsitope>" + STRING(tt-situacao-if.cdsitope) + "</cdsitope>" +
                            "</dados>".        
        END. /** Fim do FOR EACH tt-situacao-if **/

    /* Fechar tag raiz do xml */
    ASSIGN aux_xmlsitif = aux_xmlsitif + "</root>".
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_proc_pag0101
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdprogra,
                                         INPUT par_nmarqxml,
                                         INPUT par_nmarqlog,
                                         INPUT aux_xmlsitif,
                                        OUTPUT "").

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_proc_pag0101
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
    ASSIGN aux_desretor = ""
           aux_desretor = pc_proc_pag0101.pr_des_erro
                          WHEN pc_proc_pag0101.pr_des_erro <> ?.
            
    RETURN aux_desretor.

END PROCEDURE.

/****************************************************************************/
/**          Procedure para inclusao/exclusao de IF's no SPB-STR           **/
/****************************************************************************/
PROCEDURE proc_opera_str:
 
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqxml AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_CodMsg   AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrispbif AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cddbanco AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtinispb AS CHAR                           NO-UNDO.
    
    DEF VAR aux_desretor AS CHAR                                    NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_proc_opera_str
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdprogra,
                                         INPUT par_nmarqxml,
                                         INPUT par_nmarqlog,
                                         INPUT par_CodMsg,
                                         INPUT par_nrispbif,
                                         INPUT par_cddbanco,
                                         INPUT par_nmdbanco,
                                         INPUT par_dtinispb,
                                        OUTPUT "").

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_proc_opera_str
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
         
    ASSIGN aux_desretor = ""
           aux_desretor = pc_proc_opera_str.pr_des_erro
                          WHEN pc_proc_opera_str.pr_des_erro <> ?.
            
    RETURN aux_desretor.

END PROCEDURE.


/******************************************************************************/
/**                         Envia TED/TEC  - SPB                             **/
/******************************************************************************/
PROCEDURE proc_envia_tec_ted:

/*-------------------------- Variaveis de Entrada ------------------------*/
DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER   /* Cooperativa*/   NO-UNDO.  
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER /* Cod. Agencia  */  NO-UNDO. 
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER /* Numero  Caixa */  NO-UNDO. 
DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER /* Operador */     NO-UNDO.  
DEFINE INPUT  PARAMETER par_titulari AS LOGICAL /* Mesmo Titular.*/  NO-UNDO. 
DEFINE INPUT  PARAMETER par_vldocmto AS DECIMAL /* Vlr. DOCMTO */    NO-UNDO.
DEFINE INPUT  PARAMETER par_nrctrlif AS CHARACTER  /* NumCtrlIF */   NO-UNDO.
DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER /* Nro Conta De */   NO-UNDO. 
DEFINE INPUT  PARAMETER par_cdbccxlt AS INTEGER /* Codigo Banco */   NO-UNDO. 
DEFINE INPUT  PARAMETER par_cdagenbc AS INTEGER /* Cod Agencia */    NO-UNDO. 
DEFINE INPUT  PARAMETER par_nrcctrcb AS DECIMAL /*Nr.Ct.destino*/    NO-UNDO.
DEFINE INPUT  PARAMETER par_cdfinrcb AS INTEGER /* Finalidade */     NO-UNDO.  
DEFINE INPUT  PARAMETER par_tpdctadb AS INTEGER /* Tp. conta deb */  NO-UNDO.  
DEFINE INPUT  PARAMETER par_tpdctacr AS INTEGER /* Tp conta cred */  NO-UNDO.   
DEFINE INPUT  PARAMETER par_nmpesemi AS CHARACTER /* Nome De */      NO-UNDO.  
DEFINE INPUT  PARAMETER par_nmpesde1 AS CHARACTER /*Nome De 2TTL*/   NO-UNDO.  
DEFINE INPUT  PARAMETER par_cpfcgemi AS DECIMAL   /* CPF/CNPJ De*/   NO-UNDO.  
DEFINE INPUT  PARAMETER par_cpfcgdel AS DECIMAL    /*CPF sec TTL*/   NO-UNDO.   
DEFINE INPUT  PARAMETER par_nmpesrcb AS CHARACTER  /* Nome Para */   NO-UNDO. 
DEFINE INPUT  PARAMETER par_nmstlrcb AS CHARACTER /*Nome Para 2TTL*/ NO-UNDO.  
DEFINE INPUT  PARAMETER par_cpfcgrcb AS DECIMAL   /* CPF/CNPJ Para*/ NO-UNDO. 
DEFINE INPUT  PARAMETER par_cpstlrcb AS DECIMAL   /* CPF Para 2TTL*/ NO-UNDO.
DEFINE INPUT  PARAMETER par_tppesemi AS INTEGER /* Tp. pessoa De */  NO-UNDO.
DEFINE INPUT  PARAMETER par_tppesrec AS INTEGER /*Tp. pessoa Para*/  NO-UNDO.
DEFINE INPUT  PARAMETER par_flgctsal AS LOGICAL  /* YES = CC Sal. */ NO-UNDO.
DEFINE INPUT  PARAMETER par_cdidtran AS CHARACTER                    NO-UNDO.
DEFINE INPUT  PARAMETER par_cdorigem AS INTEGER /* Cod. Origem */    NO-UNDO.
DEFINE INPUT  PARAMETER par_dtagendt AS DATE                         NO-UNDO.
DEFINE INPUT  PARAMETER par_nrseqarq AS INTEGER                      NO-UNDO.
DEFINE INPUT  PARAMETER par_cdconven AS INTEGER /* Cod. Convenio */  NO-UNDO.
DEFINE INPUT  PARAMETER par_dshistor AS CHARACTER /*Dsc do Hist. */  NO-UNDO.
DEFINE INPUT  PARAMETER par_hrtransa AS INTEGER /* Hora transacao */ NO-UNDO.
DEFINE INPUT  PARAMETER par_cdispbif AS INTEGER /* ISPB Banco */     NO-UNDO.

/*--------------------------- Variaveis de Saida -------------------------*/
DEFINE OUTPUT PARAMETER aux_dscritic AS CHARACTER                    NO-UNDO.

/*-------------------------- Variaveis de Controle -----------------------*/
DEFINE VARIABLE aux_flgutstr         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE aux_flgutpag         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE aux_flgbcpag         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE aux_nmmsgenv         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_nrcalcul         AS DECIMAL                      NO-UNDO.
DEFINE VARIABLE aux_dsdctitg         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_stsnrcal         AS LOGICAL                      NO-UNDO.

/*----------------------- Parametros para o gera_XML ---------------------*/
DEFINE VARIABLE aux_cdlegado         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_tpmanut          AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_cdstatus         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_nroperacao       AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_fldebcred        AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dspesemi         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dspesrec         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dsdctadb         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dsdctacr         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dtmvtolt         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vldocmto         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_ispbdebt         AS DECIMAL                      NO-UNDO.
DEFINE VARIABLE aux_ispbcred         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_nrcpfemi         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_cpfcgrcb         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_cpfcgde1         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dtagendt         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dtmvtopr         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_nrseqarq         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_flpagmax         AS LOGICAL                      NO-UNDO.

DEFINE VARIABLE aux_tpfraude          AS INTEGER                     NO-UNDO.
DEFINE VARIABLE aux_dsfraude          AS CHARACTER                   NO-UNDO.

DEF VAR h-b1wgen0016                 AS HANDLE                       NO-UNDO.
DEF VAR h-b1wgen0011                 AS HANDLE                       NO-UNDO.
DEF VAR aux_conteudo                 AS CHARACTER                    NO-UNDO.

    ASSIGN aux_flgutstr = FALSE
           aux_flgutpag = FALSE
           aux_flgbcpag = FALSE
		   aux_flpagmax = FALSE.
   
    /* Busca dados da cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop THEN
         DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,             /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.
    
    /* Busca data do sistema */ 
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper  NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapdat THEN 
         DO:
            ASSIGN aux_cdcritic = 1
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.

    /* ISPB Debt. eh os 8 primeiros digitos do CNPJ da Coop */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "CNPJCENTRL" AND 
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "CNPJ da Central nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.
    ELSE      
         ASSIGN aux_ispbdebt = DECIMAL(craptab.dstextab).

    /* Verificar se o Banco de destino esta operando com o PAG */
    IF par_cdbccxlt > 0 THEN
        FIND crapban WHERE crapban.cdbccxlt = par_cdbccxlt  NO-LOCK NO-ERROR.
    ELSE
        FIND crapban WHERE crapban.nrispbif = par_cdispbif  NO-LOCK NO-ERROR.
        

    IF   NOT AVAILABLE crapban   THEN
         DO:
            ASSIGN aux_cdcritic = 57
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.
    ELSE
         ASSIGN aux_flgbcpag = crapban.flgoppag.

    /* ISPB Credt eh os 8 primeiros digitos do CNPJ do Banco de Destino */
    IF par_cdbccxlt > 0 THEN
       FIND crapban WHERE crapban.cdbccxlt = par_cdbccxlt AND 
                       crapban.flgdispb = TRUE         NO-LOCK NO-ERROR.
    ELSE 
        FIND crapban WHERE crapban.nrispbif = par_cdispbif AND 
                           crapban.flgdispb = TRUE         NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapban   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Banco não operante no SPB.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.
    ELSE 
         ASSIGN aux_ispbcred = STRING(crapban.nrispbif,"99999999").

    /*-- Operando com mensagens STR --*/
    IF   crapcop.flgopstr   THEN
         IF   crapcop.iniopstr <= TIME AND crapcop.fimopstr >= TIME   THEN
              ASSIGN aux_flgutstr = TRUE.             

    /*-- Operando com mensagens PAG --*/
    IF   crapcop.flgoppag   THEN
         IF   crapcop.inioppag <= TIME AND crapcop.fimoppag >= TIME   THEN
              ASSIGN aux_flgutpag = TRUE.

    IF  aux_flgutpag = TRUE  THEN /* Operando com PAG */ 
        IF  par_vldocmto > crapcop.vlmaxpag THEN
            ASSIGN aux_flpagmax = TRUE
			       aux_flgutpag = FALSE. /* Altera para nao operante */

    IF   aux_flgutstr = FALSE AND aux_flgutpag = FALSE    THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = IF  aux_flpagmax  THEN
                                      "Limite máximo por operaçao: R$ " +
                                      STRING(crapcop.vlmaxpag,"zz,zzz,zz9.99")
                                  ELSE "Horário de envio de TEDs encerrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.

                      /* Alimenta variaveis default */

           /* Tp. pessoa - Remetente */
    ASSIGN aux_dspesemi      = IF   par_tppesemi = 1   THEN
                                    "F"
                               ELSE "J"

           /* Tp. pessoa - Destinatario */ 
           aux_dspesrec      = IF   par_tppesrec = 1   THEN
                                    "F"
                               ELSE "J"

           /* Tp. conta - Remetente */
           aux_dsdctadb      = IF   par_tpdctadb = 2   THEN
                                    "PP"
                               ELSE "CC"

           /* Tp. conta - Destinatario */
           aux_dsdctacr      = IF   par_tpdctacr = 2   THEN
                                    "PP"
                               ELSE IF par_tpdctacr = 1 THEN 
                                    "CC"
                               ELSE "PG"

           /* CPF Remetente - Primeiro titular */
           aux_nrcpfemi = IF   par_tppesemi = 1   THEN
                               STRING(par_cpfcgemi,"99999999999")
                          ELSE
                               STRING(par_cpfcgemi,"99999999999999")

           /* CPF Remetente - Segundo titular */
           aux_cpfcgde1 = IF   par_tppesemi = 1   THEN
                               STRING(par_cpfcgdel, "99999999999")
                          ELSE
                               STRING(par_cpfcgdel,"99999999999999")

           /* CPF Destinatario */
           aux_cpfcgrcb = IF   par_tppesrec = 1   THEN
                               STRING(par_cpfcgrcb,"99999999999") 
                          ELSE
                               STRING(par_cpfcgrcb,"99999999999999")

           /* Format da data deve ser AAAA-MM-DD */
           aux_dtmvtolt      = STRING(YEAR(crapdat.dtmvtocd), "9999") + "-" +
                               STRING(MONTH(crapdat.dtmvtocd), "99") + "-" +
                               STRING(DAY(crapdat.dtmvtocd), "99")  

           /* Format da data deve ser AAAA-MM-DD */
           aux_dtmvtopr      = STRING(YEAR(crapdat.dtmvtopr), "9999") + "-" +
                               STRING(MONTH(crapdat.dtmvtopr), "99") + "-" +
                               STRING(DAY(crapdat.dtmvtopr), "99")
           
           /* Separador decimal de centavos deve ser "." */
           aux_vldocmto      = REPLACE(STRING(par_vldocmto),",",".")
           
                      /* Alimenta as variaveis do HEADER */           
           aux_cdlegado   = STRING(crapcop.cdagectl)
                           /*    crapcop.dssigaut   */
           aux_tpmanut    = "I" /* Inclusao */
           aux_cdstatus   = "D" /* Mensagem do tipo definitiva - real */
           aux_nroperacao = par_nrctrlif
           aux_fldebcred  = "D". /* Debito */  

    /* ----- Validar crapcbf (Fraude) ----- */
    ASSIGN aux_tpfraude = IF par_tppesrec = 1 THEN 2 ELSE 3
           aux_dsfraude = IF par_tppesrec = 1 THEN 
                          STRING(aux_cpfcgrcb, "xxx.xxx.xxx-xx") 
                          ELSE 
                          STRING(aux_cpfcgrcb, "xx.xxx.xxx/xxxx-xx").
    
    FIND FIRST crapcbf WHERE tpfraude = aux_tpfraude AND 
                             dsfraude = aux_dsfraude
                             NO-LOCK NO-ERROR.
    
    IF AVAILABLE crapcbf THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Dados inconsistentes.
                               Impossibilidade de realizar a transação.
                               Entre em contato com a área de Segurança Corporativa do AILOS.".
        
        RUN gera_erro (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1, /** Sequencia **/
                     INPUT aux_cdcritic,      
                     INPUT-OUTPUT aux_dscritic).

        /* Enviar e-mail para a area */
        RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

        IF  VALID-HANDLE(h-b1wgen0011) THEN
        DO:
            ASSIGN aux_conteudo = '<b>Atencao! Houve tentativa de TED fraudulento.<br>' +
                'Coop: ' + string(par_cdcooper) + '<br>' +
                'Age: '  + string(par_cdagenci) + '<br>' +
                'Caixa: '+ string(par_nrdcaixa) + '<br>' +
                'Conta: </b>' + string(par_nrdconta) + '<br>' +
                '<b>CPF/CNPJ destino: </b>' + aux_dsfraude.

            RUN enviar_email_completo IN h-b1wgen0011
              (INPUT par_cdcooper,
               INPUT "CAIXAONLINE",
               INPUT "cpd@ailos.coop.br",
               INPUT "monitoracaodefraudes@ailos.coop.br",
               INPUT "Atencao - Tentativa de TED para CPF/CNPJ em restritivo",
               INPUT "",
               INPUT "",
               INPUT aux_conteudo,
               INPUT TRUE).

            DELETE PROCEDURE h-b1wgen0011.
        END.

        RETURN "NOK".
    END.
    /* ----- Fim Validar crapcbf (Fraude) ----- */

    IF   par_nrdconta <> 0   THEN
         IF   par_nmpesde1 MATCHES "E/OU*"   THEN
              par_nmpesde1 = SUBSTRING(par_nmpesde1,6). 

    /*-- Monta o BODY --*/
    IF   par_flgctsal   THEN
         DO:
            /* Enviar com STR0037 ou PAG0137 */

            /* Se PAG Disponivel e se o Banco de destino estiver operando
               com PAG */
            IF   aux_flgutpag AND aux_flgbcpag   THEN
                 ASSIGN aux_nmmsgenv = "PAG0137".
            ELSE
                DO:
                   IF  aux_flgutstr  THEN /* Se STR Disponivel */
                 ASSIGN aux_nmmsgenv = "STR0037".
                   ELSE
                       DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Operação indisponível para " +
                                                "o banco favorecido.".
                                   
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /** Sequencia **/
                                         INPUT aux_cdcritic,      
                                         INPUT-OUTPUT aux_dscritic).
                          
                          RETURN "NOK".
                END.
                END.
                               
            RUN gera_xml(INPUT par_cdcooper,
                         INPUT par_cdorigem,
                         INPUT aux_nmmsgenv, /* Cod. da Mensagem */
                              /* HEADER */
                         INPUT aux_cdlegado, /* Cod. Legado */
                         INPUT aux_tpmanut, /* Inclusao */
                         INPUT aux_cdstatus, /* Mensagem do tipo definitiva */
                         INPUT aux_nroperacao,
                         INPUT aux_fldebcred, /* Debito */
                               /* BODY */
                         INPUT par_nrctrlif, /* Nr. controle da IF*/
                         INPUT SUBSTR(STRING(aux_ispbdebt,"99999999999999"),1,8),
                         INPUT STRING(crapcop.cdbcoctl), /* Banco da Coop. */
                         INPUT STRING(crapcop.cdagectl), /* Agencia da Coop. */  
                         INPUT "", /* Tp. Conta de Debito */ 
                         INPUT par_nrdconta,  /* Nr.da Conta remeternte */
                         INPUT "",/* Tp. Pessoa Remetente */             
                         INPUT STRING(par_cpfcgemi, "99999999999"),/*CPF Remet*/ 
                         INPUT "", /* CPF Remetente - Segundo ttl */ 
                         INPUT par_nmpesemi,/*Nome Remetente - Primeiro ttl*/
                         INPUT "", /* Nome Remetente - Segundo ttl */ 
                         INPUT aux_ispbcred, /* IF de Credito */  
                         INPUT STRING(par_cdbccxlt), /* Cd. Banco Destino */
                         INPUT STRING(par_cdagenbc), /* Agencia IF de credito */    
                         INPUT STRING(par_nrcctrcb), /* Conta de credito */         
                         INPUT aux_dsdctacr, /* Tp. Conta de Debito */              
                         INPUT "", /* Tp. Pessoa Destino */               
                         INPUT "", /* CPF Pessoa Destino */               
                         INPUT "", /* Nome Pessoa Destino */              
                         INPUT aux_vldocmto, /* Valor do Docmto */                  
                         INPUT "", /* Finalidade */               
                         INPUT aux_dtmvtolt,  /* Data atual */
                         INPUT aux_dtmvtopr,
                         INPUT par_cdidtran,
                         INPUT "", /* Historico */
                         INPUT par_cdagenci, /*agencia/pac*/
                         INPUT par_nrdcaixa, /*nr. do caixa*/
                         INPUT par_cdoperad, /*operador*/
                         INPUT ?,
                         INPUT 0,
                         INPUT 0,  /* convenio */
                         INPUT par_hrtransa).
         END.
    ELSE
    IF   par_nrdconta = 0   THEN
         DO:
            /* Enviar com STR0005 ou PAG0107 */
            
            /* Se PAG Disponivel e se o Banco de destino estiver operando
               com PAG */
            IF   aux_flgutpag AND aux_flgbcpag   THEN
                 ASSIGN aux_nmmsgenv = "PAG0107".
            ELSE
                DO:
                   IF  aux_flgutstr  THEN /* Se STR Disponivel */
                 ASSIGN aux_nmmsgenv = "STR0005".
                   ELSE
                       DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Operação indisponível para " +
                                                "o banco favorecido.".
                                   
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /** Sequencia **/
                                         INPUT aux_cdcritic,      
                                         INPUT-OUTPUT aux_dscritic).
                          
                          RETURN "NOK".
                END.
                END.
                                           
            RUN gera_xml(INPUT par_cdcooper,
                         INPUT par_cdorigem,
                         INPUT aux_nmmsgenv, /* Cod. da Mensagem */
                               /* HEADER */
                         INPUT aux_cdlegado, /* Cod. Legado */
                         INPUT aux_tpmanut, /* Inclusao */
                         INPUT aux_cdstatus, /* Mensagem do tipo definitiva */
                         INPUT aux_nroperacao,
                         INPUT aux_fldebcred, /* Debito */
                               /* BODY */
                         INPUT par_nrctrlif, /* Nr. controle da IF*/
                         INPUT SUBSTR(STRING(aux_ispbdebt,"99999999999999"),1,8),
                         INPUT STRING(crapcop.cdbcoctl), /* Banco da Coop. */
                         INPUT STRING(crapcop.cdagectl), /* Agencia da Coop. */ 
                         INPUT aux_dsdctadb, /* Tp. Conta de Debito */ 
                         INPUT "", /* Nr.da Conta remeternte */
                         INPUT aux_dspesemi,/* Tp. Pessoa Remetente */               
                         INPUT aux_nrcpfemi,/* CPF Remetente - Primeiro ttl */   
                         INPUT "", /* CPF Remetente  - Segundo ttl */ 
                         INPUT par_nmpesemi,/* Nome Remetente - Primeiro ttl */  
                         INPUT "", /* Nome Remetente - Segundo ttl */ 
                         INPUT aux_ispbcred,/* IF de Credito */    
                         INPUT STRING(par_cdbccxlt), /* Cd. Banco Destino */
                         INPUT STRING(par_cdagenbc), /* Agencia IF de credito */   
                         INPUT STRING(par_nrcctrcb), /* Conta de credito */          
                         INPUT aux_dsdctacr,/* Tp. Conta de Debito */                
                         INPUT aux_dspesrec,/* Tp. Pessoa Destino */                 
                         INPUT aux_cpfcgrcb,/* CPF Pessoa Destino */                 
                         INPUT par_nmpesrcb,/* Nome Pessoa Destino */                
                         INPUT aux_vldocmto,/* Valor do Docmto */                    
                         INPUT STRING(par_cdfinrcb), /* Finalidade */              
                         INPUT aux_dtmvtolt, /* Data atual */ 
                         INPUT aux_dtmvtopr,
                         INPUT par_cdidtran,
                         INPUT par_dshistor, /* Historico */
                         INPUT par_cdagenci, /*agencia/pac*/
                         INPUT par_nrdcaixa, /*nr. do caixa*/
                         INPUT par_cdoperad, /*operador*/
                         INPUT ?,
                         INPUT 0,
                         INPUT 0, /* convenio */
                         INPUT par_hrtransa). 
         END.
    ELSE
    IF par_cdconven <> 0 THEN
    DO:
        IF par_cdconven = 59 OR par_cdconven = 60 THEN /* DARE ou GNRE */
            ASSIGN aux_nmmsgenv = "STR0020"
                   aux_nrseqarq = STRING(par_nrseqarq, "999999") + 
                                  STRING(par_cdconven, "99").
        ELSE
            ASSIGN aux_nmmsgenv = "STR0007"
                   aux_nrseqarq = STRING(par_nrseqarq).

        /* Format da data deve ser AAAA-MM-DD */
        ASSIGN aux_dtmvtolt = STRING(YEAR(crapdat.dtmvtolt), "9999") + "-" +
                              STRING(MONTH(crapdat.dtmvtolt), "99")  + "-" +
                              STRING(DAY(crapdat.dtmvtolt), "99").

        /* Format da data deve ser AAAA-MM-DD */
        IF par_dtagendt <> ? THEN
            ASSIGN aux_dtagendt = STRING(YEAR(par_dtagendt), "9999") + "-" +
                                  STRING(MONTH(par_dtagendt), "99")  + "-" +
                                  STRING(DAY(par_dtagendt), "99").
        ELSE
            ASSIGN aux_dtagendt = "".

        RUN gera_xml(INPUT par_cdcooper,
                     INPUT par_cdorigem,
                     INPUT aux_nmmsgenv, /* Cod. da Mensagem */
                          /* HEADER */
                     INPUT aux_cdlegado, /* Cod. Legado */
                     INPUT aux_tpmanut, /* Inclusao */
                     INPUT aux_cdstatus, /* Mensagem do tipo definitiva */
                     INPUT aux_nroperacao,
                     INPUT aux_fldebcred, /* Debito */
                           /* BODY */
                     INPUT par_nrctrlif, /* Nr. controle da IF*/
                     INPUT SUBSTR(STRING(aux_ispbdebt,"99999999999999"),1,8),
                     INPUT STRING(crapcop.cdbcoctl), /* Banco da Coop. */
                     INPUT STRING(crapcop.cdagectl), /* Agencia da Coop. */ 
                     INPUT aux_dsdctadb, /* Tp. Conta de Debito */ 
                     INPUT STRING(par_nrdconta), /* Nr.da Conta remeternte */ 
                     INPUT aux_dspesemi, /* Tp. Pessoa Remetente */ 
                     INPUT aux_nrcpfemi, /* CPF Remetente - Primeiro ttl */ 
                     INPUT "", /* CPF Remetente - Segundo ttl */  
                     INPUT par_nmpesemi, /* Nome Remetente - Primeiro ttl */
                     INPUT "", /* Nome Remetente - Segundo ttl */ 
                     INPUT aux_ispbcred, /* IF de Credito */   
                     INPUT STRING(par_cdbccxlt), /* Cd. Banco Destino */
                     INPUT STRING(par_cdagenbc), /* Agencia IF de credito */ 
                     INPUT STRING(par_nrcctrcb), /* Conta de credito */      
                     INPUT aux_dsdctacr, /* Tp. Conta de Debito */          
                     INPUT aux_dspesrec, /* Tp. Pessoa Destino */           
                     INPUT aux_cpfcgrcb, /* CPF Pessoa Destino */           
                     INPUT par_nmpesrcb, /* Nome Pessoa Destino */          
                     INPUT aux_vldocmto, /* Valor do Docmto */              
                     INPUT STRING(par_cdfinrcb), /* Finalidade */            
                     INPUT aux_dtmvtolt, /* Data do movimento */
                     INPUT aux_dtmvtopr, /* Data do proximo movimento */
                     INPUT par_cdidtran,
                     INPUT par_dshistor, /* Historico */
                     INPUT par_cdagenci, /*agencia/pac*/
                     INPUT par_nrdcaixa, /*nr. do caixa*/
                     INPUT par_cdoperad, /*operador*/ 
                     INPUT aux_dtagendt,
                     INPUT aux_nrseqarq,
                     INPUT par_cdconven,  /* convenio */
                     INPUT par_hrtransa). 
    END.
    ELSE
         DO:
            /* Enviar com STR0008 ou PAG0108 */

            /* Se PAG Disponivel e se o Banco de destino estiver operando
               com PAG */
            IF   aux_flgutpag AND aux_flgbcpag   THEN
                 ASSIGN aux_nmmsgenv = "PAG0108".
            ELSE
                DO:
                   IF  aux_flgutstr  THEN /* Se STR Disponivel */
                 ASSIGN aux_nmmsgenv = "STR0008".
                   ELSE
                       DO:
                          ASSIGN aux_cdcritic = 0
                                 aux_dscritic = "Operação indisponível para " +
                                                "o banco favorecido.".
                                   
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /** Sequencia **/
                                         INPUT aux_cdcritic,      
                                         INPUT-OUTPUT aux_dscritic).
                          
                          RETURN "NOK".
                       END.
                END.

            RUN gera_xml(INPUT par_cdcooper,
                         INPUT par_cdorigem,
                         INPUT aux_nmmsgenv, /* Cod. da Mensagem */
                              /* HEADER */
                         INPUT aux_cdlegado, /* Cod. Legado */
                         INPUT aux_tpmanut, /* Inclusao */
                         INPUT aux_cdstatus, /* Mensagem do tipo definitiva */
                         INPUT aux_nroperacao,
                         INPUT aux_fldebcred, /* Debito */
                               /* BODY */
                         INPUT par_nrctrlif, /* Nr. controle da IF*/
                         INPUT SUBSTR(STRING(aux_ispbdebt,"99999999999999"),1,8),
                         INPUT STRING(crapcop.cdbcoctl), /* Banco da Coop. */
                         INPUT STRING(crapcop.cdagectl), /* Agencia da Coop. */ 
                         INPUT aux_dsdctadb, /* Tp. Conta de Debito */ 
                         INPUT STRING(par_nrdconta), /* Nr.da Conta remeternte */ 
                         INPUT aux_dspesemi, /* Tp. Pessoa Remetente */ 
                         INPUT aux_nrcpfemi, /* CPF Remetente - Primeiro ttl */ 
                         INPUT "", /* CPF Remetente - Segundo ttl */  
                         INPUT par_nmpesemi, /* Nome Remetente - Primeiro ttl */
                         INPUT "", /* Nome Remetente - Segundo ttl */ 
                         INPUT aux_ispbcred, /* IF de Credito */   
                         INPUT STRING(par_cdbccxlt), /* Cd. Banco Destino */
                         INPUT STRING(par_cdagenbc), /* Agencia IF de credito */ 
                         INPUT STRING(par_nrcctrcb), /* Conta de credito */      
                         INPUT aux_dsdctacr, /* Tp. Conta de Debito */          
                         INPUT aux_dspesrec, /* Tp. Pessoa Destino */           
                         INPUT aux_cpfcgrcb, /* CPF Pessoa Destino */           
                         INPUT par_nmpesrcb, /* Nome Pessoa Destino */          
                         INPUT aux_vldocmto, /* Valor do Docmto */              
                         INPUT STRING(par_cdfinrcb), /* Finalidade */            
                         INPUT aux_dtmvtolt, /* Data atual */
                         INPUT aux_dtmvtopr,
                         INPUT par_cdidtran,
                         INPUT par_dshistor, /* Historico */
                         INPUT par_cdagenci, /*agencia/pac*/
                         INPUT par_nrdcaixa, /*nr. do caixa*/
                         INPUT par_cdoperad, /*operador*/ 
                         INPUT ?,
                         INPUT 0,
                         INPUT 0,
                         INPUT par_hrtransa). /* convenio */
                        
            /* Validação de erro */
            IF  RETURN-VALUE <> "OK" THEN
                DO:

                    ASSIGN 	aux_cdcritic = 0                                                  
                            aux_dscritic = "Problemas na geração do LOG do XML".     

                    RUN sistema/generico/procedures/b1wgen0016.p 
                        PERSISTENT SET h-b1wgen0016.

                    /* Gerar log das teds com erro */
                    RUN gera_arquivo_log_ted IN h-b1wgen0016(
                                             INPUT par_cdcooper,                              
                                             INPUT "gera_xml",                                
                                             INPUT "b1wgen0046",                              
                                             INPUT TODAY,                              
                                             INPUT par_nrdconta,                              
                                             INPUT par_cpfcgrcb,                              
                                             INPUT par_cdbccxlt,                              
                                             INPUT par_cdagenbc,                              
                                             INPUT par_nrcctrcb,                              
                                             INPUT par_nmpesemi,                              
                                             INPUT par_cpfcgemi,                              
                                             INPUT par_tppesemi,                              
                                             INPUT par_tpdctadb,                              
                                             INPUT par_vldocmto,                              
                                             INPUT par_dshistor,                              
                                             INPUT par_cdfinrcb,                              
                                             INPUT par_cdispbif,                              
                                             INPUT aux_dscritic).                             
                                                                                              
                    IF  VALID-HANDLE(h-b1wgen0016) THEN                                       
                        DELETE PROCEDURE h-b1wgen0016.      

                    RUN gera_erro (INPUT par_cdcooper,                                        
                                   INPUT par_cdagenci,                                        
                                   INPUT par_nrdcaixa,                                        
                                   INPUT 1, /** Sequencia **/                                 
                                   INPUT aux_cdcritic,                                        
                                   INPUT-OUTPUT aux_dscritic).                                
                    RETURN "NOK".                                                             
                END.                                         
        END.

    RETURN "OK".

END PROCEDURE.

/*............................ PROCEDURES INTERNAS ...........................*/

/******************************************************************************/
/**                             Gera arquivo XML                             **/
/******************************************************************************/

PROCEDURE gera_xml:

DEFINE INPUT PARAMETER par_cdcooper   AS INTEGER                     NO-UNDO.
DEFINE INPUT PARAMETER par_cdorigem   AS INTEGER                     NO-UNDO.
                                 /* HEADER */
DEFINE INPUT PARAMETER par_nmmsgenv   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdlegago   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_tpmanut    AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdstatus   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nroperacao AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_fldebcred  AS CHARACTER                   NO-UNDO.
                                 /* BODY */
DEFINE INPUT PARAMETER par_nrctrlif   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_ispbdebt   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdbcoctl   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdagectl   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dsdctadb   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nrdconta   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dspesemi   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cpfcgemi   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cpfcgdel   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nmpesemi   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nmpesde1   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_ispbcred   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdbccxlt   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdagenbc   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nrcctrcb   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dsdctacr   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dspesrec   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cpfcgrcb   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nmpesrcb   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vldocmto   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdfinrcb   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dtmvtolt   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dtmvtopr   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdidtran   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dshistor   AS CHARACTER                   NO-UNDO.

DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER /* Cod. Agencia  */  NO-UNDO. 
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER /* Numero  Caixa */  NO-UNDO. 
DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER /* Operador */     NO-UNDO.
DEFINE INPUT  PARAMETER par_dtagendt AS CHARACTER                    NO-UNDO.
DEFINE INPUT  PARAMETER par_nrseqarq AS CHARACTER                    NO-UNDO.
DEFINE INPUT  PARAMETER par_cdconven AS INTEGER                      NO-UNDO.
DEFINE INPUT  PARAMETER par_hrtransa AS INTEGER                      NO-UNDO.

                             /* Variaveis Internas */
DEFINE VARIABLE aux_contador          AS INTEGER                     NO-UNDO.
DEFINE VARIABLE aux_textoxml          AS CHARACTER    EXTENT 35      NO-UNDO.
DEFINE VARIABLE aux_nmtagbod          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarquiv          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarqlog          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarqxml          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarqenv          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_dsarqenv          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_contctnr          AS INTEGER                     NO-UNDO.
DEFINE VARIABLE aux_nrcctrcb1         AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nrcctrcb2         AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_cdagenbc          AS CHARACTER                   NO-UNDO.

DEFINE VARIABLE h-b1wgen0050          AS HANDLE                      NO-UNDO.
DEFINE VARIABLE h-b1wgen0016          AS HANDLE                      NO-UNDO.

         /* Arquivo gerado para o envio */
  ASSIGN aux_nmarqxml = "/usr/coop/" + crapcop.dsdircop +
                        "/salvar/msgenv_cecred_" + STRING(YEAR(TODAY),"9999")
                        + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99")
                        + STRING(ETIME,"9999999999") + ".xml"
         /* Arquivo de log - tela LOGSPB*/
         aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" + 
                        "mqcecred_envio" +
                        STRING(crapdat.dtmvtocd,"999999") + ".log"
         aux_nmarquiv = SUBSTRING(TRIM(aux_nmarqxml),
                                       R-INDEX(aux_nmarqxml,"/") + 1).
                                       
  IF  par_dsdctacr = "CC" OR    /* Conta Corrente */
      par_dsdctacr = "PP" THEN /* Conta Poupanca */ 
      ASSIGN aux_nrcctrcb1 = STRING(par_nrcctrcb)
             aux_cdagenbc  = STRING(par_cdagenbc).
  ELSE  /* Conta de Pagamento */
      ASSIGN aux_nrcctrcb2 = STRING(par_nrcctrcb)
             aux_cdagenbc = "".                                       
                                       
                      /* HEADER - mensagens STR e PAG */
  ASSIGN aux_textoxml[1] = "<SISMSG>"
         aux_textoxml[2] = "<SEGCAB>" 
         aux_textoxml[3] = "<CD_LEGADO>" + par_cdlegago + "</CD_LEGADO>"
         aux_textoxml[4] = "<TP_MANUT>" + par_tpmanut + "</TP_MANUT>"
         aux_textoxml[5] = "<CD_STATUS>" + par_cdstatus + "</CD_STATUS>"
         aux_textoxml[6] = "<NR_OPERACAO>" + par_nroperacao + 
                           "</NR_OPERACAO>"
         aux_textoxml[7] = "<FL_DEB_CRED>" + par_fldebcred + 
                           "</FL_DEB_CRED>"
         aux_textoxml[8] = "</SEGCAB>".
         
                      /* BODY  - mensagens STR e PAG   
       STR0005 e PAG0107
       Descriçao: destinado a IF requisitar transferencia de recursos por 
                  conta de nao correntistas. */
    IF  par_nmmsgenv = "STR0005" OR par_nmmsgenv = "PAG0107"  THEN
    DO:
        ASSIGN aux_textoxml[9]  = "<" + par_nmmsgenv + ">"
               aux_textoxml[10] = " <CodMsg>" + par_nmmsgenv + "</CodMsg>"      
               aux_textoxml[11] = "<NumCtrlIF>" + par_nrctrlif +
                                  "</NumCtrlIF>"
               aux_textoxml[12] = "<ISPBIFDebtd>" + par_ispbdebt +
                                  "</ISPBIFDebtd>"
               aux_textoxml[13] = "<AgDebtd>" + par_cdagectl +
                                  "</AgDebtd>"
               aux_textoxml[16] = "<TpPessoaRemet>" + par_dspesemi +
                                  "</TpPessoaRemet>"                                    
               aux_textoxml[17] = "<CNPJ_CPFRemet>" + par_cpfcgemi +
                                  "</CNPJ_CPFRemet>"
               aux_textoxml[18] = "<NomRemet>" + par_nmpesemi +
                                  "</NomRemet>"
               aux_textoxml[19] = "<ISPBIFCredtd>" + par_ispbcred + 
                                  "</ISPBIFCredtd>".
               
        IF par_dsdctacr = "CC" OR par_dsdctacr = "PP" THEN
            ASSIGN aux_textoxml[20] = "<AgCredtd>" + aux_cdagenbc + 
                                  "</AgCredtd>"
                   aux_textoxml[21] = "<CtCredtd>" + aux_nrcctrcb1 +
                                      "</CtCredtd>".
        ELSE 
            ASSIGN aux_textoxml[20] = ""
                   aux_textoxml[21] = "<CtPgtoCredtd>" + aux_nrcctrcb2 +
                                      "</CtPgtoCredtd>".
               
               
        ASSIGN aux_textoxml[22] = "<TpCtCredtd>" + par_dsdctacr +
                                  "</TpCtCredtd>"
               aux_textoxml[23] = "<TpPessoaDestinatario>" + par_dspesrec +
                                  "</TpPessoaDestinatario>"
               aux_textoxml[24] = "<CNPJ_CPFDestinatario>" + par_cpfcgrcb +
                                  "</CNPJ_CPFDestinatario>"                  
               aux_textoxml[25] = "<NomDestinatario>" + par_nmpesrcb +
                                  "</NomDestinatario>"
               aux_textoxml[26] = "<VlrLanc>" + par_vldocmto + 
                                  "</VlrLanc>"
               aux_textoxml[27] = "<FinlddCli>" + par_cdfinrcb +
                                  "</FinlddCli>"
               aux_textoxml[28] = "<Hist>" + par_dshistor +
                                  "</Hist>"
               aux_textoxml[29] = "<DtMovto>" + par_dtmvtolt + 
                                  "</DtMovto>"
               aux_textoxml[30] = "</" + par_nmmsgenv + ">"
               aux_textoxml[31] = "</SISMSG>".
  END.
  ELSE
  /* Descricao: IF requisita Transferencia de IF para conta de cliente */
  IF  par_nmmsgenv = "STR0007" THEN
      DO:
          ASSIGN aux_textoxml[09] = "<" + par_nmmsgenv + ">"
                 aux_textoxml[10] = "<CodMsg>" + par_nmmsgenv + "</CodMsg>"
                 aux_textoxml[11] = "<NumCtrlIF>" + par_nrctrlif + "</NumCtrlIF>"
                 aux_textoxml[12] = "<ISPBIFDebtd>" + par_ispbdebt +
                                    "</ISPBIFDebtd>"
                 aux_textoxml[13] = "<ISPBIFCredtd>" + par_ispbcred + 
                                    "</ISPBIFCredtd>".
          
          IF par_dsdctacr = "CC" OR par_dsdctacr = "PP" THEN
              ASSIGN aux_textoxml[14] = "<AgCredtd>" + aux_cdagenbc + 
                                    "</AgCredtd>"
                 aux_textoxml[15] = "<TpCtCredtd>" + par_dsdctacr +
                                    "</TpCtCredtd>"
                     aux_textoxml[16] = "<CtCredtd>" + aux_nrcctrcb1 +
                                        "</CtCredtd>".
          ELSE
              ASSIGN aux_textoxml[14] = ""
                     aux_textoxml[15] = "<TpCtCredtd>" + par_dsdctacr +
                                        "</TpCtCredtd>"
                     aux_textoxml[16] = "<CtPgtoCredtd>" + aux_nrcctrcb2 +
                                        "</CtPgtoCredtd>".
                                        
          ASSIGN aux_textoxml[17] = "<TpPessoaCredtd>" + par_dspesrec + 
                                    "</TpPessoaCredtd>"
                 aux_textoxml[18] = "<CNPJ_CPFCliCredtd>" + par_cpfcgrcb +
                                    "</CNPJ_CPFCliCredtd>"
                 aux_textoxml[19] = "<NomCliCredtd>" + par_nmpesrcb +
                                    "</NomCliCredtd>"            
                 aux_textoxml[20] = "<NumContrtoOpCred></NumContrtoOpCred>"
                 aux_textoxml[21] = "<VlrLanc>" + par_vldocmto + "</VlrLanc>"
                 aux_textoxml[22] = "<FinlddIF>" + par_cdfinrcb + "</FinlddIF>"
                 aux_textoxml[23] = "<CodIdentdTransf>" + par_cdidtran +
                                    "</CodIdentdTransf>"
                 aux_textoxml[24] = "<Hist></Hist>"
                 aux_textoxml[25] = "<DtAgendt>" + par_dtagendt + "</DtAgendt>"
                 aux_textoxml[26] = "<HrAgendt></HrAgendt>"
                 aux_textoxml[27] = "<NivelPref></NivelPref>"
                 aux_textoxml[28] = "<DtMovto>" + par_dtmvtopr + "</DtMovto>"
                 aux_textoxml[29] = "</" + par_nmmsgenv + ">"
                 aux_textoxml[30] = "</SISMSG>".
      END.
  ELSE
  /* STR0008 ,  PAG0108 , STR 0009 e PAG 0109
     - Descriçao: destinado a IF requisitar transferencia de recursos 
                  entre pessoas físicas ou jurídicas em IFs distintas. */           
  IF  par_nmmsgenv = "STR0008" OR  par_nmmsgenv = "PAG0108"  OR 
      par_nmmsgenv = "STR0009" OR  par_nmmsgenv = "PAG0109"  THEN
      DO:
          /* Enquanto nao for alterada tela da rotina 20 Cx.Online */ 
          IF   par_nmmsgenv = "STR0009"   THEN
               ASSIGN par_nmmsgenv = "STR0008".

          IF   par_nmmsgenv = "PAG0109"   THEN
               par_nmmsgenv = "PAG0108".

          ASSIGN aux_textoxml[9]  = "<" + par_nmmsgenv + ">"
                 aux_textoxml[10] = "<CodMsg>" + par_nmmsgenv + "</CodMsg>"      
                 aux_textoxml[11] = "<NumCtrlIF>" + par_nrctrlif +
                                    "</NumCtrlIF>"
                 aux_textoxml[12] = "<ISPBIFDebtd>" + par_ispbdebt +
                                    "</ISPBIFDebtd>"
                 aux_textoxml[13] = "<AgDebtd>" + par_cdagectl +
                                    "</AgDebtd>"
                 aux_textoxml[14] = "<TpCtDebtd>" + par_dsdctadb +
                                    "</TpCtDebtd>"
                 aux_textoxml[15] = "<CtDebtd>" + par_nrdconta + 
                                    "</CtDebtd>"
                 aux_textoxml[16] = "<TpPessoaDebtd>" + par_dspesemi +
                                    "</TpPessoaDebtd>"
                 aux_textoxml[17] = "<CNPJ_CPFCliDebtd>" + par_cpfcgemi +
                                    "</CNPJ_CPFCliDebtd>"
                 aux_textoxml[18] = "<NomCliDebtd>" +  par_nmpesemi +
                                    "</NomCliDebtd>"
                 aux_textoxml[19] = "<ISPBIFCredtd>" + par_ispbcred + 
                                    "</ISPBIFCredtd>".
                                    
          IF par_dsdctacr = "CC" OR par_dsdctacr = "PP" THEN
              ASSIGN aux_textoxml[20] = "<AgCredtd>" + aux_cdagenbc + 
                                    "</AgCredtd>"
                 aux_textoxml[21] = "<TpCtCredtd>" + par_dsdctacr +
                                    "</TpCtCredtd>"
                     aux_textoxml[22] = "<CtCredtd>" + aux_nrcctrcb1 +
                                        "</CtCredtd>".
          ELSE
              ASSIGN aux_textoxml[20] = ""
                     aux_textoxml[21] = "<TpCtCredtd>" + par_dsdctacr +
                                        "</TpCtCredtd>"
                     aux_textoxml[22] = "<CtPgtoCredtd>" + aux_nrcctrcb2 +
                                        "</CtPgtoCredtd>".
                                        
          ASSIGN aux_textoxml[23] = "<TpPessoaCredtd>" + par_dspesrec +
                                    "</TpPessoaCredtd>"
                 aux_textoxml[24] = "<CNPJ_CPFCliCredtd>" + par_cpfcgrcb +
                                    "</CNPJ_CPFCliCredtd>"
                 aux_textoxml[25] = "<NomCliCredtd>" + par_nmpesrcb +
                                    "</NomCliCredtd>"
                 aux_textoxml[26] = "<VlrLanc>" + par_vldocmto + 
                                    "</VlrLanc>"
                 aux_textoxml[27] = "<FinlddCli>" + par_cdfinrcb +
                                    "</FinlddCli>"
                 aux_textoxml[28] = "<CodIdentdTransf>" + par_cdidtran +
                                   "</CodIdentdTransf>"
                 aux_textoxml[29] = "<Hist>" + par_dshistor +
                                   "</Hist>"
                 aux_textoxml[30] = "<DtMovto>" + par_dtmvtolt + 
                                    "</DtMovto>"
                 aux_textoxml[31] = "</" + par_nmmsgenv + ">"
                 aux_textoxml[32] = "</SISMSG>".   
      END.
  ELSE
  /* Descricao: IF requisita Transferencia para repasse de tributos estaduais*/
  IF par_nmmsgenv = "STR0020" THEN
  DO:
      ASSIGN aux_textoxml[09] = "<" + par_nmmsgenv + ">"
             aux_textoxml[10] = "<CodMsg>" + par_nmmsgenv + "</CodMsg>"
             aux_textoxml[11] = "<NumCtrlIF>" + par_nrctrlif + "</NumCtrlIF>"
             aux_textoxml[12] = "<ISPBIFDebtd>" + par_ispbdebt +
                                  "</ISPBIFDebtd>"
             aux_textoxml[13] = "<ISPBIFCredtd>" + par_ispbcred + 
                                "</ISPBIFCredtd>"
             aux_textoxml[14] = "<AgCredtd>" + aux_cdagenbc + 
                                "</AgCredtd>"
             aux_textoxml[15] = "<CtCredtd>" + par_nrcctrcb +
                                "</CtCredtd>"
             aux_textoxml[16] = "<CodSEFAZ>" + "24" + "</CodSEFAZ>"
             aux_textoxml[17] = "<TpReceita>" + "9" + "</TpReceita>"
             aux_textoxml[18] = "<TpRecolht>" + "N" + "</TpRecolht>"
             aux_textoxml[19] = "<DtArrec>" + par_dtmvtolt + "</DtArrec>"
             aux_textoxml[20] = "<VlrLanc>" + par_vldocmto + "</VlrLanc>"
             aux_textoxml[21] = "<NivelPref></NivelPref>"
             aux_textoxml[22] = "<Grupo_STR0020_VlrInf>"
             aux_textoxml[23] = "<TpVlrInf>" + "25" + "</TpVlrInf>"
             aux_textoxml[24] = "<VlrInf>" + par_vldocmto + "</VlrInf>"
             aux_textoxml[25] = "</Grupo_STR0020_VlrInf>"
             aux_textoxml[26] = "<Hist>" + par_nrseqarq + "</Hist>"
             aux_textoxml[27] = "<DtAgendt>" + par_dtagendt + "</DtAgendt>"
             aux_textoxml[28] = "<HrAgendt></HrAgendt>"
             aux_textoxml[29] = "<DtMovto>" + par_dtmvtopr + "</DtMovto>"
             aux_textoxml[30] = "</" + par_nmmsgenv + ">"
             aux_textoxml[31] = "</SISMSG>".
             
  END.
  ELSE
  /* STR0037 e PAG0137
    Descriçao: destinado a IF requisitar transferencia de recursos 
               com débito em conta-salário. (TEC) */
  IF  par_nmmsgenv = "STR0037" OR par_nmmsgenv = "PAG0137"  THEN
      ASSIGN aux_textoxml[9]  = "<" + par_nmmsgenv + ">"
             aux_textoxml[10] = "<CodMsg>" + par_nmmsgenv + "</CodMsg>"      
             aux_textoxml[11] = "<NumCtrlIF>" + par_nrctrlif +
                                "</NumCtrlIF>"
             aux_textoxml[12] = "<ISPBIFDebtd>" + par_ispbdebt +
                                "</ISPBIFDebtd>"
             aux_textoxml[13] = "<AgDebtd>" + par_cdagectl +
                                "</AgDebtd>"
             aux_textoxml[14] = "<CtDebtd>" + par_nrdconta + 
                                "</CtDebtd>"
             aux_textoxml[15] = "<CPFCliDebtd>" + par_cpfcgemi +
                                "</CPFCliDebtd>"
             aux_textoxml[16] = "<NomCliDebtd>" + par_nmpesemi +
                                "</NomCliDebtd>"
             aux_textoxml[17] = "<ISPBIFCredtd>" + par_ispbcred + 
                                "</ISPBIFCredtd>"  
             aux_textoxml[18] = "<AgCredtd>" + aux_cdagenbc + 
                                "</AgCredtd>"              
             aux_textoxml[19] = "<TpCtCredtd>" + par_dsdctacr +
                                "</TpCtCredtd>"
             aux_textoxml[20] = "<CtCredtd>" + par_nrcctrcb +
                                "</CtCredtd>"
             aux_textoxml[21] = "<VlrLanc>" + par_vldocmto +
                                "</VlrLanc>"
             aux_textoxml[22] = "<DtMovto>" + par_dtmvtolt +
                                "</DtMovto>"   
             aux_textoxml[23] = "</" + par_nmmsgenv + ">"
             aux_textoxml[24] = "</SISMSG>".
 
  /* Faz uma copia do XML de envio para o diretorio salvar */
  OUTPUT STREAM str_1 TO VALUE (aux_nmarqxml).

  /* Cria o arquivo */
  DO aux_contador = 1 TO 35:

       IF   aux_textoxml[aux_contador] = ""   THEN
            NEXT.
  
       PUT STREAM str_1 UNFORMATTED aux_textoxml[aux_contador].
       /* String que recebe a mensagem enviada por buffer */
       ASSIGN aux_dsarqenv = aux_dsarqenv + aux_textoxml[aux_contador].
  END.
  
  OUTPUT STREAM str_1 CLOSE.

  /* Cria registro de Debito */
  CREATE gnmvcen.
  ASSIGN gnmvcen.cdagectl = crapcop.cdagectl
         gnmvcen.dtmvtolt = crapdat.dtmvtocd
         gnmvcen.dsmensag = par_nmmsgenv
         gnmvcen.dsdebcre = "D" /*Debito em Conta*/
         gnmvcen.vllanmto = DEC(REPLACE(par_vldocmto,".",",")).
  VALIDATE gnmvcen.

  RUN sistema/generico/procedures/b1wgen0050.p PERSISTENT SET h-b1wgen0050.
                                       
  IF  VALID-HANDLE (h-b1wgen0050)  THEN
      DO:
          RUN grava-log-ted IN h-b1wgen0050 (INPUT par_cdcooper,
                                             INPUT TODAY,
                                             INPUT par_hrtransa,
                                             INPUT par_cdorigem,
                                             INPUT "B1WGEN0046",
                                             INPUT 1,
                                             INPUT aux_nmarquiv,
                                             INPUT par_nmmsgenv,
                                             INPUT par_nrctrlif,
                                             INPUT DEC(REPLACE(par_vldocmto,".",",")),
                                             INPUT par_cdbcoctl,
                                             INPUT par_cdagectl,
                                             INPUT par_nrdconta,
                                             INPUT par_nmpesemi,
                                             INPUT par_cpfcgemi,
                                             INPUT par_cdbccxlt,
                                             INPUT par_cdagenbc,
                                             INPUT par_nrcctrcb,
                                             INPUT par_nmpesrcb,
                                             INPUT par_cpfcgrcb,
                                             INPUT par_cdidtran,
                                             INPUT "",
                                             INPUT par_cdagenci, /*agencia/pac*/
                                             INPUT par_nrdcaixa, /*nr. do caixa*/
                                             INPUT par_cdoperad, /*operador*/
                                             INPUT par_ispbcred,
                                             INPUT 0) NO-ERROR. /* sem crise */
                                           
          /* TESTE RANGHETTI */ 
          IF  ERROR-STATUS:ERROR THEN
              DO:
                     RUN sistema/generico/procedures/b1wgen0016.p 
                         PERSISTENT SET h-b1wgen0016.
        
                       aux_dscritic = "RETURN-VALUE: " + RETURN-VALUE +
                                      " GET-MSG: " + ERROR-STATUS:GET-MESSAGE(1).

                     /* Gerar log das teds com erro */
                     RUN gera_arquivo_log_ted IN h-b1wgen0016(        
                                              INPUT par_cdcooper,     
                                              INPUT "RETURN-VALUE + GET-MSG",      
                                              INPUT "b1wgen0046",     
                                              INPUT TODAY,            
                                              INPUT par_nrdconta,     
                                              INPUT par_cpfcgrcb,     
                                              INPUT par_cdbccxlt,     
                                              INPUT par_cdagenbc,     
                                              INPUT par_nrcctrcb,     
                                              INPUT par_nmpesemi,     
                                              INPUT par_cpfcgemi,     
                                              INPUT 0, /* inpessoa */
                                              INPUT 0, /* tpdconta */
                                              INPUT par_vldocmto,     
                                              INPUT par_dshistor,     
                                              INPUT par_cdfinrcb,     
                                              INPUT par_ispbcred,     
                                              INPUT aux_dscritic).    
        
                     IF  VALID-HANDLE(h-b1wgen0016) THEN 
                         DELETE PROCEDURE h-b1wgen0016. 

              END.

          DELETE PROCEDURE h-b1wgen0050.
          
          /* Se houve erro retorna "NOK" */
          IF  RETURN-VALUE <> "OK" THEN
              DO:
                  RUN sistema/generico/procedures/b1wgen0016.p 
                      PERSISTENT SET h-b1wgen0016.

                  /* Gerar log das teds com erro */
                  RUN gera_arquivo_log_ted IN h-b1wgen0016(        
                                           INPUT par_cdcooper,     
                                           INPUT "grava-log-ted",      
                                           INPUT "b1wgen0046",     
                                           INPUT TODAY,            
                                           INPUT par_nrdconta,     
                                           INPUT par_cpfcgrcb,     
                                           INPUT par_cdbccxlt,     
                                           INPUT par_cdagenbc,     
                                           INPUT par_nrcctrcb,     
                                           INPUT par_nmpesemi,     
                                           INPUT par_cpfcgemi,     
                                           INPUT 0, /* inpessoa */
                                           INPUT 0, /* tpdconta */
                                           INPUT par_vldocmto,     
                                           INPUT par_dshistor,     
                                           INPUT par_cdfinrcb,     
                                           INPUT par_ispbcred,     
                                           INPUT aux_dscritic).    

                  IF  VALID-HANDLE(h-b1wgen0016) THEN 
                      DELETE PROCEDURE h-b1wgen0016. 

                  RETURN "NOK".   
              END.


      END.

      /* Com o comando SUDO pois para conecta no MQ através do script
         o usuário precisa ser ROOT */
      UNIX SILENT VALUE ("/usr/bin/sudo /usr/local/cecred/bin/mqcecred_envia.pl"
                         + " --msg='" + aux_dsarqenv + "'"
                         + " --coop='" + STRING(par_cdcooper) + "'"
                         + " --arq='" + aux_nmarqxml + "'"). 

      /* Logar envio 
         *****************************************************************
         * Cuidar ao mecher no log pois os espacamentos e formats estao  *
         * ajustados para que a tela LogSPB pegue os dados com SUBSTRING * 
         *****************************************************************/
      UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + " - " +
           STRING(TIME,"HH:MM:SS") + " - " + "b1wgen0046" +
           " - ENVIADA OK         --> "  + 
           "Arquivo " + STRING(aux_nmarquiv, "x(40)") +
           ". Evento: " + STRING(par_nmmsgenv, "x(9)") + 
           ", Numero Controle: " + STRING(par_nrctrlif, "x(20)") +
           ", Hora: " + STRING(TIME,"HH:MM:SS") +
           ", Valor: " + STRING(DEC(REPLACE(par_vldocmto,".",",")),"zzz,zzz,zz9.99") +
           ", Banco Remet.: " + STRING(INT(par_cdbcoctl), "zz9") +   
           ", Agencia Remet.: " + STRING(INT(par_cdagectl),"zzzz9") +
           ", Conta Remet.: " + STRING(INT(par_nrdconta), "zzzzzzzz9") +
           ", Nome Remet.: " + STRING(par_nmpesemi,"x(40)") +
           ", CPF/CNPJ Remet.: " + STRING(DEC(par_cpfcgemi),"zzzzzzzzzzzzz9") +
           ", Banco Dest.: " + STRING(INT(par_cdbccxlt),"zz9") +
           ", Agencia Dest.: " + STRING(INT(par_cdagenbc),"zzzz9") +
           ", Conta Dest.: " + STRING(par_nrcctrcb,"xxxxxxxxxxxxxx") +
           ", Nome Dest.: " + STRING(par_nmpesrcb,"x(40)") +
           ", CPF/CNPJ Dest.: " + STRING(DEC(par_cpfcgrcb),"zzzzzzzzzzzzz9") +
           ", Cod. Ident. Tansf.: " + STRING(par_cdidtran, "x(25)") +
           '"' + " >> " + aux_nmarqlog). 

   RETURN "OK".
  
END PROCEDURE.
/*............................................................................*/


/******************************************************************************/
/**                       Envia Pagto VR-Boleto  - SPB                       **/
/******************************************************************************/
PROCEDURE proc_envia_vr_boleto:

/*-------------------------- Variaveis de Entrada ------------------------*/
DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER   /* Cooperativa*/   NO-UNDO.  
DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER /* Cod. Agencia  */  NO-UNDO. 
DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER /* Numero  Caixa */  NO-UNDO. 
DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER /* Operador */     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdorigem AS INTEGER /* Cod. Origem */    NO-UNDO.
DEFINE INPUT  PARAMETER par_nrctrlif AS CHARACTER  /* NumCtrlIF */   NO-UNDO.
DEFINE INPUT  PARAMETER par_dscodbar AS CHAR /* codigo de barras */  NO-UNDO.
DEFINE INPUT  PARAMETER par_cdbanced AS INTE /* Banco Cedente */     NO-UNDO.
DEFINE INPUT  PARAMETER par_cdageced AS INTE /* Agencia Cedente */   NO-UNDO.
DEFINE INPUT  PARAMETER par_tppesced AS CHAR /* tp pessoa cedente */ NO-UNDO.
DEFINE INPUT  PARAMETER par_nrinsced AS DECIMAL /* CPF/CNPJ Ced  */  NO-UNDO.
DEFINE INPUT  PARAMETER par_tppessac AS CHAR /* tp pessoa sacado */  NO-UNDO.
DEFINE INPUT  PARAMETER par_nrinssac AS DECIMAL /* CPF/CNPJ Sac  */  NO-UNDO.
DEFINE INPUT  PARAMETER par_vldocmto AS DECIMAL /* Vlr. DOCMTO */    NO-UNDO.
DEFINE INPUT  PARAMETER par_vldesabt AS DECIMAL /* Vlr Desc. Abat */ NO-UNDO.
DEFINE INPUT  PARAMETER par_vlrjuros AS DECIMAL /* Vlr Juros */      NO-UNDO.
DEFINE INPUT  PARAMETER par_vlrmulta AS DECIMAL /* Vlr Multa */      NO-UNDO.
DEFINE INPUT  PARAMETER par_vlroutro AS DECIMAL /* Vlr Out Acresc */ NO-UNDO.
DEFINE INPUT  PARAMETER par_vldpagto AS DECIMAL /* Vlr Pagamento */  NO-UNDO.

/*--------------------------- Variaveis de Saida -------------------------*/
DEFINE OUTPUT PARAMETER aux_dscritic AS CHARACTER                    NO-UNDO.

/*-------------------------- Variaveis de Controle -----------------------*/
DEFINE VARIABLE aux_flgutstr         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE aux_nmmsgenv         AS CHARACTER                    NO-UNDO.

/*----------------------- Parametros para o gera_XML ---------------------*/
DEFINE VARIABLE aux_cdlegado         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_tpmanut          AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_cdstatus         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_nroperacao       AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_fldebcred        AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dspesced         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_dspessac         AS CHARACTER                    NO-UNDO.

DEFINE VARIABLE aux_dtmvtolt         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vldocmto         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vldesabt         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vlrjuros         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vlrmulta         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vlroutro         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_vldpagto         AS CHARACTER                    NO-UNDO.

DEFINE VARIABLE aux_ispbdebt         AS DECIMAL                      NO-UNDO.
DEFINE VARIABLE aux_nrinsced         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE aux_nrinssac         AS CHARACTER                    NO-UNDO.

    ASSIGN aux_flgutstr = FALSE.

    /* Busca dados da cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapcop THEN
         DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,             /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.
    
    /* Busca data do sistema */ 
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper  NO-LOCK NO-ERROR.
    
    IF   NOT AVAIL crapdat THEN 
         DO:
            ASSIGN aux_cdcritic = 1
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.

    /* ISPB Debt. eh os 8 primeiros digitos do CNPJ da Coop */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "CNPJCENTRL" AND 
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "CNPJ da Central nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.
    ELSE      
         ASSIGN aux_ispbdebt = DECIMAL(craptab.dstextab).

    /* ISPB Credt eh os 8 primeiros digitos do CNPJ do Banco de Destino */
    FIND crapban WHERE crapban.cdbccxlt = par_cdbanced AND 
                       crapban.flgdispb = TRUE         NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapban   THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Banco nao operante no SPB.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.

    /*-- Operando com mensagens STR --*/
    IF   crapcop.flgopstr   THEN
         IF   crapcop.iniopstr <= TIME AND crapcop.fimopstr >= TIME   THEN
              ASSIGN aux_flgutstr = TRUE.             
         
    IF   aux_flgutstr = FALSE  THEN
         DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Horário de envio dos TEDs encerrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT aux_cdcritic,      
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
         END.

    /* Alimenta variaveis default */
    ASSIGN /* CPF/CNPJ Cedente */
           aux_nrinsced = IF   par_tppesced = "F"   THEN
                               STRING(par_nrinsced,"99999999999")
                          ELSE
                               STRING(par_nrinsced,"99999999999999")

           /* CPF/CNPJ Sacado */
           aux_nrinssac = IF   par_tppessac = "F"   THEN
                               STRING(par_nrinssac,"99999999999") 
                          ELSE
                               STRING(par_nrinssac,"99999999999999")

           /* Format da data deve ser AAAA-MM-DD */
           aux_dtmvtolt      = STRING(YEAR(TODAY), "9999") + "-" +
                               STRING(MONTH(TODAY), "99") + "-" +
                               STRING(DAY(TODAY), "99")  
           
           /* Separador decimal de centavos deve ser "." */
           aux_vldocmto      = REPLACE(STRING(par_vldocmto),",",".")
           aux_vldesabt      = REPLACE(STRING(par_vldesabt),",",".")
           aux_vlrjuros      = REPLACE(STRING(par_vlrjuros),",",".")
           aux_vlrmulta      = REPLACE(STRING(par_vlrmulta),",",".")
           aux_vlroutro      = REPLACE(STRING(par_vlroutro),",",".")
           aux_vldpagto      = REPLACE(STRING(par_vldpagto),",",".")          
           
           /* Alimenta as variaveis do HEADER */           
           aux_cdlegado   = STRING(crapcop.cdagectl)
           aux_tpmanut    = "I" /* Inclusao */
           aux_cdstatus   = "D" /* Mensagem do tipo definitiva - real */
           aux_fldebcred  = "D". /* Debito */  
           /*    crapcop.dssigaut   */
           aux_nroperacao = par_nrctrlif.

    /*-- Monta o BODY --*/
    RUN gera_xml_vr_boleto
        (INPUT par_cdcooper,
         INPUT par_cdorigem,
         INPUT par_cdagenci,
         INPUT par_nrdcaixa,
         INPUT par_cdoperad,
         INPUT "STR0026", /* Cod. da Mensagem */
              /* HEADER */
         INPUT aux_cdlegado, /* Cod. Legado */
         INPUT aux_tpmanut, /* Inclusao */
         INPUT aux_cdstatus, /* Mensagem do tipo definitiva */
         INPUT aux_nroperacao,
         INPUT aux_fldebcred, /* Debito */
               /* BODY */
         INPUT par_nrctrlif, /* Nr. controle da IF*/
         INPUT SUBSTR(STRING(aux_ispbdebt,"99999999999999"),1,8),
         INPUT STRING(crapcop.cdagectl),
         INPUT par_cdbanced,
         INPUT STRING(par_cdageced),
         INPUT aux_vldpagto,
         INPUT par_tppessac,
         INPUT aux_nrinssac,
         INPUT par_tppesced,
         INPUT aux_nrinsced,
         INPUT par_dscodbar,
         INPUT aux_vldocmto,
         INPUT aux_vldesabt,
         INPUT aux_vlrjuros,
         INPUT aux_vlrmulta,
         INPUT aux_vlroutro,
         INPUT aux_dtmvtolt).

    RETURN "OK".

END PROCEDURE.
/*............................................................................*/

/******************************************************************************/
/**                             Gera arquivo XML                             **/
/******************************************************************************/

PROCEDURE gera_xml_vr_boleto:

DEFINE INPUT PARAMETER par_cdcooper   AS INTEGER                     NO-UNDO.
DEFINE INPUT PARAMETER par_cdorigem   AS INTEGER                     NO-UNDO.
DEFINE INPUT PARAMETER par_cdagenci   AS INTEGER /* Cod. Agencia  */ NO-UNDO. 
DEFINE INPUT PARAMETER par_nrdcaixa   AS INTEGER /* Numero  Caixa */ NO-UNDO. 
DEFINE INPUT PARAMETER par_cdoperad   AS CHARACTER /* Operador */    NO-UNDO.
                                 /* HEADER */
DEFINE INPUT PARAMETER par_nmmsgenv   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdlegado   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_tpmanut    AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdstatus   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nroperacao AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_fldebcred  AS CHARACTER                   NO-UNDO.
                                 /* BODY - STR0026 */
DEFINE INPUT PARAMETER par_nrctrlif   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_ispbdebt   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdagectl   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_cdbanced   AS INTEGER                     NO-UNDO.
DEFINE INPUT PARAMETER par_cdageced   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vldpagto   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dspessac   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nrinssac   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dspesced   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_nrinsced   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dscodbar   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vldocmto   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vldesabt   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vlrjuros   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vlrmulta   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_vlroutro   AS CHARACTER                   NO-UNDO.
DEFINE INPUT PARAMETER par_dtmvtolt   AS CHARACTER                   NO-UNDO.
                              /* FIM - BODY - STR0026 */

                             /* Variaveis Internas */
DEFINE VARIABLE aux_contador          AS INTEGER                     NO-UNDO.
DEFINE VARIABLE aux_textoxml          AS CHARACTER    EXTENT 31      NO-UNDO.
DEFINE VARIABLE aux_nmtagbod          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarquiv          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarqlog          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarqxml          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_nmarqenv          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_dsarqenv          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_contctnr          AS INTEGER                     NO-UNDO.
DEFINE VARIABLE aux_ispbcred          AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_canpagto          AS INTEGER                     NO-UNDO.


DEFINE VARIABLE h-b1wgen0050          AS HANDLE                      NO-UNDO.

         /* Arquivo gerado para o envio */
  ASSIGN aux_nmarqxml = "/usr/coop/" + crapcop.dsdircop +
                        "/salvar/msgenv_cecred_" + STRING(YEAR(TODAY),"9999")
                        + STRING(MONTH(TODAY),"99") + STRING(DAY(TODAY),"99")
                        + STRING(ETIME,"9999999999") + ".xml"
         /* Arquivo de log - tela LOGSPB*/
         aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" + 
                        "mqcecred_envio_vrboleto" +
                        STRING(crapdat.dtmvtocd,"999999") + ".log"
         aux_nmarquiv = SUBSTRING(TRIM(aux_nmarqxml),
                                       R-INDEX(aux_nmarqxml,"/") + 1).

  FIND crapban WHERE crapban.cdbccxlt = par_cdbanced AND 
                     crapban.flgdispb = TRUE         NO-LOCK NO-ERROR.

  ASSIGN aux_ispbcred = STRING(crapban.nrispbif,"99999999").

                      /* HEADER - mensagens STR e PAG */
  ASSIGN aux_textoxml[1] = "<SISMSG>"
         aux_textoxml[2] = "<SEGCAB>" 
         aux_textoxml[3] = "<CD_LEGADO>" + par_cdlegado + "</CD_LEGADO>"
         aux_textoxml[4] = "<TP_MANUT>" + par_tpmanut + "</TP_MANUT>"
         aux_textoxml[5] = "<CD_STATUS>" + par_cdstatus + "</CD_STATUS>"
         aux_textoxml[6] = "<NR_OPERACAO>" + par_nroperacao + 
                           "</NR_OPERACAO>"
         aux_textoxml[7] = "<FL_DEB_CRED>" + par_fldebcred + 
                           "</FL_DEB_CRED>"
         aux_textoxml[8] = "</SEGCAB>".
         
    /* BODY  - mensagem STR 
       STR0026
       Descriçao: destinado ao pagamento de VR Boletos */

  
  ASSIGN aux_canpagto = IF par_cdorigem = 2 THEN 1 ELSE 3.

  ASSIGN aux_textoxml[9]  = "<" + par_nmmsgenv + ">"
         aux_textoxml[10] = " <CodMsg>" + par_nmmsgenv + "</CodMsg>"      
         aux_textoxml[11] = "<NumCtrlIF>" + par_nrctrlif +
                            "</NumCtrlIF>"

         aux_textoxml[12] = "<ISPBIFDebtd>" + par_ispbdebt +
                            "</ISPBIFDebtd>"
         aux_textoxml[13] = "<AgDebtd>" + par_cdagectl +
                            "</AgDebtd>"

         aux_textoxml[14] = "<ISPBIFCredtd>" + aux_ispbcred +
                            "</ISPBIFCredtd>"
         aux_textoxml[15] = "<AgCredtd>" + par_cdageced +
                            "</AgCredtd>"

         aux_textoxml[16] = "<VlrLanc>" + par_vldpagto + 
                            "</VlrLanc>"

         aux_textoxml[17] = "<TpPessoaSacd>" + par_dspessac +
                            "</TpPessoaSacd>"                                    
         aux_textoxml[18] = "<CNPJ_CPFSacd>" + par_nrinssac +
                            "</CNPJ_CPFSacd>"

         aux_textoxml[19] = "<TpPessoaCed>" + par_dspesced +
                            "</TpPessoaCed>"
         aux_textoxml[20] = "<CNPJ_CPFCed>" + par_nrinsced +
                            "</CNPJ_CPFCed>"

         aux_textoxml[21] = "<TpDocBarras>1</TpDocBarras>" 

         aux_textoxml[22] = "<NumCodBarras>" + par_dscodbar +
                            "</NumCodBarras>" 

         aux_textoxml[23] = "<CanPgto>" + STRING(aux_canpagto) + "</CanPgto>" /* Internet */

         aux_textoxml[24] = "<VlrDoc>" + par_vldocmto + 
                            "</VlrDoc>"

         aux_textoxml[25] = "<VlrDesct_Abatt>" + par_vldesabt + 
                            "</VlrDesct_Abatt>"

         aux_textoxml[26] = "<VlrJuros>" + par_vlrjuros + 
                            "</VlrJuros>"

         aux_textoxml[27] = "<VlrMulta>" + par_vlrmulta + 
                            "</VlrMulta>"

         aux_textoxml[28] = "<VlrOtrAcresc>" + par_vlroutro + 
                            "</VlrOtrAcresc>"

         aux_textoxml[29] = "<DtMovto>" + par_dtmvtolt + 
                            "</DtMovto>"
         aux_textoxml[30] = "</" + par_nmmsgenv + ">"
         aux_textoxml[31] = "</SISMSG>".
 
  /* Faz uma copia do XML de envio para o diretorio salvar */
  OUTPUT STREAM str_1 TO VALUE (aux_nmarqxml).

  /* Cria o arquivo */
  DO aux_contador = 1 TO 31:

       IF   aux_textoxml[aux_contador] = ""   THEN
            NEXT.
  
       PUT STREAM str_1 UNFORMATTED aux_textoxml[aux_contador].
       /* String que recebe a mensagem enviada por buffer */
       ASSIGN aux_dsarqenv = aux_dsarqenv + aux_textoxml[aux_contador].
  END.
  
  OUTPUT STREAM str_1 CLOSE.
  
  /* Com o comando SUDO pois para conecta no MQ através do script
     o usuário precisa ser ROOT */
  UNIX SILENT VALUE ("/usr/bin/sudo /usr/local/cecred/bin/mqcecred_envia.pl"
                     + " --msg='" + aux_dsarqenv + "'"
                     + " --coop='" + STRING(par_cdcooper) + "'"
                     + " --arq='" + aux_nmarqxml + "'").
  
  /* Cria registro de Debito */
  CREATE gnmvcen.
  ASSIGN gnmvcen.cdagectl = crapcop.cdagectl
         gnmvcen.dtmvtolt = crapdat.dtmvtocd
         gnmvcen.dsmensag = par_nmmsgenv
         gnmvcen.dsdebcre = "D" /*Debito em Conta*/
         gnmvcen.vllanmto = DEC(REPLACE(par_vldpagto,".",",")).
  VALIDATE gnmvcen.

  /* Logar envio 
     *****************************************************************
     * Cuidar ao alterar o log pois os espacamentos e formats estao  *
     * ajustados para que a tela LogSPB pegue os dados com SUBSTRING * 
     *****************************************************************/
  UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + " - " +
       STRING(TIME,"HH:MM:SS") + " - " + "b1wgen0046" +
       " - ENVIADA OK         --> "  + 
       "Arquivo " + STRING(aux_nmarquiv, "x(40)") +
       ". Evento: " + STRING(par_nmmsgenv, "x(9)") + 
       ", Numero Controle: " + STRING(par_nrctrlif, "x(20)") +
       ", Hora: " + STRING(TIME,"HH:MM:SS") +
       ", Valor: " + STRING(DEC(REPLACE(par_vldpagto,".",",")),"zzz,zzz,zz9.99") +
       ", Banco Sacado.: " + STRING(crapcop.cdbcoctl, "zz9") +   
       ", Agencia Sacado: " + STRING(INT(par_cdagectl),"zzzz9") +
       ", CPF/CNPJ Sacado: " + STRING(par_nrinssac) +
       ", Banco Cedente.: " + STRING(INT(par_cdbanced),"zz9") +
       ", Agencia Cedente: " + STRING(INT(par_cdageced),"zzzz9") +
       ", Cod.Barras.: " + par_dscodbar +
       '"' + " >> " + aux_nmarqlog). 
       
/*  RUN sistema/generico/procedures/b1wgen0050.p PERSISTENT SET h-b1wgen0050.
                                       
  IF  VALID-HANDLE (h-b1wgen0050)  THEN
      DO:
          RUN grava-log-ted IN h-b1wgen0050 (INPUT par_cdcooper,
                                             INPUT TODAY,
                                             INPUT TIME,
                                             INPUT par_cdorigem,
                                             INPUT "B1WGEN0046",
                                             INPUT 1,
                                             INPUT aux_nmarquiv,
                                             INPUT par_nmmsgenv,
                                             INPUT par_nrctrlif,
                                             INPUT DEC(REPLACE(par_vldocmto,".",",")),
                                             INPUT par_cdbcoctl,
                                             INPUT par_cdagectl,
                                             INPUT par_nrdconta,
                                             INPUT par_nmpesemi,
                                             INPUT par_cpfcgemi,
                                             INPUT par_cdbccxlt,
                                             INPUT par_cdagenbc,
                                             INPUT par_nrcctrcb,
                                             INPUT par_nmpesrcb,
                                             INPUT par_cpfcgrcb,
                                             INPUT par_cdidtran,
                                             INPUT "",
                                             INPUT par_cdagenci, /*agencia/pac*/
                                             INPUT par_nrdcaixa, /*nr. do caixa*/
                                             INPUT par_cdoperad). /*operador*/
                                           
          DELETE PROCEDURE h-b1wgen0050.
      END.*/

   RETURN "OK".
  
END PROCEDURE.
/*............................................................................*/

