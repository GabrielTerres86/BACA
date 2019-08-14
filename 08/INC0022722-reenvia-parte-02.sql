
update tbcapt_custodia_lanctos 
   set idsituacao = 2 -- Pendente de Reenvio
 where idlancamento in (select idlancamento from tbcapt_custodia_conteudo_arq where idarquivo = 18302)
   and idsituacao = 9 -- Critica
   and idlancamento >= 7650086;

-- atualiza 79.673 registros

commit;
