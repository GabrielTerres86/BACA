/* .............................................................................

   Programa: Includes/listaint.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/92.                           Ultima atualizacao: 08/06/2009
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Listar os arquivos a serem integrados nas telas de solicitacao.

   Alteracoes: 19/03/98 - Tratamento para milenio e troca para V8 - (Margarete).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               28/06/2006 - Limpar o frame antes de listar os arquivos (Julio) 
               
               23/01/2009 - Alteracao cdempres (Diego).
               
               08/06/2009 - Corrigido tratamento do campo cdempres (Diego).
               
............................................................................. */

DEF        VAR tab_nmempres AS CHAR    FORMAT "x(20)"      EXTENT 10   NO-UNDO.
DEF        VAR tab_dtrefere AS DATE    FORMAT "99/99/99"   EXTENT 10   NO-UNDO.
DEF        VAR tab_ddcredit AS CHAR    FORMAT "x(2)"       EXTENT 10   NO-UNDO.

DEF        VAR aux_nmarqint AS CHAR    FORMAT "x(60)"                  NO-UNDO.
DEF        VAR aux_dstitulo AS CHAR                                    NO-UNDO.
DEF        VAR aux_cdempres AS INT                                     NO-UNDO.

FORM tab_nmempres[aux_contador] LABEL "Empresa"
     tab_dtrefere[aux_contador] LABEL "Referente"
     tab_ddcredit[aux_contador] LABEL "DL"
     WITH ROW 7 COLUMN 45 OVERLAY 10 DOWN
          TITLE COLOR MESSAGE aux_dstitulo FRAME f_integra.

ASSIGN tab_nmempres = ""
       tab_dtrefere = ?
       tab_ddcredit = "".

DO aux_contador = 1 TO 10:

   DISPLAY tab_nmempres[aux_contador]  tab_dtrefere[aux_contador]
           tab_ddcredit[aux_contador]  WITH FRAME f_integra.
   DOWN WITH FRAME f_integra.

END.  /*  Fim do DO .. TO  */

PAUSE 0.

IF   aux_tpintegr = "f"   THEN
     aux_dstitulo = " Folhas a Integrar ".
ELSE
     IF   aux_tpintegr = "e"   THEN
          aux_dstitulo = " Emprestimos a Integrar ".
     ELSE
          IF   aux_tpintegr = "c"   THEN
               aux_dstitulo = " Planos de Cotas a Integrar ".
          ELSE
               IF   aux_tpintegr = "s"   THEN
                    aux_dstitulo = " Cheques Salario a Integrar ".
               ELSE
                    IF   aux_tpintegr = "p"   THEN
                         aux_dstitulo = " Cheques Salario a Emitir ".
                    ELSE
                         aux_dstitulo = "".

aux_contador = 0.

INPUT THROUGH ls integra NO-ECHO.

REPEAT:
   
   SET aux_nmarqint WITH NO-BOX NO-LABELS FRAME f_ls.
   
   IF   SUBSTRING(aux_nmarqint,1,1) <> aux_tpintegr   THEN
        NEXT.
        
   IF   SUBSTRING(aux_nmarqint,1,3) = "err"           THEN
        NEXT.

   aux_contador = aux_contador + 1.

   IF   aux_contador > 10   THEN
        DO:
            DO aux_contador = 1 TO 10:

               DISPLAY tab_nmempres[aux_contador]  tab_dtrefere[aux_contador]
                       tab_ddcredit[aux_contador]
                       WITH FRAME f_integra.

               DOWN WITH FRAME f_integra.

            END.  /*  Fim do DO .. TO  */

            BELL.
            PAUSE MESSAGE "Tecle <Entra> para continuar ou <Fim> para encerrar".

            ASSIGN tab_nmempres = ""
                   tab_dtrefere = ?
                   tab_ddcredit = "".
                   aux_contador = 1.
        END.

   IF   aux_tpintegr = "f"  THEN
        DO:
            IF   LENGTH(aux_nmarqint) > 14  THEN  /* cdempres 99999 */ 
                 ASSIGN
                 aux_cdempres               = INTEGER(SUBSTR(aux_nmarqint,02,5))
                 tab_dtrefere[aux_contador] = DATE(
                                             INTEGER(SUBSTR(aux_nmarqint,9,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,7,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,11,4)))
                 tab_ddcredit[aux_contador] = SUBSTR(aux_nmarqint,16,2).
            ELSE
                 ASSIGN 
                 aux_cdempres               = INTEGER(SUBSTR(aux_nmarqint,02,2))
                 tab_dtrefere[aux_contador] = DATE(
                                             INTEGER(SUBSTR(aux_nmarqint,6,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,4,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,8,4)))
                 tab_ddcredit[aux_contador] = SUBSTR(aux_nmarqint,13,2).
        END.
   ELSE
   IF   aux_tpintegr = "e"  THEN
        DO:
            IF   LENGTH(aux_nmarqint) > 11  THEN  /* cdempres 99999 */
                 ASSIGN 
                 aux_cdempres               = INTEGER(SUBSTR(aux_nmarqint,02,5))
                 tab_dtrefere[aux_contador] = DATE(
                                             INTEGER(SUBSTR(aux_nmarqint,9,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,7,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,11,4)))
                 tab_ddcredit[aux_contador] = "".
            ELSE
                 ASSIGN
                 aux_cdempres               = INTEGER(SUBSTR(aux_nmarqint,02,2))
                 tab_dtrefere[aux_contador] = DATE(
                                             INTEGER(SUBSTR(aux_nmarqint,6,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,4,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,8,4)))
                 tab_ddcredit[aux_contador] = "".
        END.
   ELSE
        ASSIGN
        aux_cdempres               = INTEGER(SUBSTR(aux_nmarqint,02,5))
        tab_dtrefere[aux_contador] = DATE(INTEGER(SUBSTR(aux_nmarqint,9,2)),
                                          INTEGER(SUBSTR(aux_nmarqint,7,2)),
                                          INTEGER(SUBSTR(aux_nmarqint,11,4)))
        tab_ddcredit[aux_contador] = SUBSTR(aux_nmarqint,16,2).
   
   FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper   AND
                      crapemp.cdempres = aux_cdempres   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapemp   THEN
        tab_nmempres[aux_contador] = STRING(aux_cdempres,"99999") + " - " +
                                     FILL("*",15).
   ELSE
        tab_nmempres[aux_contador] = STRING(aux_cdempres,"99999") + " - " +
                                     crapemp.nmresemp.

END.     /*  Fim do REPEAT  */

IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN
     IF   tab_nmempres[1] <> ""   THEN
          DO aux_contador = 1 TO 10:

             DISPLAY tab_nmempres[aux_contador] tab_dtrefere[aux_contador]
                     tab_ddcredit[aux_contador]
                     WITH FRAME f_integra.

             DOWN WITH FRAME f_integra.

          END.  /*  Fim do DO .. TO  */
     ELSE
          DO:
              BELL.
              MESSAGE "Nao existem arquivos para serem integrados ao sistema!".
          END.

INPUT CLOSE.

/* .......................................................................... */

