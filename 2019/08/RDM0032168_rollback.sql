
update tbcapt_custodia_lanctos 
   set idsituacao = 9 -- critica
 where idlancamento in (select idlancamento from tbcapt_custodia_conteudo_arq where idarquivo = 18302)
   and idsituacao <> 8; -- exceto o registro que deu sucesso

commit;