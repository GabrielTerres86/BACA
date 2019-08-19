update craptel 
   set cdopptel = '@,C,T,R,L,E',
        lsopptel = 'Acesso,Consulta,Remessa,Relatorio,Log,Efetivacao'
where nmdatela like 'UPPGTO';

insert into crapace(nmdatela, cddopcao, cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
values('UPPGTO', 'E', 'F0030497', '', 1, 1, 0, 2);

insert into crapace(nmdatela, cddopcao, cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
values('UPPGTO', 'E', 'F0030598', '', 1, 1, 0, 2);

insert into crapace(nmdatela, cddopcao, cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
values('UPPGTO', 'E', 'F0030636', '', 1, 1, 0, 2);

insert into crapace(nmdatela, cddopcao, cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
values('UPPGTO', 'E', 'F0031411', '', 1, 1, 0, 2);

insert into crapace(nmdatela, cddopcao, cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
values('UPPGTO', 'E', 'F0030868', '', 1, 1, 0, 2);

insert into crapace(nmdatela, cddopcao, cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
values('UPPGTO', 'E', 'F0030215', '', 1, 1, 0, 2);

COMMIT;
