DECLARE

BEGIN

  update cecred.tbepr_consig_parcelas_tmp
     SET nrdconta = 99865858
   where cdcooper = 10
     and nrctremp = 38918;

  update cecred.tbepr_consig_contrato_tmp
     SET nrdconta = 99865858
   where cdcooper = 10
     and nrctremp = 38918;

  update cecred.tbepr_consig_movimento_tmp
     SET nrdconta = 99865858
   where cdcooper = 10
     and nrctremp = 38918;

  update cecred.tbepr_consig_parcelas_tmp
     SET nrdconta = 99865858
   where cdcooper = 10
     and nrctremp = 42024;

  update cecred.tbepr_consig_contrato_tmp
     SET nrdconta = 99865858
   where cdcooper = 10
     and nrctremp = 42024;

  update cecred.tbepr_consig_movimento_tmp
     SET nrdconta = 99865858
   where cdcooper = 10
     and nrctremp = 42024;

  commit;

EXCEPTION

  WHEN OTHERS THEN
  
    rollback;
  
END;
