DECLARE
  CURSOR cr_contratos IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlpreemp
          ,epr.vlsprojt
          ,pep.dtvencto
          ,pep.nrparepr
          ,(SELECT pep2.vlparepr
              FROM crappep pep2
             WHERE pep2.cdcooper = epr.cdcooper
               AND pep2.nrdconta = epr.nrdconta
               AND pep2.nrctremp = epr.nrctremp
               AND pep2.nrparepr = 1) vlparepr_1
          ,pep.vlparepr
          ,pep.vlsdvpar
					,pep.vlpagpar
					,pep.vldstrem
					,pep.vldstcor
					,pep.vldespar
          ,epr.rowid rowid_epr
          ,pep.rowid rowid_pep
      FROM crapepr epr
          ,crappep pep
     WHERE epr.cdcooper = pep.cdcooper
       AND epr.nrdconta = pep.nrdconta
       AND epr.nrctremp = pep.nrctremp
       AND pep.inliquid = 0
       AND pep.dtvencto >= to_date('27/03/2021','dd/mm/yyyy')
       AND (epr.cdcooper, epr.nrdconta, epr.nrctremp) IN(
           (1, 1870734, 2346287)
          ,(1, 1970593, 2418593)
          ,(1, 1994689, 2303109)
          ,(1, 2148234, 2297188)
          ,(1, 2241668, 2393295)
          ,(1, 2294389, 2419188)
          ,(1, 2559544, 2461042)
          ,(1, 2691574, 2476692)
          ,(1, 2716550, 2338921)
          ,(1, 2822334, 2239606)
          ,(1, 2847027, 2494243)
          ,(1, 2872935, 2223439)
          ,(1, 2931621, 2350305)
          ,(1, 2968088, 2762942)
          ,(1, 3140113, 2579199)
          ,(1, 3210901, 2285337)
          ,(1, 3524272, 2702817)
          ,(1, 3598373, 2344922)
          ,(1, 3650014, 2240335)
          ,(1, 3662365, 2385870)
          ,(1, 3664864, 2353000)
          ,(1, 3774090, 2383042)
          ,(1, 3779360, 2329236)
          ,(1, 3826554, 2246006)
          ,(1, 3911870, 2369424)
          ,(1, 4077490, 2266301)
          ,(1, 4081080, 2235056)
          ,(1, 6002307, 2267823)
          ,(1, 6071724, 2272843)
          ,(1, 6216323, 2255559)
          ,(1, 6246770, 2396747)
          ,(1, 6287239, 2225759)
          ,(1, 6762395, 2407029)
          ,(1, 6794645, 2459457)
          ,(1, 6862543, 2245732)
          ,(1, 6929028, 2320940)
          ,(1, 6981690, 2269869)
          ,(1, 6992455, 2237818)
          ,(1, 7036612, 2278418)
          ,(1, 7101465, 2343688)
          ,(1, 7235623, 2282682)
          ,(1, 7235623, 2282261)
          ,(1, 7236310, 2448554)
          ,(1, 7259573, 2283674)
          ,(1, 7300816, 2315049)
          ,(1, 7300816, 2315020)
          ,(1, 7581980, 2400812)
          ,(1, 7581980, 2400788)
          ,(1, 7612974, 2284316)
          ,(1, 7641583, 2274608)
          ,(1, 7797974, 2342705)
          ,(1, 7831161, 2521489)
          ,(1, 7831161, 2521511)
          ,(1, 7831161, 2233536)
          ,(1, 7831161, 2233692)
          ,(1, 7964684, 2299815)
          ,(1, 7998570, 2336483)
          ,(1, 7999712, 2286511)
          ,(1, 8173427, 2394399)
          ,(1, 8244855, 2254120)
          ,(1, 8282358, 2471957)
          ,(1, 8388024, 2733840)
          ,(1, 8420793, 2327301)
          ,(1, 8476845, 2269533)
          ,(1, 8477400, 2301815)
          ,(1, 8502129, 2290505)
          ,(1, 8517509, 2273889)
          ,(1, 8520828, 2393706)
          ,(1, 8522863, 2357041)
          ,(1, 8587477, 2764021)
          ,(1, 8636265, 2313656)
          ,(1, 8672830, 2433548)
          ,(1, 8685096, 2471056)
          ,(1, 8789002, 2217964)
          ,(1, 8806039, 2344908)
          ,(1, 8846278, 2400759)
          ,(1, 8846278, 2400471)
          ,(1, 8865698, 2241416)
          ,(1, 8882169, 2328050)
          ,(1, 8912513, 2434290)
          ,(1, 8928215, 2221876)
          ,(1, 8931437, 2338117)
          ,(1, 8937788, 2317392)
          ,(1, 8970050, 2280163)
          ,(1, 9077448, 2288779)
          ,(1, 9113126, 2305989)
          ,(1, 9121536, 2746499)
          ,(1, 9172106, 2244062)
          ,(1, 9181687, 2327479)
          ,(1, 9228829, 2398583)
          ,(1, 9269576, 2396238)
          ,(1, 9300481, 2383203)
          ,(1, 9411550, 2291703)
          ,(1, 9458867, 2400592)
          ,(1, 9482687, 2402945)
          ,(1, 9536469, 2374062)
          ,(1, 9638822, 2260370)
          ,(1, 9808728, 2318375)
          ,(1, 9883223, 2538522)
          ,(1, 9893814, 2289520)
          ,(1, 9919988, 2247390)
          ,(1, 9930124, 2366405)
          ,(1, 9938273, 2270104)
          ,(1, 9974326, 2352906)
          ,(1, 9977783, 2285510)
          ,(1, 10002510, 2351788)
          ,(1, 10130233, 2331751)
          ,(1, 10226672, 2236741)
          ,(1, 10234241, 2252145)
          ,(1, 10291512, 2250568)
          ,(1, 10339728, 2550986)
          ,(1, 10447989, 2321236)
          ,(1, 10481273, 2424436)
          ,(1, 10510915, 2242145)
          ,(1, 10541985, 2275781)
          ,(1, 10580760, 2341746)
          ,(1, 10692061, 2335855)
          ,(1, 10726691, 2312847)
          ,(1, 10781390, 2478914)
          ,(1, 10797505, 2967983)
          ,(1, 10834125, 2256767)
          ,(1, 10849467, 2318129)
          ,(1, 11024984, 2417822)
          ,(1, 80430635, 2475468)
          ,(1, 90110021, 2395739)
          ,(11, 211370, 73778)
          ,(11, 332976, 75035)
          ,(13, 9636, 65214)
          ,(13, 57215, 64606)
          ,(13, 115142, 61809)
          ,(16, 6866, 149328)
          ,(16, 338630, 156198)
          ,(16, 475149, 161761)
          ,(16, 6032877, 154411)
					)
  ORDER BY epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
          ,pep.nrparepr;

  rw_contratos          cr_contratos%ROWTYPE;
	vr_nrctremp           crapepr.nrctremp%TYPE;
  vr_texto_log          CLOB;
  vr_des_log            CLOB;
  vr_texto_crapepr_prox CLOB;
  vr_des_crapepr_prox   CLOB;
  vr_texto_crappep_prox CLOB;
  vr_des_crappep_prox   CLOB;
  vr_dsdireto           VARCHAR2(1000);
  vr_exc_proximo        EXCEPTION;
	vr_dscritic           crapcri.dscritic%TYPE;

  PROCEDURE pr_atualiza_contrato(pr_cdcooper IN  crapepr.cdcooper%TYPE
                                ,pr_nrdconta IN  crapepr.nrdconta%TYPE
                                ,pr_nrctremp IN  crapepr.nrctremp%TYPE
                                ,pr_vlpreemp IN  crapepr.vlpreemp%TYPE
                                ,pr_vlsprojt IN  crapepr.vlsprojt%TYPE
                                ,pr_dscritic OUT crapcri.dscritic%TYPE
		                            ) IS
  BEGIN
    UPDATE crapepr epr
       SET epr.vlpreemp = pr_vlpreemp
          ,epr.vlsprojt = pr_vlsprojt
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
			pr_dscritic := 'Erro ao atualizar a crapepr: ' || pr_cdcooper || ', ' || pr_nrdconta || ', ' || pr_nrctremp || ' - ' || SQLERRM || chr(10);
  END pr_atualiza_contrato;

  PROCEDURE pr_atualiza_parcela(pr_cdcooper IN  crappep.cdcooper%TYPE
                               ,pr_nrdconta IN  crappep.nrdconta%TYPE
                               ,pr_nrctremp IN  crappep.nrctremp%TYPE
                               ,pr_nrparepr IN  crappep.nrparepr%TYPE
                               ,pr_vlparepr IN  crappep.vlparepr%TYPE
                               ,pr_vlsdvpar IN  crappep.vlsdvpar%TYPE
                               ,pr_dscritic OUT crapcri.dscritic%TYPE
		                           ) IS
  BEGIN
    UPDATE crappep pep
       SET pep.vlparepr = pr_vlparepr
          ,pep.vlsdvpar = pr_vlsdvpar
     WHERE pep.cdcooper = pr_cdcooper
       AND pep.nrdconta = pr_nrdconta
       AND pep.nrctremp = pr_nrctremp
       AND pep.nrparepr = pr_nrparepr;
  EXCEPTION
    WHEN OTHERS THEN
			pr_dscritic := 'Erro ao atualizar a crappep: ' || pr_cdcooper || ', ' || pr_nrdconta || ', ' || pr_nrctremp || ', ' || pr_nrparepr || ' - ' || SQLERRM || chr(10);
  END pr_atualiza_parcela;

