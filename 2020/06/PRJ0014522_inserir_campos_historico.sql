BEGIN
  INSERT INTO TBCADAST_CAMPO_HISTORICO 
    (NMTABELA_ORACLE, 
     NMCAMPO, 
     DSCAMPO) 
  VALUES 
    ('TBCADAST_PESSOA_TELEFONE', 
     'INPRINCIPAL', 
     'Indicador do telefone principal');
     
  INSERT INTO TBCADAST_CAMPO_HISTORICO 
    (NMTABELA_ORACLE, 
     NMCAMPO, 
     DSCAMPO) 
  VALUES 
    ('TBCADAST_PESSOA_TELEFONE', 
     'INWHATSAPP', 
     'Indicador se o telefone possui whatsapp');
     
  INSERT INTO TBCADAST_CAMPO_HISTORICO 
    (NMTABELA_ORACLE, 
     NMCAMPO, 
     DSCAMPO) 
  VALUES 
    ('TBCADAST_PESSOA_EMAIL', 
     'INPRINCIPAL', 
     'Indicador do e-mail principal');

  COMMIT;   
END;     
