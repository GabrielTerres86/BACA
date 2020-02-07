/* Concede permissao a nova rotina 'T' para quem ja tem permissao na rotina 'I' */

insert into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
(select nmdatela, 'T' cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace
  from crapace
 where UPPER(NMDATELA) = 'CONTAS'
   and UPPER(NMROTINA) = 'GRUPO ECONOMICO'
   and UPPER(CDDOPCAO) = 'I');

commit; 