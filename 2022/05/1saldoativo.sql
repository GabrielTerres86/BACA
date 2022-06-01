DECLARE 
    
    vr_excsaida    EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_nraplica    craprac.nraplica%TYPE;
    vr_nmarqimp1   VARCHAR2(100)  := 'backup_inc325287.txt';
    vr_ind_arquiv1 utl_file.file_type;   
    vr_rootmicros  VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto    VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/335378inc133992'; 
    vr_exc_saida EXCEPTION;
    vr_tpcritic crapcri.cdcritic%TYPE;
    vr_nrseqrgt craprga.nrseqrgt%TYPE := 0;
    vr_dtvencto DATE;
    vr_vlindicecorrecao         NUMBER  := 0;
    vr_txinicioperiodorentab    NUMBER  := 0;
    pr_vlrentabilidade_acumulada NUMBER := 0;
    vr_vlbasecalculo_corrigida  NUMBER;
    vr_aniver integer;
   
    CURSOR cr_craprac is
      SELECT distinct ((SELECT NVL(sum(l.vllanmto),0)
                       FROM cecred.craplac l
                      WHERE l.cdhistor in (3527,  3532)
                        AND l.cdcooper = lac.cdcooper
                        AND l.nrdconta = lac.nrdconta
                        AND l.nraplica = lac.nraplica)) -
                    ((SELECT NVL(SUM(l.vllanmto),0)
                       FROM  cecred.craplac l
                      WHERE l.cdhistor in (3528)
                        AND l.cdcooper = lac.cdcooper
                        AND l.nrdconta = lac.nrdconta
                        AND l.nraplica = lac.nraplica)) vllanmto,
                    rac.idsaqtot,
                    rac.nrdconta,
                    rac.nraplica,
                    rac.cdcooper,
                    rac.vlsldatl,
                    rac.dtaniver
      FROM  cecred.craprac rac, 
            cecred.craplac lac
     WHERE rac.cdcooper = lac.cdcooper
       AND rac.nrdconta = lac.nrdconta
       AND rac.nraplica = lac.nraplica
       AND rac.dtmvtolt in 
         ( 
           to_date('29/11/2021', 'dd/mm/yyyy'),
           to_date('30/11/2021', 'dd/mm/yyyy'),
           to_date('27/10/2021', 'dd/mm/yyyy'),
           to_date('28/10/2021', 'dd/mm/yyyy'),
           to_date('28/12/2021', 'dd/mm/yyyy'),
           to_date('28/01/2022', 'dd/mm/yyyy')
         ) 
       AND lac.cdcooper in (1, 16)      
       AND rac.cdprodut = 1109
       AND rac.idsaqtot = 0;
              
       rw_craprac cr_craprac%ROWTYPE;
        
    CURSOR cr_backup(pr_cdcooper craprac.cdcooper%TYPE
                    ,pr_nrdconta craprac.nrdconta%TYPE
                    ,pr_nraplica craprac.nraplica%TYPE) IS
                                      
       SELECT rac.cdcooper,
              rac.nrdconta,
              rac.nraplica,
              rac.dtatlsld,
              rac.vlsldatl,
              rac.vlsldant, 
              rac.dtsldant
         FROM  cecred.craprac rac
        WHERE rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND rac.nraplica = pr_nraplica;
       rw_backup cr_backup%ROWTYPE;
       
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       
    PROCEDURE backup_arquivo (pr_msg VARCHAR2) IS
    BEGIN
       gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
    END; 
  
    PROCEDURE fecha_arquivo IS 
    BEGIN
       gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
    END;                                
 PROCEDURE pc_cadastra_aplic(pr_cdcooper IN craprac.cdcooper%TYPE   
                             ,pr_cdoperad IN crapope.cdoperad%TYPE 
                             ,pr_nmdatela IN craptel.nmdatela%TYPE   
                             ,pr_idorigem IN INTEGER
                             ,pr_nrdconta IN craprac.nrdconta%TYPE
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE
                             ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE
                             ,pr_qtdiaapl IN INTEGER              
                             ,pr_dtvencto IN DATE                 
                             ,pr_qtdiacar IN INTEGER              
                             ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE
                             ,pr_vlaplica IN NUMBER               
                             ,pr_iddebcti IN INTEGER              
                             ,pr_idorirec IN INTEGER              
                             ,pr_idgerlog IN INTEGER              
                             ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0
                             ,pr_nraplica OUT craprac.nraplica%TYPE     
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS 
  BEGIN

    DECLARE

      
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      
      vr_exc_saida EXCEPTION;

      
      vr_des_erro VARCHAR2(1000);

      
      vr_dtmvtopr DATE;       
      vr_retorno  VARCHAR2(3); 
      vr_percenir NUMBER:= 0;  
      vr_qtdfaxir INTEGER:= 0;
      vr_vltotrda craprda.vlsdrdca%TYPE := 0;
      vr_txaplica craplap.txaplica%TYPE;
      vr_txaplmes craplap.txaplmes%TYPE;
      vr_nraplica craprac.nraplica%TYPE;
      vr_cdnomenc craprac.cdnomenc%TYPE;
      vr_tpaplacu VARCHAR2(100);
      vr_cdhistor craplac.cdhistor%TYPE;
      vr_rowidtab ROWID;

      vr_dsinfor1 VARCHAR2(1000);
      vr_dsinfor2 VARCHAR2(1000);
      vr_dsinfor3 VARCHAR2(1000);
      vr_nmextttl crapttl.nmextttl%TYPE;
      vr_nmcidade crapage.nmcidade%TYPE;
      vr_dsprotoc crappro.dsprotoc%TYPE;
      vr_dsorigem VARCHAR2(500) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa VARCHAR2(100) := 'Inclusao de aplicacao.';
      vr_nrdrowid ROWID;
      vr_dtaniver craprac.dtaniver%TYPE;
      vr_dtinical craprac.dtinical%TYPE;
      
      
      vr_dstextab_rdcpos craptab.dstextab%TYPE;
      vr_dtinitax     DATE;     
      vr_dtfimtax     DATE; 

     
      vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_tab_tpregist   APLI0001.typ_tab_tpregist;
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;

     
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);
      vr_index_acumula INTEGER;

      vr_incrineg      INTEGER;
      vr_tab_retorno   LANC0001.typ_reg_retorno;
      
      vr_notfound      boolean;
      vr_gbl_tentativa      NUMBER:=0;
      vr_gbl_total_vezes    NUMBER:=10;
      vr_gbl_achou_registro NUMBER:=0;

      
      CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrctactl
              ,cop.nmextcop
              ,cop.nrdocnpj
        FROM  cecred.crapcop cop
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     
      CURSOR cr_crapcpc (pr_cdprodut crapcpc.cdprodut%TYPE)IS
        SELECT cpc.cdprodut
              ,cpc.nmprodut
              ,cpc.idacumul
              ,cpc.idtippro
              ,cpc.cdhsrgap
              ,cpc.idtxfixa
              ,cpc.cdhsraap
              ,cpc.cdhsnrap
              ,cpc.cdhscacc
              ,ind.nmdindex
              ,cpc.cddindex
              ,cpc.indanive
          FROM  cecred.crapcpc cpc,
                cecred.crapind ind
         WHERE cpc.cddindex = ind.cddindex
               AND cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      
      CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                       ,pr_nrdconta IN craprda.nrdconta%TYPE
                       ,pr_nraplica IN craprda.nraplica%TYPE)IS

        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
          FROM  cecred.craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;

      rw_craprda cr_craprda%ROWTYPE;
 CURSOR cr_craplot_lock(pr_cdcooper IN craplot.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.cdcooper
              ,lot.dtmvtolt
              ,lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.nrseqdig
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.vlcompdb
              ,lot.vlinfodb
              ,lot.rowid
          FROM  cecred.craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot_lock%ROWTYPE;

     
      CURSOR cr_crapnpc (pr_cdprodut crapnpc.cdprodut%TYPE
                        ,pr_qtdiacar crapnpc.qtmincar%TYPE
                        ,pr_vlsldacu crapnpc.vlminapl%TYPE)IS
      SELECT
        npc.cdnomenc
       ,npc.dsnomenc
      FROM
         cecred.crapnpc npc
      WHERE
            npc.cdprodut  = pr_cdprodut
        AND npc.qtmincar <= pr_qtdiacar
        AND npc.qtmaxcar >= pr_qtdiacar
        AND npc.vlminapl <= pr_vlsldacu
        AND npc.vlmaxapl >= pr_vlsldacu
        AND npc.idsitnom  = 1;

      rw_crapnpc cr_crapnpc%ROWTYPE;

      
      CURSOR cr_crapmpc(pr_qtdiacar IN crapmpc.qtdiacar%TYPE
                       ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE 
                       ,pr_vlsldacu IN NUMBER               
                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE
                       ) IS
        SELECT
          mpc.cdmodali
         ,mpc.vltxfixa
         ,mpc.vlperren
        FROM
           cecred.crapmpc mpc
         , cecred.crapdpc dpc
        WHERE
              mpc.cdprodut  = pr_cdprodut 
          AND mpc.qtdiacar  = pr_qtdiacar
          AND mpc.qtdiaprz  = pr_qtdiaprz 
          AND mpc.vlrfaixa <= pr_vlsldacu 
          AND dpc.cdmodali  = mpc.cdmodali
          AND dpc.cdcooper  = pr_cdcooper
          AND dpc.idsitmod  = 1
        ORDER BY
          mpc.vlrfaixa DESC;

      rw_crapmpc cr_crapmpc%ROWTYPE;

      CURSOR cr_crapmpc_cont(pr_qtdiacar IN crapmpc.qtdiacar%TYPE
                            ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE
                            ,pr_cdprodut IN crapcpc.cdprodut%TYPE
                            ) IS
        SELECT COUNT(1) cont
          FROM  cecred.crapmpc mpc
              , cecred.crapdpc dpc
        WHERE mpc.cdprodut  = pr_cdprodut 
          AND mpc.qtdiacar  = pr_qtdiacar
          AND mpc.qtdiaprz  = pr_qtdiaprz 
          AND dpc.cdmodali  = mpc.cdmodali
          AND dpc.cdcooper  = pr_cdcooper 
          AND dpc.idsitmod  = 1;
      
      rw_crapmpc_cont cr_crapmpc_cont%ROWTYPE;

      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapres.nrdconta%TYPE) IS

        SELECT crapass.cdcooper
              ,crapass.cdagenci
              ,crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.inpessoa
        FROM  cecred.crapass crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta
        FOR UPDATE NOWAIT;
      rw_crapass cr_crapass%ROWTYPE;

      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
        FROM  cecred.crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;

      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT ttl.nmextttl
            ,ttl.nrcpfcgc
        FROM  cecred.crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;

      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM  cecred.craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.nrdconta = pr_nrdconta
         AND lpp.cdhistor IN (158,496)
         AND lpp.dtmvtolt > pr_dtmvtolt
         GROUP BY lpp.nrdconta
                 ,lpp.nrctrrpp;

      rw_craplpp cr_craplpp%ROWTYPE;

      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                              ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS

        SELECT craplrg.nrdconta,craplrg.nraplica,Count(*) qtlancmto
        FROM  cecred.craplrg craplrg
        WHERE craplrg.cdcooper = pr_cdcooper
        AND   craplrg.nrdconta = pr_nrdconta
        AND   craplrg.tpaplica = 4
        AND   craplrg.inresgat = 0
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica;

      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_nrdconta IN craplrg.nrdconta%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
        FROM  cecred.craplrg craplrg
        WHERE craplrg.cdcooper  = pr_cdcooper
        AND   craplrg.nrdconta  = pr_nrdconta
        AND   craplrg.dtresgat <= pr_dtresgat
        AND   craplrg.inresgat  = 0
        AND   craplrg.tpresgat  = 1
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica
                ,craplrg.tpaplica
                ,craplrg.tpresgat;

      CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE
                       ,pr_nrdconta IN crapsli.nrdconta%TYPE
                       ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS
        SELECT
          sli.cdcooper
         ,sli.nrdconta
         ,sli.dtrefere
         ,sli.vlsddisp
         ,sli.rowid
        FROM
           cecred.crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper
          AND sli.nrdconta = pr_nrdconta
          AND sli.dtrefere = pr_dtrefere;

      rw_crapsli cr_crapsli%ROWTYPE;

    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'APLI0005.pc_cadastra_aplic');

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      IF cr_crapcop%NOTFOUND THEN

        CLOSE cr_crapcop;
        vr_cdcritic:= 651;

        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE

        CLOSE cr_crapcop;
      END IF;

      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN

        CLOSE BTCH0001.cr_crapdat;
 
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
    
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
   
      vr_gbl_tentativa:=0;
      vr_gbl_achou_registro:=0;
      
      WHILE (vr_gbl_achou_registro=0) AND 
            (vr_gbl_tentativa < vr_gbl_total_vezes) 
      LOOP  
        BEGIN 
          vr_gbl_tentativa:=vr_gbl_tentativa+1;
         
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);

     
          rw_crapass := null;  
           FETCH cr_crapass INTO rw_crapass;
          vr_gbl_achou_registro:=1; 
          
          IF cr_crapass%NOTFOUND THEN
            CLOSE cr_crapass;
            vr_dscritic := 'Cooperado nao cadastrado.';
            RAISE vr_exc_saida;
          ELSE
            CLOSE cr_crapass;
          END IF;     
          
        EXCEPTION 
            WHEN OTHERS THEN 
             RAISE vr_exc_saida;               
          END; 
      END LOOP;
      
      OPEN cr_crapcpc(pr_cdprodut => pr_cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;

      IF rw_crapcpc.indanive = 1 THEN
         IF rw_crapcpc.cddindex = 6 THEN 
            vr_dtaniver := APLI0012.fn_proximo_aniv_poupanca(pr_dtaplica => rw_crapdat.dtmvtolt);
         ELSE 
            vr_dtaniver := apli0010.fn_proximo_aniversario(pr_dtaplica => rw_crapdat.dtmvtolt 
                                                          ,pr_dtaniver => rw_crapdat.dtmvtolt);
            vr_dtinical := rw_crapdat.dtmvtolt;
         END IF;
      ELSE
        vr_dtaniver := null;
      END IF;

      vr_vltotrda := NVL(vr_vltotrda,0) + NVL(pr_vlaplica,0);

      OPEN cr_crapnpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_vlsldacu => vr_vltotrda);

      FETCH cr_crapnpc INTO rw_crapnpc;

      IF cr_crapnpc%NOTFOUND THEN
        CLOSE cr_crapnpc;
        vr_cdnomenc := '0';
      ELSE
        CLOSE cr_crapnpc;
        vr_cdnomenc := rw_crapnpc.cdnomenc;
      END IF;

      OPEN cr_crapmpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_qtdiaprz => pr_qtdiaprz
                     ,pr_vlsldacu => vr_vltotrda);

      FETCH cr_crapmpc INTO rw_crapmpc;

      IF cr_crapmpc%NOTFOUND THEN
        CLOSE cr_crapmpc;

        vr_dscritic := 'Nao foi encontrada modalidade na política de captacao para o produto selecionado.';
        RAISE vr_exc_saida;
      ELSE

        CLOSE cr_crapmpc;
      END IF;

      IF pr_iddebcti = 1 THEN

        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => last_day(pr_dtmvtolt));         
        FETCH cr_crapsli INTO rw_crapsli;

        IF cr_crapsli%NOTFOUND THEN
          CLOSE cr_crapsli;
          vr_dscritic := 'Registro de saldo nao encontrado';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapsli;
        END IF;

        IF rw_crapsli.vlsddisp < pr_vlaplica THEN
          vr_dscritic := 'Saldo insuficiente';
          RAISE vr_exc_saida;
        END IF;

      END IF;

      LOOP

        vr_nraplica := fn_sequence(pr_nmtabela => 'CRAPRAC'
                                  ,pr_nmdcampo => 'NRAPLICA'
                                  ,pr_dsdchave => pr_cdcooper || ';' || pr_nrdconta
                                  ,pr_flgdecre => 'N');

        OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nraplica => vr_nraplica);

        FETCH cr_craprda INTO rw_craprda;

        IF cr_craprda%FOUND THEN
          CLOSE cr_craprda;
          CONTINUE;
        ELSE
          CLOSE cr_craprda;
          EXIT;
        END IF;

      END LOOP;

      IF rw_crapcpc.idtxfixa = 1 THEN
        vr_txaplica := rw_crapmpc.vltxfixa;
      ELSE
        vr_txaplica := rw_crapmpc.vlperren;
      END IF;

      BEGIN
        INSERT INTO  cecred.craprac(
          cdcooper
         ,nrdconta
         ,nraplica
         ,cdprodut
         ,cdnomenc
         ,dtmvtolt
         ,dtvencto
         ,dtatlsld
         ,vlaplica
         ,vlbasapl
         ,vlsldatl
         ,vlslfmes
         ,vlsldacu
         ,qtdiacar
         ,qtdiaprz
         ,qtdiaapl
         ,txaplica
         ,idsaqtot
         ,idblqrgt
         ,idcalorc
         ,nrctrrpp
         ,iddebcti
         ,cdoperad
         ,dtaniver
         ,dtinical)
        VALUES(
          pr_cdcooper
         ,pr_nrdconta
         ,vr_nraplica
         ,pr_cdprodut
         ,vr_cdnomenc
         ,pr_dtmvtolt
         ,pr_dtvencto
         ,pr_dtmvtolt
         ,pr_vlaplica
         ,pr_vlaplica
         ,pr_vlaplica
         ,pr_vlaplica
         ,vr_vltotrda
         ,pr_qtdiacar
         ,pr_qtdiaprz
         ,pr_qtdiaapl
         ,vr_txaplica
         ,0           
         ,0          
         ,0           
         ,pr_nrctrrpp 
         ,pr_iddebcti
         ,pr_cdoperad
         ,vr_dtaniver
         ,vr_dtinical) RETURNING nraplica, ROWID INTO vr_nraplica, vr_rowidtab;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro na CRAPRAC. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      pr_nraplica := vr_nraplica;

      vr_index_acumula := vr_tab_acumula.first;
      
       OPEN cr_craplot_lock(pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 100
                              ,pr_nrdolote => 8500);

      FETCH cr_craplot_lock INTO rw_craplot;
      
      IF cr_craplot_lock%NOTFOUND THEN
        CLOSE cr_craplot_lock;
        BEGIN
          INSERT INTO
             cecred.craplot(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,tplotmov
             ,nrseqdig
             ,qtinfoln
             ,qtcompln
             ,vlinfocr
             ,vlcompcr)
          VALUES(
            pr_cdcooper
           ,pr_dtmvtolt
           ,1
           ,100
           ,8500
           ,9
           ,1
           ,1
           ,1
           ,pr_vlaplica
           ,pr_vlaplica)
          RETURNING
            craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.cdbccxlt
           ,craplot.nrdolote
           ,craplot.nrseqdig
          INTO
            rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,rw_craplot.nrseqdig;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPLOT. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
      CLOSE cr_craplot_lock;
        BEGIN

          UPDATE
             cecred.craplot
          SET
            craplot.tplotmov = 9,
            craplot.nrseqdig = rw_craplot.nrseqdig + 1,
            craplot.qtinfoln = rw_craplot.qtinfoln + 1,
            craplot.qtcompln = rw_craplot.qtcompln + 1,
            craplot.vlinfocr = rw_craplot.vlinfocr + pr_vlaplica,
            craplot.vlcompcr = rw_craplot.vlcompcr + pr_vlaplica
          WHERE
            craplot.rowid = rw_craplot.rowid
          RETURNING
            craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.cdbccxlt
           ,craplot.nrdolote
           ,craplot.nrseqdig
          INTO
            rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,rw_craplot.nrseqdig;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar registro na CRAPLOT. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      IF pr_idorirec = 0 THEN 
        vr_cdhistor := rw_crapcpc.cdhsraap;
      ELSE
        vr_cdhistor := rw_crapcpc.cdhsnrap;
      END IF;

      BEGIN
        INSERT INTO
           cecred.craplac(
            cdcooper
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,nrdconta
           ,nraplica
           ,nrdocmto
           ,nrseqdig
           ,vllanmto
           ,cdhistor
           ,cdcanal
           ,cdoperad
        )VALUES(
           pr_cdcooper
          ,rw_craplot.dtmvtolt
          ,rw_craplot.cdagenci
          ,rw_craplot.cdbccxlt
          ,rw_craplot.nrdolote
          ,pr_nrdconta
          ,vr_nraplica
          ,vr_nraplica
          ,rw_craplot.nrseqdig
          ,pr_vlaplica
          ,vr_cdhistor
          ,pr_idorigem
          ,pr_cdoperad);

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro na CRAPLAC. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      IF pr_iddebcti = 1 THEN
                        
         OPEN cr_craplot_lock(pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 100
                              ,pr_nrdolote => 9900010106);
                         
       FETCH cr_craplot_lock INTO rw_craplot;
      
      IF cr_craplot_lock%NOTFOUND THEN
        CLOSE cr_craplot_lock;
          BEGIN
            INSERT INTO
               cecred.craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfodb
               ,vlcompdb)
            VALUES(
              pr_cdcooper
             ,pr_dtmvtolt
             ,1
             ,100
             ,9900010106 
             ,29
             ,1
             ,1
             ,1
             ,pr_vlaplica
             ,pr_vlaplica)
            RETURNING
              craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdbccxlt
             ,craplot.nrdolote
             ,craplot.nrseqdig
            INTO
              rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_craplot.nrseqdig;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPLOT. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSE
          CLOSE cr_craplot_lock;
          BEGIN

            UPDATE
               cecred.craplot
            SET
              craplot.tplotmov = 29,
              craplot.nrseqdig = rw_craplot.nrseqdig + 1,
              craplot.qtinfoln = rw_craplot.qtinfoln + 1,
              craplot.qtcompln = rw_craplot.qtcompln + 1,
              craplot.vlinfodb = rw_craplot.vlinfodb + pr_vlaplica,
              craplot.vlcompdb = rw_craplot.vlcompdb + pr_vlaplica
            WHERE
              craplot.rowid = rw_craplot.rowid
            RETURNING
              craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdbccxlt
             ,craplot.nrdolote
             ,craplot.nrseqdig
            INTO
              rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_craplot.nrseqdig;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro na CRAPLOT. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

        BEGIN
          INSERT INTO
             cecred.craplci(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdocmto
             ,nrseqdig
             ,vllanmto
             ,cdhistor
             ,nraplica
           )VALUES(
              pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,pr_nrdconta
             ,vr_nraplica
             ,rw_craplot.nrseqdig
             ,pr_vlaplica
             ,491
             ,vr_nraplica);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPLCI. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => rw_crapdat.dtultdia);

        FETCH cr_crapsli INTO rw_crapsli;

        IF cr_crapsli%NOTFOUND THEN

          CLOSE cr_crapsli;

          BEGIN

            INSERT INTO
               cecred.crapsli(
                cdcooper
               ,nrdconta
               ,dtrefere
               ,vlsddisp
              ) VALUES(
                pr_cdcooper
               ,pr_nrdconta
               ,rw_crapdat.dtultdia
               ,pr_vlaplica);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPSLI. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE

          CLOSE cr_crapsli;

          BEGIN

            UPDATE
               cecred.crapsli
            SET
              vlsddisp = rw_crapsli.vlsddisp - pr_vlaplica
            WHERE
              crapsli.rowid = rw_crapsli.rowid;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPSLI. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

      END IF; 

      IF rw_crapass.inpessoa = 1 THEN

        OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_idseqttl => pr_idseqttl);

        FETCH cr_crapttl INTO rw_crapttl;

        IF cr_crapttl%NOTFOUND THEN
 
          CLOSE cr_crapttl;

          vr_cdcritic:= 0;
          vr_dscritic:= 'Titular nao encontrado.';

          RAISE vr_exc_saida;
        END IF;

        CLOSE cr_crapttl;

        vr_nmextttl:= rw_crapttl.nmextttl;

      ELSE
        vr_nmextttl:= rw_crapass.nmprimtl;
      END IF;

      OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);

      FETCH cr_crapage INTO vr_nmcidade;

      IF cr_crapage%NOTFOUND THEN
      
        CLOSE cr_crapage;

        vr_cdcritic:= 962;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        RAISE vr_exc_saida;
      ELSE
        
        CLOSE cr_crapage;

      END IF;

      vr_dsinfor1:= 'Aplicacao';

      vr_dsinfor2:= vr_nmextttl ||'#' ||
                    'Conta/dv: ' ||pr_nrdconta ||' - '||
                    rw_crapass.nmprimtl||'#'|| gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                    ' - '|| rw_crapcop.nmrescop;

      vr_dsinfor3:= 'Data da Aplicacao: '   || TO_CHAR(pr_dtmvtolt,'dd/mm/RRRR')           || '#' ||
                    'Numero da Aplicacao: ' || TO_CHAR(vr_nraplica,'9G999G990')    || '#';
      IF rw_crapcpc.cddindex = 5
        THEN rw_crapcpc.nmdindex := 'IPCA';
      END IF;

      IF rw_crapcpc.idtxfixa = 1 THEN
        vr_dsinfor3:= vr_dsinfor3 || 'Taxa Contratada: ' || rw_crapcpc.nmdindex || ' + ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '%#' ||
                      'Taxa Minima: ' || rw_crapcpc.nmdindex || ' + ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '%#';
      
      ELSIF rw_crapcpc.cddindex = 6 THEN
        vr_dsinfor3:= vr_dsinfor3 || 'Taxa Contratada: ' || rw_crapcpc.nmdindex || '#' ||
                      'Taxa Minima: ' ||' ' || '#'; 
      ELSE
        vr_dsinfor3:= vr_dsinfor3 || 'Taxa Contratada: ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '% DO ' || rw_crapcpc.nmdindex || '#' ||
                      'Taxa Minima: ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '% DO ' || rw_crapcpc.nmdindex || '#';
      END IF;
      
      IF rw_crapcpc.cddindex = 6 THEN
        vr_dsinfor3:= vr_dsinfor3 || 'Vencimento: '        || ' '           || '#' ||
                                   'Carencia: '            || ' '           || '#' ||
                                   'Data da Carencia: '    || ' '           || '#' ||
                                   'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' ||
                                   'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' ||
                                   UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(pr_dtmvtolt,'dd') || ' DE ' ||
                                   GENE0001.vr_vet_nmmesano(TO_CHAR(pr_dtmvtolt,'mm')) || ' DE ' ||
                                   TO_CHAR(pr_dtmvtolt,'RRRR') || '#N#' || UPPER(nvl(rw_crapnpc.dsnomenc,rw_crapcpc.nmprodut));
      ELSE
      vr_dsinfor3:= vr_dsinfor3 || 'Vencimento: '          || TO_CHAR(pr_dtvencto,'dd/mm/yyyy')           || '#' ||
                                   'Carencia: '            || TO_CHAR(pr_qtdiacar,'99990') || ' DIA(S)'   || '#' ||
                                   'Data da Carencia: '    || TO_CHAR(pr_dtmvtolt + pr_qtdiacar,'dd/mm/RRRR') || '#' ||
                                   'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' ||
                                   'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' ||
                                   UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(pr_dtmvtolt,'dd') || ' DE ' ||
                                   GENE0001.vr_vet_nmmesano(TO_CHAR(pr_dtmvtolt,'mm')) || ' DE ' ||
                                   TO_CHAR(pr_dtmvtolt,'RRRR') || '#N#' || UPPER(nvl(rw_crapnpc.dsnomenc,rw_crapcpc.nmprodut));
      END IF;
      
      GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper                         
                                ,pr_dtmvtolt => pr_dtmvtolt                        
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) 
                                ,pr_nrdconta => pr_nrdconta                   
                                ,pr_nrdocmto => vr_nraplica                        
                                ,pr_nrseqaut => 0                                  
                                ,pr_vllanmto => pr_vlaplica                       
                                ,pr_nrdcaixa => pr_nrdcaixa                            
                                ,pr_gravapro => TRUE                              
                                ,pr_cdtippro => 10                                
                                ,pr_dsinfor1 => vr_dsinfor1                        
                                ,pr_dsinfor2 => vr_dsinfor2                     
                                ,pr_dsinfor3 => vr_dsinfor3                    
                                ,pr_dscedent => NULL                           
                                ,pr_flgagend => FALSE                           
                                ,pr_nrcpfope => 0                               
                                ,pr_nrcpfpre => 0                              
                                ,pr_nmprepos => ''                             
                                ,pr_dsprotoc => vr_dsprotoc                       
                                ,pr_dscritic => vr_dscritic                      
                                ,pr_des_erro => vr_des_erro);    

      IF vr_dscritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN

        RAISE vr_exc_saida;
      END IF;

      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'NRAPLICA'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => vr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRDOCMTO'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'DTRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(pr_dtvencto,'dd/MM/RRRR'));

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'VLAPLICA'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlaplica);

      END IF;      

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;      
        ROLLBACK;

        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          IF upper(pr_nmdatela) <> 'CRPS145' THEN
          COMMIT;
        END IF;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_cadastra_aplic: ' || SQLERRM;

        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          
          COMMIT;
        END IF;
    END;

  END pc_cadastra_aplic;
