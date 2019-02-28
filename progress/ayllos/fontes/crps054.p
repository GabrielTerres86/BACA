/* ..........................................................................

   Programa: Fontes/crps054.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/93.                           Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Emitir resumo dos depositos bloqueados.
               Atende solicitacao 002.

   Alteracoes: Alterado em 13/01/95 para nao flegar a solicitacao como proces-
               sada. (Odair).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               28/06/99 - Alterado para nao imprimir o relatorio - conforme
                          pedido do IRINEU (Edson).

               25/01/2000 - Chamar a rotina de impressao (Deborah).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               19/10/2009 - Alteracao Codigo Historico (Kbase).   
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
							
............................................................................. */

DEF STREAM str_1.     /*  Para resumo dos depositos bloqueados  */

{ includes/var_batch.i "NEW" }

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dtliblan AS DATE                                  NO-UNDO.
DEF        VAR rel_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR rel_vlliblan AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qtliblan AS INT                                   NO-UNDO.

DEF        VAR tot_vlliblan AS DECIMAL                               NO-UNDO.
DEF        VAR tot_qtliblan AS INT                                   NO-UNDO.

DEF        VAR ger_vlliblan AS DECIMAL                               NO-UNDO.
DEF        VAR ger_qtliblan AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    FORMAT "x(14)" EXTENT 5
                               INIT ["rl/crrl049.lst","","","",""]   NO-UNDO.

DEF        VAR aux_nmformul AS CHAR    FORMAT "x(10)" EXTENT 5
                               INIT [" "," "," "," "," "]    NO-UNDO.

glb_cdprogra = "crps054".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

FORM "DATA DE LIBERACAO" AT  24
     "HISTORICO"         AT  45
     "VALOR"             AT  89
     "QTD"               AT 103
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_label.

FORM rel_dtliblan AT  29 FORMAT "99/99/9999"
     rel_dshistor AT  45 FORMAT "x(21)"
     rel_vlliblan AT  68 FORMAT "zzz,zzz,zzz,zzz,zzz,zz9.99"
     rel_qtliblan AT  99 FORMAT "zzz,zz9"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABELS WIDTH 132 FRAME f_libera.

FORM "--------------------------     -------" AT 68
     SKIP
     tot_vlliblan AT  68 FORMAT "zzz,zzz,zzz,zzz,zzz,zz9.99"
     tot_qtliblan AT  99 FORMAT "zzz,zz9"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_total.

FORM SKIP(1)
     "TOTAL GERAL:" AT  45
     ger_vlliblan   AT  68 FORMAT "zzz,zzz,zzz,zzz,zzz,zz9.99"
     ger_qtliblan   AT  99 FORMAT "zzz,zz9"
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_geral.

FORM "NAO HA DEPOSITOS BLOQUEADOS."
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_mensagem.

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[1]) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

VIEW STREAM str_1 FRAME f_label.

/*  Leitura dos depositos bloqueados  */

FOR EACH crapdpb WHERE crapdpb.cdcooper = glb_cdcooper   AND
                       crapdpb.dtliblan > glb_dtmvtolt   AND
                       crapdpb.inlibera = 1 USE-INDEX crapdpb3 NO-LOCK
                       BREAK BY crapdpb.dtliblan
                                BY crapdpb.cdhistor:

    IF   FIRST-OF(crapdpb.dtliblan)   THEN
         DO:
             rel_dtliblan = crapdpb.dtliblan.

             DISPLAY STREAM str_1
                     rel_dtliblan WITH FRAME f_libera.
         END.

    IF   FIRST-OF(crapdpb.cdhistor)   THEN
         DO:
          
             FIND craphis NO-LOCK WHERE
                                  craphis.cdcooper = crapdpb.cdcooper AND 
                                  craphis.cdhistor = crapdpb.cdhistor NO-ERROR.
  
             IF   NOT AVAILABLE craphis   THEN
                  rel_dshistor = STRING(crapdpb.cdhistor,"9999") + " - " +
                                 FILL("*",15).
             ELSE
                  rel_dshistor = STRING(crapdpb.cdhistor,"9999") + " - " +
                                 craphis.dshistor.

             DISPLAY STREAM str_1 rel_dshistor WITH FRAME f_libera.
         END.

    ASSIGN rel_vlliblan = rel_vlliblan + crapdpb.vllanmto
           rel_qtliblan = rel_qtliblan + 1

           tot_vlliblan = tot_vlliblan + crapdpb.vllanmto
           tot_qtliblan = tot_qtliblan + 1

           ger_vlliblan = ger_vlliblan + crapdpb.vllanmto
           ger_qtliblan = ger_qtliblan + 1.

    IF   LAST-OF(crapdpb.cdhistor)   OR
         LAST-OF(crapdpb.dtliblan)   THEN
         DO:
             DISPLAY STREAM str_1
                     rel_vlliblan rel_qtliblan WITH FRAME f_libera.

             DOWN STREAM str_1 WITH FRAME f_libera.

             IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                  DO:
                      PAGE STREAM str_1.

                      VIEW STREAM str_1 FRAME f_label.
                  END.

             ASSIGN rel_vlliblan = 0
                    rel_qtliblan = 0.

             IF   LAST-OF(crapdpb.dtliblan)   THEN
                  DO:
                      IF   LINE-COUNTER(str_1) > 82   THEN
                           DO:
                                PAGE STREAM str_1.

                                VIEW STREAM str_1 FRAME f_label.
                           END.

                      DISPLAY STREAM str_1
                              tot_vlliblan tot_qtliblan WITH FRAME f_total.

                      IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                           DO:
                                PAGE STREAM str_1.

                                VIEW STREAM str_1 FRAME f_label.
                           END.

                      ASSIGN tot_vlliblan = 0
                             tot_qtliblan = 0.
                  END.
         END.

END.  /*  Fim do FOR EACH  --  Leitura dos depositos bloqueados  */

IF   ger_qtliblan > 0   THEN
     DO:
         IF   LINE-COUNTER(str_1) > 83   THEN
              DO:
                  PAGE STREAM str_1.

                  VIEW STREAM str_1 FRAME f_label.
              END.

         DISPLAY STREAM str_1 ger_vlliblan ger_qtliblan WITH FRAME f_geral.
     END.
ELSE
     VIEW STREAM str_1 FRAME f_mensagem.

OUTPUT STREAM str_1 CLOSE.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS054.P",
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
    INPUT "CRPS054.P",
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

IF   glb_cdcritic > 0   THEN
     RETURN.

ASSIGN glb_nrcopias = 1
       glb_nmarqimp = aux_nmarqimp[1]
       glb_nmformul = aux_nmformul[1].

RUN fontes/imprim.p.
/* .......................................................................... */

