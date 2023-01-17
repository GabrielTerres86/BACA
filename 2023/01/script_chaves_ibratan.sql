BEGIN
  
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'URL_CONSULTA_IBRATAN', 'URL consulta biro Ibratan','https://app.capacitor.digital/api/commands-raw/Cmd001AtzSubmeterConsultas');
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'URL_RESPOSTA_IBRATAN', 'URL resposta biro Ibratan','https://app.capacitor.digital/api/commands-raw/Cmd001AtzBuscarResposta?protocolo=');

 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'ACCESSKEY_BIRO_IBRATAN', 'Chave AccessKey consulta/resposta biro Ibratan','9f64f2bda96248299d30a9a3e5575cb9'); 
  
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'SECRETKEY_BIRO_IBRATAN', 'Chave SecretKey consulta/resposta biro Ibratan','46ed0313698b42519e63553c9b0b28f49bf571a967a7432c8ef4222981519c3b49b30b083dee4ac68cd99787331f8c4adb92e7f90be740bdbbdc92d90973f101');  
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'PATH_WALLET_IBRATAN', 'Path wallet certificado https Ibratan','file:/u03/app/oracle/admin/AILOSTST/ibratan_wallet');
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'PASSWORD_WALLET_IBRATAN', 'Password wallet certificado https Ibratan','cert2022ibra');
 
 INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'CHAVE_LIGA_NOVO_BIRO_IBRATAN'
    ,1
    ,0);
        
  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'CHAVE_LIGA_NOVO_BIRO_IBRATAN')
    ,3
    ,1);

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
                                              

 

