declare
 -- Carrega o calendário de datas da cooperativa
 rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
 
 vr_exc_erro  EXCEPTION;
 
 vr_aux_ISPBIFDebtd    VARCHAR2(100);
 vr_aux_NUPortdd1      VARCHAR2(300);
 vr_aux_NUPortdd2      VARCHAR2(300);
 vr_aux_nrispbif       NUMBER;
 vr_aux_nrdconta	   NUMBER(10);
 
 vr_tab_retorno  	   lanc0001.typ_reg_retorno;
 vr_aux_flgrespo       NUMBER;
 vr_incrineg     INTEGER;
 vr_des_reto     VARCHAR2(3);
 vr_cdcritic     NUMBER;
 vr_dscritic     VARCHAR2(4000);
   
begin   
 
 OPEN BTCH0001.cr_crapdat(13);
 FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
 CLOSE BTCH0001.cr_crapdat;
 
 vr_aux_ISPBIFDebtd := '01181521';
 vr_aux_NUPortdd1 := '202102230000178311238';
 vr_aux_NUPortdd2 := '202102230000178312158';
 vr_aux_nrispbif := '5463212';
 vr_aux_nrdconta := 180084;
  
   -- Atualiza situacao da portabilidade para Concluida no JDCTC
   UPDATE tbepr_portabilidade
      SET dtliquidacao          = rw_crapdat.dtmvtolt,           -- Data da Liquidação
          nrcnpjbase_if_origem  = NVL(vr_aux_ISPBIFDebtd,0) -- ISPB da IF compradora da operação
    WHERE cdcooper              = 13
      AND nrunico_portabilidade in (vr_aux_NUPortdd1, vr_aux_NUPortdd2)
	  AND nrdconta = vr_aux_nrdconta;
  
   -- Atualiza situacao da portabilidade para Concluida no JDCTC
   empr0006.pc_atualizar_situacao(pr_cdcooper => 3           				   /* Cód. Cooperativa */
                                 ,pr_idservic => 2                             /* Tipo de servico(1-Proponente/2-Credora) */
                                 ,pr_cdlegado => 'LEG'                         /* Codigo Legado */
                                 ,pr_nrispbif => vr_aux_nrispbif           	   /* Numero ISPB IF */
                                 ,pr_nrcontrl => '1'                           /* Nr. controle (verificar) */
                                 ,pr_nuportld => vr_aux_NUPortdd1               /* Numero Portabilidade CTC */
                                 ,pr_cdsittit => 'PL5'                         /* Codigo Situacao Titulo */
                                 ,pr_flgrespo => vr_aux_flgrespo               /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                 ,pr_des_erro => vr_des_reto                   /* Indicador erro OK/NOK */
                                 ,pr_dscritic => vr_dscritic);                 /* Descricao do erro */
								 
   -- Se apresentou erro na geração do lançamento
   IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_des_reto,'OK') = 'NOK' THEN
    dbms_output.put_line('Erro ao pc_atualizar_situacao: ' || vr_dscritic);
   END IF;	
   
   -- Atualiza situacao da portabilidade para Concluida no JDCTC
   empr0006.pc_atualizar_situacao(pr_cdcooper => 3           				   /* Cód. Cooperativa */
                                 ,pr_idservic => 2                             /* Tipo de servico(1-Proponente/2-Credora) */
                                 ,pr_cdlegado => 'LEG'                         /* Codigo Legado */
                                 ,pr_nrispbif => vr_aux_nrispbif           	   /* Numero ISPB IF */
                                 ,pr_nrcontrl => '1'                           /* Nr. controle (verificar) */
                                 ,pr_nuportld => vr_aux_NUPortdd2               /* Numero Portabilidade CTC */
                                 ,pr_cdsittit => 'PL5'                         /* Codigo Situacao Titulo */
                                 ,pr_flgrespo => vr_aux_flgrespo               /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                 ,pr_des_erro => vr_des_reto                   /* Indicador erro OK/NOK */
                                 ,pr_dscritic => vr_dscritic);                 /* Descricao do erro */
								 
   -- Se apresentou erro na geração do lançamento
   IF TRIM(vr_dscritic) IS NOT NULL OR NVL(vr_des_reto,'OK') = 'NOK' THEN
    dbms_output.put_line('Erro ao pc_atualizar_situacao: ' || vr_dscritic);
   END IF;	

  COMMIT;
  
exception
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    
    -- Retornar erro
    raise_application_error(-20001,vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    
    -- Retornar erro
    raise_application_error(-20000,'Erro ao incluir lançamentos: '||SQLERRM);
  
end;    