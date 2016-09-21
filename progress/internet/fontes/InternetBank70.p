
/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank70.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/Supero
    Data    : Setembro/2011                Ultima atualizacao: 22/12/2011
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Busca periodos para Extrato Cartao Credito CECRED VISA
    
    Alteracoes : 22/12/2011 - Adicionados parâmetros à chamada da procedure
                             'extrato_periodos' e realizadas modificações na
                             geração do XML (Lucas).
..............................................................................*/

CREATE WIDGET-POOL.    

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0028 AS HANDLE                                         NO-UNDO.


RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h-b1wgen0028.

IF  NOT VALID-HANDLE(h-b1wgen0028)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0028.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.


RUN extrato_periodos IN h-b1wgen0028
                            (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_dtmvtolt,
                            OUTPUT TABLE tt-periodos,
                            OUTPUT TABLE tt-cartoes-filtro,
                            OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0028.


IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF  AVAIL tt-erro  THEN
             xml_dsmsgerr = "<dsmsgerr>" + tt-erro.dscritic + "</dsmsgerr>".

        RETURN "NOK".
    END.


FIND FIRST tt-periodos NO-LOCK NO-ERROR.

IF NOT AVAIL tt-periodos THEN DO:
    xml_dsmsgerr = "<dsmsgerr>PERIODO INEXISTENTE.</dsmsgerr>".

    RETURN "NOK".
END.

 CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "<periodovisa>".

 FOR EACH tt-periodos NO-LOCK
      BY tt-periodos.cdseqper :

    CREATE xml_operacao.
           ASSIGN xml_operacao.dslinxml = "<periodo>" + STRING(tt-periodos.dsperiod) + "</periodo>".
/*           "</periodovisa>".  */
END.

CREATE xml_operacao.
                ASSIGN xml_operacao.dslinxml = "</periodovisa>".


FIND FIRST tt-cartoes-filtro NO-LOCK NO-ERROR.

IF NOT AVAIL tt-cartoes-filtro THEN DO:
    xml_dsmsgerr = "<dsmsgerr>NAO HA FATURAS PARA ESTA CONTA. EM CASO DE DUVIDAS ENTRE EM CONTATO COM A EQUIPE DE ATENDIMENTO.</dsmsgerr>".
    

    RETURN "NOK".
END.

FOR EACH tt-cartoes-filtro NO-LOCK:

    CREATE xml_operacao.
    
    ASSIGN xml_operacao.dslinxml =
           "<cartaofiltro><nrcrexib>" + STRING(tt-cartoes-filtro.nrcrexib) + "</nrcrexib>" +
           "<nrcarres>" + STRING(tt-cartoes-filtro.nrcarres) + "</nrcarres>" +
            "</cartaofiltro>".
END.
 
RETURN "OK".

/*............................................................................*/

