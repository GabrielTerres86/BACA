/*
Dessa forma os títulos com instrução "01-Remessa de Titulos" ficam bloqueados no Ayllos e 
não aceitam baixa pela tela, tendo que ser baixados via script, conforme solicitação da área de cobrança.

-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissão | Vencimento |        Valor
          1-VIACEEDI |    11171375|          007358 |     000000 | 21/07/2020 | 25/07/2020 | R$      10,00


(Luiz Cherpers(Mouts) - INC0056387)

*/
DECLARE

  --Selecionar registro de cobranca
  CURSOR cr_crapcob  (pr_cdcooper IN crapcob.cdcooper%TYPE
                     ,pr_nrdconta IN crapcob.nrdconta%type
                     ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                     ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
    SELECT cob.cdbandoc
          ,cob.cdcooper
          ,cob.nrdconta
          ,cob.nrdctabb
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,cob.incobran
          ,cob.rowid
      FROM crapcob cob
          ,crapcco cco
     WHERE cob.cdcooper = pr_cdcooper
       AND cob.nrdconta = pr_nrdconta
       AND cob.nrcnvcob = pr_nrcnvcob
       AND cob.nrdocmto = pr_nrdocmto
       AND cco.cdcooper = cob.cdcooper
       AND cco.nrconven = cob.nrcnvcob
       AND cob.cdbandoc = cco.cddbanco
       AND cob.nrdctabb = cco.nrdctabb;

  rw_crapcob    cr_crapcob%ROWTYPE;
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  vr_dtmvtolt  DATE;
  
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_dserro VARCHAR2(100);
    
    
BEGIN
  
  -- Busca a data do movimento
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => 1);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
  vr_dtmvtolt:= rw_crapdat.dtmvtolt;

  -- Verificar cobrança
  OPEN cr_crapcob(pr_cdcooper  => 1,
                   pr_nrdconta => 11171375,
                   pr_nrcnvcob => 101004,
                   pr_nrdocmto => 0);
  FETCH cr_crapcob INTO rw_crapcob;

  IF cr_crapcob%FOUND THEN
      
    cobr0007.pc_inst_pedido_baixa ( pr_idregcob  => rw_crapcob.rowid --Rowid da Cobranca
                                   ,pr_cdocorre => '02'            --Codigo Ocorrencia
                                   ,pr_dtmvtolt => vr_dtmvtolt     --Data pagamento
                                   ,pr_cdoperad => '1'          --Operador
                                   ,pr_nrremass =>  0              --Numero da Remessa
                                   ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                   ,pr_cdcritic => vr_cdcritic --Codigo da Critica
                                   ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      DBMS_OUTPUT.put_line('Erro - INC0056387 - '||vr_dscritic);
    END IF;                       

  END IF;
  CLOSE cr_crapcob;
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Erro não tratado - INC0056387 - '||Sqlerrm);
END;
