

-- Carrega o dscodigo_b3 = 'RDB0181FG1M' e atualiza as cotas, já que já foi resgatado manualmente na B3.
update tbcapt_custodia_aplicacao set dscodigo_b3 = 'RDB0181FG1M', qtcotas = 1046 where idaplicacao = 626050;

-- Originalmente dscodigo_b3 = 'RDB0181J17R' - Resgatado total
update tbcapt_custodia_aplicacao set dscodigo_b3 = null where idaplicacao = 666940;

commit;