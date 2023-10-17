begin
INSERT INTO cecred.crapprm(
  nmsistem,
  cdcooper,
  cdacesso,
  dstexprm,
  dsvlrprm) 
  VALUES('CRED',
         0,
         'DIR_658_ARQ_TOPAZ',
         'Diretorio que recebe os arquivos manutenção cotas, Sicredi',
         '/usr/connect/sicredi/recebe');
commit;
end;
