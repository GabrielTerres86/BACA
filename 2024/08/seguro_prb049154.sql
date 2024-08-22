BEGIN 
INSERT INTO cecred.crapprm(nmsistem,
                           cdcooper,
                           cdacesso,
                           dstexprm,
                           dsvlrprm)
VALUES ('CRED',
       0,
       'AUTBUR_SCRIPT_SFTP_ICATU',
       'Script para envio e recebimento dos arquivos ICATU via SFTP',
       '/usr/local/bin/exec_comando_oracle.sh perl_remoto /usr/local/cecred/bin/sftp_envia_recebe_icatu.pl');


  UPDATE cecred.tbseg_parametros_prst p
     SET p.enderftp = 'producao.icatuseguros.com.br', 
         p.loginftp = 'Producao-AilosTST',
         p.senhaftp = 'TsA!xvnj@109'; 
  COMMIT;
END;
/
