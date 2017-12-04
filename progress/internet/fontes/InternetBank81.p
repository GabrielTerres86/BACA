/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank81.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Agosto/2012                        Ultima atualizacao: 29/11/2017
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Executar relatorio Demonstrativo Aplicacoes.
   
   Alteracoes: 11/06/2013 - Incluir procedure retorna-valor-blqjud e incluido
                            atributo xml vlblqjud (Lucas R.).
                            
               11/04/2014 - Correcao fechamento instancia b1wgen0112 (Daniel) 

			   30/03/2016 - Incluido o recebimento do parametro dsiduser para
							utiliza-lo na geracao do nome do arquivo
			               (Adriano).
                     
               29/11/2017 - Inclusao do valor de bloqueio em garantia. 
                            PRJ404 - Garantia.(Odirlei-AMcom)        
..............................................................................*/
 
CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0112tt.i }

DEF VAR h-b1wgen0112 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR aux_dslixml2 AS CHAR                                           NO-UNDO.

DEF VAR          aux_mesextra AS CHAR
        INIT "JAN,FEV,MAR,ABR,MAI,JUN,JUL,AGO,SET,OUT,NOV,DEZ"         NO-UNDO.
DEF VAR aux_dsmesext AS CHAR  EXTENT 14                                NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvctini AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvctfim AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_tprelato AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dsiduser AS CHAR							       NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF          VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF          VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
DEF          VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF          VAR aux_vlblqjud AS DECI                                  NO-UNDO.
DEF          VAR aux_vlresblq AS DECI                                  NO-UNDO.
DEF          VAR aux_vlblqapl_gar  AS DECI                             NO-UNDO.
DEF          VAR aux_vlblqpou_gar  AS DECI                             NO-UNDO.

DEF          VAR h-b1wgen0155 AS HANDLE                                NO-UNDO.

RUN sistema/generico/procedures/b1wgen0112.p PERSISTENT SET h-b1wgen0112.
            
IF  NOT VALID-HANDLE(h-b1wgen0112)  THEN
    DO:

        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0112."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".
        RETURN "NOK".
    END.

RUN sistema/generico/procedures/b1wgen0155.p PERSISTENT SET h-b1wgen0155.

IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
    DO:

        ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0155."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".
        RETURN "NOK".
    END.

ASSIGN aux_dtmvtolt = DATE(MONTH(par_dtmvtolt),1,YEAR(par_dtmvtolt)).
/*
IF (MONTH(par_dtvctfim) + 1) = 13  THEN
    par_dtvctfim = DATE(1,1,YEAR(par_dtvctfim) + 1).
ELSE
    par_dtvctfim = DATE(MONTH(par_dtvctfim) + 1,1,YEAR(par_dtvctfim)).
*/
          
          
ASSIGN aux_vlblqapl_gar = 0
       aux_vlblqpou_gar = 0.
          
/*** Busca Saldo Bloqueado Judicial ***/
    
RUN retorna-valor-blqjud IN h-b1wgen0155(
                         INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT 0, /* fixo - nrcpfcgc */
                         INPUT 0, /* fixo - cdtipmov */
                         INPUT 2, /* 2 - Aplicacao */
                         INPUT par_dtmvtolt,
                         OUTPUT aux_vlblqjud,
                         OUTPUT aux_vlresblq).

IF  RETURN-VALUE <> "OK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0155.
        
        IF  aux_dscritic = ""  THEN
            aux_dscritic = "Erro inesperado. Nao foi possivel " + 
                           "efetuar a transferencia.".
        
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".
        
        RETURN "NOK".
    END.

/*** Busca Saldo Bloqueado Garantia ***/
RUN calcula_bloq_garantia IN h-b1wgen0112
                         ( INPUT par_cdcooper,
                           INPUT par_nrdconta,                                             
                          OUTPUT aux_vlblqapl_gar,
                          OUTPUT aux_vlblqpou_gar,
                          OUTPUT aux_dscritic).

IF aux_dscritic <> "" THEN
DO:
   ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".   
   RUN proc_geracao_log (INPUT FALSE).
   RETURN "NOK".

END.
        
         
RUN Gera_Impressao_Aplicacao IN h-b1wgen0112
                      ( INPUT par_cdcooper,
                        INPUT 90,         /* cdagenci */
                        INPUT 0,          /* nrdcaixa */
                        INPUT "1",        /* cdoperad */
                        INPUT "IMPRES",   /* nmdatela */
                        INPUT "IMPRES",   /* cdprogra */
                        INPUT 3,          /* idorigem */
                        INPUT par_idseqttl,
                        INPUT par_dsiduser,  /* dsiduser */
                        INPUT 0,          /* inproces */
                        INPUT par_nrdconta,
                        INPUT 1,          /* tpmodelo */
                        INPUT par_dtvctini,
                        INPUT par_tprelato,
                        INPUT 0,          /* nraplica */
                        INPUT par_dtmvtolt,
                        INPUT par_dtvctfim,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT TABLE tt-demonstrativo,
                       OUTPUT TABLE tt-erro).


