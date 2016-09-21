/* .............................................................................

   Programa: Fontes/imptax.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/2000

   Dados referentes ao programa:                 Ultima Alteracao: 29/05/2014

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPTAX.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               19/01/2007 - Modificado o formato das variaveis do tipo DATE de
                            "99/99/99"  para "99/99/9999" (Elton).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
............................................................................. */

DEF STREAM str_1.     /*  Para taxas do RDCA e RDCA 60  */

{ includes/var_online.i }

DEF TEMP-TABLE crawtax                                               NO-UNDO
         FIELD dtaplica         AS DATE    FORMAT "99/99/9999"
         FIELD dtresgat         AS DATE    FORMAT "99/99/9999"
         FIELD qtdiaute         AS INT     FORMAT "z9"
         FIELD tpaplica         AS INT     FORMAT "9"
         FIELD txaplica         AS DECIMAL DECIMALS 8 FORMAT "zz9.999999"
         FIELD vlfaixas         AS DECIMAL FORMAT "zzz,zz9"
         FIELD indespec         AS INT     FORMAT "9".

DEF        VAR rel_nmresage     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.

DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dtaplica AS DATE    FORMAT "99/99/9999"   EXTENT 3  NO-UNDO.
DEF        VAR rel_dtresgat AS DATE    FORMAT "99/99/9999"   EXTENT 3  NO-UNDO.
DEF        VAR rel_qtdiaute AS INT     FORMAT "z9"           EXTENT 3  NO-UNDO.
DEF        VAR rel_txaplica AS DECIMAL FORMAT "zz9.999999"   EXTENT 3  NO-UNDO.
DEF        VAR rel_vlfaixas AS DECIMAL FORMAT "zzz,zz9"      EXTENT 3  NO-UNDO.

DEF        VAR rel_indespec AS CHAR    FORMAT "x(01)"                NO-UNDO.

DEF        VAR aux_qtdiaute AS INT                                   NO-UNDO.
DEF        VAR aux_nrmesant AS INT                                   NO-UNDO.
DEF        VAR aux_vlfaixas AS DECIMAL                               NO-UNDO.

DEF        VAR tel_dtiniper AS DATE                                  NO-UNDO.
DEF        VAR tel_dtfimper AS DATE                                  NO-UNDO.

DEF        VAR aux_dtresgat AS DATE                                  NO-UNDO.
DEF        VAR aux_dtaplica AS DATE                                  NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

DEF        VAR par_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

FORM SKIP(2)
     "APLICACOES POUPANCA PROGRAMADA"  AT 4
     "APLICACOES RDCA"                 AT 57
     "APLICACOES RDCA 60 E 30 ESPECIAL (*)" AT 93
     SKIP(1)
     "DE          ATE        DIAS       TAXA"          AT  1
     "DE          ATE        DIAS       TAXA"          AT 45
     "DE         ATE          FAIXA DIAS       TAXA"   AT 88
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_titulo.

FORM rel_dtaplica[1] AT  1
     rel_dtresgat[1] AT 13
     rel_qtdiaute[1] AT 26
     rel_txaplica[1] AT 29
     rel_dtaplica[2] AT 45
     rel_dtresgat[2] AT 57
     rel_qtdiaute[2] AT 70
     rel_txaplica[2] AT 73
     rel_indespec    AT 86 
     rel_dtaplica[3] AT 88
     rel_dtresgat[3] AT 99
     rel_vlfaixas[3] AT 110
     rel_qtdiaute[3] AT 120
     rel_txaplica[3] AT 123
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_taxas.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (4)
     tel_dtiniper LABEL "Data inicial" AT 13 FORMAT "99/99/9999"
     HELP "Entre com a data inicial para listar taxas."
     SKIP(2)
     tel_dtfimper LABEL "Data final"   AT 15   FORMAT "99/99/9999"
     HELP "Entre com data final para listar taxas. Maximo 60 dias a mais."
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_datas.

/* Leitura da tabela com valor da faixa de RDCA 30 Especial */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "VLREFERDCA"  AND
                   craptab.tpregist = 001 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 596.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         glb_cdcritic = 0.
         RETURN.
     END.

