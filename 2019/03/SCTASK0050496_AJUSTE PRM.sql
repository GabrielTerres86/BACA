update crapprm prm set
prm.cdcooper = 1
WHERE prm.nmsistem = 'CRED'
  AND prm.cdcooper =0
  AND prm.cdacesso = 'DIRETORIO_ARQUIVO_BRC';
commit;

Insert into crapprm values('CRED',2,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC' ,'/micros/creditextil/',null);
Insert into crapprm values('CRED',5,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC' ,'/micros/cecrisacred/',null);
Insert into crapprm values('CRED',6,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC' ,'/micros/credifiesc/',null);
Insert into crapprm values('CRED',7,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC' ,'/micros/credcrea/',null);
Insert into crapprm values('CRED',8,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC' ,'/micros/credelesc/',null);
Insert into crapprm values('CRED',9,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC' ,'/micros/transpocred/',null);
Insert into crapprm values('CRED',10,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC','/micros/credicomin/',null);
Insert into crapprm values('CRED',11,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC','/micros/credifoz/',null);
Insert into crapprm values('CRED',12,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC','/micros/crevisc/',null);
Insert into crapprm values('CRED',13,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC','/micros/scrcred/',null);
Insert into crapprm values('CRED',14,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC','/micros/rodocredito/',null);
Insert into crapprm values('CRED',16,'DIRETORIO_ARQUIVO_BRC','Diretório onde se encontram os arquivos da BRC','/micros/altovale/',null);
commit;



