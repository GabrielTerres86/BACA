-- SCTASK0050222 - Regerar relatórios de cheques que deram problemas no dia 19/02
update crapslr a 
set a.dserrger = null,
    a.flgerado = 'N',
    a.dtiniger = NULL,
    a.dtfimger = NULL
WHERE a.dtmvtolt = '19/02/2019'
and (a.dsjasper like '%crrl392%'
OR  a.dsjasper like '%crrl393%')
and a.dserrger is not null;

COMMIT;
