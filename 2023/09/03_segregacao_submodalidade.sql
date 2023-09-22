DECLARE

  vr_dtrefere         DATE := to_date('01/09/2023', 'DD/MM/RRRR');
  vr_dtrefere_ris     DATE := to_date('31/08/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop a
     WHERE a.flgativo = 1
       AND a.cdcooper IN (1,2,3,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY a.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  TYPE vr_venc IS RECORD(
      dias INTEGER);

  TYPE typ_vencto IS TABLE OF vr_venc INDEX BY BINARY_INTEGER;
      vr_vencto typ_vencto;


  TYPE typ_decimal IS RECORD(
      valor  NUMBER(25, 2) := 0
     ,dsc    VARCHAR(25));

  TYPE typ_arr_decimal
    IS TABLE OF typ_decimal
      INDEX BY BINARY_INTEGER;

  TYPE typ_decimal_pfpj IS RECORD(
      valorpf  NUMBER(25, 2) := 0
     ,dscpf    VARCHAR(25)
     ,valorpj  NUMBER(25, 2) := 0
     ,dscpj    VARCHAR(25)
     ,valormei NUMBER(25, 2) := 0
     ,dscmei   VARCHAR(25));

  TYPE typ_arr_decimal_pfpj
    IS TABLE OF typ_decimal_pfpj
      INDEX BY BINARY_INTEGER;

  vr_nom_arquivo VARCHAR2(100);
  vr_des_xml     CLOB;
  vr_dstexto     VARCHAR2(32700);
  vr_nom_direto  VARCHAR2(400);
  
  vr_dscritic         VARCHAR2(4000);
  vr_exc_erro         EXCEPTION;
  vr_retfile          VARCHAR2(500);
  vr_cdcritic         NUMBER;
  
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_dtmvtopr            cecred.crapdat.dtmvtopr%type;
  vr_dtultdia            cecred.crapdat.dtultdia%type;
  vr_dtultdia_prxmes     cecred.crapdat.dtultdia%type;
  
  rw_crapdat datascooperativa;
  
  procedure pc_segregacao_submodalidade(pr_cdcooper in number,
                                        pr_dtmvtolt in date,
                                        pr_dtmvtopr in date) is

    type vr_tab_valores is table of number index by pls_integer;
    vr_valores vr_tab_valores;

    cursor cr_modalidade_bacen is
      select t.cdmodalidade_bacen
           , g.dssubmod
           , t.tpemprst
           , case t.tpemprst when 0 then 'TR'
                             when 1 then 'Pre-fixado'
                             when 2 then 'Pos-fixado'
                             when 3 then 'Renegociacao'
                             else 'Tipo inexistente' end dstpemprst
           , t.nrctadeb
           , t.nrctacrd
        from cecred.gnsbmod g
           , cecred.tbcontab_modali_ope_crd t
       where g.cdmodali = substr(t.cdmodalidade_bacen,1,2)
         and g.cdsubmod = substr(t.cdmodalidade_bacen,3,2)
       order
          by to_number(t.cdmodalidade_bacen)
           , t.tpemprst;

    cursor cr_emprestimos(pr_cdcooper           in number
                         ,pr_dtrefere           in date
                         ,pr_tpemprst           in number
                         ,pr_cdmodalidade_bacen in varchar2) is
      select ass.cdagenci
           , ris.nrdconta
           , ris.nrctremp
           , sum(vri.vldivida) vldivida
        from craplcr lcr
           , gestaoderisco.tbrisco_crapvri vri
           , cecred.crapepr epr
           , gestaoderisco.tbrisco_crapris ris
           , cecred.crapass ass
       where lcr.cdmodali||lcr.cdsubmod = pr_cdmodalidade_bacen
         and lcr.cdlcremp = epr.cdlcremp
         and lcr.cdcooper = epr.cdcooper
         and vri.cdcooper = ris.cdcooper
         and vri.nrdconta = ris.nrdconta
         and vri.dtrefere = ris.dtrefere
         and vri.cdmodali = ris.cdmodali
         and vri.nrctremp = ris.nrctremp
         and vri.nrseqctr = ris.nrseqctr
         and vri.cdvencto between 110 and 290
         and epr.cdcooper = ris.cdcooper
         and epr.nrdconta = ris.nrdconta
         and epr.nrctremp = ris.nrctremp
         and epr.tpemprst = pr_tpemprst
         and ris.cdcooper = ass.cdcooper
         and ris.nrdconta = ass.nrdconta
         and ris.cdcooper = pr_cdcooper
         and ris.dtrefere = pr_dtrefere
         and ris.cdorigem = 3
         and ris.cdmodali = 299
         and ris.inddocto = 1
         and not exists(select 1
                          from cecred.tbcrd_cessao_credito ces
                         where ces.cdcooper = ris.cdcooper
                           and ces.nrdconta = ris.nrdconta
                           and ces.nrctremp = ris.nrctremp)
       group
          by ass.cdagenci
           , ris.nrdconta
           , ris.nrctremp
       order
          by ass.cdagenci;

    vr_exc_saida exception;

    vr_nom_diretorio       varchar2(200);
    vr_dsdircop            varchar2(200);

    vr_nmarqnov            varchar2(100);
    vr_nmarqdat            varchar2(100);
    vr_dtmvtolt_yymmdd     varchar2(8);

    vr_arquivo_txt         utl_file.file_type;

    vr_linhadet varchar2(500);
    vr_dscritic varchar2(4000);
    vr_cdcritic number;
    vr_typ_said varchar2(4);

    vr_totalizador number(20,2);
    vr_index       pls_integer;
    vr_descricao   varchar2(240);
  begin

    begin
      vr_nom_diretorio := cecred.gene0001.fn_diretorio(pr_tpdireto => 'C',
                                                pr_cdcooper => pr_cdcooper,
                                                pr_nmsubdir => 'contab');

      vr_dsdircop := cecred.gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

      vr_dtmvtolt_yymmdd := to_char(pr_dtmvtolt, 'yyyymmdd');
      vr_nmarqdat        := vr_dtmvtolt_yymmdd||'_SEGREGACAO_OP_CREDITO_NOVA_CENTRAL.txt';

      cecred.gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio, 
                               pr_nmarquiv => vr_nmarqdat,         
                               pr_tipabert => 'W',                 
                               pr_utlfileh => vr_arquivo_txt,      
                               pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := vr_dscritic;
        RAISE vr_exc_saida ;
      END IF;

      for rw_modalidade_bacen in cr_modalidade_bacen loop
        vr_valores.delete;
        vr_totalizador := 0;

        for rw_emprestimos IN cr_emprestimos(pr_cdcooper,pr_dtmvtolt,rw_modalidade_bacen.tpemprst,rw_modalidade_bacen.cdmodalidade_bacen) loop
          if vr_valores.exists(rw_emprestimos.cdagenci) then
            vr_valores(rw_emprestimos.cdagenci) := vr_valores(rw_emprestimos.cdagenci) + rw_emprestimos.vldivida;
          else
            vr_valores(rw_emprestimos.cdagenci) := rw_emprestimos.vldivida;
          end if;

          vr_totalizador := vr_totalizador + rw_emprestimos.vldivida;
        end loop;

        if nvl(vr_totalizador,0) > 0 then
          vr_descricao := substr('Reclassificação Operações de Crédito conforme carta circular BC nº 3.896/2018 - Submodalidade '||
                                 case when rw_modalidade_bacen.cdmodalidade_bacen in ('0215','0216','0217') then '0215, 0216 e 0217-Capital de Giro'
                                      else rw_modalidade_bacen.cdmodalidade_bacen||'-'||rw_modalidade_bacen.dssubmod end
                                 ||' - '||rw_modalidade_bacen.dstpemprst
                                ,1,240);

          vr_descricao := cecred.gene0007.fn_caract_acento(gene0007.fn_caract_especial(vr_descricao));

          vr_linhadet :=  TRIM(vr_dtmvtolt_yymmdd)||','||
                            trim(to_char(pr_dtmvtolt,'ddmmyy'))||','||
                            rw_modalidade_bacen.nrctadeb ||','||
                            rw_modalidade_bacen.nrctacrd ||','||
                            trim(to_char(vr_totalizador,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| 
                            5210||','||
                            '"'||vr_descricao||'"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          for i in 1..2 loop
            vr_index := vr_valores.first;

            while vr_index is not null loop
              vr_linhadet :=  lpad(vr_index,3,'0')||','||
                              trim(to_char(vr_valores(vr_index),'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

              vr_index := vr_valores.next(vr_index);
            end loop;
          end loop;

          vr_descricao := substr('Reversão Reclassificação Operações de Crédito conforme carta circular BC nº 3.896/2018 - Submodalidade '||
                                 case when rw_modalidade_bacen.cdmodalidade_bacen in ('0215','0216','0217') then '0215, 0216 e 0217-Capital de Giro'
                                      else rw_modalidade_bacen.cdmodalidade_bacen||'-'||rw_modalidade_bacen.dssubmod end
                                 ||' - '||rw_modalidade_bacen.dstpemprst
                                ,1,240);

          vr_descricao := cecred.gene0007.fn_caract_acento(gene0007.fn_caract_especial(vr_descricao));

          vr_linhadet :=  TRIM(vr_dtmvtolt_yymmdd)||','||
                            trim(to_char(pr_dtmvtopr,'ddmmyy'))||','||
                            rw_modalidade_bacen.nrctacrd ||','||
                            rw_modalidade_bacen.nrctadeb ||','||
                            trim(to_char(vr_totalizador,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| 
                            5210||','||
                            '"'||vr_descricao||'"';

          cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          for i in 1..2 loop
            vr_index := vr_valores.first;

            while vr_index is not null loop
              vr_linhadet :=  lpad(vr_index,3,'0')||','||
                              trim(to_char(vr_valores(vr_index),'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

              cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

              vr_index := vr_valores.next(vr_index);
            end loop;
          end loop;
        end if;
      end loop;

      cecred.gene0001.pc_fecha_arquivo(vr_arquivo_txt);

      vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_SEGREGACAO_OP_CREDITO_NOVA_CENTRAL.txt';

      cecred.gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                                  pr_typ_saida   => vr_typ_said,
                                  pr_des_saida   => vr_dscritic);

      if vr_typ_said = 'ERR' THEN
        vr_cdcritic := 1040;
        cecred.gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
      END IF;

      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        NULL;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    END;
  END pc_segregacao_submodalidade;

begin
  
  FOR rw_crapcop IN cr_crapcop LOOP
    GESTAODERISCO.obterCalendario(pr_cdcooper   => rw_crapcop.cdcooper
                                 ,pr_dtrefere   => vr_dtrefere
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_dtmvtolt := rw_crapdat.dtmvtoan;

    vr_dtmvtopr := rw_crapdat.dtmvtolt;

    vr_dtultdia := last_day(vr_dtmvtolt);
    vr_dtultdia_prxmes := last_day(vr_dtmvtopr);

    pc_segregacao_submodalidade(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_dtmvtolt => vr_dtultdia
                               ,pr_dtmvtopr => vr_dtmvtopr);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    COMMIT;

  END LOOP;
  
  
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
