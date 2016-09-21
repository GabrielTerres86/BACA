/* .............................................................................

   Programa: Fontes/cctror.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                         Ultima atualizacao: 29/05/2014

   Dados referentes ao programa:

   Frequefncia: Diario (on-line)
   Objetivo  : Mostrar a tela CCTROR.

   Alteracoes: 26/03/98   - Tratamento para milenio e troca para V8 (Margarete).
   
               22/12/2004 - Incluida opcao "R" (Evandro).

               09/12/2005 - Tratar novo indice no crapcor (Edson).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               07/03/2007 - Altera campo Talao para Banco (Bancoob) (Ze).
               
               19/12/2007 - Incluido campo OPE (operador), mudanca no frame   
                            f_contra_ordens na procedure imprime_contra_ordens 
                            (Gabriel).
                            
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela craphis(Guilherme).

               22/05/2009 - Alteracao CDOPERAD (Kbase).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               30/11/2010 - Alteracao de Format (Kbase/Willian).
                            001 - Alterado para 50 posições, valor anterior 40.
                           
               07/02/2012 - Tratamento para Sustacao Temporaria (Ze).
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrctachq AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(50)"                NO-UNDO. /*001*/
DEF        VAR tel_dtemscor AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdbanchq AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR tel_nrinichq AS INT     FORMAT "zzz,zz9,9"            NO-UNDO.
DEF        VAR tel_nrfinchq AS INT     FORMAT "zzz,zzz,z"            NO-UNDO.
DEF        VAR tel_dshistor AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR tel_dssitdtl AS CHAR    FORMAT "x(24)"                NO-UNDO.
DEF        VAR tel_cdoperad AS CHAR    FORMAT "x(10)"                NO-UNDO.  
   

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_nrctachq AS INT                                   NO-UNDO.
DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.
DEF        VAR aux_nrcheque AS INT                                   NO-UNDO.
DEF        VAR aux_nrchqant AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_dtemscor AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdoperad AS CHAR                                  NO-UNDO.

