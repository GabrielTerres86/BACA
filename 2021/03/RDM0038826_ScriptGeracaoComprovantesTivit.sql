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
	pc_trata_linha_retorno(3028015, '093POLO00001687522403202112323800087933', 93);
	pc_trata_linha_retorno(3029379, '093POLO00001683772403202109022200071224', 93);
	pc_trata_linha_retorno(3029380, '093POLO00001683782403202109022200009648', 93);
	pc_trata_linha_retorno(3029381, '093POLO00001683722403202109321600071469', 93);
	pc_trata_linha_retorno(3029382, '093POLO00001683732403202109321600014031', 93);
	pc_trata_linha_retorno(3029383, '093POLO00001683742403202109321600014013', 93);
	pc_trata_linha_retorno(3029432, '093POLO00001683972403202109022200009149', 93);
	pc_trata_linha_retorno(3029433, '093POLO00001683982403202109022200663900', 93);
	pc_trata_linha_retorno(3029434, '093POLO00001683992403202109022200062123', 93);
	pc_trata_linha_retorno(3029435, '093POLO00001684002403202109022200286719', 93);
	pc_trata_linha_retorno(3029436, '093POLO00001684012403202109022200253669', 93);
	pc_trata_linha_retorno(3029437, '093POLO00001684022403202109022200228302', 93);
	pc_trata_linha_retorno(3029438, '093POLO00001684032403202109022200018046', 93);
	pc_trata_linha_retorno(3029439, '093POLO00001684042403202109022200008646', 93);
	pc_trata_linha_retorno(3029440, '093POLO00001684052403202109022200008646', 93);
	pc_trata_linha_retorno(3029441, '093POLO00001684062403202109022200008646', 93);
	pc_trata_linha_retorno(3029442, '093POLO00001684072403202109022200008646', 93);
	pc_trata_linha_retorno(3029443, '093POLO00001684082403202109022200003674', 93);
	pc_trata_linha_retorno(3029444, '093POLO00001684092403202109022200003697', 93);
	pc_trata_linha_retorno(3029445, '093POLO00001683792403202109321600013418', 93);
	pc_trata_linha_retorno(3029446, '093POLO00001683802403202109321600014078', 93);
	pc_trata_linha_retorno(3029447, '093POLO00001683812403202109321600014014', 93);
	pc_trata_linha_retorno(3029448, '093POLO00001683822403202109321600013995', 93);
	pc_trata_linha_retorno(3029449, '093POLO00001683832403202109321600150831', 93);
	pc_trata_linha_retorno(3029560, '093POLO00001684112403202109022200001573', 93);
	pc_trata_linha_retorno(3029561, '093POLO00001684122403202109022200001134', 93);
	pc_trata_linha_retorno(3029562, '093POLO00001684132403202109022200129978', 93);
	pc_trata_linha_retorno(3029563, '093POLO00001684142403202109022200001109', 93);
	pc_trata_linha_retorno(3029564, '093POLO00001684152403202109022200060845', 93);
	pc_trata_linha_retorno(3029565, '093POLO00001684162403202109022200061556', 93);
	pc_trata_linha_retorno(3029566, '093POLO00001684172403202109022200284107', 93);
	pc_trata_linha_retorno(3029567, '093POLO00001684182403202109022200001515', 93);
	pc_trata_linha_retorno(3029568, '093POLO00001684192403202109022200010167', 93);
	pc_trata_linha_retorno(3029569, '093POLO00001684202403202109321600127202', 93);
	pc_trata_linha_retorno(3029570, '093POLO00001684212403202109321600037580', 93);
	pc_trata_linha_retorno(3029571, '093POLO00001684222403202109321600012299', 93);
	pc_trata_linha_retorno(3029572, '093POLO00001684232403202109321600012219', 93);
	pc_trata_linha_retorno(3029573, '093POLO00001684242403202109321600049234', 93);
	pc_trata_linha_retorno(3029574, '093POLO00001684252403202109321600054600', 93);
	pc_trata_linha_retorno(3029605, '093POLO00001684322403202109022200254430', 93);
	pc_trata_linha_retorno(3029606, '093POLO00001684332403202109022201174288', 93);
	pc_trata_linha_retorno(3029614, '093POLO00001684342403202110022600020687', 93);
	pc_trata_linha_retorno(3029617, '093POLO00001684352403202110022600204943', 93);
	pc_trata_linha_retorno(3029618, '093POLO00001684362403202110022600054648', 93);
	pc_trata_linha_retorno(3029622, '093POLO00001684372403202110022600001278', 93);
	pc_trata_linha_retorno(3029623, '093POLO00001684382403202110022600005621', 93);
	pc_trata_linha_retorno(3029633, '093POLO00001684422403202110022600033051', 93);
	pc_trata_linha_retorno(3029634, '093POLO00001684412403202110323000029761', 93);
	pc_trata_linha_retorno(3029657, '093POLO00001684392403202110323000012100', 93);
	pc_trata_linha_retorno(3029686, '093POLO00001684402403202110022600149773', 93);
	pc_trata_linha_retorno(3029699, '093POLO00001684482403202110022600001376', 93);
	pc_trata_linha_retorno(3029700, '093POLO00001684492403202110323000073109', 93);
	pc_trata_linha_retorno(3029718, '093POLO00001684452403202110022600010058', 93);
	pc_trata_linha_retorno(3029719, '093POLO00001684462403202110022600039747', 93);
	pc_trata_linha_retorno(3029720, '093POLO00001684472403202110022600002556', 93);
	pc_trata_linha_retorno(3029721, '093POLO00001684432403202110323000252519', 93);
	pc_trata_linha_retorno(3029722, '093POLO00001684442403202110323000050926', 93);
	pc_trata_linha_retorno(3029728, '093POLO00001684602403202111024700001959', 93);
	pc_trata_linha_retorno(3029729, '093POLO00001684612403202111024700011376', 93);
	pc_trata_linha_retorno(3029730, '093POLO00001684622403202111024700444453', 93);
	pc_trata_linha_retorno(3029731, '093POLO00001684632403202111024702051321', 93);
	pc_trata_linha_retorno(3029732, '093POLO00001684642403202111024700378159', 93);
	pc_trata_linha_retorno(3029733, '093POLO00001684672403202111324200003850', 93);
	pc_trata_linha_retorno(3029744, '093POLO00001684682403202111024700005087', 93);
	pc_trata_linha_retorno(3029745, '093POLO00001684692403202111324200024233', 93);
	pc_trata_linha_retorno(3029746, '093POLO00001684702403202111324200027077', 93);
	pc_trata_linha_retorno(3029766, '093POLO00001684532403202110022600004089', 93);
	pc_trata_linha_retorno(3029767, '093POLO00001684502403202110323000350775', 93);
	pc_trata_linha_retorno(3029780, '093POLO00001684552403202110022600002681', 93);
	pc_trata_linha_retorno(3029781, '093POLO00001684562403202110022600008315', 93);
	pc_trata_linha_retorno(3029782, '093POLO00001684542403202110323000063230', 93);
	pc_trata_linha_retorno(3029798, '093POLO00001684572403202111024700015551', 93);
	pc_trata_linha_retorno(3029799, '093POLO00001684582403202111024700071775', 93);
	pc_trata_linha_retorno(3029800, '093POLO00001684592403202111024700053910', 93);
	pc_trata_linha_retorno(3029828, '093POLO00001684962403202111024700300299', 93);
	pc_trata_linha_retorno(3029829, '093POLO00001684972403202111024700007028', 93);
	pc_trata_linha_retorno(3029830, '093POLO00001684982403202111024700032436', 93);
	pc_trata_linha_retorno(3029832, '093POLO00001685012403202111324200552301', 93);
	pc_trata_linha_retorno(3029833, '093POLO00001685022403202111324200012498', 93);
	pc_trata_linha_retorno(3029849, '093POLO00001684952403202111024700037957', 93);
	pc_trata_linha_retorno(3029870, '093POLO00001685052403202111024700001457', 93);
	pc_trata_linha_retorno(3029871, '093POLO00001685062403202111024700004517', 93);
	pc_trata_linha_retorno(3029901, '093POLO00001685072403202111324200051968', 93);
	pc_trata_linha_retorno(3029902, '093POLO00001685082403202111324200010474', 93);
	pc_trata_linha_retorno(3029921, '093POLO00001684712403202111024700013006', 93);
	pc_trata_linha_retorno(3029922, '093POLO00001684722403202111024700005295', 93);
	pc_trata_linha_retorno(3029923, '093POLO00001685092403202111324200051947', 93);
	pc_trata_linha_retorno(3029924, '093POLO00001685102403202111324200017296', 93);
	pc_trata_linha_retorno(3029957, '093POLO00001685192403202112031800027305', 93);
	pc_trata_linha_retorno(3029958, '093POLO00001685202403202112031800019913', 93);
	pc_trata_linha_retorno(3029959, '093POLO00001685212403202112031800405532', 93);
	pc_trata_linha_retorno(3029960, '093POLO00001685222403202112031800515022', 93);
	pc_trata_linha_retorno(3029961, '093POLO00001685232403202112031800463520', 93);
	pc_trata_linha_retorno(3029962, '093POLO00001685242403202112031800087865', 93);
	pc_trata_linha_retorno(3029963, '093POLO00001685252403202112031800154248', 93);
	pc_trata_linha_retorno(3029964, '093POLO00001685262403202112031800154248', 93);
	pc_trata_linha_retorno(3029995, '093POLO00001684742403202111024700002383', 93);
	pc_trata_linha_retorno(3029996, '093POLO00001684752403202111024700011000', 93);
	pc_trata_linha_retorno(3029997, '093POLO00001684762403202111024700036783', 93);
	pc_trata_linha_retorno(3029998, '093POLO00001684772403202111024700008952', 93);
	pc_trata_linha_retorno(3029999, '093POLO00001684782403202111024700016574', 93);
	pc_trata_linha_retorno(3030000, '093POLO00001684792403202111324200256103', 93);
	pc_trata_linha_retorno(3030001, '093POLO00001684802403202111324200059887', 93);
	pc_trata_linha_retorno(3030002, '093POLO00001684812403202111324200200911', 93);
	pc_trata_linha_retorno(3030003, '093POLO00001684822403202111324200081351', 93);
	pc_trata_linha_retorno(3030004, '093POLO00001684832403202111324200110238', 93);
	pc_trata_linha_retorno(3030023, '093POLO00001684862403202111024700006195', 93);
	pc_trata_linha_retorno(3030024, '093POLO00001684872403202111024700002328', 93);
	pc_trata_linha_retorno(3030025, '093POLO00001684882403202111324200051402', 93);
	pc_trata_linha_retorno(3030026, '093POLO00001684892403202111024700048229', 93);
	pc_trata_linha_retorno(3030027, '093POLO00001684902403202111024700037498', 93);
	pc_trata_linha_retorno(3030028, '093POLO00001684912403202111024700156155', 93);
	pc_trata_linha_retorno(3030029, '093POLO00001684922403202111324200050527', 93);
	pc_trata_linha_retorno(3030030, '093POLO00001684932403202111324200013942', 93);
	pc_trata_linha_retorno(3030049, '093POLO00001685442403202112031800001787', 93);
	pc_trata_linha_retorno(3030050, '093POLO00001685432403202112323800053371', 93);
	pc_trata_linha_retorno(3030060, '093POLO00001685552403202112031800027000', 93);
	pc_trata_linha_retorno(3030061, '093POLO00001685562403202112031800005850', 93);
	pc_trata_linha_retorno(3030062, '093POLO00001685572403202112323800057827', 93);
	pc_trata_linha_retorno(3030063, '093POLO00001685582403202112031800001240', 93);
	pc_trata_linha_retorno(3030082, '093POLO00001685812403202112031800938241', 93);
	pc_trata_linha_retorno(3030083, '093POLO00001685822403202112031804330343', 93);
	pc_trata_linha_retorno(3030084, '093POLO00001685832403202112031800183637', 93);
	pc_trata_linha_retorno(3030085, '093POLO00001685732403202112323806398726', 93);
	pc_trata_linha_retorno(3030086, '093POLO00001685742403202112323800121255', 93);
	pc_trata_linha_retorno(3030087, '093POLO00001685752403202112323800114845', 93);
	pc_trata_linha_retorno(3030088, '093POLO00001685762403202112323800105534', 93);
	pc_trata_linha_retorno(3030089, '093POLO00001685772403202112323800013738', 93);
	pc_trata_linha_retorno(3030090, '093POLO00001685782403202112323800013458', 93);
	pc_trata_linha_retorno(3030091, '093POLO00001685792403202112323800012219', 93);
	pc_trata_linha_retorno(3030092, '093POLO00001685802403202112323800079286', 93);
	pc_trata_linha_retorno(3030106, '093POLO00001685132403202112031800059610', 93);
	pc_trata_linha_retorno(3030107, '093POLO00001685142403202112031800017794', 93);
	pc_trata_linha_retorno(3030108, '093POLO00001685152403202112031800009390', 93);
	pc_trata_linha_retorno(3030109, '093POLO00001685162403202112031800076978', 93);
	pc_trata_linha_retorno(3030110, '093POLO00001685172403202112031800016679', 93);
	pc_trata_linha_retorno(3030111, '093POLO00001685182403202112031800003818', 93);
	pc_trata_linha_retorno(3030112, '093POLO00001685112403202112323800014088', 93);
	pc_trata_linha_retorno(3030113, '093POLO00001685122403202112323800003497', 93);
	pc_trata_linha_retorno(3030127, '093POLO00001685272403202112031800204041', 93);
	pc_trata_linha_retorno(3030128, '093POLO00001685282403202112031800003534', 93);
	pc_trata_linha_retorno(3030129, '093POLO00001685292403202112031800001152', 93);
	pc_trata_linha_retorno(3030130, '093POLO00001685302403202112031800016574', 93);
	pc_trata_linha_retorno(3030131, '093POLO00001685312403202112031800001712', 93);
	pc_trata_linha_retorno(3030132, '093POLO00001685322403202112323800024853', 93);
	pc_trata_linha_retorno(3030133, '093POLO00001685332403202112323800400224', 93);
	pc_trata_linha_retorno(3030134, '093POLO00001685342403202112323800399729', 93);
	pc_trata_linha_retorno(3030147, '093POLO00001685852403202112031800013500', 93);
	pc_trata_linha_retorno(3030148, '093POLO00001685862403202112031800170272', 93);
	pc_trata_linha_retorno(3030149, '093POLO00001685872403202112031800002925', 93);
	pc_trata_linha_retorno(3030150, '093POLO00001685882403202112031800001805', 93);
	pc_trata_linha_retorno(3030151, '093POLO00001685892403202112031800008275', 93);
	pc_trata_linha_retorno(3030152, '093POLO00001685902403202112031800038193', 93);
	pc_trata_linha_retorno(3030153, '093POLO00001685912403202112031800511686', 93);
	pc_trata_linha_retorno(3030154, '093POLO00001685922403202112323800071469', 93);
	pc_trata_linha_retorno(3030155, '093POLO00001685932403202112323800034437', 93);
	pc_trata_linha_retorno(3030156, '093POLO00001685942403202112323800034437', 93);
	pc_trata_linha_retorno(3030164, '093POLO00001685352403202112031800002000', 93);
	pc_trata_linha_retorno(3030165, '093POLO00001685362403202112031800005801', 93);
	pc_trata_linha_retorno(3030180, '093POLO00001685452403202112031800707385', 93);
	pc_trata_linha_retorno(3030181, '093POLO00001685462403202112031800025409', 93);
	pc_trata_linha_retorno(3030182, '093POLO00001685472403202112323800127202', 93);
	pc_trata_linha_retorno(3030183, '093POLO00001685482403202112323800003196', 93);
	pc_trata_linha_retorno(3030184, '093POLO00001685492403202112323800079984', 93);
	pc_trata_linha_retorno(3030210, '093POLO00001685652403202112031800011065', 93);
	pc_trata_linha_retorno(3030211, '093POLO00001685662403202112031800017124', 93);
	pc_trata_linha_retorno(3030212, '093POLO00001685672403202112031800002316', 93);
	pc_trata_linha_retorno(3030213, '093POLO00001685682403202112031800010767', 93);
	pc_trata_linha_retorno(3030214, '093POLO00001685692403202112031800010050', 93);
	pc_trata_linha_retorno(3030215, '093POLO00001685702403202112031800002178', 93);
	pc_trata_linha_retorno(3030216, '093POLO00001685712403202112031800016500', 93);
	pc_trata_linha_retorno(3030217, '093POLO00001685722403202112031800003575', 93);
	pc_trata_linha_retorno(3030218, '093POLO00001685592403202112323800045255', 93);
	pc_trata_linha_retorno(3030219, '093POLO00001685602403202112323800040586', 93);
	pc_trata_linha_retorno(3030220, '093POLO00001685612403202112323800301051', 93);
	pc_trata_linha_retorno(3030221, '093POLO00001685622403202112323800007957', 93);
	pc_trata_linha_retorno(3030240, '093POLO00001686102403202112031800005726', 93);
	pc_trata_linha_retorno(3030241, '093POLO00001686112403202112031800084046', 93);
	pc_trata_linha_retorno(3030242, '093POLO00001686122403202112323800010703', 93);
	pc_trata_linha_retorno(3030243, '093POLO00001686132403202112031800054648', 93);
	pc_trata_linha_retorno(3030244, '093POLO00001686142403202112031800003429', 93);
	pc_trata_linha_retorno(3030245, '093POLO00001686152403202112031800001846', 93);
	pc_trata_linha_retorno(3030246, '093POLO00001686162403202112031801152024', 93);
	pc_trata_linha_retorno(3030247, '093POLO00001686172403202112031800249605', 93);
	pc_trata_linha_retorno(3030248, '093POLO00001686032403202112323800055876', 93);
	pc_trata_linha_retorno(3030279, '093POLO00001686042403202112323800010703', 93);
	pc_trata_linha_retorno(3030280, '093POLO00001686052403202112031800003786', 93);
	pc_trata_linha_retorno(3030281, '093POLO00001686062403202112031800049037', 93);
	pc_trata_linha_retorno(3030282, '093POLO00001686072403202112031800030473', 93);
	pc_trata_linha_retorno(3030283, '093POLO00001686082403202112031800006463', 93);
	pc_trata_linha_retorno(3030284, '093POLO00001686092403202112031800060853', 93);
	pc_trata_linha_retorno(3030285, '093POLO00001686002403202112323800039177', 93);
	pc_trata_linha_retorno(3030286, '093POLO00001686012403202112323800060438', 93);
	pc_trata_linha_retorno(3030287, '093POLO00001686022403202112323800062072', 93);
	pc_trata_linha_retorno(3030311, '093POLO00001686202403202112031800006617', 93);
	pc_trata_linha_retorno(3030312, '093POLO00001686212403202112031800004674', 93);
	pc_trata_linha_retorno(3030313, '093POLO00001686222403202112031800021572', 93);
	pc_trata_linha_retorno(3030314, '093POLO00001686232403202112031800019699', 93);
	pc_trata_linha_retorno(3030315, '093POLO00001686242403202112031800004268', 93);
	pc_trata_linha_retorno(3030316, '093POLO00001686252403202112031800006636', 93);
	pc_trata_linha_retorno(3030317, '093POLO00001686262403202112031800001073', 93);
	pc_trata_linha_retorno(3030318, '093POLO00001686272403202112031800004950', 93);
	pc_trata_linha_retorno(3030348, '093POLO00001685962403202112031800286719', 93);
	pc_trata_linha_retorno(3030349, '093POLO00001685972403202112031800062123', 93);
	pc_trata_linha_retorno(3030350, '093POLO00001685952403202112323800014560', 93);
	pc_trata_linha_retorno(3030370, '093POLO00001686372403202112323800539394', 93);
	pc_trata_linha_retorno(3030371, '093POLO00001686382403202112323800006556', 93);
	pc_trata_linha_retorno(3030372, '093POLO00001686392403202101322900060957', 93);
	pc_trata_linha_retorno(3030373, '093POLO00001686402403202101322900013976', 93);
	pc_trata_linha_retorno(3030403, '093POLO00001686342403202112031800002194', 93);
	pc_trata_linha_retorno(3030404, '093POLO00001686352403202112031800124476', 93);
	pc_trata_linha_retorno(3030405, '093POLO00001686362403202112031800005000', 93);
	pc_trata_linha_retorno(3030406, '093POLO00001686332403202112323800056854', 93);
	pc_trata_linha_retorno(3030430, '093POLO00001686452403202112323800170922', 93);
	pc_trata_linha_retorno(3030431, '093POLO00001686462403202112323800303861', 93);
	pc_trata_linha_retorno(3030432, '093POLO00001686472403202112323800065968', 93);
	pc_trata_linha_retorno(3030433, '093POLO00001686482403202112323800037031', 93);
	pc_trata_linha_retorno(3030434, '093POLO00001686412403202101322900059602', 93);
	pc_trata_linha_retorno(3030435, '093POLO00001686422403202101322900053130', 93);
	pc_trata_linha_retorno(3030436, '093POLO00001686432403202101322900029202', 93);
	pc_trata_linha_retorno(3030461, '093POLO00001686492403202112323800045257', 93);
	pc_trata_linha_retorno(3030462, '093POLO00001686502403202112323800011936', 93);
	pc_trata_linha_retorno(3030463, '093POLO00001686512403202101322900032541', 93);
	pc_trata_linha_retorno(3030487, '093POLO00001686522403202112323800055088', 93);
	pc_trata_linha_retorno(3030488, '093POLO00001686532403202112323800005813', 93);
	pc_trata_linha_retorno(3030489, '093POLO00001686542403202112323800053314', 93);
	pc_trata_linha_retorno(3030490, '093POLO00001686552403202112323800064156', 93);
	pc_trata_linha_retorno(3030491, '093POLO00001686572403202101322900013458', 93);
	pc_trata_linha_retorno(3030492, '093POLO00001686582403202101322900013738', 93);
	pc_trata_linha_retorno(3030494, '093POLO00001686602403202101322900014013', 93);
	pc_trata_linha_retorno(3030495, '093POLO00001686612403202101322900013995', 93);
	pc_trata_linha_retorno(3030496, '093POLO00001686622403202101322900013976', 93);
	pc_trata_linha_retorno(3030519, '093POLO00001686632403202112323802156418', 93);
	pc_trata_linha_retorno(3030520, '093POLO00001686642403202112323800187840', 93);
	pc_trata_linha_retorno(3030521, '093POLO00001686652403202112323800941152', 93);
	pc_trata_linha_retorno(3030522, '093POLO00001686662403202112323800008483', 93);
	pc_trata_linha_retorno(3030523, '093POLO00001686672403202112323800002408', 93);
	pc_trata_linha_retorno(3030524, '093POLO00001686682403202112323800025211', 93);
	pc_trata_linha_retorno(3030525, '093POLO00001686692403202112323800116124', 93);
	pc_trata_linha_retorno(3030526, '093POLO00001686702403202101322900078778', 93);
	pc_trata_linha_retorno(3030527, '093POLO00001686712403202101322900079089', 93);
	pc_trata_linha_retorno(3030528, '093POLO00001686722403202101322900078881', 93);
	pc_trata_linha_retorno(3030529, '093POLO00001686732403202101322900078680', 93);
	pc_trata_linha_retorno(3030530, '093POLO00001686742403202101322900078480', 93);
	pc_trata_linha_retorno(3030531, '093POLO00001686752403202101322900119831', 93);
	pc_trata_linha_retorno(3030549, '093POLO00001686882403202112323800025000', 93);
	pc_trata_linha_retorno(3030550, '093POLO00001686892403202112323800005079', 93);
	pc_trata_linha_retorno(3030551, '093POLO00001686902403202112323800005079', 93);
	pc_trata_linha_retorno(3030552, '093POLO00001686912403202101322900035756', 93);
	pc_trata_linha_retorno(3030553, '093POLO00001686922403202112323800005079', 93);
	pc_trata_linha_retorno(3030554, '093POLO00001686932403202112323800005079', 93);
	pc_trata_linha_retorno(3030555, '093POLO00001686942403202112323800009594', 93);
	pc_trata_linha_retorno(3030556, '093POLO00001686952403202112323800341220', 93);
	pc_trata_linha_retorno(3030557, '093POLO00001686962403202112323801574865', 93);
	pc_trata_linha_retorno(3030558, '093POLO00001686842403202101322900063337', 93);
	pc_trata_linha_retorno(3030559, '093POLO00001686852403202101322900006687', 93);
	pc_trata_linha_retorno(3030560, '093POLO00001686862403202101322900012219', 93);
	pc_trata_linha_retorno(3030561, '093POLO00001686872403202101322900020769', 93);
	pc_trata_linha_retorno(3030581, '093POLO00001686972403202112323800005079', 93);
	pc_trata_linha_retorno(3030582, '093POLO00001686982403202112323800005079', 93);
	pc_trata_linha_retorno(3030583, '093POLO00001686992403202112323800005079', 93);
	pc_trata_linha_retorno(3030584, '093POLO00001687002403202112323800147443', 93);
	pc_trata_linha_retorno(3030585, '093POLO00001687012403202112323800016574', 93);
	pc_trata_linha_retorno(3030586, '093POLO00001687022403202112323800005079', 93);
	pc_trata_linha_retorno(3030587, '093POLO00001687032403202112323800005079', 93);
	pc_trata_linha_retorno(3030588, '093POLO00001687042403202112323800005079', 93);
	pc_trata_linha_retorno(3030589, '093POLO00001687052403202112323800123314', 93);
	pc_trata_linha_retorno(3030606, '093POLO00001687122403202112323800006001', 93);
	pc_trata_linha_retorno(3030607, '093POLO00001687132403202112323800013336', 93);
	pc_trata_linha_retorno(3030608, '093POLO00001687142403202112323800680512', 93);
	pc_trata_linha_retorno(3030609, '093POLO00001687152403202112323800026772', 93);
	pc_trata_linha_retorno(3030610, '093POLO00001687162403202112323800176422', 93);
	pc_trata_linha_retorno(3030611, '093POLO00001687092403202101322900005102', 93);
	pc_trata_linha_retorno(3030612, '093POLO00001687102403202101322900014077', 93);
	pc_trata_linha_retorno(3030613, '093POLO00001687112403202101322900205251', 93);
	pc_trata_linha_retorno(3030641, '093POLO00001687192403202112323800001192', 93);
	pc_trata_linha_retorno(3030659, '093POLO00001687202403202112323800005997', 93);
	pc_trata_linha_retorno(3030660, '093POLO00001687212403202112323800010436', 93);
	pc_trata_linha_retorno(3030661, '093POLO00001687222403202112323800027992', 93);
	pc_trata_linha_retorno(3030662, '093POLO00001687232403202112323800001178', 93);
	pc_trata_linha_retorno(3030663, '093POLO00001687242403202112323800005529', 93);
	pc_trata_linha_retorno(3030664, '093POLO00001687252403202101322900012219', 93);
	pc_trata_linha_retorno(3030674, '093POLO00001687292403202112323800004416', 93);
	pc_trata_linha_retorno(3030675, '093POLO00001687302403202112323800016574', 93);
	pc_trata_linha_retorno(3030676, '093POLO00001687262403202101322900027124', 93);
	pc_trata_linha_retorno(3030677, '093POLO00001687272403202101322900003189', 93);
	pc_trata_linha_retorno(3030678, '093POLO00001687282403202101322900012219', 93);
	pc_trata_linha_retorno(3030699, '093POLO00001687332403202112323800076050', 93);
	pc_trata_linha_retorno(3030700, '093POLO00001687342403202112323800016478', 93);
	pc_trata_linha_retorno(3030701, '093POLO00001687352403202112323800829914', 93);
	pc_trata_linha_retorno(3030702, '093POLO00001687362403202112323800173591', 93);
	pc_trata_linha_retorno(3030726, '093POLO00001687382403202112323800113470', 93);
	pc_trata_linha_retorno(3030764, '093POLO00001687422403202101322900006008', 93);
	pc_trata_linha_retorno(3030765, '093POLO00001687432403202101322900001302', 93);
	pc_trata_linha_retorno(3030785, '093POLO00001687472403202101322900008716', 93);
	pc_trata_linha_retorno(3030786, '093POLO00001687482403202101322900004568', 93);
	pc_trata_linha_retorno(3030787, '093POLO00001687492403202101322900001980', 93);
	pc_trata_linha_retorno(3030790, '093POLO00001687512403202101322900001220', 93);
	pc_trata_linha_retorno(3030798, '093POLO00001687532403202101322900066815', 93);
	pc_trata_linha_retorno(3030799, '093POLO00001687542403202101322900014477', 93);
	pc_trata_linha_retorno(3030800, '093POLO00001687552403202101322900064143', 93);
	pc_trata_linha_retorno(3030801, '093POLO00001687562403202101322900106904', 93);
	pc_trata_linha_retorno(3030802, '093POLO00001687572403202101322900038646', 93);
	pc_trata_linha_retorno(3030803, '093POLO00001687582403202101322900119320', 93);
	pc_trata_linha_retorno(3030804, '093POLO00001687592403202101322900025853', 93);
	pc_trata_linha_retorno(3030819, '093POLO00001687642403202101322900010755', 93);
	pc_trata_linha_retorno(3030856, '093POLO00001687662403202101322900016574', 93);
	pc_trata_linha_retorno(3030857, '093POLO00001687672403202101322900016574', 93);
	pc_trata_linha_retorno(3030858, '093POLO00001687682403202101322900016574', 93);
	pc_trata_linha_retorno(3030859, '093POLO00001687692403202101322900006522', 93);
	pc_trata_linha_retorno(3030906, '093POLO00001687792403202101322900012521', 93);
	pc_trata_linha_retorno(3030907, '093POLO00001687802403202101322900057787', 93);
  commit;
exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20003, v_erro);
end;