/* .............................................................................

   Programa: Fontes/limcxa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2004                      Ultima Atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela limcxa - Limites para os operadores do
               caixa on_line.

   ALTERACAO : 
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_cdoperad LIKE crapope.cdoperad                    NO-UNDO.
DEF        VAR tel_nmoperad AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_vlpagchq LIKE crapope.vlpagchq                    NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_temassoc AS LOGICAL                               NO-UNDO.

DEF        VAR aux_pesquisa AS LOGICAL FORMAT "S/N"                 NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contalin AS INT                                   NO-UNDO.

FORM SKIP (3)
     "Opcao:"     AT 5
     glb_cddopcao AT 12 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada: L-novo limite,C-consulta"
                  VALIDATE (glb_cddopcao = "L" OR glb_cddopcao = "C", 
                            "014 - Opcao errada.")
     SKIP (3)
     "Operador   Nome                 Valor do Limite" AT 9
     SKIP(2)
     tel_cdoperad AT 11 AUTO-RETURN 
                  HELP "Informe o codigo do operador."
     tel_nmoperad AT 20 AUTO-RETURN  
                  HELP "Nome do operador."
     tel_vlpagchq AT 40 AUTO-RETURN
                  HELP
            "Entre com o valor maximo de liberacao"
     SKIP(5)
     WITH NO-LABELS TITLE " Manutencao de LIMITES para CAIXAS "
     ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_limcxa.

/* variaveis para mostrar a consulta */          
 
DEF QUERY  blimcxa-q FOR crapope.
DEF BROWSE blimcxa-b QUERY blimcxa-q
      DISP SPACE(5)
           cdoperad   COLUMN-LABEL "Operador"
           nmoperad   COLUMN-LABEL "Nome"
           vlpagchq   COLUMN-LABEL "Limite"
           SPACE(5)
           WITH 9 DOWN OVERLAY.    

DEF FRAME f_limcxac
          blimcxa-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/**********************************************/

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao WITH FRAME f_limcxa.
        NEXT-PROMPT tel_cdoperad WITH FRAME f_limcxa.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           SET glb_cddopcao tel_cdoperad WITH FRAME f_limcxa.

           LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "limcxa"   THEN
                      DO:
                          HIDE FRAME f_limcxa.
                          HIDE FRAME f_limcxac.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.


        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN tel_cdoperad = INPUT tel_cdoperad
               glb_cddopcao =      INPUT glb_cddopcao.

          IF   INPUT glb_cddopcao = "L" THEN
             DO:
                 { includes/limcxal.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      { includes/limcxac.i }
                  END.
END.

/* .......................................................................... */
