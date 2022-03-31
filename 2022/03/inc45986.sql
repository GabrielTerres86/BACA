DECLARE 
    
    vr_excsaida    EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_nraplica    craprac.nraplica%TYPE;
    vr_nmarqimp1   VARCHAR2(100)  := 'backup_inc325287.txt';
    vr_ind_arquiv1 utl_file.file_type;   
    vr_rootmicros  VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto    VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc114752'; 
    vr_exc_saida EXCEPTION;
    vr_tpcritic crapcri.cdcritic%TYPE;
    vr_nrseqrgt craprga.nrseqrgt%TYPE := 0;
    vr_dtvencto DATE;

    
    CURSOR cr_craprac is
       SELECT 16 cdcooper, 107824   nrdconta, 9   nraplica, 306.06 vllanmto FROM dual
        UNION ALL
       SELECT 16 cdcooper, 129321   nrdconta, 28  nraplica, 14.24  vllanmto FROM dual
        UNION ALL
       SELECT 1  cdcooper, 2061090  nrdconta, 8   nraplica, 19.96  vllanmto FROM dual 
        UNION ALL
       SELECT 1  cdcooper, 2592851  nrdconta, 195 nraplica, 2.86   vllanmto FROM dual 
        UNION ALL
       SELECT 1  cdcooper, 3849856  nrdconta, 23  nraplica, 29.32  vllanmto FROM dual 
        UNION ALL
       SELECT 1  cdcooper, 7490909  nrdconta, 53  nraplica, 0.30   vllanmto FROM dual
        UNION ALL
       SELECT 1  cdcooper, 8488037  nrdconta, 43  nraplica, 230.75 vllanmto FROM dual 
        UNION ALL
       SELECT 1  cdcooper, 8754837  nrdconta, 95  nraplica, 8.82   vllanmto FROM dual
        UNION ALL 
       SELECT 1  cdcooper, 8868433  nrdconta, 11  nraplica, 2.18   vllanmto FROM dual 
        UNION ALL
       SELECT 1  cdcooper, 10291598 nrdconta, 37  nraplica, 6.82   vllanmto FROM dual   
        UNION ALL
       SELECT 1  cdcooper, 10470794 nrdconta, 39  nraplica, 6.81   vllanmto FROM dual
        UNION ALL
       SELECT 1  cdcooper, 11349115 nrdconta, 10  nraplica, 2.84   vllanmto FROM dual
        UNION ALL
       SELECT 1  cdcooper, 12268127 nrdconta, 3   nraplica, 3.85   vllanmto FROM dual  
        UNION ALL
       SELECT 1  cdcooper, 12651966 nrdconta, 8   nraplica, 3.98   vllanmto FROM dual  
        UNION ALL
       SELECT 1  cdcooper, 13240625 nrdconta, 1   nraplica, 0.31   vllanmto FROM dual
        UNION ALL
       SELECT 1  cdcooper, 13596578 nrdconta, 4   nraplica, 5.49   vllanmto FROM dual 
        UNION ALL
       SELECT 1  cdcooper, 13864882 nrdconta, 4   nraplica, 2.55   vllanmto FROM dual;       
       rw_craprac cr_craprac%ROWTYPE;
        
    CURSOR cr_backup(pr_cdcooper craprac.cdcooper%TYPE
                    ,pr_nrdconta craprac.nrdconta%TYPE
                    ,pr_nraplica craprac.nraplica%TYPE) IS
                                      
       SELECT rac.cdcooper,
              rac.nrdconta,
              rac.nraplica,
              rac.dtatlsld,
              replace(rac.vlsldatl,',','.') vlsldatl,
              replace(rac.vlsldant,',','.') vlsldant, 
              rac.dtsldant
         FROM craprac rac
        WHERE rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND rac.nraplica = pr_nraplica;
       rw_backup cr_backup%ROWTYPE;
       
       -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       
    PROCEDURE backup_arquivo (pr_msg VARCHAR2) IS
    BEGIN
       gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
    END; 
  
    PROCEDURE fecha_arquivo IS 
    BEGIN
       gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
    END;                                
 PROCEDURE pc_cadastra_aplic(pr_cdcooper IN craprac.cdcooper%TYPE      -- Código da Cooperativa
                             ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Código do Operador
                             ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                             ,pr_idorigem IN INTEGER                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                             ,pr_nrdconta IN craprac.nrdconta%TYPE      -- Número da Conta
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Titular da Conta
                             ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero de caixa
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data de Movimento
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE      -- Código do Produto (Produto selecionado na tela)
                             ,pr_qtdiaapl IN INTEGER                    -- Dias da Aplicação (Dias informados em tela)
                             ,pr_dtvencto IN DATE                       -- Data de Vencimento da Aplicação (Data informada em tela)
                             ,pr_qtdiacar IN INTEGER                    -- Carência da Aplicação (Carência informada em tela)
                             ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      -- Prazo da Aplicação (Prazo selecionado na tela)
                             ,pr_vlaplica IN NUMBER                     -- Valor da Aplicação (Valor informado em tela)
                             ,pr_iddebcti IN INTEGER                    -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 ¿ Não / 1 - Sim)
                             ,pr_idorirec IN INTEGER                    -- Identificador de Origem do Recurso (Identificador informado em tela)
                             ,pr_idgerlog IN INTEGER                    -- Identificador de Log (Fixo no código, 0 ¿ Não / 1 ¿ Sim)
                             ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0 -- Número aplicação programada (Opcional, 0 = Aplicação Não Programada)
                             ,pr_nraplica OUT craprac.nraplica%TYPE     -- Numero da aplicacao cadastrada
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica de erro
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica de erro
  BEGIN

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis Erro
      vr_des_erro VARCHAR2(1000);

      -- Variaveis locais
      vr_dtmvtopr DATE;         -- Data do proximo movimento
      vr_retorno  VARCHAR2(3);  -- Tipo de retorno (OK / NOK)
      vr_percenir NUMBER:= 0;   -- Percentual de IR
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
      
      --Variavel para receber valor data inicio e fim para calculo taxa rdcpos.
      vr_dstextab_rdcpos craptab.dstextab%TYPE;
      vr_dtinitax     DATE;     -- Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;     -- Data de fim da utilizacao da taxa de poupanca.

      --Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
      vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_tab_tpregist   APLI0001.typ_tab_tpregist;
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;

      --Variavel usada para montar o indice da tabela de memoria
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);
      vr_index_acumula INTEGER;

      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;
      
      vr_notfound      boolean;
      vr_gbl_tentativa      NUMBER:=0;
      vr_gbl_total_vezes    NUMBER:=10;
      vr_gbl_achou_registro NUMBER:=0;

      -- CURSORES --

      -- Selecionar os dados da Cooperativa
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
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Consulta referente a dados de produtos
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
          FROM crapcpc cpc,
               crapind ind
         WHERE cpc.cddindex = ind.cddindex
               AND cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Consulta referente a dados de aplicacoes de produtos antigos
      CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                       ,pr_nrdconta IN craprda.nrdconta%TYPE
                       ,pr_nraplica IN craprda.nraplica%TYPE)IS

        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
          FROM craprda rda
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
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot_lock%ROWTYPE;

      -- Consulta referente a nomenclatura de produtos
      CURSOR cr_crapnpc (pr_cdprodut crapnpc.cdprodut%TYPE
                        ,pr_qtdiacar crapnpc.qtmincar%TYPE
                        ,pr_vlsldacu crapnpc.vlminapl%TYPE)IS
      SELECT
        npc.cdnomenc
       ,npc.dsnomenc
      FROM
        crapnpc npc
      WHERE
            npc.cdprodut  = pr_cdprodut
        AND npc.qtmincar <= pr_qtdiacar
        AND npc.qtmaxcar >= pr_qtdiacar
        AND npc.vlminapl <= pr_vlsldacu
        AND npc.vlmaxapl >= pr_vlsldacu
        AND npc.idsitnom  = 1;

      rw_crapnpc cr_crapnpc%ROWTYPE;

      -- Consulta de modalidade de produto
      CURSOR cr_crapmpc(pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                       ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                       ,pr_vlsldacu IN NUMBER                --> Saldo Acumulado
                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                       ) IS
        SELECT
          mpc.cdmodali
         ,mpc.vltxfixa
         ,mpc.vlperren
        FROM
          crapmpc mpc
         ,crapdpc dpc
        WHERE
              mpc.cdprodut  = pr_cdprodut -- Codigo do produto
          AND mpc.qtdiacar  = pr_qtdiacar -- Quantidade de dias de carencia
          AND mpc.qtdiaprz  = pr_qtdiaprz -- Quantidade de dias de prazo
          AND mpc.vlrfaixa <= pr_vlsldacu -- Saldo Acumulado
          AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
          AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
          AND dpc.idsitmod  = 1
        ORDER BY
          mpc.vlrfaixa DESC;

      rw_crapmpc cr_crapmpc%ROWTYPE;

      CURSOR cr_crapmpc_cont(pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                            ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                            ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                            ) IS
        SELECT COUNT(1) cont
          FROM crapmpc mpc
              ,crapdpc dpc
        WHERE mpc.cdprodut  = pr_cdprodut -- Codigo do produto
          AND mpc.qtdiacar  = pr_qtdiacar -- Quantidade de dias de carencia
          AND mpc.qtdiaprz  = pr_qtdiaprz -- Quantidade de dias de prazo
          AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
          AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
          AND dpc.idsitmod  = 1;
      
      rw_crapmpc_cont cr_crapmpc_cont%ROWTYPE;

      --Selecionar informacoes dos associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapres.nrdconta%TYPE) IS

        SELECT crapass.cdcooper
              ,crapass.cdagenci
              ,crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.inpessoa
        FROM crapass crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta
        FOR UPDATE NOWAIT;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursosr para encontrar a cidade do PA do associado
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;

      --Selecionar informacoes do titular
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT ttl.nmextttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.nrdconta = pr_nrdconta
         AND lpp.cdhistor IN (158,496)
         AND lpp.dtmvtolt > pr_dtmvtolt
         GROUP BY lpp.nrdconta
                 ,lpp.nrctrrpp;

      rw_craplpp cr_craplpp%ROWTYPE;

      --Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                              ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS

        SELECT craplrg.nrdconta,craplrg.nraplica,Count(*) qtlancmto
        FROM craplrg craplrg
        WHERE craplrg.cdcooper = pr_cdcooper
        AND   craplrg.nrdconta = pr_nrdconta
        AND   craplrg.tpaplica = 4
        AND   craplrg.inresgat = 0
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_nrdconta IN craplrg.nrdconta%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
        FROM craplrg craplrg
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
          crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper
          AND sli.nrdconta = pr_nrdconta
          AND sli.dtrefere = pr_dtrefere;

      rw_crapsli cr_crapsli%ROWTYPE;

    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'APLI0005.pc_cadastra_aplic');

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      --Bloqueio do registro do cadastro de associados
      vr_gbl_tentativa:=0;
      vr_gbl_achou_registro:=0;
      
      WHILE (vr_gbl_achou_registro=0) AND 
            (vr_gbl_tentativa < vr_gbl_total_vezes) 
      LOOP  
        BEGIN 
          vr_gbl_tentativa:=vr_gbl_tentativa+1;
          --
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);

     
          rw_crapass := null;  
           FETCH cr_crapass INTO rw_crapass;
          vr_gbl_achou_registro:=1; --condicao de saida 
          
           -- Verifica se encontrou associado
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
      

      -- Consulta dados de produtos
      OPEN cr_crapcpc(pr_cdprodut => pr_cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;
      -- Se for por produto com aniversario, carrega o proximo aniversario
      IF rw_crapcpc.indanive = 1 THEN
         IF rw_crapcpc.cddindex = 6 THEN -- Aplicacao poupanca
            vr_dtaniver := APLI0012.fn_proximo_aniv_poupanca(pr_dtaplica => rw_crapdat.dtmvtolt);
         ELSE 
            vr_dtaniver := apli0010.fn_proximo_aniversario(pr_dtaplica => rw_crapdat.dtmvtolt -- add_months(rw_crapdat.dtmvtolt,1);
                                                          ,pr_dtaniver => rw_crapdat.dtmvtolt);
            vr_dtinical := rw_crapdat.dtmvtolt;
         END IF;
      ELSE
        vr_dtaniver := null;
      END IF;

      -- Saldo acumulado para aplicacao
      vr_vltotrda := NVL(vr_vltotrda,0) + NVL(pr_vlaplica,0);

      -- Consulta de nomenclatura
      OPEN cr_crapnpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_vlsldacu => vr_vltotrda);

      FETCH cr_crapnpc INTO rw_crapnpc;

      -- Verifica se encontrou registro
      IF cr_crapnpc%NOTFOUND THEN
        CLOSE cr_crapnpc;
        vr_cdnomenc := '0';
      ELSE
        CLOSE cr_crapnpc;
        vr_cdnomenc := rw_crapnpc.cdnomenc;
      END IF;

      -- Consulta de modalidade do produto
      OPEN cr_crapmpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_qtdiaprz => pr_qtdiaprz
                     ,pr_vlsldacu => vr_vltotrda);

      FETCH cr_crapmpc INTO rw_crapmpc;

      -- Verifica se encontrou registro
      IF cr_crapmpc%NOTFOUND THEN
        CLOSE cr_crapmpc;

        -- Caso nao encontre, gera critica
        vr_dscritic := 'Nao foi encontrada modalidade na política de captacao para o produto selecionado.';
        RAISE vr_exc_saida;
      ELSE
        -- Caso encontre, somente fecha o cursor
        CLOSE cr_crapmpc;
      END IF;

      -- Verifica valor da aplicacao foi retirado da conta investimento
      IF pr_iddebcti = 1 THEN

        -- Verifica se ha saldo suficiente
        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => last_day(pr_dtmvtolt));         
        FETCH cr_crapsli INTO rw_crapsli;
        -- Verifica se consulta retornou registros
        IF cr_crapsli%NOTFOUND THEN
          CLOSE cr_crapsli;
          vr_dscritic := 'Registro de saldo nao encontrado';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapsli;
        END IF;

        -- Verifica se existe saldo disponivel
        IF rw_crapsli.vlsddisp < pr_vlaplica THEN
          vr_dscritic := 'Saldo insuficiente';
          RAISE vr_exc_saida;
        END IF;

      END IF;

      LOOP
        -- Verifica qual o proximo valor da sequence
        vr_nraplica := fn_sequence(pr_nmtabela => 'CRAPRAC'
                                  ,pr_nmdcampo => 'NRAPLICA'
                                  ,pr_dsdchave => pr_cdcooper || ';' || pr_nrdconta
                                  ,pr_flgdecre => 'N');

        /* Consulta CRAPRDA para nao existir aplicacoes com o mesmo numero mesmo
        sendo produto antigo e novo */

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

      -- Verifica se taxa é fixa
      IF rw_crapcpc.idtxfixa = 1 THEN
        vr_txaplica := rw_crapmpc.vltxfixa;
      ELSE
        vr_txaplica := rw_crapmpc.vlperren;
      END IF;

      -- Insercao do registro de aplicacao
      BEGIN
        INSERT INTO craprac(
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
         ,vr_vltotrda -- Saldo acumulado
         ,pr_qtdiacar
         ,pr_qtdiaprz
         ,pr_qtdiaapl
         ,vr_txaplica
         ,0           -- Saque Total
         ,0           -- Bloqueio Resgate
         ,0           -- Cálculo Orçamento
         ,pr_nrctrrpp -- Número da aplicação programada
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

      -- Consulta primeiro indice da tabela
      vr_index_acumula := vr_tab_acumula.first;
      
       OPEN cr_craplot_lock(pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 100
                              ,pr_nrdolote => 8500);

      FETCH cr_craplot_lock INTO rw_craplot;
      
      IF cr_craplot_lock%FOUND THEN
        CLOSE cr_craplot_lock;
        BEGIN
          INSERT INTO
            craplot(
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
            craplot
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

      IF pr_idorirec = 0 THEN -- Recurso  Aplicação
        vr_cdhistor := rw_crapcpc.cdhsraap;
      ELSE
        vr_cdhistor := rw_crapcpc.cdhsnrap;
      END IF;

      -- Insercao de registros de Lancamento de aplicacao da captacao
      BEGIN
        INSERT INTO
          craplac(
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
      IF pr_iddebcti = 1 THEN -- Recurso da Conta Investimento
                        
         OPEN cr_craplot_lock(pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 100
                              ,pr_nrdolote => 9900010106);
                         
       FETCH cr_craplot_lock INTO rw_craplot;
      
      IF cr_craplot_lock%FOUND THEN
        CLOSE cr_craplot_lock;
          BEGIN
            INSERT INTO
              craplot(
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
             ,9900010106 --10106
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
              craplot
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

        -- Insere registro de Lancamento da conta investimento
        BEGIN
          INSERT INTO
            craplci(
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

        -- Verifica se existe registro de lancamento na conta investimento
        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => rw_crapdat.dtultdia);

        FETCH cr_crapsli INTO rw_crapsli;

        -- Verifica se registro de lancamento de conta investimento existe
        IF cr_crapsli%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapsli;

          -- Inserir registro de saldo da conta investimento
          BEGIN

            INSERT INTO
              crapsli(
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
          -- Fecha cursor
          CLOSE cr_crapsli;

          -- Atualiza registro de saldo na conta investimento
          BEGIN

            UPDATE
              crapsli
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

      END IF; -- Fim ELSE recurso nao proveniente de conta investimento

      -- Geracao de comprovante

      IF rw_crapass.inpessoa = 1 THEN

        /* Nome do titular que fez a aplicacao */
        OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_idseqttl => pr_idseqttl);

        --Posicionar no proximo registro
        FETCH cr_crapttl INTO rw_crapttl;

        --Se nao encontrar
        IF cr_crapttl%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapttl;

          vr_cdcritic:= 0;
          vr_dscritic:= 'Titular nao encontrado.';

          -- Gera exceção
          RAISE vr_exc_saida;
        END IF;

        -- Fechar Cursor
        CLOSE cr_crapttl;

        -- Nome titular
        vr_nmextttl:= rw_crapttl.nmextttl;

      ELSE
        vr_nmextttl:= rw_crapass.nmprimtl;
      END IF;

      -- Busca a cidade do PA do associado
      OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);

      FETCH cr_crapage INTO vr_nmcidade;

      IF cr_crapage%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapage;

        vr_cdcritic:= 962;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Gera exceção
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
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
      -- Verifica se taxa é fixa
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
      
      --Gerar protocolo
      GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper                         --> Código da cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt                         --> Data movimento
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) --> Hora da transação NOK
                                ,pr_nrdconta => pr_nrdconta                         --> Número da conta
                                ,pr_nrdocmto => vr_nraplica                         --> Número do documento
                                ,pr_nrseqaut => 0                                   --> Número da sequencia
                                ,pr_vllanmto => pr_vlaplica                         --> Valor lançamento
                                ,pr_nrdcaixa => pr_nrdcaixa                                   --> Número do caixa NOK
                                ,pr_gravapro => TRUE                                --> Controle de gravação
                                ,pr_cdtippro => 10                                  --> Código de operação
                                ,pr_dsinfor1 => vr_dsinfor1                         --> Descrição 1
                                ,pr_dsinfor2 => vr_dsinfor2                         --> Descrição 2
                                ,pr_dsinfor3 => vr_dsinfor3                         --> Descrição 3
                                ,pr_dscedent => NULL                                --> Descritivo
                                ,pr_flgagend => FALSE                               --> Controle de agenda
                                ,pr_nrcpfope => 0                                   --> Número de operação
                                ,pr_nrcpfpre => 0                                   --> Número pré operação
                                ,pr_nmprepos => ''                                  --> Nome
                                ,pr_dsprotoc => vr_dsprotoc                         --> Descrição do protocolo
                                ,pr_dscritic => vr_dscritic                         --> Descrição crítica
                                ,pr_des_erro => vr_des_erro);                       --> Descrição dos erros de processo

      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Fim geracao de comprovante

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
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

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          /* Comitar apenas se não for via batch */
          IF upper(pr_nmdatela) <> 'CRPS145' THEN
          COMMIT;
        END IF;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_cadastra_aplic: ' || SQLERRM;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
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
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
    FOR rw_craprac IN cr_craprac LOOP
                     
      OPEN cr_backup(pr_cdcooper => rw_craprac.cdcooper,
                     pr_nrdconta => rw_craprac.nrdconta, 
                     pr_nraplica => rw_craprac.nraplica);
                   
      FETCH cr_backup INTO rw_backup;
      backup_arquivo('UPDATE craprac SET dtatlsld ='||''''||rw_backup.dtatlsld||''''||',vlsldatl ='||rw_backup.vlsldatl||',vlsldant ='||rw_backup.vlsldant||',dtsldant ='||''''||rw_backup.dtsldant||''''||' WHERE nrdconta ='||rw_backup.nrdconta||' AND nraplica ='||rw_backup.nraplica||' AND cdcooper ='||rw_backup.cdcooper||';');                           
      CLOSE  cr_backup;   
              
      BEGIN     
        UPDATE craprac 
           SET dtatlsld = rw_crapdat.dtmvtolt
              ,vlsldatl = rw_craprac.vllanmto                        
              ,vlsldant = vlsldatl
              ,dtsldant = dtatlsld
         WHERE nrdconta = rw_craprac.nrdconta
           AND nraplica = rw_craprac.nraplica
           AND cdcooper = rw_craprac.cdcooper;     
      END;
    END LOOP;
     
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
     vr_dtvencto := to_date(rw_crapdat.dtmvtolt,'dd/mm/yyyy') + 9999;
     pc_cadastra_aplic(pr_cdcooper => rw_craprac.cdcooper  -- Código da Cooperativa
                      ,pr_cdoperad => 1                   --Código do Operador
                      ,pr_nmdatela => 'ATENDA'            -- Nome da Tela
                      ,pr_idorigem => 5                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                      ,pr_nrdconta => rw_craprac.nrdconta -- Número da Conta
                      ,pr_idseqttl => 1                   -- Titular da Conta
                      ,pr_nrdcaixa => 90                  -- Numero de caixa
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de Movimento
                      ,pr_cdprodut => 1109                -- Código do Produto (Produto selecionado na tela)
                      ,pr_qtdiaapl => 9999                -- Dias da Aplicação (Dias informados em tela)
                      ,pr_dtvencto => vr_dtvencto         -- Data de Vencimento da Aplicação (Data informada em tela)
                      ,pr_qtdiacar => 30                  -- Carência da Aplicação (Carência informada em tela)
                      ,pr_qtdiaprz => 9999                -- Prazo da Aplicação (Prazo selecionado na tela)
                      ,pr_vlaplica => rw_craprac.vllanmto -- Valor da Aplicação (Valor informado em tela)
                      ,pr_iddebcti => 1                   -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 ¿ Não / 1 - Sim)
                      ,pr_idorirec => 1                   -- Identificador de Origem do Recurso (Identificador informado em tela)
                      ,pr_idgerlog => 1                   -- Identificador de Log (Fixo no código, 0 ¿ Não / 1 ¿ Sim)
                      ,pr_nraplica => vr_nraplica         -- Numero da aplicacao cadastrada
                      ,pr_cdcritic => vr_cdcritic         -- Codigo da critica de erro
                      ,pr_dscritic => vr_dscritic);       -- Descricao da critica de erro -- Descricao da critica de erro

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    fecha_arquivo;
   
    COMMIT;
   
  EXCEPTION
    WHEN vr_exc_saida THEN    
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := vr_dscritic;
      ROLLBACK; 
      fecha_arquivo;

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := sqlerrm;
      ROLLBACK; 
      fecha_arquivo;
     
END;
