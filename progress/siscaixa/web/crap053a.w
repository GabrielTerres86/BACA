/* .............................................................................

   Programa: siscaixa/web/crap053a.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 13/12/2013.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Pagto de Cheque 

   Alteracoes: 26/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               13/03/2006 - Acrescentada leitura do campo cdcooper as tabelas
                            (Diego).

               25/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).

               18/12/2009 - Adicionado numero do lote na chamada da rotina
                            crap051f.w (Fernando).
                            
               04/05/2010 - Adicionado parametro flgrebcc na chamada da rotina
                            crap051f (Fernando).                  
                            
               24/12/2010 - Tratamento para cheques de contas migradas 
                            (Guilherme).
                            
               20/12/2011 - Ajuste de paramentros (Gabriel)
               
               19/01/2012 - Alterado nrsencar para dssencar (Guilherme).
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agenc AS CHARACTER FORMAT "X(256)":U 
       FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_c1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_c2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_c3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod3 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_comp AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE h-b1crap53 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap54 AS HANDLE     NO-UNDO.
 
DEF VAR de-valor AS CHAR NO-UNDO.
DEF VAR p-programa AS CHAR INITIAL "CRAP053".
DEF VAR p-flgdebcc AS LOGI INITIAL FALSE.
DEF VAR p-cmc-7-dig AS CHAR NO-UNDO.


DEF var p-cdcmpchq       AS INT     FORMAT "zz9".               /* Comp */            
DEF VAR p-cdbanchq       AS INT     FORMAT "zz9".               /* Banco */
DEF var p-cdagechq       AS INT     FORMAT "zzz9".              /* Agencia */
DEF var p-nrddigc1       AS INT     FORMAT "9".                 /* C1 */
DEF var p-nrctabdb       AS DEC     FORMAT "zzz,zzz,zzz,9".     /* Conta */
DEF var p-nrddigc2       AS INT     FORMAT "9".                 /* C2 */
DEF var p-nrcheque       AS INT     FORMAT "zzz,zz9".           /* Cheque */
DEF var p-nrddigc3       AS INT     FORMAT "9".                  /* C3 */



  DEF TEMP-TABLE w-compel
        FIELD dsdocmc7 AS CHAR    FORMAT "X(34)"
        FIELD cdcmpchq AS INT     FORMAT "zz9"
        FIELD cdbanchq AS INT     FORMAT "zz9"
        FIELD cdagechq AS INT     FORMAT "zzz9"
        FIELD nrddigc1 AS INT     FORMAT "9"   
        FIELD nrctaaux AS INT     
        FIELD nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"
        FIELD nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"
        FIELD nrddigc2 AS INT     FORMAT "9"            
        FIELD nrcheque AS INT     FORMAT "zzz,zz9"      
        FIELD nrddigc3 AS INT     FORMAT "9"            
        FIELD vlcompel AS DECIMAL FORMAT "zzz,zzz,zz9.99"
        FIELD dtlibcom AS DATE    FORMAT "99/99/9999"
        FIELD lsdigctr AS CHAR
        FIELD tpdmovto AS INTE
        FIELD nrseqdig AS INTE
        FIELD cdtipchq AS INTE
        FIELD nrdocmto LIKE craplcm.nrdocmto
        FIELD nrposchq AS INTE
        INDEX compel1 AS UNIQUE PRIMARY
              dsdocmc7
        INDEX compel2 AS UNIQUE
              nrseqdig DESCENDING.

DEF VAR p-aux-indevchq   AS INTE NO-UNDO.
DEF VAR p-nrdocmto       AS INTE NO-UNDO.
DEF VAR p-nrdolote       AS INTE NO-UNDO.
DEF VAR p-conta-atualiza AS INTE no-undo.
DEF VAR p-histor         AS INTE NO-UNDO.

DEF VAR p-literal        AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia  AS INTE  NO-UNDO.
DEF var p-registro       AS RECID NO-UNDO.

DEF VAR p-mensagem-saldo AS CHAR FORMAT "x(50)" NO-UNDO.

DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR l-habilita         AS LOG INIT NO NO-UNDO.
DEF VAR p-valor-disponivel AS DEC NO-UNDO.
DEF VAR p-flg-cta-migrada AS LOG NO-UNDO.
DEF VAR p-coop-migrada AS CHAR NO-UNDO.
DEF VAR p-nro-conta-nova AS INT NO-UNDO.
DEF VAR p-flg-coop-host AS LOG NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap053a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_cod ab_unmap.v_senha ab_unmap.vh_foco ab_unmap.v_agenc ab_unmap.v_banco ab_unmap.v_c1 ab_unmap.v_c2 ab_unmap.v_c3 ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_cod1 ab_unmap.v_cod2 ab_unmap.v_cod3 ab_unmap.v_comp ab_unmap.v_conta ab_unmap.v_conta1 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_mensagem1 ab_unmap.v_mensagem2 ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valor 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_cod ab_unmap.v_senha ab_unmap.vh_foco ab_unmap.v_agenc ab_unmap.v_banco ab_unmap.v_c1 ab_unmap.v_c2 ab_unmap.v_c3 ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_cod1 ab_unmap.v_cod2 ab_unmap.v_cod3 ab_unmap.v_comp ab_unmap.v_conta ab_unmap.v_conta1 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_mensagem1 ab_unmap.v_mensagem2 ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valor 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agenc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_banco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_c1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_c2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_c3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cmc7 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cod1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cod2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cod3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_comp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_agenc AS CHARACTER FORMAT "X(256)":U 
          FIELD v_banco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_c1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_c2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_c3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod3 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_comp AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_agenc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_banco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_c1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_c2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_c3 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cmc7 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod3 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_comp IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mensagem1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mensagem2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 


