-- Created on 01/12/2020 by T0032717 
DECLARE 
  vr_dtlibera tbepr_renegociacao.dtlibera%TYPE;

BEGIN
  -- apagando historicos gerados para dia 16/11
  -- manter o hist versao 2
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (1722660, 1734463, 1746779, 1752508, 1765020, 1769609, 1806530) AND nrversao = 3;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (1722660, 1734463, 1746779, 1752508, 1765020, 1769609, 1806530) AND nrversao = 3;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (1722660, 1734463, 1746779, 1752508, 1765020, 1769609, 1806530) AND nrversao = 3;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (1722660, 1734463, 1746779, 1752508, 1765020, 1769609, 1806530) AND nrversao = 3;
  -- manter o hist versao 1  
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (2755179, 2793821) AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (2755179, 2793821) AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (2755179, 2793821) AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 10779841 AND nrctremp IN (2755179, 2793821) AND nrversao = 2;
  -- 17/11  
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 10533710 AND nrctremp IN (1639574, 1828864, 2717336) AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 10533710 AND nrctremp IN (1639574, 1828864, 2717336) AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10533710 AND nrctremp IN (1639574, 1828864, 2717336) AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 10533710 AND nrctremp IN (1639574, 1828864, 2717336) AND nrversao = 2;
  -- civia 17/11
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 13 AND nrdconta = 371327 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 13 AND nrdconta = 371327 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 13 AND nrdconta = 371327 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 13 AND nrdconta = 371327 AND nrversao = 2;
  -- 18/11 -- apagar versao 2 de todos contratos da conta
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 10852409 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 10852409 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10852409 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 10852409 AND nrversao = 2;
  -- 19/11 -- apagar versao 2 de todos contratos da conta
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 6694691 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 6694691 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 6694691 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 6694691 AND nrversao = 2;
  -- 23/11
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 9196595 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 9196595 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 9196595 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 9196595 AND nrversao = 2;
  -- 26/11
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 8672270 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 8672270 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 8672270 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 8672270 AND nrversao = 2;
  -- 27/11
  DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 7792611 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 7792611 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 7792611 AND nrversao = 2;
  DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 7792611 AND nrversao = 2;

  SELECT dtlibera INTO vr_dtlibera FROM tbepr_renegociacao WHERE cdcooper = 1 AND nrdconta = 80427650;
  -- contrato nao efetivado ainda
  IF vr_dtlibera IS NULL THEN
    -- limpar as tabelas
    DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao = 1;
    DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao = 1;
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao = 1;
    DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao = 1;
  ELSE
    -- limpar possiveis versoes da proxima efetivacao
    DELETE FROM tbepr_renegociacao_crawepr WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao >= 2;
    DELETE FROM tbepr_renegociacao_crapepr WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao >= 2;
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao >= 2;
    DELETE FROM tbepr_renegociacao_crappep WHERE cdcooper = 1 AND nrdconta = 80427650 AND nrversao >= 2;
  END IF;
  
  COMMIT;
  
END;
