CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS024(pr_cdcooper  in crapcop.cdcooper%type,
                                              pr_nrdevias  in number,
                                              pr_flgresta  in PLS_INTEGER,
                                              pr_cdagenci  IN PLS_INTEGER DEFAULT 0,  --> Código da agência, utilizado no paralelismo
                                              pr_idparale  IN PLS_INTEGER DEFAULT 0,  --> Identificador do job executando em paralelo.                      
                                              pr_stprogra out PLS_INTEGER,
                                              pr_infimsol out PLS_INTEGER,
                                              pr_cdcritic out crapcri.cdcritic%type,
                                              pr_dscritic out varchar2) is

/* Emite relatório de acompanhamento dos talonários. */
/* ........................................................................./*

 Programa: PC_CRPS024 (Antigo Fontes/crps024.p)
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Deborah/Edson
 Data    : Maio/92.                            Ultima atualizacao: 15/01/2018

 Dados referentes ao programa:

 Frequencia: Diario (Batch - Background).
 Objetivo  : Atende a solicitacao 16.
             Acompanhamento dos talonarios quinzenalmente (25).

 Alteracao : 07/12/95 - Fazer o mesmo tratamento dado ao tipo de conta 5 para
                        o tipo de conta 6 (Odair).

             24/03/98 - Incluir a empresa no relatorio (Deborah).

             11/09/98 - Tratar tipo de conta 7 (Deborah).

             01/07/99 - Nao selicionar cheques de transferencia (Odair)

           01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).

           18/10/2004 - Tratar conta integracao (Margarete).

           09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

           15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

           21/07/2008 - Alterado formato dos campos relacionados a Media dos
                        cheques (Elton).

           01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

           17/02/2010 - Aumentar formatos dos campos totais (Gabriel).

           06/12/2011 - Sustagco provissria (Andri R./Supero).

           21/01/2013 - Conversão Progress >> Oracle PL/SQL (Daniel-Supero)

           10/10/2013 - Ajuste para controle correto da cadeia (Gabriel).
           
           22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                        ser acionada em caso de saída para continuação da cadeia,
                        e não em caso de problemas na execução (Marcos-Supero)
                        
           29/09/2014 - Tratamento para não parar cadeia quando apresentar 
                        critica 17-Tipo de conta errado, somente irá apresentar mensagem no log
                        e prosseguir demais contas, ajustes para melhorar performace(Odirlei/Amcom).

           31/10/2014 - Melhorias de Performance (Alisson - AMcom)
           
           24/01/2017 - Apresentar critica 17 para o proc_message e não parar o processo
                        como faz hoje. (Lucas Ranghetti #580524)
           
           15/01/2018 - Projeto Ligeirinho. Fabiano Girardi AMcom. Alterado para paralelizar a execução deste relatorio.
           
............................................................................. */
  ds_character_separador constant varchar2(1) := '#';

  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    -- Busca a data do movimento
    select dat.inproces, 
           dat.dtmvtolt,
           dat.dtmvtopr
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  --
  cursor cr_craptab (pr_cdcooper in crapcop.cdcooper%type) is
    -- Busca a quantidade de folhas de cheque por talão
    select to_number(substr(craptab.dstextab,1,3)) nrflsind,
           to_number(substr(craptab.dstextab,5,3)) nrflscon
      from craptab
     where craptab.cdcooper = pr_cdcooper
       and craptab.nmsistem = 'CRED'
       and craptab.tptabela = 'USUARI'
       and craptab.cdempres = 0
       and craptab.cdacesso = 'ACOMPTALAO'
       and craptab.tpregist = 1;
  --
  /* Busca informações dos cheques emitidos */
  cursor cr_crapfdc (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_cdagenci in crapass.cdagenci%type) is
    select crapfdc.nrdconta,
           crapfdc.nrcheque,
           crapfdc.cdbanchq,
           crapfdc.dtretchq,
           crapfdc.incheque,
           crapfdc.dtliqchq
      from crapfdc
          ,crapass
     where crapfdc.cdcooper  = pr_cdcooper
       and crapass.cdagenci  = decode(pr_cdagenci,0,cdagenci,pr_cdagenci)
       and crapfdc.cdcooper  = crapass.cdcooper
       and crapfdc.nrdconta  = crapass.nrdconta
       and crapfdc.nrdconta  > 0
       and crapfdc.dtemschq is not null
       and crapfdc.tpcheque  = 1
     order by 1;
  TYPE typ_tab_crapfdc IS TABLE OF cr_crapfdc%ROWTYPE index by pls_integer;   
  r_crapfdc typ_tab_crapfdc;   
  --
  /* Busca informações do associado */
  cursor cr_crapass (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_cdagenci in crapass.cdagenci%type) is
    select nrdconta,
           cdagenci,
           nmprimtl,
           cdtipcta,
           cdsitdct,
           inpessoa
      from crapass
     where cdcooper = pr_cdcooper
       and cdagenci = decode(pr_cdagenci,0,cdagenci,pr_cdagenci);
     
  type typ_reg_crapass IS RECORD
    (cdagenci crapass.cdagenci%type,
     nmprimtl crapass.nmprimtl%type,
     cdtipcta crapass.cdtipcta%type,
     cdsitdct crapass.cdsitdct%type,
     inpessoa crapass.inpessoa%type);  
      
  type typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
  vr_tab_crapass typ_tab_crapass;      
  --
  /* Busca informações da agência */
  cursor cr_crapage (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_cdagenci in crapass.cdagenci%type
                    ,pr_dtmvtolt in crapdat.dtmvtolt%type
                    ,pr_cdprogra in tbgen_batch_controle.cdprogra%type
                    ,pr_qterro   in number) is
    select crapage.cdagenci
          ,crapage.nmresage
      from crapage
     where crapage.cdcooper = pr_cdcooper
       and crapage.cdagenci = decode(pr_cdagenci,0,crapage.cdagenci,pr_cdagenci)
       and crapage.cdagenci <> 999
       and (pr_qterro = 0 or (pr_qterro > 0 and exists (select 1
                                                        from tbgen_batch_controle
                                                        where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                                          and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                                          and tbgen_batch_controle.tpagrupador = 1
                                                          and tbgen_batch_controle.cdagrupador = crapage.cdagenci
                                                          and tbgen_batch_controle.insituacao  = 1
                                                          and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));
     
  type typ_tab_crapage IS TABLE OF crapage.nmresage%type INDEX BY PLS_INTEGER;
  vr_tab_crapage typ_tab_crapage;     
  --
  /* Verifica se existe alguma contra-ordem na conta*/
  cursor cr_crapcor (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_cdagenci in crapass.cdagenci%type) is
    select crapcor.nrdconta
      from crapcor,
           crapass 
     where crapcor.cdcooper = crapass.cdcooper
       and crapcor.nrdconta = crapass.nrdconta
       and crapcor.cdcooper = pr_cdcooper
       and crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       and crapcor.flgativo = 1;
  --
  /* Busca informações do titular da conta */
  cursor cr_crapttl (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_cdagenci in crapass.cdagenci%type) is
    select crapttl.nrdconta,
           crapttl.cdempres
      from crapttl
          ,crapass
     where crapttl.cdcooper = crapass.cdcooper
       and crapttl.nrdconta = crapass.nrdconta
       and crapttl.cdcooper = pr_cdcooper 
       and crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       and crapttl.idseqttl = 1;
  --
  /* Busca informações da conta PJ */
  cursor cr_crapjur (pr_cdcooper in crapcop.cdcooper%type
                    ,pr_cdagenci in crapass.cdagenci%type) is
    select crapjur.nrdconta
          ,crapjur.cdempres
      from crapjur
          ,crapass
     where crapjur.cdcooper = crapass.cdcooper
       and crapjur.nrdconta = crapass.nrdconta
       and crapjur.cdcooper = pr_cdcooper
       and crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
       
  -- Declaração de variáveis
  /* Registro para armazenar informações do associado */
  type typ_associado is record (nrdconta crapass.nrdconta%type,
                                qtchqtal number(6),
                                cdempres crapttl.cdempres%type,
                                nmprimtl crapass.nmprimtl%type,
                                cdtipcta crapass.cdtipcta%type,
                                cdsitdct crapass.cdsitdct%type,
                                nmtipcta varchar2(65), /* Conta individual ou conjunta + lista de tipos */
                                nrflspad number(3),
                                intipcta number(1)); /* Número padrão de folhas para o tipo de conta */
  /* Tabela onde serão armazenados os registros do associado */
  /* O índice da tabela será o número da conta */
  type typ_tab_associado is table of typ_associado index by varchar2(12);
  /* Registro para armazenar as informações da agência */
  type typ_agencia is record (nmresage       crapage.nmresage%type,
                              nrseqage       number(4),
                              tab_associado  typ_tab_associado, /* Instância da tabela de associados */
                              qttaluso       number(7),
                              qttalret       number(7),
                              qttalarq       number(7),
                              qttotass       number(4),
                              qttotfol       number(6));
  /* Tabela onde serão armazenados os registros da agência */
  /* O índice da tabela será o código da agência */
  type typ_tab_agencia is table of typ_agencia index by binary_integer;
  /* Instância da tabela */
  vr_tab_agencia   typ_tab_agencia;
  /* Tabela de Contas */
  type typ_tab_crapcor is table of pls_integer index by pls_integer;
  vr_tab_crapcor typ_tab_crapcor;
  /* Tabela de Titulares */
  type typ_tab_crapttl is table of crapttl.cdempres%type index by pls_integer;
  vr_tab_crapttl typ_tab_crapttl;
  /* Tabela de Titulares - PJ*/
  type typ_tab_crapjur is table of crapjur.cdempres%type index by pls_integer;
  vr_tab_crapjur typ_tab_crapjur;

  -- Exceptions
  vr_exc_fimprg   exception;
  vr_exc_saida    exception;
  
  vr_ds_xml  tbgen_batch_relatorio_wrk.dsxml%type;

  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_inproces      crapdat.inproces%type;
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  vr_dtmvtopr      crapdat.dtmvtopr%type;

  -- Nome do formulário utilizado no relatório
  vr_nmformul      varchar2(10);
  -- Variáveis para definição do tipo de conta
  vr_nrflsind      number(3);
  vr_nrflscon      number(3);
  vr_nrflspad      number(3);
  vr_intipcta      number(1);
  vr_nmtipcta      varchar2(65);
  -- Variável para controlar a troca da conta na leitura dos cheques
  vr_nrdconta      crapfdc.nrdconta%type := 0;
  -- Variáveis para armazenar as informações do associado
  vr_cdagenci      crapass.cdagenci%type;
  vr_nmprimtl      crapass.nmprimtl%type;
  vr_cdtipcta      crapass.cdtipcta%type;
  vr_cdsitdct      crapass.cdsitdct%type;
  vr_inpessoa      crapass.inpessoa%type;
  vr_cdempres      crapttl.cdempres%type;
  -- Variáveis para armazenar as informações da agência
  vr_nmresage      crapage.nmresage%type;
  -- Variáveis para identificar se a conta possui contra-ordem de cheques ativa
  vr_contra_ordem  boolean;
  -- Índice da pl/table de associados
  vr_ind_associado varchar2(12);
  -- Totalizadores do relatório
  vr_tot_qttaluso  number(9);
  vr_tot_qttalret  number(9);
  vr_tot_qttalarq  number(9);
  -- Variáveis para armazenar as informações em XML
  --vr_xmltype       xmltype;
  vr_des_xml       clob;
  vr_dstexto       varchar2(32767);
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  -- Índices para leitura das pl/tables ao gerar o XML
  vr_indice_agencia    number(10);
  vr_indice_associado  varchar2(12);

  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(2000);
  idx integer:= 0;
  
    -- Qtde parametrizada de Jobs
  vr_qtdjobs       number;
  -- Job name dos processos criados
  vr_jobname       varchar2(30);  
  -- ID para o paralelismo
  vr_idparale      integer;
  -- Bloco PLSQL para chamar a execução paralela do pc_crps750
  vr_dsplsql       varchar2(4000); 
  
  --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
  vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
  vr_idlog_ini     tbgen_prglog.idprglog%type; 
  vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
  vr_qterro        number := 0;
  
  
  vr_prtaluso      number(5,2);
  vr_prtalret      number(5,2);
  vr_prtalarq      number(5,2);
  vr_dsmensag      varchar2(4000);
  --
  procedure pc_iniciar_amb_paralel is
  begin
    -- Gerar o ID para o paralelismo
    vr_idparale := gene0001.fn_gera_id_paralelo;
    -- Se houver algum erro, vr_idparale será 0 (Zero)
    IF vr_idparale = 0 THEN
       -- Levantar exceção
       vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
       RAISE vr_exc_saida;
    END IF;
    
    -- Verifica se algum job paralelo executou com erro
    vr_qterro := 0;
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                  pr_cdprogra    => vr_cdprogra,
                                                  pr_dtmvtolt    => vr_dtmvtolt,
                                                  pr_tpagrupador => 1,
                                                  pr_nrexecucao  => 1);
  exception
    when vr_exc_saida then
      raise vr_exc_saida;
      
  end pc_iniciar_amb_paralel;
  
  procedure pc_criar_job_paralelo is
  begin
    
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'pc_criar_job_paralelo - INICIO cursor cr_crapage. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini);  
    
  
  
    for reg_crapage in cr_crapage(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_qterro   => vr_qterro
                                 ) loop
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := vr_cdprogra ||'_'|| reg_crapage.cdagenci || '$';  
    
      -- Cadastra o programa paralelo
      gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                ,pr_idprogra => LPAD(reg_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                ,pr_des_erro => vr_dscritic);
                                
      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;     
      -- Montar o bloco PLSQL que será executado
      -- Ou seja, executaremos a geração dos dados
      -- para a agência atual atraves de Job no banco
      vr_dsplsql := 'declare'            ||chr(13)||
                    ' wpr_stprogra  binary_integer; '||chr(13)||
                    ' wpr_infimsol  binary_integer; '||chr(13)||
                    ' wpr_cdcritic  number(5); '     ||chr(13)||
                    ' wpr_dscritic  varchar2(4000); '||chr(13)||
                    ' begin '||chr(13)||
                    '   cecred.pc_crps024('||pr_cdcooper||','||chr(13)||
                                             pr_nrdevias||','||chr(13)||
                                             pr_flgresta||','||chr(13)||
                                             reg_crapage.cdagenci||','||chr(13)||
                                             vr_idparale||','||chr(13)||
                                             'wpr_stprogra,' ||chr(13)||
                                             'wpr_infimsol,' ||chr(13)||
                                             'wpr_cdcritic,' ||chr(13)||
                                             'wpr_dscritic'  ||chr(13)||
                                             ');'||chr(13)||
                   'end;';
                 
       -- Faz a chamada ao programa paralelo atraves de JOB
       gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                             ,pr_cdprogra => vr_cdprogra  --> Código do programa
                             ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                             ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                             ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                             ,pr_jobname  => vr_jobname   --> Nome randomico criado
                             ,pr_des_erro => vr_dscritic);    
                             
       -- Testar saida com erro
       if vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
       end if;
       
       -- Chama rotina que irá pausar este processo controlador
       -- caso tenhamos excedido a quantidade de JOBS em execuçao
       gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs 
                                   ,pr_des_erro => vr_dscritic);
       -- Testar saida com erro
       if  vr_dscritic is not null then 
         -- Levantar exceçao
         raise vr_exc_saida;
       end if;
       
    end loop reg_crapage;
    
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'pc_criar_job_paralelo - FIM cursor cr_crapage. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini); 
  exception
    when vr_exc_saida then
       raise vr_exc_saida;
       
  end pc_criar_job_paralelo;

  --Emite relatório de acompanhamento dos talonários.
  procedure pc_pop_dados_acom_talonarios is
  begin
    vr_ind_associado := null;
    -- Recupera a quantidade de folhas para cada tipo de conta
    open cr_craptab (pr_cdcooper);
    fetch cr_craptab into vr_nrflsind,
                          vr_nrflscon;
    if cr_craptab%notfound then
      close cr_craptab;
      vr_cdcritic := 183;
      raise vr_exc_saida;
    end if;
    close cr_craptab;
  
    -- Define o nome do formulário
    if pr_nrdevias > 1 then
      vr_nmformul := lpad(pr_nrdevias, 2, ' ')||'vias';
    else
      vr_nmformul := ' ';
    end if;
  
    -- Carregar Contra-Ordens
    for rw_crapcor in cr_crapcor (pr_cdcooper,pr_cdagenci) LOOP
      vr_tab_crapcor(rw_crapcor.nrdconta):= 0;
    end loop;
  
    -- Carregar Agencias
    for rw_crapage in cr_crapage (pr_cdcooper
                                 ,pr_cdagenci
                                 ,vr_dtmvtolt
                                 ,vr_cdprogra
                                 ,vr_qterro
                                 ) LOOP
      vr_tab_crapage(rw_crapage.cdagenci) := rw_crapage.nmresage;
    end loop;
  
    -- Carregar Dados dos Titulares                                            
    for rw_crapttl in cr_crapttl (pr_cdcooper
                                 ,pr_cdagenci) LOOP
      vr_tab_crapttl(rw_crapttl.nrdconta):= rw_crapttl.cdempres;
    end loop;

    -- Carregar Dados dos Titulares - PJ
    for rw_crapjur in cr_crapjur (pr_cdcooper
                                 ,pr_cdagenci) LOOP
      vr_tab_crapjur(rw_crapjur.nrdconta):= rw_crapjur.cdempres;
    end loop;
  
    -- Carregar Dados dos Associados                                                 
    for rw_crapass in cr_crapass (pr_cdcooper
                                 ,pr_cdagenci) LOOP
      vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
      vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
      vr_tab_crapass(rw_crapass.nrdconta).cdtipcta:= rw_crapass.cdtipcta;
      vr_tab_crapass(rw_crapass.nrdconta).cdsitdct:= rw_crapass.cdsitdct;
      vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;
    end loop;  
    
    -- Leitura e processamento dos cheques
    vr_nrdconta := 0;
    open cr_crapfdc (pr_cdcooper,pr_cdagenci);
    loop
      fetch cr_crapfdc BULK COLLECT INTO r_crapfdc LIMIT 250000;
      exit when r_crapfdc.COUNT = 0; 
      
      idx:= r_crapfdc.first;
      While idx is not null loop   
        
        -- Verifica se passou a processar uma nova conta
        if vr_nrdconta <> r_crapfdc(idx).nrdconta then
          --
          -- Recuperar informações da conta e do associado
          if vr_tab_crapass.EXISTS(r_crapfdc(idx).nrdconta) then
            vr_cdagenci:= vr_tab_crapass(r_crapfdc(idx).nrdconta).cdagenci;
            vr_nmprimtl:= vr_tab_crapass(r_crapfdc(idx).nrdconta).nmprimtl;
            vr_cdtipcta:= vr_tab_crapass(r_crapfdc(idx).nrdconta).cdtipcta;
            vr_cdsitdct:= vr_tab_crapass(r_crapfdc(idx).nrdconta).cdsitdct;
            vr_inpessoa:= vr_tab_crapass(r_crapfdc(idx).nrdconta).inpessoa;
          else
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')   || ' - ' ||
                                                          vr_cdprogra || ' --> '          ||
                                                          gene0001.fn_busca_critica(9)    ||
                                                          ' Conta: '||r_crapfdc(idx).nrdconta  ||
                                                          ' Cheque: '||r_crapfdc(idx).nrcheque ||
                                                          ' Banco: '||r_crapfdc(idx).cdbanchq);
            continue;  
          end if;                      
          --
          -- Recuperar informações da agência
          if vr_tab_crapage.EXISTS(vr_cdagenci) then
            vr_nmresage:= vr_tab_crapage(vr_cdagenci);
          else
            vr_nmresage := '***************';
          end if;
              
          --
          -- Verificar se tem contra-ordem
          vr_contra_ordem:= vr_tab_crapcor.EXISTS(r_crapfdc(idx).nrdconta);
          --
          -- Recuperar o nome do titular da conta
          if vr_inpessoa = 1 then
            -- Pessoa física
            if  vr_tab_crapttl.exists(r_crapfdc(idx).nrdconta) then
              vr_cdempres:= vr_tab_crapttl(r_crapfdc(idx).nrdconta);
            end if;  
          else
            -- Pessoa juridica
            if  vr_tab_crapjur.exists(r_crapfdc(idx).nrdconta) then
              vr_cdempres:= vr_tab_crapjur(r_crapfdc(idx).nrdconta);
            end if;  
          end if;
          --
          -- Identificar o tipo de conta (individual ou conjunta)
          if vr_cdtipcta in (1,2,5,6,7,8,9,12,13,17,18) then
            vr_intipcta := 1; -- Conta individual
            vr_nmtipcta := 'CONTAS INDIVIDUAIS (TIPOS: 1,2,5,6,7,8,9,12,13,17,18)';
            vr_nrflspad := vr_nrflsind;
          elsif vr_cdtipcta in (3,4,10,11,14,15) then
            vr_intipcta := 2; -- Conta conjunta
            vr_nmtipcta := 'CONTAS CONJUNTAS (TIPOS: 3,4,10,11,14,15)';
            vr_nrflspad := vr_nrflscon;
          else
            vr_cdcritic := 17; -- Tipo de conta errado
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || gene0001.fn_busca_critica(vr_cdcritic) ||
                                                        ' Conta: '||r_crapfdc(idx).nrdconta  ||
                                                        ' Cheque: '||r_crapfdc(idx).nrcheque ||
                                                        ' Banco: '||r_crapfdc(idx).cdbanchq);
            -- Alimentar para não entrar em loop
            vr_nrdconta := r_crapfdc(idx).nrdconta; 
            idx:= r_crapfdc.next(idx);
            continue;
          end if;
          -- Monta o índice utilizado para identificar a conta
          vr_ind_associado := lpad(vr_intipcta, 2, '0')||lpad(r_crapfdc(idx).nrdconta, 10, '0');
          -- Atualiza a variável de controle de agrupamento por conta
          
          vr_nrdconta := r_crapfdc(idx).nrdconta;
        end if;
        --
        -- Processa os cheques e armazena informações nas PL/Tables
        vr_tab_agencia(vr_cdagenci).nmresage := vr_nmresage;
        vr_tab_agencia(vr_cdagenci).nrseqage := 1;
        --
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).nmtipcta := vr_nmtipcta;
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).nrflspad := vr_nrflspad;
        --
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).nrdconta := vr_nrdconta;
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).cdempres := vr_cdempres;
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).nmprimtl := vr_nmprimtl;
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).cdtipcta := vr_cdtipcta;
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).cdsitdct := vr_cdsitdct;
        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).intipcta := vr_intipcta;
        --
        if r_crapfdc(idx).dtretchq is not null then
          if vr_contra_ordem and r_crapfdc(idx).incheque in (0,2) then
              vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).qtchqtal := nvl(vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).qtchqtal, 0) + 1;             
          end if;
        end if;
        
        -- Acumula o cheque no totalizador correto
        if r_crapfdc(idx).dtretchq is not null then
          if r_crapfdc(idx).dtliqchq is not null then
            vr_tab_agencia(vr_cdagenci).qttaluso := nvl(vr_tab_agencia(vr_cdagenci).qttaluso, 0) + 1;
            vr_tot_qttaluso := nvl(vr_tot_qttaluso, 0) + 1;
          else
            vr_tab_agencia(vr_cdagenci).qttalret := nvl(vr_tab_agencia(vr_cdagenci).qttalret, 0) + 1;
            vr_tot_qttalret := nvl(vr_tot_qttalret, 0) + 1;
          end if;
        else
          vr_tab_agencia(vr_cdagenci).qttalarq := nvl(vr_tab_agencia(vr_cdagenci).qttalarq, 0) + 1;
          vr_tot_qttalarq := nvl(vr_tot_qttalarq, 0) + 1;
        end if;
        
        --Proximo registro
        idx:= r_crapfdc.next(idx);
        
        if idx is not null then
          
          if vr_ind_associado <> lpad(vr_intipcta, 2, '0')||lpad(r_crapfdc(idx).nrdconta, 10, '0') then   
            
            if vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).qtchqtal > 
               vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).nrflspad then
               vr_tab_agencia(vr_cdagenci).qttotass := nvl(vr_tab_agencia(vr_cdagenci).qttotass, 0) + 1;
               vr_tab_agencia(vr_cdagenci).qttotfol := nvl(vr_tab_agencia(vr_cdagenci).qttotfol, 0) + 
                                                        vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).qtchqtal;
            
            end if;
             
          end if;
        
        end if;
        
      end loop;  
    
    end loop;
    
    if vr_ind_associado is not null then
      --Ugly but necessary, check twice :|
      if vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).qtchqtal > 
         vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).nrflspad then
         
         vr_tab_agencia(vr_cdagenci).qttotass := nvl(vr_tab_agencia(vr_cdagenci).qttotass, 0) + 1;
         vr_tab_agencia(vr_cdagenci).qttotfol := nvl(vr_tab_agencia(vr_cdagenci).qttotfol, 0) + 
                                                 vr_tab_agencia(vr_cdagenci).tab_associado(vr_ind_associado).qtchqtal;
            
      end if;
      
    end if;
            
  end pc_pop_dados_acom_talonarios;
  

  
  procedure pc_popular_tab_totais_wrk is
  begin
    vr_ds_xml := ds_character_separador||vr_tot_qttaluso|| 
                 ds_character_separador||vr_tot_qttalret|| 
                 ds_character_separador||vr_tot_qttalarq||
                 ds_character_separador;
    
    insert into tbgen_batch_relatorio_wrk(CDCOOPER
                                                ,CDPROGRAMA
                                                ,DSRELATORIO
                                                ,DTMVTOLT
                                                ,CDAGENCI
                                                ,NRDCONTA
                                                ,DSXML) values (pr_cdcooper
                                                               ,'CRPS024_TOTAIS'
                                                               ,'crrl025'
                                                               ,vr_dtmvtolt
                                                               ,99999
                                                               ,9999999999 
                                                               ,vr_ds_xml
                                                               );
  end pc_popular_tab_totais_wrk;
  
  procedure pc_popular_tab_agencia_wrk IS 
  begin
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia is not null loop
      vr_ds_xml := ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).nmresage||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).nrseqage||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).qttaluso||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).qttalret||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).qttalarq||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).qttotass||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).qttotfol||
                   ds_character_separador;
                       
      insert into tbgen_batch_relatorio_wrk(CDCOOPER
                                           ,CDPROGRAMA
                                           ,DSRELATORIO
                                           ,DTMVTOLT
                                           ,CDAGENCI
                                           ,NRDCONTA
                                           ,DSXML) values (pr_cdcooper
                                                           ,'CRPS024_AGENCIA'
                                                           ,'crrl025'
                                                           ,vr_dtmvtolt
                                                           ,vr_indice_agencia
                                                           ,NULL
                                                           ,vr_ds_xml);  
                                                                        
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
  end pc_popular_tab_agencia_wrk;
  
  procedure pc_popular_tab_associado_wrk is
  begin
   
    vr_indice_agencia := vr_tab_agencia.first;
    
    while vr_indice_agencia is not null loop
      
       vr_indice_associado := vr_tab_agencia(vr_indice_agencia).tab_associado.first;
       while vr_indice_associado is not null loop

         vr_ds_xml := ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nmtipcta||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nrflspad||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).qtchqtal||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).cdempres||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nmprimtl||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).cdtipcta||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).cdsitdct||ds_character_separador||
                   vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).intipcta||
                   ds_character_separador; 
                   
                              
           insert into tbgen_batch_relatorio_wrk(CDCOOPER
                                                ,CDPROGRAMA
                                                ,DSRELATORIO
                                                ,DTMVTOLT
                                                ,CDAGENCI
                                                ,NRDCONTA
                                                ,DSXML) values (pr_cdcooper
                                                               ,'CRPS024_ASSOCIADO'
                                                               ,'crrl025'
                                                               ,vr_dtmvtolt
                                                               ,vr_indice_agencia
                                                               ,vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).NRDCONTA
                                                               ,vr_ds_xml);
         
         vr_indice_associado := vr_tab_agencia(vr_indice_agencia).tab_associado.next(vr_indice_associado);
       end loop;    

       vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
       
    end loop;
    
  end pc_popular_tab_associado_wrk;
  
  procedure pc_gerar_xml_wrk is
   
   cursor cr_wrk_agencia is
      select CDAGENCI,
             nmresage,
             qttaluso,
             qttalret,
             qttalarq,
             qttotass,
             qttotfol,
             qttaluso + qttalret + qttalarq as qttal,
             CASE 
               WHEN qttaluso + qttalret + qttalarq > 0 THEN
                 ROUND((qttaluso / (qttaluso + qttalret + qttalarq)) * 100,2)
               ELSE
                 0
             END prtaluso,
             CASE 
             WHEN qttaluso + qttalret + qttalarq > 0 THEN
               ROUND((qttalret / (qttaluso + qttalret + qttalarq)) * 100,2)
             ELSE
               0
             END prtalret,
             CASE 
               WHEN qttaluso + qttalret + qttalarq > 0 THEN
                 ROUND((qttalarq / (qttaluso + qttalret + qttalarq)) * 100,2)
               ELSE
                 0
             END prtalarq,
             CASE 
                when qttotass = 0 then
                  0
                else 
                  qttotfol / qttotass
              end medfpa    
            from(
            select 
                    CDAGENCI,
                    NRDCONTA,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) nmresage,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrseqage,
                    nvl(substr(tab.dsxml,instr(tab.dsxml,'#',1,3)+1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1),0) qttaluso,
                    nvl(substr(tab.dsxml,instr(tab.dsxml,'#',1,4)+1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1),0) qttalret,
                    nvl(substr(tab.dsxml,instr(tab.dsxml,'#',1,5)+1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1),0) qttalarq,
                    nvl(substr(tab.dsxml,instr(tab.dsxml,'#',1,6)+1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1),0) qttotass,
                    nvl(substr(tab.dsxml,instr(tab.dsxml,'#',1,7)+1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1),0) qttotfol,
                    tab.dsxml
                  from (select 
                         CDAGENCI,
                         NRDCONTA,
                         dbms_lob.substr(dsxml,4000,1) dsxml
                        from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS024_AGENCIA'
                          and wrk.dsrelatorio = 'crrl025'
                          and wrk.dtmvtolt    = vr_dtmvtolt
                          and wrk.cdagenci   <> 99999
                          and wrk.nrdconta    is null
                          ) tab)
                order by CDAGENCI; 
    
    rr_wrk_agencia cr_wrk_agencia%rowtype; 
               
    cursor cr_associado_wrk(pr_cdagenci in tbgen_batch_relatorio_wrk.cdagenci%type) is 
    select cdempres,
           nmprimtl,
           cdsitdct,
           CDAGENCI,
           nmtipcta,
           to_number(nrflspad) nrflspad,
           nrdconta,
           to_number(qtchqtal) qtchqtal,
           cdtipcta
          from(
            select 
                    CDAGENCI,
                    NRDCONTA,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) nmtipcta,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrflspad,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) qtchqtal,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) cdempres,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) nmprimtl,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) cdtipcta,
                    substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) cdsitdct,
                    nvl(substr(tab.dsxml,instr(tab.dsxml,'#',1,8)+1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1),0) intipcta,
                    tab.dsxml
                  from (select 
                         CDAGENCI,
                         NRDCONTA,
                         dbms_lob.substr(dsxml,4000,1) dsxml
                        from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS024_ASSOCIADO'
                          and wrk.dsrelatorio = 'crrl025'
                          and wrk.dtmvtolt    = vr_dtmvtolt
                          and wrk.cdagenci    = pr_cdagenci
                          and wrk.nrdconta    <> 9999999999
                          ) tab)
                   order by intipcta,
                            nrdconta;

    cursor cr_wrk_totais is
      select
        nvl(sum(tab.vr_tot_qttaluso),0) as vr_tot_qttaluso,
        nvl(sum(tab.vr_tot_qttalret),0) as vr_tot_qttalret,
        nvl(sum(tab.vr_tot_qttalarq),0) as vr_tot_qttalarq
      from (select 
              substr(wrk.dsxml,instr(wrk.dsxml,'#',1,1) +1,instr(wrk.dsxml,'#',1,2)-instr(wrk.dsxml,'#',1,1)-1) vr_tot_qttaluso,
              substr(wrk.dsxml,instr(wrk.dsxml,'#',1,2) +1,instr(wrk.dsxml,'#',1,3)-instr(wrk.dsxml,'#',1,2)-1) vr_tot_qttalret,
              substr(wrk.dsxml,instr(wrk.dsxml,'#',1,3) +1,instr(wrk.dsxml,'#',1,4)-instr(wrk.dsxml,'#',1,3)-1) vr_tot_qttalarq
             from (select 
                     dbms_lob.substr(dsxml,4000,1) dsxml
                   from tbgen_batch_relatorio_wrk wrk
                   where wrk.cdcooper    = pr_cdcooper
                     and wrk.cdprograma  = 'CRPS024_TOTAIS'
                     and wrk.dsrelatorio = 'crrl025'
                     and wrk.cdagenci    = 99999
                     and wrk.nrdconta    = 9999999999
                     and wrk.dtmvtolt    = vr_dtmvtolt) wrk) tab;
  
    rg_wrk_totais cr_wrk_totais%rowtype;
             
  begin  
   
    open cr_wrk_agencia;
    
    fetch cr_wrk_agencia into rr_wrk_agencia;  
    if cr_wrk_agencia%rowcount > 0 then
       
       -- Inicializar o CLOB
       dbms_lob.createtemporary(vr_des_xml, TRUE);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><agencias>'); 
      
       loop
         pc_log_programa(PR_DSTIPLOG           => 'O',
                         PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper           => pr_cdcooper,
                         pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 4,
                         pr_dsmensagem         => '[pc_gerar_xml_wrk] Inicio Processo Agencia: '||rr_wrk_agencia.cdagenci||' - '||rr_wrk_agencia.nmresage,
                         PR_IDPRGLOG           => vr_idlog_ini);  
                         
         -- Incluir informações do cabeçalho da agência
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||rr_wrk_agencia.cdagenci||'">'||
                                                       '<nmresage>' ||rr_wrk_agencia.nmresage||'</nmresage>'       ||
                                                       '<qttaluso>' ||to_char(rr_wrk_agencia.qttaluso, '9G999G990')||'</qttaluso>'  ||
                                                       '<prtaluso>('||to_char(rr_wrk_agencia.prtaluso, '990D00')       ||'%)</prtaluso>'||
                                                       '<qttalret>' ||to_char(rr_wrk_agencia.qttalret, '9G999G990')||'</qttalret>'  ||
                                                       '<prtalret>('||to_char(rr_wrk_agencia.prtalret, '990D00')       ||'%)</prtalret>'||
                                                       '<qttalarq>' ||to_char(rr_wrk_agencia.qttalarq, '9G999G990')||'</qttalarq>'  ||
                                                       '<prtalarq>('||to_char(rr_wrk_agencia.prtalarq, '990D00')       ||'%)</prtalarq>'||
                                                       '<qttal>'    ||to_char(rr_wrk_agencia.qttal, '9G999G990')       ||'</qttal>');     

         
         for rr_associado_wrk in cr_associado_wrk(pr_cdagenci => rr_wrk_agencia.cdagenci) loop
          
           if rr_associado_wrk.qtchqtal > rr_associado_wrk.nrflspad then
          
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta nmtipcta="'||rr_associado_wrk.nmtipcta||'">'||
                                 '<nrflspad>'||rr_associado_wrk.nrflspad                        ||'</nrflspad>'||
                                 '<nrdconta>'||to_char(rr_associado_wrk.nrdconta, '9G999G999G9')||'</nrdconta>'||
                                 '<qtchqtal>'||to_char(rr_associado_wrk.qtchqtal, '9G999G990')  ||'</qtchqtal>'||
                                 '<cdempres>'||rr_associado_wrk.cdempres                        ||'</cdempres>'||
                                 '<nmprimtl>'||rr_associado_wrk.nmprimtl                        ||'</nmprimtl>'||
                                 '<cdtipcta>'||lpad(rr_associado_wrk.cdtipcta, 2, '0')          ||'</cdtipcta>'||
                                 '<cdsitdct>'||rr_associado_wrk.cdsitdct                        ||'</cdsitdct>'||
                                 '</conta>');
        
           end if;
                     
         end loop rr_associado_wrk; 
         
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencia>');   
       
         pc_log_programa(PR_DSTIPLOG           => 'O',
                         PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                         pr_cdcooper           => pr_cdcooper,
                         pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                         pr_tpocorrencia       => 4,
                         pr_dsmensagem         => 'Fim Processo Agencia: '||rr_wrk_agencia.cdagenci||' - '||rr_wrk_agencia.nmresage,
                         PR_IDPRGLOG           => vr_idlog_ini);   
       
       
         fetch cr_wrk_agencia into rr_wrk_agencia;
         if cr_wrk_agencia%notfound then
           exit;
         end if;
         
       end loop;
       
     end if;
     close cr_wrk_agencia;    
     
      -- Final do relatório, incluir resumo
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="999999"><conta>');

      
      open cr_wrk_totais;
      fetch cr_wrk_totais into rg_wrk_totais;
      close cr_wrk_totais;
      
      vr_prtaluso := 0;
      vr_prtalret := 0;
      vr_prtalarq := 0;
      
      for rg_wrk_agencia in cr_wrk_agencia loop
        
        vr_prtaluso := (to_number(rg_wrk_agencia.qttaluso) / to_number(rg_wrk_totais.vr_tot_qttaluso)) * 100;
        vr_prtalret := (to_number(rg_wrk_agencia.qttalret) / to_number(rg_wrk_totais.vr_tot_qttalret)) * 100;
        vr_prtalarq := (to_number(rg_wrk_agencia.qttalarq) / to_number(rg_wrk_totais.vr_tot_qttalarq)) * 100;   
      
        -- Incluir totais por agência
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<r_agencia>'||
                           '<r_cdagenci>'||rg_wrk_agencia.cdagenci||'</r_cdagenci>'||
                           '<r_qttaluso>'||to_char(nvl(rg_wrk_agencia.qttaluso, 0), '9G999G990')||'</r_qttaluso>'||
                           '<r_prtaluso>('||trim(to_char(vr_prtaluso, '990D00'))||')</r_prtaluso>'||
                           '<r_qttalret>'||to_char(nvl(rg_wrk_agencia.qttalret, 0), '9G999G990')||'</r_qttalret>'||
                           '<r_prtalret>('||trim(to_char(vr_prtalret, '990D00'))||')</r_prtalret>'||
                           '<r_qttalarq>'||to_char(nvl(rg_wrk_agencia.qttalarq, 0), '9G999G990')||'</r_qttalarq>'||
                           '<r_prtalarq>('||trim(to_char(vr_prtalarq, '990D00'))||')</r_prtalarq>'||
                           '<r_qttotass>'||to_char(nvl(rg_wrk_agencia.qttotass, 0), '9G990')||'</r_qttotass>'||
                           '<r_qttotfol>'||to_char(nvl(rg_wrk_agencia.qttotfol, 0), '999G990')||'</r_qttotfol>'||
                           '<r_medfpa>'||to_char(rg_wrk_agencia.medfpa, '9G990D00')||'</r_medfpa>'||
                         '</r_agencia>');
                         
      end loop rg_wrk_agencia;
      
      pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA       => vr_cdprogra ||'_'||pr_cdagenci || '$',
                        pr_cdcooper         => pr_cdcooper,
                        pr_tpexecucao       => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia     => 4,
                        pr_dsmensagem       => '[pc_gerar_xml_wrk] *FINALIZOU A MONTAGEM DO XML*',
                        PR_IDPRGLOG         => vr_idlog_ini);
      
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</conta></agencia>');
      -- ultima tag e descarregar buffer
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencias>',TRUE);
      
      
  end pc_gerar_xml_wrk;

  
  --Limpar todos os dados temporarios gerados por este programa.
  procedure pc_clear_memoria(pr_CDAGENCI in tbgen_batch_relatorio_wrk.CDAGENCI%type) is
  begin
    delete from tbgen_batch_relatorio_wrk wrk
    where wrk.cdcooper    = pr_cdcooper
      and wrk.cdprograma  in ('CRPS024_TOTAIS','CRPS024_AGENCIA','CRPS024_ASSOCIADO')
      and wrk.dsrelatorio = 'crrl025'
      and wrk.dtmvtolt    = vr_dtmvtolt
      and wrk.cdagenci    = decode(pr_CDAGENCI,0,wrk.cdagenci,pr_CDAGENCI);
      
  end pc_clear_memoria;

  procedure pc_gerar_xml_pl_table is
  
    vr_tot_qttaluso  number(9);
    vr_tot_qttalret  number(9);
    vr_tot_qttalarq  number(9);
    vr_qttal         number(9);
    vr_prtaluso      number(5,2);
    vr_prtalret      number(5,2);
    vr_prtalarq      number(5,2);
    vr_medfpa        number(6,2);
  
  
  begin
    vr_indice_agencia := vr_tab_agencia.first;
  -- Se houver informação, deve criar o arquivo
  if vr_indice_agencia is not null then
    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><agencias>');
    -- Início da leitura das informações
    while vr_indice_agencia is not null loop
      --Desprezar os calculosfeitos.
      vr_tab_agencia(vr_indice_agencia).qttotass := 0;
      vr_tab_agencia(vr_indice_agencia).qttotfol := 0;
      vr_dsmensag := '***Inicio [pc_gerar_xml_pl_table] Index Agencia: ['||vr_indice_agencia||'] Qtde Cooperados: ['||vr_tab_agencia(vr_indice_agencia).tab_associado.count()||']';
        
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);  
                      
      -- Este loop faz a quebra por agência, portanto sempre deve incluir o cabeçalho
      -- Calcular total de cheques para agência
      vr_qttal := nvl(vr_tab_agencia(vr_indice_agencia).qttaluso, 0) +
                  nvl(vr_tab_agencia(vr_indice_agencia).qttalret, 0) +
                  nvl(vr_tab_agencia(vr_indice_agencia).qttalarq, 0);
      -- Calcular percentuais
      vr_prtaluso := nvl(vr_tab_agencia(vr_indice_agencia).qttaluso, 0) / vr_qttal * 100;
      vr_prtalret := nvl(vr_tab_agencia(vr_indice_agencia).qttalret, 0) / vr_qttal * 100;
      vr_prtalarq := nvl(vr_tab_agencia(vr_indice_agencia).qttalarq, 0) / vr_qttal * 100;
      -- Incluir informações do cabeçalho da agência
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_indice_agencia||'">'||
                       '<nmresage>'||vr_tab_agencia(vr_indice_agencia).nmresage||'</nmresage>'||
                       '<qttaluso>'||to_char(vr_tab_agencia(vr_indice_agencia).qttaluso, '9G999G990')||'</qttaluso>'||
                       '<prtaluso>('||to_char(vr_prtaluso, '990D00')||'%)</prtaluso>'||
                       '<qttalret>'||to_char(vr_tab_agencia(vr_indice_agencia).qttalret, '9G999G990')||'</qttalret>'||
                       '<prtalret>('||to_char(vr_prtalret, '990D00')||'%)</prtalret>'||
                       '<qttalarq>'||to_char(vr_tab_agencia(vr_indice_agencia).qttalarq, '9G999G990')||'</qttalarq>'||
                       '<prtalarq>('||to_char(vr_prtalarq, '990D00')||'%)</prtalarq>'||
                       '<qttal>'||to_char(vr_qttal, '9G999G990')||'</qttal>');
      -- Inclui os dados das contas (tab_associados) somente quando a quantidade de cheques for maior do que a quantidade padrão
      vr_indice_associado := vr_tab_agencia(vr_indice_agencia).tab_associado.first;
      while vr_indice_associado is not null loop
        if vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).qtchqtal > 
           vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nrflspad then
           
          vr_dsmensag := '*****[pc_gerar_xml_pl_table]. Index Agencia: ['||vr_indice_agencia||'] Index Associado: ['||vr_indice_associado||']'||
                         ' Qtde Cheque: ['||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).qtchqtal||']'||
                         ' Nro Folhas Padrao: ['||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nrflspad||']';
        
          pc_log_programa(PR_DSTIPLOG           => 'O',
                          PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 4,
                          pr_dsmensagem         => vr_dsmensag,
                          PR_IDPRGLOG           => vr_idlog_ini);        
           
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta nmtipcta="'||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nmtipcta||'">'||
                           '<nrflspad>'||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nrflspad||'</nrflspad>'||
                           '<nrdconta>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nrdconta, '9G999G999G9')||'</nrdconta>'||
                           '<qtchqtal>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).qtchqtal, '9G999G990')||'</qtchqtal>'||
                           '<cdempres>'||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).cdempres||'</cdempres>'||
                           '<nmprimtl>'||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).nmprimtl||'</nmprimtl>'||
                           '<cdtipcta>'||lpad(vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).cdtipcta, 2, '0')||'</cdtipcta>'||
                           '<cdsitdct>'||vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).cdsitdct||'</cdsitdct>'||
                         '</conta>');
          -- Acumula totalizadores para uso no resumo do relatório
          vr_tab_agencia(vr_indice_agencia).qttotass := nvl(vr_tab_agencia(vr_indice_agencia).qttotass, 0) + 1;
          vr_tab_agencia(vr_indice_agencia).qttotfol := nvl(vr_tab_agencia(vr_indice_agencia).qttotfol, 0) + vr_tab_agencia(vr_indice_agencia).tab_associado(vr_indice_associado).qtchqtal;
        end if;
        vr_indice_associado := vr_tab_agencia(vr_indice_agencia).tab_associado.next(vr_indice_associado);
      end loop;
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencia>');
      
      vr_dsmensag := '***Fim [pc_gerar_xml_pl_table] Index Agencia: ['||vr_indice_agencia||']'||
                     ' Qtde Total Associados: ['||vr_tab_agencia(vr_indice_agencia).tab_associado.count()||']'||
                     ' Qtde Associados: ['|| vr_tab_agencia(vr_indice_agencia).qttotass||']'||
                     ' Qtde Total Folha: ['||vr_tab_agencia(vr_indice_agencia).qttotfol||']***';
        
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);  
      
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      
      
      
    end loop;
    -- Final do relatório, incluir resumo
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="999999"><conta>');
    vr_indice_agencia := vr_tab_agencia.first;
    
    vr_dsmensag := '***Inicio [pc_gerar_xml_pl_table Totais] Index Agencia: ['||vr_indice_agencia||'] Qtde Cooperados: ['||vr_tab_agencia(vr_indice_agencia).tab_associado.count()||']';
        
    pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);  
    while vr_indice_agencia is not null loop
      -- Calcula os percentuais
      vr_prtaluso := nvl(vr_tab_agencia(vr_indice_agencia).qttaluso, 0) / vr_tot_qttaluso * 100;
      vr_prtalret := nvl(vr_tab_agencia(vr_indice_agencia).qttalret, 0) / vr_tot_qttalret * 100;
      vr_prtalarq := nvl(vr_tab_agencia(vr_indice_agencia).qttalarq, 0) / vr_tot_qttalarq * 100;
      if nvl(vr_tab_agencia(vr_indice_agencia).qttotass, 0) = 0 then
        vr_medfpa := 0;
      else
        vr_medfpa := vr_tab_agencia(vr_indice_agencia).qttotfol / vr_tab_agencia(vr_indice_agencia).qttotass;
      end if;
      -- Incluir totais por agência
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<r_agencia>'||
                       '<r_cdagenci>'||vr_indice_agencia||'</r_cdagenci>'||
                       '<r_qttaluso>'||to_char(nvl(vr_tab_agencia(vr_indice_agencia).qttaluso, 0), '9G999G990')||'</r_qttaluso>'||
                       '<r_prtaluso>('||trim(to_char(vr_prtaluso, '990D00'))||')</r_prtaluso>'||
                       '<r_qttalret>'||to_char(nvl(vr_tab_agencia(vr_indice_agencia).qttalret, 0), '9G999G990')||'</r_qttalret>'||
                       '<r_prtalret>('||trim(to_char(vr_prtalret, '990D00'))||')</r_prtalret>'||
                       '<r_qttalarq>'||to_char(nvl(vr_tab_agencia(vr_indice_agencia).qttalarq, 0), '9G999G990')||'</r_qttalarq>'||
                       '<r_prtalarq>('||trim(to_char(vr_prtalarq, '990D00'))||')</r_prtalarq>'||
                       '<r_qttotass>'||to_char(nvl(vr_tab_agencia(vr_indice_agencia).qttotass, 0), '9G990')||'</r_qttotass>'||
                       '<r_qttotfol>'||to_char(nvl(vr_tab_agencia(vr_indice_agencia).qttotfol, 0), '999G990')||'</r_qttotfol>'||
                       '<r_medfpa>'||to_char(vr_medfpa, '9G990D00')||'</r_medfpa>'||
                     '</r_agencia>');
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
    
    vr_dsmensag := '***Fim [pc_gerar_xml_pl_table Totais] ';
        
    pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);  
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</conta></agencia>');
    -- ultima tag e descarregar buffer
    gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencias>',TRUE);
    -- Incializar a varíavel com o XML montado
    --vr_XMLType := XMLType.createXML(vr_des_xml);
    
  end if;
  end pc_gerar_xml_pl_table;