BEGIN

  -- Inicializar o CLOB
  vr_texto_log     := NULL;
  vr_des_log       := NULL;
  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

  vr_texto_crapepr_prox := NULL;
  vr_des_crapepr_prox   := NULL;
  dbms_lob.createtemporary(vr_des_crapepr_prox, TRUE);
  dbms_lob.open(vr_des_crapepr_prox, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_des_crapepr_prox, vr_texto_crapepr_prox, 'cdcooper;nrdconta;nrctremp;vr_vlpreemp_antes;vr_vlpreemp;vr_vlsprojt_antes;vr_vlsprojt;rowid' || chr(10));

  vr_texto_crappep_prox := NULL;
  vr_des_crappep_prox   := NULL;
  dbms_lob.createtemporary(vr_des_crappep_prox, TRUE);
  dbms_lob.open(vr_des_crappep_prox, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_des_crappep_prox, vr_texto_crappep_prox, 'cdcooper;nrdconta;nrctremp;nrparepr;vr_vlparepr_antes;vr_vlparepr;vr_vlsdvpar_antes;vr_vlsdvpar;rowid' || chr(10));

  vr_nrctremp := 0;
	
	OPEN cr_contratos;

  LOOP
    FETCH cr_contratos INTO rw_contratos;
    EXIT WHEN cr_contratos%NOTFOUND;

    BEGIN
      IF vr_nrctremp <> rw_contratos.nrctremp THEN
        vr_nrctremp := rw_contratos.nrctremp;
			  -- Atualiza o contrato
        pr_atualiza_contrato(pr_cdcooper => rw_contratos.cdcooper
                            ,pr_nrdconta => rw_contratos.nrdconta
                            ,pr_nrctremp => rw_contratos.nrctremp
                            ,pr_vlpreemp => rw_contratos.vlparepr_1
                            ,pr_vlsprojt => rw_contratos.vlsprojt
                            ,pr_dscritic => vr_dscritic
                            );
        IF vr_dscritic IS NOT NULL THEN
          gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, vr_dscritic);
          RAISE vr_exc_proximo;
        END IF;
        gene0002.pc_escreve_xml(vr_des_crapepr_prox, vr_texto_crapepr_prox, rw_contratos.cdcooper || ';' ||
                                                                            rw_contratos.nrdconta || ';' ||
                                                                            rw_contratos.nrctremp || ';' ||
                                                                            to_char(rw_contratos.vlpreemp
                                                                                   ,'999999990D90'
                                                                                   ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                            to_char(rw_contratos.vlparepr_1
                                                                                   ,'999999990D90'
                                                                                   ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                            to_char(rw_contratos.vlsprojt
                                                                                   ,'999999990D90'
                                                                                   ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                            to_char(rw_contratos.vlsprojt
                                                                                   ,'999999990D90'
                                                                                   ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                            rw_contratos.rowid_epr || chr(10));
      END IF;
      -- Atualiza a parcela
      pr_atualiza_parcela(pr_cdcooper => rw_contratos.cdcooper
                         ,pr_nrdconta => rw_contratos.nrdconta
                         ,pr_nrctremp => rw_contratos.nrctremp
                         ,pr_nrparepr => rw_contratos.nrparepr
                         ,pr_vlparepr => rw_contratos.vlparepr_1
                         ,pr_vlsdvpar => rw_contratos.vlparepr_1 - (NVL(rw_contratos.vlpagpar,0) +
                                                                    NVL(rw_contratos.vldstrem,0) +
                                                                    NVL(rw_contratos.vldstcor,0) +
                                                                    NVL(rw_contratos.vldespar,0))
                         ,pr_dscritic => vr_dscritic
                         );
      IF vr_dscritic IS NOT NULL THEN
        gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, vr_dscritic);
        RAISE vr_exc_proximo;
      END IF;
      gene0002.pc_escreve_xml(vr_des_crappep_prox, vr_texto_crappep_prox, rw_contratos.cdcooper || ';' ||
                                                                          rw_contratos.nrdconta || ';' ||
                                                                          rw_contratos.nrctremp || ';' ||
                                                                          rw_contratos.nrparepr || ';' ||
                                                                          to_char(rw_contratos.vlpreemp
                                                                                 ,'999999990D90'
                                                                                 ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                          to_char(rw_contratos.vlparepr_1
                                                                                 ,'999999990D90'
                                                                                 ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                          to_char(rw_contratos.vlsdvpar
                                                                                 ,'999999990D90'
                                                                                 ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                          to_char((rw_contratos.vlparepr_1 - (NVL(rw_contratos.vlpagpar,0) +
                                                                                                              NVL(rw_contratos.vldstrem,0) +
                                                                                                              NVL(rw_contratos.vldstcor,0) +
                                                                                                              NVL(rw_contratos.vldespar,0)))
                                                                                 ,'999999990D90'
                                                                                 ,'NLS_NUMERIC_CHARACTERS = '',.''') || ';' ||
                                                                          rw_contratos.rowid_pep || chr(10));
    EXCEPTION
      WHEN vr_exc_proximo THEN
        vr_dscritic := NULL;
				ROLLBACK;
    END;
    COMMIT;
  END LOOP;
  CLOSE cr_contratos;

  -- Fecha o arquivo
  gene0002.pc_escreve_xml(vr_des_log, vr_texto_log, ' ' || chr(10),TRUE);
  vr_dsdireto := SISTEMA.obternomedirectory(gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dsdireto, 'log_erros_atualizacao.csv', NLS_CHARSET_ID('UTF8'));
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  gene0002.pc_escreve_xml(vr_des_crapepr_prox, vr_texto_crapepr_prox, ' ' || chr(10),TRUE);
  vr_dsdireto := SISTEMA.obternomedirectory(gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_crapepr_prox, vr_dsdireto, 'atualizacao_crapepr.csv', NLS_CHARSET_ID('UTF8'));
  dbms_lob.close(vr_des_crapepr_prox);
  dbms_lob.freetemporary(vr_des_crapepr_prox);

  gene0002.pc_escreve_xml(vr_des_crappep_prox, vr_texto_crappep_prox, ' ' || chr(10),TRUE);
  vr_dsdireto := SISTEMA.obternomedirectory(gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/jaison');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_crappep_prox, vr_dsdireto, 'atualizacao_crappep.csv', NLS_CHARSET_ID('UTF8'));
  dbms_lob.close(vr_des_crappep_prox);
  dbms_lob.freetemporary(vr_des_crappep_prox);

EXCEPTION
  WHEN OTHERS THEN
		ROLLBACK;
END;
