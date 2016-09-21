/*..............................................................................

   Programa: distribuidor.p
   Autor   : Murilo.
   Data    : 30/05/2007                        Ultima atualizacao: 11/02/2014

   Dados referentes ao programa:

   Objetivo  : Abre o XML, identifica a BO e a procedure a invocar e roda a BO.

   Alteracoes: 04/11/2008 - Inclusao widget-pool (martin).  
   
               28/10/2010 - Tratamento para geracao de log no ambiente de
                            desenvolvimento (David).
                            
               11/02/2014 - Listar no log do WebSpeed a BO e procedure
                            requisitadas (David).

..............................................................................*/

CREATE WIDGET-POOL. 

/** Variaveis de erro **/
DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF VAR hXSuper AS HANDLE                                              NO-UNDO.

DEF VAR pkgname AS CHAR                                                NO-UNDO.
DEF VAR arqdlog AS CHAR                                                NO-UNDO.

/** Variaveis de erro **/
{ src/web2/wrap-cgi.i }

/****************************************************** 
 ** Logar execucoes do distribuidor.p                **
 ** Log utilizado para verificar erros do AYLLOS WEB **
 ** Apenas para o pkgdesen                           **
 ******************************************************/

ASSIGN pkgname = OS-GETENV("PKGNAME").

IF  pkgname = "pkgdesen"  THEN
    DO:
        /** Eliminar arquivos de log antigos **/
        INPUT THROUGH VALUE("ls /tmp/distribuidor_*.log 2>/dev/null") NO-ECHO.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            IMPORT UNFORMATTED arqdlog.
            
            IF  DATE(INTE(SUBSTR(arqdlog,21,2)),
                     INTE(SUBSTR(arqdlog,19,2)),
                     INTE(SUBSTR(arqdlog,23,4))) < TODAY  THEN
                UNIX SILENT VALUE ("rm " + arqdlog + " 2>/dev/null"). 

        END. /** Fim do DO WHILE TRUE **/ 

        INPUT CLOSE.

        OUTPUT TO VALUE("/tmp/distribuidor_" + STRING(TODAY,"99999999") + 
                        ".log") APPEND.
    END.

RUN process-web-request.

IF  pkgname = "pkgdesen"  THEN
    OUTPUT CLOSE.

