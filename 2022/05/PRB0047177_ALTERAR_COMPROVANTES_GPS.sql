declare
  vr_idsicredi varchar2(10);
  vr_autenticacao VARCHAR(100);
  vr_dscritic varchar2(4000);
  vr_dscomprovante crappro.dscomprovante_parceiro%TYPE;
  
  CURSOR cr_pagamentos IS
    SELECT 5415817 IDENTIFICADOR, '341000000008137641805202205300400054365' AUTENTICACAO_MECANICA FROM DUAL UNION
    SELECT 5415847, '341000000008137691805202205300400053372' FROM DUAL UNION
    SELECT 5415848, '341000000008137701805202205300400052545' FROM DUAL UNION
    SELECT 5415940, '341000000008137961805202205300400024240' FROM DUAL UNION
    SELECT 5416030, '341000000008138081805202205300400056138' FROM DUAL UNION
    SELECT 5416031, '341000000008138091805202205300400077412' FROM DUAL UNION
    SELECT 5416032, '341000000008138101805202205300400056138' FROM DUAL UNION
    SELECT 5416033, '341000000008138111805202205300400077412' FROM DUAL UNION
    SELECT 5416114, '341000000008138351805202205300500057657' FROM DUAL UNION
    SELECT 5416115, '341000000008138361805202205300500056140' FROM DUAL UNION
    SELECT 5416140, '341000000008138451805202205300500123176' FROM DUAL UNION
    SELECT 5416141, '341000000008138461805202205300500058209' FROM DUAL UNION
    SELECT 5416142, '341000000008138471805202205300500056850' FROM DUAL UNION
    SELECT 5416182, '341000000008138481805202205300500111771' FROM DUAL UNION
    SELECT 5416183, '341000000008138491805202205300500072495' FROM DUAL UNION
    SELECT 5416184, '341000000008138501805202205300500052873' FROM DUAL UNION
    SELECT 5416185, '341000000008138511805202205300500053251' FROM DUAL UNION
    SELECT 5416186, '341000000008138521805202205300500054117' FROM DUAL UNION
    SELECT 5416188, '341000000008138541805202205300500077238' FROM DUAL UNION
    SELECT 5416229, '341000000008138841805202205300500055923' FROM DUAL UNION
    SELECT 5416230, '341000000008138851805202205300500055376' FROM DUAL UNION
    SELECT 5416266, '341000000008138891805202205300500108876' FROM DUAL UNION
    SELECT 5416267, '341000000008138901805202205300500068925' FROM DUAL UNION
    SELECT 5416268, '341000000008138911805202205300500231619' FROM DUAL UNION
    SELECT 5416301, '341000000008138981805202205300500055274' FROM DUAL UNION
    SELECT 5416302, '341000000008138991805202205300500098005' FROM DUAL UNION
    SELECT 5416338, '341000000008139241805202205300600290417' FROM DUAL UNION
    SELECT 5416380, '341000000008139351805202205300600058313' FROM DUAL UNION
    SELECT 5416421, '341000000008139491805202205300700290417' FROM DUAL UNION
    SELECT 5416422, '341000000008139501805202205300700109161' FROM DUAL UNION
    SELECT 5416423, '341000000008139511805202205300700102433' FROM DUAL UNION
    SELECT 5416424, '341000000008139521805202205300700054798' FROM DUAL UNION
    SELECT 5416484, '341000000008139581805202205300700041258' FROM DUAL UNION
    SELECT 5416670, '341000000008140271805202205300800163523' FROM DUAL UNION
    SELECT 5416735, '341000000008140361805202205300800011755' FROM DUAL UNION
    SELECT 5416736, '341000000008140371805202205300800078072' FROM DUAL UNION
    SELECT 5416853, '341000000008140801805202205300800126111' FROM DUAL UNION
    SELECT 5416913, '341000000008140811805202205300800054112' FROM DUAL UNION
    SELECT 5416947, '341000000008140941805202205300800129092' FROM DUAL UNION
    SELECT 5416948, '341000000008140951805202205300800054102' FROM DUAL UNION
    SELECT 5416989, '341000000008141251805202205300900055617' FROM DUAL UNION
    SELECT 5417036, '341000000008141361805202205300900052235' FROM DUAL UNION
    SELECT 5417094, '341000000008141371805202205300900054539' FROM DUAL UNION
    SELECT 5417143, '341000000008141531805202205300900054070' FROM DUAL UNION
    SELECT 5417144, '341000000008141541805202205300900054070' FROM DUAL UNION
    SELECT 5417145, '341000000008141551805202205300900054070' FROM DUAL UNION
    SELECT 5417146, '341000000008141561805202205300900091377' FROM DUAL UNION
    SELECT 5417147, '341000000008141571805202205300900053046' FROM DUAL UNION
    SELECT 5417148, '341000000008141581805202205300900053046' FROM DUAL UNION
    SELECT 5417149, '341000000008141591805202205300900053046' FROM DUAL UNION
    SELECT 5417150, '341000000008141601805202205300900053046' FROM DUAL UNION
    SELECT 5417206, '341000000008141661805202205300900190683' FROM DUAL UNION
    SELECT 5417207, '341000000008141671805202205300900204759' FROM DUAL UNION
    SELECT 5417321, '341000000008142021805202205301000056404' FROM DUAL UNION
    SELECT 5417364, '341000000008142111805202205301000056404' FROM DUAL UNION
    SELECT 5417367, '341000000008142141805202205301000078477' FROM DUAL UNION
    SELECT 5417368, '341000000008142151805202205301000078477' FROM DUAL UNION
    SELECT 5417369, '341000000008142161805202205301000183856' FROM DUAL UNION
    SELECT 5417370, '341000000008142171805202205301000219600' FROM DUAL UNION
    SELECT 5417371, '341000000008142181805202205301000053705' FROM DUAL UNION
    SELECT 5417372, '341000000008142191805202205301000078477' FROM DUAL;
  rw_pagamentos cr_pagamentos%ROWTYPE;
  
  CURSOR cr_registros_lgp(pr_idsicredi IN tbconv_registro_remessa_pagfor.idsicredi%TYPE) IS
    SELECT LGP.IDSICRED, 
           SUBSTR(PRO.DSPROTOC, 1, 39) dsprotoc,
           LGP.CDCOOPER,
           LGP.NRCTAPAG,
           LGP.CDAGENCI,
           LGP.CDDPAGTO,
           LGP.VLRJUROS,
           LGP.VLRDINSS,
           LGP.VLROUENT,
           LGP.VLRTOTAL,
           REG.DHRETORNO_PROCESSAMENTO,
           LGP.MMAACOMP,
           LGP.DTMVTOLT,
           LGP.CDIDENTI2
      FROM CRAPLGP LGP,
           TBCONV_REGISTRO_REMESSA_PAGFOR REG,
           CRAPPRO PRO
     WHERE lgp.idsicred = pr_idsicredi
       AND pro.cdcooper = lgp.cdcooper
       AND pro.nrdconta = lgp.nrctapag
       AND pro.dtmvtolt = lgp.dtmvtolt
       AND pro.cdtippro = 13
       AND pro.nrseqaut = lgp.nrautdoc
       AND reg.idsicredi = lgp.idsicred;
  rw_registros_lgp cr_registros_lgp%ROWTYPE;

