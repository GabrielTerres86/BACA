/*
INC0051251
Três aplicações estão com valor negativo e disparam críticas durante o processamento do arquivo gerado para a B3.
Anderson Fossa e Daniel Heinen estão cientes da alteração, após a execução do script, Daniel dará a baixa.
*/

update tbcapt_custodia_lanctos   lct
   set lct.idsituacao = 9
 where lct.idlancamento in (14996862, 15194729, 14670350);

commit;
