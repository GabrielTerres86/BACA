

/*..............................................................................

    Programa: sistema/internet/fontes/InternetBank67.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jorge
    Data    : Maio/2011                   Ultima atualizacao: 04/04/2012
  
    Dados referentes ao programa:
  
    Frequencia: Sempre que for chamado (On-Line)
    Objetivo  : Busca de endereco
    
    Alteracoes: 
    
    04/04/2012 - Adicionado idorigem na chamada da proc. busca-endereco em 
                 BO 38. (Jorge)
                            
..............................................................................*/

CREATE WIDGET-POOL.    

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_nrceplog AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dsendere AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmcidade AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cdufende AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrregist AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nriniseq AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR par_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0038 AS HANDLE                                         NO-UNDO.

RUN sistema/generico/procedures/b1wgen0038.p PERSISTENT SET h-b1wgen0038.

IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
DO:
    ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0038.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  
            
    RETURN "NOK".
END.

RUN busca-endereco IN h-b1wgen0038 (INPUT par_nrceplog,
                                    INPUT par_dsendere,
                                    INPUT par_nmcidade,
                                    INPUT par_cdufende,
                                    INPUT par_nrregist,
                                    INPUT par_nriniseq,
                                    INPUT 3, /* idorigem 3 - InternetBank */
                                   OUTPUT par_qtregist,
                                   OUTPUT TABLE tt-endereco).
DELETE PROCEDURE h-b1wgen0038.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<ENDERECOS_MAIN qtregist='" + 
                                STRING(par_qtregist) + "'>".
                               
FOR EACH tt-endereco NO-LOCK:
    
    CREATE xml_operacao.
    
    ASSIGN xml_operacao.dslinxml = "<ENDERECOS>" + 
           "<nrcepend>" + STRING(tt-endereco.nrcepend,"99999999") + "</nrcepend>" + 
           "<dsendere>" + tt-endereco.dsendere + "</dsendere>" + 
           "<dscmpend>" + tt-endereco.dscmpend + "</dscmpend>" + 
           "<dsendcmp>" + tt-endereco.dsendcmp + "</dsendcmp>" + 
           "<cdufende>" + tt-endereco.cdufende + "</cdufende>" + 
           "<nmbairro>" + tt-endereco.nmbairro + "</nmbairro>" + 
           "<nmcidade>" + tt-endereco.nmcidade + "</nmcidade>" +
           "</ENDERECOS>". 
END.
                                    
CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</ENDERECOS_MAIN>".

RETURN "OK".

/*............................................................................*/



