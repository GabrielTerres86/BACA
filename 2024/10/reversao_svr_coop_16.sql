DECLARE

  vc_cdcooper       CONSTANT NUMBER := 16;
  vc_cdhistor_PF    CONSTANT NUMBER := 4598;
  vc_cdhistor_PJ    CONSTANT NUMBER := 4599;
  vc_cdhistor_caixa CONSTANT NUMBER := 4600;
  vc_cdoperad       CONSTANT VARCHAR2(20) := 'f0033918';
  vc_diretorio      CONSTANT VARCHAR2(100) := gene0001.fn_diretorio('M',0)||'cpd/bacas/RITM0429819';
  vc_separador      CONSTANT VARCHAR2(20) := ';';

  CURSOR cd_cooperativa IS
    SELECT cop.cdcooper
         , dat.dtmvtolt
         , dat.dtmvtocd
         , DECODE(cop.cdcooper, 1,  1,  2, 14,  5,  9
                              , 6,  2,  7,  1,  8,  1
                              , 9,  1, 10,  3, 11, 95
                              , 12, 1, 13,  1, 14,  1, 16, 1) cdagenci
         , DECODE(cop.cdcooper, 1,  3,  2,  5,  5,  4
                              , 6,  1,  7,100,  8, 22
                              , 9,  7, 10,  1, 11,  1
                              , 12,10, 13,  6, 14, 10, 16, 24) nrdcaixa
         , DECODE(cop.cdcooper, 1,vc_cdoperad, 2,vc_cdoperad, 3,vc_cdoperad, 4,vc_cdoperad
                              , 5,vc_cdoperad, 6,vc_cdoperad, 7,vc_cdoperad, 8,'f0080032'
                              , 9,vc_cdoperad,10,vc_cdoperad,11,vc_cdoperad,12,vc_cdoperad
                              ,13,vc_cdoperad,14,vc_cdoperad,15,vc_cdoperad,16,'f0160008'
                              ,17,vc_cdoperad) cdoperad
      FROM crapcop cop
     INNER JOIN crapdat dat
        ON dat.cdcooper = cop.cdcooper
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3
       AND cop.cdcooper = vc_cdcooper;

  CURSOR cr_retorno_full IS
    SELECT dev.ROWID dsdrowid
         , dev.cdcooper
         , dev.nrdconta
         , dev.vldsaldo
         , dev.dtcreant
         , decode(ass.inpessoa,1,vc_cdhistor_PF, vc_cdhistor_PJ) cdhistor
         , 0 iddifval
      FROM contacorrente.tbcc_controle_devolucoes dev
     INNER JOIN cecred.crapass ass
        ON ass.cdcooper = dev.cdcooper
       AND ass.nrdconta = dev.nrdconta
     WHERE dev.cdcooper = vc_cdcooper;

  TYPE tb_registros IS TABLE OF cr_retorno_full%ROWTYPE INDEX BY BINARY_INTEGER;
  vr_tbregistros    tb_registros;

  CURSOR cr_valor(pr_cdcooper NUMBER
                 ,pr_nrdconta NUMBER) IS
    SELECT dev.ROWID dsdrowid
         , dev.cdcooper
         , dev.nrdconta
         , dev.vldsaldo
         , dev.dtcreant
         , decode(ass.inpessoa,1,vc_cdhistor_PF, vc_cdhistor_PJ) cdhistor
         , 0 iddifval
      FROM contacorrente.tbcc_controle_devolucoes dev
     INNER JOIN cecred.crapass ass
        ON ass.cdcooper = dev.cdcooper
       AND ass.nrdconta = dev.nrdconta
     WHERE dev.cdcooper = pr_cdcooper
       AND dev.nrdconta = pr_nrdconta;
  rw_valor  cr_valor%ROWTYPE;

  CURSOR cr_crapbcx(pr_cdcooper  NUMBER
                   ,pr_dtmvtocd  DATE
                   ,pr_cdagenci  NUMBER
                   ,pr_nrdcaixa  NUMBER
                   ,pr_cdoperad  VARCHAR2) IS
    SELECT bcx.nrdmaqui
      FROM crapbcx bcx
     WHERE bcx.cdcooper = pr_cdcooper
       AND bcx.dtmvtolt = pr_dtmvtocd
       AND bcx.cdagenci = pr_cdagenci
       AND bcx.nrdcaixa = pr_nrdcaixa
       AND bcx.cdopecxa = pr_cdoperad
       AND bcx.cdsitbcx = 1;
  rw_crapbcx     cr_crapbcx%ROWTYPE;
  
  vr_nrdrowid    ROWID;

  vr_literal     VARCHAR2(100);
  vr_sequencia   INTEGER;
  vr_registro    ROWID;
  vr_nrdocmto    NUMBER;
  vr_vltotcop    NUMBER := 0;
  vr_nrseqdig    NUMBER;
  vr_cdcritic    INTEGER;
  vr_dscritic    VARCHAR2(2000);
  vr_operacao    BOOLEAN;

  vr_arqbase     UTL_FILE.file_type;
  vr_arqlog      UTL_FILE.file_type;
  vr_linha_arq   VARCHAR2(100);
  vr_arqcoop     NUMBER;
  vr_arqconta    NUMBER;
  vr_arqvalor    NUMBER;
  vr_nrlinha     NUMBER;
  vr_vet_dados   gene0002.typ_split;
  vc_dtmvtocd    DATE;
  
  TYPE typ_tab_mes IS VARRAY(12) OF VARCHAR2(3);

  vr_tab_mes typ_tab_mes:= typ_tab_mes('JAN','FEV','MAR','ABR','MAI','JUN',
                                       'JUL','AGO','SET','OUT','NOV','DEZ');

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
    FROM crapaut
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
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

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
      FROM crapage
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
      FROM crapaut
      WHERE ROWID = pr_rowid;
    rw_crapaut cr_crapaut%ROWTYPE;

    CURSOR cr_crapscn (pr_cdempres IN crapscn.cdempres%type) IS
      SELECT crapscn.cdempres
            ,crapscn.dssigemp
      FROM crapscn
      WHERE crapscn.cdempres = pr_cdempres;
    rw_crapscn cr_crapscn%ROWTYPE;

    CURSOR cr_crapstn (pr_cdempres IN crapstn.cdempres%type) IS
      SELECT crapstn.cdtransa
      FROM crapstn
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
      FROM crapcbl
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
      FROM crapaut
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
      FROM crapaut
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
          INSERT INTO crapcbl
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
          UPDATE crapcbl SET crapcbl.vlcompdb = rw_crapcbl.vlcompdb
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
          INSERT INTO crapaut
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
          INSERT INTO crapaut
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
          INSERT INTO crapaut
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
          UPDATE crapaut SET crapaut.blidenti = rw_crapcbl.blidenti
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
      UPDATE crapaut SET crapaut.dslitera = vr_literal
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

  FOR coop IN cd_cooperativa LOOP

    vr_tbregistros.delete;
    
    vc_dtmvtocd := coop.dtmvtocd;

    OPEN  cr_crapbcx(coop.cdcooper, coop.dtmvtocd, coop.cdagenci, coop.nrdcaixa, coop.cdoperad);
    FETCH cr_crapbcx INTO rw_crapbcx;

    IF cr_crapbcx%NOTFOUND THEN
      CLOSE cr_crapbcx;
      vr_cdcritic := 698;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      raise_application_error(-20005,vr_cdcritic||' - '||vr_dscritic);
    END IF;

    CLOSE cr_crapbcx;

    gene0001.pc_abre_arquivo(pr_nmdireto => vc_diretorio
                            ,pr_nmarquiv => 'log_processo_'||LPAD(coop.cdcooper,2,'0')||'.log'
                            ,pr_tipabert => 'A'
                            ,pr_utlfileh => vr_arqlog
                            ,pr_des_erro => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20010,'Erro ao abrir o arquivo de log para escrita: '||vr_dscritic);
    END IF;

    IF NOT utl_file.IS_OPEN(vr_arqlog) THEN
      raise_application_error(-20011,'Arquivo de log não está aberto para escrita de dados.');
    END IF;

    vr_nrlinha := 0;

    gene0001.pc_abre_arquivo(pr_nmdireto => vc_diretorio
                            ,pr_nmarquiv => 'base_reversao_'||LPAD(coop.cdcooper,2,'0')||'.txt'
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_arqbase
                            ,pr_des_erro => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20012,'Erro ao abrir o arquivo de reversão: '||vr_dscritic);
    END IF;

    IF NOT utl_file.IS_OPEN(vr_arqbase) THEN
      raise_application_error(-20013,'Arquivo de reversão não está aberto para consulta e processamento.');
    END IF;

    LOOP

      BEGIN
        vr_nrlinha := NVL(vr_nrlinha,0) + 1;
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqbase
                                    ,pr_des_text => vr_linha_arq);
        vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,chr(10),NULL),chr(13),NULL);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          EXIT;
        WHEN OTHERS THEN
          raise_application_error(-20014,'Erro ao ler linha '||vr_nrlinha||' do arquivo.');
      END;

      IF TRIM(vr_linha_arq) IS NULL THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Linha em branco.');
        CONTINUE;
      END IF;

      BEGIN
        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_linha_arq, pr_delimit => vc_separador);

        vr_arqcoop  := to_number(TRIM(vr_vet_dados(1)));
        
        IF vr_nrlinha = 1 AND TRIM(vr_vet_dados(2)) = '*' THEN
          FOR reg IN cr_retorno_full LOOP
            vr_tbregistros(vr_tbregistros.count() + 1) := reg;
          END LOOP;
          EXIT;
        ELSIF vr_nrlinha > 1 AND TRIM(vr_vet_dados(2)) = '*' THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                        ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Valor inválido informado para a linha. ');
          CONTINUE;
        ELSE
          vr_arqconta := to_number(TRIM(vr_vet_dados(2)));
          vr_arqvalor := gene0002.fn_char_para_number(TRIM(vr_vet_dados(3)));
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                        ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Erro ao quebrar linha. '||SQLERRM);
          CONTINUE;
      END;

      IF vc_cdcooper <> vr_arqcoop THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Cooperativa do script, diferente da cooperativa do arquivo.');
        CONTINUE;
      END IF;

      OPEN  cr_valor(vr_arqcoop,vr_arqconta);
      FETCH cr_valor INTO rw_valor;

      IF cr_valor%NOTFOUND THEN
        CLOSE cr_valor;

        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Dados de valores a reverter não encontrados para a conta '||vr_arqconta);
        CONTINUE;
      END IF;

      CLOSE cr_valor;

      IF rw_valor.vldsaldo <= 0 THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Valor de reversão da conta '||vr_arqconta||' zerado.');

        CONTINUE;
      ELSIF NVL(vr_arqvalor,0) = 0 THEN
        vr_arqvalor := rw_valor.vldsaldo;
      ELSIF rw_valor.vldsaldo < vr_arqvalor THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                      ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - Linha('||LPAD(vr_nrlinha,6,' ')||'): Valor retido da conta '||vr_arqconta||' menor que o solicitado para reversão. Arquivo: '||vr_arqvalor||' - Conta: '||rw_valor.vldsaldo);

      ELSE
        IF rw_valor.vldsaldo <> vr_arqvalor THEN
          rw_valor.iddifval := 1;
        END IF;
        rw_valor.vldsaldo := vr_arqvalor;
      END IF;

      vr_tbregistros(vr_tbregistros.count() + 1) := rw_valor;

    END LOOP;

    IF vr_tbregistros.count() = 0 THEN
      raise_application_error(-20020,'NENHUM REGISTRO ENCONTRADO PARA PROCESSAMENTO.');
    END IF;

    FOR ind IN vr_tbregistros.FIRST..vr_tbregistros.LAST LOOP
      vr_vltotcop := NVL(vr_vltotcop,0) + NVL(vr_tbregistros(ind).vldsaldo,0);
    END LOOP;

    vr_nrdocmto := gene0002.fn_busca_time;

    BEGIN

      pc_grava_autenticacao(pr_cooper       => coop.cdcooper
                           ,pr_cod_agencia  => coop.cdagenci
                           ,pr_nro_caixa    => coop.nrdcaixa
                           ,pr_cod_operador => coop.cdoperad
                           ,pr_valor        => vr_vltotcop
                           ,pr_docto        => vr_nrdocmto
                           ,pr_operacao     => FALSE
                           ,pr_status       => 1
                           ,pr_estorno      => FALSE
                           ,pr_histor       => vc_cdhistor_caixa
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
        raise_application_error(-20007,'Erro gravar autenticação('||coop.cdcooper||'): '||vr_cdcritic||' - '||vr_dscritic);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20008,'Erro pc_grava_autenticacao('||coop.cdcooper||'): '||SQLERRM);
    END;

    vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRSEQDIG'
                              ,pr_dsdchave => to_char(coop.cdcooper)
                              ,pr_flgdecre => 'N');
    BEGIN
      INSERT INTO craplcx(cdagenci
                         ,cdhistor
                         ,cdopecxa
                         ,dtmvtolt
                         ,nrdcaixa
                         ,nrdmaqui
                         ,nrdocmto
                         ,nrseqdig
                         ,vldocmto
                         ,dsdcompl
                         ,nrautdoc
                         ,cdcooper
                         ,nrdconta)
                  VALUES (coop.cdagenci
                         ,vc_cdhistor_caixa
                         ,coop.cdoperad
                         ,coop.dtmvtolt
                         ,coop.nrdcaixa
                         ,rw_crapbcx.nrdmaqui
                         ,vr_nrdocmto
                         ,vr_nrseqdig
                         ,vr_vltotcop
                         ,'REVERSAO - VALORES A DEVOLVER'
                         ,vr_sequencia
                         ,coop.cdcooper
                         ,0);

    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20009,'Erro incluir lançamento craplcx('||coop.cdcooper||'): '||SQLERRM);
    END;

    FOR ind IN vr_tbregistros.FIRST..vr_tbregistros.LAST LOOP

      IF vr_tbregistros(ind).iddifval = 0 THEN
        BEGIN
          UPDATE cecred.tbcotas_devolucao dev
             SET dev.dtinicio_credito = vr_tbregistros(ind).dtcreant
               , dev.vlpago           = (dev.vlpago - vr_tbregistros(ind).vldsaldo)
           WHERE dev.cdcooper         = vr_tbregistros(ind).cdcooper
             AND dev.nrdconta         = vr_tbregistros(ind).nrdconta
             AND dev.tpdevolucao      = 4;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20001,'Erro ao atualizar tbcotas_devolucao('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||SQLERRM);
        END;

        BEGIN
          DELETE contacorrente.tbcc_controle_devolucoes
           WHERE ROWID = vr_tbregistros(ind).dsdrowid;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20022,'Erro ao excluir tbcc_controle_devolucoes('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||SQLERRM);
        END;
      ELSE
        BEGIN
          UPDATE cecred.tbcotas_devolucao dev
             SET dev.vlpago           = (dev.vlpago - vr_tbregistros(ind).vldsaldo)
           WHERE dev.cdcooper         = vr_tbregistros(ind).cdcooper
             AND dev.nrdconta         = vr_tbregistros(ind).nrdconta
             AND dev.tpdevolucao      = 4;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20021,'Erro ao atualizar tbcotas_devolucao('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||SQLERRM);
        END;

        BEGIN
          UPDATE contacorrente.tbcc_controle_devolucoes t
             SET t.vldsaldo = t.vldsaldo - vr_tbregistros(ind).vldsaldo
           WHERE ROWID      = vr_tbregistros(ind).dsdrowid;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20002,'Erro ao incluir tbcc_controle_devolucoes('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||SQLERRM);
        END;
      END IF;

      geralog(pr_cdcooper => vr_tbregistros(ind).cdcooper
             ,pr_nrdconta => vr_tbregistros(ind).nrdconta
             ,pr_cdoperad => coop.cdoperad
             ,pr_dscritic => NULL
             ,pr_dsorigem => 'SCRIPT'
             ,pr_dstransa => 'Reversão da Captação de Recursos Esquecidos para União conf. Lei 14973/23 arts. 45-47'
             ,pr_dttransa => TRUNC(SYSDATE)
             ,pr_flgtrans => 1
             ,pr_hrtransa => gene0002.fn_busca_time
             ,pr_idseqttl => 1
             ,pr_nmdatela => 'ATENDA'
             ,pr_nrdrowid => vr_nrdrowid);

      geralogitem(pr_nrdrowid => vr_nrdrowid
                 ,pr_nmdcampo => 'Valor Total Revertido'
                 ,pr_dsdadant => vr_tbregistros(ind).vldsaldo
                 ,pr_dsdadatu => 0);

      vr_nrdocmto := gene0002.fn_busca_time;

      BEGIN

        pc_grava_autenticacao(pr_cooper       => vr_tbregistros(ind).cdcooper
                             ,pr_cod_agencia  => coop.cdagenci
                             ,pr_nro_caixa    => coop.nrdcaixa
                             ,pr_cod_operador => coop.cdoperad
                             ,pr_valor        => vr_tbregistros(ind).vldsaldo
                             ,pr_docto        => vr_nrdocmto
                             ,pr_operacao     => TRUE
                             ,pr_status       => 1
                             ,pr_estorno      => FALSE
                             ,pr_histor       => vr_tbregistros(ind).cdhistor
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
          raise_application_error(-20003,'Erro gravar autenticação('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||vr_cdcritic||' - '||vr_dscritic);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20004,'Erro pc_grava_autenticacao('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||SQLERRM);
      END;

      vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(vr_tbregistros(ind).cdcooper)
                                ,pr_flgdecre => 'N');

      BEGIN
        INSERT INTO craplcx(cdagenci
                           ,cdhistor
                           ,cdopecxa
                           ,dtmvtolt
                           ,nrdcaixa
                           ,nrdmaqui
                           ,nrdocmto
                           ,nrseqdig
                           ,vldocmto
                           ,dsdcompl
                           ,nrautdoc
                           ,cdcooper
                           ,nrdconta)
                    VALUES (coop.cdagenci
                           ,vr_tbregistros(ind).cdhistor
                           ,coop.cdoperad
                           ,coop.dtmvtolt
                           ,coop.nrdcaixa
                           ,rw_crapbcx.nrdmaqui
                           ,vr_nrdocmto
                           ,vr_nrseqdig
                           ,vr_tbregistros(ind).vldsaldo
                           ,'Agencia: ' || LPAD(coop.cdagenci,3,'0') || ' Conta/DV: ' || LPAD(vr_tbregistros(ind).nrdconta,8,'0')
                           ,vr_sequencia
                           ,vr_tbregistros(ind).cdcooper
                           ,vr_tbregistros(ind).nrdconta);

      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20006,'Erro incluir lançamento craplcx('||vr_tbregistros(ind).cdcooper||'/'||vr_tbregistros(ind).nrdconta||'): '||SQLERRM);
      END;

    END LOOP;

  END LOOP;

  COMMIT;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqbase);

  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arqlog
                                ,pr_des_text => to_char(SYSDATE,'hh24:mi:ss')||' - PROCESSAMENTO DE REVERSÃO DA COOPERATIVA '||vc_cdcooper||' ENCERRADO.');

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqlog);

END;
