/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/rodajava.i
  Autor: B&T/Solusoft
 Fun��o: Recebe uma string que corresponde � uma linha de comando JavaScript, 
         monta as tags html para um comando JavaScript e utiliza um comando 
         &out para enviar a sequencia para a sa�da.
-------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER frase AS CHARACTER.

{&OUT} SKIP(1)
       '<SCRIPT LANGUAGE="JAVASCRIPT">' SKIP.
{&OUT} frase SKIP.
{&OUT} '</SCRIPT>' SKIP.
