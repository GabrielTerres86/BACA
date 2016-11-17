/* .............................................................................

   Programa: includes/calcula_smposano.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Henrique
   Data    : Dezembro/2010.                     Ultima atualizacao: 10/01/2011

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Calculo anual dos juros sobre capital.

   Alteracoes: 10/01/2011 - Incluido o total por PAC.
                          - Alterado para exibir tres grupos. De socios ativos,
                            demitidos no ano atual e demitidos. (Henrique)
               
............................................................................. */

DEF TEMP-TABLE cratdir
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapdir.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl 
    FIELD nrmatric LIKE crapass.nrmatric
    FIELD smposano AS   DEC
    FIELD dtdemiss LIKE crapdir.dtdemiss
    FIELD fldemiss AS   INT.
    /* Valores flstatus:        */
    /*  1 - ATIVOS              */
    /*  2 - DEMITIDOS EM 2010   */
    /*  3 - DEMITIDOS           */
                    
    
DEF VAR aux_contador    AS  INT                   NO-UNDO.
DEF VAR aux_smposano    AS  DEC                   NO-UNDO.
DEF VAR aux_dtmvtolt    AS  DATE                  NO-UNDO.
DEF VAR aux_arqimpre    AS  CHAR                  NO-UNDO.
DEF VAR aux_dsstatus    AS  CHAR  FORMAT "x(30)"  NO-UNDO.
DEF VAR aux_cdagenci    AS  INT                   NO-UNDO.

/* ATIVOS */
DEF VAR aux_copativo    AS  LOGI                  NO-UNDO.
DEF VAR aux_qtdativo    AS  INT  LABEL "QTDE"     NO-UNDO.
DEF VAR aux_vlrativo    AS  DEC  LABEL "VALOR"    NO-UNDO.
/* DEMITIDOS EM 2010 */
DEF VAR aux_copdemit    AS  LOGI                  NO-UNDO.
DEF VAR aux_qtddemit    AS  INT  LABEL "QTDE"     NO-UNDO.
DEF VAR aux_vlrdemit    AS  DEC  LABEL "VALOR"    NO-UNDO.
/* DEMITIDOS */
DEF VAR aux_copantig    AS  LOGI                  NO-UNDO.
DEF VAR aux_qtdantig    AS  INT  LABEL "QTDE"     NO-UNDO.
DEF VAR aux_vlrantig    AS  DEC  LABEL "VALOR"    NO-UNDO.
/* TOTAL */
DEF VAR aux_qtdtotal    AS  INT  LABEL "QTDE"     NO-UNDO.
DEF VAR aux_vlrtotal    AS  DEC  LABEL "VALOR"    NO-UNDO.


FORM SKIP(1)
     "                         QTDE                     VALOR"
     SKIP
     "                         ----------- ------------------"
     SKIP
     "                 ATIVOS "
     aux_qtdativo  FORMAT "zzz,zzz,zz9"
     aux_vlrativo  FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP
     "      DEMITIDOS EM 2010 "
     aux_qtddemit FORMAT "zzz,zzz,zz9"
     aux_vlrdemit FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP
     "DEMITIDOS ANTES DE 2010 "
     aux_qtdantig FORMAT "zzz,zzz,zz9"
     aux_vlrantig FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP
     WITH NO-BOX NO-LABEL FRAME f_totalpac.

FORM SKIP (2)
     "TOTAL GERAL => "
     aux_qtdtotal FORMAT "zzz,zzz,zz9"
     aux_vlrtotal FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX SIDE-LABELS FRAME f_totalgeral.

FORM SKIP(1)
     "COOPERADOS" aux_dsstatus
     SKIP(2)
     WITH NO-BOX NO-LABEL FRAME f_dsstatus.

FORM "PAC =>" cratdir.cdagenci
     SKIP(1)
     WITH NO-BOX NO-LABEL FRAME f_cdagenci.

FORM cratdir.nrdconta
     cratdir.nmprimtl FORMAT "x(25)"
     cratdir.nrmatric
     cratdir.smposano FORMAT "zzz,zzz,zzz,zz9.99" LABEL "Sld. Medio"
     cratdir.dtdemiss
     WITH DOWN NO-BOX FRAME f_sldmedio.
     
EMPTY TEMP-TABLE cratdir.

ASSIGN aux_dtmvtolt = DATE (1,1,YEAR(glb_dtmvtolt))
       aux_copativo = TRUE
       aux_copdemit = TRUE
       aux_copantig = TRUE
       aux_qtdtotal = 0
       aux_qtdativo = 0
       aux_qtddemit = 0
       aux_qtdantig = 0
       aux_vlrtotal = 0
       aux_vlrativo = 0
       aux_vlrdemit = 0
       aux_vlrantig = 0.

