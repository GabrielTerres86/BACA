/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/rodajava.i
  Autor: B&T/Solusoft
 Fun��o: Substuitui��o dos caracteres especiais ^ e | para espa�o em branco e
         &(e comercial).
-------------------------------------------------------------------------------*/

PROCEDURE Substituir : /* usado pelo programas de relat�rio */

define input  parameter nome-antigo as char no-undo.
define output parameter nome-novo   as char no-undo.

assign   
   nome-antigo = replace(nome-antigo,"^"," ")
   nome-antigo = replace(nome-antigo,"|","&")
   nome-antigo = replace(nome-antigo,"�","=")
   nome-antigo = replace(nome-antigo,"�","'")
   nome-antigo = replace(nome-antigo,"�",'"')
   nome-antigo = replace(nome-antigo,"�",'+') 
   nome-novo = nome-antigo.
   
END PROCEDURE.   
PROCEDURE TrocaAspas : /* usado pelos zooms */

define input  parameter nome-antigo as char no-undo.
define output parameter nome-novo   as char no-undo.
assign
   nome-antigo = replace(nome-antigo,"'","�")
   nome-antigo = replace(nome-antigo,'"','�')
   nome-novo = nome-antigo.
   
END PROCEDURE.
