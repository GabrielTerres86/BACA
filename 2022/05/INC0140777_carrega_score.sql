DECLARE 

  vr_nmdblink VARCHAR2(10) := 'SASRW'; 
  vr_dtbase DATE := to_date('30/04/2022','DD/MM/RRRR');
  vr_dscritic VARCHAR2(4000);

  cursor cr_crapope(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdoperad crapope.cdoperad%TYPE) is
    SELECT ope.nmoperad
          ,age.nmcidade
          ,age.cdufdcop
      FROM cecred.crapope ope
          ,cecred.crapage age
     WHERE ope.cdcooper = age.cdcooper
       AND ope.cdagenci = age.cdagenci
       AND ope.cdcooper = pr_cdcooper
       and ope.cdoperad = pr_cdoperad;
  rw_crapope cr_crapope%ROWTYPE;
  
  PROCEDURE pc_efetua_carga_score_behavi(pr_cdmodelo IN tbcrd_carga_score.cdmodelo%TYPE      
                                        ,pr_dtbase   IN tbcrd_carga_score.dtbase%TYPE        
                                        ,pr_cddopcao IN tbcrd_carga_score.cdopcao%TYPE       
                                        ,pr_cdoperad IN tbcrd_carga_score.cdoperad%TYPE      
                                        ,pr_dsrejeicao IN tbcrd_carga_score.dsrejeicao%TYPE  
                                        ,pr_dscritic OUT VARCHAR2)                           
                                         IS                      

    vr_dscritic VARCHAR2(4000);
    vr_excsaida EXCEPTION;
    
    vr_nom_owner     VARCHAR2(100) := gene0005.fn_get_owner_sas;
    vr_nom_dblink_ro VARCHAR2(100);
    vr_nom_dblink_rw VARCHAR2(100);
    vr_skprocesso    VARCHAR2(100) := risc0005.fn_get_skprocesso_behavi;

    
    vr_num_cursor    number;
    vr_num_retor     number;
    vr_sql_cursor    varchar2(32000);

    
    vr_num_cursor_int    number;
    vr_num_retor_int     number;
    vr_sql_cursor_int    varchar2(32000);
    
    vr_skcarga        PLS_INTEGER := 0;
    vr_dsmodelo       tbcrd_carga_score.dsmodelo%TYPE;
    vr_inpessoa       crapass.inpessoa%TYPE;
    vr_rowidcarga     ROWID;

    vr_qtregis_tot    PLS_INTEGER := 0;
    vr_qtregistros    PLS_INTEGER := 0;
    vr_qtregis_fisica tbcrd_carga_score.qtregis_fisica%TYPE := 0;
    vr_qtregis_juridi tbcrd_carga_score.qtregis_juridi%TYPE := 0;
    vr_dtinicio  tbcrd_carga_score.dtinicio%TYPE; 
    vr_dtfinali  tbcrd_carga_score.dtinicio%TYPE; 

    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM cecred.crapcop cop
       WHERE cop.flgativo = 1;
        
    
    CURSOR cr_Ult_carga IS
      SELECT car.dtbase
        FROM cecred.tbcrd_carga_score car
       WHERE car.cdmodelo = pr_cdmodelo
         AND car.cdopcao = 'A'
       ORDER BY car.dtbase DESC;
    vr_dtbase tbcrd_carga_score.dtbase%TYPE;
    
    CURSOR cr_score_vigente(pr_cdmodelo NUMBER,
                            pr_cdcooper NUMBER) IS
      SELECT ROWID
        FROM cecred.tbcrd_score
       WHERE cdmodelo = pr_cdmodelo
         AND cdcooper = pr_cdcooper
         AND flvigente = 1;

    CURSOR cr_score_dtbase (pr_cdmodelo NUMBER,
                            pr_cdcooper NUMBER,
                            pr_dtbase   DATE) IS
      SELECT ROWID
        FROM cecred.tbcrd_score
       WHERE cdmodelo = pr_cdmodelo
         AND cdcooper = pr_cdcooper
         AND dtbase   = pr_dtbase
         AND flvigente = 0;
         
    TYPE typ_tab_score IS TABLE OF cr_score_vigente%ROWTYPE INDEX BY PLS_INTEGER;
    vr_tab_score_bulk typ_tab_score;       

    
    vr_deslog VARCHAR2(4000);
  BEGIN
    IF pr_cdmodelo IS NULL THEN
      vr_dscritic := 'Modelo de Carga deve ser informado!';
      RAISE vr_excsaida;
    END IF;
    
    IF pr_dtbase IS NULL THEN
      vr_dscritic := 'Data Base de Carga deve ser informado!';
      RAISE vr_excsaida;
    END IF;    
    
    IF pr_cddopcao IS NULL OR pr_cddopcao NOT IN('A','R') THEN
      vr_dscritic := 'Opcao invalida! Favor enviar [A]provar ou [R]eprovar!';
      RAISE vr_excsaida;
    END IF;
    
    IF pr_cdoperad IS NULL THEN
      vr_dscritic := 'Operador conectado deve ser informado!';
      RAISE vr_excsaida;
    END IF;
    
    IF pr_cddopcao = 'R' AND pr_dsrejeicao IS NULL THEN
      vr_dscritic := 'Motivo da Rejeicao e obrigatorio para esta opcao!';
      RAISE vr_excsaida;
    END IF;

    
    vr_nom_dblink_ro := gene0005.fn_get_dblink_sas('R');
    IF vr_nom_dblink_ro IS NULL THEN
      vr_dscritic := 'Nao foi possivel retornar o DBLink(RO) do SAS, verifique!';
      RAISE vr_excsaida;
    END IF;
    vr_nom_dblink_rw := gene0005.fn_get_dblink_sas('W');
    IF vr_nom_dblink_rw IS NULL THEN
      vr_dscritic := 'Nao foi possivel retornar o DBLink(RW) do SAS, verifique!';
      RAISE vr_excsaida;
    END IF;

    
    vr_sql_cursor := 'SELECT car.skcarga '
                  || '  FROM '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_ro||' car '
                  || ' WHERE car.skdtbase   = '||to_char(pr_dtbase, 'yyyymmdd')
                  || '   AND car.skprocesso = '||vr_skprocesso
                  || '   AND car.qtregistroprocessado > 0 '
                  || '   AND car.dthorafiminclusao is not null '
                  || '   AND car.dthorainicioprocesso is null ';

    
    vr_num_cursor := dbms_sql.open_cursor;

    
    dbms_sql.parse(vr_num_cursor, vr_sql_cursor, 1);
    
    dbms_sql.define_column(vr_num_cursor, 1, vr_skcarga);
    
    vr_num_retor := dbms_sql.execute(vr_num_cursor);
    LOOP
    
      vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
      IF vr_num_retor = 0 THEN
    
        IF dbms_sql.is_open(vr_num_cursor) THEN
    
          dbms_sql.close_cursor(vr_num_cursor);
        END IF;
        EXIT;
      ELSE
    
        vr_qtregis_fisica := 0;
        vr_qtregis_juridi := 0;
    
        dbms_sql.column_value(vr_num_cursor, 1, vr_skcarga);
    
        vr_sql_cursor_int := 'SELECT scm.dsmodelo '
                      || '      ,sco.tppessoa '
                      || '      ,COUNT(1) qtpessoa '
                      || '  FROM '||vr_nom_owner||'sas_score_modelo@'||vr_nom_dblink_ro||' scm '
                      || '      ,'||vr_nom_owner||'sas_score@'||vr_nom_dblink_ro||' sco '
                      || ' WHERE scm.cdmodelo = sco.cdmodelo '
                      || '   AND sco.cdmodelo = '||pr_cdmodelo
                      || '   AND sco.dtbase   = to_date('''||to_char(pr_dtbase, 'ddmmyyyy')||''', ''ddmmyyyy'')'
                      || '   AND sco.skcarga  = '||vr_skcarga
                      || '  GROUP BY scm.dsmodelo '
                      || '          ,sco.tppessoa ';

    
        vr_num_cursor_int := dbms_sql.open_cursor;

    
        dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
    
        dbms_sql.define_column(vr_num_cursor_int, 1, vr_dsmodelo, 255);
        dbms_sql.define_column(vr_num_cursor_int, 2, vr_inpessoa);
        dbms_sql.define_column(vr_num_cursor_int, 3, vr_qtregistros);

    
        vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
        LOOP 
    
          vr_num_retor_int := dbms_sql.fetch_rows(vr_num_cursor_int);
          IF vr_num_retor_int = 0 THEN
    
            IF dbms_sql.is_open(vr_num_cursor_int) THEN
    
              dbms_sql.close_cursor(vr_num_cursor_int);
            END IF;
            EXIT;
          ELSE
    
            dbms_sql.column_value(vr_num_cursor_int, 1, vr_dsmodelo);
            dbms_sql.column_value(vr_num_cursor_int, 2, vr_inpessoa);
            dbms_sql.column_value(vr_num_cursor_int, 3, vr_qtregistros);
    
            IF vr_inpessoa = 1 THEN
              vr_qtregis_fisica := vr_qtregis_fisica + vr_qtregistros;
            ELSE 
              vr_qtregis_juridi := vr_qtregis_juridi + vr_qtregistros;
            END IF;
          END IF;
        END LOOP;

    
        IF vr_qtregis_fisica + vr_qtregis_juridi > 0 THEN

    
          vr_dtinicio := SYSDATE;

    
          BEGIN
            vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                              || '   set car.dthorainicioprocesso = to_date('''||to_char(vr_dtinicio,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                              || ' where car.skcarga = '||vr_skcarga;

            vr_num_cursor_int := dbms_sql.open_cursor;

            dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);

            vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);

            dbms_sql.close_cursor(vr_num_cursor_int);
          EXCEPTION
            WHEN vr_excsaida THEN
              RAISE vr_excsaida;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro na atualizacao de inicio da carga do Score: '||SQLERRM;
              RAISE vr_excsaida;
          END;

          COMMIT;

          
          vr_qtregis_tot := vr_qtregis_tot + vr_qtregis_fisica + vr_qtregis_juridi;

          
          IF vr_rowidcarga IS NULL THEN
            BEGIN
              INSERT INTO cecred.tbcrd_carga_score(cdmodelo
                                           ,dtbase
                                           ,dsmodelo 
                                           ,dtinicio 
                                           ,dttermino
                                           ,cdopcao 
                                           ,cdoperad
                                           ,qtregis_fisica 
                                           ,qtregis_juridi
                                           ,dsrejeicao)
                                     VALUES(pr_cdmodelo
                                           ,pr_dtbase
                                           ,vr_dsmodelo
                                           ,vr_dtinicio
                                           ,SYSDATE
                                           ,pr_cddopcao
                                           ,pr_cdoperad
                                           ,0
                                           ,0
                                           ,pr_dsrejeicao)
                                     RETURNING ROWID INTO vr_rowidcarga;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar historico de carga: '||SQLERRM;
                RAISE vr_excsaida;
            END;
          END IF;

          IF pr_cddopcao = 'A' THEN
          
            BEGIN          
              vr_sql_cursor_int := 'INSERT INTO cecred.tbcrd_score(cdmodelo '
                            || '                       ,dtbase '
                            || '                       ,tppessoa '
                            || '                       ,cdcooper '
                            || '                       ,nrcpfcnpjbase '
                            || '                       ,nrscore_alinhado '
                            || '                       ,dsclasse_score '
                            || '                       ,dsexclusao_principal '
                            || '                       ,flvigente) '
                            || '                  SELECT sco.cdmodelo '
                            || '                        ,sco.dtbase '
                            || '                        ,sco.tppessoa '
                            || '                        ,sco.cdcooper '
                            || '                        ,sco.nrcpfcnpjbase '
                            || '                        ,sco.nrscorealinhado '
                            || '                        ,sco.dsclassescore '
                            || '                        ,sco.dsexclusaoprincipal '
                            || '                        ,1 '
                            || '                    FROM '||vr_nom_owner||'sas_score@'||vr_nom_dblink_ro||' sco '
                            || '                   WHERE sco.cdmodelo = '||pr_cdmodelo
                            || '                     AND sco.dtbase   = to_date('''||to_char(pr_dtbase, 'ddmmyyyy')||''', ''ddmmyyyy'')'
                            || '                     AND sco.skcarga = '||vr_skcarga;
              
              vr_num_cursor_int := dbms_sql.open_cursor;              
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
              
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);              
              dbms_sql.close_cursor(vr_num_cursor_int);
              
              IF vr_num_retor_int = 0 THEN
                vr_dscritic := 'Erro na carga do Score. Nenhum registro encontrado para o modelo e data base!';
                RAISE vr_excsaida;
              END IF;
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na carga do Score: '||SQLERRM;
                RAISE vr_excsaida;  
            END;

            
            BEGIN
              vr_sql_cursor_int := 'INSERT INTO cecred.tbcrd_score_exclusao '
                            || '                       (cdmodelo '
                            || '                       ,dtbase '
                            || '                       ,tppessoa '
                            || '                       ,cdcooper '
                            || '                       ,nrcpfcnpjbase '
                            || '                       ,cdexclusao '
                            || '                       ,dsexclusao) '
                            || '                  SELECT sce.cdmodelo '
                            || '                        ,sce.dtbase '
                            || '                        ,sce.tppessoa '
                            || '                        ,sce.cdcooper '
                            || '                        ,sce.nrcpfcnpjbase '
                            || '                        ,sce.cdexclusao '
                            || '                        ,sce.dsexclusao '
                            || '                    FROM '||vr_nom_owner||'sas_score_exclusao@'||vr_nom_dblink_ro||' sce '
                            || '                   WHERE sce.cdmodelo = '||pr_cdmodelo
                            || '                     AND sce.dtbase   = to_date('''||to_char(pr_dtbase, 'ddmmyyyy')||''', ''ddmmyyyy'')'
                            || '                     AND sce.skcarga = '||vr_skcarga;
              
              vr_num_cursor_int := dbms_sql.open_cursor;
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);

              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
              dbms_sql.close_cursor(vr_num_cursor_int);
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na carga de exclusoes do Score: '||SQLERRM;
                RAISE vr_excsaida;
            END;

            OPEN cr_Ult_carga;
            FETCH cr_Ult_carga
             INTO vr_dtbase;
            CLOSE cr_Ult_carga;
            
            FOR rw_crapcop IN cr_crapcop LOOP
            
              OPEN cr_score_vigente(pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_cdmodelo => pr_cdmodelo);
              LOOP                    
                FETCH cr_score_vigente BULK COLLECT INTO vr_tab_score_bulk LIMIT 10000;
                IF vr_tab_score_bulk.count > 0 THEN  
                  BEGIN
                    FORALL vr_idx IN 1..vr_tab_score_bulk.count SAVE EXCEPTIONS
                      UPDATE cecred.tbcrd_score
                         SET flvigente = 0
                       WHERE ROWID = vr_tab_score_bulk(vr_idx).rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao remover vigencias de scores antigos -> '
                                      || '. Detalhes:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                        vr_tab_score_bulk.DELETE; 
                        CLOSE cr_score_vigente;
                        RAISE vr_excsaida; 
                  END;
                ELSE 
                  EXIT;
                END IF;    
               
              END LOOP;
              CLOSE cr_score_vigente;
              
              OPEN cr_score_dtbase( pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_cdmodelo => pr_cdmodelo,
                                    pr_dtbase   => pr_dtbase
                                    );
              LOOP                    
                FETCH cr_score_dtbase BULK COLLECT INTO vr_tab_score_bulk LIMIT 10000;
                IF vr_tab_score_bulk.count > 0 THEN  
                  BEGIN
                    FORALL vr_idx IN 1..vr_tab_score_bulk.count SAVE EXCEPTIONS
                      UPDATE cecred.tbcrd_score
                         SET flvigente = 1
                       WHERE ROWID = vr_tab_score_bulk(vr_idx).rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao  marcar vigencias de scores -> '
                                      || '. Detalhes:'|| SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                        vr_tab_score_bulk.DELETE; 
                        CLOSE cr_score_dtbase;
                        RAISE vr_excsaida; 
                  END;
                ELSE 
                  EXIT;
                END IF;    
               
              END LOOP; 
              CLOSE cr_score_dtbase;
            
              COMMIT;
            END LOOP;

            
            vr_dtfinali := SYSDATE;
            
            
            BEGIN
              vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                                || '   set car.dthorafimprocesso = to_date('''||to_char(vr_dtfinali,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                || '      ,car.qtregistrook = '||to_char(vr_qtregis_fisica + vr_qtregis_juridi)
                                || ' where car.skcarga = '||vr_skcarga;
            
              vr_num_cursor_int := dbms_sql.open_cursor;
            
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
            
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
            
              dbms_sql.close_cursor(vr_num_cursor_int);
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na atualizacao de finalização da carga do Score: '||SQLERRM;
                RAISE vr_excsaida;
            END;

          ELSE

            
            vr_dtfinali := SYSDATE;

            
            BEGIN
              vr_sql_cursor_int := 'update '||vr_nom_owner||'dw_fatocontrolecarga@'||vr_nom_dblink_rw||' car '
                                || '   set car.dthorafimprocesso = to_date('''||to_char(vr_dtfinali,'ddmmrrrrhh24miss')||''',''ddmmrrrrhh24miss'') '
                                || '      ,car.qtregistroerro = '||to_char(vr_qtregis_fisica + vr_qtregis_juridi)
                                || ' where car.skcarga = '||vr_skcarga;
            
              vr_num_cursor_int := dbms_sql.open_cursor;
            
              dbms_sql.parse(vr_num_cursor_int, vr_sql_cursor_int, 1);
            
              vr_num_retor_int := dbms_sql.execute(vr_num_cursor_int);
            
              dbms_sql.close_cursor(vr_num_cursor_int);
            EXCEPTION
              WHEN vr_excsaida THEN
                RAISE vr_excsaida;
              WHEN OTHERS THEN
                vr_dscritic := 'Erro na atualizacao de finalização da carga do Score: '||SQLERRM;
                RAISE vr_excsaida;
            END; 
          END IF;

          
          BEGIN
            UPDATE cecred.tbcrd_carga_score car
               SET car.dttermino = vr_dtfinali
                  ,car.qtregis_fisica = car.qtregis_fisica + vr_qtregis_fisica
                  ,car.qtregis_juridi = car.qtregis_juridi + vr_qtregis_juridi
             WHERE ROWID = vr_rowidcarga;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar historico de carga: '||SQLERRM;
              RAISE vr_excsaida;
          END;
        END IF;

        
        COMMIT;

      END IF;
    END LOOP;
    

    IF vr_qtregis_tot = 0 THEN

      vr_dscritic := 'Modelo '||pr_cdmodelo||' na data base '||to_char(pr_dtbase,'dd/mm/rrrrr')||' sem registro para carga! Processo nao efetuado...';
      RAISE vr_excsaida;
    END IF;


    open cr_crapope(3,pr_cdoperad);
    fetch cr_crapope into rw_crapope;
    CLOSE cr_crapope;


    IF pr_cddopcao = 'A' THEN
      vr_deslog := 'Aprovacao de Carga ';
    ELSE
      vr_deslog := 'Rejeicao de Carga ';
    END IF;

    vr_deslog := vr_deslog 
              || 'Modelo '||pr_cdmodelo||'- '||vr_dsmodelo|| ' Data Base '||to_char(pr_dtbase,'mm/rrrr')
              || ' com '||to_char(vr_qtregis_tot)||' registros por '
              || 'Operador '||pr_cdoperad||' - '||rw_crapope.nmoperad;


    btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                              ,pr_ind_tipo_log => 2 
                              ,pr_nmarqlog     => 'SCORE'
                              ,pr_flfinmsg     => 'N'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                               || ' -> ' || vr_deslog);


    COMMIT;
  EXCEPTION
    WHEN vr_excsaida THEN
      IF dbms_sql.is_open(vr_num_cursor) THEN

        dbms_sql.close_cursor(vr_num_cursor);
      END IF;
      IF dbms_sql.is_open(vr_num_cursor_int) THEN
        
        dbms_sql.close_cursor(vr_num_cursor_int);
      END IF;
      
      pr_dscritic := 'Erro na execucao da Carga/Rejeicao: '||vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      IF dbms_sql.is_open(vr_num_cursor) THEN
        
        dbms_sql.close_cursor(vr_num_cursor);
      END IF;
      IF dbms_sql.is_open(vr_num_cursor_int) THEN
        
        dbms_sql.close_cursor(vr_num_cursor_int);
      END IF;
      
      pr_dscritic := 'Erro nao tratado na execucao da Carga/Rejeicao: '||SQLERRM;
      ROLLBACK;
  END;

begin


  UPDATE integradados.dw_fatocontrolecarga@SASRW car 
     SET car.dthorainicioprocesso = NULL,
         car.dthorafimprocesso = NULL
    WHERE car.skdtbase   = to_char(vr_dtbase,'RRRRMMDD')
      AND car.skprocesso = 856 
      AND car.dthorainicioprocesso is NOT NULL;
  COMMIT;
  
  pc_efetua_carga_score_behavi(pr_cdmodelo => 3,
                                        pr_dtbase => vr_dtbase,
                                        pr_cddopcao => 'A',
                                        pr_cdoperad => 1,
                                        pr_dsrejeicao => NULL,
                                        pr_dscritic => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20500,vr_dscritic);  
  END IF; 
  
  COMMIT;                                      
   
END;
