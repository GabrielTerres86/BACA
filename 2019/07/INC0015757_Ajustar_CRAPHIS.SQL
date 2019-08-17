/* 
Solicitação: INC0015757
Objetivo   : Ajustar a coluna CRAPHIS.DSEXTHST para os casos que contém o caracter inválido ASCII = 26 (setinha) nesta coluna. Este caracter está sendo substituído por um hífen (-).
Autor      : Edmar
*/


UPDATE CRAPHIS h
SET h.dsexthst = replace(h.dsexthst, chr(26), '-')
WHERE instr(h.dsexthst, chr(26)) > 0;

COMMIT;