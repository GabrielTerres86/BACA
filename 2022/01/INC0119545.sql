DECLARE
  CURSOR cr_his (pr_cdcooper IN crapcop.cdcooper%TYPE
                ,pr_cdhistor IN craphis.cdhistor%TYPE)IS
    SELECT t.cdhistor, t.dshistor, t.indebcre
      FROM craphis t
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdhistor = pr_cdhistor;
  rw_his  cr_his%ROWTYPE;
  
  CURSOR cr_sld_prj (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT t.vlsdprej, t.idprejuizo
      FROM tbcc_prejuizo t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;
  rw_sld_prj  cr_sld_prj%ROWTYPE;

  vr_indebcre  craphis.indebcre%TYPE;
  vr_found     BOOLEAN;

  vr_incidente VARCHAR2(15);
  vr_cdcooper  crapcop.cdcooper%TYPE;
  vr_nrdconta  crapass.nrdconta%TYPE;
  vr_vllanmto  tbcc_prejuizo.vlsdprej%TYPE;
  vr_cdhistor  craphis.cdhistor%TYPE;
  vr_idlancto  tbcc_prejuizo_detalhe.idlancto%TYPE;

  PROCEDURE registrarVERLOG(pr_cdcooper            IN crawepr.cdcooper%TYPE
                           ,pr_nrdconta            IN crawepr.nrdconta%TYPE
                           ,pr_dstransa            IN VARCHAR2      -- Operacao que foi efetuada
                           ,pr_dsCampo             IN VARCHAR       -- ITEM - Campo alterado
                           ,pr_antes               IN VARCHAR2
                           ,pr_depois              IN VARCHAR2) IS

 

    vr_dstransa             craplgm.dstransa%TYPE;
    vr_descitem             craplgi.nmdcampo%TYPE;
    vr_nrdrowid             ROWID;
    vr_risco_anterior       VARCHAR2(10);

 

  BEGIN

    vr_dstransa := pr_dstransa;

    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_dstransa => vr_dstransa
                        ,pr_dscritic => ''
                        ,pr_cdoperad => '1'
                        ,pr_dsorigem => 'SCRIPT'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 0
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ''
                        ,pr_nrdrowid => vr_nrdrowid);

    IF trim(pr_dsCampo) IS NOT NULL THEN
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => pr_dsCampo
                               ,pr_dsdadant => pr_antes
                               ,pr_dsdadatu => pr_depois);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END registrarVERLOG;
  
  
 PROCEDURE prc_gera_lct (prm_cdcooper IN craplcm.cdcooper%TYPE,
                         prm_nrdconta IN craplcm.nrdconta%TYPE,
                         prm_vllanmto IN craplcm.vllanmto%TYPE,
                         prm_cdhistor IN craplcm.cdhistor%TYPE) IS
  
    -- Variáveis negócio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Variáveis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT dtmvtolt
      INTO   vr_dtmvtolt
      FROM   crapdat
      WHERE  cdcooper = prm_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar Data da Cooperatriva. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;
    
    dbms_output.put_line(' ');
    dbms_output.put_line('   Parâmetros (LCM VLR):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Data...........: '||To_Char(vr_dtmvtolt,'dd/mm/yyyy'));
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line(' ');
    
    --Busca Data Atual da Cooperativa
    BEGIN
      SELECT a.idprejuizo
        INTO vr_idprejuizo
        FROM tbcc_prejuizo a
       WHERE a.cdcooper = prm_cdcooper
         AND a.nrdconta = prm_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Buscar chave prejuizo. Conta: '|| prm_nrdconta ||', coop:'|| prm_cdcooper ||' Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;

    -- Cria lançamento (Tabela tbcc_prejuizo_detalhe)
    prej0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => prm_cdcooper
                                     ,pr_nrdconta   => prm_nrdconta
                                     ,pr_dtmvtolt   => vr_dtmvtolt
                                     ,pr_cdhistor   => prm_cdhistor
                                     ,pr_idprejuizo => vr_idprejuizo
                                     ,pr_vllanmto   => prm_vllanmto
                                     ,pr_dthrtran   => SYSDATE
                                     ,pr_cdcritic   => vr_cdcritic
                                     ,pr_dscritic   => vr_dscritic);
    IF Nvl(vr_cdcritic,0) > 0 OR Trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_erro; 
    ELSE
      dbms_output.put_line('   Lançamento do Histórico '||prm_cdhistor||' efetuado com Sucesso na Coop\Conta '||prm_cdcooper||'\'||prm_nrdconta||'.');  
    END IF;

    registrarVERLOG(pr_cdcooper  => prm_cdcooper
                   ,pr_nrdconta  => prm_nrdconta
                   ,pr_dstransa  => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                   ,pr_dsCampo   => 'pc_gera_lcto_extrato_prj'
                   ,pr_antes     => ''
                   ,pr_depois    => prm_vllanmto);

  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_gera_lct: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_gera_lct: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_gera_lct. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_gera_lct;  

BEGIN
  

------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

---------------------------------------------------
  --#1 Civia 14.922.5 (2721 - 16,97)
  vr_incidente := 'INC0119545';
  vr_cdcooper  := 13;
  vr_nrdconta  := 149225;
  vr_vllanmto  := 16.97;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);


