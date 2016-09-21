/* .............................................................................

   Programa: Fontes/obtem_hostname.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2006                          Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado por outro programa.
   Objetivo  : Obter o nome do servidor onde o sistema esta executando.

   Alteracoes: 

............................................................................. */

DEF OUTPUT PARAM glb_hostname AS CHAR FORMAT "x(30)"                   NO-UNDO.

INPUT THROUGH hostname NO-ECHO.

SET glb_hostname.

INPUT CLOSE.

/* .......................................................................... */

