begin
DECLARE
  vr_dados_rollback CLOB; 
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000);
  vr_rootmicros    VARCHAR2(5000);
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_exc_erro  EXCEPTION;
  vr_tem_repique     Integer;
  vr_numctacns   crapcns.nrcotcns%TYPE;
  vr_proxutil   DATE;
  vr_cdcritic crapcri.cdcritic%TYPE; 
  ds_critica_v    cecred.crapcri.dscritic%type;
  ds_rowidlct  rowid;
  CURSOR cr_recusaContr IS
  select c.rowid as id_linha   
       ,c.CDCOOPER
       , c.NRDCONTA
       , c.TPSEGURO
       , c.NRCTRSEG
       , d.dtmvtolt
       , c.dtfimvig
       , p.NRPROPOSTA
       , p.TPCUSTEI
       , c.dtcancel
       , c.cdsitseg
       , c.cdopeexc
       , c.cdageexc
       , c.dtinsexc
       , c.cdopecnl
       , p.nrctremp
    from cecred.tbseg_prestamista p
    inner join cecred.crapseg c on (c.NRDCONTA= p.NRDCONTA and c.CDCOOPER = p.CDCOOPER and c.nrctrseg = p.nrctrseg)
    inner join cecred.crapdat d on p.cdcooper   = d.cdcooper
    WHERE c.TPSEGURO=4
    and p.TPCUSTEI=0
    and c.CDSITSEG != 5
    and p.nrproposta in(770628896259,
                        770629641165,
                        770629050639,
                        770629587209,
                        770628903379,
                        770629614443,
                        770629162364,
                        770629637486,
                        770629630627,
                        202210355138,
                        202208458026,
                        202208459953,
                        202208459866,
                        202207301104,
                        202208608119,
                        202208459267,
                        202208872783,
                        770629412298,
                        770629077278,
                        770629455396
                        );

  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2,
                             pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic  crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);
    BEGIN
      IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                      pr_nmdireto ||
                                                      ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;
  END pc_valida_direto;
  
PROCEDURE pc_efetuar_estorno( pr_cdcooper in  cecred.craplau.cdcooper%TYPE,
        pr_nrdconta in  cecred.craplau.nrdconta%TYPE,
        pr_nrproposta in  cecred.tbseg_prestamista.nrproposta%TYPE,
        pr_dtmvtolt in  cecred.crapdat.dtmvtolt%TYPE,
        pr_rowidlct out rowid) IS

vr_tab_retorno  cecred.LANC0001.typ_reg_retorno;
vr_incrineg INTEGER DEFAULT 0 ;
vr_cdcritic PLS_INTEGER;
vr_dscritic VARCHAR2(4000);
vr_exc_erro EXCEPTION;

cursor  cr_craplcm( pr_cdcooper cecred.craplau.cdcooper%TYPE,
      pr_nrdconta cecred.craplau.nrdconta%TYPE,
      pr_nrproposta cecred.tbseg_prestamista.nrproposta%TYPE) IS

SELECT  m.cdagenci,
  m.cdbccxlt,
  m.nrdolote,
  m.nrdconta,
  m.nrdocmto,
  m.cdhistor,
  m.nrseqdig,
  m.vllanmto,
  m.nrdctabb,
  m.cdcooper,
  m.nrdctitg
FROM  cecred.craplau u,
  cecred.craplcm m
WHERE u.cdcooper  = pr_cdcooper
AND u.nrdconta  = pr_nrdconta
AND u.cdhistor  = 3651
AND u.cdseqtel  = pr_nrproposta
AND u.insitlau  = 2
AND m.cdcooper  = u.cdcooper
AND m.nrdconta  = u.nrdconta
AND m.cdhistor  = u.cdhistor
AND m.dtmvtolt  = u.dtmvtopg
AND m.nrdocmto  = u.nrdocmto
AND m.vllanmto  = u.vllanaut
AND NOT EXISTS
  (SELECT 1
  FROM  cecred.craplcm b
  WHERE b.cdcooper  = m.cdcooper
  AND b.nrdconta  = m.nrdconta
  AND b.nrdocmto || '001' = m.nrdocmto
  AND b.cdhistor  = 3852
  AND b.dtmvtolt  >= m.dtmvtolt
  AND b.vllanmto  = m.vllanmto);

rw_craplcm  cr_craplcm%ROWTYPE;

begin

  OPEN  cr_craplcm( pr_cdcooper => pr_cdcooper,
        pr_nrdconta => pr_nrdconta,
        pr_nrproposta => pr_nrproposta);
  FETCH cr_craplcm INTO rw_craplcm;

    IF  (cr_craplcm%FOUND) THEN

      lanc0001.pc_gerar_lancamento_conta( pr_dtmvtolt => pr_dtmvtolt,
                pr_cdagenci => rw_craplcm.cdagenci,
                pr_cdbccxlt => rw_craplcm.cdbccxlt,
                pr_nrdolote => rw_craplcm.nrdolote,
                pr_nrdconta => rw_craplcm.nrdconta,
                pr_nrdocmto => rw_craplcm.nrdocmto || '001',
                pr_cdhistor => 3852,
                pr_nrseqdig => rw_craplcm.nrseqdig + 1,
                pr_vllanmto => rw_craplcm.vllanmto,
                pr_nrdctabb => rw_craplcm.nrdctabb,
                pr_dtrefere => pr_dtmvtolt,
                pr_hrtransa => to_char(SYSDATE,'SSSSS'),
                pr_cdcooper => rw_craplcm.cdcooper,
                pr_nrdctitg => rw_craplcm.nrdctitg,
                pr_tab_retorno  => vr_tab_retorno,
                pr_incrineg => vr_incrineg,
                pr_cdcritic => vr_cdcritic,
                pr_dscritic => vr_dscritic);

      pr_rowidlct := vr_tab_retorno.rowidlct;

      IF  (NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NOT NULL) THEN

        RAISE vr_exc_erro;

            END IF;

    END IF;

  CLOSE cr_craplcm;

