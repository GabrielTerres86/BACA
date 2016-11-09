/* .............................................................................
   Programa: wcrm0003_xml.p
   Sistema : CRM 
   Sigla   : CRM
   Autor   : Rosangela
   Data    : Agosto/2006                   Ultima Atualizacao: 28/10/2016
   Dados referentes ao programa:
   Frequencia: esporadica(internet)
   Objetivo  : gera arquivo com os vinculos (para inscrição de familiar)
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
 
			   28/10/2016 - Inclusão da chamada da procedure pc_informa_acesso_progrid
							para gravar log de acesso. (Jean Michel)
														 
..............................................................................*/

{ sistema/generico/includes/var_log_progrid.i }
 
create widget-pool.
 
DEFINE VARIABLE par_cdcooper AS INTEGER                               NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL         INIT FALSE            NO-UNDO.
DEFINE VARIABLE aux_cdgraupr AS CHARACTER.
DEFINE VARIABLE aux_contador AS INT                                   NO-UNDO.
/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.
/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):
    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot:APPEND-CHILD(xField).
    xDoc:CREATE-NODE(xText,"","TEXT").
    xField:APPEND-CHILD(xText).
    xText:NODE-VALUE = STRING(textoCampo).
    RETURN TRUE.
END FUNCTION.
/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}


/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).
ASSIGN par_cdcooper = INT(GET-VALUE("aux_cdcooper")).

RUN insere_log_progrid("WPGD0003_xml.p",STRING(par_cdcooper)).

CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.
/* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
xDoc:APPEND-CHILD( xRoot ).
/* busca a lista de grau de parentesco */
FIND FIRST craptab WHERE craptab.cdcooper = INT(par_cdcooper) AND
                         craptab.nmsistem = "CRED"            AND
                         craptab.tptabela = "GENERI"          AND
                         craptab.cdempres = 0                 AND
                         craptab.cdacesso = "VINCULOTTL"      AND
                         craptab.tpregist = 0                 NO-LOCK NO-ERROR.
    DO aux_contador = 1 TO NUM-ENTRIES(craptab.dstextab) BY 2:
       
        /* Vinculo "nenhum" */
        IF   INT(ENTRY(aux_contador + 1,craptab.dstextab)) = 9   THEN
             NEXT.
        criaCampo("DSGRAUPR",ENTRY(aux_contador,craptab.dstextab)).
        xField:SET-ATTRIBUTE("CDGRAUPR",STRING(ENTRY(aux_contador + 1,craptab.dstextab))).
    END.   
    
    aux_flgexist = TRUE.
/* Se não encontrou registros, gera TAG de erro */
IF   NOT aux_flgexist   THEN
     DO:
         aux_dscritic = "Não existe cadastro de grau de parentesco!".
       
     END.
xDoc:SAVE("STREAM","WEBSTREAM").
DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/* .......................................................................... */
