/*
INC0051251
Tr�s aplica��es est�o com valor negativo e disparam cr�ticas durante o processamento do arquivo gerado para a B3.
Anderson Fossa e Daniel Heinen est�o cientes da altera��o, ap�s a execu��o do script, Daniel dar� a baixa.
*/

update tbcapt_custodia_lanctos   lct
   set lct.idsituacao = 9
 where lct.idlancamento in (14996862, 15194729, 14670350);

commit;
