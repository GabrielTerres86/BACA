--INC0056522 - alterar situacao do lancamento

update tbcapt_custodia_lanctos   lct
   set lct.idsituacao = 9
 where lct.idlancamento = 16110574;

commit;
