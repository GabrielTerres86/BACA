/*******************************************************************************************************
30/10/2020 - Projeto Portabilidade - Capital de Giro (Script de Rollback)
             Inserir Parâmetros (CRAPTAB) de Natureza Juridica que permitirão Portabilidade de Capital
             de Giro (Compra).
             Obs: Segundo validação do Télvio da Lista de Naturezas Jurídicas, somente a Natureza
                  2135 - Empresario (Individual) pode fazer Portabilidade de Capital de Giro. 
*******************************************************************************************************/
BEGIN
  
  DELETE  craptab
  WHERE  CDCOOPER = 0
  AND    NMSISTEM = 'CRED'
  AND    TPTABELA = 'GENERI'
  AND    CDEMPRES = 0
  AND    CDACESSO = 'NATJURPORTAB' 
  AND    TPREGIST = 2135;
      
  COMMIT;

END;
/
