-- Exclusão de participantes no SGE teste em produção, o evento foi excluído mas é necessário excluir a participação dessas pessoas pois aparecem no BI.
delete FROM crapidp a
where a.dtanoage = 2019
and a.nrdconta IN (2944871,
7455992,
2395282,
2269686,
2374811,
6590578,
6034845,
2269686,
929450,
792012, 
3754871,
3705340,
3959767,
7832370,
7244789,
3934845,
1885146,
3857360,
3522067,
649481,
2374811,
6590578,
2395282,
2944871,
7455992,
2269686)
and idevento = 2
and cdoperad = 'F0030538';

COMMIT;


