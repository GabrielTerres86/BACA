/* ..........................................................................

   Programa: Fontes/crps059.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                          Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Quando da exportacao/importacao do banco de dados.
   Objetivo  : Controle da importacao das definicoes do banco e do conteudo dos
	       arquivos.

............................................................................. */

DEFINE NEW SHARED VAR errline   AS INT                     NO-UNDO.
DEFINE NEW SHARED VAR errcount  AS INT                     NO-UNDO.
DEFINE NEW SHARED VAR del-file  AS CHAR                    NO-UNDO.
DEFINE NEW SHARED VAR fname     AS CHAR FORMAT "x(12)"     NO-UNDO.
DEFINE NEW SHARED VAR lname     AS CHAR FORMAT "x(12)"     NO-UNDO.
DEFINE NEW SHARED VAR perr      AS INT  INIT 0             NO-UNDO.

DEFINE NEW SHARED VAR diretorio AS CHAR                    NO-UNDO.
DEFINE NEW SHARED VAR banco     AS CHAR                    NO-UNDO.

DEFINE            VAR contador  AS INT                     NO-UNDO.

diretorio = "/win10/credito/arq/".    /*  Diretorio p/ export./import.  */

banco = DBNAME.                             /*  Nome do banco de dados  */

DO contador = LENGTH(banco) TO 1 BY -1:

   IF   SUBSTRING(banco,contador,1) = "/"   THEN
	DO:
	    banco = SUBSTRING(banco,contador + 1,14).

	    IF   banco = ""   THEN
		 DO:
		     BELL.
		     MESSAGE "BANCO SEM NOME...".
		     RETURN.
		 END.

	    LEAVE.
	END.
END.

RUN fontes/crps060.p.      /*  Importa as definicoes  */

RUN fontes/crps061.p.      /*  Importa o conteudo dos arquivos  */

QUIT.

/* .......................................................................... */
