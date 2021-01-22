/*******************************************************************************************************
30/10/2020 - Projeto Portabilidade - Capital de Giro
             Inserir Parâmetros (CRAPTAB) de Natureza Juridica que permitirão Portabilidade de Capital
             de Giro (Compra).
             Obs: Segundo validação do Télvio da Lista de Naturezas Jurídicas, somente a Natureza
                  2135 - Empresario (Individual) pode fazer Portabilidade de Capital de Giro. 
*******************************************************************************************************/
BEGIN
  --Insere CRAPTAB
  INSERT INTO craptab
    (nmsistem
    ,tptabela
    ,cdempres
    ,cdacesso
    ,tpregist
    ,dstextab
    ,cdcooper)
  VALUES
    ('CRED'  
    ,'GENERI'
    ,0
    ,'NATJURPORTAB'
    ,2135
    ,'Empresario (Individual)'
    ,0);
    
  --Salva 
  COMMIT;  
  
END;
/
