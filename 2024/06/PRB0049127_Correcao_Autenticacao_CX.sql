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
       and tit.progress_recid in (235535086, 235535470, 235536766, 235537403, 235538149, 235538685, 235552862, 235545488, 235553842, 235568423, 235571755, 235576929, 
        235581184, 235581356, 235582350, 235582384, 235533002, 235533465, 235542724, 235542975, 235543024, 235545329, 235547802, 235550707, 235552533, 235553056, 
        235553091, 235553211, 235553239, 235553410, 235553523, 235553762, 235553885, 235553936, 235554161, 235554944, 235555828, 235556017, 235557188, 235563375, 
        235563454, 235563854, 235567381, 235568470, 235569277, 235586413, 235536074, 235536869, 235549776, 235530998, 235533643, 235533556, 235534372, 235539021, 
        235552813, 235589299, 235523929, 235526429, 235526999, 235533050, 235534721, 235547076, 235547437, 235562322, 235571550, 235572374, 235580816, 235584690, 
        235528111, 235530393, 235530518, 235530770, 235531083, 235531631, 235531952, 235532001, 235532655, 235532742, 235532791, 235532816, 235532834, 235532867, 
        235538103, 235564424, 235567204, 235534181, 235535211, 235537678, 235547277, 235580683, 235540119, 235540251, 235543399, 235545203, 235545241, 235546114, 
        235563236, 235565011, 235576423, 235576946, 235581242, 235585759, 235586015, 235586533, 235588112, 235591043, 235561517, 235603775, 235593527, 235537475, 
        235538264, 235538353, 235538360, 235538409, 235538446, 235538466, 235538494, 235538576, 235539478, 235540064, 235540785, 235541672, 235541705, 235542655, 
        235539317, 235540217, 235542658, 235563124, 235581373, 235582505, 235583270, 235583488, 235583912, 235584731, 235590286, 235590421, 235590929, 235591458, 
        235591481, 235591577, 235592491, 235593156, 235593298, 235593525, 235593906, 235594659, 235594763, 235596593, 235596629, 235596714, 235597115, 235530386, 
        235545467, 235529338, 235529478, 235530822, 235533198, 235534681, 235544076, 235548067, 235566403, 235580865, 235589276, 235529881, 235531741, 235533120, 
        235535627, 235524011, 235525318, 235525681, 235526624, 235544715, 235551150, 235564940, 235530453, 235531822, 235535557, 235535979, 235553500, 235555043, 
        235557281, 235558200, 235560051, 235561725, 235565116, 235556000, 235556846, 235563306, 235568098, 235527031, 235527589, 235527752, 235527873, 235547031, 
        235547132, 235547309, 235547764, 235548048, 235548070, 235548112, 235548170, 235548360, 235548422, 235548534, 235549168, 235549470, 235549558, 235550142, 
        235550435, 235550590, 235551059, 235551374, 235551898, 235551930, 235552220, 235552280, 235552593, 235553046, 235555219, 235560233, 235566564, 235568724, 
        235527761, 235550378, 235556230, 235553067, 235560134, 235575201, 235600581, 235601495, 235601577, 235604156, 235604641, 235604694, 235604791, 235604886, 
        235605738, 235526869, 235528953, 235530846, 235536545, 235581272, 235590747, 235591138, 235523309, 235521377, 235528346, 235571130, 235576587, 235577257, 
        235553245, 235563709, 235567293, 235567436, 235541603, 235541663, 235553745, 235522309, 235542763, 235549609, 235559043, 235545386, 235547836, 235554962, 
        235554309, 235531351, 235525723, 235524216, 235524563, 235526013, 235526212, 235543013, 235548155, 235550288, 235554403, 235554467, 235554496, 235562501, 
        235563505, 235564444, 235566736, 235531792, 235538367, 235567265, 235582220, 235583753, 235567217, 235569891, 235521526, 235522318, 235523340, 235524128, 
        235524616, 235524650, 235525788, 235532709, 235535101, 235538558, 235548096, 235564342, 235580141);
       
  CURSOR cr_crapaut  IS
    SELECT aut.progress_recid
         , rowid
         , aut.cdcooper
      FROM cecred.crapaut aut
     WHERE aut.progress_recid in (1110807119, 1110795715, 1110687318, 1110692002, 1110695811, 1110691736, 1110692175, 1110692305, 1110696264, 1110694187, 1110692956, 1110690402, 
        1110692405, 1110691706, 1110691362, 1110694318, 1110687916, 1110912942, 1110923963, 1110871751, 1110877700, 1110874624, 1110915539, 1110916412, 1110917511, 1110922594, 
        1110785311, 1110920588, 1110921130, 1110876718, 1110918996, 1110874071, 1110907891, 1110870203, 1110920455, 1110921026, 1110921286, 1110924670, 1110934506, 1110913860, 
        1110923094, 1110698712, 1110696281, 1110638940, 1110722437, 1110636818, 1110632240, 1110635871, 1110630638, 1110640341, 1110655436, 1110658156, 1110612505, 1110605531, 
        1110618076, 1110609548, 1110794374, 1110740163, 1110709064, 1110798098, 1110753955, 1110770146, 1110771527, 1110754594, 1110771041, 1110680294, 1110779481, 1110666126, 
        1110639311, 1110642706, 1110763534, 1110790107, 1110809613, 1110755682, 1110807506, 1110774945, 1110733372, 1110736830, 1110737050, 1110745962, 1110729216, 1110733108, 
        1110735224, 1110739381, 1110728766, 1110722948, 1110732048, 1110739785, 1110742914, 1110755243, 1110805892, 1110728940, 1110741589, 1110744611, 1110741499, 1110733855, 
        1110734206, 1110744920, 1110724450, 1110728650, 1110723352, 1110727945, 1110620688, 1110623728, 1110616405, 1110620192, 1110730790, 1110739156, 1110620229, 1110759563, 
        1110969080, 1110839320, 1110746062, 1110965959, 1110963971, 1110959937, 1110960280, 1110961301, 1110965543, 1110960944, 1110969473, 1110774510, 1110869734, 1110616743, 
        1110628645, 1110904078, 1110911886, 1110636997, 1110676050, 1110603826, 1110603403, 1110634041, 1110849208, 1110826111, 1110852322, 1110811478, 1110749790, 1110812086, 
        1110782992, 1110747663, 1110693891, 1110694163, 1110726035, 1110605011, 1110768828, 1110701785, 1110722079, 1110751231, 1110724783, 1110757008, 1110648221, 1110609712, 
        1110790521, 1110760783, 1110706972, 1110738816, 1110760660, 1110798952, 1110795805, 1110729163, 1110794944, 1110757403, 1110613819, 1110618726, 1110610556, 1110616270, 
        1110807369, 1110870840, 1110872985, 1110691774, 1110642556, 1110807161, 1110809223, 1110605049, 1110670477, 1110606110, 1110608082, 1110646543, 1110603947, 1110608202, 
        1110609939, 1110606920, 1110728871, 1110792424, 1110862125, 1110695740, 1110620507, 1110622742, 1110686486, 1110650594, 1110636585, 1110641389, 1110646849, 1110647113, 
        1110642115, 1110647270, 1110645505, 1110639789, 1110629916, 1110647406, 1110638995, 1110643260, 1110644652, 1110788961, 1110916416, 1110802279, 1110860695, 1110658990, 
        1110659505, 1110718303, 1110714782, 1110721469, 1110693260, 1110698905, 1110716886, 1110964507, 1110728742, 1110708325, 1110725516, 1110844811, 1110748101, 1110790373, 
        1110794722, 1110814719, 1110811885, 1110721802, 1110787544, 1110745993, 1110752477, 1110746173, 1110754068, 1110747727, 1110753358, 1110706819, 1110735490, 1110751175, 
        1110894446, 1110814146, 1110748273, 1110755740, 1110749660, 1110749761, 1110752083, 1110753538, 1110701597, 1110818436, 1110871318, 1110873466, 1110813926, 1110866361, 
        1110870121, 1110670264, 1110685538, 1110664582, 1110768155, 1110724612, 1110707034, 1110748884, 1110669721, 1110729772, 1110668582, 1110673376, 1110901518, 1110740873, 
        1110659840, 1110602101, 1110654981, 1110687490, 1110667392, 1110686709, 1110672776, 1110654624, 1110640881, 1110645268, 1110786850, 1110877535, 1110731456, 1110797700, 
        1110789820, 1110869610, 1110880130, 1110884405, 1110895366, 1110908404, 1110898022, 1110741064, 1110678973, 1110679711, 1110727812, 1110671113, 1110673971, 1110657420, 
        1110834043, 1110831314, 1110723137, 1110860464, 1110855811, 1110844876, 1110851604, 1110690679, 1110899426);
     
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