begin
  vr_cdprogra := 'CRPS024'; 
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                            pr_flgbatch => 1,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_cdcritic => vr_cdcritic);
    -- Se retornou algum erro
  if vr_cdcritic <> 0 then
    raise vr_exc_saida;
  end if;
  -- Buscar a data do movimento
  open cr_crapdat(pr_cdcooper);
  fetch cr_crapdat into vr_inproces,
                        vr_dtmvtolt,
                        vr_dtmvtopr;
  close cr_crapdat;
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS024',
                             pr_action => vr_cdprogra);

  -- Buscar quantidade parametrizada de Jobs
  vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                               ,pr_cdprogra => vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                               );  

  /* Paralelismo visando performance Rodar Somente no processo Noturno */
  if vr_inproces  > 2 and
     vr_qtdjobs   > 0 and 
     pr_cdagenci  = 0 then 
    --Pode ter ficado sujeira de uma execucao anterior (abortado), limpar tabela de memoria
    pc_clear_memoria(pr_CDAGENCI => 0); 
   
    vr_tpexecucao := 1;
    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'I',    
                    pr_cdprograma => vr_cdprogra,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => 1, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini); --Out.
    
    --Gerar o vr_idparale, para ser usado nos jobs.
    pc_iniciar_amb_paralel;
    --Rotina responsavel em criar os jobs por agencia, considerando a sua cooperativa.
    pc_criar_job_paralelo; 
    --Chamar rotina de aguardo agora passando 0, para esperar
    --até que todos os Jobs tenha finalizado seu processamento
    gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => 0
                                ,pr_des_erro => vr_dscritic);
                                
    -- Testar saida com erro
    if  vr_dscritic is not null then 
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;
    
    vr_qterro := 0;
    --Verificar a qtde de erro gerado pelos jobs.
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                  pr_cdprogra    => vr_cdprogra,
                                                  pr_dtmvtolt    => vr_dtmvtolt,
                                                  pr_tpagrupador => 1,
                                                  pr_nrexecucao  => 1);
                                     
    if vr_qterro > 0 then 
      vr_cdcritic := 0;
      vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
      raise vr_exc_saida;
    end if; 
    
  
  else
        
    if pr_cdagenci <> 0 then
      vr_tpexecucao := 2;
    else
      vr_tpexecucao := 1;
    end if; 
    
    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'I',    
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini); 
                    
    --[Fabiano Girardi AMcom 11/01/2018] 
    -- Grava controle de batch por agência
    gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                    ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                    ,pr_dtmvtolt    => vr_dtmvtolt               -- Data de Movimento
                                    ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                    ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                    ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                    ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                    ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                    ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                    ,pr_dscritic    => vr_dscritic              
                                     );   
    -- Testar saida com erro
    if  vr_dscritic is not null then 
      -- Levantar exceçao
      raise vr_exc_saida;
    end if; 
    
    --Cada Job é responsável em buscar todos os dados da sua agencia na qual foi parametrizada no Job. 
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Início - pc_pop_dados_acom_talonarios AGENCIA: ['||pr_cdagenci||'] - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini); 
    --Preencher a pl-table com as informações dos associados.  
    pc_pop_dados_acom_talonarios;  
    
    --Cada Job é responsável em buscar todos os dados da sua agencia na qual foi parametrizada no Job. 
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim - pc_pop_dados_acom_talonarios AGENCIA: ['||pr_cdagenci||'] - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini); 
    
    
    --Quando esta rotina for executada via job criado por paralelismo, o pr_idparale deve ser <> 0
    if pr_idparale <> 0 then
      --Cada Job é responsável em buscar todos os dados da sua agencia na qual foi parametrizada no Job. 
      --Popular a tabela wrk, com as informações das agencias que estao na pl-table.
      pc_popular_tab_agencia_wrk;
      --Popular a tabela wrk, com as informações dos associados que estao na pl-table.
      pc_popular_tab_associado_wrk;
      --Popular a tabela wrk, com as informações dos totais que estao na pl-table.
      pc_popular_tab_totais_wrk;     
    end if; 
    
    --Grava data fim para o JOB na tabela de LOG 
    pc_log_programa(pr_dstiplog   => 'F',    
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini,
                    pr_flgsucesso => 1);

    
  end if;
  
  --Nao foi executado por um job paralelo.    
  if (pr_idparale = 0) then
    
    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => pr_cdcooper,
                                              pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    -- Nome base do arquivo é crrl025
    vr_nom_arquivo  := 'crrl025';                                              
    
    --Apos a finalização de todos os Jobs, é necessário montar o XML.
    
    
    --Caso a Cooperativa tiver jobs para o programa, o xml é montado usando a tabela wrk
    if vr_qtdjobs > 0 and vr_inproces > 2 then
      vr_dsmensag := 'Inicio - pc_gerar_xml_wrk AGENCIA: ['||pr_cdagenci||'] - INPROCES: ['||vr_inproces||']'||
                   ' vr_tpexecucao = [ '||vr_tpexecucao||']';
                   
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);
      pc_gerar_xml_wrk;

      vr_dsmensag := 'Fim - pc_gerar_xml_wrk AGENCIA: ['||pr_cdagenci||'] - INPROCES: ['||vr_inproces||']'||
                   ' vr_tpexecucao = [ '||vr_tpexecucao||']';
                   
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);
                    
      --Limpar a tabela temporaria, todas as agencias.
      pc_clear_memoria(pr_CDAGENCI => 0);
    else
      --Caso a Cooperativa nao tiver jobs para o programa, o xml é montado usando a pl-table
      vr_dsmensag := '*Inicio - pc_gerar_xml_pl_table AGENCIA: ['||pr_cdagenci||'] - INPROCES: ['||vr_inproces||']'||
                     ' vr_tpexecucao = ['||vr_tpexecucao||'] Qtde vr_tab_agencia ['||vr_tab_agencia.count()||']';

      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => vr_dsmensag,
                      PR_IDPRGLOG           => vr_idlog_ini);
       pc_gerar_xml_pl_table;
       
       vr_dsmensag := '*Fim - pc_gerar_xml_pl_table AGENCIA: ['||pr_cdagenci||'] - INPROCES: ['||vr_inproces||']'||
                     ' vr_tpexecucao = ['||vr_tpexecucao||'] Qtde vr_tab_agencia ['||vr_tab_agencia.count()||']';

       pc_log_programa(PR_DSTIPLOG           => 'O',
                       PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                       pr_cdcooper           => pr_cdcooper,
                       pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       pr_tpocorrencia       => 4,
                       pr_dsmensagem         => vr_dsmensag,
                       PR_IDPRGLOG           => vr_idlog_ini);
    end if;
                        
    -- Incializar a varíavel com o XML montado
    --vr_XMLType := XMLType.createXML(vr_des_xml);
    btch0001.pc_gera_log_batch(pr_cdcooper,
                               1, -- Processo normal
                               to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> Geração do PDF --> Coop. --> '||pr_cdcooper||'.',
                               vr_cdprogra);
      
    -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/agencias/agencia/conta', --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl025.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,   --> Enviar como parâmetro apenas a agência
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 80,
                                pr_flg_impri => 'S',           --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => vr_nmformul,   --> Nome do formulário para impressão
                                pr_nrcopias  => 1,             --> Número de cópias para impressão
                                pr_des_erro  => vr_dscritic);       --> Saída com erro
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

    -- Testar se houve erro
    if vr_dscritic is not null then
      raise vr_exc_saida;
    end if;
        
    --Grava data fim para o JOB na tabela de LOG 
    if vr_inproces > 2 and vr_qtdjobs > 0 then 
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra,
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini,
                      pr_flgsucesso => 1); 
    end if;
  
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);


                                 
    if vr_idcontrole <> 0 then
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);
                                         
      -- Testar saida com erro
      if  vr_dscritic is not null then 
        -- Levantar exceçao
        raise vr_exc_saida;
      end if; 
                                                      
    end if;
    
  else
    -- Foi executado por um job paralelo
    -- Atualiza finalização do batch na tabela de controle 
    gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                       ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                       ,pr_dscritic   => vr_dscritic);
                                       
    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                ,pr_des_erro => vr_dscritic);  
    
    pc_log_programa(pr_dstiplog   => 'F',    
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini,
                    pr_flgsucesso => 1);       
  end if;   
  
  commit;
  
