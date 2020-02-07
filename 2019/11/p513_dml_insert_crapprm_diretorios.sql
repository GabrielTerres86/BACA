--diretorio do arquivo de conciliacao saque e pague recebido
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_RECEBE','Saque e Pague - Diretorio do arquivo de conciliacao recebido (servidor UNIX)',
             '/usr/connect/SAQUEPAGUE/recebe');
COMMIT;      

--diretorio dos arquivos recebidos de conciliacao saque e pague apos processados
insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
             values ('CRED',0,'SAQUE_PAGUE_RECEBIDOS','Saque e Pague - Diretorio dos arquivos de conciliacao recebidos salvos (servidor UNIX), após serem processados',
             '/usr/connect/SAQUEPAGUE/recebidos');
COMMIT;   