begin  
  update tbcadast_pessoa_endereco
  set nrlogradouro = trunc(nrlogradouro)
  where nrlogradouro <> trunc(nrlogradouro);
  commit;
exception
  when others then
       rollback;
end;