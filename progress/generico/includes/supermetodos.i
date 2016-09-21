/*..............................................................................

   Programa: supermetodos.i
   Autor   : Murilo
   Data    : Junho/2007                        Ultima atualizacao: 24/03/2014

   Dados referentes ao programa:

   Objetivo  : Include com supermetodos utilizados para leitura e criacao de
               conteudo XML nas XBO's.

   Alteracoes: Controle de registros itens/filhos, Procedure 'piAbreXML'
               (Jose Luis Marchezoni, DB1 - 08/07/10)
               
               21/10/2010 - Tratamento para controle de acesso as operacoes do
                            sistema Ayllos (David).
                            
               03/12/2010 - Eliminar instancia da BO b1wgen0000.p (David).

               24/03/2014 - Implementar log de sessao para Oracle (David).

..............................................................................*/

{ sistema/generico/includes/var_oracle.i }

DEF TEMP-TABLE tt-param NO-UNDO
    FIELD nomeCampo  AS CHAR
    FIELD valorCampo AS CHAR.

DEF TEMP-TABLE tt-param-i NO-UNDO
    FIELD SqControle AS INTE
    FIELD nomeTabela AS CHAR
    FIELD nomeCampo  AS CHAR
    FIELD valorCampo AS CHAR.

DEF TEMP-TABLE tt-permis-acesso NO-UNDO
    FIELD nmdatela AS CHAR
    FIELD nmrotina AS CHAR
    FIELD cddopcao AS CHAR
    FIELD idsistem AS INTE
    FIELD cdagecxa AS INTE
    FIELD nrdcaixa AS INTE
    FIELD cdopecxa AS CHAR
    FIELD idorigem AS INTE.

DEF INPUT PARAM hXDoc AS HANDLE                                        NO-UNDO.

DEF VAR hBO          AS HANDLE                                         NO-UNDO.
DEF VAR hBOGenerica  AS HANDLE                                         NO-UNDO.
DEF VAR hSuper       AS HANDLE                                         NO-UNDO.
                   
DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtopr AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtoan AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtocd AS DATE                                           NO-UNDO.

DEF VAR aux_inproces AS INTE                                           NO-UNDO.
                     

/*................................ PROCEDURES ................................*/


PROCEDURE executa_metodo:

    DEF INPUT  PARAM cNomeBO    AS CHAR                             NO-UNDO.
    DEF INPUT  PARAM cProcedure AS CHAR                             NO-UNDO.
    
    RUN sistema/generico/procedures/superXML.p PERSISTENT SET hSuper.

    IF  NOT VALID-HANDLE(hSuper)  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Handle invalido para BO superXML.".

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        
            RETURN.
        END.
        
    THIS-PROCEDURE:ADD-SUPER-PROCEDURE(hSuper).
    
    RUN piAbreXML (INPUT hXDoc, 
                  OUTPUT TABLE tt-param, 
                  OUTPUT TABLE tt-param-i,
                  OUTPUT TABLE tt-permis-acesso ).

    RUN VALUE ("sistema/generico/procedures/" + cNomeBO) 
        PERSISTENT SET hBO.
       
    IF  NOT VALID-HANDLE(hBO)  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Handle invalido para BO " + cNomeBO.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").

            DELETE PROCEDURE hSuper.

            RETURN.
        END.

    RUN valores_entrada. /** Para pegar valores enviados por XML **/
    
    FIND FIRST tt-permis-acesso NO-LOCK NO-ERROR.

    { sistema/generico/includes/PLSQL_grava_operacao_AyllosWeb.i 
                                            &dboraayl={&scd_dboraayl} }
                                          
    FIND crapdat WHERE crapdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Sistema sem data de movimento.".

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:                                    
            ASSIGN aux_dtmvtolt = crapdat.dtmvtolt
                   aux_dtmvtopr = crapdat.dtmvtopr
                   aux_dtmvtoan = crapdat.dtmvtoan
                   aux_dtmvtocd = crapdat.dtmvtocd
                   aux_inproces = crapdat.inproces.

            FIND FIRST tt-permis-acesso NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-permis-acesso  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0000.p PERSISTENT
                        SET hBOGenerica.

                    IF  NOT VALID-HANDLE(hBOGenerica)  THEN
                        DO:
                            CREATE tt-erro.
                            ASSIGN tt-erro.dscritic = "Handle invalido para " +
                                                      "BO b1wgen0000.".
                
                            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                                            INPUT "Erro").
                        END.
                    ELSE
                        DO:
                            RUN verifica_permissao_operacao IN hBOGenerica
                                               (INPUT aux_cdcooper,
                                                INPUT tt-permis-acesso.cdagecxa,
                                                INPUT tt-permis-acesso.nrdcaixa,
                                                INPUT tt-permis-acesso.cdopecxa,
                                                INPUT tt-permis-acesso.idorigem,
                                                INPUT tt-permis-acesso.idsistem,
                                                INPUT tt-permis-acesso.nmdatela,
                                                INPUT tt-permis-acesso.nmrotina,
                                                INPUT tt-permis-acesso.cddopcao,
                                                INPUT aux_inproces,
                                               OUTPUT TABLE tt-erro).

                            DELETE PROCEDURE hBOGenerica.

                            IF  RETURN-VALUE = "NOK"  THEN
                                RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                                                INPUT "Erro").
                            ELSE
                                RUN VALUE(cProcedure). 
                        END.
                END.    
            ELSE
                RUN VALUE(cProcedure). 
        END.    

    DELETE PROCEDURE hBO.
    DELETE PROCEDURE hSuper.
        
END PROCEDURE.

PROCEDURE piAbreXML:

    DEFINE INPUT  PARAMETER hXDoc        AS HANDLE    NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-param.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-param-i.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-permis-acesso.

    RUN SUPER ( INPUT hXDoc,
               OUTPUT TABLE tt-param ,
               OUTPUT TABLE tt-param-i,
               OUTPUT TABLE tt-permis-acesso ).

END PROCEDURE.

PROCEDURE piXmlSaida:
   
    DEFINE INPUT  PARAMETER hTempTable AS HANDLE     NO-UNDO.
    DEFINE INPUT  PARAMETER cTagName   AS CHARACTER  NO-UNDO.

    RUN SUPER (INPUT hTempTable,
               INPUT cTagName).

END PROCEDURE.

PROCEDURE piXmlNew:
    
    RUN SUPER.

END PROCEDURE.

PROCEDURE piXmlExport:
    
    DEFINE INPUT  PARAMETER hTempTable AS HANDLE     NO-UNDO.
    DEFINE INPUT  PARAMETER cTagName   AS CHARACTER  NO-UNDO.
    
    RUN SUPER (INPUT hTempTable,
               INPUT cTagName  ).

END PROCEDURE.

PROCEDURE piXmlAtributo:
    
    DEFINE INPUT  PARAMETER ipNomeVar  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER ipVariable AS CHARACTER  NO-UNDO.

    RUN SUPER (INPUT ipNomeVar, INPUT ipVariable).

END PROCEDURE.

PROCEDURE piXmlSave:
    
    RUN SUPER.

END PROCEDURE.


/*............................................................................*/
