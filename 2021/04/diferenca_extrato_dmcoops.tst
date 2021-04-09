PL/SQL Developer Test script 3.0
259
-- Created on 05/04/2021 by T0032717 
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
   
  CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                   ,pr_nrdconta IN craplem.nrdconta%TYPE
                   ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
    SELECT SUM(
         DECODE(h.indebcre, 
               'D', craplem.vllanmto, 
               CASE craplem.cdhistor 
                 WHEN 2415 THEN craplem.vllanmto 
                 WHEN 2411 THEN craplem.vllanmto 
                 WHEN 1040 THEN craplem.vllanmto 
                 WHEN 1037 THEN craplem.vllanmto 
                 WHEN 1077 THEN craplem.vllanmto 
                 WHEN 1078 THEN craplem.vllanmto 
                 WHEN 1619 THEN craplem.vllanmto 
                 WHEN 1620 THEN craplem.vllanmto 
                 WHEN 1735 THEN craplem.vllanmto 
                 WHEN 1733 THEN craplem.vllanmto
                 ELSE (craplem.vllanmto * (-1)) 
               END))
           lancamento
     FROM craplem craplem, craphis h
    WHERE craplem.cdcooper = pr_cdcooper
      AND craplem.nrdconta = pr_nrdconta
      AND craplem.nrctremp = pr_nrctremp
      /* Desprezando historicos de concessao de credito com juros a apropriar e lancamendo para desconto + demais historicos que estao descontados ou adicionados a outros */    
      AND craplem.cdhistor NOT IN (1047,1077,1032,1033,1034,1035,1048,1049,2566,2567,
                                   2388,2473,2389,2390,2475,2392,2474,2393,2394,2476,
                                   2386,2388,2473,2389,2390,2475,2387,2392,2474,2393,
                                   2394,2476,1731,2396,2397,2381,2382,2385,2400,3356,
                                   3357,3358,3359,1734,1736,2382,2423,2416,2390,2475,
                                   2394,2476,2735,2471,2472,2358,2359,2878,2884,2885,
                                   2888,2405,2735,2311,2312,1076,1078)
      /*Historicos que nao vao compor o saldo, mas vao aparecer no relatorio*/
      AND craplem.cdhistor NOT IN (1048,1049,1050,1051,1717,1720,1708,1711,2566,2567,
                                   2423,2416,2390,2475,2394,2476,2735,
                                   --> Novos historicos de estorno de financiamento
                                   2784,2785,2786,2787,2882,2883,2887,2884,2886,2954,
                                   2955,2956,2953,2735
                                   --> Estorno IOF Comp. Consignado (P437)
                                   ,3013)
      AND h.cdcooper = craplem.cdcooper
      AND h.cdhistor = craplem.cdhistor;
  rw_craplem cr_craplem%ROWTYPE;
  
  CURSOR cr_crapepr IS
    SELECT a.cdcooper, a.nrdconta, a.nrctremp, a.vlsdprej 
      FROM (SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 2
               AND nrctremp in (224716, 244724, 4580, 244149, 240554, 242528, 235832, 249544, 239436, 222571, 220316, 239342, 236682, 244142, 247682, 248365, 257281, 234078)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 5
               AND nrctremp in (13516, 6489, 1352, 6867, 5443, 6450, 8204, 6669, 5450, 8683, 2707, 3016, 2713, 15523, 99384, 7428, 6254, 7909, 10925, 12654, 8493, 10291, 12239, 9646, 10452, 13980, 13870, 13151, 15104)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 6
               AND nrctremp in (213634, 214112, 214971, 2019, 222333, 217482, 78409, 224319, 221422, 226898, 219128, 216828, 212332, 216051, 223143, 222539, 226903, 224850, 227063, 227750, 221564, 216969, 217819, 215460, 506745, 214944)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 7
               AND nrctremp in (1, 15698, 12684, 3062, 16362, 13388, 8527, 8577, 21682, 88447, 2308, 10804, 8191, 18094, 19324, 26422, 17769, 20342, 26726, 24711, 21293, 9698, 18384, 14496, 242853, 29934, 311472)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 8
               AND nrctremp in (2937, 1034, 83925, 1222, 955, 2056, 3837, 1842, 1328, 3967, 208532, 5701, 247, 1653, 2874, 4376, 3294, 5584, 5668)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 9
               AND nrctremp in (2653, 7580, 4121002, 11926, 55921, 3684, 7292, 6645, 91545, 6099, 105090, 10668, 7643, 5946, 7052, 7291, 11240, 8157, 12983, 6135, 13879, 12388, 9790, 11745, 11573, 12860, 13394, 13607, 13778, 24341, 9931, 605, 155, 7154, 10455, 911291)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 10
               AND nrctremp in (7645, 16411, 3424, 1559, 27294, 2297, 3302, 3633, 4920, 6184, 7976, 4994, 5665)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 11
               AND nrctremp in (22005, 16623, 34617, 56254, 35129, 24108, 30687, 86302, 19581, 9035, 15373, 19794, 44008, 22134, 9210, 52889, 20624, 18438, 26580, 12818, 1154, 33280, 21953, 8060, 36023, 18744, 30080, 41018, 20816, 32116, 25245, 15650, 25007, 34607, 31269, 15471, 30837, 16625, 45740, 24288, 47089, 19650, 261092, 30339, 45675, 269751, 290300, 20416, 32132, 19634, 34853, 45902, 18830, 55448, 28299, 20218, 54425, 27781, 23557, 46565, 39762, 33690, 39166, 28656, 47439, 28788, 25666, 33257, 26432, 45970, 58664, 43667, 25150, 32794, 43238, 52233, 38511, 50560, 43938, 65855, 40663, 67018, 39219, 37070, 42453, 47021, 45417, 45533, 47492, 57162, 56950, 45594, 65090, 55983, 42309, 43274, 57068, 44089, 44887, 52056, 62525, 58230, 55865, 57560)
               AND vlsdprej > 0
            UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 12
               AND nrctremp in (4272, 1082, 7539, 10863, 4291, 11044, 1925, 5118, 12848, 1863, 15001, 14928, 2250, 158164, 3355, 4014, 9049, 9991, 51942, 13008, 8079, 2528, 8183, 10510, 5587, 12040, 10386, 4136, 11146, 7348, 10679, 7573, 13780, 9878, 1820485, 9951, 7304, 10693, 17441, 17883, 10130, 13164, 15432, 15138, 15690, 18679)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 13
               AND nrctremp in (14181, 8612, 7985, 20232, 16444, 16297, 4172, 12877, 61760, 30181, 10896, 37771, 11028, 53277, 20622, 28415, 31280, 34097, 34346, 28029, 33841, 46057, 25691, 8941, 25534, 34308, 26012, 37908, 27465, 32396, 7285, 3394, 230839, 90902, 17300, 10462, 15398, 6343, 28472, 35054, 2828, 33454, 36941, 47804, 48831, 44986, 63571, 58246, 53477, 57717, 49903, 38633, 47974, 8341, 10048, 53093, 6823, 53470, 31380, 43015, 40849, 15488, 9825, 501530, 9269, 7584, 18212, 12798, 19702)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 14
               AND nrctremp in (912, 3047, 1953, 11024, 11207, 4590, 1282, 17981, 5298, 11013, 20990, 1412, 22705, 24945, 7785, 5124, 5337, 31445, 3136, 9675, 5158, 45527, 3599, 5145, 4012, 4000, 4335, 4543, 6551, 7698, 5663, 11005, 8521, 7811, 6116, 6531, 7509, 10498)
               AND vlsdprej > 0
             UNION ALL
            SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 16
               AND nrctremp in (118958, 22916, 13204, 111611, 60444, 21115, 1735, 21251, 4034, 15413, 125764, 14725, 33516, 2401, 30923, 33705, 191225, 64151, 24043, 80652, 9594, 24107, 100615, 95907, 70822, 29414, 66845, 79716, 96493, 18622, 32095, 12183, 2539, 100627, 114060, 113948, 131966, 25494, 18800, 47331, 18129, 18480, 20151, 137375, 34715, 69835, 4544, 134585, 59987, 20978, 38192, 12988, 17184, 12443, 17063, 128526, 81285, 68370, 228818, 34701, 62653, 103621, 24495, 84509, 98734, 82164, 130686, 10752, 64897, 76093, 80602, 74444, 45395, 50599, 113662, 76205, 82050, 106349, 43779, 70093, 63543, 96205, 50894, 79069, 280860, 79766, 67399, 72363, 59661, 104056, 123058, 28646, 116203, 7292, 83730, 71788, 85940, 56352, 53559, 78626, 65192, 96267, 107145, 73484, 107802, 77636, 98738, 59916, 103191, 57900, 140126, 117216, 64502, 98706, 86072, 126988, 83102, 80936, 79778, 21058, 85519, 96249, 75078, 25023, 65807, 82212, 79096, 95902, 92716, 66821, 103592, 101394, 74439, 133326, 70244, 95919, 116872, 109805, 90696, 115326, 80414, 100686, 73646, 74166, 92660, 129557, 74646, 98667, 125732, 76594, 77082, 87132, 79163, 96294, 117825, 87998, 83452, 125066, 121831, 106731, 85861, 98624, 101022, 118251, 109037, 115128, 109372, 120517, 112408, 123657, 117842, 117376, 124246, 135021, 72676, 6127, 4909, 84677, 22338, 20211, 15159, 86133, 15246, 40578, 13870, 17432, 11847, 20025, 52507, 47601, 60220, 68723, 81278, 91088, 76097, 11029, 21748, 95801, 111477, 14961, 8444, 14266, 29887, 6558, 129571, 54770, 24807, 10882, 33751, 57166, 74386, 65358, 55494)
               AND vlsdprej > 0
      ) a;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                            ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);      
    BEGIN
        -- Primeiro garantimos que o diretorio exista
        IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN

          -- Efetuar a criação do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permissão total na pasta
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

        END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;    
  END;   
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas'
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas/INC0084567'
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0084567'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0084567_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_crapepr IN cr_crapepr LOOP
    
    OPEN cr_craplem(pr_cdcooper => rw_crapepr.cdcooper
                   ,pr_nrdconta => rw_crapepr.nrdconta
                   ,pr_nrctremp => rw_crapepr.nrctremp);
    FETCH cr_craplem INTO rw_craplem;
    CLOSE cr_craplem;
    
    IF rw_crapepr.vlsdprej > rw_craplem.lancamento AND rw_craplem.lancamento > 0 AND rw_crapepr.vlsdprej > 0 THEN
      -- atualiza o valor 
      UPDATE crapepr 
         SET vlsdprej = rw_craplem.lancamento
       WHERE cdcooper = rw_crapepr.cdcooper
         AND nrdconta = rw_crapepr.nrdconta
         AND nrctremp = rw_crapepr.nrctremp;
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE crapepr ' || chr(13) || 
                              '   SET vlsdprej = ' || REPLACE(rw_crapepr.vlsdprej, ',', '.') || chr(13) ||
                              ' WHERE cdcooper = ' || rw_crapepr.cdcooper || chr(13) ||
                              '   AND nrdconta = ' || rw_crapepr.nrdconta || chr(13) ||
                              '   AND nrctremp = ' || rw_crapepr.nrctremp || '; ' ||chr(13)||chr(13), FALSE); 
    END IF;
  END LOOP;
  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  -- Fecha o arquivo rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  commit;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || SQLERRM);
END;
0
0
