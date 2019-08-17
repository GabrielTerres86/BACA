

update tbcapt_custodia_aplicacao set dscodigo_b3 = 'RDB0181J17R', qtcotas = 0 where idaplicacao = 666940;

-- antes era RDB0180XXNC
update tbcapt_custodia_aplicacao set dscodigo_b3 = null where idaplicacao = 391124;

commit;