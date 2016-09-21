/* .............................................................................

   Programa: Includes/termimpr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/95.                          Ultima atualizacao: 02/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Questionar o usuario se o seu terminal tem uma impressora conec-
               tada para impressao escrava.

               16/11/2000 - Possibilitar que o usuario mude de impressora
                            (Eduardo).
                            
               15/12/2004 - Verificar se a impressora informada existe no
                            sistema (Edson).

               07/07/2005 - Alimentado campo cdcooper da tabela craptab (Diego).

               03/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               23/05/2011 - Alterada a leitura da tabela craptab para a 
                            tabela crapope (Isara - RKAM).       
                            
               21/12/2011 - Corrigido warnings (Tiago).        
               
               25/03/2014 - Ajuste processo busca impressora (Daniel). 
               
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */


DEF STREAM str_1.

DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                       NO-UNDO.
DEF VAR tel_nmoperad AS CHAR    FORMAT "x(30)"                       NO-UNDO.
DEF VAR aux_server   AS CHAR                                         NO-UNDO.
DEF VAR tel_dsmicimp AS CHAR    FORMAT "x(5)" INIT "Micro"           NO-UNDO.
DEF VAR tel_dssimimp AS CHAR    FORMAT "x(3)" INIT "Sim"             NO-UNDO.
DEF VAR tel_dsnaoimp AS CHAR    FORMAT "x(3)" INIT "Nao"             NO-UNDO.
DEF VAR tel_nmimpres AS CHAR    FORMAT "x(15)"                       NO-UNDO.

DEF VAR aux_flgconfi AS LOGICAL FORMAT "Sim/Nao"                     NO-UNDO.
DEF VAR aux_flgopcao AS LOGICAL FORMAT "S/N"  INIT "S"               NO-UNDO.

DEf VAR aux_grep     AS CHAR    FORMAT "x(15)"                       NO-UNDO.

DEF VAR aux_nmimpres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
            
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

INPUT THROUGH basename `hostname -s` NO-ECHO.
IMPORT UNFORMATTED aux_server.
INPUT CLOSE.

aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                      aux_nmendter.

IF   LENGTH(crapope.nmoperad) >= 30   THEN
     tel_nmoperad = crapope.nmoperad.
ELSE
     tel_nmoperad = FILL(" ",15 - INTEGER(LENGTH(crapope.nmoperad) / 2)) +
                    crapope.nmoperad.

ASSIGN glb_flgimpre = FALSE
       glb_flgmicro = FALSE
       glb_flgescra = FALSE
       glb_nmdafila = "".
                  