IF  RETURN-VALUE <> "OK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0112.

        IF  aux_dscritic = ""  THEN
            aux_dscritic = "Erro inesperado. Nao foi possivel " + 
                           "efetuar a transferencia.".

        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                              "</dsmsgerr>".

        RETURN "NOK".
    END.

/* VALIDAR SE HOUVERAM ERROS */
FIND FIRST tt-erro NO-LOCK NO-ERROR.
IF  AVAIL tt-erro THEN DO:

    DELETE PROCEDURE h-b1wgen0112.

    aux_dscritic = tt-erro.dscritic.

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                          "</dsmsgerr>".
    RETURN "NOK".
END.

/* VALIDAR TABELA DE DADOS */
FIND FIRST tt-demonstrativo NO-LOCK NO-ERROR.
IF  NOT AVAIL tt-demonstrativo THEN DO:

    DELETE PROCEDURE h-b1wgen0112.

    aux_dscritic = "Nao foram encontrados dados para a pesquisa!".

    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                          "</dsmsgerr>".
    RETURN "NOK".
END.

IF VALID-HANDLE(h-b1wgen0155) THEN
    DELETE PROCEDURE h-b1wgen0112.


ASSIGN aux_nrsequen = 0.

/*message "IBANK81: " aux_dtmvtolt par_dtvctini par_dtvctfim.*/

DO  WHILE ((par_dtvctini <= par_dtvctfim) AND /* LIMITE DATA FIM    */
           (aux_nrsequen < 12 )           AND /* LIMITE DE 12 MESES */
           (par_dtvctini <= aux_dtmvtolt)     /* LIMITE MES ATUAL   */
          ):

   ASSIGN aux_nrsequen = aux_nrsequen + 1.

   ASSIGN aux_dsmesext[aux_nrsequen] = 
                 STRING(ENTRY(MONTH(par_dtvctini),aux_mesextra,","))
                 + "/" + 
                 STRING(YEAR(par_dtvctini)).

   IF (MONTH(par_dtvctini) + 1) = 13  THEN
       par_dtvctini = DATE(1,1,YEAR(par_dtvctini) + 1).
   ELSE
       par_dtvctini = DATE(MONTH(par_dtvctini) + 1,1,YEAR(par_dtvctini)).

END.

/* MONTA LINHA DE CABECALHO DAS COLUNAS */
ASSIGN aux_dslinxml = 
       "<LINHA>" + 
            "<nraplica> </nraplica>" + 
            "<idsequen> </idsequen>" + 
            "<dstplanc> </dstplanc>" + 
            "<vlcolu01>" + aux_dsmesext[1]  + "</vlcolu01>" + 
            "<vlcolu02>" + aux_dsmesext[2]  + "</vlcolu02>" + 
            "<vlcolu03>" + aux_dsmesext[3]  + "</vlcolu03>" + 
            "<vlcolu04>" + aux_dsmesext[4]  + "</vlcolu04>" + 
            "<vlcolu05>" + aux_dsmesext[5]  + "</vlcolu05>" + 
            "<vlcolu06>" + aux_dsmesext[6]  + "</vlcolu06>" +
            "<vlcolu07>" + aux_dsmesext[7]  + "</vlcolu07>" + 
            "<vlcolu08>" + aux_dsmesext[8]  + "</vlcolu08>" + 
            "<vlcolu09>" + aux_dsmesext[9]  + "</vlcolu09>" + 
            "<vlcolu10>" + aux_dsmesext[10] + "</vlcolu10>" + 
            "<vlcolu11>" + aux_dsmesext[11] + "</vlcolu11>" + 
            "<vlcolu12>" + aux_dsmesext[12] + "</vlcolu12>" + 
/*            "<vlcolu13>" + aux_dsmesext[13] + "</vlcolu13>" +*/
            "<vlcolu14> </vlcolu14>" + 
            "<vlcolu15> </vlcolu15>" +
        "</LINHA>".

/* ABRE TAG DE INICIO */
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<DEMONSTRATIVO>".

