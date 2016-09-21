/* ..........................................................................

   Programa: Fontes/crps114.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/95                         Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Atende a solicitacao 059.
               Ordem do programa na solicitacao = 1.
               Ordem da Solicitacao 032.
               Exclusividade = 2
               Gerar fichas dos admitidos para cadastramento.

   Alteracao : 19/04/96 - Gerar relatorio 126.

               19/09/96 - Alterado para listar a secao de extrato (Odair).

               31/10/96 - Alterado para listar admitidos ate ultimo dia do mes
                          anterior (Odair).

               13/01/97 - Alterado para listar somente os admitidos no ultimo
                          mes (Deborah).

               12/02/97 - Alterado para listar todos os nao recadastrados para
                          o PAC 14 (Edson).

               12/06/97 - Alterado para apenas listar as pessoas para recadas-
                          tramento (Odair).

               19/11/97 - Incluir turno no relatorio 94 (Odair).

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               15/10/1999 - Acerto na contagem dos associados (Deborah).

               22/10/1999 - Buscar dados da Cooperativa no crapcop (Edson).

               02/02/2000 - Gerar pedido de impressao (Deborah).

               12/01/2001 - Acerto no cabecalho do relatorio (Deborah).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               31/10/2007 - Mostrar secao da crapttl.nmdsecao (Guilherme).

               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               23/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               15/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
............................................................................. */

{ includes/var_batch.i "NEW" }

DEF STREAM str_1. /* Para fichas de recadastramento */
DEF STREAM str_2. /* Para relatorio 126 Ceval Jaragua */
DEF STREAM str_3. /* Para arquivo auxiliar */

DEF        VAR rel_nmresemp AS CHAR                                    NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                      NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]                NO-UNDO.

DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"              NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5     NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
DEF        VAR aux_nmarqtmp AS CHAR                                    NO-UNDO.

DEF        VAR flg_regexist AS LOGICAL   INIT FALSE                    NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                     NO-UNDO.
DEF        VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
DEF        VAR aux_qtassoci AS INT                                     NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                                 NO-UNDO.
DEF        VAR aux_cdempres AS INT                                     NO-UNDO.


FORM SKIP(8)
     "FUNCIONARIOS QUE DEVEM COMPARECER NA" AT 5
     crapcop.nmrescop FORMAT "x(20)" 
     "PARA CADASTRAMENTO" 
     "============================================================================" AT 5
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_titulo.

FORM aux_nmprimtl  AT  15 LABEL "NOME"      FORMAT "x(40)"
     aux_nrdconta  AT  56 LABEL "CONTA/DV"  FORMAT "zzzz,zz9,9"
     SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_lista.

FORM aux_qtassoci  AT  15 LABEL "TOTAL DE FUNCIONARIOS" FORMAT "zzz,zz9"
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_total.

FORM crapage.nmresage LABEL "PA"   AT 07
     SKIP(1)
     WITH DOWN NO-BOX SIDE-LABELS FRAME f_agencia.

FORM crapass.nrdconta LABEL "Conta/Dv"
     crapass.nmprimtl LABEL "Titular"  FORMAT "x(30)"
     crapass.dtadmiss LABEL "Admissao" FORMAT "99/99/9999"
     aux_cdempres     LABEL "Emp"      FORMAT "zzzz9"
     crapttl.cdturnos LABEL "Tu"       FORMAT "z9"
     SKIP(1)
     WITH DOWN NO-BOX NO-LABELS WITH FRAME f_dados.

ASSIGN  glb_cdprogra = "crps114"
        glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

{ includes/cabrel080_1.i }

IF   glb_cdcritic > 0 THEN
     QUIT.

/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

/*  Verifica se deve executar  */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "EXESOLADMI" AND
                   craptab.tpregist = 001          NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 433.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         QUIT.
     END.
ELSE
     IF   craptab.dstextab = "1" THEN
          DO:
              glb_cdcritic  = 146.
              RUN fontes/critic.p.
              UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '" +
                                 glb_dscritic + " >> log/proc_batch.log").
              QUIT.
          END.

ASSIGN aux_nmarqimp = "rl/crrl094.lst"
       aux_nmarqtmp = "rl/crps114.tmp".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
OUTPUT STREAM str_3 TO VALUE(aux_nmarqtmp).

