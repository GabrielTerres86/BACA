PL/SQL Developer Test script 3.0
882
-- Created on 13/01/2021 by T0032717 
DECLARE
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper craplem.cdcooper%TYPE) IS
    SELECT e.nrdconta, e.nrctremp, e.inprejuz, e.vlsdprej, e.vlttmupr, e.vlpgmupr, e.vlttjmpr, e.vlpgjmpr, e.vltiofpr, e.vlpiofpr, e.dtprejuz
      FROM crapepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.inprejuz = 1
       AND e.tpemprst = 1
       AND e.dtprejuz >= '01/01/2016'
       AND e.dtprejuz <= '31/12/2020'
       AND e.vlsdprej > 0;
  rw_principal cr_principal%ROWTYPE;

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  CURSOR cr_craplem5(pr_cdcooper craplem.cdcooper%TYPE
                    ,pr_nrdconta craplem.nrdconta%TYPE
                    ,pr_nrctremp craplem.nrctremp%TYPE
                    ,pr_dtmvtolt craplem.dtmvtolt%TYPE
                    ) IS
    SELECT nvl(SUM(lem.vllanmto),0) vllanmto
      FROM craplem lem
     WHERE to_char(lem.dtmvtolt, 'MMRRRR') = to_char(pr_dtmvtolt, 'MMRRRR')
       AND lem.cdhistor = 2409
       AND lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp;
  rw_craplem5 cr_craplem5%ROWTYPE;
  
  CURSOR cr_devedor(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_nrdconta craplem.nrdconta%TYPE
                   ,pr_nrctremp craplem.nrctremp%TYPE) IS
    SELECT cdcooper,
           nrdconta,
           SUM(decode(inprejuz,1,vlsdprej, --> Para contas em prejuizo, somar valor saldo em prejuizo
                                vlsdeved)) vlsdeved
      FROM crapepr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND (inliquid = 0 OR (inliquid = 1 AND inprejuz = 1))
       AND (nvl(vlsdeved,0) <> 0 OR 
            nvl(vlsdprej,0) <> 0)
     GROUP BY cdcooper, nrdconta;
  rw_devedor cr_devedor%ROWTYPE;
  
  CURSOR cr_crapdir(pr_cdcooper craplem.cdcooper%TYPE
                   ,pr_nrdconta craplem.nrdconta%TYPE) IS
    SELECT vlsddvem 
      FROM crapdir
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta
       AND dtmvtolt = '31/12/2020';
  rw_crapdir cr_crapdir%ROWTYPE;
  
  --
  vr_tab_extrato_epr      extr0002.typ_tab_extrato_epr; 
  TYPE typ_tab_extrato_epr_novo IS TABLE OF extr0002.typ_reg_extrato_epr INDEX BY VARCHAR2(100);
  vr_tab_extrato_epr_novo typ_tab_extrato_epr_novo;
  pr_tab_extrato_epr_aux  extr0002.typ_tab_extrato_epr_aux;
  vr_des_reto VARCHAR2(1000);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_index_extrato PLS_INTEGER;
  vr_index_novo    VARCHAR2(100);
  vr_index_epr_aux PLS_INTEGER;
  vr_flgloop  BOOLEAN := FALSE;
  vr_vlsaldo1 NUMBER;
  vr_vlsaldo2 NUMBER;
  vr_exc_proximo EXCEPTION;
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
  vr_tab_calculado empr0001.typ_tab_calculado;
  vr_vljurdia NUMBER;
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_vlsdprej NUMBER;
  vr_flgativo INTEGER;
  vr_vlsddvem NUMBER;
  vr_vldezemb NUMBER;
  
  PROCEDURE pc_obtem_extrato_emprest    (pr_cdcooper    IN crapcop.cdcooper%TYPE       --Codigo Cooperativa
                                          ,pr_cdagenci    IN crapass.cdagenci%TYPE       --Codigo Agencia
                                          ,pr_nrdcaixa    IN INTEGER                     --Numero do Caixa
                                          ,pr_cdoperad    IN VARCHAR2                    --Codigo Operador
                                          ,pr_nmdatela    IN VARCHAR2                    --Nome da Tela
                                          ,pr_idorigem    IN INTEGER                     --Origem dos Dados
                                          ,pr_nrdconta    IN crapass.nrdconta%TYPE       --Numero da Conta do Associado
                                          ,pr_idseqttl    IN INTEGER                     --Sequencial do Titular
                                          ,pr_nrctremp    IN crapepr.nrctremp%TYPE       --Contrato Emprestimo
                                          ,pr_dtiniper    IN DATE                        --Inicio periodo
                                          ,pr_dtfimper    IN DATE                        --Final periodo
                                          ,pr_flgerlog    IN BOOLEAN                     --Imprimir log
                                          ,pr_extrato_epr OUT extr0002.typ_tab_extrato_epr        --Tipo de tabela com extrato emprestimo
                                          ,pr_des_reto    OUT VARCHAR2                   --Retorno OK ou NOK
                                          ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS  --Tabela de Erros
  BEGIN
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_obtem_extrato_emprest             Antigo: procedures/b1wgen0002.p/obtem-extrato-emprestimo
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 06/05/2020
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para obter extrato do emprestimo
  --
  -- Alterações : 14/07/2014 - Conversão Progress -> Oracle (Alisson - AMcom)
  --              
  --              09/02/2015 - Ajuste no calculo do prejuizo para o emprestimo PP.
  --                           (James/Oscar)
  -- 
  --              08/10/2015 - Tratar os históricos de estorno do produto PP. (Oscar)                   
  --              14/10/2015 - Incluir o tratamento de pagamento de avalista 
  --                           que foi esquecido na migração para o Oracle. (Oscar)
  --
  --              15/08/2017 - Inclusao do campo qtdiacal e historicos do Pos-Fixado. (Jaison/James - PRJ298) 
  --
  --              03/04/2018 - M324 ajuste na configuração de extrato para emprestimo (Rafael Monteiro - Mouts)
  --
  --              31/07/2018 - P410 - Inclusao de Histórico para não compor Saldo no IOF do Prejuizo (Marcos-Envolti)
  --
  --              25/09/2018 - Incluir novos historicos de estorno de financiamento 2784,2785,2786,2787.
  --                           PRJ450 - Regulatorio(Odirlei - AMcom)     
  --
  --              05/03/2020 - Ajuste no extrato para emprestimo do consignado com pgto de avalista,
  --                           somando Historico de IOF com Atrado. Squad Produto (Fernanda Kelli - AMcom)   
  --
  --              06/05/2020 - Ajuste no extrato para emprestimo do consignado. Somar Juros e Multa ao valor do
  --                           lançto no pagto da parcela, mesmo qdo o pgto for realizados após o estorno do mesmo.
  --                           Squad Produto - RITM0064513 (Fernanda Kelli - AMcom)
  --   
  --              09/06/2020 - INC0043234 - Ajuste no extrato para emprestimo com pgto PP de avalista,
  --                           somando Historico de IOF com Atrasado. Squad Emprestimos (Elton - AMcom)   
  --
  --
  --              16/09/2020 - Adicionados tratamentos para extrato prejuizo pp
  --                           PRJ0019378 (Darlei Zillmer / Supero)
  ---------------------------------------------------------------------------------------------------------------
  DECLARE
      --Tabela de Memoria primeira parcela
      TYPE typ_tab_flgpripa IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;
      vr_tab_flgpripa typ_tab_flgpripa;
      
      -- Buscar cadastro auxiliar de emprestimo
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%type,
                         pr_nrdconta IN crapepr.nrdconta%type,
                         pr_nrctremp IN crapepr.nrctremp%type) is
        SELECT crapepr.tpemprst
              ,crapepr.inprejuz
              ,crapepr.dtprejuz
              ,crapepr.tpdescto
              ,crapepr.rowid
        FROM crapepr crapepr
        WHERE crapepr.cdcooper = pr_cdcooper
        AND   crapepr.nrdconta = pr_nrdconta
        AND   crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%rowtype;
      
      -- Buscar informações de pagamentos do empréstimos
      CURSOR cr_craplem (pr_cdcooper IN craplem.cdcooper%type
                        ,pr_nrdconta IN craplem.nrdconta%type
                        ,pr_nrctremp IN craplem.nrctremp%type
                        ,pr_dtiniper IN DATE
                        ,pr_dtfimper IN DATE) IS
        SELECT /*+ INDEX (craplem CRAPLEM##CRAPLEM6) */
               to_char(craplem.dtmvtolt,'dd') ddlanmto
              ,craplem.dtmvtolt
              ,craplem.cdhistor
              ,craplem.vlpreemp
              ,craplem.vllanmto
              ,craplem.nrparepr
              ,craplem.cdcooper
              ,craplem.nrdconta
              ,craplem.nrctremp
              ,craplem.nrseqdig
              ,craplem.cdagenci
              ,craplem.cdbccxlt
              ,craplem.nrdolote
              ,craplem.nrdocmto
              ,craplem.txjurepr
              ,craplem.nrseqava
              ,craplem.qtdiacal
              ,craplem.vltaxprd
              ,craplem.dthrtran
            --  ,DECODE(craplem.cdorigem,1,'Ayllos',2,'Caixa',3,'Internet',4,'Cash',5,'Ayllos WEB',6,'URA',7,'Batch',8,'Mensageria',20,'Folha (Consignado)',' ') cdorigem
              ,DECODE(craplem.cdorigem,1,'Debito CC',2,'Caixa',3,'Internet',4,'Cash',5,'Debito CC',6,'URA',7,'Debito CC',8,'Mensageria',20,'Folha',' ') cdorigem
              ,count(*) over (partition by  craplem.cdcooper,craplem.nrdconta,craplem.dtmvtolt) nrtotdat
              ,row_number() over (partition by craplem.dtmvtolt ORDER BY craplem.cdcooper
                                                                        ,craplem.nrdconta
                                                                        ,craplem.dtmvtolt
                                                                        ,craplem.cdhistor
                                                                        ,craplem.nrdocmto
                                                                        ,craplem.progress_recid) nrseqdat
          FROM craplem craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND ((craplem.dtmvtolt >= pr_dtiniper AND pr_dtiniper IS NOT NULL) OR pr_dtiniper IS NULL)          
           AND ((craplem.dtmvtolt <= pr_dtfimper AND pr_dtfimper IS NOT NULL) OR pr_dtfimper IS NULL)
         ORDER BY craplem.dtmvtolt, craplem.cdhistor;
      rw_craplem cr_craplem%ROWTYPE;
      -- Buscar informações de pagamentos do empréstimos
      CURSOR cr_craplem_his (pr_cdcooper IN crapepr.cdcooper%type
                            ,pr_nrdconta IN crapepr.nrdconta%type
                            ,pr_nrctremp IN crapepr.nrctremp%type
                            ,pr_nrparepr IN craplem.nrparepr%type
                            ,pr_dtmvtolt IN craplem.dtmvtolt%type
                            ,pr_cdhistor IN craplem.cdhistor%TYPE) IS
        SELECT craplem.vllanmto
        FROM craplem craplem
        WHERE craplem.cdcooper = pr_cdcooper
        AND   craplem.nrdconta = pr_nrdconta
        AND   craplem.nrctremp = pr_nrctremp
        AND   craplem.nrparepr = pr_nrparepr
        AND   craplem.dtmvtolt = pr_dtmvtolt  
        AND   craplem.cdhistor = pr_cdhistor
        ORDER BY cdcooper,dtmvtolt,cdagenci,cdbccxlt,nrdolote,nrdconta,nrdocmto;
      rw_craplem_his cr_craplem_his%ROWTYPE; 
      
      -- cursor para historicos de prejuizo pp
      CURSOR cr_lemprej(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE
                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT 1
          FROM craplem l
         WHERE l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta
           AND l.nrctremp = pr_nrctremp
           AND l.dtmvtolt = pr_dtmvtolt
           AND l.cdhistor IN (3052, 3051, 3054, 3053);
      rw_lemprej cr_lemprej%ROWTYPE;
      
      CURSOR cr_craplcr(pr_cdcooper IN craplem.cdcooper%TYPE
                       ,pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT l.dsoperac
          FROM craplcr l, crapepr e
         WHERE e.cdcooper = l.cdcooper
           AND e.cdlcremp = l.cdlcremp
           AND e.cdcooper = pr_cdcooper
           AND e.nrdconta = pr_nrdconta
           AND e.nrctremp = pr_nrctremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      --Selecionar Historicos
      CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS        
        SELECT craphis.indebfol
              ,craphis.inhistor
              ,craphis.dshistor
              ,craphis.indebcre
              ,craphis.cdhistor
              ,craphis.dsextrat
        FROM craphis craphis
        WHERE craphis.cdcooper = pr_cdcooper       
        AND   craphis.cdhistor = pr_cdhistor;                      
      rw_craphis cr_craphis%ROWTYPE;  
      --Variaveis Locais
      vr_cdhistor INTEGER;
      vr_vllantmo NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      --Variaveis de indices
      vr_index PLS_INTEGER;
      --Variaveis de Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;

      vr_index_novo PLS_INTEGER;
      vr_cdhistorlem INTEGER;
    BEGIN
      --Limpar tabelas memoria
      pr_tab_erro.DELETE;
      pr_extrato_epr.DELETE;
      
      --Inicializar transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Obter extrato do emprestimo.';

      --Consultar Emprestimo
      OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      --Se Encontrou
      IF cr_crapepr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapepr;  
        --mensagem Critica
        vr_cdcritic:= 356;
        vr_dscritic:= NULL;
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Sair Programa
        RETURN;                     
      END IF;
      --Fechar Cursor
      CLOSE cr_crapepr; 
      
      --Percorrer Lancamentos Emprestimo
      FOR rw_craplem IN cr_craplem (pr_cdcooper  => pr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta
                                   ,pr_nrctremp  => pr_nrctremp
                                   ,pr_dtiniper  => pr_dtiniper 
                                   ,pr_dtfimper  => pr_dtfimper) LOOP
        --Se for a primeira ocorrencia da data
        IF rw_craplem.nrseqdat = 1 OR 
           (rw_crapepr.tpemprst = 1 AND rw_crapepr.tpdescto = 2 )THEN --RITM0064513 Squad Produtos 
          --Marcar tabela primeira parcela como false
          FOR idx IN 1..999 LOOP
            vr_tab_flgpripa(idx):= FALSE;
          END LOOP;  
        END IF;                             
        /* Desprezando historicos de concessao de credito com juros a apropriar e lancamendo para desconto */               
        IF rw_craplem.cdhistor IN (1032,1033,1034,1035,1048,1049,2566,2567,2388,2473,2389,2390,2475,2392,2474,2393,2394,2476) THEN
          --Proximo registro
          CONTINUE;
        END IF;
        /* Desprezando historicos de concessao de credito com juros a apropriar e lancamendo para desconto */
        -- rmm desconsiderar pagamentos prejuizo (2390,2392,2388,2475)        
        IF rw_crapepr.tpemprst = 1 AND rw_craplem.cdhistor IN --(2390,2392,2388,2475,2391,2395) 
          (2386,2388,2473,2389,2390,2475,2387,2392,2474,2393,2394,2476,1731) THEN
          CONTINUE;          
        END IF;
        
        IF NOT extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_tpemprst => 1) THEN
          IF rw_crapepr.tpemprst = 1 AND rw_craplem.cdhistor IN (2701,2702,2391,2395,1731) THEN
            CONTINUE;          
          END IF;          
        END IF;
        
        
        IF NOT extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_tpemprst => 1) THEN
        --
        /* Verifica se o contrato estah em prejuizo */
        IF rw_crapepr.tpemprst = 1 AND
           rw_crapepr.inprejuz = 1 AND 
           rw_craplem.dtmvtolt >= rw_crapepr.dtprejuz THEN
           
             -- Lote do novo emprestimo 
           IF rw_craplem.nrdolote <= 600000 OR rw_craplem.nrdolote >= 650000 THEN
             CONTINUE;
           END IF;

        END IF;
        END IF;
        
        --Criar Extrato
        vr_index:= pr_extrato_epr.count + 1;
        --
        pr_extrato_epr(vr_index).dthrtran := rw_craplem.dthrtran;
        --Se existe valor emprestimo 
        IF rw_craplem.vlpreemp > 0 THEN
          pr_extrato_epr(vr_index).qtpresta:= apli0001.fn_round(rw_craplem.vllanmto / rw_craplem.vlpreemp,4);
        ELSE
          pr_extrato_epr(vr_index).qtpresta:= 0;
        END IF;    
        /*Historicos que nao vao compor o saldo, mas vao aparecer no relatorio*/
        IF rw_craplem.cdhistor IN (1048,1049,1050,1051,1717,1720,1708,1711,2566,2567, /*2382,*/ 2411, 2415, 2423,2416,2390,2475,2394,2476,2735,
                                   --> Novos historicos de estorno de financiamento
                                   2784,2785,2786,2787,2882,2883,2887,2884,2886,2954,2955,2956,2953,2735
                                   --> Estorno IOF Comp. Consignado (P437)
                                   ,3013) THEN 
          --marcar para nao mostrar saldo
          pr_extrato_epr(vr_index).flgsaldo:= FALSE;                           
        END IF;
        /*Historicos que nao vao aparecer no relatorio, mas vao compor saldo */
        IF rw_craplem.cdhistor IN (2471,2472,2358,2359,2878,2883,2887,2882,2884,2885,2886,2888,2954,2955,2956,2953,2388,2390,2405,2411,2415 /* POS */) THEN
          --marcar com false para nao listar
          pr_extrato_epr(vr_index).flglista:= FALSE;  
        END IF;        
        -- INICIO - PRJ298.3
        -- Não exibir no extrato
        IF NOT extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                        ,pr_tpemprst => 1) THEN
          /* Historicos que nao vao aparecer no relatorio, mas vao compor saldo */
          IF rw_craplem.cdhistor IN (1040,1041,1042,1043) THEN /* PP */
            -- marcar com false para nao listar / flgsaldo vem como true por default
            pr_extrato_epr(vr_index).flglista:= FALSE;  
          END IF;  
        IF rw_crapepr.tpemprst = 1 AND rw_craplem.cdhistor = 2409 THEN
          --
          pr_extrato_epr(vr_index).flglista := FALSE;
          --
        END IF;
        ELSE
          /* Estória 2 , nao exibir e não calcular para estes historicos */
          IF rw_craplem.cdhistor IN (2396,2397,2381,2382,2385,2400,3356,3357,3358,3359,1733,1735) THEN
            -- marcar com false para nao listar e nao calcular
            pr_extrato_epr(vr_index).flglista:= FALSE;  
            pr_extrato_epr(vr_index).flgsaldo:= FALSE;  
          END IF;  
             
        END IF;
        
        -- FIM - PRJ298.3
        /* Verifica se o contrato estah em prejuizo */
        IF rw_crapepr.tpemprst = 1 AND
           rw_crapepr.inprejuz = 1 AND 
           rw_craplem.dtmvtolt >= rw_crapepr.dtprejuz THEN
           
           /* Multa e Juros de Mora de Prejuizo */
           /* M324 - inclusao dos novos historicos de multas e juros */
           IF rw_craplem.cdhistor IN (1733,1734,1735,1736, 2382, 2411, 2415, 2423,2416,2390,2475,2394,2476,2735) THEN
             pr_extrato_epr(vr_index).flgsaldo := FALSE;
           END IF;  
           
        END IF;
             
        -- Se for POS e estiver Em Prejuizo
        IF rw_crapepr.tpemprst = 2 AND
           rw_crapepr.inprejuz = 1 THEN
          --
          IF rw_craplem.cdhistor IN(2471,2472,2358,2359,2878,2884,2885,2888,2405,2411,2415,2735) THEN
            --
            pr_extrato_epr(vr_index).flgsaldo:= FALSE;
            --
          END IF;
          --
        END IF;
              
        --Valor Lancamento
        vr_vllantmo:= rw_craplem.vllanmto;
        /* Se lancamento de pagamento*/
        IF rw_craplem.cdhistor IN (1044,1039,1057,1045 /* PP */) THEN 
          --Se nao for primeira parcela
          IF vr_tab_flgpripa.EXISTS(rw_craplem.nrparepr) AND
             vr_tab_flgpripa(rw_craplem.nrparepr) = FALSE THEN

            /* Historico de juros de mora */
            CASE WHEN rw_craplem.cdhistor = 1044 THEN
                 vr_cdhistor := 1077; /* Devedor */ 
                 WHEN rw_craplem.cdhistor = 1045 THEN
                 vr_cdhistor := 1619; /* Aval */
                 WHEN rw_craplem.cdhistor = 1057 THEN
                 vr_cdhistor := 1620; /* Aval */                 
            ELSE     
                 vr_cdhistor := 1078; /* Devedor */
            END CASE;
               
            /* Achar juros de inadimplencia desta parcela */
            OPEN cr_craplem_his (pr_cdcooper => rw_craplem.cdcooper
                                ,pr_nrdconta => rw_craplem.nrdconta
                                ,pr_nrctremp => rw_craplem.nrctremp
                                ,pr_nrparepr => rw_craplem.nrparepr
                                ,pr_dtmvtolt => rw_craplem.dtmvtolt
                                ,pr_cdhistor => vr_cdhistor);
            FETCH cr_craplem_his INTO rw_craplem_his;
            --Se encontrou
            IF cr_craplem_his%FOUND THEN
              --Acumular valor lancamento
              vr_vllantmo:= nvl(vr_vllantmo,0) + nvl(rw_craplem_his.vllanmto,0);
            END IF;  
            --Fechar Cursor
            CLOSE cr_craplem_his;                

            /* Historico de juros de multa */
            CASE WHEN rw_craplem.cdhistor = 1044 THEN
                 vr_cdhistor := 1047; /* Devedor */ 
                 WHEN rw_craplem.cdhistor = 1045 THEN
                 vr_cdhistor := 1540; /* Aval */
                 WHEN rw_craplem.cdhistor = 1057 THEN
                 vr_cdhistor := 1618; /* Aval */                 
            ELSE     
                 vr_cdhistor := 1076; /* Devedor */
            END CASE;

            /* Achar juros de inadimplencia desta parcela */
            OPEN cr_craplem_his (pr_cdcooper => rw_craplem.cdcooper
                                ,pr_nrdconta => rw_craplem.nrdconta
                                ,pr_nrctremp => rw_craplem.nrctremp
                                ,pr_nrparepr => rw_craplem.nrparepr
                                ,pr_dtmvtolt => rw_craplem.dtmvtolt
                                ,pr_cdhistor => vr_cdhistor);
            FETCH cr_craplem_his INTO rw_craplem_his;
            --Se encontrou
            IF cr_craplem_his%FOUND THEN
              --Acumular valor lancamento
              vr_vllantmo:= nvl(vr_vllantmo,0) + nvl(rw_craplem_his.vllanmto,0);
            END IF;  
            --Fechar Cursor
            CLOSE cr_craplem_his; 
            
            -- Historico de IOF 
            CASE WHEN rw_craplem.cdhistor IN(1044,1045) THEN
               vr_cdhistor := 2311; -- Devedor 
            ELSE     
               vr_cdhistor := 2312; -- Devedor 
            END CASE;  

            /* Achar juros de inadimplencia desta parcela */
            OPEN cr_craplem_his (pr_cdcooper => rw_craplem.cdcooper
                                ,pr_nrdconta => rw_craplem.nrdconta
                                ,pr_nrctremp => rw_craplem.nrctremp
                                ,pr_nrparepr => rw_craplem.nrparepr
                                ,pr_dtmvtolt => rw_craplem.dtmvtolt
                                ,pr_cdhistor => vr_cdhistor);
            FETCH cr_craplem_his INTO rw_craplem_his;
            --Se encontrou
            IF cr_craplem_his%FOUND THEN
              --Acumular valor lancamento
              vr_vllantmo:= nvl(vr_vllantmo,0) + nvl(rw_craplem_his.vllanmto,0);
            END IF;  
            --Fechar Cursor
            CLOSE cr_craplem_his;
            --Atualizar tabela primeira parcela
            vr_tab_flgpripa(rw_craplem.nrparepr):= TRUE;  
          END IF;  
        END IF; --rw_craplem.cdhistor IN (1044,1039)
        --Selecionar Historicos
        OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                        ,pr_cdhistor => rw_craplem.cdhistor);
        FETCH cr_craphis INTO rw_craphis;
        --Se nao encontrou
        IF cr_craphis%NOTFOUND THEN
          pr_extrato_epr(vr_index).dshistor:= rw_craplem.cdhistor;
          pr_extrato_epr(vr_index).dshistoi:= rw_craplem.cdhistor;
          pr_extrato_epr(vr_index).indebcre:= '*';
        ELSE 
          pr_extrato_epr(vr_index).dshistor:= to_char(rw_craphis.cdhistor,'fm0000')||' - '|| rw_craphis.dshistor;
          pr_extrato_epr(vr_index).dshistoi:= rw_craphis.dshistor;
          pr_extrato_epr(vr_index).indebcre:= rw_craphis.indebcre;
          pr_extrato_epr(vr_index).dsextrat:= rw_craphis.dsextrat;
        END IF;
        --Fechar Cursor
        CLOSE cr_craphis; 
        
        /* Pagamento de avalista */
        IF rw_craphis.cdhistor IN (1057,1045,1620,1619,1618,1540 /* PP */
                                  ,2335,2336,2377,2375,2369,2367 /* POS */) 
          AND rw_craplem.nrseqava > 0 THEN
           
           pr_extrato_epr(vr_index).dshistor := pr_extrato_epr(vr_index).dshistor || ' ' ||
                                                TO_CHAR(rw_craplem.nrseqava);
           pr_extrato_epr(vr_index).dsextrat := rw_craphis.dsextrat || ' ' || 
                                                TO_CHAR(rw_craplem.nrseqava);
        END IF;
        
        --Historico de Debito
        IF rw_craphis.cdhistor IN (1077,1078,1619,1620) THEN
           pr_extrato_epr(vr_index).indebcre:= 'D'; 
        END IF;
        
        --Popular informacoes no Extrato
        pr_extrato_epr(vr_index).dtmvtolt:= rw_craplem.dtmvtolt;
        pr_extrato_epr(vr_index).nranomes:= to_number(to_char(rw_craplem.dtmvtolt,'YYYYMM'));
        pr_extrato_epr(vr_index).cdhistor:= rw_craplem.cdhistor;
        pr_extrato_epr(vr_index).nrseqdig:= rw_craplem.nrseqdig;
        pr_extrato_epr(vr_index).cdagenci:= rw_craplem.cdagenci;
        pr_extrato_epr(vr_index).cdbccxlt:= rw_craplem.cdbccxlt;
        pr_extrato_epr(vr_index).nrdolote:= rw_craplem.nrdolote;
        pr_extrato_epr(vr_index).nrdocmto:= rw_craplem.nrdocmto;
        pr_extrato_epr(vr_index).vllanmto:= vr_vllantmo;
        pr_extrato_epr(vr_index).txjurepr:= rw_craplem.txjurepr;
        pr_extrato_epr(vr_index).tpemprst:= rw_crapepr.tpemprst;
        pr_extrato_epr(vr_index).qtdiacal:= rw_craplem.qtdiacal;
        pr_extrato_epr(vr_index).vltaxprd:= rw_craplem.vltaxprd;        
        
        IF rw_craplem.cdhistor IN(1039,1044,1045,1057 /* PP */
                             ,3026,3027 /*Consignado*/
                                 ,2331,2330,2336,2335 /* POS */) THEN
          pr_extrato_epr(vr_index).cdorigem:= rw_craplem.cdorigem;
        ELSE
          pr_extrato_epr(vr_index).cdorigem:= ' ';
        END IF;
        
        --Numero parcelas diferente zero
        IF NVL(rw_craplem.nrparepr,0) <> 0 THEN
          pr_extrato_epr(vr_index).nrparepr:= rw_craplem.nrparepr;
        ELSIF rw_craplem.cdhistor IN (1040,1041,1042,1043 /* PP */
                                     ,2471,2472,2358,2359 /* POS */) THEN
          /* Se ajuste, parcela = 99 para aparecer por ultimo no extrato*/
          pr_extrato_epr(vr_index).nrparepr:= NULL;
        END IF;  
        
        IF extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => pr_cdcooper
                                    ,pr_tpemprst => 1) = TRUE THEN 
          --> Necesario verificar antes de criar se ja existe os novos historicos para esse contrato
          -- Ver se nao tem o lancamento do historico novo nesse mesmo dia, tratamento para o legado
          -- para nao mexer nos lancamentos com baca ou data de corte, tratamos somente na impressao
          IF rw_craplem.cdhistor IN (2411, 2415,1733,1735) THEN
            OPEN cr_lemprej(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => rw_craplem.dtmvtolt);
            FETCH cr_lemprej INTO rw_lemprej;
            IF cr_lemprej%NOTFOUND THEN 
              vr_index_novo := pr_extrato_epr.count + 1;
              pr_extrato_epr(vr_index_novo) := pr_extrato_epr(vr_index);
              pr_extrato_epr(vr_index_novo).flglista:= TRUE;  
              pr_extrato_epr(vr_index_novo).flgsaldo:= TRUE;
              pr_extrato_epr(vr_index_novo).indebcre:= 'D';
              
              IF rw_craplem.cdhistor IN (2411) THEN   
                OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp);
                FETCH cr_craplcr INTO rw_craplcr;
                CLOSE cr_craplcr;
                IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN 
                  vr_cdhistorlem := 3053; /* 3053 - MULTA FINANCIAMENTO PRE-FIXADO */  
                ELSE --'EMPRESTIMO'
                  vr_cdhistorlem := 3051; /* 3051 - MULTA EMPRESTIMO PRE-FIXADO */  
                END IF;
              ELSIF rw_craplem.cdhistor IN (2415) THEN 
                OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp);
                FETCH cr_craplcr INTO rw_craplcr;
                CLOSE cr_craplcr;
                IF rw_craplcr.dsoperac = 'FINANCIAMENTO' THEN 
                  vr_cdhistorlem := 3054; /* 3054 - JURO MORA FINANCIAMENTO PRE-FIXADO */  
                ELSE --'EMPRESTIMO'
                  vr_cdhistorlem := 3052; /* 3052 - JURO MORA EMPRESTIMO PRE-FIXADO */
                END IF; 
              END IF;
              OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                             ,pr_cdhistor => vr_cdhistorlem);
              FETCH cr_craphis INTO rw_craphis;
              pr_extrato_epr(vr_index_novo).dshistor:= to_char(rw_craphis.cdhistor,'fm0000')||' - '|| rw_craphis.dshistor;
              pr_extrato_epr(vr_index_novo).dshistoi:= rw_craphis.dshistor;
              pr_extrato_epr(vr_index_novo).dsextrat:= rw_craphis.dsextrat;
              CLOSE cr_craphis;
            END IF;
            CLOSE cr_lemprej;
          END IF;
        END IF;
      END LOOP;
        
      -- Se foi solicitado geração de LOG
      IF pr_flgerlog THEN
        -- Chamar geração de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;    
      --Retorno OK
      pr_des_reto:= 'OK';  
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;  
      WHEN OTHERS THEN
        
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na pc_obtem_extrato_emprestimo --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;    
      END;
    END pc_obtem_extrato_emprest; 
