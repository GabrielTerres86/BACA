DECLARE

BEGIN

  UPDATE cecred.tbepr_consig_movimento_tmp cmt
     SET cmt.instatusproces = 'P'
   WHERE cmt.cdcooper = 13
     AND cmt.nrdconta = 154520
     AND cmt.nrctremp = 245701
     AND TRUNC(cmt.dtmovimento) <= TRUNC(TO_DATE('10/02/2023', 'dd/mm/yyyy'));

  UPDATE cecred.tbepr_consig_movimento_tmp cmt
     SET cmt.instatusproces = 'P'
   WHERE cmt.cdcooper = 1
     AND cmt.nrdconta = 9519947
     AND cmt.nrctremp = 6301326
     AND cmt.idseqmov IN (4057537, 4057538)
     AND TRUNC(cmt.dtmovimento) = TRUNC(TO_DATE('10/01/2023', 'dd/mm/yyyy'));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