PROCEDURE triagemXML:

    DEF  INPUT PARAM ipXDoc AS HANDLE                               NO-UNDO.
    
    DEF VAR hXBO       AS HANDLE                                    NO-UNDO.
    DEF VAR hXDoc      AS HANDLE                                    NO-UNDO.
    DEF VAR hCabecalho AS HANDLE                                    NO-UNDO.
    DEF VAR hTag       AS HANDLE                                    NO-UNDO.

    DEF VAR cNomeBO    AS CHAR                                      NO-UNDO.
    DEF VAR cProcedure AS CHAR                                      NO-UNDO.

    DEF VAR i          AS INTE                                      NO-UNDO.

    /** Abertura do XML **/
    CREATE X-DOCUMENT hXDoc.
    CREATE X-NODEREF  hCabecalho.
    CREATE X-NODEREF  hTag.

    ASSIGN hXDoc = ipXDoc.

    /** Busca os dados da BO a executar **/
    hXDoc:GET-CHILD(hCabecalho,1).

    DO i = 1 TO hCabecalho:NUM-CHILDREN:
    
        hCabecalho:GET-CHILD(hTag,i).
        
        IF  hTag:NAME = "Cabecalho"  THEN 
            DO:
                hTag:GET-CHILD(hTag,2). /** Pega a tag BO      **/
                hTag:GET-CHILD(hTag,1). /** Pega o texto da BO **/
                
                ASSIGN cNomeBO = hTag:NODE-VALUE.
                
                hCabecalho:GET-CHILD(hTag,i).
                hTag:GET-CHILD(hTag,4). /** Pega a tag Proc **/
                hTag:GET-CHILD(hTag,1).
                
                ASSIGN cProcedure = hTag:NODE-VALUE.
                
                LEAVE. 
            END. 
    
    END. /** Fim do DO .. TO **/

    IF  pkgname = "pkgdesen"  THEN
        DISP STRING(TODAY,"99/99/9999") + 
             " - " + STRING(TIME,"HH:MM:SS") + " --> " +
             cNomeBO + " " + cProcedure
             FORMAT "x(80)" WITH NO-BOX NO-LABEL.
    ELSE
        MESSAGE "BO: " + cNomeBO + " - Procedure: " + cProcedure.
    
    /** Execucao BO **/
    IF  SEARCH("sistema/generico/procedures/x":U + cNomeBO) <> ?  THEN
        RUN VALUE("sistema/generico/procedures/x":U + cNomeBO) 
            PERSISTENT SET hXBO (INPUT hXDoc).

    /** Execucao da procedure da BO **/
    RUN executa_metodo IN hXBO (INPUT cNomeBO, INPUT cProcedure) NO-ERROR.
    
    /** Se a BO ou metodo nao existe, segue para o tratamento de erro **/
    IF  ERROR-STATUS:ERROR  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "BO ou nome do Metodo nao esta correto " +
                                      "no XML de entrada".
        END.
         
    IF  VALID-HANDLE(hXBO)  THEN
        DELETE PROCEDURE hXBO.
    
    IF  VALID-HANDLE(hXBO)  THEN
        DELETE OBJECT hXBO.

    IF  VALID-HANDLE(hXDoc)  THEN
        DELETE OBJECT hXDoc.

    IF  VALID-HANDLE(ipXDoc)  THEN
        DELETE OBJECT ipXDoc.
    
    IF  VALID-HANDLE(hCabecalho)  THEN
        DELETE OBJECT hCabecalho.
    
    IF  VALID-HANDLE(hTag)  THEN
        DELETE OBJECT hTag.

END PROCEDURE.

PROCEDURE outputheader:

    output-content-type ("text/xml").
    
END PROCEDURE.

PROCEDURE outputHeaderGet: 

    output-content-type ("text/html").
        
END PROCEDURE.

PROCEDURE process-web-request:

    /** Criticar se o usuario tentar acessar direto pelo browser **/
    IF  REQUEST_METHOD = "GET":U  THEN 
        DO:
            RUN outputHeaderGet. 
            
            {&out}
            "<HTML>"
            "<TITLE>ACESSO NEGADO!</TITLE>"  
            "<BODY>"  
            "<FONT SIZE=40><B>ACESSO NEGADO!</B></FONT>"
            "<BR>"
            "<FONT SIZE=15>REQUISICAO POR BROWSER NAO E VALIDA.</FONT>"
            "</BODY>"   
            "</HTML>".  
        END. 
    
    /** Execucao normal se for um XML Valido **/
    IF  REQUEST_METHOD = "POST":U  THEN
        DO:
            RUN outputHeader.
            
            IF  WEB-CONTEXT:IS-XML                    AND 
                VALID-HANDLE(WEB-CONTEXT:X-DOCUMENT)  THEN
                RUN triagemXML (WEB-CONTEXT:X-DOCUMENT). /** Executar XBO **/
            ELSE
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "O arquivo nao possui um " + 
                               "formato XML valido " +
                               STRING(WEB-CONTEXT:IS-XML) + 
                               STRING(VALID-HANDLE(WEB-CONTEXT:X-DOCUMENT)).
                END.

            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN 
                DO:
                    RUN sistema/generico/procedures/superXML.p
                        PERSISTENT SET hXSuper.
                    
                    RUN piXmlSaida IN hXSuper (INPUT TEMP-TABLE tt-erro:HANDLE,
                                               INPUT "Erro").
                
                    IF  VALID-HANDLE(hXSuper)  THEN
                        DELETE PROCEDURE hXSuper.
                END. 
        END. 

END PROCEDURE.  


/*............................................................................*/
