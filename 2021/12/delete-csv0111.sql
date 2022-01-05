begin
  
delete tbchq_processamento_parceiro a
where a.nmarquivoimportacao like 'CC011101.CSV';

commit;
end;
