/* .............................................................................

   Programa: Fontes/tab028.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                        Ultima alteracao: 01/02/2006

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB028 - Tarifas Pre-Deposito.     
   
   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
............................................................................. */

{ includes/var_online.i }


DEF        VAR tel_dtcobpdp AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_vllimdoc AS DECIMAL FORMAT "zzzzz9.99"            NO-UNDO.
DEF        VAR tel_vlpercen AS DECIMAL FORMAT "zz9.9999"             NO-UNDO.

DEF        VAR aux_dia      AS INTE                                  NO-UNDO.
DEF        VAR aux_mes      AS INTE                                  NO-UNDO.
DEF        VAR aux_ano      AS INTE                                  NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

FORM SKIP(3)
     glb_cddopcao AT 15 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(2)
     tel_dtcobpdp AT 28 LABEL "Data Pre-Deposito  "
                        HELP "Data Inicial a ser gerada a tarifacao"
     SKIP(1)
     tel_vllimdoc AT 28 LABEL "Valor   "     
            HELP "Valor Inicial a ser gerada a  tarifacao"
     SKIP(1)
     tel_vlpercen AT 28 LABEL "Percentual"                   
               HELP "Percentual que sera utilizado p/calculo da tarifa " 
     SKIP(5)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab028.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_tab028 NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab028.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab028"   THEN
                 DO:
                     HIDE FRAME f_tab028.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO TRANSACTION ON ERROR UNDO, NEXT:
           
           DO WHILE TRUE:
          
              FIND craptab WHERE 
                   craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "PREDEPOSIT"  AND
                   craptab.tpregist = 1  
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 55.
                            LEAVE.
                        END.
              
              LEAVE.
              
           END.  /*  Fim do DO WHILE TRUE  */
           
           IF   glb_cdcritic > 0   THEN
                NEXT.

           ASSIGN tel_dtcobpdp = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                                      INT(SUBSTRING(craptab.dstextab,1,2)),
                                      INT(SUBSTRING(craptab.dstextab,7,4)))
                  tel_vllimdoc = DECIMAL(SUBSTRING(craptab.dstextab,21,9))
                  tel_vlpercen = DECIMAL(SUBSTRING(craptab.dstextab,12,8)).

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
              UPDATE tel_dtcobpdp
                     tel_vllimdoc
                     tel_vlpercen
                     WITH FRAME f_tab028.

              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                 aux_confirma = "N".

                 glb_cdcritic = 78.
                 RUN fontes/critic.p.
                 BELL.
                 glb_cdcritic = 0.
                 MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                 LEAVE.

              END.

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                   aux_confirma <> "S" THEN
                   DO:
                       glb_cdcritic = 79.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                   END.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */
       
           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                NEXT.

           ASSIGN aux_dia = DAY(tel_dtcobpdp)
                  aux_mes = MONTH(tel_dtcobpdp)
                  aux_ano = YEAR(tel_dtcobpdp).
                  
           ASSIGN SUBSTR(craptab.dstextab,1,2) = STRING(aux_dia,"99")
                  SUBSTR(craptab.dstextab,3,1) = "/"
                  SUBSTR(craptab.dstextab,4,2) = STRING(aux_mes,"99")
                  SUBSTR(craptab.dstextab,6,1) = "/"
                  SUBSTR(craptab.dstextab,7,4) = STRING(aux_ano,"9999")
                  SUBSTR(craptab.dstextab,21,9) =
                         STRING(tel_vllimdoc,"999999.99")             
                  SUBSTR(craptab.dstextab,12,8) = 
                         STRING(tel_vlpercen,"999.9999").            

           CLEAR FRAME f_tab028 NO-PAUSE.

        END.  /*  Fim do DO TRANSACTION  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
                       
           FIND craptab WHERE 
                craptab.cdcooper = glb_cdcooper  AND
                craptab.nmsistem = "CRED"        AND
                craptab.tptabela = "USUARI"      AND
                craptab.cdempres = 00            AND
                craptab.cdacesso = "PREDEPOSIT"  AND
                craptab.tpregist = 1 
                NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT.
                 END.

           ASSIGN tel_dtcobpdp = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                                      INT(SUBSTRING(craptab.dstextab,1,2)),
                                      INT(SUBSTRING(craptab.dstextab,7,4)))
                  tel_vllimdoc = DECIMAL(SUBSTRING(craptab.dstextab,21,9))
                  tel_vlpercen = DECIMAL(SUBSTRING(craptab.dstextab,12,8)).

            DISPLAY tel_dtcobpdp
                    tel_vllimdoc
                    tel_vlpercen
                    WITH FRAME f_tab028.
        END.

   RELEASE craptab.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

