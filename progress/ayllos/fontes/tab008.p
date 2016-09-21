/* .............................................................................

   Programa: Fontes/tab008.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/94.                      Ultima atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB008 (Tabela com o valor da taxa de devolucao)

   Alteracao : 26/10/95 - Alterado para incluir a taxa de cadastramento de
                          contra-ordem (Odair).
               23/03/2004 - Incluidos Campos Tarifa/Qtd.Doctos em Branco para
                            serem parametrizados(Mirtes)

              01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

              18/12/2008 - Criticar tel_qtctrdif = 0, obrigatorio > 0
                           para o crps136 (Guilherme).
                           
              19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_vltaxdev AS DECIMAL FORMAT "zzz,zz9.99"           NO-UNDO.
DEF        VAR tel_vltaxord AS DECIMAL FORMAT "zzz,zz9.99"           NO-UNDO.
DEF        VAR tel_txctrdif AS DECIMAL FORMAT "zzz,zz9.99"           NO-UNDO.  
DEF        VAR tel_qtctrdif AS INT     FORMAT "99"                   NO-UNDO.

DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dadosusr         AS CHAR                          NO-UNDO.
DEF        VAR par_loginusr         AS CHAR                          NO-UNDO.
DEF        VAR par_nmusuari         AS CHAR                          NO-UNDO.
DEF        VAR par_dsdevice         AS CHAR                          NO-UNDO.
DEF        VAR par_dtconnec         AS CHAR                          NO-UNDO.
DEF        VAR par_numipusr         AS CHAR                          NO-UNDO.
DEF        VAR h-b1wgen9999         AS HANDLE                        NO-UNDO.


FORM SKIP(3)
     glb_cddopcao AT 41 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A ou C)"
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(2)
     tel_vltaxdev AT 09 LABEL "          Taxa de devolucao de cheque"
             HELP "Entre com o valor da taxa de devolucao de cheques"
     SKIP(1)
     tel_vltaxord AT 09 LABEL "Taxa de cadastramento de contra-ordem"
             HELP "Entre com o valor da taxa de cadastramento de contra-ordem"
     SKIP(1)
     tel_txctrdif AT 09 LABEL "Taxa de Doctos nao Preenchidos(Roubo)"
             HELP "Entre com o valor da taxa de cheques nao preenchidos   "
     SKIP(1)
     tel_qtctrdif AT 09 LABEL "Qtdade Doctos nao Preenchidos(Roubo)"
         HELP "Entre com qtd.cheques(p/cobranca de taxa) nao preenchidos"
         VALIDATE(tel_qtctrdif > 0,"Valor informado deve ser maior que zero.")
     SKIP(3)
     WITH ROW 4 OVERLAY SIDE-LABELS TITLE glb_tldatela WIDTH 80 FRAME f_tab008.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab008.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB008"   THEN
                 DO:
                     HIDE FRAME f_tab008.
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

   tel_vltaxdev = 0.

   IF   glb_cddopcao = "A" THEN
        DO:
            glb_cdcritic = 0.

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TAXADEVCHQ"   AND
                               craptab.tpregist = 001
                               NO-LOCK NO-ERROR.

             IF   AVAILABLE craptab   THEN
                 ASSIGN tel_vltaxdev = DECIMAL(SUBSTR(craptab.dstextab,1,10))
                        tel_vltaxord = DECIMAL(SUBSTR(craptab.dstextab,12,10))
                        tel_txctrdif = DECIMAL(SUBSTR(craptab.dstextab,26,10))
                        tel_qtctrdif = INTEGER(SUBSTR(craptab.dstextab,23,2)).
            ELSE
                 DO:
                     glb_cdcritic = 55.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     DISPLAY tel_vltaxdev
                             tel_vltaxord
                             tel_txctrdif 
                             tel_qtctrdif 
                             WITH FRAME f_tab008.
                 END.

            IF   glb_cdcritic = 0 THEN
                 DO:
                     DO WHILE TRUE:

                     UPDATE tel_vltaxdev 
                            tel_vltaxord
                            tel_txctrdif 
                            tel_qtctrdif 
                            WITH FRAME f_tab008

                        EDITING:

                            READKEY.
                            IF   FRAME-FIELD = "tel_vltaxdev"  OR
                                 FRAME-FIELD = "tel_vltaxord"  OR  
                                 FRAME-FIELD = "tel_txctrdif"  OR
                                 FRAME-FIELD = "tel_qtctrdif" 
                                 THEN
                                 IF   LASTKEY =  KEYCODE(".")   THEN
                                      APPLY 44.
                                 ELSE
                                      APPLY LASTKEY.
                            ELSE
                                 APPLY LASTKEY.

                        END.

                        LEAVE.

                     END.  /*  Fim do DO WHILE TRUE  */

                     DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                        DO  aux_contador = 1 TO 10:

                            FIND craptab WHERE
                                 craptab.cdcooper = glb_cdcooper   AND
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "USUARI"       AND
                                 craptab.cdempres = 11             AND
                                 craptab.cdacesso = "TAXADEVCHQ"   AND
                                 craptab.tpregist = 001
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF   NOT AVAILABLE craptab THEN
                                 IF LOCKED craptab   THEN
                                      DO:
                                       RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                                      INPUT "banco",
                                                                      INPUT "craptab",
                                                                      OUTPUT par_loginusr,
                                                                      OUTPUT par_nmusuari,
                                                                      OUTPUT par_dsdevice,
                                                                      OUTPUT par_dtconnec,
                                                                      OUTPUT par_numipusr).
                
                                	  DELETE PROCEDURE h-b1wgen9999.
                                
                                	  ASSIGN aux_dadosusr = 
                                			 "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                			MESSAGE aux_dadosusr.
                                			PAUSE 3 NO-MESSAGE.
                                			LEAVE.
                                		END.
                                
                                	   ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                							  " - " + par_nmusuari + ".".
                                
                                		HIDE MESSAGE NO-PAUSE.
                                
                                		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                			MESSAGE aux_dadosusr.
                                			PAUSE 5 NO-MESSAGE.
                                			LEAVE.
                                		END.
                                                                		
                                		NEXT.
                                      END.
                                 ELSE
                                      DO:
                                          glb_cdcritic = 55.
                                          CLEAR FRAME f_tab008.
                                          LEAVE.
                                      END.
                            ELSE
                                 DO:
                                     aux_contador = 0.
                                     LEAVE.
                                 END.
                        END.

                        IF   aux_contador <> 0   THEN
                             DO:
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 NEXT.
                             END.

                        craptab.dstextab = STRING(tel_vltaxdev,"9999999.99") +
                                           " " +
                                           STRING(tel_vltaxord,"9999999.99") +
                                           " " +
                                           STRING(tel_qtctrdif,"99") +
                                           " " +
                                           STRING(tel_txctrdif,"9999999.99").

                     END. /* Fim da transacao */

                     RELEASE craptab.

                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                          NEXT.

                     CLEAR FRAME f_tab008 NO-PAUSE.
                 END.
        END.
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            glb_cdcritic = 0.

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "TAXADEVCHQ"   AND
                               craptab.tpregist = 001             
                               NO-LOCK NO-ERROR.

            IF   AVAILABLE craptab   THEN
                 ASSIGN tel_vltaxdev = DECIMAL(SUBSTR(craptab.dstextab,1,10))
                        tel_vltaxord = DECIMAL(SUBSTR(craptab.dstextab,12,10))
                        tel_txctrdif = DECIMAL(SUBSTR(craptab.dstextab,26,10))
                        tel_qtctrdif = INTEGER(SUBSTR(craptab.dstextab,23,2)).
            ELSE
                 DO:
                     glb_cdcritic = 55.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                 END.

            DISPLAY tel_vltaxdev 
                    tel_vltaxord
                    tel_txctrdif 
                    tel_qtctrdif 
                    WITH FRAME f_tab008.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

