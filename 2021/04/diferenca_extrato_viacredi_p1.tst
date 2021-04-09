PL/SQL Developer Test script 3.0
193
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
             WHERE cdcooper = 1 
               AND nrctremp in (1543112, 1064814, 1293002, 1397244, 974642, 1145711, 743054, 821670, 670033, 1118718, 705090, 1278575, 634563, 498663, 967074, 762762, 982100, 1214602, 1186963, 1131549, 715895, 709635, 1289999, 812574, 1016561, 747686, 1052375, 726242, 696643, 1204933, 881073, 1110171, 1268999, 1138300, 1076618, 190610, 945946, 1374683, 1921065, 816483, 816487, 1155518, 722569, 664156, 1517565, 364438, 636891, 455869, 818707, 581117, 1345993, 838620, 196214, 1027941, 567523, 784673, 1070949, 1401770, 1218906, 479549, 1380019, 1409321, 1834681, 1164325, 448349, 535595, 723381, 963084, 1082886, 495735, 740135, 996871, 988725, 1166713, 881283, 175749, 910911, 11344, 373749, 1117675, 11240, 111042, 994869, 1107051, 2007541, 1413116, 1009128, 119292, 1001501, 774512, 701300, 11243, 1134231, 817934, 380189, 204856, 989400, 860720, 2126575, 995453, 921772, 1090578, 396109, 684784, 360831, 1060421, 166109, 669999, 667305, 741720, 685002, 689123, 598980, 921071, 476819, 639855, 739733, 647698, 914959, 1170757, 1150994, 1254648, 1596284, 574759, 625914, 1041831, 1378891, 854900, 767545, 1089249, 30206, 897914, 508065, 1413869, 1581609, 1630089, 156277, 577932, 104057, 1187350, 952798, 155326, 1128687, 666281, 852611, 942298, 1481330, 584455, 663866, 2013065, 832754, 1300132, 1407835, 928631, 1503796, 1255972, 726123, 158155, 863086, 186797, 1330413, 828924, 1103946, 1237077, 642172, 486126, 1257579, 1257907, 1096852, 830659, 609664, 922187, 489270, 869468, 1140018, 1140036, 647107, 132486, 1008717, 1145425, 1515355, 1491660, 519030, 758476, 702329, 393502, 593948, 180105, 313730, 1030224, 1026856, 672128, 2482355, 1186366, 1357338, 905401, 1094039, 1062233, 566810, 11547, 377702, 1272666, 156180, 1015832, 225242, 1511465, 944874, 2551845, 1028595, 893501, 894204, 485372, 316415, 12057, 1022125, 845591, 738258, 1511794, 502852, 1334603, 1401951, 825326, 835158, 1474986, 1173643, 111612, 437218, 879038, 625738, 1494011, 665958, 1360110, 1429302, 824048, 849120, 979143, 179838, 556549, 394122, 804431, 403281, 1270771, 628059, 1257656, 313353, 1337095, 667011, 361224, 825163, 1237663, 754805, 1384411, 557298, 467006, 857956, 1269501, 578254, 1141704, 629684, 811743, 682717, 1604557, 722038, 1593180, 699387, 1358072, 364136, 1388544, 1005738, 1208098, 1311063, 1006447, 1579532, 1430665, 1501312, 1137222, 641483, 963941, 553206, 903145, 961420, 1015999, 568522, 641616, 196702, 1119384, 1476806, 20958, 315559, 902945, 870554, 144216, 189721, 143493, 1191449, 101309, 1010174, 114211, 70822, 692308, 1343456, 871197, 2954435, 802113, 1274937, 1279607, 901334, 715972, 2970384, 921109, 1320414, 1474347, 1187592, 733899, 783500, 866477, 782504, 173825, 611256, 768349, 1296539, 723844, 1199017, 811010, 1354708, 740212, 776958, 1125188, 625315, 1152150, 1028764, 154569, 1248003, 1582329, 530503, 1372722, 1640386, 107401, 821378, 754821, 1087387, 757667, 573828, 952610, 1147531, 11406, 1366348, 329291, 141570, 869573, 1345118, 1111649, 1514719, 1531459, 688823, 822427, 1131935, 994676, 851742, 3158373, 3159000, 1053056, 897461, 882818, 1271795, 1954555, 997855, 905236, 749542, 1308483, 3207218, 867193, 1161032, 1519119, 673645, 845873, 407732, 877882, 1002439, 929740, 1513745, 1109731, 808949, 979814, 1802184, 1591661, 1274889, 962656, 764794, 1642800, 3506657, 120955, 735276, 150585, 1505388, 998618, 1040307, 920311, 1398053, 1514779, 11113, 1014719, 707463, 117425, 794132, 823590, 1127666, 844816, 996012, 27433, 899481, 798992, 120741, 2432631, 692659, 1185725, 829545, 113892, 942087, 1045977, 1015102, 633431, 745432, 1440449, 628055, 1117584, 494671, 1132888, 1264272, 1446353, 701214, 1045093, 1287364, 1349353, 479587, 788852, 21341, 761808, 3741427, 415415, 1105681, 750741, 989273, 1275734, 3760863, 827983, 21552, 11945, 494145, 862813, 219801, 1153743, 1806212, 530565, 1198641, 1326328, 857856, 175479, 1362892, 1135269, 1170368, 175512, 404203, 862074, 1041454, 1215851, 1309130, 1192986, 680857, 1438309, 1921160, 833472, 1389661, 1539810, 749565, 836405, 893695, 198868, 447232, 781649, 584884, 616559, 3853276, 859914, 1044278, 1040322, 145277, 1099973, 144473, 34785, 3879194, 478768, 658240, 678051, 668187, 806716, 644120, 1013059, 1450564, 678161, 654240, 902740, 1164582, 922841, 1082448, 1131573, 1112826, 720603, 991081, 1196304, 1415414, 644655, 1230347, 1088531, 910472, 1326574, 428334, 428335, 745944, 1387145, 1049570, 1272972, 1413052, 864254, 890876, 1475387, 1224066, 1049049, 1041994, 64950, 1330998, 457785, 639122, 1076088, 822834, 519992, 703495, 804740, 1146820, 489261, 785802, 747412, 1037553, 1161230, 1029747, 909009, 1252698, 1125349, 704262, 1251146, 1126154, 532881, 1031862, 1619433, 1017950, 788036, 965028, 1109972, 1610687, 1243879, 1184101, 4025989, 731604, 1226468, 763827, 695545, 1408029, 908415, 4036557, 728372, 718535, 899454, 1267174, 734743, 1480576, 712240, 900929, 1640517, 650227, 802407, 814432, 1072043, 1144726, 644649, 1144004, 873552, 904574, 964350, 1227004, 924444, 1227497, 820408, 6010784, 1358299, 1477501, 1302393, 29646, 570260, 953657, 1289318, 727749, 1168749, 844874, 1379255, 1445634, 655792, 482983, 550982, 778018, 638859, 1183709, 729585, 795783, 689697, 943599, 1139185, 175270, 324782, 1095979, 1006380, 894111, 434688, 1157961, 383419, 337393, 6137385, 849604, 935601, 110439, 765677, 1144465, 460590, 1457747, 444268, 1124142, 166161, 114984, 1625884, 964546, 941746, 1536505, 138499, 1428350, 1219228, 1111515, 1375361, 819364, 915461, 1474476, 932627, 1146833, 577539, 1433003, 600814, 1114078, 1208669, 1382293, 117631, 127365, 298903, 892836, 748371, 985752, 98962, 27854, 870350, 999874, 634539, 646651, 127982, 1182547, 993659, 1284706, 548241, 1218591, 415913, 19772, 1260100, 1541897, 142938, 1153110, 698037, 941999, 1177445, 384466, 31352, 1150485, 364554, 1347362, 1151664, 1476988, 968956, 1345931, 727345, 1191503, 920994, 966580, 735991, 1241628, 390240, 1026039, 322673, 1417294, 927796, 1231953, 497042, 1715835, 826164, 145012, 1402693, 834081, 1583792, 1336825, 974515, 828912, 564356, 805671, 1219057, 11310, 979859, 762787, 1080429, 643425, 958271, 718467, 506570, 884392, 586582, 1296810, 932373, 982105, 353399, 764019, 1033589, 1171408, 6430627, 1378022, 70307, 654160, 1440351, 840604, 875900, 842823, 1251155, 606647, 493161, 1047315, 291551, 1271931, 1309207, 983798, 796746, 6493289, 1450405, 6494749, 913599, 887151, 131899, 597008, 766683, 470260, 408449, 1099, 889017, 174674, 1389442, 1034054, 1560725, 836597, 766020, 350247, 880516, 470718, 766380, 900874, 1055451, 121846, 124511, 6539572, 982502, 38580, 59894, 427508, 468071, 83355, 1262253, 1136980, 1527915, 610858, 859114, 960582, 583178, 391672, 131525, 1534164, 1069133, 1266079, 1517112, 1102726, 1921275, 404213, 493820, 1404304, 882138, 699998, 988718, 827544, 1108936, 994536, 557479, 871076, 1094836, 204511, 671417, 1166613, 995127, 1534601, 760390, 1350857, 1102413, 443447, 1487425, 326171, 782752, 336772, 1194934, 1480693, 1204088, 748079, 669552, 668429, 591672, 690898, 65447, 1100104, 397718, 918564, 873679, 493868, 1159042, 447748, 608587, 366175, 1921001, 1440635, 453726, 568167, 1283579, 1488770, 455000, 1046495, 426808, 1350923, 901723, 920006, 817549, 1726090, 1082042, 121163, 1622295, 550712, 11518, 855611, 355111, 850514, 930290, 1063172, 1374273, 147244, 983215, 1224607, 1155450, 11054, 1345063, 1200247, 569392, 804060, 860176, 1504327, 698937, 6812058, 1378805, 822614, 1476846, 1033407, 11629, 142703, 1424809, 500361, 1230979, 11111, 66193, 316500, 816114, 473119, 1250864, 1028035, 121446, 1214353, 644562, 726009, 917470, 1013159, 730192, 1621915, 970457, 343020, 1696571, 973068, 1064201, 1389666, 1223439, 1436155, 486659, 666298, 670220, 173957, 317303, 1094337, 623968, 1030570, 1064564, 782450, 556141, 1853825, 1123058, 694348, 1440325, 813046, 1137842, 2012666, 1625693, 6914519, 2325973, 805953, 1853101, 1325040, 1157729, 750034, 184517, 1307575, 57100, 436235, 1007279, 2104469, 1079698, 986655, 913899, 6946259, 1523886, 682846, 737194, 912262, 1917644, 698683, 1268187, 1089164, 679651, 840212, 653425, 206987, 6969402, 890914, 6971180, 548577, 954469, 1281824, 445840, 1104827, 128778, 988194, 1556363, 1097580, 163199, 618506, 1180297, 1478236, 1308375, 1096400, 935606, 1454607, 673512, 1352296, 818059, 732068, 1028591, 1388996, 824754, 869621, 1555420, 368677, 427890, 889752, 1536943, 888559, 1547391, 687862, 1422536, 1120297)
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
  vr_nmarqbkp  := 'ROLLBACK_VIA_INC0084567_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
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
