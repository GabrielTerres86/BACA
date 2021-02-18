/*******************************************************************************************************
30/10/2020 - Projeto Portabilidade - Capital de Giro
             Inserir Par�metros (CRAPTAB) de Natureza Juridica que permitir�o Portabilidade de Capital
             de Giro (Compra).
             Obs: Segundo valida��o do T�lvio da Lista de Naturezas Jur�dicas, somente a Natureza
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
