/*...............................................................................
Alterações: 01/07/2016 - Criaçao da tela, Prj. 229 (Jean Michel).
................................................................................*/
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_dsendurl AS CHARACTER
       FIELD aux_dsretorn AS CHARACTER
       FIELD aux_idevento AS CHARACTER
       FIELD aux_lspermis AS CHARACTER
       FIELD aux_nrdrowid AS CHARACTER
       FIELD aux_cdevento AS CHARACTER
       FIELD aux_nrseqpdp AS CHARACTER
       FIELD aux_cdcopope AS CHARACTER
       FIELD aux_cdoperad AS CHARACTER.

CREATE WIDGET-POOL.

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0008c"].
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".

DEFINE VARIABLE i               AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-identificacao AS CHARACTER NO-UNDO.
DEFINE VARIABLE aux_nrseqpdp    AS CHARACTER NO-UNDO.

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0008c.htm

&Scoped-define FRAME-NAME Web-Frame

&Scoped-Define ENABLED-FIELDS
&Scoped-define ENABLED-TABLES ab_unmap
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_idevento ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad ~
ab_unmap.aux_cdevento
&Scoped-Define DISPLAYED-FIELDS
&Scoped-define DISPLAYED-TABLES ab_unmap
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_idevento ~
ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_cdcopope ab_unmap.aux_cdoperad ~
ab_unmap.aux_cdevento

DEFINE FRAME Web-Frame
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_nrseqpdp AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 71.4 BY 14.76.

{src/web2/html-map.i}

{src/web2/template/hmapmain.i}

PROCEDURE htmOffsets :
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqpdp":U,"ab_unmap.aux_nrseqpdp":U,ab_unmap.aux_nrseqpdp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.

PROCEDURE local-display-fields :
  RUN displayFields.
END PROCEDURE.

PROCEDURE outputHeader :
  output-content-type ("text/html":U).
END PROCEDURE.

PROCEDURE PermissaoDeAcesso:
  {includes/wpgd0009.i}
END PROCEDURE.

PROCEDURE incluiPublicoAlvo:
    
  CREATE crappde.
  ASSIGN crappde.idevento = INT(ab_unmap.aux_idevento)
         crappde.cdcooper = 0
         crappde.dtanoage = 0
         crappde.cdevento = INT(ab_unmap.aux_cdevento)
         crappde.nrseqpdp = INT(ab_unmap.aux_nrseqpdp)
         crappde.cdcopope = INT(ab_unmap.aux_cdcopope)
         crappde.cdoperad = ab_unmap.aux_cdoperad
         crappde.cdprogra = 'WPGD0008b'
         crappde.dtatuali = TODAY NO-ERROR.
         
  IF NOT ERROR-STATUS:ERROR THEN
    DO:
      RETURN "OK".
    END.
  ELSE
    RETURN "OK".  
    
END.

PROCEDURE process-web-request :

  ASSIGN aux_nrseqpdp = "Selecione um Produto,0,".
  
  FOR EACH crappdp NO-LOCK BY crappdp.dsprodut: 
    ASSIGN aux_nrseqpdp = aux_nrseqpdp + CAPS(crappdp.dsprodut) + "," + STRING(crappdp.nrseqpdp) + ",".
  END.

  ASSIGN ab_unmap.aux_nrseqpdp:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = SUBSTRING(aux_nrseqpdp, 1, LENGTH(aux_nrseqpdp) - 1)
         v-identificacao = get-cookie("cookie-usuario-em-uso").

  FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
  END.
 
  ASSIGN ab_unmap.aux_idevento = get-value("aux_idevento")
         ab_unmap.aux_dsendurl = AppURL                        
         ab_unmap.aux_lspermis = GET-VALUE("aux_lspermis")               
         ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")
         ab_unmap.aux_nrseqpdp = GET-VALUE("aux_nrseqpdp")
         ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
         ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope")
         ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad").

  RUN outputHeader.
   
  IF REQUEST_METHOD = "POST":U THEN 
    DO:
      RUN inputFields.
      RUN enableFields.
      RUN outputFields.
      RUN incluiPublicoAlvo.
      
      IF RETURN-VALUE <> "OK" THEN
        DO:
          RUN RodaJavaScript('alert("Erro ao inserir registro.");').
        END.
      ELSE
        DO:
          RUN RodaJavaScript('window.opener.Recarrega();').
          RUN RodaJavaScript('self.close();').
        END.        
    END.
  ELSE
    DO:
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).

      CASE ab_unmap.aux_lspermis:
        WHEN "1" THEN
          RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
        WHEN "2" THEN
          DO: 
            DELETE-COOKIE("cookie-usuario-em-uso",?,?).
            RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
          END.
        WHEN "3" THEN
          RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
        OTHERWISE
          DO:
            RUN displayFields.
            RUN enableFields.
            RUN outputFields.
          END.
        END CASE. 
  END.

  IF AnyMessage() THEN 
    DO:
       ShowDataMessages().
    END.
END PROCEDURE.

PROCEDURE RodaJavaScript:
  {includes/rodajava.i}
END PROCEDURE.