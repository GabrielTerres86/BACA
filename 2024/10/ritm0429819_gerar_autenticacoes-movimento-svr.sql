DECLARE
  
  vc_diretorio      CONSTANT VARCHAR2(100) := gene0001.fn_diretorio('M',0)||'cpd/bacas/RITM0429819';
  vc_dtmvtocd       CONSTANT DATE := to_date('16/10/2024','dd/mm/yyyy');
  vc_cdhistor_PF    CONSTANT NUMBER := 4606;
  vc_cdhistor_PJ    CONSTANT NUMBER := 4607;
  vc_cdhistor_caixa CONSTANT NUMBER := 4608;
  
  TYPE typ_tab_mes IS VARRAY(12) OF VARCHAR2(3);

  vr_tab_mes typ_tab_mes:= typ_tab_mes('JAN','FEV','MAR','ABR','MAI','JUN',
                                       'JUL','AGO','SET','OUT','NOV','DEZ');


  CURSOR cr_caixas(pr_idtodas NUMBER) IS
    SELECT cop.cdcooper
         , DECODE(cop.cdcooper, 1,  1,  2, 14,  5,  9
                              , 6,  2,  7,  1,  8,  1
                              , 9,  1, 10,  3, 11, 95
                              , 12, 1, 13,  1, 14,  1, 16, 1) cdagenci
         , DECODE(cop.cdcooper, 1,  3,  2,  5,  5,  4
                              , 6,  1,  7,100,  8,  2
                              , 9,  7, 10,  1, 11,  1
                              , 12,10, 13,  6, 14, 10, 16, 1) nrdcaixa
         , DECODE(cop.cdcooper, 8,'f0080040', 'f0033918') cdoperad
      FROM cecred.crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3
       AND (cop.cdcooper IN (1,2) OR pr_idtodas = 1);
  
  CURSOR cr_lancamento(pr_cdcooper  NUMBER
                      ,pr_cdagenci  NUMBER
                      ,pr_nrdcaixa  NUMBER) IS 
    SELECT t.tpoperac
         , ROWID dsdrowid
      FROM cecred.crapaut t 
     WHERE t.cdcooper = pr_cdcooper
       AND t.cdagenci = pr_cdagenci
       AND t.nrdcaixa = pr_nrdcaixa
       AND t.dtmvtolt = vc_dtmvtocd
       AND t.cdhistor = vc_cdhistor_caixa;
  
  CURSOR cr_sem_autenticacao(pr_cdcooper NUMBER
                            ,pr_cdagenci NUMBER
                            ,pr_nrdcaixa NUMBER) IS
    SELECT lcx.cdcooper
         , lcx.nrdconta
         , lcx.cdagenci
         , lcx.nrdcaixa
         , lcx.cdopecxa 
         , lcx.cdhistor
         , lcx.dtmvtolt
         , lcx.nrdmaqui
         , lcx.nrdocmto
         , lcx.vldocmto
         , lcx.nrautdoc
         , lcx.cdopeatr
         , his.indebcre
         , lcx.ROWID dsdrowid
      FROM cecred.craplcx lcx
     INNER JOIN cecred.craphis his
        ON his.cdcooper = lcx.cdcooper
       AND his.cdhistor = lcx.cdhistor
     WHERE lcx.cdcooper = pr_cdcooper
       AND lcx.dtmvtolt = vc_dtmvtocd
       AND lcx.cdagenci = pr_cdagenci
       AND lcx.nrdcaixa = pr_nrdcaixa
       AND NVL(lcx.nrautdoc,0) = 0
       AND lcx.cdhistor IN (vc_cdhistor_PF,vc_cdhistor_PJ,vc_cdhistor_caixa)
       AND NOT EXISTS (SELECT 1 
                         FROM cecred.crapaut aut
                        WHERE aut.cdcooper = lcx.cdcooper
                          AND aut.cdagenci = lcx.cdagenci
                          AND aut.nrdcaixa = lcx.nrdcaixa
                          AND aut.dtmvtolt = lcx.dtmvtolt
                          AND aut.vldocmto = lcx.vldocmto
                          AND aut.nrdocmto = lcx.nrdocmto
                          AND aut.cdhistor = lcx.cdhistor);
  
  CURSOR cr_crapaut_sequen (pr_cdcooper IN crapaut.cdcooper%TYPE
                           ,pr_cdagenci IN crapaut.cdagenci%TYPE
                           ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE
                           ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE
                           ,pr_nrsequen IN crapaut.nrsequen%TYPE) IS
    SELECT crapaut.dtmvtolt
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.nrdcaixa
          ,crapaut.blidenti
          ,crapaut.blsldini
          ,crapaut.bltotpag
          ,crapaut.bltotrec
          ,crapaut.blvalrec
          ,crapaut.nrseqaut
          ,crapaut.ROWID
    FROM cecred.crapaut
    WHERE crapaut.cdcooper = pr_cdcooper
    AND   crapaut.cdagenci = pr_cdagenci
    AND   crapaut.nrdcaixa = pr_nrdcaixa
    AND   crapaut.dtmvtolt = pr_dtmvtolt
    AND   crapaut.nrsequen = pr_nrsequen
    ORDER BY crapaut.progress_recid ASC;
  
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
  
  vr_arqlog      UTL_FILE.file_type;
  vr_literal     VARCHAR2(100);
  vr_sequencia   INTEGER;
  vr_registro    ROWID;
  vr_cdcritic    INTEGER;
  vr_dscritic    VARCHAR2(2000);
  vr_operacao    BOOLEAN;
  
  PROCEDURE pc_obtem_literal_autenticacao (pr_cooper   IN INTEGER 
                                          ,pr_registro IN ROWID    
                                          ,pr_literal  OUT VARCHAR2
                                          ,pr_cdcritic OUT INTEGER 
                                          ,pr_dscritic OUT VARCHAR2) IS 

    CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                      ,pr_cdagenci IN crapage.cdagenci%type) IS
      SELECT crapage.nmresage
            ,crapage.cdagenci
            ,crapage.qtddaglf
      FROM cecred.crapage
      WHERE crapage.cdcooper = pr_cdcooper
      AND   crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

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
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    pr_literal:= NULL;

    OPEN cr_crapaut (pr_rowid => pr_registro);
    FETCH cr_crapaut INTO rw_crapaut;
    IF cr_crapaut%FOUND THEN

      OPEN cr_crapage (pr_cdcooper => pr_cooper
                      ,pr_cdagenci => rw_crapaut.cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      IF cr_crapage%NOTFOUND THEN
        CLOSE cr_crapage;
        CLOSE cr_crapaut;
        
        vr_cdcritic:= 15;
        vr_dscritic:= NULL;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapage;

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
            IF cr_crapstn%NOTFOUND THEN
              CLOSE cr_crapstn;
              CLOSE cr_crapscn;
              vr_cdcritic:= 0;
              vr_dscritic:= 'Transacao para pagamento nao cadastrada.';
              RAISE vr_exc_erro;
            END IF;
            CLOSE cr_crapstn;

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

  EXCEPTION
     WHEN vr_exc_erro THEN
       pr_cdcritic:= vr_cdcritic;
       pr_dscritic:= vr_dscritic;
     WHEN OTHERS THEN
       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro na rotina CXON0000.pc_obtem_literal_autenticacao. '||SQLERRM;
  END pc_obtem_literal_autenticacao;
  
  PROCEDURE pc_grava_autenticacao (pr_cooper       IN INTEGER 
                                  ,pr_cod_agencia  IN INTEGER 
                                  ,pr_nro_caixa    IN INTEGER 
                                  ,pr_cod_operador IN VARCHAR2
                                  ,pr_valor        IN NUMBER  
                                  ,pr_docto        IN NUMBER  
                                  ,pr_operacao     IN BOOLEAN 
                                  ,pr_status       IN VARCHAR2
                                  ,pr_estorno      IN BOOLEAN 
                                  ,pr_histor       IN INTEGER 
                                  ,pr_data_off     IN DATE    
                                  ,pr_sequen_off   IN INTEGER 
                                  ,pr_hora_off     IN INTEGER 
                                  ,pr_seq_aut_off  IN INTEGER 
                                  ,pr_literal      OUT VARCHAR2 
                                  ,pr_sequencia    OUT INTEGER  
                                  ,pr_registro     OUT ROWID    
                                  ,pr_cdcritic     OUT INTEGER  
                                  ,pr_dscritic     OUT VARCHAR2) IS 
  
    CURSOR cr_crapcbl (pr_cdcooper IN crapcbl.cdcooper%type
                      ,pr_cdagenci IN crapcbl.cdagenci%type
                      ,pr_nrdcaixa IN crapcbl.nrdcaixa%type) IS
      SELECT crapcbl.cdcooper
            ,crapcbl.cdagenci
            ,crapcbl.nrdcaixa
            ,crapcbl.blidenti
            ,crapcbl.vlcompdb
            ,crapcbl.vlcompcr
            ,crapcbl.vlinicial
            ,crapcbl.rowid
      FROM cecred.crapcbl 
      WHERE crapcbl.cdcooper = pr_cdcooper
      AND   crapcbl.cdagenci = pr_cdagenci
      AND   crapcbl.nrdcaixa = pr_nrdcaixa;
    rw_crapcbl  cr_crapcbl%ROWTYPE; 
    
    CURSOR cr_crapaut (pr_cdcooper IN crapaut.cdcooper%TYPE
                      ,pr_cdagenci IN crapaut.cdagenci%TYPE
                      ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE
                      ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE) IS
      SELECT crapaut.dtmvtolt
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.nrdcaixa
            ,crapaut.blidenti
            ,crapaut.blsldini
            ,crapaut.bltotpag
            ,crapaut.bltotrec
            ,crapaut.blvalrec
            ,crapaut.nrseqaut
            ,crapaut.ROWID
      FROM cecred.crapaut
      WHERE crapaut.cdcooper = pr_cdcooper
      AND   crapaut.cdagenci = pr_cdagenci
      AND   crapaut.nrdcaixa = pr_nrdcaixa
      AND   crapaut.dtmvtolt = pr_dtmvtolt
      ORDER BY crapaut.progress_recid DESC;
    rw_crapaut cr_crapaut%ROWTYPE;
      
    CURSOR cr_crapaut_hist (pr_cdcooper IN crapaut.cdcooper%TYPE
                           ,pr_cdagenci IN crapaut.cdagenci%TYPE
                           ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE
                           ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE
                           ,pr_cdhistor IN crapaut.cdhistor%TYPE
                           ,pr_nrdocmto IN crapaut.nrdocmto%TYPE
                           ,pr_estorno  IN crapaut.estorno%TYPE) IS
      SELECT crapaut.dtmvtolt
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.nrdcaixa
            ,crapaut.blidenti
            ,crapaut.blsldini
            ,crapaut.bltotpag
            ,crapaut.bltotrec
            ,crapaut.blvalrec
            ,crapaut.nrseqaut
            ,crapaut.ROWID
      FROM cecred.crapaut
      WHERE crapaut.cdcooper = pr_cdcooper
      AND   crapaut.cdagenci = pr_cdagenci
      AND   crapaut.nrdcaixa = pr_nrdcaixa
      AND   crapaut.dtmvtolt = pr_dtmvtolt
      AND   crapaut.cdhistor = pr_cdhistor
      AND   crapaut.nrdocmto = pr_nrdocmto
      AND   crapaut.estorno  = pr_estorno
      ORDER BY crapaut.progress_recid DESC;
    
    
    vr_sequen   INTEGER;
    vr_seq_aut  INTEGER;
    vr_estorno  INTEGER;
    vr_operacao INTEGER;
    vr_literal  VARCHAR2(100);
    vr_busca    VARCHAR2(100);
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
  BEGIN

    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;

    OPEN cr_crapcop(pr_cdcooper => pr_cooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;

    IF pr_data_off IS NULL AND
       pr_cod_agencia <> 90 AND
       pr_cod_agencia <> 91 THEN

      OPEN cr_crapcbl (pr_cdcooper => pr_cooper
                      ,pr_cdagenci => pr_cod_agencia
                      ,pr_nrdcaixa => pr_nro_caixa);

      FETCH cr_crapcbl INTO rw_crapcbl;

      IF cr_crapcbl%NOTFOUND THEN
        CLOSE cr_crapcbl;

        BEGIN
          INSERT INTO cecred.crapcbl
          (crapcbl.cdcooper
          ,crapcbl.cdagenci
          ,crapcbl.nrdcaixa)
          VALUES
          (pr_cooper
          ,pr_cod_agencia
          ,pr_nro_caixa)
          RETURNING
           crapcbl.cdcooper
          ,crapcbl.cdagenci
          ,crapcbl.nrdcaixa
          ,crapcbl.rowid
          INTO
           rw_crapcbl.cdcooper
          ,rw_crapcbl.cdagenci
          ,rw_crapcbl.nrdcaixa
          ,rw_crapcbl.rowid;
        EXCEPTION
          WHEN Dup_Val_On_Index THEN
            NULL;
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir no BL do caixa online. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
      IF cr_crapcbl%ISOPEN THEN
        CLOSE cr_crapcbl;
      END IF;

      IF  rw_crapcbl.blidenti <> ' ' THEN
        IF  pr_operacao THEN 
          IF  pr_estorno THEN
            rw_crapcbl.vlcompdb:= Nvl(rw_crapcbl.vlcompdb,0) - Nvl(pr_valor,0);
          ELSE
            rw_crapcbl.vlcompdb:= Nvl(rw_crapcbl.vlcompdb,0) + Nvl(pr_valor,0);
          END IF;
        ELSE
          IF  pr_estorno THEN
            rw_crapcbl.vlcompcr:= Nvl(rw_crapcbl.vlcompcr,0) - Nvl(pr_valor,0);
          ELSE
            rw_crapcbl.vlcompcr:= Nvl(rw_crapcbl.vlcompcr,0) + Nvl(pr_valor,0);
          END IF;
        END IF;
        BEGIN
          UPDATE cecred.crapcbl SET crapcbl.vlcompdb = rw_crapcbl.vlcompdb
                            ,crapcbl.vlcompcr = rw_crapcbl.vlcompcr
          WHERE crapcbl.ROWID = rw_crapcbl.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
    END IF;

    IF pr_data_off IS NULL THEN
      vr_busca :=  TRIM(pr_cooper)      || ';' ||
                   TRIM(pr_cod_agencia) || ';' ||
                   TRIM(pr_nro_caixa)  || ';' ||
                   TO_char(vc_dtmvtocd,'dd/mm/yyyy');

      vr_sequen := fn_sequence('CRAPAUT','NRSEQUEN',vr_busca);

      pr_sequencia:= vr_sequen;
      IF NOT pr_estorno THEN
        IF pr_estorno THEN
          vr_estorno:= 1;
        ELSE
          vr_estorno:= 0;
        END IF;
        IF pr_operacao THEN
          vr_operacao:= 1;
        ELSE
          vr_operacao:= 0;
        END IF;

        BEGIN
          INSERT INTO cecred.crapaut
            (crapaut.cdcooper
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.dtmvtolt
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.hrautent
            ,crapaut.vldocmto
            ,crapaut.nrdocmto
            ,crapaut.tpoperac
            ,crapaut.cdstatus
            ,crapaut.estorno
            ,crapaut.cdhistor)
          VALUES
            (pr_cooper
            ,pr_cod_agencia
            ,pr_nro_caixa
            ,vc_dtmvtocd
            ,vr_sequen
            ,pr_cod_operador
            ,GENE0002.fn_busca_time
            ,pr_valor
            ,pr_docto
            ,vr_operacao
            ,pr_status
            ,vr_estorno
            ,pr_histor)
           RETURNING
             crapaut.ROWID
           INTO
             rw_crapaut.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      ELSE
        vr_seq_aut:= 0;
        IF pr_status = '1' AND pr_sequen_off <> 0 THEN
          vr_seq_aut:= pr_sequen_off;
        ELSE
          OPEN cr_crapaut_hist (pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => pr_nro_caixa
                               ,pr_dtmvtolt => vc_dtmvtocd
                               ,pr_cdhistor => pr_histor
                               ,pr_nrdocmto => pr_docto
                               ,pr_estorno  => 0);
          FETCH cr_crapaut_hist INTO rw_crapaut;
          IF cr_crapaut_hist%FOUND THEN
            vr_seq_aut:= rw_crapaut.nrsequen;
          END IF;
          CLOSE cr_crapaut_hist;
        END IF;

        IF pr_estorno THEN
          vr_estorno:= 1;
        ELSE
          vr_estorno:= 0;
        END IF;
        IF pr_operacao THEN
          vr_operacao:= 1;
        ELSE
          vr_operacao:= 0;
        END IF;

        BEGIN
          INSERT INTO cecred.crapaut
            (crapaut.cdcooper
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.dtmvtolt
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.hrautent
            ,crapaut.vldocmto
            ,crapaut.nrdocmto
            ,crapaut.tpoperac
            ,crapaut.cdstatus
            ,crapaut.estorno
            ,crapaut.nrseqaut
            ,crapaut.cdhistor)
          VALUES
            (pr_cooper
            ,pr_cod_agencia
            ,pr_nro_caixa
            ,vc_dtmvtocd
            ,vr_sequen
            ,pr_cod_operador
            ,GENE0002.fn_busca_time
            ,pr_valor
            ,pr_docto
            ,vr_operacao
            ,pr_status
            ,vr_estorno
            ,vr_seq_aut
            ,pr_histor)
           RETURNING
            crapaut.ROWID
           INTO
            rw_crapaut.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
    ELSE
      OPEN cr_crapaut_sequen (pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_dtmvtolt => pr_data_off
                             ,pr_nrsequen => pr_sequen_off);
      FETCH cr_crapaut_sequen INTO rw_crapaut;
      IF cr_crapaut_sequen%NOTFOUND THEN
        CLOSE cr_crapaut_sequen;

        IF pr_estorno THEN
          vr_estorno:= 1;
        ELSE
          vr_estorno:= 0;
        END IF;
        IF pr_operacao THEN
          vr_operacao:= 1;
        ELSE
          vr_operacao:= 0;
        END IF;

        BEGIN
          INSERT INTO cecred.crapaut
            (crapaut.cdcooper
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.dtmvtolt
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.hrautent
            ,crapaut.vldocmto
            ,crapaut.nrdocmto
            ,crapaut.tpoperac
            ,crapaut.cdstatus
            ,crapaut.estorno
            ,crapaut.nrseqaut
            ,crapaut.cdhistor)
          VALUES
            (pr_cooper
            ,pr_cod_agencia
            ,pr_nro_caixa
            ,pr_data_off
            ,pr_sequen_off
            ,pr_cod_operador
            ,pr_hora_off
            ,pr_valor
            ,pr_docto
            ,vr_operacao
            ,pr_status
            ,vr_estorno
            ,pr_seq_aut_off
            ,pr_histor)
           RETURNING
           crapaut.ROWID
           INTO
           rw_crapaut.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;
      IF cr_crapaut_sequen%ISOPEN THEN
        CLOSE cr_crapaut_sequen;
      END IF;
    END IF;

    IF pr_data_off IS NULL THEN
      IF pr_cod_agencia <> 90 AND
         pr_cod_agencia <> 91 THEN
      IF nvl(rw_crapcbl.blidenti, ' ') <> ' ' THEN
        BEGIN
          UPDATE cecred.crapaut SET crapaut.blidenti = rw_crapcbl.blidenti
                            ,crapaut.blsldini = rw_crapcbl.vlinicial
                            ,crapaut.bltotpag = rw_crapcbl.vlcompdb
                            ,crapaut.bltotrec = rw_crapcbl.vlcompcr
                            ,crapaut.blvalrec = (rw_crapcbl.vlinicial + rw_crapcbl.vlcompdb - rw_crapcbl.vlcompcr)
          WHERE crapaut.ROWID = rw_crapaut.ROWID
          RETURNING
             crapaut.blsldini
            ,crapaut.bltotpag
            ,crapaut.bltotrec
            ,crapaut.blvalrec
          INTO
             rw_crapaut.blsldini
            ,rw_crapaut.bltotpag
            ,rw_crapaut.bltotrec
            ,rw_crapaut.blvalrec;
        EXCEPTION
          WHEN Others THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao atualizar tabela crapcbl. '||sqlerrm;
           RAISE vr_exc_erro;
        END;
      END IF;
    END IF;
    END IF;
    pr_registro:= rw_crapaut.rowid;

    pc_obtem_literal_autenticacao (pr_cooper   => pr_cooper
                                  ,pr_registro => rw_crapaut.rowid
                                  ,pr_literal  => vr_literal
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    pr_literal := vr_literal;

    BEGIN
      UPDATE cecred.crapaut SET crapaut.dslitera = vr_literal
      WHERE crapaut.ROWID = rw_crapaut.ROWID;
    EXCEPTION
      WHEN Others THEN
       vr_cdcritic:= 0;
       vr_dscritic:= 'Erro ao atualizar tabela crapaut. '||sqlerrm;
       RAISE vr_exc_erro;
    END;

  EXCEPTION
     WHEN vr_exc_erro THEN
       pr_cdcritic:= vr_cdcritic;
       pr_dscritic:= vr_dscritic;
     WHEN OTHERS THEN
       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro na rotina CXON0000.pc_grava_autenticacao. '||SQLERRM;
  END pc_grava_autenticacao;
  
BEGIN
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vc_diretorio
                          ,pr_nmarquiv => 'log_ajuste_corretivo.log'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqlog
                          ,pr_des_erro => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20001,'Erro ao abrir o arquivo de log para escrita: '||vr_dscritic);
  END IF;
    
  IF NOT utl_file.IS_OPEN(vr_arqlog) THEN
    raise_application_error(-20002,'Arquivo de log não está aberto para escrita de dados.');
  END IF;

  FOR caixa IN cr_caixas(1) LOOP
    
    FOR lanc IN cr_lancamento(caixa.cdcooper,caixa.cdagenci,caixa.nrdcaixa) LOOP
      BEGIN
        UPDATE cecred.crapaut t
           SET t.tpoperac = 0
         WHERE ROWID = lanc.dsdrowid;
         
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                        ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Autenticação ajustada('||caixa.cdcooper||'/'||caixa.cdagenci||'/'||caixa.nrdcaixa||'): '||lanc.dsdrowid);
      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                        ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Erro ao ajustar autenticação('||caixa.cdcooper||'/'||caixa.cdagenci||'/'||caixa.nrdcaixa||'): '||SQLERRM);
          CONTINUE;
      END;
    END LOOP;
  
  END LOOP;
  
  COMMIT;
  gene0001.pc_fecha_arquivo(vr_arqlog);
  
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vc_diretorio
                          ,pr_nmarquiv => 'log_ajuste_corretivo.log'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqlog
                          ,pr_des_erro => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20003,'Erro ao abrir o arquivo de log para escrita: '||vr_dscritic);
  END IF;
    
  IF NOT utl_file.IS_OPEN(vr_arqlog) THEN
    raise_application_error(-20004,'Arquivo de log não está aberto para escrita de dados.');
  END IF;
  
  FOR caixa IN cr_caixas(0) LOOP
    
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                  ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Gerando autenticações da cooperativa: '||caixa.cdcooper);
  
    FOR autentica IN cr_sem_autenticacao(caixa.cdcooper, caixa.cdagenci, caixa.nrdcaixa) LOOP
      
      BEGIN
        
        IF autentica.indebcre = 'C' THEN
          vr_operacao := FALSE;
        ELSE
          vr_operacao := TRUE;
        END IF;
      
        pc_grava_autenticacao(pr_cooper       => caixa.cdcooper
                             ,pr_cod_agencia  => caixa.cdagenci
                             ,pr_nro_caixa    => caixa.nrdcaixa
                             ,pr_cod_operador => caixa.cdoperad
                             ,pr_valor        => autentica.vldocmto
                             ,pr_docto        => autentica.nrdocmto
                             ,pr_operacao     => vr_operacao
                             ,pr_status       => 1
                             ,pr_estorno      => FALSE
                             ,pr_histor       => autentica.cdhistor
                             ,pr_data_off     => NULL
                             ,pr_sequen_off   => 0
                             ,pr_hora_off     => 0
                             ,pr_seq_aut_off  => 0
                             ,pr_literal      => vr_literal  
                             ,pr_sequencia    => vr_sequencia
                             ,pr_registro     => vr_registro 
                             ,pr_cdcritic     => vr_cdcritic 
                             ,pr_dscritic     => vr_dscritic );
        
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          IF TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          raise_application_error(-20003,'Erro gravar autenticação('||autentica.cdcooper||'/'||autentica.nrdconta||'): '||vr_cdcritic||' - '||vr_dscritic);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20004,'Erro pc_grava_autenticacao('||autentica.cdcooper||'/'||autentica.nrdconta||'): '||SQLERRM);
      END;
      
      BEGIN
        UPDATE cecred.craplcx lcx
           SET lcx.nrautdoc = vr_sequencia
         WHERE ROWID = autentica.dsdrowid;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20005,'Erro ao atualizar lancamento('||autentica.dsdrowid||'): '||SQLERRM);
      END;
      
    END LOOP;
  
    COMMIT;
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                  ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Autenticações geradas para a cooperativa: '||caixa.cdcooper);
  
  END LOOP;
  
  COMMIT;
  gene0001.pc_fecha_arquivo(vr_arqlog);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    vr_dscritic := 'Erro no processamento do script: '||SQLERRM;
                                  
    IF UTL_FILE.is_open(vr_arqlog) THEN
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                    ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - '||vr_dscritic);
      gene0001.pc_fecha_arquivo(vr_arqlog);
    END IF;
    
    raise_application_error(-20000,vr_dscritic);
END;