exception

  when vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end If;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    commit;

  when vr_exc_saida then
      -- Se foi retornado apenas código
      if vr_cdcritic > 0 and vr_dscritic is null then
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      end if;
      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      rollback;
      --Limpar a tabela wrk somente para a sua agencia.
      if vr_qtdjobs > 0 then
        pc_clear_memoria(pr_CDAGENCI => pr_cdagenci);
        commit;
      end if;
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 2,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini);  
      --Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini,
                      pr_flgsucesso => 0);
      
      if pr_idparale <> 0 then 
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
        commit;
        
      end if; 

  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
    --Limpar a tabela wrk somente para a sua agencia.
    if vr_qtdjobs > 0 then
      pc_clear_memoria(pr_CDAGENCI => pr_cdagenci);
      commit;
    end if;
    pc_log_programa(PR_DSTIPLOG           => 'E',
                    PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 2,
                    pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                             'pr_dscritic:'||pr_dscritic,
                    PR_IDPRGLOG           => vr_idlog_ini);   

    --Grava data fim para o JOB na tabela de LOG 
    pc_log_programa(pr_dstiplog   => 'F',    
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini,
                    pr_flgsucesso => 0);  
    
    if pr_idparale <> 0 then     
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic); 
    end if; 
    commit;
end PC_CRPS024;
/
