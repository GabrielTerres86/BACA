/* .............................................................................

   Programa: Fontes/tab006.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela tab006.

   Alteracoes: 09/05/2001 - Tendo cheques no dia nao alterar (Margarete).

               18/06/2004 - Criticar somente a alteracao do valor dos cheques
                            maiores se ja houve acolhidos. Os demais campos
                            podem ser alterados (Deborah).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                            b1wgen9999.p procedure acha-lock, que identifica qual 
                            é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               13/06/2017 - Nao permitir mais alterar o valor do campo “Valor para os Cheques Maiores”,
                            apenas exibi-lo em tela. PRJ367 - Compe Sessao Unica (Lombardi)
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_vlmaichq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF        VAR tel_vlsldneg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR tel_vlchcomp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.

DEF        VAR aux_tentaler AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgacolh AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlmaichq AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dadosusr         AS CHAR                            NO-UNDO.
DEF        VAR par_loginusr         AS CHAR                            NO-UNDO.
DEF        VAR par_nmusuari         AS CHAR                            NO-UNDO.
DEF        VAR par_dsdevice         AS CHAR                            NO-UNDO.
DEF        VAR par_dtconnec         AS CHAR                            NO-UNDO.
DEF        VAR par_numipusr         AS CHAR                            NO-UNDO.
DEF        VAR h-b1wgen9999         AS HANDLE                          NO-UNDO.


FORM SKIP (4)
     glb_cddopcao AT 42 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A ou C)"
                        VALIDATE(glb_cddopcao = "A" OR
                                 glb_cddopcao = "C","014 - Opcao errada.")
     SKIP (2)
     tel_vlmaichq AT 18 LABEL "Valor para os Cheques Maiores" AUTO-RETURN
                        HELP "Entre com o valor para os maiores cheques."
                        VALIDATE(tel_vlmaichq > 0,"269 - Valor errado.")
     SKIP (1)
     tel_vlsldneg AT 13 LABEL "Valor maximo para Saldos Negativos" AUTO-RETURN
                        HELP "Entre o valor maximo para Saldos Negativos."
                        VALIDATE(tel_vlsldneg < 0,"269 - Valor errado.")
     SKIP (1)
     tel_vlchcomp AT  8 LABEL "Valor para Conferencia dos Cheques Comp"                                       AUTO-RETURN
                  HELP "Entre com o Valor para Conferencia dos Cheques Comp."
                        VALIDATE(tel_vlchcomp > 0,"269 - Valor errado.")     
     
     SKIP(4)
     WITH ROW 4 COLUMN 1 OVERLAY WIDTH 80 SIDE-LABELS
         TITLE COLOR MESSAGE " Maiores Cheques/Maximo Negativo " FRAME f_tab006.

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab006.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB006"   THEN
                 DO:
                     HIDE FRAME f_tab006.
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

   ASSIGN tel_vlmaichq = 0
          tel_vlsldneg = 0
          tel_vlchcomp = 0
          aux_vlmaichq = 0
          glb_cdcritic = 0.

   IF   glb_cddopcao = "A" THEN
        DO TRANSACTION:

           aux_flgacolh = FALSE.
           
           DO aux_tentaler = 1 TO 5:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                                 craptab.nmsistem = "CRED"         AND
                                 craptab.tptabela = "USUARI"       AND
                                 craptab.cdempres = 11             AND
                                 craptab.cdacesso = "MAIORESCHQ"   AND
                                 craptab.tpregist = 001
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF  LOCKED craptab   THEN
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
                            LEAVE.
                        END.
              
              ASSIGN tel_vlmaichq = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                     tel_vlsldneg = DECIMAL(SUBSTRING(craptab.dstextab,17,16))
                     tel_vlchcomp = DECIMAL(SUBSTRING(craptab.dstextab,34,15)).

              LEAVE.

           END.  /*  Fim do DO .. TO  -- Tenta Ler  */

           aux_vlmaichq = tel_vlmaichq.
           
           IF   glb_cdcritic = 0   THEN
                DO:
                    FIND FIRST crapchd WHERE 
                               crapchd.cdcooper = glb_cdcooper AND
                               crapchd.dtmvtolt = glb_dtmvtolt NO-LOCK NO-ERROR.

                    IF   AVAILABLE crapchd   THEN
                         aux_flgacolh = TRUE.
                END.
                
           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_tab006 NO-PAUSE.
                    NEXT.
                END.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              DISPLAY tel_vlmaichq WITH FRAME f_tab006.
              
              UPDATE  tel_vlsldneg tel_vlchcomp WITH FRAME f_tab006

              EDITING:

                       READKEY.
                       IF   FRAME-FIELD = "tel_vlmaichq"   OR
                            FRAME-FIELD = "tel_vlsldneg"   OR
                            FRAME-FIELD = "tel_vlchcomp"   THEN
                            IF   LASTKEY =  KEYCODE(".")   THEN
                                 APPLY 44.
                            ELSE
                                 APPLY LASTKEY.
                       ELSE
                            APPLY LASTKEY.

              END.

              IF   aux_flgacolh AND 
                   aux_vlmaichq <> tel_vlmaichq THEN
                   DO:
                       glb_cdcritic = 713.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       CLEAR FRAME f_tab006 NO-PAUSE.
                       NEXT.
                   END.
              
              ASSIGN craptab.dstextab = STRING(tel_vlmaichq,"999999999999.99") +
                                        " " +
                                        STRING(tel_vlsldneg,"999999999999.99-")
                                        + " " +
                                        STRING(tel_vlchcomp,"999999999999.99").

              CLEAR FRAME f_tab006 NO-PAUSE.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

        END.  /*  Fim da transacao  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND 
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "MAIORESCHQ" AND
                               craptab.tpregist = 001          NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     CLEAR FRAME f_tab006 NO-PAUSE.
                     NEXT.
                 END.

             ASSIGN tel_vlmaichq = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
                    tel_vlsldneg = DECIMAL(SUBSTRING(craptab.dstextab,17,16)).
                    tel_vlchcomp = DECIMAL(SUBSTRING(craptab.dstextab,34,15)).

             DISPLAY tel_vlmaichq tel_vlsldneg tel_vlchcomp WITH FRAME f_tab006.
        END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
