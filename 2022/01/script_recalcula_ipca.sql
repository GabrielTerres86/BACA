
DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';
   vr_nraplica             craprac.nraplica%TYPE;     
   vr_dtcalcul_considerado crapdat.dtmvtolt%TYPE;
   vr_negativo             BOOLEAN;
   vr_exc_erro             EXCEPTION;
   vr_cdhistor             craphis.cdhistor%TYPE; --historico para lcto
   vr_nrdocmto             craplci.nrdocmto%TYPE;
   vr_tab_retorno          LANC0001.typ_reg_retorno;
   vr_incrineg             INTEGER;
   vidtxfixa               NUMBER;
   vcddindex               NUMBER;
   
   -- Variáveis de retorno
   vr_idtipbas NUMBER := 1;
   vr_idgravir NUMBER := 0;
   vr_vlbascal NUMBER := 0; 
   vr_vlsldtot NUMBER := 0;
   vr_vlsldrgt NUMBER := 0;
   vr_vlultren NUMBER := 0;
   vr_vlrentot NUMBER := 0;
   vr_vlrevers NUMBER := 0;
   vr_vlrdirrf NUMBER := 0;
   vr_percirrf NUMBER := 0;
   vr_vllanmto NUMBER := 0;
   vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
   
   vr_dslog VARCHAR2(4000) := '';
   
   CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,nmprodut
            ,idsitpro
            ,idtippro
            ,idtxfixa
            ,idacumul
            ,cdhscacc
            ,cdhsvrcc
            ,cdhsraap
            ,cdhsnrap
            ,cdhsprap
            ,cdhsrvap
            ,cdhsrdap
            ,cdhsirap
            ,cdhsrgap
            ,cdhsvtap
        FROM crapcpc cpc
       WHERE cpc.cddindex = 5
         AND cpc.indanive = 1
         AND cpc.idsitpro = 1
         AND cpc.cdprodut = 1057;
   
         rw_crapcpc cr_crapcpc%ROWTYPE;      
   
   CURSOR cr_craprac IS
     SELECT rac.cdcooper, 
            rac.nrdconta, 
            rac.nraplica, 
            rac.dtaniver,
            rac.dtmvtolt,
            rac.txaplica,            
            rac.qtdiacar,
            rac.vlaplica,
            rac.vlsldatl,
            rac.dtatlsld,
            rac.dtsldant,
            rac.vlsldant,
            rac.rowid,
            cpc.cdhsvrcc
       FROM craprac rac,
            crapcpc cpc
      WHERE rac.cdprodut = cpc.cdprodut 
       -- AND rac.cdcooper = 1 -- cooperativas Viacredi e Alto Vale
        AND rac.idsaqtot = 0
        AND rac.cdprodut = 1057
        AND NOT EXISTS (SELECT 1 FROM craplac l
                        WHERE l.cdcooper = rac.cdcooper
                          AND l.nrdconta = rac.nrdconta
                          AND l.nraplica = rac.nraplica
                          AND l.cdhistor = 3333)
        AND rac.dtmvtolt IN ('31/03/2021','31/05/2021','31/08/2021');
   
        rw_craprac cr_craprac%ROWTYPE;
   
              