BEGIN
  dbms_output.enable(NULL);

  FOR rw_crapcop IN cr_crapcop LOOP
    --Buscar Data do Sistema para a cooperativa 
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
    --Limpar tabela Emprestimo
      vr_tab_extrato_epr.DELETE; 
      pr_tab_extrato_epr_aux.DELETE;
      vr_vlsaldo1 := 0;
      --Obter Extrato do Emprestimo
      pc_obtem_extrato_emprest (pr_cdcooper    => rw_crapcop.cdcooper            --Codigo Cooperativa
                               ,pr_cdagenci    => 0                              --Codigo Agencia
                               ,pr_nrdcaixa    => 0                              --Numero do Caixa
                               ,pr_cdoperad    => 1                              --Codigo Operador
                               ,pr_nmdatela    => 'ATENDA'                       --Nome da Tela
                               ,pr_idorigem    => 5                              --Origem dos Dados
                               ,pr_nrdconta    => rw_principal.nrdconta          --Numero da Conta do Associado
                               ,pr_idseqttl    => 1                              --Sequencial do Titular
                               ,pr_nrctremp    => rw_principal.nrctremp          --Numero Contrato Emprestimo           
                               ,pr_dtiniper    => NULL                           --Inicio periodo Extrato
                               ,pr_dtfimper    => to_date('05/01/2021')          --Final periodo Extrato
                               ,pr_flgerlog    => FALSE                          --Imprimir log
                               ,pr_extrato_epr => vr_tab_extrato_epr             --Tipo de tabela com extrato emprestimo
                               ,pr_des_reto    => vr_des_reto                    --Retorno OK ou NOK
                               ,pr_tab_erro    => vr_tab_erro);                  --Tabela de Erros
      
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN 
        RETURN;
      END IF; 
      
      --Percorrer todo o extrato emprestimo para carregar tabela auxiliar
      vr_index_novo:= vr_tab_extrato_epr.FIRST;
      WHILE vr_index_novo IS NOT NULL LOOP
        BEGIN
          --Primeira Ocorrencia
          IF vr_flgloop = FALSE THEN
            /* Saldo Inicial */
            vr_vlsaldo1:= vr_tab_extrato_epr(vr_index_novo).vllanmto; 
            vr_flgloop := TRUE;
            --Proximo Registro
            RAISE vr_exc_proximo;            
          END IF; 
          --Se for Credito
          IF vr_tab_extrato_epr(vr_index_novo).indebcre = 'C' THEN
            --Se possuir Saldo
            IF vr_tab_extrato_epr(vr_index_novo).flgsaldo THEN
              vr_vlsaldo1:= nvl(vr_vlsaldo1,0) - vr_tab_extrato_epr(vr_index_novo).vllanmto;
            END IF;    
          ELSIF vr_tab_extrato_epr(vr_index_novo).indebcre = 'D' THEN 
            --Valor Debito
            --Se possuir Saldo
            IF vr_tab_extrato_epr(vr_index_novo).flgsaldo THEN
              vr_vlsaldo1:= nvl(vr_vlsaldo1,0) + vr_tab_extrato_epr(vr_index_novo).vllanmto;
            END IF;    
          END IF;
          IF to_char(vr_tab_extrato_epr(vr_index_novo).dtmvtolt, 'DD/MM/YYYY') IN ('30/12/2020', '31/12/2020') THEN
            vr_vldezemb := vr_vlsaldo1;
          END IF;
        EXCEPTION
          WHEN vr_exc_proximo THEN
            NULL;
        END;       
        --Proximo Registro Extrato
        vr_index_novo:= vr_tab_extrato_epr.NEXT(vr_index_novo);
      END LOOP; 
      
      IF rw_principal.inprejuz = 1 AND extr0002.fn_extrato_prejuizo_ativo(pr_cdcooper => rw_crapcop.cdcooper
                                                                       ,pr_tpemprst => 1) = TRUE THEN
              
        rw_craplem5 := NULL;
        vr_vlsdprej := 0;
        OPEN cr_craplem5(pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => rw_principal.nrdconta
                        ,pr_nrctremp => rw_principal.nrctremp
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplem5 INTO rw_craplem5;
        CLOSE cr_craplem5;

        vr_vljurdia := 0;

        prej0001.pc_calcula_juros_diario(pr_cdcooper => rw_crapcop.cdcooper            -- IN
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- IN
                                        ,pr_dtmvtoan => rw_crapdat.dtmvtoan -- IN
                                        ,pr_nrdconta => rw_principal.nrdconta            -- IN
                                        ,pr_nrctremp => rw_principal.nrctremp    -- IN
                                        ,pr_vljurdia => vr_vljurdia            -- OUT
                                        ,pr_cdcritic => vr_cdcritic            -- OUT
                                        ,pr_dscritic => vr_dscritic            -- OUT
                                        );  
        --
        vr_vlsdprej := nvl(rw_principal.vlsdprej, 0) +
                      (nvl(rw_principal.vlttmupr, 0) - nvl(rw_principal.vlpgmupr, 0)) +
                      (nvl(rw_principal.vlttjmpr, 0) - nvl(rw_principal.vlpgjmpr, 0)) +
                      (nvl(rw_principal.vltiofpr, 0) - nvl(rw_principal.vlpiofpr, 0)); 
                            
        IF vr_vlsdprej > 0 THEN
          vr_vlsdprej := vr_vlsdprej + (nvl(vr_vljurdia,0) - nvl(rw_craplem5.vllanmto, 0));
        END IF;
        
      END IF;
     
      IF vr_vlsdprej < vr_vlsaldo1 THEN
        OPEN cr_crapdir(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_principal.nrdconta);
        FETCH cr_crapdir INTO rw_crapdir;
        CLOSE cr_crapdir;
        -- Total atual da crapdir
        vr_vlsddvem := rw_crapdir.vlsddvem;
        -- Tirar o contrato antigo
        OPEN cr_devedor(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_principal.nrdconta
                       ,pr_nrctremp => rw_principal.nrctremp);
        FETCH cr_devedor INTO rw_devedor;
        CLOSE cr_devedor;
        vr_vlsddvem := vr_vlsddvem - rw_devedor.vlsdeved;
        -- Atualizar devedor do contrato
        BEGIN 
          UPDATE crapepr
             SET vlsdprej = vr_vlsaldo1
           WHERE cdcooper = rw_crapcop.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND nrctremp = rw_principal.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro crapepr na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || vr_vlsdprej || '/' || vr_vlsaldo1 || ' - ' || SQLERRM);
        END;
        -- Somar o novo devedor na crapdir
        BEGIN 
          UPDATE crapdir
             SET vlsddvem = vr_vlsddvem + vr_vldezemb
           WHERE cdcooper = rw_crapcop.cdcooper
             AND nrdconta = rw_principal.nrdconta
             AND dtmvtolt = '31/12/2020';
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('Erro crapdir na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || SQLERRM);
        END;
        dbms_output.put_line('Atualizado na Conta: ' || rw_principal.nrdconta || ' Contrato: ' || rw_principal.nrctremp || ' - ' || vr_vlsdprej || '/' || vr_vlsaldo1);
      END IF;
    END LOOP;
    COMMIT;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, 'Erro: '||SQLERRM);
END;
0
0
