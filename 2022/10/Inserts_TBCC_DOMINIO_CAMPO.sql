DECLARE
  vr_code NUMBER;
  vr_errm VARCHAR2(64);
BEGIN
  
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
  (nmdominio
  ,cddominio
  ,dscodigo)
  VALUES
  ('TIPOSCHAVEPIX'
  ,'CPF'
  ,'1');
  
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOSCHAVEPIX'
    ,'CNPJ'
    ,'1');
    
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOSCHAVEPIX'
    ,'EMAIL'
    ,'2'); 

  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOSCHAVEPIX'
    ,'PHONE'
    ,'3');    
       
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOSCHAVEPIX'
    ,'EVP'
    ,'4'); 
    
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOCONTA'
    ,'CACC'
    ,'1'); 

  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOCONTA'
    ,'SVGS'
    ,'3'); 

  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('TIPOCONTA'
    ,'TRAN'
    ,'9'); 
    
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDORIGEMSOLICITACAO'
    ,'010'
    ,'Depósito à Vista');  

  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDORIGEMSOLICITACAO'
    ,'060'
    ,'Cota Capital');    

  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T
    (nmdominio
    ,cddominio
    ,dscodigo)
  VALUES
    ('CDORIGEMSOLICITACAO'
    ,'061'
    ,'Sobras');     
    
  COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao inserir Tipos de Chave Pix - ' || vr_code || ' / ' || vr_errm);
END;    
