CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS770(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                             ,pr_nmdatela  in varchar2              --> Nome da tela
                                             ,pr_infimsol OUT PLS_INTEGER
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
/* ..........................................................................

   Programa: pc_crps211 (antigo Fontes/crps211.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael - Mout's
   Data    : Fevereiro / 2018                     Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao M324.
               Rotina para realizar o pagamento de prejuízo automaticamente

   Alteracoes: 
............................................................................. */                                       
                                       
  -- Contratos sem garantia
  CURSOR c01 IS
    SELECT decode(epr.tpemprst,1,'PP','TR') idtpprd
          --, dtultpag
          ,epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdprej vlsdvpar
          ,epr.inliquid
          ,epr.rowid
      FROM crapepr epr,
           crapprp prp
     WHERE 
           epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = prp.cdcooper
       AND epr.nrdconta = prp.nrdconta
       AND epr.nrctremp = prp.nrctrato
       AND epr.inprejuz = 1  --> Somente as em prejuízo
       AND epr.dtprejuz IS NOT NULL
       AND prp.nrgarope = 10 -- Sem Garantia
       AND epr.vlsdprej > 0
       --AND epr.cdcooper = 8           
       --AND epr.nrdconta = 25461         --> Coop conectada           
       --AND epr.nrctremp = 200467
       ;
  -- Ordem de maior Valor
  CURSOR C02 IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdprej
          ,ROW_NUMBER () OVER (PARTITION BY epr.nrdconta
                                   ORDER BY epr.vlsdprej DESC) sequencia              
      FROM crapepr epr,
           crapprp prp
     WHERE 
           epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = prp.cdcooper
       AND epr.nrdconta = prp.nrdconta
       AND epr.nrctremp = prp.nrctrato
       AND epr.inprejuz = 1  --> Somente as em prejuízo
       AND epr.dtprejuz IS NOT NULL
       AND prp.nrgarope <> 10 -- Sem Garantia
       AND epr.vlsdprej > 0
       --AND epr.cdcooper = 8         
       --AND epr.nrdconta = 25461         --> Coop conectada           
       --AND epr.nrctremp = 200467
       ORDER BY epr.nrdconta, sequencia
       ;       

 vr_cdcritic NUMBER;
 vr_dscritic VARCHAR2(1000);
 vr_tab_erro gene0001.typ_tab_erro;
 vr_nrdrowid ROWID;
 
BEGIN
  FOR r01 IN c01 LOOP
    vr_dscritic := NULL;
    pc_crps780_1(pr_cdcooper => r01.cdcooper,
                 pr_nrdconta => r01.nrdconta,
                 pr_nrctremp => r01.nrctremp,
                 pr_vlpagmto => 0, -- parametro 0 para considerar o saldo da conta
                 pr_vldabono => 0, -- Na automatica não deverá ter abono
                 pr_cdagenci => 1,
                 pr_cdoperad => '1',
                 pr_cdcritic => vr_cdcritic,
                 pr_dscritic => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    -- Gerar LOG
    gene0001.pc_gera_log(pr_cdcooper => r01.cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => 'AYLLOS'
                        ,pr_dstransa => 'Falha ao pagar Prejuizo Contrato sem Garantia'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'CRPS770'
                        ,pr_nrdconta => r01.nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    COMMIT;
  END LOOP;
  
  FOR r02 IN c02 LOOP
    vr_dscritic := NULL;
    -- Rotina que realiza o pagamento de prejuizo
    pc_crps780_1(pr_cdcooper => r02.cdcooper,
                 pr_nrdconta => r02.nrdconta,
                 pr_nrctremp => r02.nrctremp,
                 pr_vlpagmto => 0, -- parametro 0 para considerar o saldo da conta
                 pr_vldabono => 0, -- Na automatica não deverá ter abono
                 pr_cdagenci => 1,
                 pr_cdoperad => '1',
                 pr_cdcritic => vr_cdcritic,
                 pr_dscritic => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      gene0001.pc_gera_log(pr_cdcooper => r02.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Falha ao pagar Prejuizo contrato maior saldo devedor'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'HH24MISS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS770'
                          ,pr_nrdconta => r02.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;
    COMMIT;
  END LOOP;  

END;
/
