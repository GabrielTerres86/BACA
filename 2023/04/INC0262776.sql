DECLARE

  CURSOR cr_crapass(pr_cdcooper cecred.crapass.cdcooper%type
                   ,pr_nrdconta cecred.crapass.nrdconta%type) is
    SELECT a.nrdconta,
           a.cdcooper,
           a.cdsitdct,
           a.dtdemiss,
           a.cdmotdem,
           a.dtelimin,
           a.cdagenci,
           a.inpessoa
      FROM CECRED.CRAPASS a
     WHERE a.cdcooper = pr_cdcooper
       and a.nrdconta = pr_nrdconta;

  rg_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_craplct(pr_cdcooper NUMBER
                   ,pr_nrdconta NUMBER
                   ,pr_cdhistor NUMBER) is
    SELECT ROWID dsdrowid
          ,l.cdcooper
          ,l.nrdconta
          ,l.vllanmto
          ,l.dtmvtolt
      FROM cecred.craplct l
     WHERE l.cdcooper = pr_cdcooper
       AND l.nrdconta = pr_nrdconta
       and l.cdhistor = pr_cdhistor
       and l.dtmvtolt = (select max(d.dtmvtolt)
                           from cecred.craplct d
                          where d.cdcooper = pr_cdcooper
                            and d.nrdconta = pr_nrdconta
                            and d.cdhistor = pr_cdhistor);
  
  CURSOR cr_devolucao(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_tpdevolu NUMBER) IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.tpdevolucao
         , t.vlcapital
         , t.qtparcelas
         , t.dtinicio_credito
         , t.vlpago
      FROM cecred.tbcotas_devolucao t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper
       AND tpdevolucao = pr_tpdevolu;

  CURSOR cr_cotas(pr_cdcooper NUMBER
                 ,pr_nrdconta NUMBER) IS
    SELECT t.vldcotas
      FROM cecred.crapcot t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper;

  vr_arq_path            VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0262776';


  vr_nmarquiv            VARCHAR2(100) := 'Contas_INC0262776.txt';
  vr_nmarqbkp            VARCHAR2(100) := 'INC0262776_script_rollback.sql';
  vr_nmarqcri            VARCHAR2(100) := 'INC0262776_script_log.txt';

  vr_hutlfile            utl_file.file_type;
  vr_dstxtlid            VARCHAR2(1000);
  vr_contador            INTEGER := 0;
  vr_qtdctatt            INTEGER := 0;
  vr_flagfind            BOOLEAN := FALSE;
  vr_tab_linhacsv        gene0002.typ_split;
  vr_vet_dados           tipoSplit.typ_split;
  vr_dstextab            varchar2(4000);
  

  vr_flarqrol            utl_file.file_type;
  vr_flarqlog            utl_file.file_type;
  vr_des_rollback_xml    CLOB;
  vr_texto_rb_completo   VARCHAR2(32600);
  vr_des_critic_xml      CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);  


  vr_lgrowid             ROWID;
  vr_dstransa            VARCHAR2(100) := 'Alterada situacao de conta por script. INC0262776.';
  vr_cdcooper            cecred.crapass.cdcooper%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_cdsitdct            NUMBER := 1;
  vr_vldcotas            NUMBER;
  vr_nrdocmto_lct        NUMBER;
  vr_nrdocmto_lcm        NUMBER;
  vr_nrseqdig            NUMBER;
  vr_dtmvtolt            DATE;
  vr_cdhistor_lancado_Cotas    cecred.craphis.cdhistor%type;
  vr_cdhistor_estorno_Cotas    cecred.craphis.cdhistor%type;
  vr_cdhistor_estorno_DepVista cecred.craphis.cdhistor%type;
  vr_cdcritic            NUMBER;
  vr_dscritic            VARCHAR2(2000);
  vr_dsdrowid            VARCHAR2(50);
  vr_tab_retorno         CECRED.LANC0001.typ_reg_retorno;
  vr_incrineg            INTEGER;

  vr_prox_conta          EXCEPTION;
  vr_exc_erro            EXCEPTION;
  vr_exc_clob            EXCEPTION;
  vr_des_erro            VARCHAR2(4000);

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
  END;

BEGIN

  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;

  

  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_hutlfile
                          ,pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na leitura do arquivo -> '||vr_dscritic;
    pc_escreve_xml_critica(vr_dscritic || chr(10));
    RAISE vr_exc_erro;
  END IF;

  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN
      LOOP
        vr_cdcooper := 0;
        vr_nrdconta := 0;

        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile
                                           ,pr_des_text => vr_dstxtlid);

        IF length(vr_dstxtlid) <= 1 THEN
          continue;
        END IF;

        vr_contador := vr_contador + 1;
        vr_flagfind := FALSE;

        vr_tab_linhacsv := gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := gene0002.fn_char_para_number(vr_tab_linhacsv(2));

        IF nvl(vr_cdcooper,0) = 0 OR nvl(vr_nrdconta,0) = 0 THEN
          pc_escreve_xml_critica('Erro ao encontrar cooperativa e conta ' || vr_dstxtlid  || chr(10));
          CONTINUE;
        END IF;
        
        vr_dtmvtolt := sistema.datascooperativa(vr_cdcooper).dtmvtolt;
        
        vr_dstextab := null;
    
        CADASTRO.Obterdstextab(pr_cdcooper => vr_cdcooper
                              ,pr_nmsistem => 'CRED'
                              ,pr_tptabela => 'GENERI'
                              ,pr_cdempres => 0
                              ,pr_cdacesso => 'PRAZODESLIGAMENTO'
                              ,pr_tpregist => 1
                              ,pr_dstextab => vr_dstextab);
        IF TRIM(vr_dstextab) IS NULL THEN
          pc_escreve_xml_critica('Erro ao buscar parametro de prazo de desligamento da cooperativa ' || vr_cdcooper || '.' || chr(10));
          CONTINUE;
        END IF;
        
        vr_vet_dados := quebraString(pr_string => vr_dstextab, pr_delimit => ';');
        
        FOR rg_crapass IN cr_crapass(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => vr_nrdconta) LOOP
          BEGIN
            IF NOT vr_flagfind THEN
              vr_flagfind := TRUE;
            END IF;
            SAVEPOINT TRANSACAO_CONTA;
            
            IF rg_crapass.cdsitdct <> 4 THEN
              pc_escreve_xml_critica('Cooperativa/Conta ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' <> 4 - encerrada por demissao.' || chr(10));
              RAISE vr_prox_conta;
            END IF;
            
            BEGIN
              select h.dsvalor_anterior
                into vr_cdsitdct
                from cecred.tbcc_conta_historico h
               where h.cdcooper = rg_crapass.cdcooper
                 and h.nrdconta = rg_crapass.nrdconta
                 and h.idcampo = 2
                 and h.tpoperacao = 2
                 and trim(h.dsvalor_novo) = '4'
                 and h.dhalteracao = (select max(h1.dhalteracao)
                                        from cecred.tbcc_conta_historico h1
                                       where h1.cdcooper = rg_crapass.cdcooper
                                         and h1.nrdconta = rg_crapass.nrdconta
                                         and h1.idcampo = 2
                                         and h1.tpoperacao = 2
                                         and trim(h1.dsvalor_novo) = '4');
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                vr_cdsitdct := 4;
              WHEN OTHERS THEN
                pc_escreve_xml_critica('Erro ao buscar situacao no historico da cCoperativa/Conta ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || SQLERRM || chr(10));
                CONTINUE;
            END;
            
            BEGIN
              UPDATE cecred.crapass
                 SET cdsitdct = vr_cdsitdct
                   , dtdemiss = NULL
                   , dtelimin = NULL
                   , cdmotdem = 0
               WHERE nrdconta = rg_crapass.nrdconta
                 AND cdcooper = rg_crapass.cdcooper;
               
            EXCEPTION
              WHEN OTHERS THEN
                pc_escreve_xml_critica('Erro ao atualizar registro da cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                RAISE vr_prox_conta;
            END;
            
            pc_escreve_xml_rollback('UPDATE CECRED.crapass' ||
                                    ' SET cdsitdct = '|| rg_crapass.cdsitdct ||
                                    ', dtdemiss = to_date('''||to_char(rg_crapass.dtdemiss,'dd/mm/yyyy')||''',''dd/mm/yyyy'')' ||
                                    case
                                      when rg_crapass.dtelimin IS NULL THEN
                                        ', dtelimin = NULL'
                                      else
                                        ', dtelimin = to_date('''||to_char(rg_crapass.dtelimin,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                                    end ||
                                    ', cdmotdem = '||NVL(rg_crapass.cdmotdem,0) ||
                                    ' WHERE cdcooper = '||rg_crapass.cdcooper ||
                                    ' AND nrdconta = '||rg_crapass.nrdconta||';' || chr(10) || chr(10));

            gene0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper
                                ,pr_cdoperad => '1'
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => 'AIMARO'
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => ''
                                ,pr_nrdconta => rg_crapass.nrdconta
                                ,pr_nrdrowid => vr_lgrowid);

            gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                     ,pr_nmdcampo => 'crapass.cdsitdct'
                                     ,pr_dsdadant => rg_crapass.cdsitdct
                                     ,pr_dsdadatu => vr_cdsitdct);

            gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                     ,pr_nmdcampo => 'crapass.dtdemiss'
                                     ,pr_dsdadant => rg_crapass.dtdemiss
                                     ,pr_dsdadatu => NULL);

            gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                     ,pr_nmdcampo => 'crapass.dtelimin'
                                     ,pr_dsdadant => rg_crapass.dtelimin
                                     ,pr_dsdadatu => NULL);

            gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                     ,pr_nmdcampo => 'crapass.cdmotdem'
                                     ,pr_dsdadant => rg_crapass.cdmotdem
                                     ,pr_dsdadatu => 0);

            pc_escreve_xml_rollback('DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = '''||vr_lgrowid||''' '
                                 || ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND '
                                 || ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);' || chr(10) || chr(10));

            pc_escreve_xml_rollback('DELETE cecred.craplgm WHERE rowid = '''||vr_lgrowid||'''; ' || chr(10) || chr(10));

            vr_nrdocmto_lct := fn_sequence('CRAPLCT','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';'||rg_crapass.cdagenci||';100;600040');            
            vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';'||rg_crapass.cdagenci||';100;600040');
            
            IF vr_vet_dados(1) = 1 THEN
              FOR lct IN cr_craplct(rg_crapass.cdcooper, rg_crapass.nrdconta, 2136) LOOP
                IF lct.vllanmto > 0 THEN
                  BEGIN                
                    INSERT INTO CECRED.craplct
                                  (cdcooper
                                  ,cdagenci
                                  ,cdbccxlt
                                  ,nrdolote
                                  ,dtmvtolt
                                  ,cdhistor
                                  ,nrctrpla
                                  ,nrdconta
                                  ,nrdocmto
                                  ,nrseqdig
                                  ,vllanmto
                                  ,cdopeori
                                  ,dtinsori)
                           VALUES (rg_crapass.cdcooper
                                  ,rg_crapass.cdagenci
                                  ,100
                                  ,600040
                                  ,vr_dtmvtolt
                                  ,61
                                  ,0
                                  ,rg_crapass.nrdconta
                                  ,vr_nrdocmto_lct
                                  ,vr_nrseqdig
                                  ,lct.vllanmto
                                  ,1
                                  ,SYSDATE) RETURN ROWID INTO vr_dsdrowid;

                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                             ,pr_nmdcampo => 'craplct.vllanmto'
                                             ,pr_dsdadant => NULL
                                             ,pr_dsdadatu => lct.vllanmto);

                    pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));

                  EXCEPTION
                    WHEN OTHERS THEN
                      pc_escreve_xml_critica('Erro ao realizar credito de lançamento de cota (historico 61) na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                      RAISE vr_prox_conta;
                  END;

                  BEGIN
                    vr_vldcotas := 0;

                    OPEN  cr_cotas(rg_crapass.cdcooper, rg_crapass.nrdconta);
                    FETCH cr_cotas INTO vr_vldcotas;
                    CLOSE cr_cotas;

                    UPDATE CECRED.crapcot
                      SET vldcotas = ( NVL(vldcotas,0) + NVL(lct.vllanmto,0) )
                    WHERE cdcooper = rg_crapass.cdcooper
                      AND nrdconta = rg_crapass.nrdconta;

                    pc_escreve_xml_rollback('UPDATE cecred.crapcot SET vldcotas = '||to_char(NVL(vr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||' WHERE cdcooper = '||rg_crapass.cdcooper||' AND nrdconta = '||rg_crapass.nrdconta||'; ' || chr(10) || chr(10));

                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                             ,pr_nmdcampo => 'crapcot.vldcotas'
                                             ,pr_dsdadant => to_char(NVL(vr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')
                                             ,pr_dsdadatu => to_char(( NVL(vr_vldcotas,0) + NVL(lct.vllanmto,0) ),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,'''));

                  EXCEPTION
                    WHEN OTHERS THEN
                      pc_escreve_xml_critica('Erro ao atualizar valor de cota na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                      RAISE vr_prox_conta;
                  END;
                  
                  BEGIN
                    vr_nrdocmto_lcm := fn_sequence('CRAPLCM','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';'||rg_crapass.cdagenci||';100;600040');
                    cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => rg_crapass.cdcooper
                                                             ,pr_dtmvtolt    => vr_dtmvtolt
                                                             ,pr_cdagenci    => rg_crapass.cdagenci
                                                             ,pr_cdbccxlt    => 100
                                                             ,pr_nrdolote    => 600040
                                                             ,pr_nrdctabb    => rg_crapass.nrdconta
                                                             ,pr_nrdocmto    => vr_nrdocmto_lcm
                                                             ,pr_cdhistor    => 127
                                                             ,pr_vllanmto    => lct.vllanmto
                                                             ,pr_nrdconta    => rg_crapass.nrdconta
                                                             ,pr_hrtransa    => gene0002.fn_busca_time
                                                             ,pr_cdorigem    => 0
                                                             ,pr_inprolot    => 1
                                                             ,pr_tab_retorno => vr_tab_retorno
                                                             ,pr_incrineg    => vr_incrineg
                                                             ,pr_cdcritic    => vr_cdcritic
                                                             ,pr_dscritic    => vr_dscritic);

                  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                    IF TRIM(vr_dscritic) IS NULL THEN
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    END IF;
                    pc_escreve_xml_critica('Erro ao incluir lancamento de estorno do cota capital em CRAPLCM, na cooperativa/conta ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ': ' ||vr_dscritic || chr(10));
                    RAISE vr_prox_conta;
                  END IF;

                  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                           ,pr_nmdcampo => 'craplcm.vllanmto (cdhistor = 127)'
                                           ,pr_dsdadant => NULL
                                           ,pr_dsdadatu => lct.vllanmto);

                pc_escreve_xml_rollback('DELETE cecred.craplcm ' || 
                                        'WHERE cdcooper = '||rg_crapass.cdcooper || 
                                        ' AND nrdconta = '||rg_crapass.nrdconta ||
                                        ' AND dtmvtolt = to_date('''||TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')' ||
                                        ' AND cdagenci = '||rg_crapass.cdagenci ||
                                        ' AND cdbccxlt = 100' ||
                                        ' AND nrdolote = 600040' ||
                                        ' AND nrdocmto = '||vr_nrdocmto_lcm||';' || chr(10) || chr(10));

                  EXCEPTION
                    WHEN OTHERS THEN
                      pc_escreve_xml_critica('Erro ao lancar debito do estorno do capital (historico 127) na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                      RAISE vr_prox_conta;
                  END;                
                END IF;
              END LOOP; 
                                         
              FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 1) LOOP
                BEGIN
                  DELETE cecred.tbcotas_devolucao
                   WHERE ROWID = valor.dsdrowid;

                  pc_escreve_xml_rollback('INSERT INTO cecred.tbcotas_devolucao' ||
                                          ' (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) ' ||
                                          ' VALUES ('||valor.cdcooper ||
                                          ' ,'||valor.nrdconta ||
                                          ' ,'||valor.tpdevolucao ||
                                          ' ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') ||
                                          case
                                            when valor.qtparcelas IS NULL THEN
                                              ' ,NULL'
                                            else
                                              ' ,'||valor.qtparcelas
                                          end ||
                                          case
                                            when valor.dtinicio_credito IS NULL THEN
                                              ' ,NULL'
                                            else
                                              ' ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                                          end ||
                                          ' ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');' || chr(10) || chr(10));

                EXCEPTION
                  WHEN OTHERS THEN
                    pc_escreve_xml_critica('Erro ao excluir registro de devolução tipo 1 na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                    RAISE vr_prox_conta;
                END;
              END LOOP;
              
            ELSE
              IF rg_crapass.inpessoa = 1 THEN
                vr_cdhistor_lancado_Cotas := 2079;
                vr_cdhistor_estorno_Cotas := 2518;
              ELSE
                vr_cdhistor_lancado_Cotas := 2080;
                vr_cdhistor_estorno_Cotas := 2519;
              END IF;
              
              FOR lct IN cr_craplct(rg_crapass.cdcooper, rg_crapass.nrdconta, vr_cdhistor_lancado_Cotas) LOOP              
                BEGIN                
                  INSERT INTO CECRED.craplct
                                (cdcooper
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,dtmvtolt
                                ,cdhistor
                                ,nrctrpla
                                ,nrdconta
                                ,nrdocmto
                                ,nrseqdig
                                ,vllanmto
                                ,cdopeori
                                ,dtinsori)
                         VALUES (rg_crapass.cdcooper
                                ,rg_crapass.cdagenci
                                ,100
                                ,600040
                                ,vr_dtmvtolt
                                ,vr_cdhistor_estorno_Cotas
                                ,0
                                ,rg_crapass.nrdconta
                                ,vr_nrdocmto_lct
                                ,vr_nrseqdig
                                ,lct.vllanmto
                                ,1
                                ,SYSDATE) RETURN ROWID INTO vr_dsdrowid;

                  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                           ,pr_nmdcampo => 'craplct.vllanmto'
                                           ,pr_dsdadant => NULL
                                           ,pr_dsdadatu => lct.vllanmto);

                  pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ' || chr(10) || chr(10));

                EXCEPTION
                  WHEN OTHERS THEN
                    pc_escreve_xml_critica('Erro ao realizar lançamento de cota na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                    RAISE vr_prox_conta;
                END;

                BEGIN
                  vr_vldcotas := 0;

                  OPEN  cr_cotas(rg_crapass.cdcooper, rg_crapass.nrdconta);
                  FETCH cr_cotas INTO vr_vldcotas;
                  CLOSE cr_cotas;

                  UPDATE CECRED.crapcot
                    SET vldcotas = ( NVL(vldcotas,0) + NVL(lct.vllanmto,0) )
                  WHERE cdcooper = rg_crapass.cdcooper
                    AND nrdconta = rg_crapass.nrdconta;

                  pc_escreve_xml_rollback('UPDATE cecred.crapcot SET vldcotas = '||to_char(NVL(vr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||' WHERE cdcooper = '||rg_crapass.cdcooper||' AND nrdconta = '||rg_crapass.nrdconta||'; ' || chr(10) || chr(10));

                EXCEPTION
                  WHEN OTHERS THEN
                    pc_escreve_xml_critica('Erro ao atualizar valor de cota na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                    RAISE vr_prox_conta;
                END;
              END LOOP;
              
              FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 3) LOOP
                BEGIN
                  DELETE cecred.tbcotas_devolucao
                   WHERE ROWID = valor.dsdrowid;

                  pc_escreve_xml_rollback('INSERT INTO cecred.tbcotas_devolucao' ||
                                          ' (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) ' ||
                                          ' VALUES ('||valor.cdcooper ||
                                          ' ,'||valor.nrdconta ||
                                          ' ,'||valor.tpdevolucao ||
                                          ' ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') ||
                                          case
                                            when valor.qtparcelas IS NULL THEN
                                              ' ,NULL'
                                            else
                                              ' ,'||valor.qtparcelas
                                          end ||
                                          case
                                            when valor.dtinicio_credito IS NULL THEN
                                              ' ,NULL'
                                            else
                                              ' ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                                          end ||
                                          ' ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');' || chr(10) || chr(10));

                EXCEPTION
                  WHEN OTHERS THEN
                    pc_escreve_xml_critica('Erro ao excluir registro de devolução tipo 1 na cooperativa/conta: ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                    RAISE vr_prox_conta;
                END;
              END LOOP;          
            END IF;
            
            vr_nrdocmto_lcm := fn_sequence('CRAPLCM','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';'||rg_crapass.cdagenci||';100;600040');
            FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 4) LOOP

              IF valor.vlcapital > 0 THEN
                
                IF rg_crapass.inpessoa = 1 THEN
                  vr_cdhistor_estorno_DepVista := 2520;
                ELSE
                  vr_cdhistor_estorno_DepVista := 2521;
                END IF;
                
                cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => rg_crapass.cdcooper
                                                         ,pr_dtmvtolt    => vr_dtmvtolt
                                                         ,pr_cdagenci    => rg_crapass.cdagenci
                                                         ,pr_cdbccxlt    => 100
                                                         ,pr_nrdolote    => 600040
                                                         ,pr_nrdctabb    => rg_crapass.nrdconta
                                                         ,pr_nrdocmto    => vr_nrdocmto_lcm
                                                         ,pr_cdhistor    => vr_cdhistor_estorno_DepVista
                                                         ,pr_vllanmto    => valor.vlcapital
                                                         ,pr_nrdconta    => rg_crapass.nrdconta
                                                         ,pr_hrtransa    => gene0002.fn_busca_time
                                                         ,pr_cdorigem    => 0
                                                         ,pr_inprolot    => 1
                                                         ,pr_tab_retorno => vr_tab_retorno
                                                         ,pr_incrineg    => vr_incrineg
                                                         ,pr_cdcritic    => vr_cdcritic
                                                         ,pr_dscritic    => vr_dscritic);

                IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  IF TRIM(vr_dscritic) IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  END IF;
                  pc_escreve_xml_critica('Erro ao incluir lancamento de estorno do deposito a vista na cooperativa/conta ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ': ' ||vr_dscritic || chr(10));
                  RAISE vr_prox_conta;
                END IF;


                gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                         ,pr_nmdcampo => 'craplcm.vllanmto'
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => valor.vlcapital);

                pc_escreve_xml_rollback('DELETE cecred.craplcm ' || 
                                        'WHERE cdcooper = '||rg_crapass.cdcooper || 
                                        ' AND nrdconta = '||rg_crapass.nrdconta ||
                                        ' AND dtmvtolt = to_date('''||TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')' ||
                                        ' AND cdagenci = '||rg_crapass.cdagenci ||
                                        ' AND cdbccxlt = 100' ||
                                        ' AND nrdolote = 600040' ||
                                        ' AND nrdocmto = '||vr_nrdocmto_lcm||';' || chr(10) || chr(10));

              END IF;

              BEGIN
                DELETE cecred.tbcotas_devolucao
                 WHERE ROWID = valor.dsdrowid;

                pc_escreve_xml_rollback('INSERT INTO cecred.tbcotas_devolucao ' ||
                                        '(cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) ' ||
                                        'VALUES ('||valor.cdcooper ||
                                        ' ,'||valor.nrdconta ||
                                        ' ,'||valor.tpdevolucao ||
                                        ' ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''') ||
                                        case
                                          when valor.qtparcelas IS NULL THEN
                                            ' ,NULL'
                                          else
                                            ' ,'||valor.qtparcelas
                                        end ||
                                        case
                                          when valor.dtinicio_credito IS NULL THEN
                                            ' ,NULL'
                                          else
                                            ' ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                                        end ||
                                        ' ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');' || chr(10) || chr(10));
              EXCEPTION
                WHEN OTHERS THEN
                  pc_escreve_xml_critica('Erro ao excluir registro de devolução tipo 4 da cooperativa/conta ' || rg_crapass.cdcooper || '/' || rg_crapass.nrdconta || ' - ' || SQLERRM || chr(10));
                  RAISE vr_prox_conta;
              END;

            END LOOP;

          EXCEPTION
            WHEN vr_prox_conta THEN
              ROLLBACK TO TRANSACAO_CONTA;
              CONTINUE;
            WHEN OTHERS THEN
              pc_escreve_xml_critica('>>>> Erro ao processar registro da coop: ' || vr_cdcooper || ', conta: ' || vr_nrdconta || ' - ' || SQLERRM || chr(10));
              CONTINUE;
          END;

        END LOOP;

        IF NOT vr_flagfind THEN
          pc_escreve_xml_critica('>>>> Erro ao processar registro da coop: ' || vr_cdcooper || ', conta: ' || vr_nrdconta || ' - Conta não encontrada.' ||chr(10));
        END IF;
        
        vr_qtdctatt := vr_qtdctatt + 1;
        
        IF mod(vr_qtdctatt,100) = 0 THEN
          COMMIT;
          dbms_output.put_line('Commit de ' || vr_qtdctatt || ' registros.');
        END IF;

      END LOOP;

    EXCEPTION
      WHEN no_data_found THEN
        pc_escreve_xml_critica('Qtde contas lidas:'||vr_contador||chr(10));
        pc_escreve_xml_critica('Qtde contas atualizadas:'||vr_qtdctatt);
        pc_escreve_xml_critica(' ',TRUE);

        pc_escreve_xml_rollback('COMMIT;');
        pc_escreve_xml_rollback(' ',TRUE);

        CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqbkp,
                                      pr_des_erro => vr_des_erro);
        IF (vr_des_erro IS NOT NULL) THEN
          dbms_lob.close(vr_des_rollback_xml);
          dbms_lob.freetemporary(vr_des_rollback_xml);
          RAISE vr_exc_clob;
        END IF;

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                      pr_caminho  => vr_arq_path,
                                      pr_arquivo  => vr_nmarqcri,
                                      pr_des_erro => vr_des_erro);
        IF (vr_des_erro IS NOT NULL) THEN
          dbms_lob.close(vr_des_critic_xml);
          dbms_lob.freetemporary(vr_des_critic_xml);
          RAISE vr_exc_clob;
        END IF;

        dbms_lob.close(vr_des_rollback_xml);
        dbms_lob.freetemporary(vr_des_rollback_xml);

        dbms_lob.close(vr_des_critic_xml);
        dbms_lob.freetemporary(vr_des_critic_xml);

        dbms_output.put_line('Rotina finalizada, verifique arquivo de criticas em :' || vr_arq_path);
      WHEN OTHERS THEN
        dbms_output.put_line('Erro inesperado 1 - ' || SQLERRM);
        cecred.pc_internal_exception;
    END;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;

    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);

    raise_application_error(-20001, vr_dscritic);

  WHEN OTHERS THEN
    ROLLBACK;

    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);

    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;
