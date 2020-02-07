BEGIN
  
  INSERT INTO crapprm(nmsistem
                     ,cdcooper
                     ,cdacesso
                     ,dstexprm
                     ,dsvlrprm)
               VALUES('CRED'
                     ,0
                     ,'EMAIL_IMPORT_CPC'
                     ,'Comunicar erro na importação dos arquivos CPC'
                     ,'fernanda.buettgen@ailos.coop.br;debora.veras@ailos.coop.br;ligia.pickler@ailos.coop.br;joice.reis@ailos.coop.br;ligia.russi@ailos.coop.br;juliana@ailos.coop.br;luana@ailos.coop.br');
  
  COMMIT;
  
END;  
