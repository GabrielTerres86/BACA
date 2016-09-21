/* .............................................................................

   Programa: Fontes/tab013.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/96                           Ultima alteracao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB013.

   Alteracoes: 01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
               26/01/2009 - Alteracao cdempres (Diego).
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

............................................................................. */

{ includes/var_online.i }

DEF        VAR aux_vlchqnom AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_cdempres AS INTEGER FORMAT "zzzz9"                NO-UNDO.
DEF        VAR aux_dsempres AS CHAR    FORMAT "x(30)"                NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM SKIP (3)
     glb_cddopcao AT 22 LABEL "Opcao" AUTO-RETURN
                  HELP "Entre com a opcao desejada"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                            "014 - Opcao errada.")

     SKIP (2)
     aux_cdempres AT 20 LABEL "Empresa"
                  HELP "Entre com o codigo da empresa."
                  VALIDATE(CAN-FIND(FIRST crapemp WHERE 
                                          crapemp.cdcooper = glb_cdcooper AND 
                                          crapemp.cdempres = aux_cdempres),
                                          "040 - Empresa nao Cadastrada.")
     aux_dsempres AT 35 NO-LABEL
     SKIP(2)
     aux_vlchqnom AT 05 LABEL "Valor minimo para emissao de cheque nominal"
                  HELP "Acima deste valor serao feitos cheques nominais."
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_tab013.

glb_cddopcao = "C".

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_tab013.

        NEXT-PROMPT aux_cdempres WITH FRAME f_tab013.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                 UPDATE glb_cddopcao aux_cdempres
                            WITH FRAME f_tab013.
                 LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "tab013"   THEN
                      DO:
                          HIDE FRAME f_tab013.
                          HIDE FRAME f_moldura.
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

        FIND FIRST crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                                 crapemp.cdempres = aux_cdempres
                                 NO-LOCK NO-ERROR.

        aux_dsempres = "- " + crapemp.nmresemp.

        IF   glb_cddopcao = "A" THEN
             DO:
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    DO  aux_contador = 1 TO 10:

                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "USUARI"       AND
                                           craptab.cdempres = aux_cdempres   AND
                                           craptab.cdacesso = "VLRNOMINAL"   AND
                                           craptab.tpregist = 001
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   NOT AVAILABLE craptab   THEN
                             IF   LOCKED craptab   THEN
                                  DO:
                                      RUN sistema/generico/procedures/b1wgen9999.p
			                          PERSISTENT SET h-b1wgen9999.

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
                                      CLEAR FRAME f_tab013.
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

                   aux_vlchqnom = DECIMAL(craptab.dstextab).

                   DISPLAY aux_dsempres aux_vlchqnom  WITH FRAME f_tab013.

                   DO WHILE TRUE:

                      UPDATE aux_vlchqnom WITH FRAME f_tab013.
                      craptab.dstextab = STRING(aux_vlchqnom,"999999999.99").
                      LEAVE.

                   END.

                 END. /* Fim da transacao */

                 RELEASE craptab.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_tab013 NO-PAUSE.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:

                 FIND craptab WHERE
                      craptab.cdcooper = glb_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "USUARI"      AND
                      craptab.cdempres = aux_cdempres  AND
                      craptab.cdacesso = "VLRNOMINAL"  AND
                      craptab.tpregist = 001           NO-LOCK NO-ERROR NO-WAIT.

                 IF   AVAILABLE craptab   THEN
                      DO:
                          ASSIGN aux_vlchqnom = DECIMAL(craptab.dstextab).

                          DISPLAY aux_dsempres aux_vlchqnom WITH FRAME f_tab013.
                      END.
                 ELSE
                      DO:
                          glb_cdcritic = 511.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          CLEAR FRAME f_tab013.
                          NEXT.
                      END.
             END.
END.
/* .......................................................................... */

