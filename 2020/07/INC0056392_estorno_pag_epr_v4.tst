PL/SQL Developer Test script 3.0
172
-- Created on 24/07/2020 by F0032386 
declare 

  vr_dtlanct_estorno DATE := to_date('22/07/2020');
  vr_cdcritic             NUMBER(3);
  vr_dscritic             VARCHAR2(1000);
  vr_excerro              EXCEPTION;
  rw_crapdat              btch0001.cr_crapdat%rowtype;
  
  vr_nmcooper             VARCHAR2(2000);
  vr_nrdconta             NUMBER;
  vr_nrctremp             NUMBER;
  vr_tipo                 VARCHAR2(2000);
  
  TYPE typ_linhas IS TABLE OF varchar2(4000)
  INDEX BY PLS_INTEGER;
  
  vr_tab_linha  typ_linhas;          
  vr_tab_campos gene0002.typ_split;
  
  
  
  CURSOR cr_acordo  (pr_cdcooper   NUMBER,
                     pr_nrdconta   NUMBER,
                     pr_nrctremp   NUMBER) IS
    SELECT a.nracordo,a.cdsituacao
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c
     WHERE a.nracordo = c.nracordo      
       AND a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp;
  
  rw_acordo cr_acordo%ROWTYPE;
  
  CURSOR cr_crapepr_2(pr_nmrescop  VARCHAR2,
                      pr_nrdconta  NUMBER,
                      pr_nrctremp  NUMBER ) IS
    SELECT e.*,
           decode(e.tpemprst,0,'TR',1,'PP',2,'POS') idtipo  
      FROM crapepr e,
           crapcop c
     WHERE e.cdcooper = c.cdcooper
       AND c.nmrescop = pr_nmrescop
       AND e.inprejuz = 0
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp; 
  rw_crapepr_2 cr_crapepr_2%ROWTYPE;
  
  CURSOR cr_crapepr IS
    SELECT e.*,
           decode(e.tpemprst,0,'TR',1,'PP',2,'POS') idtipo  
      FROM crapepr e
     WHERE e.cdcooper = 1
       AND e.inprejuz = 0
       AND e.nrdconta = 7717490
       AND e.nrctremp = 1134699; 


BEGIN
 
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3827330;1510630;158948;baca;171,5;estorn';  

  FOR i IN vr_tab_linha.first..vr_tab_linha.count-1 LOOP
  
  vr_tab_campos := gene0002.fn_quebra_string(pr_string => vr_tab_linha(i), 
                                             pr_delimit => ';');
                                             
                            
  vr_nmcooper := vr_tab_campos(1);
  vr_nrdconta := vr_tab_campos(2);
  vr_nrctremp := vr_tab_campos(3);
  vr_tipo     := vr_tab_campos(5);

  IF upper(vr_tipo) = 'BACA' THEN
    OPEN cr_crapepr_2(pr_nmrescop => vr_nmcooper,
                      pr_nrdconta => vr_nrdconta,
                      pr_nrctremp => vr_nrctremp);
    FETCH cr_crapepr_2 INTO rw_crapepr_2;                    
    IF cr_crapepr_2%NOTFOUND THEN
      dbms_output.put_line('NAO ENCONTRADO -->'||vr_tab_linha(i));  
      CLOSE cr_crapepr_2;
      continue;
    ELSE
      
      CLOSE cr_crapepr_2;
      IF rw_crapepr_2.tpemprst <> '1' THEN
        dbms_output.put_line('Tipo Epr nao permite estorno -->'||vr_tab_linha(i)||';'||rw_crapepr_2.idtipo);  
        continue; 
      ELSE
        dbms_output.put_line(vr_tab_linha(i)||';'||rw_crapepr_2.idtipo);   
      END IF;    
      
    END IF;
    
    
    
    /* Busca data de movimento */
    open btch0001.cr_crapdat(rw_crapepr_2.cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    close btch0001.cr_crapdat;
    
    rw_acordo := NULL;
    OPEN cr_acordo  (pr_cdcooper   => rw_crapepr_2.cdcooper,
                     pr_nrdconta   => rw_crapepr_2.nrdconta,
                     pr_nrctremp   => rw_crapepr_2.nrctremp);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    
    BEGIN
      UPDATE tbrecup_acordo a  
         SET a.cdsituacao = 3 -- mudar para cancelado temporariamente
       WHERE a.nracordo = rw_acordo.nracordo;  
    END;
        
    empr0008.pc_tela_estornar_pagamentos( pr_cdcooper => rw_crapepr_2.cdcooper  --> Cooperativa conectada
                                         ,pr_cdagenci => 1                    --> Código da agência
                                         ,pr_nrdcaixa => 100                  --> Número do caixa
                                         ,pr_cdoperad => '1'                  --> Código do Operador
                                         ,pr_nmdatela => 'ESTORN'             --> Nome da tela
                                         ,pr_idorigem => 7                    --> Id do módulo de sistema
                                         ,pr_nrdconta => rw_crapepr_2.nrdconta  --> Número da conta
                                         ,pr_idseqttl => 1                    --> Seq titula
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Movimento atual
                                         ,pr_dtmvtopr => rw_crapdat.dtmvtopr  --> Movimento atual
                                         ,pr_nrctremp => rw_crapepr_2.nrctremp  --> Número do contrato de empréstimo
                                         ,pr_dsjustificativa => 'Pagamento de parcela indevida pelo modelo de acordo'       --> Justificativa
                                         ,pr_cdcritic => vr_cdcritic          --> Codigo da Critica
                                         ,pr_dscritic => vr_dscritic);         --> Erros do processo

    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_excerro;
    END IF; 
    
    BEGIN
      UPDATE tbrecup_acordo a  
         SET a.cdsituacao = rw_acordo.cdsituacao -- voltar para o valor original
       WHERE a.nracordo = rw_acordo.nracordo;  
    END;


  END IF;    
  
END LOOP;

  /* Busca data de movimento */
  open btch0001.cr_crapdat(6);
  fetch btch0001.cr_crapdat into rw_crapdat;
  close btch0001.cr_crapdat;
    
  -- Call the procedure
  cecred.prej0003.pc_gera_cred_cta_prj(pr_cdcooper => 6,
                                       pr_nrdconta => 113557,
                                       pr_cdoperad => 1,
                                       pr_vlrlanc => 1813.38,
                                       pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);

  IF nvl(vr_cdcritic,0) > 0 OR 
     TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_excerro;
  END IF; 

  COMMIT;

EXCEPTION
   WHEN vr_excerro THEN    
     ROLLBACK; 
     raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic);
end;
0
0
