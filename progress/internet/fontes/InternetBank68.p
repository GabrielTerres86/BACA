/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank70.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/Supero
    Data    : Agosto/2011                   Ultima atualizacao: 22/12/2011
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Busca Extrato Cartao Credito CECRED VISA
    
    Alteracao : 22/12/2011 - Adicionada chamada da procedure 'identifica-cartao'
                             (Lucas).                            
..............................................................................*/

CREATE WIDGET-POOL.    

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrcrcard AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_dtvctini AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dtvctfim AS DATE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR par_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0028 AS HANDLE                                         NO-UNDO.


RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.

IF  NOT VALID-HANDLE(h-b1wgen0028)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0028.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

/* PROCEDURE que identifica o nº completo do cartão 
pelos 4 primeiros e 4 ultimos digitos. */
RUN identifica-cartao IN h-b1wgen0028
                        (INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         INPUT-OUTPUT par_nrcrcard,
                         OUTPUT TABLE tt-erro).

IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAIL tt-erro  THEN
            xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".

        RETURN "NOK".
    END.

RUN extrato_cartao_bradesco IN h-b1wgen0028
                            (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_nrcrcard,
                             INPUT par_dtvctini,
                             INPUT par_dtvctfim,
                             OUTPUT TABLE tt-extrato-cartao,
                             OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0028.


IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF  AVAIL tt-erro  THEN
             xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".

        RETURN "NOK".
    END.


FIND FIRST tt-extrato-cartao NO-LOCK NO-ERROR.

IF NOT AVAIL tt-extrato-cartao THEN DO:
    xml_dsmsgerr = "<dsmsgerr>FATURA NÃO ENCONTRADA. EM CASO DE DÚVIDAS ENTRE EM CONTATO COM A EQUIPE DE ATENDIMENTO</dsmsgerr>".

    RETURN "NOK".
END.

FOR EACH tt-extrato-cartao NO-LOCK:

    CREATE xml_operacao.
    
    ASSIGN xml_operacao.dslinxml = "<EXTRATOVISA>" + 
           "<cdcooper>" + STRING(tt-extrato-cartao.cdcooper) + "</cdcooper>" +
           "<nrcrcard>" + STRING(tt-extrato-cartao.nrcrcard) + "</nrcrcard>" +
           "<nrdconta>" + STRING(tt-extrato-cartao.nrdconta) + "</nrdconta>" +
           "<nmtitcrd>" + tt-extrato-cartao.nmtitcrd + "</nmtitcrd>" +
           "<nmprimtl>" + tt-extrato-cartao.nmprimtl + "</nmprimtl>" +
           "<dtvencto>" + STRING(tt-extrato-cartao.dtvencto) + "</dtvencto>" +
           "<dtcompra>" + STRING(tt-extrato-cartao.dtcompra) + "</dtcompra>" +
           "<cdmoedtr>" + tt-extrato-cartao.cdmoedtr + "</cdmoedtr>" +
           "<dsatvcom>" + tt-extrato-cartao.dsatvcom + "</dsatvcom>" +
           "<dsestabe>" + tt-extrato-cartao.dsestabe + "</dsestabe>" +
           "<nmcidade>" + tt-extrato-cartao.nmcidade + "</nmcidade>" +
           "<cdufende>" + tt-extrato-cartao.cdufende + "</cdufende>" +
           "<idseqinc>" + STRING(tt-extrato-cartao.idseqinc) + "</idseqinc>" +
           "<indebcre>" + tt-extrato-cartao.indebcre + "</indebcre>" +
           "<nmarqimp>" + tt-extrato-cartao.nmarqimp + "</nmarqimp>" +
           "<tpatvcom>" + tt-extrato-cartao.tpatvcom + "</tpatvcom>" +
           "<vlcpaori>" + STRING(tt-extrato-cartao.vlcpaori) + "</vlcpaori>" +
           "<vlcparea>" + STRING(tt-extrato-cartao.vlcparea) + "</vlcparea>" +
           "<dtmvtolt>" + STRING(tt-extrato-cartao.dtmvtolt) + "</dtmvtolt>" +
           "<vllimite>" + STRING(tt-extrato-cartao.vllimite) + "</vllimite>" +
           "<cdcritic>" + STRING(tt-extrato-cartao.cdcritic) + "</cdcritic>" +
           "<cdoperad>" + tt-extrato-cartao.cdoperad + "</cdoperad>" +
           "<cdtransa>" + tt-extrato-cartao.cdtransa + "</cdtransa>" +
           "</EXTRATOVISA>". 
END.

RETURN "OK".

/*............................................................................*/
