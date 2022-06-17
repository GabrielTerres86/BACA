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
  vr_nrdocmto  INTEGER;
  vr_incrineg  INTEGER;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(1000);
  vr_excerro   EXCEPTION;
  vr_des_erro  VARCHAR2(1000);

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
  
    -- Vari�veis neg�cio
    vr_dtmvtolt    craplcm.dtmvtolt%TYPE;
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_cdhistor    tbcc_prejuizo_detalhe.cdhistor%TYPE;

    -- Vari�veis Tratamento Erro
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
    dbms_output.put_line('   Par�metros (LCM VLR):');
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
        vr_dscritic := 'Erro ao Buscar chave prejuizo. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro; 
    END;

    -- Cria lan�amento (Tabela tbcc_prejuizo_detalhe)
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
      dbms_output.put_line('   Lan�amento do Hist�rico '||prm_cdhistor||' efetuado com Sucesso na Coop\Conta '||prm_cdcooper||'\'||prm_nrdconta||'.');  
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


  PROCEDURE prc_atlz_prejuizo (prm_cdcooper IN craplcm.cdcooper%TYPE,
                               prm_nrdconta IN craplcm.nrdconta%TYPE,
                               prm_vllanmto IN craplcm.vllanmto%TYPE,
                               prm_cdhistor IN craplcm.cdhistor%TYPE,
                               prm_tipoajus IN VARCHAR2) IS
  
    -- Vari�veis neg�cio
    vr_idprejuizo  tbcc_prejuizo.idprejuizo%TYPE;
    vr_tipoacao    BOOLEAN;
    vr_vlsdprej    tbcc_prejuizo.vlsdprej%TYPE;

    -- Vari�veis Tratamento Erro
    vr_erro        EXCEPTION;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);

  BEGIN

    OPEN cr_sld_prj (pr_cdcooper => prm_cdcooper
                    ,pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj INTO rw_sld_prj;
    vr_found    := cr_sld_prj%FOUND;
    vr_vlsdprej := rw_sld_prj.vlsdprej;
    CLOSE cr_sld_prj;

    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro ao buscar Saldo Prejuizo Cop/Cta (' ||prm_cdcooper || '/'||prm_nrdconta||')';
      RAISE vr_erro;  
    END IF;
    vr_found := NULL;

    dbms_output.put_line(' ');
    dbms_output.put_line('   Par�metros (prc_atlz_prejuizo):');
    dbms_output.put_line('     Cooperativa....: '||prm_cdcooper);
    dbms_output.put_line('     Conta..........: '||prm_nrdconta);
    dbms_output.put_line('     Valor..........: '||prm_vllanmto);
    dbms_output.put_line('     Historico......: '||prm_cdhistor);
    dbms_output.put_line('     Tipo Ajuste....: '||prm_tipoajus);
    dbms_output.put_line('     Sld Prej. Antes: '||vr_vlsdprej);

    IF prm_tipoajus IS NULL
    OR prm_tipoajus NOT IN ('E','I') THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: Tipo de Ajuste invalido! (' ||prm_tipoajus||')';
      RAISE vr_erro;  
    END IF;

    -- Verificar o historico a ser deletado
    OPEN cr_his (pr_cdcooper => prm_cdcooper
                ,pr_cdhistor => prm_cdhistor);
    FETCH cr_his INTO rw_his;
    vr_found    := cr_his%FOUND;
    vr_indebcre := rw_his.indebcre;
    CLOSE cr_his;

    IF NOT vr_found THEN
      vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: Historico n�o encontrato Cop/Hist (' ||prm_cdcooper || '/'||prm_cdhistor||')';
      RAISE vr_erro;  
    END IF;

    IF prm_tipoajus = 'E' THEN --Exclus�o
      IF vr_indebcre = 'C' THEN
         -- Exclus�o de CREDITO, diminui Saldo Prejuizo
         vr_tipoacao := TRUE;
      ELSE -- D - debito
         -- Exclus�o de DEBITO, aumenta Saldo Prejuizo
         vr_tipoacao := FALSE;
      END IF;
    ELSE -- I - Inclus�o
      IF vr_indebcre = 'C' THEN
         -- Inclusao de CREDITO, aumenta Saldo Prejuizo
         vr_tipoacao := FALSE;
      ELSE -- D - debito
         -- Inclusao de DEBITO, diminui Saldo Prejuizo
         vr_tipoacao := TRUE;
      END IF;
    END IF;



    IF vr_tipoacao THEN -- TRUE - diminui Saldo Prejuizo
      BEGIN
        UPDATE tbcc_prejuizo  a
           SET a.vlsdprej = Nvl(vlsdprej,0) - Nvl(prm_vllanmto,0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_erro;  
      END; 
    ELSE  -- FALSE - aumenta Saldo Prejuizo
      BEGIN
        UPDATE tbcc_prejuizo  a
           SET a.vlsdprej = Nvl(vlsdprej,0) + Nvl(prm_vllanmto,0)
         WHERE a.cdcooper = prm_cdcooper
           AND a.nrdconta = prm_nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Valor Saldo Preju�zo. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_erro;  
      END; 
    END IF;  
    --
    IF Nvl(SQL%RowCount,0) > 0 THEN 
      dbms_output.put_line('   Atualizado Saldo Devedor Preju�zo: '||Nvl(SQL%RowCount,0)||' registro(s).');
    ELSE
      vr_dscritic := 'Conta n�o encontrada. Cooperativa: '||prm_cdcooper||' | Conta: '||prm_nrdconta;
      RAISE vr_erro;  
    END IF;

    vr_vlsdprej := 0;
    OPEN cr_sld_prj (pr_cdcooper => prm_cdcooper
                    ,pr_nrdconta => prm_nrdconta);
    FETCH cr_sld_prj INTO rw_sld_prj;
    vr_vlsdprej := rw_sld_prj.vlsdprej;
    CLOSE cr_sld_prj;

    dbms_output.put_line('     Sld Prej.Depois: '||vr_vlsdprej);


    registrarVERLOG(pr_cdcooper  => prm_cdcooper
                   ,pr_nrdconta  => prm_nrdconta
                   ,pr_dstransa  => 'Ajuste Contabil - ' || To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss')
                   ,pr_dsCampo   => 'Saldo Prejuizo'
                   ,pr_antes     => vr_vlsdprej
                   ,pr_depois    => rw_sld_prj.vlsdprej);


  EXCEPTION
    WHEN vr_erro THEN
      dbms_output.put_line('prc_atlz_prejuizo: '||vr_dscritic);
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20001,vr_dscritic);
    WHEN OTHERS THEN
      dbms_output.put_line('prc_atlz_prejuizo: Erro: '||SubStr(SQLERRM,1,255));
      ROLLBACK;
      dbms_output.put_line('Efetuado Rollback.');
      Raise_Application_Error(-20002,'Erro Geral no prc_atlz_prejuizo. Erro: '||SubStr(SQLERRM,1,255));    
  END prc_atlz_prejuizo;      
  
  PROCEDURE pc_grava_prejuizo_cc_forcado(pr_cdcooper       IN crapcop.cdcooper%TYPE   --> Coop conectada
                                        ,pr_nrdconta      IN  crapass.nrdconta%TYPE  --> NR da Conta
                                        ,pr_tpope         IN VARCHAR2 DEFAULT 'N'    --> Tipo de Opera��o(N-Normal F-Fraude)
                                        ,pr_cdcritic      OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                        ,pr_dscritic      OUT VARCHAR2) IS
    -- Verifica se a conta j� est� marcada como "em preu�zo"
    CURSOR cr_crapass  (pr_cdcooper  crapass.cdcooper%TYPE,
                        pr_nrdconta  crapass.nrdconta%TYPE) IS
     SELECT a.inprejuz
          , a.vllimcre
          , a.cdsitdct
       FROM crapass a
      WHERE a.cdcooper = pr_cdcooper
        AND a.nrdconta   = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;

    -- Busca dias de atraso da conta transferida por fraude
    CURSOR cr_qtdiaatr(pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_nrdconta      crapris.nrdconta%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE) IS
      SELECT ris.qtdiaatr
       FROM  crapris ris
       WHERE ris.cdcooper  = pr_cdcooper
       AND   ris.nrdconta  = pr_nrdconta
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.dtrefere  = pr_dtrefere;

    --Variaveis de critica
    vr_cdcritic  NUMBER(3);
    vr_dscritic  VARCHAR2(1000);
    vr_des_erro  VARCHAR2(1000);

    --Variavel de exce��o
    vr_exc_saida exception;

    --Data da cooperativa
    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;

    -- Vari�veis para busca do saldo devedor
    vr_vlslddev  NUMBER:= 0;
    vr_tab_erro cecred.gene0001.typ_tab_erro;

    vr_qtdiaatr crapris.qtdiaatr%TYPE;

    -- Valores de juros +60
    vr_vlhist37 NUMBER;
    vr_vlhist38 NUMBER;
    vr_vlhist57 NUMBER;

    vr_vljuro60_37 NUMBER; -- Juros +60 (Hist. 37 + Hist. 2718)
    vr_vljuro60_38 NUMBER; -- Juros +60 (Hist. 38)
    vr_vljuro60_57 NUMBER; -- Juros +60 (Hist. 57)

    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
  BEGIN
      
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;

        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
     FETCH cr_crapass INTO rw_crapass;

     IF cr_crapass%NOTFOUND THEN
       CLOSE cr_crapass;
       vr_cdcritic:= 651;
       RAISE vr_exc_saida;
     ELSE
       CLOSE cr_crapass;
     END IF;

     -- Verifica se a conta est� marcada como "em preju�zo" (para o caso de transfer�ncia for�ada)
     IF rw_crapass.inprejuz = 1 THEN
       vr_cdcritic := 0;
       vr_dscritic := 'A conta informada j� est� marcada como "Em preju�zo".';
       RAISE vr_exc_saida;
     END IF;

     -- Cancela produtos/servi�os da conta (cart�o magn�tico, senha da internet, limite de cr�dito)
     PREJ0003.pc_cancela_servicos_cc_prj(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_dtinc_prejuizo => rw_crapdat.dtmvtolt
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) is not NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao cancelar produtos/servi�os para a conta ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     -- Identificar valores provisionados de juros +60 e debitar na conta
     PREJ0003.pc_debita_juros60_prj(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_vlhist37 => vr_vlhist37
                                   ,pr_vlhist38 => vr_vlhist38
                                   ,pr_vlhist57 => vr_vlhist57
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) is not NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao debitar valores provisionados de juros +60 para conta ' || pr_nrdconta;

       RAISE vr_exc_saida;
     END IF;

     -- Busca saldo devedor (saldo at� 59 dias de atraso) e juros +60 n�o pagos da conta
     TELA_ATENDA_DEPOSVIS.pc_busca_saldos_juros60_det(pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_vlsld59d => vr_vlslddev
                                                     ,pr_vlju6037 => vr_vljuro60_37
                                                     ,pr_vlju6038 => vr_vljuro60_38
                                                     ,pr_vlju6057 => vr_vljuro60_57
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);

     IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) is not NULL THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao recuperar saldo devedor da conta corrente ' || pr_nrdconta;
       RAISE vr_exc_saida;
     END IF;

     OPEN cr_qtdiaatr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtrefere => rw_crapdat.dtmvcentral);
     FETCH cr_qtdiaatr INTO vr_qtdiaatr;

     IF cr_qtdiaatr%NOTFOUND THEN
       vr_qtdiaatr := 0;
     END IF;

     CLOSE cr_qtdiaatr;

     BEGIN
       INSERT INTO TBCC_PREJUIZO(cdcooper
                                ,nrdconta
                                ,dtinclusao
                                ,cdsitdct_original
                                ,vldivida_original
                                ,qtdiaatr
                                ,vlsdprej
                                ,vljur60_ctneg
                                ,vljur60_lcred
                                ,intipo_transf)
       VALUES (pr_cdcooper,
               pr_nrdconta,
               rw_crapdat.dtmvtolt,
               rw_crapass.cdsitdct,
               vr_vlslddev + vr_vljuro60_37 + vr_vljuro60_57 + vr_vljuro60_38,
               vr_qtdiaatr,
               vr_vlslddev,
               vr_vljuro60_37 + vr_vljuro60_57,
               vr_vljuro60_38,
               CASE WHEN pr_tpope = 'N' THEN 0 ELSE 1 END)
       RETURNING idprejuizo INTO vr_idprejuizo;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro de insert na TBCC_PREJUIZO: '||SQLERRM;
        RAISE vr_exc_saida;
     END;

     BEGIN
       --Transfere conta para prejuizo AQUI
       UPDATE crapass a
          SET a.inprejuz = 1
        WHERE a.cdcooper = pr_cdcooper
          AND a.nrdconta = pr_nrdconta;
     EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:=0;
          vr_dscritic := 'Erro de update na CRAPASS: '||SQLERRM;
        RAISE vr_exc_saida;
     END;
     -- ornelas
     -- Grava situa��o da conta corrente antes da transfer�ncia para Prejuizo
     PREJ0003.pc_define_situacao_cc_prej(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_cdcritic => vr_cdcritic 
                                        ,pr_dscritic => vr_dscritic );
                                         
     if nvl(vr_cdcritic,0) > 0  or TRIM(vr_dscritic) is not null then
         RAISE vr_exc_saida;
     end if;    

     -- Registra as informa��es da transfer�ncia no extrato do preju�zo
     PREJ0003.pc_lanca_transf_extrato_prj(pr_idprejuizo => vr_idprejuizo
                                         ,pr_cdcooper   => pr_cdcooper
                                         ,pr_nrdconta   => pr_nrdconta
                                         ,pr_vlsldprj   => vr_vlslddev
                                         ,pr_vljur60_ctneg => vr_vljuro60_37 + vr_vljuro60_57
                                         ,pr_vljur60_lcred => vr_vljuro60_38
                                         ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                                         ,pr_tpope      => pr_tpope
                                         ,pr_cdcritic   => vr_cdcritic
                                         ,pr_dscritic   => vr_dscritic);
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

  END pc_grava_prejuizo_cc_forcado;
  
