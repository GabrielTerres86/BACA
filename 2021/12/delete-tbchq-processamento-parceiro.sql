begin
  
delete tbchq_processamento_parceiro a
where a.nmarquivoimportacao like '%CC061201.CSV%';

commit;
end;
