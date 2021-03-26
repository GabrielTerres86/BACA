declare
  v_erro   varchar2(2000);
  --
  PROCEDURE pc_trata_linha_retorno(p_idsicredi in number,
                                   p_dsautenticacao in varchar2,
                                   p_cdagente in number) IS
    --
    cursor cr_registro_remessa_pagfor is
      select r.idsicredi,
             r.cdstatus_processamento,
             r.dhinclusao_processamento,
             r.dhretorno_processamento,
             r.nmarquivo_inclusao,
             r.nmarquivo_retorno,
             r.dsprocessamento,
             r.cdempresa_documento,
             r.cdcooper,
             r.nrdconta,
             r.cdagenci,
             r.nrdolote,
             r.nrautenticacao_documento,
             r.vlrpagamento,
             p.dtmovimento
        from tbconv_registro_remessa_pagfor r,
             tbconv_remessa_pagfor p
       where r.idsicredi = p_idsicredi
         and p.idremessa = r.idremessa;
    rw_registro_remessa_pagfor cr_registro_remessa_pagfor%rowtype;

    vr_exc_erro      exception;
    vr_rej_erro      exception;
    vr_rej_prot      exception;
    vr_dscritic      varchar2(4000);
    vr_dscomprovante crappro.dscomprovante_parceiro%type := null;
    v_pr_dscomprovante  VARCHAR2(4000) := null;
    v_pr_dhleitura      date;
    vr_dsprotoc      crappro.dsprotoc%type;
    --
    PROCEDURE pc_comprovante_darf_gps (pr_idsicredi      IN tbconv_registro_remessa_pagfor.idsicredi%TYPE,
                                       pr_dtmovimento    IN tbconv_remessa_pagfor.dtmovimento%TYPE,
                                       pr_cdempres       IN tbconv_registro_remessa_pagfor.cdempresa_documento%TYPE,
                                       pr_cdagente       IN NUMBER,
                                       pr_dtcomprovante  IN DATE,
                                       pr_dsautenticacao IN VARCHAR2,
                                       pr_dsprotoc       IN crappro.dsprotoc%TYPE,
                                       pr_dscomprovante OUT VARCHAR2) IS
    BEGIN
      DECLARE       
        CURSOR cr_craplft IS                        
          SELECT lft.dtmvtolt
                ,lft.cdtribut
                ,lft.nrrefere
                ,lft.vllanmto
                ,lft.vlrjuros
                ,lft.vlrmulta
                ,(lft.vllanmto + lft.vlrjuros + lft.vlrmulta) vlrtotal
                ,lft.nrcpfcgc
                ,lft.dtapurac
                ,lft.dtlimite
                ,lft.cdcooper
                ,lft.nrdconta
                ,lft.cdagenci
            FROM craplft lft
           WHERE lft.idsicred = pr_idsicredi
             AND lft.dtmvtolt = pr_dtmovimento;
        rw_craplft cr_craplft%ROWTYPE;   
        
        CURSOR cr_craplgp IS  
          SELECT lgp.dtmvtolt
                ,lgp.vlrtotal
                ,lgp.cdcooper
                ,lgp.nrctapag
                ,lgp.cdagenci
                ,lgp.cddpagto
                ,lgp.cdidenti2
                ,lgp.mmaacomp
                ,lgp.vlrdinss
                ,lgp.vlrouent
                ,lgp.vlrjuros
            FROM craplgp lgp
           WHERE lgp.idsicred = pr_idsicredi
             AND lgp.dtmvtolt = pr_dtmovimento;
        rw_craplgp cr_craplgp%ROWTYPE;
   
        vr_exec_saida EXCEPTION;    
      BEGIN      
        pr_dscomprovante := ' ';      
        
        IF pr_cdempres = 'A0' THEN -- DARF Normal Sem Barras
          OPEN cr_craplft;
          FETCH cr_craplft INTO rw_craplft;        
          IF cr_craplft%NOTFOUND THEN
            CLOSE cr_craplft;
            RAISE vr_exec_saida;
          END IF;        
          CLOSE cr_craplft;      
          
          PAGA0003.pc_comprovante_darf_gps_tivit (pr_cdcooper  => rw_craplft.cdcooper,
                                                  pr_nrdconta  => rw_craplft.nrdconta,
                                                  pr_cdagenci  => rw_craplft.cdagenci,
                                                  pr_dtmvtolt  => pr_dtmovimento,
                                                  pr_cdempres  => pr_cdempres,
                                                  pr_cdagente  => pr_cdagente,
                                                  pr_dttransa  => pr_dtcomprovante,
                                                  pr_hrtransa  => TO_NUMBER(TO_CHAR(pr_dtcomprovante,'sssss')),
                                                  pr_dsprotoc  => pr_dsprotoc,
                                                  pr_dsautent  => pr_dsautenticacao,
                                                  pr_idsicred  => pr_idsicredi,
                                                  pr_nrsequen  => 0,
                                                  pr_cdtribut  => rw_craplft.cdtribut,
                                                  pr_nrrefere  => rw_craplft.nrrefere,
                                                  pr_vllanmto  => rw_craplft.vllanmto,
                                                  pr_vlrjuros  => rw_craplft.vlrjuros,
                                                  pr_vlrmulta  => rw_craplft.vlrmulta,
                                                  pr_vlrtotal  => rw_craplft.vlrtotal,
                                                  pr_nrcpfcgc  => rw_craplft.nrcpfcgc,
                                                  pr_dtapurac  => rw_craplft.dtapurac,
                                                  pr_dtlimite  => rw_craplft.dtlimite,
                                                  pr_cddpagto  => 0,
                                                  pr_cdidenti2 => ' ',
                                                  pr_mmaacomp  => 0,
                                                  pr_vlrdinss  => 0,
                                                  pr_vlrouent  => 0,
                                                  pr_flgcaixa  => FALSE,
                                                  pr_dscomprv  => pr_dscomprovante);
        ELSIF pr_cdempres = 'C06' THEN -- GPS Sem Barras 
          OPEN cr_craplgp;
          FETCH cr_craplgp INTO rw_craplgp;        
          IF cr_craplgp%NOTFOUND THEN
            CLOSE cr_craplgp;
            RAISE vr_exec_saida;
          END IF;        
          CLOSE cr_craplgp;                            
          
          PAGA0003.pc_comprovante_darf_gps_tivit (pr_cdcooper  => rw_craplgp.cdcooper,
                                                  pr_nrdconta  => rw_craplgp.nrctapag,
                                                  pr_cdagenci  => rw_craplgp.cdagenci,
                                                  pr_dtmvtolt  => pr_dtmovimento,
                                                  pr_cdempres  => pr_cdempres,
                                                  pr_cdagente  => pr_cdagente,
                                                  pr_dttransa  => pr_dtcomprovante,
                                                  pr_hrtransa  => TO_NUMBER(TO_CHAR(pr_dtcomprovante,'sssss')),
                                                  pr_dsprotoc  => pr_dsprotoc,
                                                  pr_dsautent  => pr_dsautenticacao,
                                                  pr_idsicred  => pr_idsicredi,
                                                  pr_nrsequen  => 0,
                                                  pr_cdtribut  => ' ',
                                                  pr_nrrefere  => ' ',
                                                  pr_vllanmto  => 0,
                                                  pr_vlrjuros  => rw_craplgp.vlrjuros,
                                                  pr_vlrmulta  => 0,
                                                  pr_vlrtotal  => rw_craplgp.vlrtotal,
                                                  pr_nrcpfcgc  => ' ',
                                                  pr_dtapurac  => NULL,
                                                  pr_dtlimite  => NULL,
                                                  pr_cddpagto  => rw_craplgp.cddpagto,
                                                  pr_cdidenti2 => rw_craplgp.cdidenti2,
                                                  pr_mmaacomp  => rw_craplgp.mmaacomp,
                                                  pr_vlrdinss  => rw_craplgp.vlrdinss,
                                                  pr_vlrouent  => rw_craplgp.vlrouent,
                                                  pr_flgcaixa  => FALSE,
                                                  pr_dscomprv  => pr_dscomprovante);    
        END IF;
      EXCEPTION
        WHEN vr_exec_saida THEN 
          pr_dscomprovante := ' ';
        WHEN OTHERS THEN
          pr_dscomprovante := ' ';
      END;
    END pc_comprovante_darf_gps;
    
    FUNCTION fn_obtem_protocolo (pr_cdempresa_documento      IN tbconv_registro_remessa_pagfor.cdempresa_documento%TYPE,
                                 pr_cdcooper                 IN tbconv_registro_remessa_pagfor.cdcooper%TYPE,
                                 pr_nrdolote                 IN tbconv_registro_remessa_pagfor.nrdolote%TYPE,
                                 pr_cdagenci                 IN tbconv_registro_remessa_pagfor.cdagenci%TYPE,
                                 pr_dtmovimento              IN tbconv_remessa_pagfor.dtmovimento%TYPE,
                                 pr_nrautenticacao_documento IN tbconv_registro_remessa_pagfor.nrautenticacao_documento%TYPE)
                                 RETURN VARCHAR2 IS
    -------------------------------------------------------------------------------------------------------------------------
    
      CURSOR cr_crapaut(pr_cdcooper IN crapaut.cdcooper%TYPE,
                        pr_cdagenci IN crapaut.cdagenci%TYPE,
                        pr_nrdcaixa IN crapaut.nrdcaixa%TYPE,
                        pr_dtmvtolt IN crapaut.dtmvtolt%TYPE,
                        pr_nrsequen IN crapaut.nrsequen%TYPE) IS
        SELECT a.dsprotoc
          FROM crapaut a
         WHERE a.cdcooper = pr_cdcooper
           AND a.cdagenci = pr_cdagenci
           AND a.nrdcaixa = pr_nrdcaixa
           AND a.dtmvtolt = pr_dtmvtolt
           AND a.nrsequen = pr_nrsequen;       
           
      CURSOR cr_crappro(pr_cdcooper IN crappro.cdcooper%TYPE
                       ,pr_dsprotoc IN crappro.dsprotoc%TYPE) IS
        SELECT COUNT(*)
          FROM crappro pro
         WHERE pro.cdcooper        = pr_cdcooper
           AND UPPER(pro.dsprotoc) LIKE pr_dsprotoc||'%';         
             
      vr_nrdcaixa crapaut.nrdcaixa%TYPE;
      vr_dsprotoc crappro.dsprotoc%TYPE;
      vr_flgexist NUMBER;
      
    BEGIN
      
      IF pr_cdempresa_documento = 'C06' THEN -- GPS
        vr_nrdcaixa := pr_nrdolote - 31000;
      ELSE -- Demais Tributos
        vr_nrdcaixa := pr_nrdolote - 15000;
      END IF;
              
      OPEN cr_crapaut(pr_cdcooper => pr_cdcooper,
                      pr_cdagenci => pr_cdagenci,
                      pr_nrdcaixa => vr_nrdcaixa,
                      pr_dtmvtolt => pr_dtmovimento,
                      pr_nrsequen => pr_nrautenticacao_documento);
      FETCH cr_crapaut INTO vr_dsprotoc;
      CLOSE cr_crapaut;
      
      IF NVL(vr_dsprotoc,' ') <> ' ' THEN
        OPEN cr_crappro(pr_cdcooper => pr_cdcooper, 
                        pr_dsprotoc => vr_dsprotoc);
        FETCH cr_crappro INTO vr_flgexist;      
        CLOSE cr_crappro;    
        
        IF NVL(vr_flgexist,0) = 0 THEN
          -- Atribuir valor null pois dsprotoc não existe na crappro
          vr_dsprotoc := NULL;
        END IF;
      END IF;
      
      RETURN NVL(vr_dsprotoc,' ');
      
    END fn_obtem_protocolo;

  BEGIN
    OPEN cr_registro_remessa_pagfor;
    FETCH cr_registro_remessa_pagfor INTO rw_registro_remessa_pagfor;
    CLOSE cr_registro_remessa_pagfor;

    -- Se tem um comprovante retornado pelo serviço Bancoob de arrecadação ou autenticação mecânica retornada pela TIVIT e foi pago via Conta Online ou Ailos Mobile
    -- atualizar o registro do comprovante do Aimaro com essa informação adicional para disponibilização na impressão através dos canais
    IF rw_registro_remessa_pagfor.cdagenci = 90 AND (NVL(v_pr_dscomprovante,' ') <> ' ' OR NVL(p_dsautenticacao,' ') <>  ' ') THEN
      vr_dsprotoc := fn_obtem_protocolo(pr_cdempresa_documento      => rw_registro_remessa_pagfor.cdempresa_documento,
                                        pr_cdcooper                 => rw_registro_remessa_pagfor.cdcooper,
                                        pr_nrdolote                 => rw_registro_remessa_pagfor.nrdolote,
                                        pr_cdagenci                 => rw_registro_remessa_pagfor.cdagenci,
                                        pr_dtmovimento              => rw_registro_remessa_pagfor.dtmovimento,
                                        pr_nrautenticacao_documento => rw_registro_remessa_pagfor.nrautenticacao_documento);

      -- Atualizar crappro somente se encontrou o protocolo gerado no momento do pagamento
      IF vr_dsprotoc <> ' ' THEN
        -- Criar comprovante e aplicar encode em formato em Base64 para pagamento liquidado via TIVIT
        -- Essa criação é necessária para armazenar o comprovante no mesmo modelo e fluxo aplicado para API do Bancoob
        IF NVL(p_dsautenticacao,' ') <>  ' ' THEN
          pc_comprovante_darf_gps (pr_idsicredi      => rw_registro_remessa_pagfor.idsicredi,
                                   pr_dtmovimento    => rw_registro_remessa_pagfor.dtmovimento,
                                   pr_cdempres       => rw_registro_remessa_pagfor.cdempresa_documento,
                                   pr_cdagente       => p_cdagente,
                                   pr_dtcomprovante  => v_pr_dhleitura,
                                   pr_dsautenticacao => p_dsautenticacao,
                                   pr_dsprotoc       => vr_dsprotoc,
                                   pr_dscomprovante  => vr_dscomprovante);
        ELSE -- API Bancoob já retorna o comprovante em Base64
          vr_dscomprovante := v_pr_dscomprovante;
        END IF;

        IF NVL(vr_dscomprovante,' ') <>  ' ' THEN
          GENE0006.pc_grava_comprovante_parceiro (pr_cdcooper               => rw_registro_remessa_pagfor.cdcooper,
                                                  pr_dsprotoc               => vr_dsprotoc,
                                                  pr_dscomprovante_parceiro => vr_dscomprovante,
                                                  pr_dscritic               => vr_dscritic);

          IF TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := vr_dscritic || ' - IDArrecadacao: ' || rw_registro_remessa_pagfor.idsicredi;
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      rollback;
      raise_application_error(-20002, vr_dscritic);
    WHEN others THEN
      vr_dscritic := sqlerrm;
      rollback;
      raise_application_error(-20001, vr_dscritic);
  END;
  --
