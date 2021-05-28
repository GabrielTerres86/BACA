DECLARE
  -- Local variables
  vr_qtdiajur NUMBER;
  vr_vlrtarif NUMBER;
  vr_cdcritic INTEGER;
  vr_tab_erro gene0001.typ_tab_erro;
  vr_contador_atualizados INTEGER := 0;
  vr_contador_cursor_contratos INTEGER := 0;
  vr_qtd_parcelas_restantes INTEGER := 0;
  vr_dtrefjur DATE;
  vr_diarefju crapepr.diarefju%TYPE;
  vr_mesrefju crapepr.mesrefju%TYPE;
  vr_anorefju crapepr.anorefju%TYPE;
      
  -- Variável genérica de calendário com base no cursor da btch0001
  rw_crapdat         btch0001.cr_crapdat%ROWTYPE;  
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
  vr_tab_calculado   empr0001.typ_tab_calculado;
  vr_vlparepr        NUMBER(25,2);
    
  -- Variaveis sistemas
  vr_vljurmes        NUMBER(25,2);
  vr_taxa_diaria     NUMBER(25,2);
  vr_vlr_ajust_car   NUMBER(25,2);
  vr_nova_prestacao  NUMBER(25,2);
  vr_texto_completo  CLOB;
  vr_des_log         CLOB;
  vr_dsdireto VARCHAR2(1000);
    
  -- Variavel tratamento de erro
  vr_dscritic        VARCHAR2(1000);
  vr_exc_erro        EXCEPTION;
  vr_des_reto        VARCHAR2(10);
      
  /*Cursor com as respectivas cooperativas, contas e contratos a serem atualizadas*/
  CURSOR cr_coop_conta_contrato_atualizar IS
    SELECT REGEXP_SUBSTR('56316,1031,13250,122947,76945,15253,81477,7064,1015,24864,36714,127230,32808,30449,1163,152803,29513,152773,12521,153214,41351,25860,19038,23787,12122,81000,81140,286117,199702,5452,114294,10251,20249,194786,22195,286117,238066,429805,59277,461059,60038,2358042,6939,325031,3619575,2358514,13552,166723,2694603,6161448,3851893,108308,6554911,134996,541001,643564,217212,198986,3735788,7943563,9329641,9406786,8818037,8697442,9688722,10659510,10692061,8321671,6530303,2246490,3906523,10589104,9170847,8329150,9720057,9356240,10341790,9372431,3872416,9745483,2846101,3924432,2180227,10247238,2334283,10247440,2180570,8592080,2180588,2180561,11084626,3937933,9616063,6179460,8235864,7208510,6977332,868094,2569027,80495192,8176515,6811116,10214917,9753060,8060754,8337110,7128304,11105496,2881012,6708013,9190929,2228467,9835458,7650663,10910468,6848770,10575804,6790402,6878300,9121382,7435991,7258470,7749066,8292213,6589111,6848168,10879447,4061578,7632339,22390,80095518,7999976,6903720,6843042,8700214,8015759,7295898,9835598,6568360,7168330,10780866,9120262,7165048,2315114,7715080,10003517,6478263,8720576,8013098,80278000,9779914,7768958,3638626,11142073,10555889,6708366,7379722,2680416,3806669,2331136,3029581,8043353,10003282,7368569,8184682,7869061,3923282,9142886,3838897,8485690,3944506,843415,9665501,9439102,10524703,10920048,10538046,10351612,2612933,3837130,7208650,3656551,8370176,10219544,7589220,7898606,10063374,10307311,9534164,10449108,1516779,2629100,7420900,6035655,6909990,3714586,8478090,832189,3648885,8965978,4007310,7710801,8022372,8830177,8356815,9846891,8155402,6615848,9996982,3898199,2048680,2328100,9721924,6130267,8015139,9183922,10453040,8015147,7295812,80148816,7395590,7865104','[^,]+', 1, LEVEL) AS PR_NRDCONTA,
           REGEXP_SUBSTR('12102,12159,12186,12192,12201,12208,12217,13738,13774,13861,13950,13984,14008,14015,14018,14023,14027,14029,14041,14043,14045,14049,14062,14109,20553,20644,20645,26546,27072,27076,27213,27221,27260,27284,27362,28145,64514,65174,66007,160661,160771,160854,161544,161546,161717,161784,162201,162204,162218,162286,162415,162432,162433,162491,162697,162709,162716,162728,2432200,2438351,2445953,2446660,2449017,2478226,2483595,2484304,2484912,2486051,2486309,2486627,2487043,2487236,2487414,2487697,2487886,2488146,2488399,2488416,2488778,2489852,2489954,2490354,2490987,2491272,2491427,2492036,2492192,2492371,2492544,2492746,2492859,2493208,2493361,2493580,2493859,2494288,2494360,2494438,2495268,2495324,2495375,2495523,2495827,2496017,2496206,2496388,2496712,2496784,2496854,2496958,2497127,2497825,2497933,2498079,2498267,2498306,2498442,2498462,2498484,2498621,2498624,2498634,2498751,2498803,2498821,2498916,2498926,2498956,2498976,2499032,2499119,2499166,2499234,2499294,2499318,2499404,2499458,2499490,2499510,2499558,2499670,2499681,2499703,2499714,2499738,2499760,2499799,2499851,2499882,2499894,2499920,2500394,2500448,2500539,2500552,2500556,2500626,2500630,2500683,2500723,2500739,2500956,2501001,2501059,2501132,2501153,2501242,2501282,2501347,2501457,2501467,2501474,2501600,2501624,2501823,2501991,2502057,2502078,2502185,2502254,2502255,2502806,2502920,2502956,2503019,2503020,2503114,2503164,2503183,2503257,2503332,2503347,2503408,2503542,2503551,2503590,2503622,2503845,2503976,2503986,2504187,2504192,2504213,2504414,2504485,2504512,2504531,2504559,2504618,2504711,2504716,2504762,2504763,2504798,2504866,2504869,2504883,2504953,2508172,2508623,2513417,2521121','[^,]+', 1, LEVEL) AS PR_NRCTRATO,
           REGEXP_SUBSTR('10,10,10,10,10,10,10,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,12,5,5,9,9,9,9,9,9,9,9,9,13,13,13,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1','[^,]+', 1, LEVEL) AS PR_CDCOOPER
    FROM DUAL 
  CONNECT BY REGEXP_SUBSTR('56316,1031,13250,122947,76945,15253,81477,7064,1015,24864,36714,127230,32808,30449,1163,152803,29513,152773,12521,153214,41351,25860,19038,23787,12122,81000,81140,286117,199702,5452,114294,10251,20249,194786,22195,286117,238066,429805,59277,461059,60038,2358042,6939,325031,3619575,2358514,13552,166723,2694603,6161448,3851893,108308,6554911,134996,541001,643564,217212,198986,3735788,7943563,9329641,9406786,8818037,8697442,9688722,10659510,10692061,8321671,6530303,2246490,3906523,10589104,9170847,8329150,9720057,9356240,10341790,9372431,3872416,9745483,2846101,3924432,2180227,10247238,2334283,10247440,2180570,8592080,2180588,2180561,11084626,3937933,9616063,6179460,8235864,7208510,6977332,868094,2569027,80495192,8176515,6811116,10214917,9753060,8060754,8337110,7128304,11105496,2881012,6708013,9190929,2228467,9835458,7650663,10910468,6848770,10575804,6790402,6878300,9121382,7435991,7258470,7749066,8292213,6589111,6848168,10879447,4061578,7632339,22390,80095518,7999976,6903720,6843042,8700214,8015759,7295898,9835598,6568360,7168330,10780866,9120262,7165048,2315114,7715080,10003517,6478263,8720576,8013098,80278000,9779914,7768958,3638626,11142073,10555889,6708366,7379722,2680416,3806669,2331136,3029581,8043353,10003282,7368569,8184682,7869061,3923282,9142886,3838897,8485690,3944506,843415,9665501,9439102,10524703,10920048,10538046,10351612,2612933,3837130,7208650,3656551,8370176,10219544,7589220,7898606,10063374,10307311,9534164,10449108,1516779,2629100,7420900,6035655,6909990,3714586,8478090,832189,3648885,8965978,4007310,7710801,8022372,8830177,8356815,9846891,8155402,6615848,9996982,3898199,2048680,2328100,9721924,6130267,8015139,9183922,10453040,8015147,7295812,80148816,7395590,7865104','[^,]+', 1, LEVEL) IS NOT NULL;
      
  CURSOR cr_tbepr_adiamento_contrato (pr_dtmvtoan IN crapdat.dtmvtoan%TYPE, pr_cooperativa IN NUMBER, pr_conta IN NUMBER, pr_contrato IN NUMBER)IS
    SELECT DISTINCT 
      crapepr.cdcooper, 
      crapepr.nrdconta, 
      crapepr.nrctremp,
      crapepr.dtdpagto,
      crapepr.diarefju,
      crapepr.mesrefju,
      crapepr.anorefju,
      crawepr.dtlibera,
      crawepr.txdiaria,
      crawepr.txmensal,
      crapepr.vlsdeved,
      crapepr.vlpreemp,
      crapepr.txjuremp,
      (select max(crappep.nrparepr)       
       from crappep
       where crappep.cdcooper = crapepr.cdcooper
         and crappep.nrdconta = crapepr.nrdconta
         and crappep.nrctremp = crapepr.nrctremp
         and crappep.inliquid = 0) ultima_parcela, 
      crawepr.qtpreemp  
    FROM crapepr
    JOIN crawepr
      ON crawepr.cdcooper = crapepr.cdcooper
     AND crawepr.nrdconta = crapepr.nrdconta
     AND crawepr.nrctremp = crapepr.nrctremp
    WHERE crapepr.inliquid = 0
      AND crapepr.cdcooper = pr_cooperativa 
      AND crapepr.nrdconta = pr_conta 
      AND crapepr.nrctremp = pr_contrato;
      
BEGIN
   -- Inicializar o CLOB
   vr_texto_completo := NULL;
   vr_des_log        := NULL;
   dbms_lob.createtemporary(vr_des_log, TRUE);
   dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);
  --Cabeçalho para geração do arquivo de log
  gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,'Cooperativa;Conta;Contrato;Parcela atual;Parcela nova;Saldo devedor atual;Novo saldo devedor'|| chr(10));
  --set serveroutput on size unlimited
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
  -- Loop no cursor de 222 contratos apontados com necessidade de atualização 
  FOR ret_contrato_atualizacao IN cr_coop_conta_contrato_atualizar LOOP   
    vr_contador_cursor_contratos := vr_contador_cursor_contratos + 1;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 1);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      RETURN;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    FOR rw_tbepr_adiamento_contrato IN cr_tbepr_adiamento_contrato (pr_dtmvtoan => rw_crapdat.dtmvtoan, 
                                                                    pr_cooperativa => ret_contrato_atualizacao.PR_CDCOOPER, 
                                                                    pr_conta => ret_contrato_atualizacao.PR_NRDCONTA, 
                                                                    pr_contrato => ret_contrato_atualizacao.PR_NRCTRATO) LOOP
      vr_tab_erro.DELETE;
      vr_tab_pgto_parcel.DELETE;
      vr_tab_calculado.DELETE;
      vr_vlparepr := 0;
      --------------------------------------------------------------------------------------------------      
      -- Calcular Juros Remuneratorio ate hoje para compor o saldo
      --------------------------------------------------------------------------------------------------                  
      --Data referencia recebe movimento
      vr_dtrefjur := rw_crapdat.dtmvtolt;
          
      --Retornar Dia/mes/ano de referencia
      vr_diarefju := to_number(to_char(vr_dtrefjur, 'DD'));
      vr_mesrefju := to_number(to_char(vr_dtrefjur, 'MM'));
      vr_anorefju := to_number(to_char(vr_dtrefjur, 'YYYY'));
          
      --Calcular Quantidade dias
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(rw_tbepr_adiamento_contrato.dtdpagto, 'DD') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => rw_tbepr_adiamento_contrato.diarefju -- Dia da data de referência da última vez que rodou juros
                              ,pr_mesrefju => rw_tbepr_adiamento_contrato.mesrefju -- Mes da data de referência da última vez que rodou juros
                              ,pr_anorefju => rw_tbepr_adiamento_contrato.anorefju -- Ano da data de referência da última vez que rodou juros
                              ,pr_diafinal => vr_diarefju -- Dia data final
                              ,pr_mesfinal => vr_mesrefju -- Mes data final
                              ,pr_anofinal => vr_anorefju -- Ano data final
                              ,pr_qtdedias => vr_qtdiajur); -- Quantidade de dias calculada
      --------------------------------------------------------------------------------------------------      
      -- Calcula saldo devedor atualizado
      --------------------------------------------------------------------------------------------------
      empr0001.pc_busca_pgto_parcelas(pr_cdcooper => rw_tbepr_adiamento_contrato.cdcooper
                                     ,pr_cdagenci => 0
                                     ,pr_nrdcaixa => 0
                                     ,pr_cdoperad => '1'
                                     ,pr_nmdatela => 'ATENDA'
                                     ,pr_idorigem => 5
                                     ,pr_nrdconta => rw_tbepr_adiamento_contrato.nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_flgerlog => 0
                                     ,pr_nrctremp => rw_tbepr_adiamento_contrato.nrctremp
                                     ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                     ,pr_nrparepr => 0
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro
                                     ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                     ,pr_tab_calculado   => vr_tab_calculado);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;            
        ELSE
          vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
        END IF;      
        RAISE vr_exc_erro;
      END IF;
      --------------------------------------------------------------------------------------------------      
      -- Calculo do residuo (nova parcela)
      --------------------------------------------------------------------------------------------------
      vr_qtd_parcelas_restantes := rw_tbepr_adiamento_contrato.qtpreemp - vr_tab_calculado(1).qtprecal;
      -- Calcula taxa diária
      vr_taxa_diaria := round((100 * (POWER((rw_tbepr_adiamento_contrato.txmensal / 100) + 1, (1 / 30)) - 1)), 10);
      -- Valor presente com ajuste da carencia
      vr_vlr_ajust_car := NVL(vr_tab_calculado(1).vlsdeved,0) * POWER(1 + (vr_taxa_diaria / 100), vr_qtdiajur - 30);
      -- Valor da Prestacao
      vr_nova_prestacao := (vr_vlr_ajust_car * rw_tbepr_adiamento_contrato.txmensal / 100) / 
                           (1 - POWER((1 + rw_tbepr_adiamento_contrato.txmensal / 100), (-1 * vr_qtd_parcelas_restantes)));
      --Registro das alterações que serão realizdas
      dbms_output.put_line('Cooperativa/Conta/Contrato: ' || ret_contrato_atualizacao.PR_CDCOOPER || '/' || ret_contrato_atualizacao.PR_NRDCONTA || '/' || ret_contrato_atualizacao.PR_NRCTRATO);
      dbms_output.put_line('Valor atual parcela: '||rw_tbepr_adiamento_contrato.vlpreemp||' -- Saldo devedor: '||rw_tbepr_adiamento_contrato.vlsdeved);
      dbms_output.put_line('Novo valor parcela: '||vr_nova_prestacao||' -- Novo saldo devedor: '||  vr_tab_calculado(1).vlsdeved);
      --------------------------------------------------------------------------------------------------      
      -- Atualiza o valor da parcela com o valor do residuo
      --------------------------------------------------------------------------------------------------
      BEGIN
        UPDATE crappep SET 
          vlparepr = NVL(vr_nova_prestacao,rw_tbepr_adiamento_contrato.vlpreemp), --> Valor da parcela
          vlsdvpar = NVL(vr_nova_prestacao,rw_tbepr_adiamento_contrato.vlpreemp), --> Contem o valor do saldo devedor da parcela.
          vlsdvsji = NVL(vr_nova_prestacao,rw_tbepr_adiamento_contrato.vlpreemp)  --> Contem o saldo devedor da parcela sem juros de inadimplencia.
        WHERE crappep.cdcooper = rw_tbepr_adiamento_contrato.cdcooper
          AND crappep.nrdconta = rw_tbepr_adiamento_contrato.nrdconta
          AND crappep.nrctremp = rw_tbepr_adiamento_contrato.nrctremp
          AND crappep.inliquid = 0
          AND crappep.vlparepr = rw_tbepr_adiamento_contrato.vlpreemp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := SQLERRM;
          RAISE vr_exc_erro;
      END;
        
      -- Registrar log
      --Cabeçalho: 'Cooperativa;Conta;Contrato;Parcela atual;Parcela nova;Saldo devedor atual;Novo saldo devedor'
      gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,rw_tbepr_adiamento_contrato.cdcooper||';'||
                                                           rw_tbepr_adiamento_contrato.nrdconta||';'||
                                                           rw_tbepr_adiamento_contrato.nrctremp||';'||
                                                           REPLACE(rw_tbepr_adiamento_contrato.vlpreemp,',','.')||';'||
                                                           REPLACE(vr_nova_prestacao,',','.')||';'||
                                                           REPLACE(rw_tbepr_adiamento_contrato.vlsdeved,',','.')||';'||
                                                           REPLACE(vr_tab_calculado(1).vlsdeved,',','.')||';'||chr(10));
      
      vr_contador_atualizados := vr_contador_atualizados + 1;
    END LOOP;
  END LOOP;
  
  -- Fecha o arquivo
  gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,' ' || chr(10),TRUE);
    
  vr_dsdireto := SISTEMA.obternomedirectory(GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/matheusklug');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log,vr_dsdireto,'contratos_PESE.csv',NLS_CHARSET_ID('UTF8'));
    
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  -- Sucesso
  dbms_output.put_line('Quantidade de contratos analisados: '|| vr_contador_cursor_contratos);
  dbms_output.put_line('Quantidade de contratos atualizados: '|| vr_contador_atualizados);
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Erro na atualização dos contratos de PESE. Operação abortada. Causa: ' || sqlerrm);
    ROLLBACK;
END;
