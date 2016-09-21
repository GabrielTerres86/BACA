/* ..........................................................................

   Programa: Fontes/crps017.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                      Ultima atualizacao: 08/01/2008

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 012.
               Emite relatorio com todas as tabelas do sistema (22).
               
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               08/01/2008 - Colocado format no campo tpregist(Guilherme).

............................................................................. */

DEF STREAM str_1.     /*  Para relatorio com todas as tabelas do sistema  */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    EXTENT 2
                                       INIT ["rl/crrl022.lst",""]    NO-UNDO.

DEF        VAR aux_nmformul AS CHAR    EXTENT 2
                                       INIT ["",""]                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.

glb_cdprogra = "crps017".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

ASSIGN aux_regexist = FALSE
       aux_flgfirst = TRUE.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 12            AND
                       crapsol.insitsol = 1 
                       TRANSACTION ON ERROR UNDO, RETRY:

    glb_nrdevias = crapsol.nrdevias.

    { includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

    aux_regexist = TRUE.

    IF   aux_flgfirst   THEN
         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[1]) PAGED PAGE-SIZE 84.
    ELSE
         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[1])
                       APPEND PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper NO-LOCK 
                           BREAK BY craptab.nmsistem 
                                    BY craptab.tptabela
                                       BY craptab.cdempres 
                                          BY craptab.cdacesso
                                             BY craptab.tpregist:

        DISPLAY STREAM str_1 craptab.nmsistem  
                             craptab.tptabela  
                             craptab.cdempres
                             craptab.cdacesso  
                             craptab.tpregist FORMAT "zzzzz9"
                             craptab.dstextab
                             WITH WIDTH 132 DOWN FRAME f_tabelas.

        IF   LAST-OF(craptab.cdacesso)   THEN
             IF  (LINE-COUNTER(str_1) + 2) <= PAGE-SIZE(str_1)   THEN
                  DO:
                      DOWN STREAM str_1 2 WITH FRAME f_tabelas.
                      NEXT.
                  END.
             ELSE
                  DO:
                      PAGE STREAM str_1.
                      NEXT.
                  END.
        ELSE
             DOWN STREAM str_1 WITH FRAME f_tabelas.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             PAGE STREAM str_1.

    END.

    ASSIGN aux_flgfirst     = FALSE
           crapsol.insitsol = 2.

    OUTPUT STREAM str_1 CLOSE.

END.

RUN fontes/fimprg.p.

IF   glb_cdcritic > 0   THEN
     RETURN.

DO  aux_contador = 1 TO 1:

    ASSIGN glb_nmarqimp = aux_nmarqimp[aux_contador]
           glb_nmformul = aux_nmformul[aux_contador]
           glb_nrcopias = 1.

    RUN fontes/imprim.p.

END.

/* .......................................................................... */

