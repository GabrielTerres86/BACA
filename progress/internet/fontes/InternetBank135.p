/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank135.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Dionathan Henchel
   Data    : 04/05/2015                        Ultima atualizacao: 27/09/2016

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultas de Comprovantes Recebidos - Mobile
   
   Alteracoes: 26/08/2015 - Na chamada da procedure obtem-log-cecred, incluir
                            novo parametro - Melhoria Gestao de TEDs/TECs - 85
                            (Lucas Ranghetti)
                            
               12/11/2015 - Na chamada da procedure obtem-log-cecred, incluir
                            novo parametro inestcri projeto Estado de Crise
                            (Jorge/Andrino)             

               27/09/2016 - M211 - Envio do parado cdifconv na chamada da 
                            obtem-log-cecred (Jonata-RKAM)
                            
 .............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0050tt.i }

DEF VAR h-b1wgen0050 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsgenv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsgrec AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_nrsequen AS INT                                   NO-UNDO.
DEF  INPUT PARAM par_dtiniper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtfimper AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_qtregpag AS INT                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.


DEF TEMP-TABLE tt-logspb-detalhe-aux LIKE tt-logspb-detalhe.

EMPTY TEMP-TABLE tt-logspb-detalhe-aux.
EMPTY TEMP-TABLE tt-logspb-detalhe.

ASSIGN xml_dsmsgerr = "".

RUN sistema/generico/procedures/b1wgen0050.p PERSISTENT SET h-b1wgen0050.

IF  NOT VALID-HANDLE(h-b1wgen0050)  THEN
    ASSIGN xml_dsmsgerr = "<dsmsgerr>Handle invalido para BO b1wgen0050." +
                          "</dsmsgerr>".  

IF  xml_dsmsgerr <> ""  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0050.

        RETURN "NOK".
    END.  

RUN transacao.


/* Gera o xml de retorno */
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '<COMPROVANTE>'.

FOR EACH tt-logspb-detalhe BY tt-logspb-detalhe.dttransa DESC
                           BY tt-logspb-detalhe.hrtransa DESC:
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS>" +
    "<cdbanrem>" + TRIM(STRING(tt-logspb-detalhe.cdbanrem)) + "</cdbanrem>" +
    "<cdagerem>" + TRIM(STRING(tt-logspb-detalhe.cdagerem, "9999")) + "</cdagerem>" +
    "<nrctarem>" + TRIM(STRING(tt-logspb-detalhe.nrctarem)) + "</nrctarem>" +
    "<dsnomrem>" + TRIM(REPLACE(tt-logspb-detalhe.dsnomrem, "&", "")) + "</dsnomrem>" +
    "<dscpfrem>" + TRIM(STRING(tt-logspb-detalhe.dscpfrem)) + "</dscpfrem>" +
    "<cdbandst>" + TRIM(STRING(tt-logspb-detalhe.cdbandst)) + "</cdbandst>" +
    "<cdagedst>" + TRIM(STRING(tt-logspb-detalhe.cdagedst, "9999")) + "</cdagedst>" +
    "<nrctadst>" + TRIM(STRING(tt-logspb-detalhe.nrctadst)) + "</nrctadst>" +
    "<dsnomdst>" + TRIM(REPLACE(tt-logspb-detalhe.dsnomdst, "&", "")) + "</dsnomdst>" +
    "<dscpfdst>" + TRIM(STRING(tt-logspb-detalhe.dscpfdst)) + "</dscpfdst>" +
    "<dttransa>" + TRIM(STRING(tt-logspb-detalhe.dttransa)) + "</dttransa>" +
    "<hrtransa>" + TRIM(tt-logspb-detalhe.hrtransa) + "</hrtransa>" +
    "<vltransa>" + TRIM(STRING(tt-logspb-detalhe.vltransa,"zz,zzz,zz9.99-")) + "</vltransa>" +
    "<cdtiptra>" + TRIM(STRING(tt-logspb-detalhe.cdtiptra,"9")) + "</cdtiptra>" +
    "<dstiptra>" + TRIM(tt-logspb-detalhe.dstiptra) + "</dstiptra>" +
    "</DADOS>".

END. /*Fim do FOR EACH*/

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = '</COMPROVANTE>'.
                  
DELETE PROCEDURE h-b1wgen0050.

RETURN "OK".


PROCEDURE transacao:

    RUN obtem-log-cecred IN h-b1wgen0050 (INPUT par_cdcooper,
                                          INPUT 90,
                                          INPUT 900,
                                          INPUT "996",
                                          INPUT "INTERNETBANK",
                                          INPUT 0,
                                          INPUT par_dtiniper,
                                          INPUT par_dtfimper,
                                          INPUT 2,
                                          INPUT "P",
                                          INPUT par_nrdconta,
                                          INPUT par_nrsequen,
                                          INPUT 0,
                                          INPUT par_qtregpag,
                                          INPUT 0, /* inestcri, 0 Nao, 1 Sim */
                                          INPUT 3,  /* IF da TED - Todas */
                                          INPUT 0, /* par_vlrdated */
                                         OUTPUT TABLE tt-logspb,
                                         OUTPUT TABLE tt-logspb-detalhe,
                                         OUTPUT TABLE tt-logspb-totais,
                                         OUTPUT TABLE tt-erro).
    
    RUN obtem-log-sistema-cecred IN h-b1wgen0050 (INPUT par_cdcooper,
                                                  INPUT par_nrdconta,
                                                  INPUT par_dtiniper,
                                                  INPUT par_dtfimper,
                                                 OUTPUT TABLE tt-logspb-detalhe-aux).

    /* Concatena as duas tabelas */
    FOR EACH tt-logspb-detalhe-aux:
        
        CREATE tt-logspb-detalhe.

        BUFFER-COPY tt-logspb-detalhe-aux TO tt-logspb-detalhe.

    END. /*Fim do FOR EACH*/

END.


