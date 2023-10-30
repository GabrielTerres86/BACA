DECLARE

BEGIN

  INSERT INTO cecred.tbgen_batch_param
    (idparametro
    ,qtparalelo
    ,qtreg_transacao
    ,cdcooper
    ,cdprograma)
  VALUES
    ((SELECT MAX(bp.idparametro) + 1
       FROM cecred.tbgen_batch_param bp)
    ,20
    ,0
    ,1
    ,'CRPS782');

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
