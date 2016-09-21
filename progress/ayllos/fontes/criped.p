/* .............................................................................

   Programa: Fontes/criped.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                         Ultima atualizacao: 26/03/98

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CRIPED.

   Alteracoes: 26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

............................................................................. */

DEF STREAM str_1.

{ includes/var_online.i }

DEF        VAR tel_nrpedido AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrtalchq AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zz9,9"           NO-UNDO.
DEF        VAR tel_nrdctabb AS INT     FORMAT "zzzz,zz9,9"           NO-UNDO.
DEF        VAR tel_dtemstal AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dtrettal AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqcri AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
			HELP "Informe a opcao desejada (B ou L)"
			VALIDATE (CAN-DO("B,L",glb_cddopcao),
				  "014 - Opcao errada.")
     SKIP(1)
"Conta/dv       Talao     Pedido      Conta BB     Liberacao     Retirada"
     AT 5
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_criped.

FORM tel_nrdconta AT  3
     tel_nrtalchq AT 18
     tel_nrpedido AT 29
     tel_nrdctabb AT 40
     tel_dtemstal AT 54
     tel_dtrettal AT 67
     WITH ROW 10 COLUMN 2 NO-BOX NO-LABELS 11 DOWN OVERLAY FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

IF   NOT CAN-DO("B,L",glb_cddopcao)   THEN
     glb_cddopcao = "B".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_nmtelant = "PEDIDO"   THEN
	   DO:
	       glb_nmtelant = "".
	       DISPLAY glb_cddopcao WITH FRAME f_criped.
	       LEAVE.
	   END.

      UPDATE glb_cddopcao WITH FRAME f_criped.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
	DO:
	    RUN fontes/novatela.p.
	    IF   glb_nmdatela <> "CRIPED"   THEN
		 DO:
		     HIDE FRAME f_criped.
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

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   glb_cddopcao = "B"   THEN
	aux_nmarqcri = "arq/pedido.blq".
   ELSE
	IF   glb_cddopcao = "L"   THEN
	     aux_nmarqcri = "arq/pedido.lib".

   IF   SEARCH(aux_nmarqcri) = ?   THEN
	DO:
	    glb_cdcritic = 182.
	    RUN fontes/critic.p.
	    BELL.
	    MESSAGE glb_dscritic "-->" aux_nmarqcri.
	    NEXT.
	END.

   INPUT STREAM str_1 FROM VALUE(aux_nmarqcri) NO-ECHO.

   ASSIGN aux_contador = 0
	  aux_flgretor = FALSE
	  aux_regexist = FALSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET STREAM str_1
	  tel_nrdconta  tel_nrtalchq  tel_nrpedido
	  tel_nrdctabb  tel_dtemstal  tel_dtrettal.

      IF   tel_nrdconta = 99999999   THEN
	   LEAVE.

      ASSIGN aux_regexist = TRUE
	     aux_contador = aux_contador + 1.

      IF   aux_contador = 1   THEN
	   IF   aux_flgretor   THEN
		DO:
		    PAUSE MESSAGE
			"Tecle <Entra> para continuar ou <Fim> para encerrar".
		    CLEAR FRAME f_lanctos ALL NO-PAUSE.
		END.

      PAUSE (0).

      DISPLAY tel_nrdconta  tel_nrtalchq  tel_nrpedido
	      tel_nrdctabb  tel_dtemstal  tel_dtrettal
	      WITH FRAME f_lanctos.

      IF   aux_contador = 11   THEN
	   DO:
	       ASSIGN aux_contador = 0
		      aux_flgretor = TRUE.
	   END.
      ELSE
	   DOWN WITH FRAME f_lanctos.

   END.  /*  Fim do DO WHILE TRUE  */

   INPUT STREAM str_1 CLOSE.

   IF   NOT aux_regexist   THEN
	DO:
	    glb_cdcritic = 237.
	    RUN fontes/critic.p.
	    BELL.
	    MESSAGE glb_dscritic.
	END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