begin
  pc_trata_linha_retorno(2761602, '093POLO00000985081202202109003805562489', 93);
  pc_trata_linha_retorno(2761697, '093POLO00000985531202202109003800242108', 93);
  pc_trata_linha_retorno(2761698, '093POLO00000985541202202109003800108555', 93);
  pc_trata_linha_retorno(2761700, '093POLO00000985561202202109003800085614', 93);
  pc_trata_linha_retorno(2761702, '093POLO00000985581202202109003800051225', 93);
  pc_trata_linha_retorno(2761710, '093POLO00000985661202202109003800025000', 93);
  pc_trata_linha_retorno(2761713, '093POLO00000985691202202109003800030060', 93);
  pc_trata_linha_retorno(2761714, '093POLO00000985701202202109003800118955', 93);
  pc_trata_linha_retorno(2761715, '093POLO00000985711202202109003800132479', 93);
  pc_trata_linha_retorno(2761716, '093POLO00000985721202202109003801245283', 93);
  pc_trata_linha_retorno(2761717, '093POLO00000985731202202109003801706080', 93);
  pc_trata_linha_retorno(2761718, '093POLO00000985741202202109003800098620', 93);
  pc_trata_linha_retorno(2761719, '093POLO00000985751202202109003800086484', 93);
  pc_trata_linha_retorno(2761720, '093POLO00000985761202202109003800547200', 93);
  pc_trata_linha_retorno(2761721, '093POLO00000985771202202109003800328320', 93);
  pc_trata_linha_retorno(2761722, '093POLO00000985781202202109003800031083', 93);
  pc_trata_linha_retorno(2761723, '093POLO00000985791202202109003800013135', 93);
  pc_trata_linha_retorno(2761830, '093POLO00000985991202202109003800231136', 93);
  pc_trata_linha_retorno(2761831, '093POLO00000986001202202109003800369518', 93);
  pc_trata_linha_retorno(2761832, '093POLO00000986011202202109003800376103', 93);
  pc_trata_linha_retorno(2761833, '093POLO00000986021202202109003800041332', 93);
  pc_trata_linha_retorno(2761834, '093POLO00000986031202202109003800104194', 93);
  pc_trata_linha_retorno(2761835, '093POLO00000986041202202109003800008868', 93);
  pc_trata_linha_retorno(2761836, '093POLO00000986051202202109003800052760', 93);
  pc_trata_linha_retorno(2761837, '093POLO00000986061202202109003800002500', 93);
  pc_trata_linha_retorno(2761838, '093POLO00000986071202202109003800050828', 93);
  pc_trata_linha_retorno(2761839, '093POLO00000986081202202109003809402335', 93);
  pc_trata_linha_retorno(2761840, '093POLO00000986091202202109003800015548', 93);
  pc_trata_linha_retorno(2761841, '093POLO00000986101202202109003800015548', 93);
  pc_trata_linha_retorno(2761842, '093POLO00000986111202202109003800015548', 93);
  pc_trata_linha_retorno(2761843, '093POLO00000986121202202109003800011617', 93);
  pc_trata_linha_retorno(2761844, '093POLO00000986131202202109003800083218', 93);
  pc_trata_linha_retorno(2761845, '093POLO00000986141202202109003810435266', 93);
  pc_trata_linha_retorno(2761846, '093POLO00000986151202202109003800182490', 93);
  pc_trata_linha_retorno(2761847, '093POLO00000986161202202109003800044726', 93);
  pc_trata_linha_retorno(2761848, '093POLO00000986171202202109003800004402', 93);
  pc_trata_linha_retorno(2761849, '093POLO00000986181202202109003800009577', 93);
  pc_trata_linha_retorno(2761850, '093POLO00000986191202202109003800008451', 93);
  pc_trata_linha_retorno(2761851, '093POLO00000986201202202109003800008059', 93);
  pc_trata_linha_retorno(2761852, '093POLO00000986211202202109003800054637', 93);
  pc_trata_linha_retorno(2761853, '093POLO00000986221202202109003900050000', 93);
  pc_trata_linha_retorno(2761854, '093POLO00000986231202202109003900009577', 93);
  pc_trata_linha_retorno(2761855, '093POLO00000986241202202109003900053719', 93);
  pc_trata_linha_retorno(2761856, '093POLO00000986251202202109003900008868', 93);
  pc_trata_linha_retorno(2761857, '093POLO00000986261202202109003900008451', 93);
  pc_trata_linha_retorno(2761858, '093POLO00000986271202202109003900008059', 93);
  pc_trata_linha_retorno(2761859, '093POLO00000986281202202109003900003354', 93);
  pc_trata_linha_retorno(2761860, '093POLO00000986291202202109003900002580', 93);
  pc_trata_linha_retorno(2761861, '093POLO00000986301202202109003900002500', 93);
  pc_trata_linha_retorno(2761862, '093POLO00000986311202202109003900017021', 93);
  pc_trata_linha_retorno(2761863, '093POLO00000986321202202109003900003688', 93);
  pc_trata_linha_retorno(2761864, '093POLO00000986331202202109003900199503', 93);
  pc_trata_linha_retorno(2761865, '093POLO00000986341202202109003900198272', 93);
  pc_trata_linha_retorno(2761866, '093POLO00000986351202202109003900175224', 93);
  pc_trata_linha_retorno(2761867, '093POLO00000986361202202109003900538900', 93);
  pc_trata_linha_retorno(2761868, '093POLO00000986371202202109003900534340', 93);
  pc_trata_linha_retorno(2761869, '093POLO00000986381202202109003900448979', 93);
  pc_trata_linha_retorno(2761870, '093POLO00000986391202202109003900385000', 93);
  pc_trata_linha_retorno(2761871, '093POLO00000986401202202109003900231000', 93);
  pc_trata_linha_retorno(2761872, '093POLO00000986411202202109003900001662', 93);
  pc_trata_linha_retorno(2761873, '093POLO00000986421202202109003900122412', 93);
  pc_trata_linha_retorno(2761874, '093POLO00000986431202202109003900204019', 93);
  pc_trata_linha_retorno(2761993, '093POLO00000986451202202109003900025744', 93);
  pc_trata_linha_retorno(2761994, '093POLO00000986461202202109003900070000', 93);
  pc_trata_linha_retorno(2761995, '093POLO00000986471202202109003900050719', 93);
  pc_trata_linha_retorno(2761996, '093POLO00000986481202202109003900070000', 93);
  pc_trata_linha_retorno(2761997, '093POLO00000986491202202109003900006846', 93);
  pc_trata_linha_retorno(2761998, '093POLO00000986501202202109003900007337', 93);
  pc_trata_linha_retorno(2761999, '093POLO00000986511202202109003900076706', 93);
  pc_trata_linha_retorno(2762000, '093POLO00000986521202202109003900702579', 93);
  pc_trata_linha_retorno(2762001, '093POLO00000986531202202109003900331557', 93);
  pc_trata_linha_retorno(2762002, '093POLO00000986541202202109003900057181', 93);
  pc_trata_linha_retorno(2762003, '093POLO00000986551202202109003900084672', 93);
  pc_trata_linha_retorno(2762004, '093POLO00000986561202202109003902900241', 93);
  pc_trata_linha_retorno(2762005, '093POLO00000986571202202109003900366780', 93);
  pc_trata_linha_retorno(2762006, '093POLO00000986581202202109003900084917', 93);
  pc_trata_linha_retorno(2762007, '093POLO00000986591202202109003900057877', 93);
  pc_trata_linha_retorno(2762008, '093POLO00000986601202202109003900001547', 93);
  pc_trata_linha_retorno(2762009, '093POLO00000986611202202109003900010804', 93);
  pc_trata_linha_retorno(2762010, '093POLO00000986621202202109003901304871', 93);
  pc_trata_linha_retorno(2762011, '093POLO00000986631202202109003900318386', 93);
  pc_trata_linha_retorno(2762012, '093POLO00000986641202202109003900257616', 93);
  pc_trata_linha_retorno(2762013, '093POLO00000986651202202109003900220068', 93);
  pc_trata_linha_retorno(2762014, '093POLO00000986661202202109003901147027', 93);
  pc_trata_linha_retorno(2762015, '093POLO00000986671202202109003901258667', 93);
  pc_trata_linha_retorno(2762016, '093POLO00000986681202202109003900669120', 93);
  pc_trata_linha_retorno(2762017, '093POLO00000986691202202109003900056139', 93);
  pc_trata_linha_retorno(2762018, '093POLO00000986701202202109003900060480', 93);
  pc_trata_linha_retorno(2762019, '093POLO00000986711202202109003900160534', 93);
  pc_trata_linha_retorno(2762020, '093POLO00000986721202202109003900080394', 93);
  pc_trata_linha_retorno(2762021, '093POLO00000986731202202109003900052105', 93);
  pc_trata_linha_retorno(2762022, '093POLO00000986741202202109003900261440', 93);
  pc_trata_linha_retorno(2762023, '093POLO00000986751202202109003900277452', 93);
  pc_trata_linha_retorno(2762024, '093POLO00000986761202202109003900039909', 93);
  pc_trata_linha_retorno(2762025, '093POLO00000986771202202109003900184199', 93);
  pc_trata_linha_retorno(2762026, '093POLO00000986781202202109003900001612', 93);
  pc_trata_linha_retorno(2762027, '093POLO00000986791202202109003900209281', 93);
  pc_trata_linha_retorno(2762130, '093POLO00000986931202202109003901057606', 93);
  pc_trata_linha_retorno(2762131, '093POLO00000986941202202109003901358530', 93);
  pc_trata_linha_retorno(2762132, '093POLO00000986951202202109003900085029', 93);
  pc_trata_linha_retorno(2762133, '093POLO00000986961202202109003900286548', 93);
  pc_trata_linha_retorno(2762134, '093POLO00000986971202202109003900041252', 93);
  pc_trata_linha_retorno(2762135, '093POLO00000986981202202109003900045364', 93);
  pc_trata_linha_retorno(2762136, '093POLO00000986991202202109003900033919', 93);
  pc_trata_linha_retorno(2762137, '093POLO00000987001202202109003900022409', 93);
  pc_trata_linha_retorno(2762138, '093POLO00000987011202202109003900055867', 93);
  pc_trata_linha_retorno(2762139, '093POLO00000987021202202109003900530693', 93);
  pc_trata_linha_retorno(2762140, '093POLO00000987031202202109003905913542', 93);
  pc_trata_linha_retorno(2762141, '093POLO00000987041202202109003900117274', 93);
  pc_trata_linha_retorno(2762142, '093POLO00000987051202202109003900033919', 93);
  pc_trata_linha_retorno(2762143, '093POLO00000987061202202109003900144397', 93);
  pc_trata_linha_retorno(2762144, '093POLO00000987071202202109003900019116', 93);
  pc_trata_linha_retorno(2762145, '093POLO00000987081202202109003900021240', 93);
  pc_trata_linha_retorno(2762146, '093POLO00000987091202202109003900172250', 93);
  pc_trata_linha_retorno(2762147, '093POLO00000987101202202109003900046723', 93);
  pc_trata_linha_retorno(2762148, '093POLO00000987111202202109003900028751', 93);
  pc_trata_linha_retorno(2762149, '093POLO00000987121202202109003900016574', 93);
  pc_trata_linha_retorno(2762150, '093POLO00000987131202202109003900018169', 93);
  pc_trata_linha_retorno(2762151, '093POLO00000987141202202109003900036268', 93);
  pc_trata_linha_retorno(2762240, '093POLO00000987461202202109004000336549', 93);
  pc_trata_linha_retorno(2762241, '093POLO00000987471202202109004000403335', 93);
  pc_trata_linha_retorno(2762242, '093POLO00000987481202202109004000363001', 93);
  pc_trata_linha_retorno(2762243, '093POLO00000987491202202109004000364623', 93);
  pc_trata_linha_retorno(2762244, '093POLO00000987501202202109004000535211', 93);
  pc_trata_linha_retorno(2762245, '093POLO00000987511202202109004000035086', 93);
  pc_trata_linha_retorno(2762246, '093POLO00000987521202202109004000038666', 93);
  pc_trata_linha_retorno(2762247, '093POLO00000987531202202109004001596734', 93);
  pc_trata_linha_retorno(2762248, '093POLO00000987541202202109004000017163', 93);
  pc_trata_linha_retorno(2762249, '093POLO00000987551202202109004000617626', 93);
  pc_trata_linha_retorno(2762250, '093POLO00000987561202202109004000328160', 93);
  pc_trata_linha_retorno(2762251, '093POLO00000987571202202109004000043925', 93);
  pc_trata_linha_retorno(2762252, '093POLO00000987581202202109004000013690', 93);
  pc_trata_linha_retorno(2762253, '093POLO00000987591202202109004000016739', 93);
  pc_trata_linha_retorno(2762254, '093POLO00000987601202202109004000033642', 93);
  pc_trata_linha_retorno(2762255, '093POLO00000987611202202109004000002426', 93);
  pc_trata_linha_retorno(2762256, '093POLO00000987621202202109004000370576', 93);
  pc_trata_linha_retorno(2762257, '093POLO00000987631202202109004000009352', 93);
  pc_trata_linha_retorno(2762258, '093POLO00000987641202202109004000104932', 93);
  pc_trata_linha_retorno(2762259, '093POLO00000987651202202109004001401860', 93);
  pc_trata_linha_retorno(2762260, '093POLO00000987661202202109004001996234', 93);
  pc_trata_linha_retorno(2761740, '093POLO00000985521202202109003800292764', 93);
  pc_trata_linha_retorno(2761875, '093POLO00000985801202202109003800011836', 93);
  pc_trata_linha_retorno(2761876, '093POLO00000985811202202109003800116744', 93);
  pc_trata_linha_retorno(2761877, '093POLO00000985821202202109003800190440', 93);
  pc_trata_linha_retorno(2761878, '093POLO00000985831202202109003800134919', 93);
  pc_trata_linha_retorno(2761879, '093POLO00000985841202202109003800192332', 93);
  pc_trata_linha_retorno(2761880, '093POLO00000985851202202109003800270593', 93);
  pc_trata_linha_retorno(2761881, '093POLO00000985861202202109003800102329', 93);
  pc_trata_linha_retorno(2761882, '093POLO00000985871202202109003800052573', 93);
  pc_trata_linha_retorno(2761883, '093POLO00000985881202202109003800052556', 93);
  pc_trata_linha_retorno(2761884, '093POLO00000985891202202109003800013916', 93);
  pc_trata_linha_retorno(2761885, '093POLO00000985901202202109003800243098', 93);
  pc_trata_linha_retorno(2761886, '093POLO00000985911202202109003800140723', 93);
  pc_trata_linha_retorno(2761887, '093POLO00000985921202202109003800013126', 93);
  pc_trata_linha_retorno(2761888, '093POLO00000985931202202109003800036694', 93);
  pc_trata_linha_retorno(2761889, '093POLO00000985941202202109003800245462', 93);
  pc_trata_linha_retorno(2761890, '093POLO00000985951202202109003800033357', 93);
  pc_trata_linha_retorno(2761891, '093POLO00000985961202202109003800067138', 93);
  pc_trata_linha_retorno(2761892, '093POLO00000985971202202109003800051921', 93);
  pc_trata_linha_retorno(2761893, '093POLO00000985981202202109003800157807', 93);
  pc_trata_linha_retorno(2762028, '093POLO00000986801202202109003900066673', 93);
  pc_trata_linha_retorno(2762029, '093POLO00000986811202202109003900055489', 93);
  pc_trata_linha_retorno(2762030, '093POLO00000986821202202109003900051804', 93);
  pc_trata_linha_retorno(2762031, '093POLO00000986831202202109003900013927', 93);
  pc_trata_linha_retorno(2762032, '093POLO00000986841202202109003900019097', 93);
  pc_trata_linha_retorno(2762033, '093POLO00000986851202202109003900013546', 93);
  pc_trata_linha_retorno(2762034, '093POLO00000986861202202109003900013264', 93);
  pc_trata_linha_retorno(2762035, '093POLO00000986871202202109003900087607', 93);
  pc_trata_linha_retorno(2762036, '093POLO00000986881202202109003900056831', 93);
  pc_trata_linha_retorno(2762037, '093POLO00000986891202202109003900055781', 93);
  pc_trata_linha_retorno(2762038, '093POLO00000986901202202109003900051247', 93);
  pc_trata_linha_retorno(2762039, '093POLO00000986911202202109003900051973', 93);
  pc_trata_linha_retorno(2762040, '093POLO00000986921202202109003900053499', 93);
  pc_trata_linha_retorno(2762152, '093POLO00000987151202202109003900032817', 93);
  pc_trata_linha_retorno(2762153, '093POLO00000987161202202109003900058387', 93);
  pc_trata_linha_retorno(2762154, '093POLO00000987171202202109003900058192', 93);
  pc_trata_linha_retorno(2762155, '093POLO00000987181202202109003900058083', 93);
  pc_trata_linha_retorno(2762156, '093POLO00000987191202202109003900055486', 93);
  pc_trata_linha_retorno(2762157, '093POLO00000987201202202109003900031190', 93);
  pc_trata_linha_retorno(2762158, '093POLO00000987211202202109003900030857', 93);
  pc_trata_linha_retorno(2762159, '093POLO00000987221202202109003900079781', 93);
  pc_trata_linha_retorno(2762160, '093POLO00000987231202202109003900069192', 93);
  pc_trata_linha_retorno(2762161, '093POLO00000987241202202109003900013110', 93);
  pc_trata_linha_retorno(2762162, '093POLO00000987251202202109003900035509', 93);
  pc_trata_linha_retorno(2762163, '093POLO00000987261202202109003900033055', 93);
  pc_trata_linha_retorno(2762164, '093POLO00000987271202202109003900050678', 93);
  pc_trata_linha_retorno(2762165, '093POLO00000987281202202109003900051920', 93);
  pc_trata_linha_retorno(2762261, '093POLO00000987291202202109003900013581', 93);
  pc_trata_linha_retorno(2762262, '093POLO00000987301202202109003900144387', 93);
  pc_trata_linha_retorno(2762263, '093POLO00000987311202202109003900055677', 93);
  pc_trata_linha_retorno(2762264, '093POLO00000987321202202109003900084679', 93);
  pc_trata_linha_retorno(2762265, '093POLO00000987331202202109003900044756', 93);
  pc_trata_linha_retorno(2762266, '093POLO00000987341202202109003900053734', 93);
  pc_trata_linha_retorno(2762268, '093POLO00000987361202202109003900050203', 93);
  pc_trata_linha_retorno(2762269, '093POLO00000987371202202109003900064384', 93);
  pc_trata_linha_retorno(2762270, '093POLO00000987381202202109003900060685', 93);
  pc_trata_linha_retorno(2762271, '093POLO00000987391202202109003900054718', 93);
  pc_trata_linha_retorno(2762272, '093POLO00000987401202202109003900034996', 93);
  pc_trata_linha_retorno(2762273, '093POLO00000987411202202109003900207689', 93);
  pc_trata_linha_retorno(2762274, '093POLO00000987421202202109003900055194', 93);
  pc_trata_linha_retorno(2762275, '093POLO00000987431202202109004000052008', 93);
  pc_trata_linha_retorno(2762276, '093POLO00000987441202202109004000056087', 93);
  pc_trata_linha_retorno(2762277, '093POLO00000987451202202109004000154922', 93);
  commit;
exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20003, v_erro);
end;
