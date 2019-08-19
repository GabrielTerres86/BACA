/* PJ530 - Bacenjud fase 2 - SCript para marcar históricos para não considerar na regra do Bacenjud bloqueios */
update craphis a
set a.indutblq='N'
where a.cdhistor not in (1402,1403,2162,1406,2425,2648)
  and a.indebcre='D';
update craphis a
set a.indutblq='S'
where a.cdhistor in (1402,1403,2162,1406,2425,2648);
commit;
