/*Pegar os saldos do dia 05/11 das seguintes contas e contratos da Acredicoop:
conta 832510 e contrato 301017 - Parcelas 7 e 8
conta 873926 e contrato 300286 - Somente parcela 7*/

BEGIN
  -- conta 832510 e contrato 301017 (Acredicoop)
  insert into TBEPR_CONSIG_CONTRATO_TMP (CDCOOPER, NRDCONTA, NRCTREMP, DTMOVIMENTO, DTGRAVACAO, INCLIDESLIGADO, VLIOFEPR, VLIOFADIC, QTPRESTPAGAS, VLJURAMESATU, VLJURAMESANT, VLSDEV_EMPRATU_D0, VLSDEV_EMPRATU_D1, VLJURA60DIAS, INSTATUSCONTR, INSTATUSPROCES, DSERROPROCES)
  values (2, 832510, 301017, to_date('04-11-2021', 'dd-mm-yyyy'), to_date('02-11-2021', 'dd-mm-yyyy'), 'N', 68.71, 12.05, 3, 0.00, 0.00, 3017.80, 3019.25, 253.33, '1', null, null);
  

  -- conta 832510 e contrato 301017 (Acredicoop), parcelas 07 e 08
  insert into TBEPR_CONSIG_PARCELAS_TMP (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLSALDOPARC, VLMORAATRASO, VLMULTAATRASO, VLIOFATRASO, VLDESCANTEC, DTPAGTOPARC, INPARCELALIQ, INSTATUSPROCES, DSERROPROCES)
  values (2, 832510, 301017, 7, to_date('05-11-2021', 'dd-mm-yyyy'), to_date('02-11-2021', 'dd-mm-yyyy'), 162.39, 0.21, 3.18, 0.05, 0.00, null, '0', null, null);

  insert into TBEPR_CONSIG_PARCELAS_TMP (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLSALDOPARC, VLMORAATRASO, VLMULTAATRASO, VLIOFATRASO, VLDESCANTEC, DTPAGTOPARC, INPARCELALIQ, INSTATUSPROCES, DSERROPROCES)
  values (2, 832510, 301017, 8, to_date('05-11-2021', 'dd-mm-yyyy'), to_date('02-11-2021', 'dd-mm-yyyy'), 156.82, 0.00, 0.00, 0.00, 2.13, null, '0', null, null);
  
--#################--

  -- conta 873926 e contrato 300286 (Acredicoop)
  INSERT into TBEPR_CONSIG_CONTRATO_TMP (CDCOOPER, NRDCONTA, NRCTREMP, DTMOVIMENTO, DTGRAVACAO, INCLIDESLIGADO, VLIOFEPR, VLIOFADIC, QTPRESTPAGAS, VLJURAMESATU, VLJURAMESANT, VLSDEV_EMPRATU_D0, VLSDEV_EMPRATU_D1, VLJURA60DIAS, INSTATUSCONTR, INSTATUSPROCES, DSERROPROCES)
  values (2, 873926, 300286, to_date('04-11-2021', 'dd-mm-yyyy'), to_date('02-11-2021', 'dd-mm-yyyy'), 'N', 63.28, 16.22, 3, 0.00, 0.00, 3481.81, 3483.35, 278.94, '1', null, null);
  

  -- conta 873926 e contrato 300286 (Acredicoop), parcela 07
  insert into TBEPR_CONSIG_PARCELAS_TMP (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLSALDOPARC, VLMORAATRASO, VLMULTAATRASO, VLIOFATRASO, VLDESCANTEC, DTPAGTOPARC, INPARCELALIQ, INSTATUSPROCES, DSERROPROCES)
  values (2, 873926, 300286, 7, to_date('05-11-2021', 'dd-mm-yyyy'), to_date('02-11-2021', 'dd-mm-yyyy'), 397.29, 0.52, 7.78, 0.11, 0.00, null, '0', null, null);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    
END;