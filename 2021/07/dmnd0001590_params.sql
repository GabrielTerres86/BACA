INSERT INTO crappat (
CDPARTAR,
NMPARTAR,
TPDEDADO
) VALUES (
117,
'ASSEMBLEIA COM MODELO DE DELEGADOS (S/N)',
2
);


INSERT INTO crappco (
cdpartar,
cdcooper,
dsconteu
) select 117,cdcooper,'N' from crapcop;

commit;