/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agenc":U,"ab_unmap.v_agenc":U,ab_unmap.v_agenc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_banco":U,"ab_unmap.v_banco":U,ab_unmap.v_banco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_c1":U,"ab_unmap.v_c1":U,ab_unmap.v_c1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_c2":U,"ab_unmap.v_c2":U,ab_unmap.v_c2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_c3":U,"ab_unmap.v_c3":U,ab_unmap.v_c3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cmc7":U,"ab_unmap.v_cmc7":U,ab_unmap.v_cmc7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod1":U,"ab_unmap.v_cod1":U,ab_unmap.v_cod1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod2":U,"ab_unmap.v_cod2":U,ab_unmap.v_cod2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod3":U,"ab_unmap.v_cod3":U,ab_unmap.v_cod3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_comp":U,"ab_unmap.v_comp":U,ab_unmap.v_comp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta1":U,"ab_unmap.v_conta1":U,ab_unmap.v_conta1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem1":U,"ab_unmap.v_mensagem1":U,ab_unmap.v_mensagem1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem2":U,"ab_unmap.v_mensagem2":U,ab_unmap.v_mensagem2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 
  RUN outputHeader.
  {include/i-global.i}
   
  ASSIGN de-valor    = get-value("v_valor").
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.                                                  */
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */
    
    {include/assignfields.i}


    IF  get-value("cancela") <> "" THEN DO:
         ASSIGN v_cod1      = ""
                v_cod2      = ""
                v_cod3      = ""
                v_comp      = ""
                v_banco     = ""
                v_agenc     = ""
                v_c1        = ""
                v_conta     = ""
                v_c2        = ""
                v_conta1    = ""
                v_c3        = ""
                v_mensagem1 = ""
                v_mensagem2 = ""
                v_msg       = ""
                vh_foco     = "9".
     END.
     ELSE DO:
         IF  get-value("auto") <> "" THEN DO:
             {&OUT}
             '<script>window.location = "crap053.w?v_valor=" + "'get-value("v_valor")'" + "&v_cmc7=" + "'get-value("v_cmc7")'" + "&v_codigo=" + "'get-value("v_codigo")'"
              </script>'.
         END.
         ELSE DO:
    
             ASSIGN p-cmc-7-dig = "<" + v_cod1   + 
                                  "<" + v_cod2   +
                                  ">" + v_cod3   + ":".   

             RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
             RUN critica-codigo-cheque-dig IN h-b1crap53(INPUT v_coop,
                                                         INPUT INT(v_pac),
                                                         INPUT INT(v_caixa),
                                                         INPUT p-cmc-7-dig).
             DELETE PROCEDURE h-b1crap53.

             IF  RETURN-VALUE = "NOK" THEN DO:
                 {include/i-erro.i}
             END. 
             ELSE DO:
                
                RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
                RUN valida-codigo-cheque IN h-b1crap53(INPUT v_coop,
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT " ",
                                                       INPUT p-cmc-7-dig,
                                                       OUTPUT v_comp, 
                                                       OUTPUT v_banco,       
                                                       OUTPUT v_agenc,       
                                                       OUTPUT v_c1,       
                                                       OUTPUT v_conta,       
                                                       OUTPUT v_c2,       
                                                       OUTPUT v_conta1,       
                                                       OUTPUT v_c3). 
                DELETE PROCEDURE h-b1crap53.

                IF  RETURN-VALUE = "NOK" THEN DO:
                    {include/i-erro.i}
                END. 
                ELSE DO:
                    RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
                    RUN valida-pagto-cheque IN h-b1crap53(
                                                   INPUT v_coop,
                                                   INPUT int(v_pac),
                                                   INPUT int(v_caixa),
                                                   INPUT " ",
                                                   INPUT p-cmc-7-dig,
                                                   INPUT INT(v_comp), 
                                                   INPUT INT(v_banco), 
                                                   INPUT INT(v_agenc),  
                                                   INPUT INT(v_c1),   
                                                   INPUT DEC(v_conta), 
                                                   INPUT INT(v_c2), 
                                                   INPUT INT(v_conta1),
                                                   INPUT INT(v_c3),
                                                   INPUT DEC(v_valor),
                                                   OUTPUT v_mensagem1,
                                                   OUTPUT v_mensagem2,
                                                   OUTPUT p-aux-indevchq,
                                                   OUTPUT p-nrdocmto,
                                                   OUTPUT p-conta-atualiza,
                                                   OUTPUT p-mensagem-saldo,
                                                   OUTPUT p-valor-disponivel,
                                                   OUTPUT p-flg-cta-migrada,
                                                   OUTPUT p-coop-migrada,
                                                   OUTPUT p-flg-coop-host,
                                                   OUTPUT p-nro-conta-nova).
                    DELETE PROCEDURE h-b1crap53.
                    
                    IF  p-mensagem-saldo <> " "  THEN
                        ASSIGN v_mensagem1 =  v_mensagem1 + " " + p-mensagem-saldo.
                    
                    ASSIGN v_valor = STRING(DEC(v_valor),"zzz,zzz,zzz,zz9.99").
                    
                    IF  p-mensagem-saldo <> " "  THEN
                        ASSIGN l-habilita = YES.
                    
                    IF  RETURN-value = "NOK"  THEN DO:
                        {include/i-erro.i}
                    END. 
                    ELSE DO:
                         
                        ASSIGN vh_foco = "22". 

                        ASSIGN l-houve-erro = NO.
                            
                        IF  get-value("ok") <> "" THEN DO:
                                
                            RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.
                                
                            RUN valida-permissao-saldo-conta 
                             IN h-b1crap54(INPUT v_coop,
                                           INPUT INT(v_pac),    
                                           INPUT INT(v_caixa),
                                           INPUT DEC(v_valor),
                                           INPUT v_operador,
                                           INPUT DEC(v_conta),
                                           INPUT 0,  
                                           INPUT "", 
                                           INPUT "",  
                                           INPUT v_cod,
                                           INPUT v_senha,
                                           INPUT  p-valor-disponivel,
                                           INPUT  p-mensagem-saldo,
                                           INPUT 1,
                                           INPUT "",
                                           INPUT "").
                                
                             DELETE PROCEDURE h-b1crap54.
                             IF  RETURN-VALUE = "NOK" THEN DO:
                                 {include/i-erro.i}
                             END.
                             ELSE DO:

                                 DO TRANSACTION ON ERROR UNDO:
                                           
                                    RUN dbo/b1crap53.p 
                                        PERSISTENT SET h-b1crap53.
                                    IF  NOT p-flg-cta-migrada  THEN
                                    RUN atualiza-pagto-cheque 
                                     IN h-b1crap53(INPUT v_coop,
                                                   INPUT INT(v_pac),
                                                   INPUT INT(v_caixa),
                                                   INPUT v_operador,
                                                   INPUT v_cod,
                                                   INPUT DEC(v_conta),
                                                   INPUT INT(v_conta1),
                                                   INPUT INT(v_c3),
                                                   INPUT DEC(v_valor),
                                                   INPUT p-aux-indevchq,
                                                   INPUT p-nrdocmto,
                                                   INPUT p-conta-atualiza,
                                                   INPUT INT(v_banco),
                                                   INPUT INT(v_agenc),
                                                   OUTPUT p-histor,  
                                                   OUTPUT p-literal,
                                                   OUTPUT p-ult-sequencia).
                                    ELSE
                                    DO:
                                        IF  NOT p-flg-coop-host  THEN
                                            RUN atualiza-pagto-cheque-migrado
                                             IN h-b1crap53(INPUT v_coop,
                                                           INPUT p-coop-migrada,
                                                           INPUT INT(v_pac),
                                                           INPUT INT(v_caixa),
                                                           INPUT v_operador,
                                                           INPUT v_cod,
                                                           INPUT DEC(v_conta),
                                                           INPUT INT(v_conta1),
                                                           INPUT INT(v_c3),
                                                           INPUT DEC(v_valor),
                                                           INPUT p-aux-indevchq,
                                                           INPUT p-nrdocmto,
                                                           INPUT p-conta-atualiza,
                                                           INPUT INT(v_banco),
                                                           INPUT INT(v_agenc),
                                                           INPUT p-nro-conta-nova,
                                                           OUTPUT p-histor,  
                                                           OUTPUT p-literal,
                                                           OUTPUT p-ult-sequencia).
                                        ELSE
                                            RUN atualiza-pagto-cheque-migrado-host
                                             IN h-b1crap53(INPUT v_coop,
                                                           INPUT p-coop-migrada,
                                                           INPUT INT(v_pac),
                                                           INPUT INT(v_caixa),
                                                           INPUT v_operador,
                                                           INPUT v_cod,
                                                           INPUT DEC(v_conta),
                                                           INPUT INT(v_conta1),
                                                           INPUT INT(v_c3),
                                                           INPUT DEC(v_valor),
                                                           INPUT p-aux-indevchq,
                                                           INPUT p-nrdocmto,
                                                           INPUT p-conta-atualiza,
                                                           INPUT INT(v_banco),
                                                           INPUT INT(v_agenc),
                                                           INPUT p-nro-conta-nova,
                                                           OUTPUT p-histor,  
                                                           OUTPUT p-literal,
                                                           OUTPUT p-ult-sequencia).

                                    END.
                                    DELETE PROCEDURE h-b1crap53.
            
                                    ASSIGN v_valor = 
                                    STRING(DEC(v_valor),"zzz,zzz,zzz,zz9.99").
                                
                                    IF  RETURN-VALUE = "NOK" THEN DO:
                                        ASSIGN l-houve-erro = YES.
                                        FOR EACH w-craperr:
                                            DELETE w-craperr.
                                        END.
                                        FOR EACH craperr NO-LOCK WHERE
                                           craperr.cdcooper =  
                                             crapcop.cdcooper  AND
                                           craperr.cdagenci =  
                                             INT(v_pac)        AND
                                           craperr.nrdcaixa =  
                                             INT(v_caixa):

                                            CREATE w-craperr.
                                            ASSIGN w-craperr.cdcooper =
                                                             craperr.cdcooper
                                                   w-craperr.cdagenci = 
                                                             craperr.cdagenc
                                                   w-craperr.nrdcaixa = 
                                                             craperr.nrdcaixa
                                                   w-craperr.nrsequen = 
                                                             craperr.nrsequen
                                                   w-craperr.cdcritic = 
                                                             craperr.cdcritic
                                                   w-craperr.dscritic = 
                                                             craperr.dscritic
                                                   w-craperr.erro     = 
                                                             craperr.erro.
                                        END.
                                        UNDO.
                                    END.     
                                 END.
                         
                                 IF  l-houve-erro = YES  THEN DO:
                                     FOR EACH w-craperr NO-LOCK:
                                         CREATE craperr.
                                         ASSIGN craperr.cdcooper = 
                                                        w-craperr.cdcooper
                                                craperr.cdagenci = 
                                                        w-craperr.cdagenc
                                                craperr.nrdcaixa = 
                                                        w-craperr.nrdcaixa
                                                craperr.nrsequen = 
                                                        w-craperr.nrsequen
                                                craperr.cdcritic = 
                                                        w-craperr.cdcritic
                                                craperr.dscritic = 
                                                        w-craperr.dscritic
                                                craperr.erro     = 
                                                        w-craperr.erro.
                                         VALIDATE craperr.
                                     END.
                                     {include/i-erro.i}
                                 END.
                                 IF  l-houve-erro = NO THEN do:  
                                    {&OUT}
                                         '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
                                         "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "NO"  + "&v_psetcook=" + "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                     </script>'.
                                 
                                     /* Se o cheque for de uma conta migrada e estiver pagando na 
                                        cooperativa geradora do cheque, nao gerar crapcme 
                                        Guilherme/Magui/Mirtes - Migracao PAC Jan/2010 */
                                     IF  p-flg-cta-migrada  AND
                                         p-flg-coop-host    THEN
                                     DO:
                                     END.
                                     ELSE
                                     DO:
                                     /*** Incluido por Magui 19/08/2003 ***/
                                     IF   DEC(v_valor) <> 0   THEN
                                          DO:
                              
                                              FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                                                 craptab.nmsistem = "CRED"            AND
                                                                 craptab.tptabela = "GENERI"          AND
                                                                 craptab.cdempres = 0                 AND
                                                                 craptab.cdacesso = "VLCTRMVESP"      AND
                                                                 craptab.tpregist = 0   NO-LOCK NO-ERROR.
                                              IF   AVAILABLE craptab   THEN             
                                                   DO:
                                                       IF  DEC(v_valor) >= DEC(craptab.dstextab)   THEN
                                                           DO:
                                                               ASSIGN p-nrdolote = 11000 + INT(v_caixa).
                                                               {&OUT}
                                                               '<script> window.location=
                                                               "crap051f.w?v_pconta=' + v_conta '" + 
                                                               "&v_pvalor=" + "' get-value("v_valor") '" +
                                                               "&v_pnrdocmto=" + "' p-nrdocmto '" +
                                                               "&v_pult_sequencia=" + "' p-ult-sequencia '" +
                                                               "&v_pconta_base=" + "' STRING(p-conta-atualiza) '" +
                                                               "&v_nrdolote=" + "' STRING(p-nrdolote) '" +
                                                               "&v_pprograma=" + "' p-programa '" +
                                                               "&v_flgdebcc=" + "' p-flgdebcc '" </script>'.
                                                           END.
                                                   END.
                                          END.         
                                     /********************************/
                                     END.
                                 {&OUT}
                                   '<script>window.location = "crap053.html"
                                   </script>'.
                                 END.
                          
                             END. 
                          
                         END. /* get-value("OK") */
                    END.
                END.
             END.  
         END.
     END.
    /* STEP 4 -
     * Decide what HTML to return to the user. Choose STEP 4.1 to simulate
     * another Web request -OR- STEP 4.2 to return the original form (the
     * default action).
     *
     * STEP 4.1 -
     * To simulate another Web request, change the REQUEST_METHOD to GET
     * and RUN the Web object here.  For example,
     *
     *  ASSIGN REQUEST_METHOD = "GET":U.
     *  RUN run-web-object IN web-utilities-hdl ("myobject.w":U).
     */
     
    /* STEP 4.2 -
     * To return the form again, set data values, display them, and output 
     * them to the WEB stream.  
     *
     * STEP 4.2a -
     * Set any values that need to be set, then display them. */
    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    IF l-habilita = YES THEN
        ENABLE v_cod
               v_senha WITH FRAME {&FRAME-NAME}.
    ELSE 
        DISABLE v_cod
                v_senha WITH FRAME {&FRAME-NAME}.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.
    
  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
     /*
      RUN findRecords.
     */
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */

    ASSIGN v_valor = string(dec(de-valor),"zzz,zzz,zzz,zz9.99").
    ASSIGN vh_foco = "9".
    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    DISABLE v_cod
            v_senha WITH FRAME {&FRAME-NAME}.


    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
  END. 
  
  /* Show error messages. */
  IF AnyMessage() THEN 
  DO:
     /* ShowDataMessage may return a Progress column name. This means you
      * can use the function as a parameter to HTMLSetFocus instead of 
      * calling it directly.  The first parameter is the form name.   
      *
      * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */
     ShowDataMessages().
  END.
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

