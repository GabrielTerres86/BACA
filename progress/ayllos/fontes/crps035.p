/* ..........................................................................

   Programa: Fontes/crps035.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                        Ultima Atualizacao: 10/06/2009

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 022
               Listar os associados por empresa (rel. 034) conforme solicitacao.

   Alteracao : 05/04/95 - Alterado para listar relatorios quando dsparame =
                          1 3, 2 2, 2 3, 3 2  e 3 3 (Odair).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               11/02/2000 - Gerar pedido de impressao (Deborah). 

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               16/01/2009 - Alteracao cdempres (Diego).
               
               10/06/2009 - Corrigido SUBSTRING da variavel glb_dsparame
                            devido o aumento do campo cdempres (Diego).
               
............................................................................. */

DEF STREAM str_1.     /*  Para listagem de associados por empresa */

{ includes/var_batch.i "NEW" }

DEF        VAR rel_cdagenci AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_nrdconta AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_nrmatric AS INT     EXTENT 2                      NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR    EXTENT 2                      NO-UNDO.

DEF        VAR rel_cdempres AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_tprelato AS CHAR    FORMAT "x(60)"                NO-UNDO.

DEF        VAR rel_qtdassoc AS INT     FORMAT "zzz,zz9"              NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(11)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    EXTENT 5
                                       FORMAT "x(40)"                NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF       VAR aux_nmarqimp AS CHAR     FORMAT "x(20)" EXTENT 99      NO-UNDO.
DEF       VAR aux_nrdevias AS INT      FORMAT "z9"    EXTENT 99      NO-UNDO.

DEF       VAR aux_nrdlinha AS INT      FORMAT "z9"                   NO-UNDO.
DEF       VAR aux_contador AS INT      FORMAT "z9"                   NO-UNDO.
DEF       VAR aux_contaarq AS INT      FORMAT "z9"                   NO-UNDO.
DEF       VAR aux_nrpagina AS INT      FORMAT "zzzz9"                NO-UNDO.
DEF       VAR aux_qtassemp AS INT      FORMAT "zzz,zz9"              NO-UNDO.
DEF       VAR aux_cdempres AS INT      FORMAT "zzzz9"                NO-UNDO.
DEF       VAR aux_cdempres_2 AS INT                                  NO-UNDO.

DEF       VAR aux_regexist AS LOGICAL                                NO-UNDO.

glb_cdprogra = "crps035".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     DO:
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" +
                             glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.

FORM "EMPRESA:"       AT   1
     rel_cdempres     AT  10 
     "-"              AT  16
     rel_nmresemp     AT  18 FORMAT "x(15)"
     rel_tprelato     AT  35 FORMAT "x(60)"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_empresa.

FORM "QUANTIDADE DE ASSOCIADOS:" AT 2
     rel_qtdassoc   AT 28 FORMAT "zzz,zz9"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 132 FRAME f_qtdassoc.

FORM rel_cdagenci[1] FORMAT "zzz"        LABEL "AG."      AT 2
     rel_nrdconta[1] FORMAT "zzzz,zzz,z" LABEL "CTA/CAD"  AT 6
     rel_nrmatric[1] FORMAT "zzz,zzz"    LABEL "MATRIC."  AT 17
     rel_nmprimtl[1] FORMAT "x(40)"      LABEL "TITULAR"  AT 26
     rel_cdagenci[2] FORMAT "zzz"        LABEL "AG."      AT 69
     rel_nrdconta[2] FORMAT "zzzz,zzz,z" LABEL "CTA/CAD"  AT 73
     rel_nrmatric[2] FORMAT "zzz,zzz"    LABEL "MATRIC."  AT 84
     rel_nmprimtl[2] FORMAT "x(40)"      LABEL "TITULAR"  AT 93
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_associados.

aux_regexist = FALSE.

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                       crapsol.dtrefere = glb_dtmvtolt   AND
                       crapsol.nrsolici = 22             AND
                       crapsol.insitsol = 1
                       TRANSACTION ON ERROR UNDO, RETRY:

    ASSIGN glb_nrdevias = crapsol.nrdevias
           glb_dsparame = crapsol.dsparame
           glb_cdempres = 11.

    { includes/cabrel132_1.i }             /* Monta cabecalho do relatorio */

    ASSIGN aux_regexist = TRUE
           rel_qtdassoc = 0
           aux_contador = 0
           aux_qtassemp = 0

           aux_contaarq = aux_contaarq + 1
           aux_nmarqimp[aux_contaarq] = "rl/crrl034_" +
                                        STRING(crapsol.nrseqsol,"99") + ".lst"
           aux_nrdevias[aux_contaarq] = crapsol.nrdevias.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp[aux_contaarq]) PAGED PAGE-SIZE 84.

    ASSIGN aux_cdempres = INTEGER(SUBSTRING(glb_dsparame,1,5))
           rel_cdempres = aux_cdempres
           rel_nmresemp = FILL("*",15)
           rel_tprelato = IF SUBSTRING(glb_dsparame,9,1) = "1"
                             THEN "(TODOS OS ASSOCIADOS)"
                             ELSE IF SUBSTRING(glb_dsparame,9,1) = "2"
                                     THEN "(SOMENTE OS ATIVOS)"
                                     ELSE IF SUBSTRING(glb_dsparame,9,1) = "3"
                                             THEN "(SOMENTE OS INATIVOS)"
                                             ELSE ""
           rel_tprelato = rel_tprelato + "   " +
                          IF   SUBSTR(glb_dsparame,7,1) = "1"
                               THEN "ORDEM ALFABETICA"        ELSE
                          IF   SUBSTR(glb_dsparame,7,1) = "2"
                               THEN "ORDEM DE CONTA"          ELSE
                          IF   SUBSTR(glb_dsparame,7,1) = "3"
                               THEN "ORDEM DE CADASTRO"       ELSE
                               "".

    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper  AND
                       crapemp.cdempres = aux_cdempres  NO-LOCK NO-ERROR.

    IF   AVAILABLE crapemp   THEN
         rel_nmresemp = crapemp.nmresemp.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    DISPLAY STREAM str_1 rel_cdempres rel_nmresemp rel_tprelato
            WITH FRAME f_empresa.
    
    { includes/crps035.i } 
    
    OUTPUT STREAM str_1 CLOSE.

    ASSIGN  glb_nrcopias = 1
            glb_nmformul = ""
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
                             glb_dscritic + " - 022"
                             + " >> log/proc_batch.log").
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */

