/* .............................................................................

   Programa: Fontes/tab020.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2003                           Ultima alteracao: 15/07/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB020 - Tarifa para o desconto de cheques.
   
   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               16/02/2009 - Criado log, log/tab020.log (Gabriel).
               
               20/05/2009 - Liberado somente opcao "C" para COOPs(Guilherme).
               
               15/07/2009 - Alteracao CDOPERAD (Diego).
   
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vltarctr AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarrnv AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarbdc AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarchq AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltardev AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltarrgt AS DECIMAL FORMAT "zz9.99"               NO-UNDO.

DEF        VAR log_vltarctr AS DECIMAL                               NO-UNDO.
DEF        VAR log_vltarrnv AS DECIMAL                               NO-UNDO.
DEF        VAR log_vltarbdc AS DECIMAL                               NO-UNDO.
DEF        VAR log_vltarchq AS DECIMAL                               NO-UNDO.
DEF        VAR log_vltardev AS DECIMAL                               NO-UNDO.
DEF        VAR log_vltarrgt AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

FORM SKIP(1)
     glb_cddopcao AT 35 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                        HELP "Entre com a opcao desejada (A,C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     tel_vltarctr AT 28 LABEL "Por contrato"
                        HELP "Entre com o valor da tarifa por contrato."
     SKIP(1)
     tel_vltarrnv AT 27 LABEL "Por renovacao"
                        HELP "Entre com o valor da tarifa por renovacao."
     SKIP(1)
     tel_vltarbdc AT 29 LABEL "Por bordero"
                        HELP "Entre com o valor da tarifa por bordero."
     SKIP(1)
     tel_vltarchq AT 30 LABEL "Por cheque"
                        HELP "Entre com o valor da tarifa por cheque."

     SKIP(1)
     tel_vltardev AT 20 LABEL "Por cheque devolvido"
                        HELP "Entre com o valor da tarifa por cheque devolvido."
     SKIP(1)
     tel_vltarrgt AT 20 LABEL "Por cheque resgatado"
                        HELP "Entre com o valor da tarifa por cheque resgatado."
     SKIP(2)
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_tab020.

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
               CLEAR FRAME f_tab020 NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao  WITH FRAME f_tab020.

      IF   NOT CAN-DO("C",glb_cddopcao)   THEN
           IF   NOT CAN-DO("PRODUTOS,COORD.ADM/FINANCEIRO,TI",glb_dsdepart) 
                    THEN
                DO:
                    glb_cdcritic = 36.
                    NEXT.
                END.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "tab020"   THEN
                 DO:
                     HIDE FRAME f_tab020.
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
          
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "USUARI"       AND
                                 craptab.cdempres = 11             AND
                                 craptab.cdacesso = "TARDESCONT"   AND
                                 craptab.tpregist = 0
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

           ASSIGN tel_vltarctr = DECIMAL(SUBSTRING(craptab.dstextab,01,06))
                  tel_vltarrnv = DECIMAL(SUBSTRING(craptab.dstextab,08,06))
                  tel_vltarbdc = DECIMAL(SUBSTRING(craptab.dstextab,15,06))
                  tel_vltarchq = DECIMAL(SUBSTRING(craptab.dstextab,22,06))
                  tel_vltardev = DECIMAL(SUBSTRING(craptab.dstextab,29,06))
                  tel_vltarrgt = DECIMAL(SUBSTRING(craptab.dstextab,36,06))
                  
                  log_vltarctr = tel_vltarctr
                  log_vltarrnv = tel_vltarrnv
                  log_vltarbdc = tel_vltarbdc
                  log_vltarchq = tel_vltarchq
                  log_vltardev = tel_vltardev
                  log_vltarrgt = tel_vltarrgt.
                  
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
              IF   glb_cdcritic > 0   THEN
                   DO:
                   END.
              
              UPDATE tel_vltarctr  tel_vltarrnv  tel_vltarbdc 
                     tel_vltarchq  tel_vltardev  tel_vltarrgt 
                     WITH FRAME f_tab020

              EDITING:

                 READKEY.
              
                 IF   FRAME-FIELD = "tel_vltarctr"  OR
                      FRAME-FIELD = "tel_vltarrnv"  OR
                      FRAME-FIELD = "tel_vltarbdc"  OR
                      FRAME-FIELD = "tel_vltarchq"  OR
                      FRAME-FIELD = "tel_vltardev"  OR
                      FRAME-FIELD = "tel_vltarrgt"  THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.

              END.  /*  Fim do EDITING  */

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

           craptab.dstextab = STRING(tel_vltarctr,"999.99") + " " +
                              STRING(tel_vltarrnv,"999.99") + " " +
                              STRING(tel_vltarbdc,"999.99") + " " +
                              STRING(tel_vltarchq,"999.99") + " " +
                              STRING(tel_vltardev,"999.99") + " " +
                              STRING(tel_vltarrgt,"999.99").

           RUN proc_log (INPUT log_vltarctr,
                         INPUT tel_vltarctr,
                         INPUT "Por contrato").

           RUN proc_log (INPUT log_vltarrnv,
                         INPUT tel_vltarrnv,
                         INPUT "Por renovacao").              
        
           RUN proc_log (INPUT log_vltarbdc,
                         INPUT tel_vltarbdc, 
                         INPUT "Por bordero").

           RUN proc_log (INPUT log_vltarchq,
                         INPUT tel_vltarchq,
                         INPUT "Por cheque").
                         
           RUN proc_log (INPUT log_vltardev,
                         INPUT tel_vltardev,
                         INPUT "Por cheque devolvido").
                                       
           RUN proc_log (INPUT log_vltarrgt,
                         INPUT tel_vltarrgt,
                         INPUT "Por cheque resgatado").              
                            
           CLEAR FRAME f_tab020 NO-PAUSE.
                      
        END.  /*  Fim do DO TRANSACTION  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TARDESCONT"   AND
                               craptab.tpregist = 0            
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT.
                 END.

            ASSIGN tel_vltarctr = DECIMAL(SUBSTRING(craptab.dstextab,01,06))
                   tel_vltarrnv = DECIMAL(SUBSTRING(craptab.dstextab,08,06))
                   tel_vltarbdc = DECIMAL(SUBSTRING(craptab.dstextab,15,06))
                   tel_vltarchq = DECIMAL(SUBSTRING(craptab.dstextab,22,06))
                   tel_vltardev = DECIMAL(SUBSTRING(craptab.dstextab,29,06))
                   tel_vltarrgt = DECIMAL(SUBSTRING(craptab.dstextab,36,06)).

            DISPLAY tel_vltarctr  tel_vltarrnv  tel_vltarbdc 
                    tel_vltarchq  tel_vltardev  tel_vltarrgt 
                    WITH FRAME f_tab020.
        END.

   RELEASE craptab.

END.  /*  Fim do DO WHILE TRUE  */


PROCEDURE proc_log:

    DEF INPUT PARAM par_vldantes AS DEC   NO-UNDO.
    DEF INPUT PARAM par_vldepois AS DEC   NO-UNDO.
    DEF INPUT PARAM par_dsdcampo AS CHAR  NO-UNDO.

    IF   par_vldantes = par_vldepois   THEN
         RETURN.
         
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                      " Operador " + glb_cdoperad + " alterou o campo "     +
                      par_dsdcampo + " de " + STRING(par_vldantes,"zz9.99") + 
                      " para "     +          STRING(par_vldepois,"zz9.99") + 
                      " >> log/tab020.log").

END PROCEDURE.

/* .......................................................................... */
