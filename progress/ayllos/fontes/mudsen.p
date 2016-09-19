/* .............................................................................

   Programa: Fontes/mudsen.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                           Ultima alteracao: 11/07/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela MUDSEN.

   Alteracoes: 31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
   
               14/06/2011 - Adaptar para usar a B1wgen0100.p (Gabriel). 
               
               11/07/2014 - Implementada a saida da tela com END/F4 (Carlos)
............................................................................. */

{ includes/var_online.i } 
{ sistema/generico/includes/var_internet.i }

/* Operador e senha Atual*/
DEF        VAR tel_cdoperad LIKE crapope.cdoperad                    NO-UNDO.
DEF        VAR tel_cdsenha1 AS CHAR FORMAT "x(10)"                   NO-UNDO.

/* Nova senha e confirmacao */
DEF        VAR tel_cdsenha2 AS CHAR FORMAT "x(10)"                   NO-UNDO.
DEF        VAR tel_cdsenha3 AS CHAR FORMAT "x(10)"                   NO-UNDO.

DEF        VAR h-b1wgen0100 AS HANDLE                                NO-UNDO.

DEF        VAR aux_confirma AS CHAR FORMAT "!"                       NO-UNDO.

DEF        VAR par_nmdcampo AS CHAR                                  NO-UNDO.

FORM SKIP (3)
     "Codigo de operador:"       AT 27
     tel_cdoperad                AT 47 NO-LABEL
                                       HELP "Informe o codigo do operador." 
     SKIP (1)
     tel_cdsenha1                AT 34 BLANK LABEL "Senha atual"
                                       HELP "Informe a senha atual." 
     SKIP (2)
     "Digite nova senha:"        AT 28
     tel_cdsenha2 FORMAT "x(10)" AT 47 BLANK NO-LABEL
                                       HELP "Informe a nova senha."
     SKIP (1)
     "Confirme nova senha:"      AT 26
     tel_cdsenha3 FORMAT "x(10)" AT 47 BLANK NO-LABEL
                                       HELP "Informe novamente a nova senha."
     SKIP (5)
     WITH SIDE-LABELS TITLE COLOR MESSAGE " Mudanca de Senha "
          ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_mudsen.

DO WHILE TRUE ON ENDKEY UNDO, RETRY:

   RUN fontes/inicia.p.

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
    DO:
        RUN fontes/novatela.p.
        IF   CAPS(glb_nmdatela) <> "MUDSEN"   THEN
             DO:
                 IF  VALID-HANDLE(h-b1wgen0100) THEN
                     DELETE OBJECT h-b1wgen0100.
    
                 HIDE FRAME f_opcao.
                 HIDE FRAME f_moldura.
                 RETURN.
             END.
        ELSE
             NEXT.
    END.

   UPDATE tel_cdoperad
          tel_cdsenha1 
         
          tel_cdsenha2 
          tel_cdsenha3 WITH FRAME f_mudsen

   EDITING:

      READKEY.

      APPLY LASTKEY.

      IF   GO-PENDING   THEN
           DO:
               DO WITH FRAME f_mudsen:
                  ASSIGN tel_cdoperad
                         tel_cdsenha1
                         tel_cdsenha2
                         tel_cdsenha3.
               END.

               RUN sistema/generico/procedures/b1wgen0100.p 
                   PERSISTENT SET h-b1wgen0100.

               RUN valida-altera-senha IN h-b1wgen0100 (INPUT glb_cdcooper,
                                                        INPUT 0,
                                                        INPUT 0,
                                                        INPUT glb_dtmvtolt,
                                                        INPUT tel_cdoperad,
                                                        INPUT tel_cdsenha1,
                                                        INPUT tel_cdsenha2,
                                                        INPUT tel_cdsenha3,
                                                       OUTPUT TABLE tt-erro,
                                                       OUTPUT par_nmdcampo).
               DELETE PROCEDURE h-b1wgen0100.

               FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
               IF   RETURN-VALUE <> "OK"   THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                        IF   AVAIL tt-erro   THEN
                             MESSAGE tt-erro.dscritic.
                        ELSE
                             MESSAGE "Erro na alteracao da senha do operador.".
              
                        { sistema/generico/includes/foco_campo.i
                                     &VAR-GERAL=SIM
                                     &NOME-FRAME="f_mudsen"
                                     &NOME-CAMPO=par_nmdcampo }
                    END.
           END.

   END. /* Fim do EDITING */

   HIDE FRAME f_mudsen NO-PAUSE.

   ASSIGN glb_nmdatela = IF   glb_nmtelant = "MUDSEN"  THEN 
                              ""
                         ELSE 
                              glb_nmtelant

          glb_nmtelant = "MUDSEN".

   LEAVE.
 
END.

/* .......................................................................... */