/* variaveis para impressao */
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao    "  AUTO-RETURN
                        HELP "Informe a opcao desejada (C, R)"
                        VALIDATE(CAN-DO("C,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_nrdconta AT  2 LABEL "Conta/dv."
                        HELP  "Entre com o numero da conta do associado"
     tel_nmprimtl AT  2 LABEL "Titular"
     SKIP(1)
     tel_dssitdtl AT  2 LABEL "Situacao do Titular da Conta  "
     SKIP(1)
     "Numero do Cheque" AT 34
     SKIP
     "Emissao    Banco Conta Base  Operador     Inicial     Final Historico" 
     AT 2
     SKIP
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cctror.

FORM tel_dtemscor AT  2   tel_cdbanchq AT 13
     tel_nrctachq AT 19   tel_cdoperad AT 31
     tel_nrinichq AT 42   tel_nrfinchq AT 52
     tel_dshistor AT 62
     WITH ROW 13 COLUMN 2 OVERLAY 8 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_cctror

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      glb_nrcalcul = tel_nrdconta.
      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               glb_cdcritic = 8.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_cctror NO-PAUSE.
               CLEAR FRAME f_lanctos ALL NO-PAUSE.
               NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
               glb_cdcritic = 0.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 ou FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CCTROR"   THEN
                 DO:
                     HIDE FRAME f_cctror
                          FRAME f_lanctos
                          FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                      crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            glb_cdcritic = 9.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_cctror  NO-PAUSE.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
            glb_cdcritic = 0.
            NEXT.
        END.

   tel_nmprimtl = crapass.nmprimtl.

   FIND crapsit WHERE  crapsit.cdcooper = glb_cdcooper AND
                       crapsit.cdsitdtl = crapass.cdsitdtl NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapsit   THEN
        DO:
            glb_cdcritic = 12.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_cctror  NO-PAUSE.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
            glb_cdcritic = 0.
            NEXT.
        END.

   tel_dssitdtl = STRING(crapass.cdsitdtl) + " - " + crapsit.dssitdtl.

   ASSIGN aux_regexist = FALSE
          aux_flgretor = FALSE
          aux_flgfirst = TRUE
          aux_contador = 0
          tel_nrfinchq = 0.

   DISPLAY tel_nmprimtl 
           tel_dssitdtl  
           WITH FRAME f_cctror.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   glb_cddopcao = "R"   THEN
        DO:
            RUN imprime_contra_ordens.
            HIDE FRAME f_contra_ordens
                 FRAME f_atencao.
            NEXT.
        END.
   
   FOR EACH crapcor WHERE crapcor.cdcooper = glb_cdcooper   AND
                          crapcor.nrdconta = tel_nrdconta   AND
                          crapcor.flgativo = TRUE           AND
                          crapcor.dtvalcor = ?              NO-LOCK
                          BY crapcor.dtemscor
                             BY crapcor.cdbanchq
                                BY crapcor.nrctachq
                                   BY crapcor.nrcheque
                                      BY crapcor.cdhistor:

       aux_regexist = TRUE.
       aux_nrcheque = INT(SUBSTR(STRING(crapcor.nrcheque,"9999999"),1,6)) - 1.

       IF   crapcor.dtemscor = aux_dtemscor   AND
            crapcor.cdbanchq = aux_cdbanchq   AND
            crapcor.nrctachq = aux_nrctachq   AND
            crapcor.cdhistor = aux_cdhistor   AND
            aux_nrcheque     = aux_nrchqant   THEN
            ASSIGN tel_nrfinchq = crapcor.nrcheque
                   aux_nrchqant = INT(SUBSTR
                                     (STRING(crapcor.nrcheque,"9999999"),1,6)).
       ELSE
            DO:
                IF   aux_flgfirst   THEN
                     DO:
                         ASSIGN aux_dtemscor = crapcor.dtemscor
                                aux_cdbanchq = crapcor.cdbanchq
                                aux_nrctachq = crapcor.nrctachq
                                aux_cdoperad = crapcor.cdoperad
                                aux_cdhistor = crapcor.cdhistor
                                aux_nrchqant = INT(SUBSTR(STRING
                                              (crapcor.nrcheque,"9999999"),1,6))
                                aux_flgfirst = FALSE
                                aux_contador = 1        /*   alterei aqui  */
                                tel_nrinichq = crapcor.nrcheque.
                         NEXT.       
                     END.

                aux_contador = aux_contador + 1.

                IF   aux_contador = 1   THEN
                     IF   aux_flgretor   THEN
                          DO:
                              PAUSE MESSAGE
                         "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.

                FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                   craphis.cdhistor = aux_cdhistor
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craphis   THEN
                     DO:
                         glb_cdcritic = 80.
                         LEAVE.
                     END.

                ASSIGN tel_dshistor = STRING(aux_cdhistor,"9999") + "-" +
                                      craphis.dshistor
                       tel_dtemscor = aux_dtemscor
                       tel_cdbanchq = aux_cdbanchq
                       tel_nrctachq = aux_nrctachq
                       tel_cdoperad = aux_cdoperad.

                DISPLAY tel_dtemscor  tel_cdbanchq  tel_nrctachq
                        tel_cdoperad  tel_nrinichq  tel_nrfinchq
                        tel_dshistor  WITH FRAME f_lanctos.

                ASSIGN tel_nrinichq = crapcor.nrcheque
                       tel_nrfinchq = 0
                       aux_dtemscor = crapcor.dtemscor
                       aux_cdbanchq = crapcor.cdbanchq
                       aux_cdoperad = crapcor.cdoperad
                       aux_nrctachq = crapcor.nrctachq
                       aux_cdhistor = crapcor.cdhistor
                       aux_nrchqant = INT(SUBSTR(STRING(crapcor.nrcheque,
                                                        "9999999"),1,6)).

                IF   aux_contador = 8   THEN
                     ASSIGN aux_contador = 0
                            aux_flgretor = TRUE.
                ELSE
                     DOWN WITH FRAME f_lanctos.

            END.
   
   END. /* Faim do FOR EACH */

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 254.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF   aux_contador = 0   THEN
        DO:
            PAUSE MESSAGE "Tecle <Entra> para continuar ou <Fim> para encerrar".
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
        END.

   FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                      craphis.cdhistor = aux_cdhistor NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craphis   THEN
        DO:
            glb_cdcritic = 80.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
            glb_cdcritic = 0.
            NEXT.
        END.

   ASSIGN tel_dshistor = STRING(aux_cdhistor,"9999") + "-" + craphis.dshistor
          tel_dtemscor = aux_dtemscor
          tel_cdbanchq = aux_cdbanchq
          tel_nrctachq = aux_nrctachq
          tel_cdoperad = aux_cdoperad.

   DISPLAY tel_dtemscor  tel_cdbanchq  
           tel_nrctachq  tel_cdoperad  
           tel_nrinichq  tel_nrfinchq 
           tel_dshistor  
           WITH FRAME f_lanctos.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE imprime_contra_ordens:

   FORM "CONTRA-ORDENS/AVISOS"            AT 30
        SKIP(1)
        tel_nrdconta  LABEL "Conta/dv"    AT 5
        SKIP
        tel_nmprimtl  LABEL "Titular "    AT 5
        SKIP(1)              
        "Emissao    Banco Conta Base  Operador     Inicial     Final Historico"
        AT 3
        WITH SIDE-LABEL FRAME f_contra_ordens.
   
   FORM SKIP(1)
        "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
        SKIP(1)
        tel_dsimprim AT 14
        tel_dscancel AT 29
        SKIP(1)
        WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 FRAME f_atencao.

   DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.
   CHOOSE FIELD tel_dsimprim tel_dscancel WITH FRAME f_atencao.

   IF   FRAME-VALUE <> tel_dsimprim   THEN
        LEAVE.
   
   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.   
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.  

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
   ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

   ASSIGN glb_cdcritic    = 0
          glb_nrdevias    = 1
          glb_cdempres    = 11          
          glb_nmformul    = "80col"
          glb_cdrelato[1] = 402.
  
   { includes/cabrel080_1.i }
   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

   VIEW STREAM str_1 FRAME f_cabrel080_1.
   
   DISPLAY STREAM str_1 tel_nrdconta 
                        tel_nmprimtl WITH FRAME f_contra_ordens.
   
   FOR EACH crapcor WHERE crapcor.cdcooper = glb_cdcooper AND
                          crapcor.nrdconta = tel_nrdconta AND
                          crapcor.flgativo = TRUE         AND
                          crapcor.dtvalcor = ?            NO-LOCK
                          BY crapcor.dtemscor
                             BY crapcor.cdbanchq
                                BY crapcor.nrctachq
                                   BY crapcor.nrcheque
                                      BY crapcor.cdhistor:

       aux_regexist = TRUE.
       aux_nrcheque = INT(SUBSTR(STRING(crapcor.nrcheque,"9999999"),1,6)) - 1.

       IF   crapcor.dtemscor = aux_dtemscor   AND
            crapcor.cdbanchq = aux_cdbanchq   AND
            crapcor.nrctachq = aux_nrctachq   AND
            crapcor.cdhistor = aux_cdhistor   AND
            aux_nrcheque     = aux_nrchqant   THEN
            ASSIGN tel_nrfinchq = crapcor.nrcheque
                   aux_nrchqant = INT(SUBSTR
                                     (STRING(crapcor.nrcheque,"9999999"),1,6)).
       ELSE
            DO:
                IF   aux_flgfirst   THEN
                     DO:
                         ASSIGN aux_dtemscor = crapcor.dtemscor
                                aux_cdbanchq = crapcor.cdbanchq
                                aux_nrctachq = crapcor.nrctachq
                                aux_cdoperad = crapcor.cdoperad
                                aux_cdhistor = crapcor.cdhistor
                                aux_nrchqant = INT(SUBSTR(STRING
                                              (crapcor.nrcheque,"9999999"),1,6))
                                aux_flgfirst = FALSE
                                tel_nrinichq = crapcor.nrcheque.
                         NEXT.
                     END.

                FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                                   craphis.cdhistor = aux_cdhistor
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craphis   THEN
                     DO:
                         glb_cdcritic = 80.
                         LEAVE.
                     END.

                ASSIGN tel_dshistor = STRING(aux_cdhistor,"9999") + "-" +
                                      craphis.dshistor
                       tel_dtemscor = aux_dtemscor
                       tel_cdbanchq = aux_cdbanchq
                       tel_nrctachq = aux_nrctachq
                       tel_cdoperad = aux_cdoperad.

                DISPLAY STREAM str_1  tel_dtemscor  tel_cdbanchq  tel_nrctachq  
                                      tel_cdoperad  tel_nrinichq  tel_nrfinchq 
                                      tel_dshistor  WITH FRAME f_lanctos.

                ASSIGN tel_nrinichq = crapcor.nrcheque
                       tel_nrfinchq = 0
                       aux_dtemscor = crapcor.dtemscor
                       aux_cdbanchq = crapcor.cdbanchq
                       aux_nrctachq = crapcor.nrctachq
                       aux_cdoperad = crapcor.cdoperad
                       aux_cdhistor = crapcor.cdhistor
                       aux_nrchqant = INTEGER(SUBSTRING(STRING(crapcor.nrcheque,
                                              "9999999"),1,6)).

                DOWN STREAM str_1 WITH FRAME f_lanctos.
                
                IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                     DO:
                         PAGE STREAM str_1.
                         DISPLAY STREAM str_1  tel_nrdconta tel_nmprimtl 
                                               WITH FRAME f_contra_ordens.
                     END.


            END.
   END.

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF   NOT aux_regexist   THEN
        DO:
            glb_cdcritic = 254.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            glb_cdcritic = 0.
            NEXT.
        END.

   FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND
                      craphis.cdhistor = aux_cdhistor NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craphis   THEN
        DO:
            glb_cdcritic = 80.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_cctror.
            glb_cdcritic = 0.
            NEXT.
        END.

   ASSIGN tel_dshistor = STRING(aux_cdhistor,"9999") + "-" + craphis.dshistor
          tel_dtemscor = aux_dtemscor
          tel_cdbanchq = aux_cdbanchq
          tel_nrctachq = aux_nrctachq
          tel_cdoperad = aux_cdoperad.

   DISPLAY STREAM str_1  tel_dtemscor  tel_cdbanchq  tel_nrctachq
                         tel_cdoperad  tel_nrinichq  tel_nrfinchq  
                         tel_dshistor  WITH FRAME f_lanctos.
   
   OUTPUT STREAM str_1 CLOSE.

   { includes/impressao.i }

END PROCEDURE.

/* .......................................................................... */
