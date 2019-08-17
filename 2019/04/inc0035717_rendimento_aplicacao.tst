PL/SQL Developer Test script 3.0
903
/* Ajusta aplicacoes nao resgatadas */
declare 


  pr_cdcooper crapcop.cdcooper%TYPE;
  pr_dtiniano date := to_date('01/01/2018','dd/mm/rrrr');
  pr_dstitulo varchar2(500) := 'rendimento-cooper';

  vr_cdidiari NUMBER(10,8); 
  vr_dscritic varchar2(5000) := ' ';
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_nrdocmto craplap.nrdocmto%TYPE;
  vr_nrdocmto_inicial craplap.nrdocmto%TYPE := 655000;
  vr_nrseqdig craplap.nrseqdig%TYPE := 0;
  vr_laprowid rowid;
  vr_vltxapli NUMBER;  
  vr_vlrendim NUMBER(18,2);  
  vr_vltotal  NUMBER(18,2) := 0;
  vr_qtd      PLS_INTEGER := 0;
  vr_saldo_cal_2018 number(18,4);
  vr_dstextab varchar2(1000);
  vr_dtinitax   DATE;
  vr_dtfimtax   DATE;
  vr_vlrtaxa number;
  vr_flgarantia boolean:= false;
  
  TYPE typ_tab_saldo_2018 IS
   TABLE OF NUMBER(22,8)
    INDEX BY VARCHAR2(20);
  vr_tab_saldo_2018 typ_tab_saldo_2018;
  vr_index VARCHAR(20);
  
  vr_tem_critica boolean := false;
  vr_dia      date;
  vr_excsaida EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0035717';
  vr_nmarqimp        VARCHAR2(100)  := pr_dstitulo||'-log.txt';  
  vr_nmarqimp2       VARCHAR2(100)  := pr_dstitulo||'-sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := pr_dstitulo||'-falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := pr_dstitulo||'-backup.txt';
  vr_nmarqimp5       VARCHAR2(100)  := 'rendimento_cooperativa.csv';
  vr_nmarqimp6       VARCHAR2(100)  := 'alteracao_faixas_abril.csv';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  vr_ind_arquiv5     utl_file.file_type;
  vr_ind_arquiv6     utl_file.file_type;
  
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  cursor cr_crapmfx (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_dtmvtolt in crapdat.dtmvtolt%type
                    ,pr_tpmoefix in crapmfx.tpmoefix%type)IS
  select *
    from crapmfx x
   where x.tpmoefix = pr_tpmoefix
     and x.dtmvtolt = pr_dtmvtolt
     and x.cdcooper = pr_cdcooper;
  rw_crapmfx cr_crapmfx%ROWTYPE;