BEGIN 
     
  BEGIN
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto      
                            ,pr_nmarquiv => vr_nmarqimp1       
                            ,pr_tipabert => 'W'                
                            ,pr_utlfileh => vr_ind_arquiv1     
                            ,pr_des_erro => vr_dscritic);      
    IF vr_dscritic IS NOT NULL THEN 
      RAISE vr_excsaida; 
      END IF;
    END;
      
    
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

      
    IF btch0001.cr_crapdat%NOTFOUND THEN
        
      CLOSE btch0001.cr_crapdat;
         RAISE vr_exc_saida;
    ELSE
        CLOSE btch0001.cr_crapdat;
    END IF;
      
    FOR rw_craprac IN cr_craprac LOOP
       IF rw_craprac.vlsldatl <> rw_craprac.vllanmto THEN              
          OPEN cr_backup(pr_cdcooper => rw_craprac.cdcooper,
                         pr_nrdconta => rw_craprac.nrdconta, 
                         pr_nraplica => rw_craprac.nraplica);
                       
          FETCH cr_backup INTO rw_backup;
          backup_arquivo('UPDATE craprac SET dtatlsld ='||''''||rw_backup.dtatlsld||''''||',vlsldatl ='||replace(rw_backup.vlsldatl,',','.')  ||',vlsldant ='||replace(rw_backup.vlsldant,',','.')||',dtsldant ='||''''||rw_backup.dtsldant||''''||' WHERE nrdconta ='||rw_backup.nrdconta||' AND nraplica ='||rw_backup.nraplica||' AND cdcooper ='||rw_backup.cdcooper||';');                           
          CLOSE  cr_backup;         
          vr_aniver := EXTRACT(day FROM rw_craprac.dtaniver);
          vr_txinicioperiodorentab := 0;
          vr_vlbasecalculo_corrigida   := 0;
          vr_vlindicecorrecao          := 0; 
          pr_vlrentabilidade_acumulada := 0;       
          
          IF vr_aniver = 1 THEN
             apli0012.pc_taxa_poupanca(pr_datataxa => add_months(rw_craprac.dtaniver, -1)
                                      ,pr_vlrdtaxa => vr_txinicioperiodorentab
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          

            vr_vlindicecorrecao := (1 + (vr_txinicioperiodorentab / 100));
            vr_vlbasecalculo_corrigida := rw_craprac.vllanmto * vr_vlindicecorrecao;   
            pr_vlrentabilidade_acumulada := nvl(round(vr_vlbasecalculo_corrigida - rw_craprac.vllanmto,2),0);
      
            APLI0012.pc_lcto_poupanca(pr_cdcooper => rw_craprac.cdcooper
                                     ,pr_nrdconta => rw_craprac.nrdconta
                                     ,pr_nraplica => rw_craprac.nraplica
                                     ,pr_cdhistor => 3532
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_vllanmto => pr_vlrentabilidade_acumulada
                                     ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                                      
            IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Erro creditando aniversario poupança - ' || NVL(vr_dscritic,' ');
              RAISE vr_excsaida;
            END IF;    
      
          END IF;
                               
          BEGIN     
            UPDATE  cecred.craprac rac
               SET dtatlsld = rw_crapdat.dtmvtolt
                  ,vlsldatl = rw_craprac.vllanmto + pr_vlrentabilidade_acumulada                       
                  ,vlsldant = rw_backup.vlsldatl
                  ,dtsldant = rw_backup.dtatlsld
             WHERE nrdconta = rw_craprac.nrdconta
               AND nraplica = rw_craprac.nraplica
               AND cdcooper = rw_craprac.cdcooper;     
          END;
              
          APLI0005.pc_efetua_resgate(pr_cdcooper => rw_craprac.cdcooper                            
                                    ,pr_cdoperad => 1
                                    ,pr_nrdconta => rw_craprac.nrdconta
                                    ,pr_nraplica => rw_craprac.nraplica
                                    ,pr_vlresgat => 0
                                    ,pr_idtiprgt => 2
                                    ,pr_dtresgat => rw_crapdat.dtmvtolt
                                    ,pr_nrseqrgt => vr_nrseqrgt
                                    ,pr_idrgtcti => 1
                                    ,pr_idorigem => 5
                                    ,pr_tpcritic => vr_tpcritic  
                                    ,pr_cdcritic => vr_cdcritic  
                                    ,pr_dscritic => vr_dscritic) ;
                     
          IF vr_dscritic IS NOT NULL THEN        
            RAISE vr_exc_saida;
          END IF; 
          vr_dtvencto :=  rw_crapdat.dtmvtolt + 9999;
         
          pc_cadastra_aplic(pr_cdcooper => rw_craprac.cdcooper 
                           ,pr_cdoperad => 1                  
                           ,pr_nmdatela => 'ATENDA'            
                           ,pr_idorigem => 5                   
                           ,pr_nrdconta => rw_craprac.nrdconta 
                           ,pr_idseqttl => 1                  
                           ,pr_nrdcaixa => 90                  
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdprodut => 1109               
                           ,pr_qtdiaapl => 9999                
                           ,pr_dtvencto => vr_dtvencto        
                           ,pr_qtdiacar => 30                  
                           ,pr_qtdiaprz => 9999               
                           ,pr_vlaplica => rw_craprac.vllanmto + pr_vlrentabilidade_acumulada
                           ,pr_iddebcti => 1                  
                           ,pr_idorirec => 1                  
                           ,pr_idgerlog => 1                   
                           ,pr_nraplica => vr_nraplica         
                           ,pr_cdcritic => vr_cdcritic        
                           ,pr_dscritic => vr_dscritic);      
 
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
       END IF;
    END LOOP;
    
    fecha_arquivo;
   
    COMMIT;
   
  EXCEPTION
    WHEN vr_exc_saida THEN    
      vr_dscritic := vr_dscritic || sqlerrm;
      backup_arquivo(vr_dscritic);
      ROLLBACK; 
      fecha_arquivo;

    WHEN OTHERS THEN
      vr_dscritic := vr_dscritic || sqlerrm;
      backup_arquivo(vr_dscritic);
      ROLLBACK; 
      fecha_arquivo;
     
END;
