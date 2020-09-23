-- INC0062052 - Alerta de email

update tbcapt_custodia_lanctos   lct
   set lct.idsituacao = 9
 where lct.idlancamento = 17533006;

commit;
