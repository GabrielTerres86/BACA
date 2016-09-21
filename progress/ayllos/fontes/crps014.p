/* ..........................................................................

   Programa: Fontes/crps014.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                        Ultima atualizacao: 16/01/2009

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 010
               Listar os associados conforme solicitacao (18).


   Alteracoes: 22/04/98 - Tratar milenio e V8 (Odair)

               02/03/2001 - Liberar a rotina de relatorio geral, em ordem
                            alfabetica, dos ativos (Deborah).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               16/01/2009 - Alteracao cdempres (Diego).
               
............................................................................. */

DEF STREAM str_1.     /*  Para listagem de associados  */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_nrdconta AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_nrmatric AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_cdsitdct AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_cdtipcta AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_indnivel AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR    EXTENT 2                      NO-UNDO.

DEF        VAR rel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR rel_nmresage AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nrseqage AS INT     FORMAT "zzzz9"                NO-UNDO.

DEF        VAR rel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nrseqemp AS INT     FORMAT "zzzz9"                NO-UNDO.

DEF        VAR rel_qtdassoc AS INT     FORMAT "zzz,zz9"              NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(11)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    EXTENT 5
                                       FORMAT "x(40)"                NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["DEP. A VISTA   ",
                                             "CAPITAL        ",
                                             "EMPRESTIMOS    ",
                                             "DIGITACAO      ",
                                             "GENERICO       "]      NO-UNDO.

DEF       VAR aux_nmarqimp AS CHAR     FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF       VAR aux_nrdevias AS INT      FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF       VAR aux_nrdlinha AS INT      FORMAT "z9"                   NO-UNDO.
DEF       VAR aux_contador AS INT      FORMAT "z9"                   NO-UNDO.
DEF       VAR aux_contaarq AS INT      FORMAT "z9"                   NO-UNDO.
DEF       VAR aux_nrpagina AS INT      FORMAT "zzzz9"                NO-UNDO.
DEF       VAR aux_qtassage AS INT      FORMAT "zzz,zz9"              NO-UNDO.
DEF       VAR aux_qtassemp AS INT      FORMAT "zzz,zz9"              NO-UNDO.
DEF       VAR aux_qtassger AS INT      FORMAT "zzz,zz9"              NO-UNDO.

DEF       VAR aux_flgfirst AS LOGICAL                                NO-UNDO.
DEF       VAR aux_regexist AS LOGICAL                                NO-UNDO.

DEF  TEMP-TABLE tt-crapass       NO-UNDO
     FIELD cdcooper              LIKE crapass.cdcooper
     FIELD nrdconta              LIKE crapass.nrdconta
     FIELD cdempres              AS INT
     INDEX tt-crapass1   AS PRIMARY UNIQUE
           cdcooper
           nrdconta.

glb_cdprogra = "crps014".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     DO:
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" +
                             glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

FORM "AGENCIA:"       AT   1
     rel_cdagenci     AT   9 FORMAT "zz9"
     "-"              AT  13
     rel_nmresage     AT  15 FORMAT "x(15)"
     "SEQ.:"          AT 123
     rel_nrseqage     AT 128 FORMAT "zzzz9"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_agencia.

FORM "EMPRESA:"       AT   1
     rel_cdempres     AT  10 
     "-"              AT  16
     rel_nmresemp     AT  18 FORMAT "x(15)"
     "SEQ.:"          AT 123
     rel_nrseqemp     AT 128 FORMAT "zzzz9"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_empresa.

FORM "QUANTIDADE DE ASSOCIADOS      :"
     rel_qtdassoc   FORMAT "zzz,zz9"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_qtdassoc.

FORM "QUANTIDADE TOTAL DE ASSOCIADOS:"
     rel_qtdassoc   FORMAT "zzz,zz9"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_qtgassoc.

FORM rel_nrdconta[1] FORMAT "zzzz,zzz,z" LABEL "CONTA/DV"
     rel_nrmatric[1] FORMAT "zzz,zzz"    LABEL "MATRIC."
     rel_cdsitdct[1] FORMAT "z"          LABEL "S"
     rel_cdtipcta[1] FORMAT "zz"         LABEL " T"
     rel_indnivel[1] FORMAT "z"          LABEL "N"
     rel_nmprimtl[1] FORMAT "x(40)"      LABEL "TITULAR"
     rel_nrdconta[2] FORMAT "zzzz,zzz,z" LABEL "CONTA/DV"
     rel_nrmatric[2] FORMAT "zzz,zzz"    LABEL "MATRIC."
     rel_cdsitdct[2] FORMAT "z"          LABEL "S"
     rel_cdtipcta[2] FORMAT "zz"         LABEL " T"
     rel_indnivel[2] FORMAT "z"          LABEL "N"
     rel_nmprimtl[2] FORMAT "x(39)"      LABEL "TITULAR"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_associados.

ASSIGN aux_regexist = FALSE
       aux_flgfirst = TRUE.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 10            AND
                       crapsol.insitsol = 1
                       TRANSACTION ON ERROR UNDO, RETRY:

    ASSIGN glb_nrdevias = crapsol.nrdevias
           glb_dsparame = crapsol.dsparame
           glb_cdempres = 11.

    { includes/cabrel132_1.i }             /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist               = TRUE
           rel_nrseqage               = 0
           rel_nrseqemp               = 0
           rel_qtdassoc               = 0
           aux_contador               = 0 
           aux_qtassage               = 0
           aux_qtassemp               = 0
           aux_qtassger               = 0

           aux_contaarq               = aux_contaarq + 1
           aux_nmarqimp[aux_contaarq] = "rl/crrl018_" +
                                        STRING(crapsol.nrseqsol,"99") + ".lst"
           aux_nrdevias[aux_contaarq] = crapsol.nrdevias.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[aux_contaarq]) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    {includes/crps014.i }                  

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN glb_nrcopias = crapsol.nrdevias
           glb_nmformul = "132dm"
           glb_nmarqimp = aux_nmarqimp[aux_contaarq].
        
    RUN fontes/imprim.p.

    crapsol.insitsol = 2. 

END.  /*  Fim do FOR EACH  --  Leitura das solicitacoes  */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.

         UNIX SILENT VALUE ("echo " +
                             STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" +
                             glb_dscritic + " - SOL010"
                             + " >> log/proc_batch.log").
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */

