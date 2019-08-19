-- Created on 13/03/2019 by F0030248 
-- Referente ao INC0031872
-- Reenviar boletos ao IEPTB que não foram pra cartório
declare 
  -- Local variables here
  i integer;
  vr_nrremret crapcre.nrremret%TYPE;
  vr_rowid_ret ROWID;
  vr_nrseqreg craprem.nrseqreg%TYPE;
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_des_erro VARCHAR2(1000);
  
  CURSOR cr_crapdat (pr_cdcooper IN INTEGER) IS
    SELECT dtmvtolt, dtmvtopr 
      FROM crapdat 
     WHERE cdcooper = pr_cdcooper;
    
  rw_crapdat cr_crapdat%ROWTYPE;
begin
  -- Test statements here
  FOR rw IN (SELECT rem.*, rem.rowid rowid_rem, cob.rowid rowid_cob, cob.insitcrt
               FROM craprem rem, crapcre cre, crapcob cob, crapcco cco
              WHERE cco.cdcooper > 0 
                AND cco.cddbanco = 85
                AND rem.cdcooper = cco.cdcooper
                AND rem.nrcnvcob = cco.nrconven
                AND rem.dtaltera between trunc(SYSDATE) - 60 and trunc(sysdate) - 1
                AND rem.cdocorre = 9
                --AND rem.hrtransa >= 37800
                AND cre.cdcooper = rem.cdcooper
                AND cre.nrcnvcob = rem.nrcnvcob
                AND cre.dtmvtolt = rem.dtaltera
                AND cre.intipmvt = 1
                AND cob.cdcooper = rem.cdcooper
                AND cob.nrdconta = rem.nrdconta
                AND cob.nrcnvcob = rem.nrcnvcob
                AND cob.nrdocmto = rem.nrdocmto
                AND cob.nrdctabb = cco.nrdctabb
                AND cob.cdbandoc = cco.cddbanco
                AND cob.insitcrt = 1
                AND cob.incobran = 0) LOOP
        
    OPEN cr_crapdat(pr_cdcooper => rw.cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
    
    IF rw.insitcrt = 2 THEN
      UPDATE crapcob SET insitcrt = 1 
       WHERE ROWID = rw.rowid_cob;
    END IF;
    
    PAGA0001.pc_prep_remessa_banco (pr_cdcooper => rw.cdcooper --Cooperativa
                                   ,pr_nrcnvcob => rw.nrcnvcob --Numero Convenio
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtopr  --Data Movimento
                                   ,pr_cdoperad => '1' --Codigo Operador
                                   ,pr_idregcob => '0' --ROWID da cobranca
                                   ,pr_nrremret => vr_nrremret --Numero Remessa
                                   ,pr_rowid_ret => vr_rowid_ret --ROWID Remessa Retorno
                                   ,pr_nrseqreg => vr_nrseqreg --Numero Sequencial registro
                                   ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                   ,pr_dscritic => vr_dscritic); --Descricao Critica
                   
    vr_nrseqreg:= Nvl(vr_nrseqreg,0) + 1;
    --Criar tabela Remessa
    PAGA0001.pc_cria_tab_remessa (pr_idregcob => rw.rowid_cob --ROWID da cobranca
                   ,pr_nrremret => vr_nrremret          --Numero Remessa
                   ,pr_nrseqreg => vr_nrseqreg          --Numero Sequencial
                   ,pr_cdocorre => 9                    --Codigo Ocorrencia
                   ,pr_cdmotivo => NULL                 --Codigo Motivo
                   ,pr_dtdprorr => NULL                 --Data Prorrogacao
                   ,pr_vlabatim => 0                    --Valor Abatimento
                   ,pr_cdoperad => 1                    --Codigo Operador
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --Data Movimento
                   ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                   ,pr_dscritic => vr_dscritic);        --Descricao Critica                                                 
                   
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid_cob   --ROWID da Cobranca
                                 ,pr_cdoperad => '1'   --Operador
                                 ,pr_dtmvtolt => SYSDATE   --Data movimento
                                 ,pr_dsmensag => 'Nova instrucao de protesto'   --Descricao Mensagem
                                 ,pr_des_erro => vr_des_erro   --Indicador erro
                                 ,pr_dscritic => vr_dscritic); --Descricao erro
                     
                
  END LOOP;
  
  COMMIT;                
end;
