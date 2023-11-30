begin
  update crapaca c
     set c.lstparam = 'pr_nrcpfcgc,pr_cdvaga'
   where c.nmdeacao = 'BUSCA_NOME_CANDIDATO';
 commit;
end;