---------------------------------------------------
  --#2 Civia 15.218.8 (2721  15,95)
  vr_cdcooper  := 13;
  vr_nrdconta  := 152188;
  vr_vllanmto  := 15.95;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
---------------------------------------------------
  --#3 Civia 27.336.8 (2721  4,22)
  vr_cdcooper  := 13;
  vr_nrdconta  := 273368;
  vr_vllanmto  := 4.22;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
---------------------------------------------------
  --#4 Civia 39.245.6 (2721  17,50)
  vr_cdcooper  := 13;
  vr_nrdconta  := 392456;
  vr_vllanmto  := 17.50;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
---------------------------------------------------
  --#5 Credicomin 12.177.0 (2721 2,05 )
  vr_cdcooper  := 10;
  vr_nrdconta  := 121770;
  vr_vllanmto  := 2.05;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
             
---------------------------------------------------
  --#6 Credelesc 3.436.3 (2721   2,75 )
  vr_cdcooper  := 8;
  vr_nrdconta  := 34363;
  vr_vllanmto  := 2.75;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             

---------------------------------------------------
  --#7 Credelesc 33189 (2721   3,25) 
  vr_cdcooper  := 8;
  vr_nrdconta  := 33189;
  vr_vllanmto  := 3.25;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             

---------------------------------------------------
  --#8 Credifoz 44.121.0 (2721   11,21)
  vr_cdcooper  := 11;
  vr_nrdconta  := 441210;
  vr_vllanmto  := 11.21;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);
             
---------------------------------------------------
  --#9 Crevisc 13.960.2 (2721  6,53)
  vr_cdcooper  := 12;
  vr_nrdconta  := 139602;
  vr_vllanmto  := 6.53;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);             

---------------------------------------------------
  --#10 Únilos 10.906.1 (2721  2,75)
  vr_cdcooper  := 6;
  vr_nrdconta  := 109061;
  vr_vllanmto  := 2.75;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);  
             
             
---------------------------------------------------
  --#11 Alto Vale 34.514.8 (2721 10,67)
  vr_cdcooper  := 16;
  vr_nrdconta  := 345148;
  vr_vllanmto  := 10.67;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);  
             
---------------------------------------------------
  --#12 Alto Vale 27.933.1 (2721 10,05)
  vr_cdcooper  := 16;
  vr_nrdconta  := 279331;
  vr_vllanmto  := 10.05;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);  
             

---------------------------------------------------
  --#13 Viacredi 675.823.1 (2721 36,65)
  vr_cdcooper  := 1;
  vr_nrdconta  := 6758231;
  vr_vllanmto  := 36.65;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);  
             
             
---------------------------------------------------
  --#13 Viacredi 1038.235.6 (2721 66,28)
  vr_cdcooper  := 1;
  vr_nrdconta  := 10382356;
  vr_vllanmto  := 66.28;
  vr_cdhistor  := 2721;
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');

  prc_gera_lct (prm_cdcooper => vr_cdcooper,
                         prm_nrdconta => vr_nrdconta,
                         prm_vllanmto => vr_vllanmto,
                         prm_cdhistor => vr_cdhistor);  

             
             
                          
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------


  --Salva
  COMMIT;

  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
------------ BLOCO PRINCIPAL - FIM ---------------------


EXCEPTION    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
END;
