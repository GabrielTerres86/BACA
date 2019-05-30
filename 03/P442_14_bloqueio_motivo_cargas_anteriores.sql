-- Script para ajustar cargas anteriores a liberação bloqueando e exibindo o motivo de bloqueio
BEGIN
  -- Criar motivos de exclusão
  INSERT INTO tbepr_motivo_nao_aprv(cdcooper
                                   ,nrdconta
                                   ,idcarga
                                   ,idmotivo
                                   ,tppessoa
                                   ,nrcpfcnpj_base
                                   ,dtbloqueio)
        SELECT cpa.cdcooper
              ,0
              ,cpa.iddcarga
              ,79
              ,cpa.tppessoa
              ,cpa.nrcpfcnpj_base
              ,SYSDATE
        FROM crapcpa cpa
        WHERE cpa.nrdconta > 0
          AND cpa.cdsituacao IS NULL
          AND EXISTS (SELECT 1
                      FROM tbepr_carga_pre_aprv aprv
                      WHERE aprv.idcarga = cpa.iddcarga
                        AND aprv.cdcooper = cpa.cdcooper);
  
  -- Atualizar CPA das cargas antigas
  UPDATE crapcpa cpa
    SET cpa.dtbloqueio = SYSDATE
       ,cpa.cdoperad_bloque = 1
       ,cpa.cdsituacao = 'B'
  WHERE cpa.nrdconta > 0
    AND cpa.cdsituacao IS NULL;
    
  COMMIT;
END;
