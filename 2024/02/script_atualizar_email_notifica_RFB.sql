BEGIN         
  UPDATE crapprm prm
     SET prm.dsvlrprm = 'jose.zunino@ailos.coop.br;jeferson.nunes@ailos.coop.br'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper IN(3,0) --> Busca tanto da passada, quanto da geral (se existir)
     AND prm.cdacesso = 'EMAIL_REM_RFB';
  COMMIT;
END;    