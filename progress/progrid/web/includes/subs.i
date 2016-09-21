/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/rodajava.i
  Autor: B&T/Solusoft
 Função: Substuituição dos caracteres especiais ^ e | para espaço em branco e
         &(e comercial).
-------------------------------------------------------------------------------*/

PROCEDURE Substituir : /* usado pelo programas de relatório */

define input  parameter nome-antigo as char no-undo.
define output parameter nome-novo   as char no-undo.

assign   
   nome-antigo = replace(nome-antigo,"^"," ")
   nome-antigo = replace(nome-antigo,"|","&")
   nome-antigo = replace(nome-antigo,"Þ","=")
   nome-antigo = replace(nome-antigo,"¿","'")
   nome-antigo = replace(nome-antigo,"¬",'"')
   nome-antigo = replace(nome-antigo,"Ð",'+') 
   nome-novo = nome-antigo.
   
END PROCEDURE.   
PROCEDURE TrocaAspas : /* usado pelos zooms */

define input  parameter nome-antigo as char no-undo.
define output parameter nome-novo   as char no-undo.
assign
   nome-antigo = replace(nome-antigo,"'","¿")
   nome-antigo = replace(nome-antigo,'"','¬')
   nome-novo = nome-antigo.
   
END PROCEDURE.