cursor cr_lancamentos is
select o.cdcooper
      ,o.nrdconta
      ,o.nraplica
      ,o.dtmvtolt
      ,o.vlaplica
      ,o.qtdiauti
      ,o.vlsaldo_acum
      ,o.vlfaixa_calculada
      ,o.vlfaixa_contratada
      ,o.vlsltxmx
      ,o.vlsltxmm
      ,o.dtatslmx
      ,o.tpaplica
      ,o.valor
      ,o.progress_recid
  from(
SELECT rda.cdcooper 
      ,rda.nrdconta 
      ,rda.nraplica 
      ,rda.dtmvtolt 
      ,rda.vlaplica 
      ,rda.qtdiauti 
      ,rda.vlsltxmx
      ,rda.vlsltxmm
      ,rda.dtatslmx
      ,rda.tpaplica
      ,(decode(his.indebcre,'D',-1,1) * lap.vllanmto) valor
      ,rda.progress_recid      
      ,(select sum(cap.vlsddapl) 
         from crapcap cap 
        where cap.cdcooper = rda.cdcooper 
          and cap.nrdconta = rda.nrdconta 
          and cap.nraplica = rda.nraplica) vlsaldo_acum 
      ,(select max(ftx.perapltx) 
          from crapftx ftx 
         where ftx.cdcooper = rda.cdcooper 
           and ftx.tptaxrdc = rda.tpaplica
           and ftx.cdperapl = ttx.cdperapl 
           and ftx.vlfaixas <= (select sum(cap.vlsddapl) + rda.vlaplica
                                  from crapcap cap 
                                 where cap.cdcooper = rda.cdcooper 
                                   and cap.nrdconta = rda.nrdconta 
                                   and cap.nraplica = rda.nraplica)) vlfaixa_calculada 
      ,(select distinct lap.txaplica
          from craplap lap
         where lap.cdcooper = rda.cdcooper
           and lap.nrdconta = rda.nrdconta
           and lap.nraplica = rda.nraplica
           and lap.dtmvtolt = rda.dtmvtolt) vlfaixa_contratada 
  FROM craprda rda, 
       crapttx ttx,
       craplap lap, 
       craphis his
 WHERE rda.cdcooper not in( 2,8)
   and rda.insaqtot = 0
   and rda.tpaplica = 8
   and rda.dtmvtolt > '01/01/2018'
   and rda.dtmvtolt < '01/04/2019'
   and ttx.cdcooper = rda.cdcooper
   AND ttx.tptaxrdc = 8
   and ttx.qtdiacar = rda.qtdiauti   
   and lap.cdcooper = rda.cdcooper
   and lap.nrdconta = rda.nrdconta
   and lap.nraplica = rda.nraplica 
   and lap.dtmvtolt = rda.dtmvtolt
   and not exists(select 1
                    from craplap lap
                   where lap.cdcooper = rda.cdcooper
                     and lap.nrdconta = rda.nrdconta
                     and lap.nraplica = rda.nraplica
                     and lap.cdhistor in (534,531))  -- Sem Resgate e sem reversão
   AND his.cdcooper = lap.cdcooper
   AND his.cdhistor = lap.cdhistor
) o
where vlfaixa_calculada <> vlfaixa_contratada
  and vlfaixa_calculada > vlfaixa_contratada;
  rw_cr_lancamentos cr_lancamentos%rowtype;
  
  /* LANCAMENTOS Abril */  
