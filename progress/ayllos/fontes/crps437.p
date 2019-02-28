/* ..........................................................................

   Programa: Fontes/crps437.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Marco/2005                      Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 086.
               Listar os Dados do Sistema Financeiro (relatorio 413).
               
   Alteracoes: 08/11/2005 - Corrigido FORMAT da agencia (Evandro).

               15/02/2006 - Alterado para imprimir 1 via p/ Viacredi (Diego).
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               13/09/2007 - Incluido no relatorio o operador que fez a inclusao
                            do inicio do relacionamento bancario do cooperado
                            (Elton).
                            
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)           
..............................................................................*/

{ includes/var_batch.i "NEW" }

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR rel_nrdctadv AS CHAR    FORMAT "x(11)"                NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

FORM crapass.cdagenci  LABEL "PA"
     SPACE(2)
     crapass.nrdconta  LABEL "CONTA/DV"
     SPACE(2)
     crapass.nmprimtl  LABEL "NOME"         FORMAT "x(31)"
     SPACE(2)
     crapsfn.cddbanco  LABEL "COD"
     SPACE(2)
     crapsfn.cdageban  LABEL "AGENCIA"      FORMAT "99999"
     SPACE(2)
     rel_nrdctadv      LABEL "   CONTA/DV"
     SPACE(2)
     crapsfn.nminsfin  LABEL "BANCO/INSTITUICAO"
     SPACE(2)
     crapsfn.cdoperad  LABEL "OPER."  
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 COLUMN 6 FRAME f_sistema.

ASSIGN glb_cdprogra = "crps437"
       aux_nmarqimp = "rl/crrl413.lst"
       glb_cdempres = 11.

RUN fontes/iniprg.p.                                                                   

IF   glb_cdcritic > 0   THEN
     QUIT.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.

{ includes/cabrel132_1.i }

VIEW STREAM str_1 FRAME f_cabrel132_1.

FOR EACH crapsfn WHERE crapsfn.cdcooper = glb_cdcooper AND
                       crapsfn.dtmvtolt = glb_dtmvtolt NO-LOCK,
    EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrcpfcgc = crapsfn.nrcpfcgc NO-LOCK
                       BREAK BY crapass.cdagenci
                               BY crapass.nrdconta:
    
    DISPLAY STREAM str_1 crapass.cdagenci  WHEN FIRST-OF(crapass.cdagenci)
                         crapass.nrdconta
                         crapass.nmprimtl
                         crapsfn.cdoperad  
                         WITH FRAME f_sistema.    

    /* se for banco */
    IF   crapsfn.cddbanco <> 0   THEN
         DO:
             FIND crapban WHERE crapban.cdbccxlt = crapsfn.cddbanco
                                NO-LOCK NO-ERROR.
                                
             rel_nrdctadv = STRING(crapsfn.nrdconta,"9999999999") + 
                            crapsfn.dgdconta.

             DISPLAY STREAM str_1 crapsfn.cddbanco
                                  crapban.nmextbcc @ crapsfn.nminsfin
                                  crapsfn.cdageban
                                  rel_nrdctadv
                                  WITH FRAME f_sistema.

         END.                                
    ELSE
         DISPLAY STREAM str_1 crapsfn.nminsfin
                              WITH FRAME f_sistema.
                         
    DOWN STREAM str_1 WITH FRAME f_sistema.                         

    IF   LAST-OF(crapass.cdagenci)   THEN
         DOWN 1 STREAM str_1 WITH FRAME f_sistema.

END.

OUTPUT STREAM str_1 CLOSE.

IF   glb_cdcooper = 1  THEN
     ASSIGN glb_nrcopias = 1.
ELSE
     ASSIGN glb_nrcopias = 2.
     
ASSIGN glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.
                     
RUN fontes/imprim.p.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS437.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS437.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }                     
                           
RUN fontes/fimprg.p.

/* .......................................................................... */

