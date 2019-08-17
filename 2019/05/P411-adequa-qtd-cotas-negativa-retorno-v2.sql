
/* Script de retorno */

update tbcapt_custodia_lanctos set qtcotas = 1980000 where idaplicacao = 3531786 and idlancamento = 5971581;
update tbcapt_custodia_lanctos set qtcotas = -10631  where idaplicacao = 3531786 and idlancamento = 5971580;

commit;
