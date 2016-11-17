/* ..........................................................................

   Programa: Fontes/execteste.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/92.                           Ultima atualizacao: 16/08/93

   Dados referentes ao programa:

   Frequencia: Nos teste de execucao de programas.
   Objetivo  : Testar programas.

............................................................................. */

{ includes/var_batch.i "NEW" }

DEF NEW SHARED VAR glb_tpintegr AS CHAR    INIT "f"                  NO-UNDO.

DEF            VAR aux_cdprogra AS CHAR    FORMAT "x(40)"            NO-UNDO.

FORM aux_cdprogra LABEL "Programa a executar"
     WITH CENTERED ROW 8 TITLE " TESTE DE EXECUCAO " SIDE-LABELS FRAME f_teste.

ASSIGN glb_cdprogra = "execteste"
       glb_flgbatch = FALSE.

FIND FIRST crapdat NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapdat THEN
     DO:
	 BELL.
	 MESSAGE "Sistema sem data!".
	 RETURN.
     END.
ELSE
     glb_dtmvtolt = crapdat.dtmvtolt.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   STATUS INPUT "Database " + DBNAME + " - Nome do programa a executar.".

   SET aux_cdprogra WITH FRAME f_teste.

   IF   SEARCH(LC(aux_cdprogra)) = ?   THEN
	DO:
	    BELL.
	    MESSAGE "PROGRAMA NAO EXISTE!".
	END.
   ELSE
	DO:
	    MESSAGE "EXECUTANDO ==>" LC(aux_cdprogra).
	    RUN VALUE(LC(aux_cdprogra)).
	    aux_cdprogra = "".
	END.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
