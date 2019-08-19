
INSERT INTO crapace
  (nmdatela,
   cddopcao,
   cdoperad,
   nmrotina,
   cdcooper,
   nrmodulo,
   idevento,
   idambace)
  SELECT 'TELUNI' nmdatela,
         'C' cddopcao,
         op.cdoperad cdoperad,
         ' ' nmrotina,
         op.cdcooper cdcooper,
         1 nrmodulo,
         1 idevento,
         2 idambace
    FROM (select distinct x.cdcooper, x.cdoperad
            from crapace x, crapope ope, crapcop c
           where ope.cdcooper = x.cdcooper
             and ope.cdoperad = x.cdoperad
             and ope.cdsitope = 1
             and ope.cdcooper = c.cdcooper
             and c.flgativo = 1
             and x.nmdatela = 'ATENDA'
             and trim(x.nmrotina) is not null
             and (x.nmrotina = 'EMPRESTIMOS' and x.cddopcao = 'I' or
                 x.nmrotina = 'CARTAO CRED' and x.cddopcao = 'N' or
                 x.nmrotina = 'DSC TITS - PROPOSTA' and x.cddopcao = 'I')
             and not exists (select 1
                              from crapace a
                             where a.cdcooper = x.cdcooper
                               and upper(a.nmdatela) = 'TELUNI'
                               and a.cdoperad = ope.cdoperad
                               and upper(a.cddopcao) = 'C')) op;

commit;                               