BEGIN
  

------------ BLOCO PRINCIPAL ---------------------
  dbms_output.put_line('Script iniciado em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));

---------------------------------------------------
  --INC0141704 Diferen�a dep�sito a vista - Viacredi 09/06
  vr_incidente := 'INC0141704';
  vr_cdcooper  := 1;
  vr_nrdocmto  := fn_sequence('CRAPLCT',
                              'NRDOCMTO',
                              vr_cdcooper || ';' ||
                              TRIM(to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')) || ';' || 61);
  dbms_output.put_line('  ');
  dbms_output.put_line('-------- '|| vr_incidente || ' - INICIO --------');
  
  OPEN BTCH0001.cr_crapdat(vr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
  
---------------------------------------------------

  vr_nrdconta  := 10376836;
  vr_vllanmto  := 23.47;
  vr_cdhistor  := 362;
  
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 1,
                                     pr_nrdolote    => 600040,
                                     pr_nrdctabb    => vr_nrdconta,
                                     pr_nrdocmto    => vr_nrdocmto,
                                     pr_cdhistor    => vr_cdhistor,
                                     pr_vllanmto    => vr_vllanmto,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_hrtransa    => gene0002.fn_busca_time,
                                     pr_cdorigem    => 0,
                                     pr_inprolot    => 1,
                                     pr_tab_retorno => vr_tab_retorno,
                                     pr_incrineg    => vr_incrineg,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic);
    
  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_excerro;
  END IF;
                     
---------------------------------------------------

  vr_nrdconta  := 10376836;
  vr_vllanmto  := 513.74;
  vr_cdhistor  := 2721;

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);
                          
---------------------------------------------------

  vr_nrdconta  := 9163638;
  vr_vllanmto  := 0.01;
  vr_cdhistor  := 2408;

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);
                          
  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                     prm_nrdconta => vr_nrdconta,
                     prm_vllanmto => vr_vllanmto,
                     prm_cdhistor => vr_cdhistor,
                     prm_tipoajus => 'I');

