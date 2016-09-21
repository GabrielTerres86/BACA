/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/rodajavalong.i
  Autor: Martin - SQLWorks
 Função: Recebe uma temp-table que corresponde à uma linha de comando JavaScript, 
         monta as tags html para um comando JavaScript e utiliza um comando 
         &out para enviar a sequencia para a saída.
         Utilizado quando a linha de comando é muito longa, tal como um array.
          
         definir no programa que chama include a seguinte temp-table:
         
         def temp-table tt-javaFrase no-undo
             field seq as int
             field frase as char
             field agregado as char
             field jump as log
             index idx1 seq.                                                                   
                                                                                      
-------------------------------------------------------------------------------*/

{&OUT} SKIP(1)
       '<SCRIPT LANGUAGE="JAVASCRIPT">' SKIP.
FOR EACH tt-javaFrase:
    IF tt-javaFrase.seq = 1 THEN DO:
        {&OUT} tt-javaFrase.frase.
    END.
    ELSE
       {&OUT} tt-javaFrase.agregado tt-javaFrase.frase.
    IF tt-javaFrase.jump THEN {&out} SKIP.
END.
{&OUT} '</SCRIPT>' SKIP.
