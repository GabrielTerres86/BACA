PL/SQL Developer Test script 3.0
141
-- Created on 21/07/2020 by F0032386 
declare 
  CURSOR cr_crapcco IS    
     SELECT cco.*
    FROM CRAPCCO CCO
   WHERE CCO.DSORGARQ = 'ACORDO'
    -- AND cco.cdcooper = 16
   ORDER BY cdcooper;
   
  CURSOR cr_crapcob (pr_nrconven NUMBER,
                     pr_cdcooper NUMBER)IS
    SELECT cob.*,cco.qtdecate,cob.rowid
      FROM CRAPCCO CCO, CRAPCOB COB
     WHERE CCO.DSORGARQ = 'ACORDO'
       AND COB.CDCOOPER = CCO.CDCOOPER
       AND COB.NRCNVCOB = CCO.NRCONVEN
       AND COB.CDBANDOC = CCO.CDDBANCO
       AND cob.cdbandoc = 85
       AND cob.nrdconta = 850004
       AND COB.INCOBRAN = 0
       AND COB.DTVENCTO > '31/07/2020'
       AND COB.DTVENCTO < '30/09/2020'
       AND cco.cddbanco = 85
       AND (cob.dtlipgto - cob.dtvencto) < cco.qtdecate
       AND cco.nrconven = pr_nrconven
       AND cco.cdcooper = pr_cdcooper; 

  CURSOR cr_crapcob_ant (pr_nrconven NUMBER,
                         pr_cdcooper NUMBER)IS   
  SELECT cob.*,cob.rowid
      FROM CRAPCCO CCO, CRAPCOB COB
     WHERE CCO.DSORGARQ = 'ACORDO'
       AND COB.CDCOOPER = CCO.CDCOOPER
       AND COB.NRCNVCOB = CCO.NRCONVEN
       AND COB.CDBANDOC = CCO.CDDBANCO
       AND cob.cdbandoc = 85
       AND cob.nrdconta = 850004
       AND COB.INCOBRAN = 0
       AND COB.DTVENCTO <= '31/07/2020'
       AND COB.Dtmvtolt < '29/04/2020'
       AND cco.cddbanco = 85
       AND cco.nrconven = pr_nrconven
       AND cco.cdcooper = pr_cdcooper;
  
  
  vr_qtd NUMBER;
  --Tabelas de Memoria de Remessa
  vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
  
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(4000);
  vr_excerro EXCEPTION;
  
  
  
BEGIN
  
  dbms_output.put_line('cdcooper;qtd');
  FOR rw_crapcco IN cr_crapcco LOOP
      
    /*SELECT count(1)--cob.dtlipgto - cob.dtvencto,cco.*
      INTO vr_qtd
      FROM CRAPCCO CCO, CRAPCOB COB
     WHERE CCO.DSORGARQ = 'ACORDO'
       AND COB.CDCOOPER = CCO.CDCOOPER
       AND COB.NRCNVCOB = CCO.NRCONVEN
       AND COB.CDBANDOC = CCO.CDDBANCO
       AND cob.cdbandoc = 85
       AND cob.nrdconta = 850004
       AND COB.INCOBRAN = 0
       AND COB.DTVENCTO > '31/07/2020'
       AND COB.DTVENCTO < '30/09/2020'
       AND cco.cddbanco = 85
       AND (cob.dtlipgto - cob.dtvencto) < cco.qtdecate
       AND cco.nrconven = rw_crapcco.nrconven
       AND cco.cdcooper = rw_crapcco.cdcooper;
       
       dbms_output.put_line(rw_crapcco.cdcooper||';'||vr_qtd);*/
       
    FOR rw_crapcob IN cr_crapcob (pr_nrconven => rw_crapcco.nrconven,
                                  pr_cdcooper => rw_crapcco.cdcooper) LOOP     
     
      BEGIN
        UPDATE crapcob cob
           SET cob.dtlipgto = cob.DTVENCTO + nvl(rw_crapcob.qtdecate,60) + 5     
         WHERE cob.rowid = rw_crapcob.rowid;        
      END;                           
      
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_excerro;
      END IF;  
    END LOOP; 
  
  
    FOR rw_crapcob IN cr_crapcob_ant (pr_nrconven => rw_crapcco.nrconven,
                                      pr_cdcooper => rw_crapcco.cdcooper) LOOP     
       
        
      DDDA0001.pc_procedimentos_dda_jd (pr_rowid_cob => rw_crapcob.rowid         --ROWID da Cobranca
                                       ,pr_tpoperad  => 'A'                      --Tipo Operacao
                                       ,pr_tpdbaixa  => ' '                      --Tipo de Baixa
                                       ,pr_dtvencto  => rw_crapcob.dtvencto      --Data Vencimento
                                       ,pr_vldescto  => rw_crapcob.vldescto      --Valor Desconto
                                       ,pr_vlabatim  => rw_crapcob.vlabatim      --Valor Abatimento
                                       ,pr_flgdprot  => rw_crapcob.flgdprot      --Flag Protesto
                                       ,pr_tab_remessa_dda => vr_tab_remessa_dda --tabela remessa
                                       ,pr_tab_retorno_dda => vr_tab_retorno_dda --Tabela memoria retorno DDA
                                       ,pr_cdcritic  => vr_cdcritic             --Codigo Critica
                                       ,pr_dscritic  => vr_dscritic);           --Descricao Critica
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_excerro;
      END IF;  
    END LOOP;
  END LOOP;  
  
  --ROLLBACK;   
  COMMIT;
EXCEPTION
   WHEN vr_excerro THEN
     ROLLBACK;   
     raise_application_error(-20500,vr_cdcritic||'-'||vr_dscritic);
   
   WHEN OTHERS THEN  
     ROLLBACK;   
     raise_application_error(-20500,SQLERRM);
  
END;
0
0