BEGIN     

  FOR rw_pagamentos IN cr_pagamentos LOOP
      
      vr_idsicredi    := rw_pagamentos.identificador;
      vr_autenticacao := rw_pagamentos.autenticacao_mecanica;
        
      OPEN cr_registros_lgp(pr_idsicredi => vr_idsicredi);
      FETCH cr_registros_lgp INTO rw_registros_lgp;
      CLOSE cr_registros_lgp;
        
      PAGA0003.pc_comprovante_darf_gps_tivit (pr_cdcooper  => rw_registros_lgp.cdcooper,
                                              pr_nrdconta  => rw_registros_lgp.nrctapag,
                                              pr_cdagenci  => rw_registros_lgp.cdagenci,
                                              pr_dtmvtolt  => rw_registros_lgp.dtmvtolt,
                                              pr_cdempres  => 'C06',
                                              pr_cdagente  => 341,
                                              pr_dttransa  => rw_registros_lgp.dhretorno_processamento,
                                              pr_hrtransa  => TO_NUMBER(TO_CHAR(rw_registros_lgp.dhretorno_processamento,'sssss')),
                                              pr_dsprotoc  => rw_registros_lgp.dsprotoc,
                                              pr_dsautent  => vr_autenticacao,
                                              pr_idsicred  => vr_idsicredi,
                                              pr_nrsequen  => 0,
                                              pr_cdtribut  => ' ',
                                              pr_nrrefere  => ' ',
                                              pr_vllanmto  => 0,
                                              pr_vlrjuros  => rw_registros_lgp.vlrjuros,
                                              pr_vlrmulta  => 0,
                                              pr_vlrtotal  => rw_registros_lgp.vlrtotal,
                                              pr_nrcpfcgc  => ' ',
                                              pr_dtapurac  => NULL,
                                              pr_dtlimite  => NULL,
                                              pr_cddpagto  => rw_registros_lgp.cddpagto,
                                              pr_cdidenti2 => rw_registros_lgp.cdidenti2,
                                              pr_mmaacomp  => rw_registros_lgp.mmaacomp,
                                              pr_vlrdinss  => rw_registros_lgp.vlrdinss,
                                              pr_vlrouent  => rw_registros_lgp.vlrouent,
                                              pr_flgcaixa  => FALSE,
                                              pr_dscomprv  => vr_dscomprovante);                                          

      GENE0006.pc_grava_comprovante_parceiro (pr_cdcooper               => rw_registros_lgp.cdcooper,
                                              pr_dsprotoc               => rw_registros_lgp.dsprotoc,
                                              pr_dscomprovante_parceiro => vr_dscomprovante,
                                              pr_dscritic               => vr_dscritic);
        
      GENE0006.pc_grava_arrecadador_parceiro (pr_cdcooper => rw_registros_lgp.cdcooper,
                                              pr_nrdconta => rw_registros_lgp.nrctapag,
                                              pr_dsprotoc => rw_registros_lgp.dsprotoc,
                                              pr_cdagente => 341,
                                              pr_dscritic => vr_dscritic);    

  END LOOP;
  
  COMMIT;

END;
