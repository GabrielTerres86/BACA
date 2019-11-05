UPDATE crapcri x
   set dscritic = '1503 - Ja existe um reenvio para analise em andamento. Aguarde.'
where x.cdcritic = 1503;

commit;
