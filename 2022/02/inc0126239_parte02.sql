DECLARE

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;

  vr_cdcooper   crapepr.cdcooper%TYPE;
  vr_nrdconta   crapepr.nrdconta%TYPE;
  vr_nrctremp   crapepr.nrctremp%TYPE;
  vr_vllanmto   craplem.vllanmto%TYPE;
  vr_cdhistor   craplem.cdhistor%TYPE;
  vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;

  vr_conta     GENE0002.typ_split;
  vr_reg_conta GENE0002.typ_split;

BEGIN

  vr_conta := GENE0002.fn_quebra_string(pr_string  => '7;262935;2408;26,77|1;10376836;2722;20,62|1;10101373;2721;0,60|',
                                        pr_delimit => '|');
  IF vr_conta.COUNT > 0 THEN
  
    FOR vr_idx_lst IN 1 .. vr_conta.COUNT - 1 LOOP
      vr_reg_conta := GENE0002.fn_quebra_string(pr_string  => vr_conta(vr_idx_lst),
                                                pr_delimit => ';');
    
      vr_cdcooper := vr_reg_conta(1);
      vr_nrdconta := vr_reg_conta(2);
      vr_cdhistor := vr_reg_conta(3);
      vr_vllanmto := to_number(vr_reg_conta(4));
    
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    
      BEGIN
        SELECT a.idprejuizo
          INTO vr_idprejuizo
          FROM tbcc_prejuizo a
         WHERE a.cdcooper = vr_cdcooper
           AND a.nrdconta = vr_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: ' ||
                         SubStr(SQLERRM, 1, 255);
          RAISE vr_exc_erro;
      END;
    
      prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => vr_cdcooper,
                                        pr_nrdconta   => vr_nrdconta,
                                        pr_dtmvtolt   => rw_crapdat.dtmvtolt,
                                        pr_cdhistor   => vr_cdhistor,
                                        pr_idprejuizo => vr_idprejuizo,
                                        pr_vllanmto   => vr_vllanmto,
                                        pr_dthrtran   => SYSDATE,
                                        pr_cdcritic   => vr_cdcritic,
                                        pr_dscritic   => vr_dscritic);
      IF Nvl(vr_cdcritic, 0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      ELSE
        dbms_output.put_line('   Lançamento do Histórico '||vr_cdhistor||' efetuado com Sucesso na Coop\Conta '||vr_cdcooper||'\'||vr_nrdconta||'.');  
      END IF;
    
    END LOOP;
  END IF;

  BEGIN
    DELETE FROM tbcc_prejuizo_detalhe
     WHERE cdcooper = 1
       AND nrdconta = 10376836
       AND cdhistor = 2408
       AND vllanmto IN (900, 9.77, 46.11, 45.85)
       AND dtmvtolt = to_date('04/02/2022', 'dd/mm/rrrr');
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao excluir lançamentos. Erro : ' ||
                     SUBSTR(0, 200, SQLERRM);
      RAISE vr_exc_erro;
  END;

  BEGIN
    UPDATE tbcc_prejuizo a
       SET a.vlsdprej = Nvl(vlsdprej, 0) - 1001.73
     WHERE a.cdcooper = 1
       AND a.nrdconta = 10376836;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: ' ||
                     SubStr(SQLERRM, 1, 255);
      RAISE vr_exc_erro;
  END;

  BEGIN
    UPDATE tbcc_prejuizo a
       SET a.vlsdprej = Nvl(vlsdprej, 0) + 26.77
     WHERE a.cdcooper = 7
       AND a.nrdconta = 262935;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Prejuízo. Erro: ' ||
                     SubStr(SQLERRM, 1, 255);
      RAISE vr_exc_erro;
  END;

  COMMIT;

  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em ' ||
                       To_Char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20111, SQLERRM);
END;
