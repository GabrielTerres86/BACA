PL/SQL Developer Test script 3.0
190
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
  /*
  vr_tab_linha(vr_tab_linha.count) := 'ACENTRA;132870;17193;593,95;baca;531,98;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'CIVIA;68586;24546;204,45;baca;204,88;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'CIVIA;296023;38633;588,6;baca;589,52;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'CREDICOMIN;74225;5045;239,26;baca;164,56;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'CREDIFOZ;295590;70597;210,32;baca;R$ 213,43;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'CREVISC;122319;15690;277,44;baca;237,8;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'CREVISC;70505;15826;160,31;baca;321,24;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'EVOLUA;106267;13910;2.000,00;baca;159,69;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7717490;1134699;398,59;baca;399,07;estorn';*/
 -- vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9479880;1042327;591,19;baca;96,02;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6170790;789037;486,89;baca;486,89;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6170790;789037;495;baca;495;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6170790;789037;486,89;baca;490,23;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9375295;1156138;566,1;baca;566,58;estorn';/*
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6630740;1108936;773,21;baca;773,21;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6882250;1921062;157,61;baca;160,71;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9452788;1682642;496,59;baca;496,59;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3805000;857856;303,53;baca;303,86;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;10259651;2067747;319,46;baca;320,14;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;4069412;930091;288,97;baca;282,21;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8166463;2012983;403,71;baca;408,61;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7575700;972142;522,32;baca;522,32;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7874855;902608;276,23;baca;276,49;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9725806;1524384;625,42;baca;625,42;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9611649;1114249;508,28;baca;508,28;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9527575;1382025;386,07;baca;386,09;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6361544;1460409;387,31;baca;387,74;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;6616615;598870;1.089,02;baca;1.114,97;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8057893;1272197;466,74;baca;526,71;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;2332841;1407835;150;baca;150,26;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7641818;1439931;650;baca;650;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9196935;1483365;1.610,00;baca;1610;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7968108;845596;2.000,00;baca;2000;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;9825207;1481632;200;baca;200;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;3827330;1510622;5.000,00;baca;5000;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;8187118;958507;708;Baca;708;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;348511;61858;203,59;baca;203,59;estorn';
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI AV;431990;134784;171,5;baca;171,5;estorn';  */

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

COMMIT;

EXCEPTION
   WHEN vr_excerro THEN    
     ROLLBACK; 
     raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic);
end;
0
0