FOR EACH tt-demonstrativo NO-LOCK
   BREAK BY tt-demonstrativo.nraplica
         BY tt-demonstrativo.idsequen:

    IF  FIRST-OF(tt-demonstrativo.nraplica) THEN DO:
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<APLICACAO nraplica='" + 
               STRING(tt-demonstrativo.nraplica,"zzz,zz9") + "'
               vlblqjud='" + STRING(aux_vlblqjud,"zzz,zzz,zzz,zz9.99") + "'
               vlblqapl_gar='" + STRING(aux_vlblqapl_gar,"zzz,zzz,zzz,zz9.99") + "'
               vlblqpou_gar='" + STRING(aux_vlblqpou_gar,"zzz,zzz,zzz,zz9.99") + "' >".
       
        /* CRIA LINHA DE TITULOS COM MESES **/
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = aux_dslinxml.
      
    END.

    ASSIGN aux_dslixml2 = "".
    RUN pi_cria_dados.

    IF  LAST-OF(tt-demonstrativo.nraplica) THEN DO:
        /* CRIA TAG FINAL DA APLICACAO */
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "</APLICACAO>".
    END.

    IF  VALID-HANDLE(h-b1wgen0155) THEN
        DELETE PROCEDURE h-b1wgen0155.

END.

/* FECHA TAG DE INICIO */
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</DEMONSTRATIVO>".

RETURN "OK".

/*............................................................................*/

PROCEDURE pi_cria_dados:


    ASSIGN aux_dslixml2 = 
 "<LINHA>" +
 "<nraplica>" + STRING(tt-demonstrativo.nraplica,"zzz,zz9")    + "</nraplica>"
 +
 "<idsequen>" + STRING(tt-demonstrativo.idsequen)              + "</idsequen>"
 +
 "<dstplanc>" + tt-demonstrativo.dstplanc                      + "</dstplanc>".
 
 IF aux_nrsequen >= 1 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu01>" + STRING(tt-demonstrativo.vlcolu01,"zz,zzz,zz9.99") 
         + "</vlcolu01>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu01></vlcolu01>".

 IF aux_nrsequen >= 2 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu02>" + STRING(tt-demonstrativo.vlcolu02,"zz,zzz,zz9.99") 
         + "</vlcolu02>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu02></vlcolu02>".

 IF aux_nrsequen >= 3 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu03>" + STRING(tt-demonstrativo.vlcolu03,"zz,zzz,zz9.99") 
         + "</vlcolu03>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu03></vlcolu03>".

 IF aux_nrsequen >= 4 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu04>" + STRING(tt-demonstrativo.vlcolu04,"zz,zzz,zz9.99") 
         + "</vlcolu04>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu04></vlcolu04>".

 IF aux_nrsequen >= 5 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu05>" + STRING(tt-demonstrativo.vlcolu05,"zz,zzz,zz9.99") 
         + "</vlcolu05>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu05></vlcolu05>".

 IF aux_nrsequen >= 6 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu06>" + STRING(tt-demonstrativo.vlcolu06,"zz,zzz,zz9.99") 
         + "</vlcolu06>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu06></vlcolu06>".

 IF aux_nrsequen >= 7 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu07>" + STRING(tt-demonstrativo.vlcolu07,"zz,zzz,zz9.99") 
         + "</vlcolu07>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu07></vlcolu07>".

 IF aux_nrsequen >= 8 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu08>" + STRING(tt-demonstrativo.vlcolu08,"zz,zzz,zz9.99") 
         + "</vlcolu08>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu08></vlcolu08>".

 IF aux_nrsequen >= 9 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu09>" + STRING(tt-demonstrativo.vlcolu09,"zz,zzz,zz9.99") 
         + "</vlcolu09>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu09></vlcolu09>".
    
 IF aux_nrsequen >= 10 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu10>" + STRING(tt-demonstrativo.vlcolu10,"zz,zzz,zz9.99") 
         + "</vlcolu10>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu10></vlcolu10>".

 IF aux_nrsequen >= 11 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu11>" + STRING(tt-demonstrativo.vlcolu11,"zz,zzz,zz9.99") 
         + "</vlcolu11>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu11></vlcolu11>".

 IF aux_nrsequen >= 12 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu12>" + STRING(tt-demonstrativo.vlcolu12,"zz,zzz,zz9.99") 
         + "</vlcolu12>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu12></vlcolu12>".

/* IF aux_nrsequen >= 13 THEN
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu13>" + STRING(tt-demonstrativo.vlcolu13,"zz,zzz,zz9.99") 
         + "</vlcolu13>".
 ELSE
    ASSIGN aux_dslixml2 = aux_dslixml2 +
           "<vlcolu13></vlcolu13>".*/


 ASSIGN aux_dslixml2 = aux_dslixml2 +
 "<vlcolu14>" + tt-demonstrativo.vlcolu14 + "</vlcolu14>"
 +
 "<vlcolu15>" + tt-demonstrativo.vlcolu15 + "</vlcolu15>"
 + "</LINHA>".

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = aux_dslixml2.


END PROCEDURE.

