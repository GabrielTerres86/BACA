begin
  insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  values ('CRED', 0, 'DIR_ARQ_REINF', 'Diretório para geração dos arquivos da REINF.', '/usr/sistemas/SCCI/REINF');
  
  commit;
end;
