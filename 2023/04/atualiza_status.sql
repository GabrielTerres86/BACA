DECLARE 

  vr_exc_erro     EXCEPTION;
  
  vr_dscritic     VARCHAR2(4000);
  vr_cdcritic     NUMBER;
  vr_stmtaux      VARCHAR2(4000);
  vr_des_erro     VARCHAR2(4000);
  vr_tab_erro     CECRED.GENE0001.typ_tab_erro;

  vr_dtrefere     DATE;
  vr_nrcrcard     CECRED.craplau.nrcrcard%TYPE;
  vr_cdagenci     NUMBER;
  vr_nrdocmto     VARCHAR2(25); 
  
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0267869';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0267869.sql';
  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_rowid          ROWID;
  
 CURSOR cr_craplau IS
    SELECT u.cdcooper 
           ,u.cdagenci         
            ,u.nrdconta
            ,u.dtmvtopg
            ,u.vllanaut
            ,u.nrdocmto
            ,u.nrcrcard
            ,u.cdhistor
            ,u.cdseqtel
            ,u.IDLANCTO
            ,u.cdcritic
            ,u.rowid
            ,seg.cdsegmento   tpconsor
            ,s.nrctacns
        FROM cecred.craplau U
            ,cecred.craphis
            ,cecred.tbconsor_segmento seg
            ,cecred.crapass s
       WHERE u.cdcooper = craphis.cdcooper
         AND u.cdhistor = craphis.cdhistor
         AND seg.cdhistordebito = u.cdhistor
         AND u.cdcooper = 1
         AND u.dtmvtopg = '10/04/2023'
         AND u.insitlau = 1
         AND u.cdhistor IN (1230, 1231, 1232, 1233, 1234, 2027)
         and s.cdcooper = u.cdcooper
         and s.nrdconta = u.nrdconta;
               
   PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
    BEGIN
      IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' ||
                                                             pr_nmdireto ||
                                                             ' 1> /dev/null',
                                    pr_typ_saida   => vr_typ_saida,
                                    pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
  END;                 
               
  PROCEDURE pc_gera_crapndb (pr_cdcooper  IN crapcop.cdcooper%TYPE        
                            ,pr_dtmvtolt  IN DATE                         
                            ,pr_nrdconta  IN crapass.nrdconta%TYPE        
                            ,pr_cdempres  IN craplau.cdempres%TYPE        
                            ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE        
                            ,pr_nrctacns  IN crapass.nrctacns%TYPE        
                            ,pr_vllanaut  IN craplau.vllanaut%TYPE        
                            ,pr_cdagenci  IN crapass.cdagenci%TYPE        
                            ,pr_cdseqtel  IN craplau.cdseqtel%TYPE        
                            ,pr_cdhistor  IN craplau.cdhistor%TYPE        
                            ,pr_cdcritic  IN OUT crapcri.cdcritic%TYPE    
                            ,pr_dscritic     OUT VARCHAR2                 
                            ,pr_rowid        OUT ROWID) IS             
  BEGIN
    DECLARE

      vr_nrctasic cecred.crapcop.nrctasic%TYPE;
      vr_dstexarq VARCHAR2(200) := '';
      
      vr_resultado VARCHAR2(25);

      vr_cdcritic cecred.crapcri.cdcritic%TYPE := 0;
      vr_critica  cecred.crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(4000);

      vr_exc_erro EXCEPTION;
      vr_exc_saida EXCEPTION;

    CURSOR cr_crapcop2 IS
      SELECT cop.cdagesic
        FROM cecred.crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop2 cr_crapcop2%ROWTYPE;

    CURSOR cr_crapscn (pr_cdempres cecred.crapscn.cdempres%TYPE) IS
      SELECT scn.qtdigito
            ,scn.cdempres
            ,scn.tppreenc
        FROM cecred.crapscn scn
       WHERE scn.cdempres = pr_cdempres;
     rw_crapscn cr_crapscn%ROWTYPE;

   BEGIN

      OPEN cr_crapcop2;
      FETCH cr_crapcop2 INTO rw_crapcop2;

      IF cr_crapcop2%NOTFOUND THEN
        CLOSE cr_crapcop2;
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        vr_nrctasic := gene0002.fn_mask(rw_crapcop2.cdagesic,'9999');
       CLOSE cr_crapcop2;
      END IF;

      OPEN cr_crapscn (pr_cdempres => pr_cdempres);
      FETCH cr_crapscn INTO rw_crapscn;
      IF cr_crapscn%NOTFOUND THEN
        CLOSE cr_crapscn;
      END IF;

      IF rw_crapscn.tppreenc = 1 THEN
        IF rw_crapscn.qtdigito <> 0 THEN
          vr_resultado := LPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0');
        ELSE
          vr_resultado := LPAD(pr_nrdocmto,25,'0');
        END IF;
      ELSIF rw_crapscn.tppreenc = 2 THEN
        IF rw_crapscn.qtdigito <> 0 THEN
          vr_resultado := RPAD(pr_nrdocmto,rw_crapscn.qtdigito,'0');
        ELSE
          vr_resultado := RPAD(pr_nrdocmto,25,'0');
        END IF;
      ELSE
        IF rw_crapscn.qtdigito <> 0 THEN
          vr_resultado :=  RPAD(pr_nrdocmto,rw_crapscn.qtdigito,' ');
        ELSE
          vr_resultado := RPAD(pr_nrdocmto,25,' ');
        END IF;
      END IF;

      IF LENGTH(vr_resultado) < 25 THEN

        vr_resultado := RPAD(vr_resultado,25,' ');
      END IF;

      IF NVL(pr_cdcritic,0) IN (64, 9, 454) THEN
         vr_critica := 15;  
      ELSE
         vr_critica := 1;   
      END IF;
            
        vr_dstexarq := 'F' || vr_resultado ||
                       gene0002.fn_mask(vr_nrctasic,'9999') ||
                       gene0002.fn_mask(pr_nrctacns,'999999') ||
                       gene0002.fn_mask('','zzzzzzzz') ||
                       TO_CHAR(pr_dtmvtolt,'yyyy') ||
                       TO_CHAR(pr_dtmvtolt,'mm') ||
                       TO_CHAR(pr_dtmvtolt,'dd') ||
                       LPAD((pr_vllanaut*100),15,'0') ||
                       LPAD(vr_critica,2,'0') ||
                       RPAD(pr_cdseqtel,70, ' ') ||
                       RPAD(' ',10) || '0';
      
        BEGIN
          INSERT INTO CECRED.crapndb(dtmvtolt,
                              nrdconta,
                              cdhistor,
                              flgproce,
                              cdcooper,
                              dstexarq)
                       VALUES(pr_dtmvtolt,
                              pr_nrdconta,
                              Nvl(pr_cdhistor, 1019),
                              0,          
                              pr_cdcooper,
                              vr_dstexarq) 
                              returning
                              rowid
                              into pr_rowid;
            
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao inserir na tabela CRAPNDB: ' || sqlerrm;
            RAISE vr_exc_erro;
        END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= NVL(vr_dscritic, gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic));
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado em pc_gera_crapndb --> '||SQLERRM;
    END;

  END pc_gera_crapndb;  
  
begin

    pc_valida_direto(pr_nmdireto => vr_nmdir,
                     pr_dscritic => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
  
    CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarq
                                   ,pr_tipabert => 'W'
                                   ,pr_utlfileh => vr_ind_arq
                                   ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
       vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
       RAISE vr_exc_erro;
    END IF;

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');

    vr_dtrefere:= TO_DATE(SYSDATE,'DD/MM/YYYY');
  
    FOR rw_craplau in cr_craplau LOOP

      vr_linha:= '';
      vr_cdagenci := rw_craplau.cdagenci;
    
      IF rw_craplau.nrcrcard <> 0 THEN
        vr_nrcrcard := rw_craplau.nrcrcard;
      ELSE
        vr_nrcrcard := rw_craplau.nrdocmto;
      END IF;    
      
      pc_gera_crapndb (pr_cdcooper => rw_craplau.cdcooper,
                       pr_dtmvtolt => vr_dtrefere,
                       pr_nrdconta => rw_craplau.nrdconta,
                       pr_cdempres => 'J5',
                       pr_nrdocmto => vr_nrcrcard,
                       pr_nrctacns => rw_craplau.nrctacns,
                       pr_vllanaut => rw_craplau.vllanaut,
                       pr_cdagenci => vr_cdagenci,
                       pr_cdseqtel => rw_craplau.cdseqtel,
                       pr_cdhistor => rw_craplau.cdhistor,
                       pr_cdcritic => rw_craplau.cdcritic,
                       pr_dscritic => vr_dscritic,
                       pr_rowid   => vr_rowid);
      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
       vr_linha :=    ' DELETE CECRED.CRAPNDB'
                      || ' WHERE rowid = ''' || vr_rowid || ''';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
      vr_linha:= '';
      
      vr_linha :=    ' UPDATE CECRED.craplau p'
                      || ' SET p.insitlau = 1,'
                      || ' p.dtdebito = '''''   
                      || ' WHERE rowid = ''' || rw_craplau.rowid || ''';';

      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
            
      BEGIN
        UPDATE CECRED.craplau
           SET insitlau = 3
              ,dtdebito = vr_dtrefere
         WHERE ROWID = rw_craplau.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar craplau: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;

    COMMIT;
    
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
    
EXCEPTION
    WHEN vr_exc_erro THEN
      DBMS_OUTPUT.put_line('vr_cdcritic: '||nvl(vr_cdcritic,0)||CHR(13)||
                           'vr_dscritic: '||vr_dscritic||CHR(13)||
                           'SQLERRM: '|| SQLERRM);
      ROLLBACK;
    WHEN OTHERS THEN            
      vr_dscritic := 'Erro não tratado --> '||SQLERRM;
      DBMS_OUTPUT.put_line('vr_dscritic: '||vr_dscritic);
      ROLLBACK;      
END;
/
