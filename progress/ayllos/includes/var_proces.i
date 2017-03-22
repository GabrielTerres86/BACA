/* .............................................................................

   Programa: includes/var_proces.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Junho/2004.                     Ultima atualizacao:  01/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela PROCES.

   Alteracao : 29/10/2004 - Criada tabela temporaria w_criticas para permitir 
                            solicitacao automatica(Mirtes) 

               06/02/2006 - Incluida opcao NO-UNDO na TEMP-TABLE w_criticas
                            SQLWorks - Fernando   
                            
               14/11/2007 - Alterado SIZE do edi_criticas para 132, assim
                            ele "corre" 132 colunas(Guilherme).

               10/01/2008 - Gerar sol 35 para Darf IOF (Magui).
               
               07/05/2008 - Declarada variavel "aux_nmarquiv" para ser utilizado
                            pelo programa fontes/gera_criticas_proces.p.(Elton)
               
               28/04/2009 - Adicionados os campos cdsitexc e cdagenci na 
                            TEMP-TABLE w_criticas (Fernando).
                            
               06/12/2011 - Novas variaveis para verificar taxas CDI e TR (Ze).
               
               01/02/2017 - Ajustes para consultar dados da tela PROCES de todas as cooperativas
                            (Lucas Ranghetti #491624)
............................................................................ */


DEF STREAM str_1.

DEF {1} SHARED VAR aux_nmarqimp AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmarquiv AS CHAR                              NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.

DEF {1} SHARED VAR user-prog    AS CHAR    FORMAT "x(60)"            NO-UNDO.
DEF {1} SHARED VAR choice       AS INT     INIT 1                    NO-UNDO.
DEF {1} SHARED VAR cmdcount     AS INT     INIT 4                    NO-UNDO.
DEF {1} SHARED VAR cmd          AS CHAR    FORMAT "x(65)" EXTENT 4   NO-UNDO.
DEF {1} SHARED VAR cmdlist      AS CHAR    INIT "12"                 NO-UNDO.
DEF {1} SHARED VAR lastchoice   AS INT     INIT 1                    NO-UNDO.
DEF {1} SHARED VAR qgo          AS LOGICAL INIT FALSE                NO-UNDO.
DEF {1} SHARED VAR defstat      AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"             NO-UNDO.
DEF {1} SHARED VAR aux_nrmaxmfx AS INT     INIT 2                    NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_vlmoefix AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
                                       EXTENT 15                     NO-UNDO.
DEF {1} SHARED VAR aux_nrdctabb AS INTEGER FORMAT "99999999"         NO-UNDO.
DEF {1} SHARED VAR aux_qtdconta AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_lscontas AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_nmarq039 AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR aux_dtdebito AS DATE                              NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtocm AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF {1} SHARED VAR aux_dtiniper AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF {1} SHARED VAR aux_dtdoltab AS DATE    FORMAT "99/99/9999"       NO-UNDO.

DEF {1} SHARED VAR aux_nrdiautl AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_vldaurvs AS DECIMAL                           NO-UNDO.
DEF {1} SHARED VAR aux_vlufircm AS DECIMAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgencer AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_cont     AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_tpmoefix AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_moeda    AS CHAR FORMAT "x(12)"
        EXTENT 5 INIT ["6-CDI Anual","16-CDI Mensal","18-CDI Diario",
                       "8-Poupanca","11-TR"]                         NO-UNDO.

DEF {1} SHARED VAR aux_flgaprda AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgaprdc AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgaprpp AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgprior AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgsol09 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol11 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol16 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol17 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol20 AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgsol26 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol27 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol28 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol29 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol30 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol33 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol34 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol35 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol37 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol38 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol39 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol40 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol44 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol46 AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgsol52 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol53 AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_flgsol57 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol58 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol59 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol80 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgsol81 AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flsoliof AS LOGICAL                           NO-UNDO.
DEF {1} SHARED VAR aux_flgexist AS LOGICAL                           NO-UNDO.

DEF {1} SHARED VAR aux_nrseqsol AS INT     FORMAT "zzz9"  INIT 1050  NO-UNDO.
DEF {1} SHARED VAR aux_dsparame AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_dspar040 AS CHAR    FORMAT "x(40)"            NO-UNDO.
DEF {1} SHARED VAR aux_dtultdia AS DATE                              NO-UNDO.
DEF {1} SHARED VAR aux_nmarqden AS CHAR    FORMAT "x(30)"            NO-UNDO.

DEF {1} SHARED VAR aux_dtdiames AS INT                               NO-UNDO.

DEF {1} SHARED VAR aux_dtavisos AS DATE                              NO-UNDO.
DEF {1} SHARED VAR aux_qtdiasut AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nmarqlmp AS CHAR  INIT "arquivos/.limpezaok"  NO-UNDO.
DEF {1} SHARED VAR aux_inpessoa LIKE crapass.inpessoa                NO-UNDO.
DEF {1} SHARED VAR aux_nrsequen AS INTE FORMAT "999"                 NO-UNDO.
DEF {1} SHARED VAR aux_dtfimper AS DATE                              NO-UNDO.

DEF {1} SHARED FRAME f-cmd.

DEF    TEMP-TABLE w_criticas                                         NO-UNDO
       FIELD nrsequen  AS  INT  FORMAT "99999"
       FIELD dscritic  AS  CHAR FORMAT "x(70)"
       FIELD cdsitexc  AS  INT
       FIELD cdagenci  AS  INT  FORMAT "z99"
       FIELD cdcooper  AS  INT.
                                 
FORM SKIP(5)
     cmd[1] AT 11
     SKIP(1)
     cmd[2] AT 11
     SKIP(1)
     cmd[3] AT 11
     SKIP(1) 
     cmd[4] AT 11
     SKIP(4)
     WITH OVERLAY WIDTH 80 TITLE glb_tldatela FRAME f-cmd NO-LABELS.
                                   
/* variaveis para a opcao visualizar */
DEF BUTTON btn-ok     LABEL "Sair".
DEF VAR edi_criticas   AS CHAR VIEW-AS EDITOR SIZE 132 BY 14
                    /* SCROLLBAR-VERTICAL */  PFCOLOR 0.     

DEF FRAME fra_criticas 
    edi_criticas  
HELP "<F4> ou <END> p/finalizar e <PAGE UP> ou <PAGE DOWN> p/navegar" 
    WITH SIZE 76 BY 14 ROW 7 COLUMN 3 USE-TEXT NO-BOX NO-LABELS 
    OVERLAY.

FORM SKIP(14)
     WITH FRAME f_moldura OVERLAY NO-LABELS ROW 6 WIDTH 80 TITLE "CRITICAS". 

/* .......................................................................... */