cursor cr_lancamentos_abril is
select o.cdcooper
      ,o.nrdconta
      ,o.nraplica
      ,o.dtmvtolt
      ,o.vlaplica
      ,o.qtdiauti
      ,o.vlsaldo_acum
      ,o.vlfaixa_calculada
      ,o.vlfaixa_contratada
      ,o.vlsltxmx
      ,o.vlsltxmm
      ,o.dtatslmx
      ,o.tpaplica
      ,o.valor
      ,o.progress_recid
  from(
SELECT rda.cdcooper 
      ,rda.nrdconta 
      ,rda.nraplica 
      ,rda.dtmvtolt 
      ,rda.vlaplica 
      ,rda.qtdiauti 
      ,rda.vlsltxmx
      ,rda.vlsltxmm
      ,rda.dtatslmx
      ,rda.tpaplica
      ,(decode(his.indebcre,'D',-1,1) * lap.vllanmto) valor
      ,rda.progress_recid      
      ,(select sum(cap.vlsddapl) 
         from crapcap cap 
        where cap.cdcooper = rda.cdcooper 
          and cap.nrdconta = rda.nrdconta 
          and cap.nraplica = rda.nraplica) vlsaldo_acum 
      ,(select max(ftx.perapltx) 
          from crapftx ftx 
         where ftx.cdcooper = rda.cdcooper 
           and ftx.tptaxrdc = rda.tpaplica
           and ftx.cdperapl = ttx.cdperapl 
           and ftx.vlfaixas <= (select sum(cap.vlsddapl) + rda.vlaplica
                                  from crapcap cap 
                                 where cap.cdcooper = rda.cdcooper 
                                   and cap.nrdconta = rda.nrdconta 
                                   and cap.nraplica = rda.nraplica)) vlfaixa_calculada 
      ,(select distinct lap.txaplica
          from craplap lap
         where lap.cdcooper = rda.cdcooper
           and lap.nrdconta = rda.nrdconta
           and lap.nraplica = rda.nraplica
           and lap.dtmvtolt = rda.dtmvtolt) vlfaixa_contratada 
  FROM craprda rda, 
       crapttx ttx,
       craplap lap, 
       craphis his
 WHERE rda.cdcooper not in( 2,8)
   and rda.insaqtot = 0
   and rda.tpaplica = 8
   and rda.dtmvtolt >= '01/04/2019'
   and rda.dtmvtolt <= '16/04/2019'
   and ttx.cdcooper = rda.cdcooper
   AND ttx.tptaxrdc = 8
   and ttx.qtdiacar = rda.qtdiauti   
   and lap.cdcooper = rda.cdcooper
   and lap.nrdconta = rda.nrdconta
   and lap.nraplica = rda.nraplica 
   and lap.dtmvtolt = rda.dtmvtolt
   and not exists(select 1
                    from craplap lap
                   where lap.cdcooper = rda.cdcooper
                     and lap.nrdconta = rda.nrdconta
                     and lap.nraplica = rda.nraplica
                     and lap.cdhistor in (534,531))  -- Sem Resgate e sem reversão
     
   AND his.cdcooper = lap.cdcooper
   AND his.cdhistor = lap.cdhistor
) o
where vlfaixa_calculada <> vlfaixa_contratada
  and vlfaixa_calculada > vlfaixa_contratada;
  rw_cr_lancamentos_abril cr_lancamentos_abril%rowtype;
  /********************/

 CURSOR cr_craplap_2018 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta  IN craprda.nrdconta%TYPE
                        ,pr_nraplica  IN craprda.nraplica%TYPE) is
  select lap.nrdconta
        ,lap.nraplica
        ,(decode(his.indebcre,'D',-1,1) * lap.vllanmto) valor
    from craplap lap, craphis his, craprda rda
   where lap.cdcooper = pr_cdcooper
     and lap.cdcooper = rda.cdcooper
     and lap.nrdconta = rda.nrdconta
     and lap.nraplica = rda.nraplica
     and rda.insaqtot = 0
     and rda.cdcooper = pr_cdcooper
     and rda.nrdconta = pr_nrdconta
     and rda.nraplica = pr_nraplica
     
     AND his.cdcooper = lap.cdcooper
     AND his.cdhistor = lap.cdhistor;
  rw_craplap_2018 cr_craplap_2018%ROWTYPE;

 CURSOR cr_craplap (pr_cdcooper  IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta  IN craprda.nrdconta%TYPE
                   ,pr_nraplica  IN craprda.nraplica%TYPE
                   ,pr_dtmvtolt  IN craprda.dtmvtolt%TYPE) IS
  SELECT cl.*
    FROM craplap cl
   WHERE cl.cdcooper = pr_cdcooper
     AND cl.nrdconta = pr_nrdconta
     AND cl.nraplica = pr_nraplica
     AND cl.dtmvtolt = pr_dtmvtolt;
  rw_craplap cr_craplap%rowtype; 
  
 CURSOR cr_craplot (pr_cdcooper  IN crapcop.cdcooper%TYPE
                   ,pr_dtmvtolt  IN craplot.dtmvtolt%TYPE) IS
  SELECT lot.*, lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = 1
     AND lot.cdbccxlt = 100
     AND lot.nrdolote = 8480;
  rw_craplot cr_craplot%rowtype;   

  
  FUNCTION fn_round(pr_vlorigem IN NUMBER
                   ,pr_qtarredo IN INTEGER) RETURN NUMBER IS
  BEGIN    
    BEGIN
      -- Somente efetuar o arredondamento de 10 se a quantidade de
      -- casas desejadas for inferior a 10 (limite Progress)
      IF pr_qtarredo < 10 THEN
        -- Efetuar um Round com 10 internamente e apos o Round desejado
        RETURN ROUND(ROUND(pr_vlorigem,10),pr_qtarredo);
      ELSE
        -- Arredondar somente a quantidade de casas passada
        -- pois do contrario teriamos perda de valor.
        RETURN ROUND(pr_vlorigem,pr_qtarredo);
      END IF;
    END;
  END fn_round;

  function formata(pr_valor NUMERIC) RETURN VARCHAR2 is
  BEGIN
    return replace(pr_valor,',','.');
  END;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;

  procedure pc_calculo_garantia (pr_txaplica in craplap.txaplica%type                                
                                ,pr_dtmvtolt in crapdat.dtmvtolt%type
                                ,pr_txdiapop out number) is
    vr_controle   EXCEPTION;
    vr_txaplmes   NUMBER(15,8);
    vr_txaplica   NUMBER(15,8);
    vr_dtinipop   DATE;
    vr_txmespop   NUMBER(10,8);
    vr_txdiapop   NUMBER(10,8);
    vr_dtiniper   craprda.dtiniper%TYPE;
    vr_datlibpr   DATE;
    vr_vlmoefix   number;
    
    CURSOR cr_craptrd(pr_dtiniper IN DATE) IS
    SELECT trd.qtdiaute
      FROM craptrd trd
     WHERE cdcooper = pr_cdcooper
       AND dtiniper = pr_dtiniper
     ORDER BY progress_recid;
  vr_qtdiaute craptrd.qtdiaute%TYPE;
  begin
        
      BEGIN
        -- Usar poupanca de um mes atras.
        vr_dtinipop := to_date(to_char(pr_dtmvtolt, 'DD') || '/' || to_char(to_char(pr_dtmvtolt, 'MM') - 1) || '/' || to_char(pr_dtmvtolt, 'RRRR'), 'DD/MM/RRRR');
      EXCEPTION
        WHEN others THEN
          -- Tratar anos anteriores.
          -- Caso não exista a data, pegar primeiro dia do mes.
          IF to_number(to_char(pr_dtmvtolt, 'MM')) = 1 THEN
            vr_dtinipop := pr_dtmvtolt - 31;
          ELSE
            vr_dtinipop := to_date('01/' || to_char(pr_dtmvtolt, 'MM') || '/' || to_char(pr_dtmvtolt, 'RRRR'), 'DD/MM/RRRR');
          END IF;
      END;

      -- Limpar auxiliar de moeda
      vr_vlmoefix := NULL;

      -- Data de liberacao do projeto novo indexador de poupanca
      vr_datlibpr := to_date('01/07/2014','dd/mm/yyyy');
          
      IF pr_dtmvtolt >= to_date('04/05/2012','dd/mm/yyyy') AND
         pr_dtmvtolt >= vr_datlibpr THEN
         -- Busca valor de moeda de saida             
         OPEN cr_crapmfx(pr_cdcooper, vr_dtinipop, 20);
         FETCH cr_crapmfx INTO rw_crapmfx;
         IF cr_crapmfx%NOTFOUND THEN
           vr_dscritic := 'crapmfx! Erro.';
           falha(vr_dscritic);
           RAISE vr_excsaida;
         else
           vr_vlmoefix:= rw_crapmfx.vlmoefix;
         END IF;
         close cr_crapmfx;
      ELSE
         -- Busca valor de moeda de saida
         -- Montar a chave do registro com o tipo + data
         OPEN cr_crapmfx(pr_cdcooper, vr_dtinipop, 8);
         FETCH cr_crapmfx INTO rw_crapmfx;
         IF cr_crapmfx%NOTFOUND THEN
           vr_dscritic := 'crapmfx! Erro.';
           falha(vr_dscritic);
           RAISE vr_excsaida;
         else
           vr_vlmoefix:= rw_crapmfx.vlmoefix;
         END IF;
         close cr_crapmfx;
      END IF;

      -- Buscar a data na tabela
      OPEN cr_craptrd(pr_dtiniper => vr_dtinipop);
      FETCH cr_craptrd
       INTO vr_qtdiaute;
      CLOSE cr_craptrd;

      -- Calcula taxa de poupanca
      APLI0001.pc_calctx_poupanca(pr_cdcooper
                                 ,vr_qtdiaute
                                 ,vr_vlmoefix
                                 ,vr_txmespop
                                 ,vr_txdiapop);

      pr_txdiapop := vr_txdiapop;
      
  end pc_calculo_garantia;