VIEW STREAM str_1 FRAME f_cabrel080_1.

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:

    ASSIGN aux_qtassoci = 0
           aux_flgfirst = TRUE.

    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.dtelimin = ?            AND
                           crapass.dtdemiss = ?            AND
                           crapass.inpessoa < 3            AND
                           crapass.cdagenci = crapage.cdagenci
                           USE-INDEX crapass2 NO-LOCK:

        IF   crapass.inpessoa = 1   THEN
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                    crapttl.nrdconta = crapass.nrdconta   AND
                                    crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
        
                 IF   AVAIL crapttl  THEN
                      ASSIGN aux_cdempres = crapttl.cdempres.
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                    crapjur.nrdconta = crapass.nrdconta
                                    NO-LOCK NO-ERROR.
        
                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
             END.


        FIND FIRST crapalt WHERE crapalt.cdcooper = glb_cdcooper     AND
                                 crapalt.nrdconta = crapass.nrdconta AND
                                 crapalt.tpaltera = 1  NO-LOCK NO-ERROR.

        IF   AVAILABLE crapalt THEN
             NEXT.
                                        
        /*  Cria arquivo temporario com todos os nao recadastrados do PAC 14  */
        IF   crapass.cdagenci = 14 THEN
             DO:                         
                 flg_regexist = TRUE.

                 PUT STREAM str_3
                     '"'
                     crapass.nmprimtl FORMAT "x(40)" '" '
                     crapass.nrdconta FORMAT "99999999" SKIP.
            END.
        ELSE    
             DO:

                 IF  aux_flgfirst THEN
                     DO:

                         DISPLAY STREAM str_1 crapage.nmresage
                                        WITH FRAME f_agencia.

                         DOWN STREAM str_1 WITH FRAME f_agencia.
                     END.

                 IF  LINE-COUNTER(str_1) > 82 THEN
                     DO:
                         PAGE STREAM str_1.
                         DISPLAY STREAM str_1 crapage.nmresage
                                 WITH FRAME f_agencia.

                         DOWN STREAM str_1 WITH FRAME f_agencia.

                     END.

                 IF   AVAILABLE crapttl    THEN
                      DISPLAY STREAM str_1
                              crapass.nrdconta crapass.nmprimtl
                              crapass.dtadmiss aux_cdempres
                              crapttl.cdturnos 
                              WITH FRAME f_dados.
                 ELSE 
                      DISPLAY STREAM str_1
                              crapass.nrdconta crapass.nmprimtl
                              crapass.dtadmiss aux_cdempres
                              "" @ crapttl.cdturnos                               
                              WITH FRAME f_dados.

                 DOWN STREAM str_1 WITH FRAME f_dados.

                 ASSIGN aux_qtassoci = aux_qtassoci + 1
                        aux_flgfirst = FALSE.

             END.
    END.  /*  Fim do FOR EACH -- crapass  */

    IF   aux_qtassoci > 0 THEN
         DO:
             DISPLAY STREAM str_1 aux_qtassoci WITH FRAME f_total.

             PAGE STREAM str_1.
         END.
END. /* FOR EACH crapage */

OUTPUT STREAM str_3 CLOSE.
OUTPUT STREAM str_1 CLOSE.

aux_qtassoci = 0.

IF   flg_regexist THEN
     DO:
         UNIX SILENT VALUE("sort -o " + aux_nmarqtmp + " " +
                            aux_nmarqtmp + " 2> /dev/null").

         INPUT STREAM str_3 FROM VALUE(aux_nmarqtmp) NO-ECHO.

         OUTPUT STREAM str_2 TO "rl/crrl126.lst" PAGED PAGE-SIZE 84.

         DISPLAY STREAM str_2 crapcop.nmrescop WITH FRAME f_titulo.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            SET STREAM str_3
                aux_nmprimtl FORMAT "x(40)"
                aux_nrdconta FORMAT "99999999".

            aux_qtassoci = aux_qtassoci + 1.

            IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2) THEN
                 DO:
                     PAGE STREAM str_2.

                     DISPLAY STREAM str_2 crapcop.nmrescop WITH FRAME f_titulo.
                 END.

            DISPLAY STREAM str_2
                    aux_nmprimtl aux_nrdconta WITH FRAME f_lista.

            DOWN STREAM str_2 WITH FRAME f_lista.

         END.

         INPUT STREAM str_3 CLOSE.

         IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2) THEN
              DO:
                  PAGE STREAM str_2.

                  DISPLAY STREAM str_2 crapcop.nmrescop WITH FRAME f_titulo.
              END.

         DISPLAY STREAM str_2 aux_qtassoci WITH FRAME f_total.

         OUTPUT STREAM str_2 CLOSE.

         ASSIGN glb_nrcopias = 3
                glb_nmformul = "timbre"
                glb_nmarqimp = "rl/crrl126.lst".

         RUN fontes/imprim.p.

     END.

DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETRY:

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.nmsistem = "CRED"       AND
                      craptab.tptabela = "GENERI"     AND
                      craptab.cdempres = 00           AND
                      craptab.cdacesso = "EXESOLADMI" AND
                      craptab.tpregist = 001
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab THEN
        IF   LOCKED craptab THEN
             DO:
                 PAUSE 2 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             DO:
                 glb_cdcritic = 433.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " >> log/proc_batch.log").
                 QUIT.
              END.
   ELSE
        craptab.dstextab = "1".

   LEAVE.

END.    /*  Fim do DO WHILE TRUE  */

UNIX SILENT VALUE("rm " + aux_nmarqtmp + " 2> /dev/null").

ASSIGN glb_nrcopias = 1
       glb_nmformul = "80col"
       glb_nmarqimp = aux_nmarqimp
       glb_infimsol = TRUE.

RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/* .......................................................................... */



