/* ..........................................................................

   Programa: Fontes/crps390.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2004                      Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 4.
               Emitir relacao de associados sem capital minimo.
               Emite relatrio 346.

   Alteracoes: 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               01/02/2007 - Prever cotas negativas (Magui).

               05/12/2007 - Retirada condicao de registro selecionado (Gabriel).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739) 
							
............................................................................. */

DEF STREAM str_1.      /*  Para relatorio de rejeitados  */

{ includes/var_batch.i "NEW" }
/* Chamada Oracle - 20/02/2019 - REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                      NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]                NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5     NO-UNDO.

DEF        VAR rel_qtassoci     AS INT                                 NO-UNDO.
DEF        VAR rel_vltotcap     AS DECIMAL                             NO-UNDO.

FORM crapmat.vlcapini AT 1 FORMAT "zzz,zz9.99" LABEL "CAPITAL MINIMO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS FRAME f_minimo.

FORM crapass.cdagenci AT   2 FORMAT "zz9"            LABEL "PA"
     crapass.dtadmiss AT   6 FORMAT "99/99/9999"     LABEL "ADMITIDO EM"
     crapass.nrmatric AT  19 FORMAT "zzz,zz9"        LABEL "MATRICULA"
     crapass.nrdconta AT  31 FORMAT "zzzz,zzz,9"     LABEL "CONTA/DV"
     crapass.nmprimtl AT  44 FORMAT "x(40)"          LABEL "NOME"
     crapcot.vldcotas AT  87 FORMAT "zz,zzz,zz9.99-" LABEL "VALOR"
     WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 132 DOWN FRAME f_sem_minimo.

FORM SKIP(1)
     rel_qtassoci AT 51 FORMAT "zzz,zz9"        NO-LABEL
     rel_vltotcap AT 94 FORMAT "zz,zzz,zz9.99-" NO-LABEL
     SKIP(2)
     "**************************************************************" AT 35
     "*                                                            *" AT 35
     "*      OS COOPERADOS ACIMA NAO POSSUEM O CAPITAL MINIMO      *" AT 35
     "*      ************************************************      *" AT 35
     "*        EXIGIDO PELO ESTATUTO SOCIAL DA COOPERATIVA.        *" AT 35
     "*        ********************************************        *" AT 35
     "*                                                            *" AT 35
     "*                                                            *" AT 35
     "*   ASSINATURA DA PRESIDENCIA: ___________________________   *" AT 35
     "*                                                            *" AT 35
     "*                                                            *" AT 35
     "*      ASSINATURA DA GERENCIA: ___________________________   *" AT 35
     "*                                                            *" AT 35
     "**************************************************************" AT 35
     SKIP(3)
     WITH COL 3 NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_total.

glb_cdprogra = "crps390".

RUN fontes/iniprg.p.
          
IF   glb_cdcritic > 0 THEN
     QUIT.

{ includes/cabrel132_1.i }          /*  Monta cabecalho do relatorio  */

OUTPUT STREAM str_1 TO "rl/crrl346.lst" PAGED PAGE-SIZE 87.

VIEW STREAM str_1 FRAME f_cabrel132_1.

FIND FIRST crapmat WHERE crapmat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

DISPLAY STREAM str_1 crapmat.vlcapini WITH FRAME f_minimo.

FOR EACH crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                       crapcot.vldcotas < crapmat.vlcapini NO-LOCK:

    /*FIND crapass OF crapcot NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                       crapass.nrdconta = crapcot.nrdconta
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             glb_cdcritic = 251.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic  +
                               " Conta: " + 
                               TRIM(STRING(crapcot.nrdconta,"zzzz,zzz,9")) +
                               " >> log/proc_batch.log").
             NEXT.
         END.
    
    IF   crapass.dtdemiss <> ?   OR
         crapass.inpessoa = 3    THEN
         NEXT.
    
    ASSIGN  rel_qtassoci = rel_qtassoci + 1
            rel_vltotcap = rel_vltotcap + crapcot.vldcotas.
    
    DISPLAY STREAM str_1
            crapass.cdagenci  crapass.dtadmiss  crapass.nrmatric
            crapass.nrdconta  crapass.nmprimtl  crapcot.vldcotas
            WITH FRAME f_sem_minimo.
 
    DOWN STREAM str_1 WITH FRAME f_sem_minimo.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.
             DISPLAY STREAM str_1 crapmat.vlcapini WITH FRAME f_minimo.
         END.

END. /*  Fim do FOR EACH crapcot  */

IF   LINE-COUNTER(str_1) > 65   THEN
     PAGE STREAM str_1.

DISPLAY STREAM str_1 rel_qtassoci rel_vltotcap WITH FRAME f_total.

OUTPUT STREAM str_1 CLOSE.

/* Relatorio chama imprim.p independentemente de ter ou nao registros selecionados*/

ASSIGN glb_nmformul = ""
       glb_nmarqimp = "rl/crrl346.lst"
       glb_nrcopias = 1.
                    
RUN fontes/imprim.p.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS390.P",
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
    INPUT "CRPS390.P",
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

/*........................................................................... */
