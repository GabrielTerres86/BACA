-- Created on 08/08/2019 by Rafael Ferreira (Mouts) - T0032702 
DECLARE

BEGIN
  -- Este Script tem por finalidade retornar o backup dos registros alterados no INC0020100

  -- Cursor que identifica o que foi alterado entre o Backup e a tabela atual
  FOR cr_cebBKP IN (SELECT cebBKP.cdcooper, cebBKP.nrdconta, cebBKP.nrconven, cebBKP.qtdfloat, cebBKP.qtdecprz,
                           cebATUAL.rowid ROWID_ATUAL
                      FROM cecred.crapceb_bkpfloat cebBKP, cecred.crapceb cebATUAL
                  WHERE cebBKP.Cdcooper = cebATUAL.Cdcooper
                    and cebBKP.Nrdconta = cebATUAL.Nrdconta
                    and cebBKP.Nrconven = cebATUAL.Nrconven) LOOP
  
    
      -- Tenta efetuar o update, e ignora o registro caso ocorra algum erro
      -- Obs: Utilizo o update pelo Rowid por ser a forma mais performática de encontrar e alterar um registro
      -- o ROWID independe de Indices ou Otimizações do Oracle.
      BEGIN
        UPDATE cecred.crapceb ceb
           SET ceb.qtdfloat = cr_cebBKP.qtdfloat, ceb.qtdecprz = cr_cebBKP.qtdecprz
         WHERE ceb.rowid = cr_cebBKP.ROWID_ATUAL;
      EXCEPTION
        -- Caso ocorra alguma falha ignora o registro atual e continua o próximo
        WHEN OTHERS THEN
          continue;
      END;
    
    END LOOP; -- cr_ceb
  
  COMMIT; -- Commit Geral
END;