FOR EACH crapdir WHERE crapdir.cdcooper = glb_cdcooper
                   AND crapdir.dtmvtolt = glb_dtmvtolt
                   NO-LOCK:

    FIND crapass WHERE crapass.cdcooper = crapdir.cdcooper
                           AND crapass.nrdconta = crapdir.nrdconta
                           NO-LOCK NO-ERROR.

    ASSIGN aux_smposano = 0.

    DO  aux_contador = 1 TO 12:        
        ASSIGN aux_smposano = aux_smposano + 
                              crapdir.smposano[aux_contador].
    END.
    
    CREATE cratdir.
    ASSIGN cratdir.cdagenci = crapass.cdagenci
           cratdir.nrdconta = crapdir.nrdconta
           cratdir.nmprimtl = crapass.nmprimtl
           cratdir.nrmatric = crapass.nrmatric
           cratdir.smposano = ROUND(aux_smposano / 12 ,2)
           cratdir.dtdemiss = crapdir.dtdemiss
           cratdir.fldemiss = IF  crapdir.dtdemiss = ? THEN
                                  1
                              ELSE
                              IF  crapdir.dtdemiss >= aux_dtmvtolt THEN
                                  2
                              ELSE
                                  3.      
END. /* Fim for each crapdir */

FOR EACH cratdir BREAK BY cratdir.fldemiss
                       BY cratdir.cdagenci
                       BY cratdir.nrdconta:

    IF cratdir.fldemiss = 1 THEN
       DO:
         IF aux_copativo = TRUE THEN
            DO:
               ASSIGN aux_copativo = FALSE
                      aux_dsstatus = "ATIVOS".
               
               DISP STREAM str_1 aux_dsstatus WITH FRAME f_dsstatus.
            END.
           
         IF cratdir.smposano > 0 THEN
            ASSIGN aux_qtdativo = aux_qtdativo + 1
                   aux_vlrativo = aux_vlrativo + cratdir.smposano.
       END.
    IF cratdir.fldemiss = 2 THEN
       DO:      
         IF aux_copdemit = TRUE THEN
            DO:
               PAGE STREAM str_1.
              
               ASSIGN aux_copdemit = FALSE
                      aux_dsstatus = "DEMITIDOS".
                     
               DISP STREAM str_1 aux_dsstatus WITH FRAME f_dsstatus.
            END.
            
         IF cratdir.smposano > 0 THEN
            ASSIGN aux_qtddemit = aux_qtddemit + 1
                   aux_vlrdemit = aux_vlrdemit + cratdir.smposano.
       END.
    IF cratdir.fldemiss = 3 THEN
       DO:
         IF aux_copantig = TRUE THEN
            DO:
              PAGE STREAM str_1.
             
              ASSIGN aux_copantig = FALSE
                     aux_dsstatus = "DEMITIDOS ANTES DE 2010".
                                      
              DISP STREAM str_1 aux_dsstatus WITH FRAME f_dsstatus.
            END.
              
         IF cratdir.smposano > 0  THEN
            ASSIGN aux_qtdantig = aux_qtdantig + 1
                   aux_vlrantig = aux_vlrantig + cratdir.smposano.

       END.
    
    IF FIRST-OF(cratdir.cdagenci) THEN
    DO:
        PAGE STREAM str_1.
        
        DISP STREAM str_1 cratdir.cdagenci WITH FRAME f_cdagenci.
    END.

    DISP STREAM str_1 cratdir.nrdconta
                      cratdir.nmprimtl
                      cratdir.nrmatric
                      cratdir.smposano
                      cratdir.dtdemiss
                      WITH FRAME f_sldmedio.
                      
    DOWN STREAM str_1 WITH FRAME f_sldmedio.

    IF LAST-OF(cratdir.cdagenci) THEN
       DO:
          DISP STREAM str_1 aux_qtdativo aux_vlrativo
                            aux_qtddemit aux_vlrdemit
                            aux_qtdantig aux_vlrantig
                            WITH FRAME f_totalpac.
                            
          ASSIGN aux_qtdativo = 0
                 aux_vlrativo = 0
                 aux_qtddemit = 0
                 aux_vlrdemit = 0
                 aux_qtdantig = 0
                 aux_vlrantig = 0.
       END.

    
END. /* Fim for each cratdir */

DISP STREAM str_1 aux_qtdtotal aux_vlrtotal WITH FRAME f_totalgeral.

OUTPUT STREAM str_1 CLOSE.
