DECLARE

  CURSOR cr_craptit  IS
    select tit.rowid
         , aut.NRSEQUEN
      from cecred.craptit tit
         , cecred.crapaut aut
     where tit.CDAGENCI = aut.CDAGENCI
       and tit.DTMVTOLT = aut.DTMVTOLT
       and tit.CDOPERAD = aut.CDOPECXA
       and tit.VLDPAGTO = aut.VLDOCMTO
       and tit.NRDOCMTO = aut.NRDOCMTO
       and tit.CDCOOPER = aut.CDCOOPER
       and aut.cdagenci not in (90, 91)
       and tit.progress_recid in (231720376, 231720379, 231720377, 231720378);
       
  CURSOR cr_crapaut  IS
    SELECT aut.progress_recid
         , rowid
         , aut.cdcooper
      FROM cecred.crapaut aut
     WHERE aut.progress_recid in (1084809975, 1084809978, 1084809976, 1084809977);
     
   vr_dslitera varchar2(4000);
   vr_dscritic VARCHAR2(4000);
   vr_exc_erro EXCEPTION;
   
  PROCEDURE pc_obtem_autenticacao (pr_cooper   IN INTEGER
                                  ,pr_registro IN ROWID
                                  ,pr_literal  OUT VARCHAR2) IS

        TYPE typ_tab_dia IS VARRAY(7) OF VARCHAR2(3);
        TYPE typ_tab_mes IS VARRAY(12) OF VARCHAR2(3);
        vr_tab_dia typ_tab_dia := typ_tab_dia('DOM','SEG','TER','QUA','QUI','SEX','SAB');
        vr_tab_mes typ_tab_mes := typ_tab_mes('JAN','FEV','MAR','ABR','MAI','JUN','JUL','AGO','SET','OUT','NOV','DEZ');
        
        CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                          ,pr_cdagenci IN crapage.cdagenci%type) IS
          SELECT crapage.nmresage
                ,crapage.cdagenci
                ,crapage.qtddaglf
          FROM cecred.crapage
          WHERE crapage.cdcooper = pr_cdcooper
          AND   crapage.cdagenci = pr_cdagenci;
        rw_crapage cr_crapage%ROWTYPE;
        
        CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
          SELECT crapcop.cdcooper
                ,crapcop.nmrescop
                ,crapcop.nrtelura
                ,crapcop.dsdircop
                ,crapcop.cdbcoctl
                ,crapcop.cdagectl
                ,crapcop.flgoppag
                ,crapcop.flgopstr
                ,crapcop.inioppag
                ,crapcop.fimoppag
                ,crapcop.iniopstr
                ,crapcop.fimopstr
                ,crapcop.cdagebcb
                ,crapcop.dssigaut
                ,crapcop.cdagesic
                ,crapcop.nrctasic
                ,crapcop.cdcrdins
            FROM cecred.crapcop
           WHERE crapcop.cdcooper = pr_cdcooper;
        rw_crapcop cr_crapcop%ROWTYPE;
        
        CURSOR cr_crapaut (pr_rowid IN ROWID) IS
          SELECT crapaut.dtmvtolt
                ,crapaut.hrautent
                ,crapaut.nrsequen
                ,crapaut.nrdcaixa
                ,crapaut.cdagenci
                ,crapaut.tpoperac
                ,crapaut.cdstatus
                ,crapaut.cdhistor
                ,crapaut.vldocmto
                ,crapaut.estorno
                ,crapaut.dsobserv
                ,crapaut.nrseqaut
                ,crapaut.nrdocmto
                ,crapaut.ROWID
          FROM cecred.crapaut
          WHERE ROWID = pr_rowid;
        rw_crapaut cr_crapaut%ROWTYPE;
        
        CURSOR cr_crapscn (pr_cdempres IN crapscn.cdempres%type) IS
          SELECT crapscn.cdempres
                ,crapscn.dssigemp
          FROM cecred.crapscn
          WHERE crapscn.cdempres = pr_cdempres;
        rw_crapscn cr_crapscn%ROWTYPE;
        
        CURSOR cr_crapstn (pr_cdempres IN crapstn.cdempres%type) IS
          SELECT crapstn.cdtransa
          FROM cecred.crapstn
          WHERE crapstn.cdempres = pr_cdempres
          AND   crapstn.tpmeiarr = 'C';
        rw_crapstn cr_crapstn%ROWTYPE;
        
        vr_off_line CHAR;
        vr_pg_rc    VARCHAR2(2);
        vr_valor    VARCHAR2(100);
        vr_dssigaut crapcop.dssigaut%TYPE;
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(4000);
        vr_exc_erro EXCEPTION;   
                                      
      BEGIN
        
        pr_literal  := NULL;
        
        OPEN cr_crapaut (pr_rowid => pr_registro);
        FETCH cr_crapaut INTO rw_crapaut;
        
        OPEN cr_crapcop (pr_cdcooper => pr_cooper);
        FETCH cr_crapcop INTO rw_crapcop;
        
        OPEN cr_crapage (pr_cdcooper => pr_cooper
                        ,pr_cdagenci => rw_crapaut.cdagenci);
        FETCH cr_crapage INTO rw_crapage;
        
        IF cr_crapaut%FOUND THEN
          IF rw_crapaut.tpoperac = 1 THEN
            vr_pg_rc:= 'PG';
          ELSE
            vr_pg_rc:= 'RC';
          END IF;
          IF  rw_crapaut.cdstatus = '2'  THEN
            vr_off_line:= '*';
          ELSE
            vr_off_line:= ' ';
          END IF;
          
          IF rw_crapaut.cdhistor = 582 THEN
            vr_valor:= LPad('*'||To_Char(rw_crapaut.vldocmto,'fm999g990d00'),11,' ');
            vr_dssigaut:= 'CEC '||gene0002.fn_mask(rw_crapcop.cdagebcb,'9999');
          ELSIF rw_crapaut.cdhistor = 1414 THEN
            vr_valor:= LPad(To_Char(rw_crapaut.vldocmto,'fm999g999g990d00'),11,'*');
            vr_dssigaut:= 'CCR';
          ELSE
            vr_valor:= LPad('*'||To_Char(rw_crapaut.vldocmto,'fm999g999g990d00'),15,' ');
            vr_dssigaut:= rw_crapcop.dssigaut;
          END IF;
          
          IF rw_crapaut.estorno = 0 THEN
            IF rw_crapaut.dtmvtolt < To_Date('04/25/2012','MM/DD/YYYY')  OR
               rw_crapaut.cdhistor = 582 OR
               rw_crapaut.cdagenci IN (90,91) THEN
              pr_literal:=  vr_dssigaut||' '||
                            gene0002.fn_mask(rw_crapaut.nrsequen,'99999') || ' ' ||
                            To_Char(rw_crapaut.dtmvtolt,'DD') ||
                            vr_tab_mes(To_Char(rw_crapaut.dtmvtolt,'MM'))||
                            To_Char(rw_crapaut.dtmvtolt,'YY')||
                            '      '||
                            vr_valor||
                            vr_pg_rc||
                            vr_off_line||
                            gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')||
                            gene0002.fn_mask(rw_crapaut.cdagenci,'999');
              IF  rw_crapaut.cdhistor = 1414
                  AND rw_crapaut.cdagenci = 90 THEN
                  pr_literal:= vr_dssigaut||
                               gene0002.fn_mask(rw_crapcop.nrctasic,'99999-9') ||
                               ' ' ||
                               gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')||
                               ' XXXX '||
                               To_Char(rw_crapaut.dtmvtolt,'DD/MM/YYYY')||
                               vr_valor ||
                               vr_pg_rc ||
                               '      ' ||
                               'GPS/INSS IDENT ';
              END IF;
              
            ELSIF  nvl(rw_crapaut.dsobserv,' ') <> ' ' THEN
              OPEN cr_crapscn (pr_cdempres => rw_crapaut.dsobserv);
              FETCH cr_crapscn INTO rw_crapscn;
              IF cr_crapscn%FOUND THEN
                OPEN cr_crapstn (pr_cdempres => rw_crapscn.cdempres);
                FETCH cr_crapstn INTO rw_crapstn;
                pr_literal:= 'BCS'||
                             '00089-2 '||
                             gene0002.fn_mask(rw_crapcop.cdagesic,'9999')|| ' '||
                             gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')|| ' '||
                             gene0002.fn_mask(rw_crapaut.nrsequen,'99999')|| ' '||
                             '********'||
                             To_Char(rw_crapaut.vldocmto,'fm9g999g999d99')||
                             'RR     '||' '||
                             to_char(rw_crapaut.dtmvtolt,'DD/MM/YYYY')||' '||
                             '* *****-*'||' '||
                             gene0002.fn_mask(rw_crapstn.cdtransa,'999')||' '||
                             gene0002.fn_mask(rw_crapscn.dssigemp,'999999999');
              END IF;
              
              CLOSE cr_crapscn;
            ELSIF  rw_crapaut.cdhistor = 1414 THEN
              pr_literal:= vr_dssigaut ||
                           gene0002.fn_mask(rw_crapcop.nrctasic,'99999-9') ||
                           ' ' ||
                           gene0002.fn_mask(rw_crapaut.nrdcaixa,'999')||
                           ' XXXX '||
                           To_Char(rw_crapaut.dtmvtolt,'DD/MM/YYYY')||
                           vr_valor ||
                           vr_pg_rc ||
                           '      ' ||
                           'GPS/INSS IDENT '; 
            ELSE
              pr_literal:= gene0002.fn_mask(rw_crapcop.cdbcoctl,'999')||
                           gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                           gene0002.fn_mask(rw_crapage.cdagenci,'999')||
                           gene0002.fn_mask(rw_crapaut.nrdcaixa,'99')||
                           ' '||
                           gene0002.fn_mask(rw_crapaut.nrsequen,'99999')||
                           ' '||
                           To_Char(rw_crapaut.dtmvtolt,'DDMMYY')||
                           '     '||
                           vr_off_line||
                           vr_valor||
                           vr_pg_rc;
            END IF;
            
          ELSE
            IF rw_crapaut.dtmvtolt < To_Date('25/04/2012','DD/MM/YYYY')  OR
               rw_crapaut.cdhistor = 582 OR
               rw_crapaut.cdagenci IN (90,91) THEN
              pr_literal:=  vr_dssigaut||' '||
                            gene0002.fn_mask(rw_crapaut.nrsequen,'99999') || ' ' ||
                            To_Char(rw_crapaut.dtmvtolt,'DD') ||
                            vr_tab_mes(To_Char(rw_crapaut.dtmvtolt,'MM'))||
                            To_Char(rw_crapaut.dtmvtolt,'YY')||
                            '-E'||
                            gene0002.fn_mask(rw_crapaut.nrseqaut,'99999')||' '||
                            To_Char(rw_crapaut.vldocmto,'fm999g999g990d00')||
                            vr_pg_rc||
                            vr_valor||
                            vr_off_line||
                            gene0002.fn_mask(rw_crapaut.nrdcaixa,'z99')||
                            gene0002.fn_mask(rw_crapaut.cdagenci,'999');
            ELSE
              pr_literal:= gene0002.fn_mask(rw_crapcop.cdbcoctl,'999')||
                           gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                           gene0002.fn_mask(rw_crapage.cdagenci,'999')||
                           gene0002.fn_mask(rw_crapaut.nrdcaixa,'99')||
                           ' '||
                           gene0002.fn_mask(rw_crapaut.nrsequen,'99999')||
                           ' '||
                           To_Char(rw_crapaut.dtmvtolt,'DDMMYY')||
                           'E'||
                           gene0002.fn_mask(rw_crapaut.nrseqaut,'99999')||
                           vr_off_line||
                           To_Char(rw_crapaut.vldocmto,'fm999g999g990d00')||
                           vr_pg_rc;
            END IF;
            
          END IF;
          
        END IF;
        
        CLOSE cr_crapaut;
        CLOSE cr_crapcop;
        CLOSE cr_crapage;   

   END pc_obtem_autenticacao;
   
BEGIN
  
  For rec_aut in cr_crapaut loop
    exit when cr_crapaut%notfound or (cr_crapaut%notfound) is null;
    pc_obtem_autenticacao(pr_cooper   => rec_aut.cdcooper
                         ,pr_registro => rec_aut.rowid
                         ,pr_literal  => vr_dslitera);
                         
    BEGIN
      UPDATE cecred.crapaut set dslitera = vr_dslitera
       WHERE rowid = rec_aut.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro RowId (' || rec_aut.rowid || ') da tabela CRAPAUT';
        RAISE vr_exc_erro;
    END;
    
  End Loop;
  
  COMMIT;
  
  For rec_tit in cr_craptit loop
    exit when cr_craptit%notfound or (cr_craptit%notfound) is null;
    
    BEGIN
      UPDATE cecred.craptit set nrautdoc = rec_tit.NRSEQUEN
       WHERE rowid = rec_tit.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro RowId (' || rec_tit.rowid || ') da tabela CRAPTIT';
        RAISE vr_exc_erro;
    END;
    
  End Loop;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;