begin

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
    
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp5       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv5     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp6       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv6     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  loga('Inicio Processo');  
  
  /*******************/
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv5,'Cooperativa;'||
                                                'Conta;'||
                                                'Data Aplicacao;'||
                                                'Aplicacao;'||
                                                'Valor Aplicado;'||
                                                'CDI Contratado;'||
                                                'Saldo Aplicado Atual;'||
                                                'CDI Calculado;'||
                                                'Saldo Recalculado;'||
                                                'Diferenca;'||chr(13));
  /*******************/
  
  FOR rw_lancamentos IN cr_lancamentos LOOP    
  
    vr_flgarantia:= false;
    
    -- Verifica a data da cooper viacredi
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_lancamentos.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      loga('Data nao encontrada!');
      RAISE vr_excsaida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    IF rw_crapdat.inproces > 1 THEN
      vr_dscritic := 'Batch em execução! Cooper: '|| rw_lancamentos.cdcooper;
      falha(vr_dscritic);
      RAISE vr_excsaida;
    END IF;
  
    FOR rw_craplap_2018 IN cr_craplap_2018 (pr_cdcooper => rw_lancamentos.cdcooper
                                           ,pr_nrdconta => rw_lancamentos.nrdconta
                                           ,pr_nraplica => rw_lancamentos.nraplica) LOOP
      vr_index := lpad(rw_craplap_2018.nrdconta,10,'0')||lpad(rw_craplap_2018.nraplica,10,'0');
      if vr_tab_saldo_2018.exists(vr_index) then
        vr_tab_saldo_2018(vr_index) := vr_tab_saldo_2018(vr_index) + rw_craplap_2018.valor;
      else
        vr_tab_saldo_2018(vr_index) := rw_craplap_2018.valor;
      end if;
    END LOOP;  
    
    loga('Carregou os saldos 2018 da conta: '||to_char(rw_lancamentos.nrdconta));  
    
    if nvl(pr_cdcooper,0) <> rw_lancamentos.cdcooper then    
      SELECT max(nvl(nrseqdig,0)) vr_nrseqdig into vr_nrseqdig
        FROM craplap
       WHERE cdcooper = rw_lancamentos.cdcooper
         and dtmvtolt = rw_crapdat.dtmvtolt
         and cdagenci = 1
         and cdbccxlt = 100
         and nrdolote = 8480;
         
       -- Data de fim e inicio da utilizacao da taxa de poupanca.
      -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
      --  a poupanca, a cooperativa opta por usar ou nao.
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_lancamentos.cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'MXRENDIPOS'
                                               ,pr_tpregist => 1);
                                               
      -- Se não encontrar
      IF TRIM(vr_dstextab) IS NULL THEN
        -- Utilizar datas padrão
        vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
        vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
      ELSE
        -- Utilizar datas da tabela
        vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
        vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
      END IF;
    end if;
     
    -- Coop ant. 
    pr_cdcooper:= rw_lancamentos.cdcooper;
        
    vr_qtd := vr_qtd + 1;
    loga('Ajustando: Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica|| ' Proc: '||vr_qtd);
    
    -- Backup craprda
    backup('update craprda set vlsltxmx = '|| formata(rw_lancamentos.vlsltxmx) ||' ,vlsltxmm = '|| formata(rw_lancamentos.vlsltxmm) ||' where craprda.progress_recid = '''|| rw_lancamentos.progress_recid ||''';');
    
    OPEN cr_craplap(rw_lancamentos.cdcooper, rw_lancamentos.nrdconta, rw_lancamentos.nraplica, rw_lancamentos.dtmvtolt);
    FETCH cr_craplap INTO rw_craplap;
    IF cr_craplap%NOTFOUND THEN
      vr_dscritic := 'Taxa nao encontrada! Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica;
      falha(vr_dscritic);
      RAISE vr_excsaida;
    END IF;
    
    vr_index := lpad(rw_lancamentos.nrdconta,10,'0')||lpad(rw_lancamentos.nraplica,10,'0');
    IF NOT vr_tab_saldo_2018.exists(vr_index) THEN
      vr_dscritic := 'Saldo nao encontrado! Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica;
      falha(vr_dscritic);
      RAISE vr_excsaida;
    END IF;

    vr_saldo_cal_2018 := vr_tab_saldo_2018(vr_index);
    
    IF rw_lancamentos.tpaplica = 8 THEN
      /* RDC POS */
      vr_cdhistor := 529;
  
      OPEN cr_crapmfx(rw_lancamentos.cdcooper, rw_lancamentos.dtmvtolt, 6);
      FETCH cr_crapmfx INTO rw_crapmfx;
      IF cr_crapmfx%NOTFOUND THEN
        vr_dscritic := 'crapmfx! Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica;
        falha(vr_dscritic);
        RAISE vr_excsaida;
      END IF;
      close cr_crapmfx;

      vr_cdidiari := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
      --vr_vltxapli := TRUNC(fn_round(vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100,10),8);
      vr_vltxapli := fn_round((vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100 ) / 100 ,8);

      if rw_lancamentos.dtmvtolt > vr_dtinitax and vr_dtfimtax >=  rw_lancamentos.dtmvtolt then
        vr_flgarantia:= true;
        -- vr_vltxapli := (vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100);
         vr_vltxapli:= fn_round((vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100 ) / 100 ,8);
         
         pc_calculo_garantia(vr_cdidiari,rw_lancamentos.dtmvtolt,vr_vlrtaxa);
         
         IF vr_vltxapli < vr_vlrtaxa / 100 THEN
            vr_vltxapli := vr_vlrtaxa / 100;
         END IF;         
         
         vr_vlrendim := rw_lancamentos.vlaplica + TRUNC(fn_round(rw_lancamentos.vlaplica * vr_vltxapli,10), 8);
      else
        vr_flgarantia:= false;
         vr_vlrtaxa:= vr_cdidiari;
       -- vr_vlrendim := rw_lancamentos.vlaplica + (rw_lancamentos.vlaplica * vr_vlrtaxa * rw_lancamentos.vlfaixa_calculada / 100 / 100);
        vr_vlrendim := rw_lancamentos.vlaplica + (rw_lancamentos.vlaplica * vr_vlrtaxa * rw_lancamentos.vlfaixa_calculada / 100 / 100);
      end if;
      
      vr_dia      := rw_lancamentos.dtmvtolt + 1;
      LOOP      
        vr_dia := gene0005.fn_valida_dia_util(rw_lancamentos.cdcooper, vr_dia, 'P', true, true);      
        exit when vr_dia >= rw_lancamentos.dtatslmx;
        
        OPEN cr_crapmfx(rw_lancamentos.cdcooper, vr_dia, 6);
        FETCH cr_crapmfx INTO rw_crapmfx;
        IF cr_crapmfx%NOTFOUND THEN
          vr_dscritic := 'crapmfx! Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica;
          falha(vr_dscritic);
          RAISE vr_excsaida;
        END IF;
        close cr_crapmfx;
        
        vr_cdidiari := (POWER((1 + rw_crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100;
        --vr_vltxapli := TRUNC(fn_round(vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100,10),8);                       
        vr_vltxapli := fn_round((vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100 ) / 100 ,8);
        
        if vr_dia > vr_dtinitax and vr_flgarantia then
          --vr_vltxapli:= TRUNC(fn_round(vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100 / 100 ,10), 8);
          vr_vltxapli:= fn_round((vr_cdidiari * rw_lancamentos.vlfaixa_calculada / 100 ) / 100 ,8);
          
           pc_calculo_garantia(vr_cdidiari,vr_dia,vr_vlrtaxa);
           
           IF vr_vltxapli < vr_vlrtaxa / 100 THEN
              vr_vltxapli := vr_vlrtaxa / 100;              
           END IF;         
           
           vr_vlrendim := vr_vlrendim + vr_vlrendim * vr_vltxapli;
        else
           vr_vlrtaxa:= vr_cdidiari;
          -- vr_vlrendim := vr_vlrendim + (vr_vlrendim * vr_vlrtaxa * rw_lancamentos.vlfaixa_calculada / 100 / 100);
           vr_vlrendim := vr_vlrendim + (vr_vlrendim * vr_vlrtaxa * rw_lancamentos.vlfaixa_calculada / 100 / 100);
        end if;
        
        vr_dia := vr_dia + 1;
      end loop;
      
    ELSE
      vr_dscritic := 'Tipo aplicacao invalida! Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica || ' Tpaplica: '|| rw_lancamentos.tpaplica;
      falha(vr_dscritic);
      if cr_craplap%isopen then    
        CLOSE cr_craplap;
      end if;
      CONTINUE;
    END IF;
    
    vr_vltotal := vr_vlrendim - vr_saldo_cal_2018;
    --dbms_output.put_line(vr_vltotal);
    
    IF round(vr_vltotal,2) > 0 THEN
      /*******************/
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv5, rw_lancamentos.cdcooper||';'||
                                                     rw_lancamentos.nrdconta||';'||
                                                     rw_lancamentos.dtmvtolt||';'||
                                                     rw_lancamentos.nraplica||';'||
                                                     rw_lancamentos.vlaplica||';'||
                                                     rw_lancamentos.vlfaixa_contratada||';'||
                                                     vr_saldo_cal_2018||';'||
                                                     rw_lancamentos.vlfaixa_calculada||';'||
                                                     vr_vlrendim||';'||
                                                     vr_vltotal);
    end if;
    
    /*******************/
    if cr_craplap%isopen then    
      CLOSE cr_craplap;
    end if;

   /* Se o valor do rendimento for zero, nao vamos fazer nada */
    IF round(vr_vltotal,2) <= 0 THEN
      vr_dscritic := 'Rendimento calculado zerado. Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica || ' Tpaplica: '|| rw_lancamentos.tpaplica || ' Rend.: '|| formata(vr_vltotal) ;
      loga(vr_dscritic);
      CONTINUE;
    END IF;
    
        
    vr_nrseqdig := nvl(vr_nrseqdig,0) + 1;
    vr_nrdocmto := vr_nrdocmto_inicial + vr_nrseqdig;
    --vr_vltotal  := vr_vltotal + vr_vlrendim;
    BEGIN
      insert into craplap (cdagenci, cdbccxlt, dtmvtolt, nrdolote, nrdconta, cdhistor, nraplica, nrdocmto, nrseqdig, vllanmto, txaplica, dtrefere, txaplmes, cdcooper, vlrendmm)
         values
        (1   --cdagenci
        ,100 --cdbccxlt
        ,rw_crapdat.dtmvtolt
        ,8480 --nrdolote 
        ,rw_lancamentos.nrdconta
        ,vr_cdhistor
        ,rw_lancamentos.nraplica
        ,vr_nrdocmto
        ,vr_nrseqdig
        ,round(vr_vltotal,2)  --vllanmto
        ,rw_lancamentos.vlfaixa_calculada
        ,rw_craplap.dtrefere
        ,rw_lancamentos.vlfaixa_calculada 
        ,rw_lancamentos.cdcooper
        ,round(vr_vltotal,2)  -- vlrendmm
        ) returning rowid into vr_laprowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro inserindo craplap! '|| SQLERRM ||' - Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;

    backup('delete from craplap where rowid = '''|| vr_laprowid ||''';');
    
    BEGIN
      UPDATE craprda
         SET vlsltxmx = vlsltxmx + vr_vltotal
            ,vlsltxmm = vlsltxmm + vr_vltotal
       WHERE progress_recid = rw_lancamentos.progress_recid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro alterando craprda! '|| SQLERRM ||' - Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
    
    sucesso('Creditado para Cooper: '|| rw_lancamentos.cdcooper || ' Conta: ' ||rw_lancamentos.nrdconta || ' Aplica: '|| rw_lancamentos.nraplica || ' Valor : '|| vr_vlrendim || ' Valor anterior: ' || rw_lancamentos.vlsltxmx || ' Valor atualizado: ' || (rw_lancamentos.vlsltxmx + vr_vlrendim) );
    
    if cr_craplap%isopen then    
      CLOSE cr_craplap;
    end if;
    
    -- Commitar a cada 1000 registros
    -- para nao lockar as aplicacoes
    IF rw_lancamentos.cdcooper = 1 and MOD(vr_qtd,1000) = 0 THEN
      backup('/* COMITOU AQUI '|| vr_qtd || ' registro ');
      COMMIT;
    END IF;
    
    -- Atualiza capa de lote 
    OPEN cr_craplot(pr_cdcooper => rw_lancamentos.cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_craplot INTO rw_craplot;
    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;
      
      BEGIN
        INSERT INTO craplot(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,tplotmov
                           ,vlinfodb
                           ,vlcompdb
                           ,qtinfoln
                           ,qtcompln
                           ,vlinfocr
                           ,vlcompcr)
                     VALUES(rw_lancamentos.cdcooper
                           ,rw_crapdat.dtmvtolt
                           ,1
                           ,100
                           ,8480
                           ,9
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0)
                   RETURNING cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,tplotmov
                            ,nrseqdig
                            ,rowid
                        INTO rw_craplot.cdagenci
                            ,rw_craplot.cdbccxlt
                            ,rw_craplot.nrdolote
                            ,rw_craplot.tplotmov
                            ,rw_craplot.nrseqdig
                            ,rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          vr_dscritic := 'Erro inserindo craplot! '|| SQLERRM ||' - Cooper: '|| rw_lancamentos.cdcooper || ' Data: ' ||rw_lancamentos.dtmvtolt;
          falha(vr_dscritic);
          RAISE vr_excsaida;
      END;
    ELSE
      CLOSE cr_craplot;
    END IF;  
    
    BEGIN          
       UPDATE craplot ct
          SET ct.vlinfocr = NVL(ct.vlinfocr,0) + vr_vltotal
             ,ct.vlcompcr = NVL(ct.vlcompcr,0) + vr_vltotal
             ,ct.qtinfoln = NVL(ct.qtinfoln,0) + (vr_nrseqdig -  NVL(ct.nrseqdig,0))
             ,ct.qtcompln = NVL(ct.qtcompln,0) + (vr_nrseqdig -  NVL(ct.nrseqdig,0))
             ,ct.nrseqdig = NVL(ct.nrseqdig,0) + vr_nrseqdig
          WHERE ct.ROWID = rw_craplot.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro alterando craplot! '|| SQLERRM ||' - Cooper: '|| rw_lancamentos.cdcooper || ' Data: ' ||rw_lancamentos.dtmvtolt;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
    
    BEGIN
      update craplap p
         set p.txaplica = rw_lancamentos.vlfaixa_calculada
            ,p.txaplmes = rw_lancamentos.vlfaixa_calculada
       WHERE p.cdcooper = rw_lancamentos.cdcooper
         AND p.nrdconta = rw_lancamentos.nrdconta
         AND p.nraplica = rw_lancamentos.nraplica;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro alterando craplap! '|| SQLERRM;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;

  END LOOP;
  
  /***************** LANCAMENTOS DE ABRIL ****************************/  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv6,'Cooperativa;'||
                                                'Conta;'||
                                                'Data Aplicacao;'||
                                                'Aplicacao;'||
                                                'Valor Aplicado;'||
                                                'CDI Contratado;'||
                                                'CDI Calculado;'||chr(13));
  
  
  FOR rw_lancamentos_abril IN cr_lancamentos_abril LOOP    
    BEGIN
      update craplap p
         set p.txaplica = rw_lancamentos_abril.vlfaixa_calculada
            ,p.txaplmes = rw_lancamentos_abril.vlfaixa_calculada
       WHERE p.cdcooper = rw_lancamentos_abril.cdcooper
         AND p.nrdconta = rw_lancamentos_abril.nrdconta
         AND p.nraplica = rw_lancamentos_abril.nraplica;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro alterando craplap! '|| SQLERRM;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv6, rw_lancamentos_abril.cdcooper||';'||
                                                   rw_lancamentos_abril.nrdconta||';'||
                                                   rw_lancamentos_abril.dtmvtolt||';'||
                                                   rw_lancamentos_abril.nraplica||';'||
                                                   rw_lancamentos_abril.vlaplica||';'||
                                                   rw_lancamentos_abril.vlfaixa_contratada||';'||
                                                   rw_lancamentos_abril.vlfaixa_calculada);
  END LOOP;
  
  /**************** FIM DO LANCAMENTOS DE ABRIL ***************/
  
  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
  
  loga('Fim do Processo com sucesso');
  
  commit;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv6); --> Handle do arquivo aberto;    

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;    
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto; 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv6); --> Handle do arquivo aberto;       
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv6); --> Handle do arquivo aberto;      
end;
1
vr_dscritic
1
SUCESSO
5
8
vr_vlrendim
vr_saldo_cal_2018
vr_dia
vr_vltotal
rw_lancamentos.nrdconta
rw_crapmfx.vlmoefix
vr_vltxapli
vr_cdidiari
