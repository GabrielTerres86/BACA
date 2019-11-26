PL/SQL Developer Test script 3.0
59
-- Created on 26/11/2019 by T0032420 
DECLARE
  CURSOR cr_tbcc_prejuizo_detalhe IS
    SELECT cdcooper, nrdconta, idlancto, vllanmto
      FROM tbcc_prejuizo_detalhe
     WHERE nrdconta = 122092
       AND cdcooper = 5
       AND cdhistor = 2408
       AND dtmvtolt = '19/11/2019'
       AND vllanmto = 30600.00;
  rw_tbcc_prejuizo_detalhe cr_tbcc_prejuizo_detalhe%ROWTYPE;
  vr_cdcritic   NUMBER;
  vr_dscritic   VARCHAR2(10000);
  vr_exc_saida  EXCEPTION;
  vr_idlancto   tbcc_prejuizo_detalhe.idlancto%TYPE;
  vr_vllanmto   tbcc_prejuizo_detalhe.vllanmto%TYPE;
  vr_cdcooper   tbcc_prejuizo_detalhe.cdcooper%TYPE;
  vr_nrdconta   tbcc_prejuizo_detalhe.nrdconta%TYPE;
BEGIN
  dbms_output.put_line('Conta: 53082');
  --Coop: Acentra
  --Precisa fazer um ajuste de diferença contábil, excluir os lançamentos abaixo em conta da Transpocred:
  --Conta: C/C 12.209-2
  --Lançamento histórico 2408  do dia 19/11/2019 de R$ 30.600,0
  OPEN cr_tbcc_prejuizo_detalhe;
  FETCH cr_tbcc_prejuizo_detalhe INTO rw_tbcc_prejuizo_detalhe;
  IF cr_tbcc_prejuizo_detalhe%FOUND THEN
    vr_idlancto := rw_tbcc_prejuizo_detalhe.idlancto;
    vr_vllanmto := rw_tbcc_prejuizo_detalhe.vllanmto;
    vr_cdcooper := rw_tbcc_prejuizo_detalhe.cdcooper;
    vr_nrdconta := rw_tbcc_prejuizo_detalhe.nrdconta;
  ELSE
    vr_dscritic := 'Lançamento não encontrado';
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_tbcc_prejuizo_detalhe;
  BEGIN
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE idlancto = vr_idlancto
       AND nrdconta = vr_nrdconta
       AND cdcooper = vr_cdcooper;
    UPDATE tbcc_prejuizo
       SET vlsdprej = vlsdprej - vr_vllanmto
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta;
  END;
  dbms_output.put_line('Término');
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    dbms_output.put_line('Mensagem: ' || vr_dscritic);
    RAISE_APPLICATION_ERROR(-20500,vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    vr_dscritic := 'Erro genérico: ' || SQLERRM;
    dbms_output.put_line('Mensagem: ' || vr_dscritic);
    RAISE_APPLICATION_ERROR(-20510,vr_dscritic);
END;
0
0
