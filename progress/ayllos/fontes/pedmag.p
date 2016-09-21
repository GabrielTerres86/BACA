/* .............................................................................

   Programa: Fontes/pedmag.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Agosto/2003.                        Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PEDMAG (Pedido de Cartao Magnetico).

   Alteracoes: 

............................................................................. */

{ includes/var_online.i }
                                                       
DEF        VAR tel_nrpedido AS CHAR    FORMAT "x(8)"                 NO-UNDO.
DEF        VAR tel_dspedido AS CHAR    FORMAT "x(8)"                 NO-UNDO.
DEF        VAR tel_dtsolped AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dssitped AS CHAR    FORMAT "x(10)"                NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_pesquisa AS DATE    FORMAT "99/99/9999"           NO-UNDO.
 
FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela
                   FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (B, C ou L)"
                        VALIDATE (glb_cddopcao = "B" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "L","014 - Opcao errada.")

     tel_nrpedido AT 15 LABEL "Numero do Pedido" AUTO-RETURN
                        HELP "Informe o numero do pedido"

     "C A R T A O    M A G N E T I C O" AT 45
     SKIP(1)
     "                 Pedido     Solicitacao      Situacao" AT  1
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_pedido.

FORM tel_dspedido AT 16
     tel_dtsolped AT 30
     tel_dssitped AT 46
     WITH ROW 10 COLUMN 2 NO-BOX NO-LABELS 11 DOWN OVERLAY FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_pedido.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PEDMAG"   THEN
                 DO:
                     HIDE FRAME f_pedido.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"   THEN
        DO:
           { includes/pedmagc.i }
        END.
   ELSE
   IF   glb_cddopcao = "L"   THEN  
        DO:
           { includes/pedmagl.i }
        END.
   ELSE
   IF   glb_cddopcao = "B"   THEN  
        DO:
           { includes/pedmagb.i }
        END.              
         
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