EXCEPTION
WHEN  vr_exc_erro THEN

  ds_critica_v  := vr_dscritic || SQLERRM;

WHEN  OTHERS THEN

  vr_dscritic := 'Erro ao alterar craplau SEGU0001.pc_efetiva_pgto_prest_contrib';
  ds_critica_v  := vr_dscritic||SQLERRM;

END pc_efetuar_estorno;
  
BEGIN
  vr_rootmicros     := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto       := vr_rootmicros|| 'cpd/bacas';
  pc_valida_direto(pr_nmdireto => vr_nmdireto || '/INC0235580R',
                   pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  vr_nmdireto := vr_nmdireto || '/INC0235580R';
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          '-- Programa para rollback das informacoes' ||
                          chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'BEGIN' || chr(13),
                          FALSE);
  vr_nmarqbkp := 'ROLLBACK_INC0235580R' || to_char(sysdate, 'hh24miss') ||
                 '.sql';
  for rw_recusa in cr_recusaContr loop
    UPDATE crapseg
             SET crapseg.dtcancel = TO_DATE(rw_recusa.dtmvtolt, 'dd/mm/yyyy'), 
                 crapseg.cdsitseg = 5,
                 crapseg.cdopeexc = 1,
                 crapseg.cdageexc = 1,
                 crapseg.dtinsexc = TO_DATE(rw_recusa.dtmvtolt, 'dd/mm/yyyy'),
                 crapseg.cdopecnl = 1
           WHERE crapseg.nrctrseg = rw_recusa.nrctrseg
             AND crapseg.nrdconta = rw_recusa.nrdconta
             AND crapseg.cdcooper = rw_recusa.cdcooper
             AND crapseg.tpseguro = 4; 
          cecred.gene0002.pc_escreve_xml( vr_dados_rollback,
          vr_texto_rollback,
          'update cecred.crapseg a ' || chr(13) ||
          'set  a.dtfimvig  = ' || 'to_date(' || chr(39) || trim(to_char(rw_recusa.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
          ' a.dtcancel  = ' || 'to_date(' || chr(39) || trim(to_char(rw_recusa.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
          ' a.cdsitseg  = ' || replace(nvl(trim(to_char(rw_recusa.cdsitseg)),'null'),',','.') || ', ' || chr(13) ||
          ' a.cdopeexc  = ' || chr(39) || rw_recusa.cdopeexc || chr(39) || ', ' || chr(13) ||
          ' a.cdageexc  = ' || replace(nvl(trim(to_char(rw_recusa.cdageexc)),'null'),',','.') || ', ' || chr(13) ||
          ' a.dtinsexc  = ' || 'to_date(' || chr(39) || trim(to_char(rw_recusa.dtinsexc,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
          ' a.cdopecnl  = ' || chr(39) || rw_recusa.cdopecnl || chr(39) || chr(13) ||
          'where  a.rowid   = ' || chr(39) || rw_recusa.id_linha || chr(39) || ';' || chr(13) || chr(13), false);    

           vr_proxutil := GENE0005.fn_valida_dia_util(pr_cdcooper => rw_recusa.cdcooper
                                                     ,pr_dtmvtolt =>rw_recusa.dtmvtolt
                                                     ,pr_tipo => 'P');
      pc_efetuar_estorno( pr_cdcooper => rw_recusa.cdcooper,
          pr_nrdconta => rw_recusa.nrdconta,
          pr_nrproposta => rw_recusa.nrproposta,
          pr_dtmvtolt => vr_proxutil,
          pr_rowidlct => ds_rowidlct);       
      cecred.gene0002.pc_escreve_xml( vr_dados_rollback,
            vr_texto_rollback,
            'delete from cecred.craplcm a ' || chr(13) ||
            'where  a.rowid = ' || chr(39) || ds_rowidlct || chr(39) || ';' || chr(13) || chr(13), false);

      commit;
  end loop;
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'COMMIT;' || chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          'END;' || chr(13),
                          FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback,
                          vr_texto_rollback,
                          chr(13),
                          TRUE);
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 
                                     ,
                                      pr_cdprogra  => 'ATENDA'
                                     ,
                                      pr_dtmvtolt  => trunc(SYSDATE) 
                                     ,
                                      pr_dsxml     => vr_dados_rollback 
                                     ,
                                      pr_dsarqsaid => vr_nmdireto || '/' ||
                                                      vr_nmarqbkp 
                                     ,
                                      pr_flg_impri => 'N' 
                                     ,
                                      pr_flg_gerar => 'S' 
                                     ,
                                      pr_flgremarq => 'N' 
                                     ,
                                      pr_nrcopias  => 1 
                                     ,
                                      pr_des_erro  => vr_dscritic);
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);
  COMMIT;
END;
COMMIT;
end;