BEGIN
    
  FOR rw_crapcpc IN cr_crapcpc LOOP                        
      vidtxfixa := rw_crapcpc.idtxfixa;  
      vcddindex := rw_crapcpc.cddindex;  
  END LOOP;
   
  FOR rw_craprac in cr_craprac LOOP
   
     vr_dslog := 'UPDATE CRAPRAC SET vlsldatl = '|| REPLACE(rw_craprac.vlsldatl,',','.') ||
                                  ', dtatlsld = '''|| rw_craprac.dtatlsld || ''' '|| 
                                  ', vlsldant = '|| REPLACE(rw_craprac.vlsldant,',','.') ||
                                  ', dtsldant = '''|| rw_craprac.dtsldant ||''' '||  
                                  ', dtaniver = '''|| rw_craprac.dtaniver ||''' '||  
           ' WHERE CDCOOPER = '||rw_craprac.cdcooper ||
             ' AND NRDCONTA = '||rw_craprac.nrdconta||
             ' AND NRAPLICA = '||rw_craprac.nraplica||';';
             
     CECRED.pc_log_programa(pr_dstiplog      => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                           ,pr_tpocorrencia  => 4 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                           ,pr_cdcriticidade => 0 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                           ,pr_tpexecucao    => 3 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0109631_IPCA'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);         
    
     vr_vlbascal := rw_craprac.vlaplica;
       
     APLI0006.pc_posicao_saldo_aplicacao_pos( pr_cdcooper => rw_craprac.cdcooper,
                                              pr_nrdconta => rw_craprac.nrdconta,
                                              pr_nraplica => rw_craprac.nraplica,
                                              pr_dtiniapl => rw_craprac.dtmvtolt,
                                              pr_txaplica => rw_craprac.txaplica,
                                              pr_idtxfixa => vidtxfixa,
                                              pr_cddindex => vcddindex,
                                              pr_qtdiacar => rw_craprac.qtdiacar,
                                              pr_idgravir => vr_idgravir,
                                              pr_flgcaren => 2, -- IMPORTANTE: O valor 2 indica que deve ser calculada a rentabilidade da poupança
                                              pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                              pr_dtinical => rw_craprac.dtmvtolt,
                                              pr_dtfimcal => add_months(rw_craprac.dtaniver,-1),
                                              pr_idtipbas => vr_idtipbas,
                                              pr_incalliq => 0,                   --> Nao calcula saldo liquido
                                              -- OUT
                                              pr_vlbascal => vr_vlbascal,                                                              
                                              pr_vlsldtot => vr_vlsldtot,
                                              pr_vlsldrgt => vr_vlsldrgt,
                                              pr_vlultren => vr_vlultren,
                                              pr_vlrentot => vr_vlrentot,
                                              pr_vlrevers => vr_vlrevers,
                                              pr_vlrdirrf => vr_vlrdirrf,
                                              pr_percirrf => vr_percirrf,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);    
       
     -- tratamento para possiveis erros gerados pelas rotinas anteriores
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_dslog := 'Erro pc_posicao_saldo_aplicacao_pos. ' || vr_dscritic;
        RAISE vr_excsaida;
      END IF;
                
      vr_negativo := false;
      vr_cdhistor := rw_crapcpc.cdhsprap;
                
      -- se rendimento for negativo
      IF vr_vlultren < 0 THEN
        -- remove o sinal e usa o historico de reversao de provisao
        vr_vlultren := vr_vlultren * -1;
        vr_cdhistor := rw_crapcpc.cdhsrvap;
        vr_negativo := true;
      END IF;
      -- calcular a diferença do saldo da aplicação para então efetuar o lançamento
      vr_vllanmto := vr_vlsldtot - rw_craprac.vlsldatl; 
        
      IF vr_vllanmto > 0 THEN
        apli0010.pc_credita_aniversario_lctos(pr_cdcooper => rw_craprac.cdcooper,
                                              pr_nrdconta => rw_craprac.nrdconta,
                                              pr_nraplica => rw_craprac.nraplica,
                                              pr_dtaplica => rw_craprac.dtmvtolt,
                                              pr_dtaniver => rw_craprac.dtaniver,
                                              pr_cdhistor => 3328,
                                              pr_dtmvtolt => trunc(SYSDATE),
                                              pr_vllanmto => vr_vllanmto,
                                              pr_dtatlsld => rw_craprac.dtatlsld,
                                              pr_vlsldatl => rw_craprac.vlsldatl,
                                              pr_dtsldant => rw_craprac.dtsldant,
                                              pr_vlsldant => rw_craprac.vlsldant,
                                              pr_rowid    => rw_craprac.rowid,
                                              pr_negativo => vr_negativo,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
                                                
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           vr_dslog := 'Erro pc_credita_aniversario_lctos. ' || vr_dscritic;
           RAISE vr_excsaida;
        END IF;
      END IF;
                                                                         
  END LOOP;
    
  COMMIT;
       
  EXCEPTION 
     WHEN vr_excsaida then  
         CECRED.pc_log_programa(pr_dstiplog      => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                           ,pr_tpocorrencia  => 4 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                           ,pr_cdcriticidade => 0 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                           ,pr_tpexecucao    => 3 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0109631_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);   
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         CECRED.pc_log_programa(pr_dstiplog      => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                           ,pr_tpocorrencia  => 4 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                           ,pr_cdcriticidade => 0 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                           ,pr_tpexecucao    => 3 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                           ,pr_dsmensagem    => vr_dslog '. ' || vr_dscritic
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0109631_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 

END;
