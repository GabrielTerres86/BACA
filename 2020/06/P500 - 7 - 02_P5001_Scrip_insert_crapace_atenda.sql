/*
select * from crapace ace
where ace.nmdatela = 'ATENDA'
--and   ace.nmrotina = 'PAGTO POR ARQUIVO'
and   ace.nmrotina = 'TED TRANSF ARQUIVO'
*/


Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
Select ace.nmdatela, ace.cddopcao, ace.cdoperad, 'TED TRANSF ARQUIVO', ace.cdcooper, ace.nrmodulo, ace.idevento, ace.idambace
From crapace ace
where ace.nmdatela = 'ATENDA'
and   ace.nmrotina = 'PAGTO POR ARQUIVO';

commit;
