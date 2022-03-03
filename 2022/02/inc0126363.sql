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

  vr_conta := GENE0002.fn_quebra_string(pr_string  => '13;187127;2721;5,70|13;290670;2721;13,75|13;286583;2721;7,50|1;10382356;2721;20,42|16;403725;2721;7,50|',
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