---------------------------------------------------

  vr_nrdconta  := 10757147;
  vr_vllanmto  := 10;
  vr_cdhistor  := 2408;

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);
                          
  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                     prm_nrdconta => vr_nrdconta,
                     prm_vllanmto => vr_vllanmto,
                     prm_cdhistor => vr_cdhistor,
                     prm_tipoajus => 'I');

---------------------------------------------------
    
  vr_nrdconta  := 8062749;
  vr_vllanmto  := 800;
  vr_cdhistor  := 535;
  
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 1,
                                     pr_nrdolote    => 600040,
                                     pr_nrdctabb    => vr_nrdconta,
                                     pr_nrdocmto    => vr_nrdocmto,
                                     pr_cdhistor    => vr_cdhistor,
                                     pr_vllanmto    => vr_vllanmto,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_hrtransa    => gene0002.fn_busca_time,
                                     pr_cdorigem    => 0,
                                     pr_inprolot    => 1,
                                     pr_tab_retorno => vr_tab_retorno,
                                     pr_incrineg    => vr_incrineg,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic);
    
  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_excerro;
  END IF;

---------------------------------------------------

  vr_nrdconta  := 8062749;
  vr_vllanmto  := 800;
  vr_cdhistor  := 2739;

  prc_gera_lct(prm_cdcooper => vr_cdcooper,
               prm_nrdconta => vr_nrdconta,
               prm_vllanmto => vr_vllanmto,
               prm_cdhistor => vr_cdhistor);
                          
  prc_atlz_prejuizo (prm_cdcooper => vr_cdcooper,
                     prm_nrdconta => vr_nrdconta,
                     prm_vllanmto => vr_vllanmto,
                     prm_cdhistor => vr_cdhistor,
                     prm_tipoajus => 'I');

  pc_grava_prejuizo_cc_forcado(pr_cdcooper      => vr_cdcooper
                              ,pr_nrdconta      => vr_nrdconta
                              ,pr_tpope         => 'N' -- N normal / F for�ada
                              ,pr_cdcritic      => vr_cdcritic
                              ,pr_dscritic      => vr_dscritic);
    
  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_excerro;
  END IF; 
---------------------------------------------------


---------------------------------------------------
  dbms_output.put_line('-------- '|| vr_incidente || ' - FIM --------');
  dbms_output.put_line('  ');
---------------------------------------------------

  --Salva
  COMMIT;

  dbms_output.put_line(' ');
  dbms_output.put_line('Script finalizado com Sucesso em '||To_Char(SYSDATE,'dd/mm/yyyy hh24:mi:ss'));
------------ BLOCO PRINCIPAL - FIM ---------------------


EXCEPTION   
  WHEN vr_excerro THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||vr_dscritic);
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||vr_dscritic);    
  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
END;
