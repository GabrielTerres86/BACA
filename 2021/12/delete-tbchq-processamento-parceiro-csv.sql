begin
  
delete tbchq_processamento_parceiro a
where a.nmarquivoimportacao like 'CC031101.CSV';

commit;
end;
