-- Ajusta o registro bugado
update tbcapt_custodia_lanctos   set qtcotas = 3, vlpreco_unitario = 0.01052720 where idlancamento = 12249352;

update tbcapt_custodia_aplicacao set qtcotas = 0, vlpreco_unitario = 0.01052720 where idaplicacao = 2742615;

update craprda set insaqtot = 1 where cdcooper = 9 and nrdconta = 139971 and nraplica = 1;

commit;