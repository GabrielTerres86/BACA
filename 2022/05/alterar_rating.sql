begin
UPDATE tbrisco_operacoes a
SET a.dtrisco_rating_autom = to_date('20/05/2022','dd/mm/yyyy'),
    a.inrisco_rating = 2,
    a.inrisco_rating_autom = 2,
    a.dtrisco_rating = to_date('20/05/2022','dd/mm/yyyy'),
    a.insituacao_rating = 4,
    a.innivel_rating = 1,
    a.inpontos_rating = 1,
    a.insegmento_rating = 'SEM GARANTIA',
    a.dtvencto_rating = to_date('25/12/2022','dd/mm/yyyy'),
    a.qtdiasvencto_rating = 180,
    a.idrating = 1
WHERE a.CDCOOPER = 1 
AND a.NRCPFCNPJ_BASE IN 
(41009322869)
and a.tpctrato = 68;
commit;
end;
