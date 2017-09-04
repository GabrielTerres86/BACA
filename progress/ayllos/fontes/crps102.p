 /* ..........................................................................

   Programa: Fontes/crps102.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94                         Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Batch - Background.

   Objetivo  : Emitir a listagem de contas incluidas no CCF pelo BB.
               Relatorio 85.
               Atende a solicitacao  57 (Automatica apos dia 19)
               Ordem da Solicitacao 061.
               Exclusividade 2.
               Ordem do programa na solicitacao = 1.

   Alteracao : 24/05/95 - Alterado para listar a quantidade de associados
                          e devolucoes (Odair).

               24/06/97 - Listar o PAC, tipo e situacao de conta (Odair)

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             07/10/2005 - Alterado para ler tbm na tabela crapali o codigo da
                          cooperativa (Diego).
                          
             15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
             
             11/01/2011 - Incluido format "x(40)" para o campo nmprimtl
                          (Kbase - Gilnei)  
             
             15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
             01/09/2017 - Inclusao de log de fim de execucao do programa 
                          (Carlos)
             ............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR aux_nrdconta     AS  INT                              NO-UNDO.
DEF        VAR aux_nmarqimp     AS  CHAR     INIT   "rl/crrl085.lst" NO-UNDO.

DEF        VAR rel_nmresage     AS CHAR                                     .
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nrmodulo     AS INT     FORMAT "9"                NO-UNDO.
DEF        VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dtliminf     AS  DATE                             NO-UNDO.
DEF        VAR rel_dtlimsup     AS  DATE                             NO-UNDO.

DEF        VAR rel_dsalinea     AS  CHAR   FORMAT "x(22)"            NO-UNDO.

DEF        VAR rel_qtassoci     AS  INT    FORMAT "zzz,zz9"          NO-UNDO.
DEF        VAR rel_qtdevolu     AS  INT    FORMAT "zzz,zz9"          NO-UNDO.

ASSIGN glb_cdprogra = "crps102"
       aux_nrdconta = 0.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM "PERIODO:"
     rel_dtliminf      AT 10  FORMAT "99/99/9999"  NO-LABEL
     "A"               AT 21
     rel_dtlimsup      AT 23  FORMAT "99/99/9999"  NO-LABEL
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL    WIDTH 132 FRAME f_label.

FORM crapass.cdagenci  AT  02                      LABEL "PA"
     crapass.nrdconta  AT  07                      LABEL "CONTA/DV"
     crapass.cdtipcta  AT  19                      LABEL "TIPO"
     crapass.cdsitdct  AT  25                      LABEL "SIT."
     crapass.nmprimtl  AT  31  FORMAT "X(40)"      LABEL "TITULAR"
     crapneg.nrdctabb  AT  74                      LABEL "CONTA BASE"
     crapneg.nrdocmto  AT  87  FORMAT "zzz,zzz,9"  LABEL "DOCUMENTO"
     rel_dsalinea      AT  99                      LABEL "ALINEA"
     crapneg.dtiniest  AT 122  FORMAT "99/99/9999" LABEL "DEVOLUCAO"
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN   WIDTH 132 FRAME f_linha.

FORM SKIP(1)
     rel_qtassoci      AT  31                     LABEL "QTD. DE ASSOCIADOS"
     rel_qtdevolu      AT  74                     LABEL "QTD. DE DEVOLUCOES"
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_qtdade.

{ includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

/* Monta a data limite inferior */

IF   MONTH(glb_dtmvtolt) = 1  THEN
     rel_dtliminf = DATE(12,20,YEAR(glb_dtmvtolt) - 1).
ELSE
     rel_dtliminf = DATE(MONTH(glb_dtmvtolt) - 1,20,YEAR(glb_dtmvtolt)).

/* Monta a data limite superior */

rel_dtlimsup = DATE(MONTH(glb_dtmvtolt),21,YEAR(glb_dtmvtolt)).

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW    STREAM str_1                   FRAME f_cabrel132_1.
DISPLAY STREAM str_1   rel_dtliminf rel_dtlimsup WITH FRAME f_label.

FOR EACH crapneg WHERE  crapneg.cdcooper = glb_cdcooper    AND
                       (crapneg.dtiniest > rel_dtliminf    AND
                        crapneg.dtiniest < rel_dtlimsup)   AND
                        crapneg.cdhisest =  1              AND 
                       (crapneg.cdobserv = 12    OR
                        crapneg.cdobserv = 13) 
                        USE-INDEX crapneg4 NO-LOCK
                        BY crapneg.nrdconta    
                           BY crapneg.nrdctabb
                              BY crapneg.nrdocmto:

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                       crapass.nrdconta = crapneg.nrdconta 
                       USE-INDEX crapass1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass THEN
         DO:
            glb_cdcritic = 251.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                               " >> log/proc_batch.log").
            QUIT.
         END.
    ELSE
    IF   crapass.inlbacen = 1   THEN
         NEXT.
    ELSE
         DO:
            FIND crapali WHERE crapali.cdalinea = crapneg.cdobserv
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapali THEN
                 rel_dsalinea = STRING(crapneg.cdobserv) + " -  Nao Cadastrada".
            ELSE
                 rel_dsalinea = STRING(crapneg.cdobserv) + " - " +
                                       crapali.dsalinea.
         END.

    DISPLAY STREAM str_1
            crapass.cdagenci   WHEN crapass.nrdconta <> aux_nrdconta
            crapass.nrdconta   WHEN crapass.nrdconta <> aux_nrdconta
            crapass.cdtipcta   WHEN crapass.nrdconta <> aux_nrdconta
            crapass.cdsitdct   WHEN crapass.nrdconta <> aux_nrdconta
            crapass.nmprimtl   WHEN crapass.nrdconta <> aux_nrdconta
            crapneg.nrdctabb   crapneg.nrdocmto   rel_dsalinea
            crapneg.dtiniest   WITH FRAME f_linha.

    ASSIGN rel_qtdevolu = rel_qtdevolu + 1
           rel_qtassoci = IF  crapass.nrdconta <> aux_nrdconta
                              THEN  rel_qtassoci + 1
                              ELSE  rel_qtassoci
           aux_nrdconta = crapass.nrdconta.

    DOWN STREAM str_1 WITH FRAME f_linha.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
            PAGE STREAM str_1.
            VIEW    STREAM str_1                   FRAME f_label.
         END.

END.  /*  Fim do FOR EACH  do crapneg */

DISPLAY STREAM str_1 rel_qtassoci rel_qtdevolu WITH FRAME f_qtdade.

OUTPUT STREAM str_1 CLOSE.

glb_infimsol = true.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

ASSIGN glb_nmarqimp = aux_nmarqimp
       glb_nmformul = ""
       glb_nrcopias = 1.

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS102.P",
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

RUN fontes/imprim.p.

/* .......................................................................... */