FIND crapter WHERE crapter.cdcooper = glb_cdcooper AND
                   crapter.nmendter = aux_nmendter NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapter   THEN
     DO: 
         IF crapope.dsimpres = "" THEN
              DO:
                  FORM SKIP(1)
                       tel_nmoperad AT 13
                       SKIP(1)
                       "Existe uma impressora conectada em seu terminal?" AT 3
                       SKIP(1)
                       tel_dsnaoimp AT 13
                       tel_dssimimp AT 26
                       tel_dsmicimp AT 39
                       SKIP(1)
                       "Obs.: A resposta errada podera ocasionar" AT 7
                       SKIP
                       "o travamento do seu terminal." AT 13
                       SKIP(1)
                       "Responda corretamente!!!" AT 15
                       SKIP(1)
                       WITH ROW 7 COLUMN 14 OVERLAY WIDTH 54 NO-LABELS
                            FRAME f_tem_imp.

                  BELL.

                  DISPLAY tel_nmoperad tel_dsnaoimp tel_dssimimp tel_dsmicimp
                          WITH FRAME f_tem_imp.
                  
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     CHOOSE FIELD tel_dsnaoimp tel_dssimimp tel_dsmicimp
                                  WITH FRAME f_tem_imp.

                     IF   FRAME-VALUE = tel_dsmicimp THEN  
                          DO:  
                              UPDATE "  Entre com o nome da impressora: "
                                     tel_nmimpres " "   
                                     WITH ROW 11 CENTERED OVERLAY
                                          NO-LABELS FRAME f_imp.


                              ASSIGN aux_grep = ""
                                     aux_nmimpres = "^" + tel_nmimpres + ":".
                              
                              INPUT STREAM str_1 THROUGH
                                     VALUE ('grep -Ew "' + aux_nmimpres + '" /etc/qconfig' ) NO-ECHO.
                                
                              DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                                
                                  IMPORT STREAM str_1 UNFORMATTED aux_grep.
                                  
                              END.

                              IF   TRIM(aux_grep) = "" THEN
                                   DO:
                                       BELL.
                                       MESSAGE "Impressora nao cadastrada -" 
                                               tel_nmimpres.
                                       NEXT.
                                   END.

                              FIND CURRENT crapope EXCLUSIVE-LOCK 
                                                   NO-ERROR NO-WAIT.

                              ASSIGN crapope.dsimpres = tel_nmimpres
                                     glb_flgmicro     = TRUE
                                     glb_nmdafila     = LC(crapope.dsimpres) 
                                     glb_flgimpre     = FALSE
                                     glb_flgescra     = FALSE. 

                              FIND CURRENT crapope NO-LOCK NO-ERROR.

                              HIDE FRAME f_imp NO-PAUSE.
                              LEAVE.
                          END.
                     ELSE
                          DO:
                              IF   FRAME-VALUE = tel_dsnaoimp   THEN
                                   DO:
                                      ASSIGN glb_flgimpre = FALSE
                                             glb_nmdafila = "Sem impressora".
                                      LEAVE.
                                   END.
                              
                              ASSIGN aux_flgconfi = FALSE
                                     glb_cdcritic = 78.

                              RUN fontes/critic.p.
                              glb_cdcritic = 0.

                              MESSAGE glb_dscritic UPDATE aux_flgconfi.
                                 
                              IF   aux_flgconfi   THEN
                                   DO:
                                       ASSIGN glb_flgimpre = TRUE
                                              glb_flgescra = TRUE.
                                       LEAVE.
                                   END.
                          END.
                     
                     HIDE FRAME f_tem_imp NO-PAUSE.                  
                  END.  /*  Fim do DO WHILE TRUE  */
              END.
         ELSE
              DO:
                  MESSAGE "Confirmar a impressora " + 
                          TRIM(crapope.dsimpres) + " ? (S/N)"
                          UPDATE aux_flgopcao.

                  IF   NOT aux_flgopcao THEN
                       DO:
                           DO WHILE TRUE TRANSACTION ON ERROR UNDO, RETRY:
                              
                              UPDATE "  Entre com o nome da impressora: "
                                     tel_nmimpres " "   
                                     WITH ROW 11 CENTERED OVERLAY
                                          NO-LABELS FRAME f_impres.

                              ASSIGN aux_grep = ""
                                     aux_nmimpres = "^" + tel_nmimpres + ":".
                              
                              INPUT STREAM str_1 THROUGH
                                     VALUE ('grep -Ew "' + aux_nmimpres + '" /etc/qconfig' ) NO-ECHO.
                                
                              DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                                
                                  IMPORT STREAM str_1 UNFORMATTED aux_grep.
                                  
                              END.

                              IF   TRIM(aux_grep) = "" THEN
                                   DO:
                                       BELL.
                                       MESSAGE "Impressora nao cadastrada -" 
                                               tel_nmimpres.
                                       NEXT.
                                   END.
                              
                              FIND CURRENT crapope EXCLUSIVE-LOCK 
                                                   NO-ERROR NO-WAIT.

                              crapope.dsimpres = tel_nmimpres.

                              FIND CURRENT crapope NO-LOCK NO-ERROR.
                              
                              IF  tel_nmimpres = "ESCRAVA" THEN
                                  ASSIGN glb_flgimpre = TRUE
                                         glb_flgescra = TRUE.
                              
                              HIDE FRAME f_impres NO-PAUSE.
                              
                              LEAVE.     
                           
                           END. /*   Fim do DO WHILE TRUE  */
                       END.   /*  Fim do IF   NOT aux_flgopcao  */
              END.

         IF crapope.dsimpres = "" THEN
             glb_flgmicro = FALSE.
         ELSE
             ASSIGN glb_flgmicro = TRUE
                    glb_nmdafila = LC(crapope.dsimpres).
     END.
ELSE
IF   crapter.nmdafila <> "Limbo"   THEN
     ASSIGN glb_flgimpre = TRUE
            glb_nmdafila = LC(crapter.nmdafila)
            glb_flgescra = IF crapter.nmdafila = "Escrava"
                              THEN TRUE
                              ELSE FALSE.
ELSE
     ASSIGN glb_flgimpre = FALSE
            glb_nmdafila = "Sem impressora".

/* .......................................................................... */