ASSIGN aux_vlfaixas = DECIMAL(craptab.dstextab).

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "@"
       glb_cdcritic = 0
       glb_nrdevias = 0
       par_flgfirst = TRUE
       par_flgrodar = TRUE.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN par_flgcance = FALSE

       glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 108.

{ includes/cabrel132_1.i }

DO WHILE TRUE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
         END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "IMPTAX"   THEN
                 DO:
                     HIDE FRAME f_datas.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_dtiniper tel_dtfimper WITH FRAME f_datas.
                
      LEAVE.
   END. 

   aux_regexist = FALSE.   

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
        END.
   
   /* Limpa dados da estrutura auxiliar */

   /*FOR EACH crawtax TRANSACTION:
       DELETE crawtax.
   END.*/
   EMPTY TEMP-TABLE crawtax.
               
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        NEXT.

   IF   glb_flgescra THEN
        DO:
            glb_cdcritic = 685.
            NEXT.
        END.
/*            
   IF   ((tel_dtfimper - tel_dtiniper) > 62 ) OR tel_dtfimper < tel_dtiniper
        THEN
        DO:
            glb_cdcritic = 13.
            NEXT-PROMPT tel_dtfimper WITH FRAME f_datas.
            NEXT.
        END.
*/
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE.
                  
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S" THEN
        DO:
            ASSIGN glb_cdcritic = 79.
            NEXT.
        END.

   FOR EACH craptrd WHERE craptrd.cdcooper  = glb_cdcooper AND
                          craptrd.dtiniper >= tel_dtiniper AND
                          craptrd.dtiniper <= tel_dtfimper NO-LOCK:

       aux_regexist = TRUE.

       IF   craptrd.tptaxrda = 1  AND      /* rdca */
            craptrd.txofimes > 0  THEN
            DO:
                CREATE crawtax.
                ASSIGN crawtax.dtaplica = craptrd.dtiniper
                       crawtax.dtresgat = craptrd.dtfimper
                       crawtax.qtdiaute = craptrd.qtdiaute
                       crawtax.txaplica = craptrd.txofimes
                       crawtax.tpaplica = 2
                       crawtax.indespec = 0.
            END.
       ELSE
       IF   craptrd.tptaxrda = 2 AND craptrd.txofimes > 0 THEN /* poupanca */
            DO:
                CREATE crawtax.
                ASSIGN crawtax.dtaplica = craptrd.dtiniper
                       crawtax.dtresgat = craptrd.dtfimper
                       crawtax.qtdiaute = craptrd.qtdiaute
                       crawtax.txaplica = craptrd.txofimes
                       crawtax.tpaplica = 1
                       crawtax.indespec = 0.
            END.
       ELSE     
       IF   craptrd.tptaxrda = 3   AND   craptrd.incarenc = 0  AND
            craptrd.txofimes > 0   THEN
            DO:
                CREATE crawtax.
                ASSIGN crawtax.dtaplica = craptrd.dtiniper
                       crawtax.dtresgat = craptrd.dtfimper
                       crawtax.qtdiaute = craptrd.qtdiaute
                       crawtax.txaplica = craptrd.txofimes
                       crawtax.vlfaixas = craptrd.vlfaixas
                       crawtax.tpaplica = 3
                       crawtax.indespec = 0.
            END.
       ELSE
       IF   craptrd.tptaxrda = 6   AND   craptrd.incarenc = 0   AND
            craptrd.txofimes > 0   THEN
            DO:
                CREATE crawtax.
                ASSIGN crawtax.dtaplica = craptrd.dtiniper
                       crawtax.dtresgat = craptrd.dtfimper
                       crawtax.qtdiaute = craptrd.qtdiaute
                       crawtax.txaplica = craptrd.txofimes
                       crawtax.vlfaixas = aux_vlfaixas
                       crawtax.tpaplica = 3
                       crawtax.indespec = 1.
            END.

   END.  /*  Fim do FOR EACH -- craptrd  */

   HIDE MESSAGE  NO-PAUSE.

   IF   NOT aux_regexist THEN
        DO:
            glb_cdcritic = 11.
            NEXT.
        END.

   INPUT THROUGH basename `tty` NO-ECHO.

     SET aux_nmendter WITH FRAME f_terminal.

   INPUT CLOSE.
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.

   UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

      aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 82.

   /*  Configura a impressora para 1/8"  */

   PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

   PUT STREAM str_1 CONTROL "\0330\033x0\033\017" NULL.
   
   VIEW STREAM str_1 FRAME f_cabrel132_1.

   VIEW STREAM str_1 FRAME f_titulo.

   FOR EACH crawtax BREAK BY crawtax.dtaplica
                          BY crawtax.tpaplica
                             BY crawtax.indespec
                                BY crawtax.vlfaixas:

       ASSIGN rel_dtaplica[crawtax.tpaplica] = crawtax.dtaplica
              rel_dtresgat[crawtax.tpaplica] = crawtax.dtresgat
              rel_qtdiaute[crawtax.tpaplica] = crawtax.qtdiaute
              rel_txaplica[crawtax.tpaplica] = crawtax.txaplica
              rel_vlfaixas[crawtax.tpaplica] = crawtax.vlfaixas
              rel_indespec                   = IF   crawtax.indespec = 0
                                                 THEN " "
                                                 ELSE "*".
       IF   crawtax.tpaplica = 3        OR
            LAST-OF(crawtax.dtaplica)   THEN
            DO:
                DISPLAY STREAM str_1
                        rel_dtaplica[1] rel_dtresgat[1]
                        rel_qtdiaute[1] WHEN rel_qtdiaute[1] > 0
                        rel_txaplica[1] WHEN rel_txaplica[1] > 0
                        rel_indespec
                        rel_dtaplica[2]      rel_dtresgat[2]
                        rel_qtdiaute[2] WHEN rel_qtdiaute[2] > 0
                        rel_txaplica[2] WHEN rel_txaplica[2] > 0
                        rel_dtaplica[3] rel_dtresgat[3]
                        rel_vlfaixas[3] WHEN rel_txaplica[3] > 0
                        rel_qtdiaute[3] WHEN rel_qtdiaute[3] > 0
                        rel_txaplica[3] WHEN rel_txaplica[3] > 0
                        
                        WITH FRAME f_taxas.

                IF  (rel_dtaplica[2] <> ?    AND   rel_dtaplica[3] =  ?)   THEN
                     IF   MONTH(rel_dtaplica[1] + 1) <> MONTH(rel_dtaplica[1])
                          THEN
                          DOWN STREAM str_1 2 WITH FRAME f_taxas.
                     ELSE
                          DOWN STREAM str_1 WITH FRAME f_taxas.
                ELSE
                IF ((rel_dtaplica[2] =  ?    AND   rel_dtaplica[3] <> ?)   OR
                    (rel_dtaplica[2] <> ?    AND   rel_dtaplica[3] <> ?))  AND
                     LAST-OF(crawtax.dtaplica)                             THEN
                     IF   MONTH(rel_dtaplica[3] + 1) <> MONTH(rel_dtaplica[3]) 
                          THEN
                          DOWN STREAM str_1 2 WITH FRAME f_taxas.
                     ELSE
                          DOWN STREAM str_1 WITH FRAME f_taxas.
                ELSE
                     DOWN STREAM str_1 WITH FRAME f_taxas.

                IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                     DO:
                         PAGE STREAM str_1.
                         VIEW STREAM str_1 FRAME f_titulo.
                     END.

                ASSIGN rel_dtaplica = ?
                       rel_dtresgat = ?
                       rel_qtdiaute = 0
                       rel_txaplica = 0
                       rel_vlfaixas = 0.
            END.

   END.  /*  Fim do FOR EACH  */

   PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

   OUTPUT STREAM str_1 CLOSE.

    /* cambalhacho para rotina impressao acessar ass */
  
   FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapass THEN
        NEXT.
   
   { includes/impressao.i } 
    
END.

/* ......................................................................... */

