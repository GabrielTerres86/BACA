PL/SQL Developer Test script 3.0
1801
-- Created on 08/02/2019 by F0031800 
declare 

wpr_stprogra NUMBER;
wpr_infimsol NUMBER;
wpr_cdcritic NUMBER;
wpr_dscritic VARCHAR2(32767);

PROCEDURE pc_crps388_i(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                   ,pr_flgresta IN PLS_INTEGER             --> Flag padr�o para utiliza��o de restart
                   ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                   ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                   ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  ----------------------------- ESTRUTURAS de MEMORIA -----------------------------
  TYPE typ_reg_craptco IS RECORD(cdcopant craptco.cdcopant%type 
                                ,nrctaant craptco.nrctaant%type
                                ,cdagectl crapcop.cdagectl%type);
  TYPE typ_tab_craptco IS TABLE OF typ_reg_craptco
                          INDEX BY PLS_INTEGER;
  
  ------------------------------- VARIAVEIS GLOBAIS -------------------------------

  -- Tratamento de erros
  vr_excsaida  EXCEPTION;
  vr_excfimpr EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  -- C�digo do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS388';
  -- Calend�rio
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- Cursor COP
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmcidade
          ,cop.cdufdcop
          ,cop.nmrescop
          ,cop.cdagectl
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  ------------------------------- VARIAVEIS ESPECIFICAS -------------------------------
  
  -- Vari�veis espec�ficas para os relat�rios / arquivos 
  vr_camicop      VARCHAR2(1000);
  vr_clobarqu     CLOB;
  vr_txtoarqu     varchar2(32767);
  vr_clobrela     CLOB;
  vr_txtorela     varchar2(32767);
  vr_nmarqdat     varchar2(40);
  vr_nmarqped     varchar2(40);
  vr_nmciddat     varchar2(70);
  vr_nmcidade     varchar2(70);
  vr_dtmvtolt     varchar2(8);
  vr_flgfirst     boolean;
  vr_dtmvtopr     DATE;
  vr_flgrelat     BOOLEAN;
  -- Informa��es dos lan�amentos
  vr_nrseqdig     PLS_INTEGER;
  vr_tot_vlfatura NUMBER;
  vr_tot_vltarifa NUMBER;
  vr_tot_vlapagar NUMBER;
  vr_nrseqndb     PLS_INTEGER;
  vr_vlfatndb     NUMBER;
  vr_nrseqret     PLS_INTEGER;
  vr_vldocto2     NUMBER;
  vr_dsobserv     VARCHAR(15);
  vr_ctamigra     BOOLEAN;
  vr_vlapagar     NUMBER;
  vr_nrseqarq     PLS_INTEGER;
  vr_cdrefere     VARCHAR2(13);
  vr_cdcooper     VARCHAR2(4); 
  vr_nrdconta     VARCHAR2(14);
  vr_nrsequni     NUMBER;
  vr_vllanmto     NUMBER;
  vr_vlfatura     NUMBER;
  vr_vltarifa     NUMBER;
  vr_nragenci     VARCHAR2(4);
  vr_dslinreg     VARCHAR2(255);
  vr_nrseqtot     NUMBER;
  vr_vltotarq     NUMBER;
  vr_nrrefere     VARCHAR2(25);
  vr_qtdigito     INTEGER;
  vr_cdconven     gnconve.cdconven%TYPE := 0;
  ---------------------------------- CURSORES  ----------------------------------
  
  -- Verificar se � conta migrada
  cursor cr_craptco IS
    select tco.nrdconta
          ,tco.cdcopant 
          ,tco.nrctaant
          ,cop.cdagectl
      from craptco tco
          ,crapcop cop
     where tco.cdcopant = cop.cdcooper
       and tco.cdcooper = pr_cdcooper          
       and tco.tpctatrf = 1                     
       and tco.flgativo = 1; 
  vr_tab_tco typ_tab_craptco;
  
  -- Busca os conv�nios ativos de Debito Autom�tico da Cooperativa
  CURSOR cr_gnconve (pr_cdconven in gnconve.cdconven%type) IS   
    SELECT gncvcop.cdconven
          ,gnconve.tprepass
          ,gnconve.nmempres
          ,gnconve.cdhisdeb
          ,gnconve.flgagenc
          ,gnconve.flgcvuni
          ,gnconve.flggeraj
          ,gnconve.nrseqatu
          ,gnconve.nmarqdeb
          ,gnconve.nrcnvfbr
          ,crapcop.cdcooper
          ,crapcop.nmrescop
          ,gnconve.tpdenvio
          ,gnconve.vltrfdeb
          ,gnconve.cddbanco
          ,replace(gnconve.dsenddeb,',,','') dsenddeb /*Remover aqueles sem email*/
          ,gnconve.rowid nrrowid
          ,gnconve.nrlayout
      FROM gncvcop 
          ,gnconve
          ,crapcop 
     WHERE gncvcop.cdcooper = pr_cdcooper
       AND gnconve.cdconven = decode(pr_cdconven,0,gnconve.cdconven,pr_cdconven)
       AND gnconve.cdconven = gncvcop.cdconven
       AND gnconve.flgativo = 1 /* True */
       AND gnconve.cdhisdeb > 0
       AND gnconve.nmarqdeb <> ' ' /* Somente convenios deb.autom. */
       AND crapcop.cdcooper = gnconve.cdcooper;
  
  -- Busca dos lan�amentos efetivados no dia
  CURSOR cr_craplcm(pr_cdhisdeb gnconve.cdhisdeb%TYPE) IS
    SELECT nrdconta
          ,cdhistor 
          ,cdpesqbb
          ,dtmvtolt
          ,nrdocmto
          ,vllanmto
      FROM craplcm 
     WHERE cdcooper = pr_cdcooper      
       AND dtmvtolt = rw_crapdat.dtmvtolt      
       AND cdhistor = pr_cdhisdeb;
  
  -- Checar se existe o lan�amento autom�tico 
  CURSOR cr_craplau(pr_cdcooper number
                   ,pr_nrdconta number 
                   ,pr_cdhistor number
                   ,pr_dtmvtolt date 
                   ,pr_cdpesqbb craplcm.cdpesqbb%type) IS
    SELECT cdcooper
          ,nrdconta
          ,cdhistor
          ,nrcrcard
          ,nrdocmto
          ,dtmvtopg
          ,cdcritic
          ,dscodbar
          ,cdseqtel
          ,tbconv.tppessoa_dest
          ,tbconv.nrcpfcgc_dest
      FROM craplau
          ,tbconv_det_agendamento tbconv
     WHERE craplau.cdcooper  = pr_cdcooper
       AND craplau.nrdconta  = pr_nrdconta 
       AND craplau.cdhistor  = pr_cdhistor  
       AND craplau.dtdebito  = pr_dtmvtolt  
       AND craplau.dsorigem NOT IN('CAIXA','INTERNET','TAA','PG555','CARTAOBB','BLOQJUD','DAUT BANCOOB')
       AND craplau.nrdocmto  = gene0002.fn_busca_entrada(6,SUBSTR(pr_cdpesqbb,6,100),'-')
       AND tbconv.idlancto = craplau.idlancto;
  rw_craplau cr_craplau%ROWTYPE;
  
  -- Verificar se existe autoriza��o de d�bito especifica para CASAN
  CURSOR cr_crapatr_casan(pr_nrdconta craplcm.nrdconta%type
                         ,pr_cdhistor craplcm.cdhistor%type
                         ,pr_cdpesqbb craplcm.cdpesqbb%type) IS 
    SELECT 1
      FROM crapatr 
     WHERE cdcooper = pr_cdcooper  
       AND nrdconta = pr_nrdconta 
       AND cdhistor = pr_cdhistor 
       AND cdrefere = gene0002.fn_busca_entrada(6,SUBSTR(pr_cdpesqbb,6,100),'-')
       AND dtiniatr < to_date('05/10/2016','dd/mm/rrrr');
  vr_atrcasan NUMBER(1);
  
  -- Verificar se existe autoriza��o de d�bito (antigo e novo)
  CURSOR cr_crapatr(pr_nrdconta craplcm.nrdconta%type
                   ,pr_cdhistor craplcm.cdhistor%type
                   ,pr_nrcrcard craplau.nrcrcard%type
                   ,pr_nrdocmto craplau.nrdocmto%type) IS 
    SELECT cdrefere
          ,dtiniatr
      FROM crapatr 
     WHERE cdcooper = pr_cdcooper  
       AND nrdconta = pr_nrdconta 
       AND cdhistor = pr_cdhistor 
       AND cdrefere in(pr_nrcrcard,pr_nrdocmto);
  rw_crapatr cr_crapatr%ROWTYPE;
  
  -- Buscar lan�amentos n�o efetuados do conv�nio 
  CURSOR cr_crapndb(pr_cdhisdeb gnconve.cdhisdeb%TYPE) IS
    SELECT dstexarq
      FROM crapndb 
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = rw_crapdat.dtmvtolt 
       AND cdhistor = pr_cdhisdeb;
        
  -- Buscar informa��es para gera��o do registro J
  CURSOR cr_gnarqrx(pr_cdconven gnconve.cdconven%TYPE) IS 
    SELECT dtgerarq
          ,dtmvtolt
          ,nrsequen
          ,qtregarq
          ,vltotarq
          ,rowid nrrowid
      FROM gnarqrx
     WHERE cdconven = pr_cdconven 
       AND flgretor = 0; --FALSE
       
  -- Utilizado apenas em homologacao de convenios
  CURSOR cr_hconven (pr_cdcooper in crapass.cdcooper%TYPE) IS
  SELECT prm.dsvlrprm
    FROM crapprm prm
   WHERE prm.cdcooper = pr_cdcooper
     AND prm.nmsistem = 'CRED'
     AND prm.cdacesso = 'PRM_HCONVE_CRPS388_IN';
  rw_hconven cr_hconven%ROWTYPE;
  
  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------
  
  -- Procedimento para obten��o da sequencia atual dos arquivos 
  PROCEDURE pc_obtem_atualiza_sequencia(pr_rw_gnconve IN OUT cr_gnconve%ROWTYPE
                                       ,pr_nrseqarq OUT NUMBER 
                                       ,pr_cdcritic OUT NUMBER
                                       ,pr_dscritic OUT VARCHAR2) IS
    -- Buscar a sequencia atual com for-update para garantir o lock na tabela
    CURSOR cr_gnconve IS
      SELECT nrseqatu
        FROM gnconve
       WHERE rowid =  pr_rw_gnconve.nrrowid
         FOR UPDATE;   
    rw_gnconve cr_gnconve%ROWTYPE;      
  BEGIN 
    -- Buscar a sequencia atual com for-update para garantir o lock na tabela
    OPEN cr_gnconve;
    FETCH cr_gnconve
     INTO rw_gnconve; 
    -- Se n�o encontrou nenhuma linhas
    IF cr_gnconve%NOTFOUND THEN
        -- Geraremos critica 151 e sairemos do processo 
        pr_cdcritic := 151;
      CLOSE cr_gnconve;
        RETURN;
      END IF;
    
    -- Utilizar a sequencia atual 
    pr_nrseqarq := rw_gnconve.nrseqatu;
    
    -- Se n�o for conv�nio unificado 
    IF pr_rw_gnconve.flgcvuni = 0 THEN 
      -- Atualizar a sequencia na tabela 
      UPDATE gnconve
         SET nrseqatu = nrseqatu + 1
       WHERE CURRENT OF cr_gnconve;
       -- Atualizar no retorno
       pr_rw_gnconve.nrseqatu := rw_gnconve.nrseqatu + 1;
    END IF;
    -- Nao cria registro de controle se convenio for unificado e a 
    -- execucao for na Cecred, pois quando roda programa que faz a 
    -- unificacao nao atualiza a sequencia do convenio 
    IF pr_cdcooper <> 3 OR pr_rw_gnconve.flgcvuni = 0 THEN
      -- Criaremos registro de controle 
      INSERT INTO gncontr (cdcooper
                          ,tpdcontr
                          ,cdconven
                          ,dtmvtolt
                          ,nrsequen)
                   VALUES (pr_cdcooper
                          ,4
                          ,pr_rw_gnconve.cdconven
                          ,rw_crapdat.dtmvtopr
                          ,pr_nrseqarq);
    END IF;
    
    -- Fechar o cusror para liberar a tabela
    CLOSE cr_gnconve;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      -- Se cursor aberto, liberar a tabela
      IF cr_gnconve%ISOPEN THEN 
        CLOSE cr_gnconve;        
      END IF;
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado - Rotina pc_obtem_atualiza_sequencia - '||sqlerrm;
  
  END pc_obtem_atualiza_sequencia;
  
  -- Procedimento para nomea��o dos arquivos 
  PROCEDURE pc_nomeia_arquivos(pr_rw_gnconve IN OUT cr_gnconve%ROWTYPE
                              ,pr_nrseqarq OUT NUMBER 
                              ,pr_nragenci IN OUT VARCHAR2
                              ,pr_nmarqdat OUT VARCHAR2
                              ,pr_nmarqped OUT VARCHAR2 
                              ,pr_cdcritic OUT NUMBER
                              ,pr_dscritic OUT VARCHAR2) IS
    -- Busca da sequencia atual para a COOP 
    CURSOR cr_gncontr IS  
      SELECT nrsequen
        FROM gncontr  
       WHERE cdcooper = pr_cdcooper     
         AND tpdcontr = 4 -- Debito Automatico                  
         AND cdconven = pr_rw_gnconve.cdconven     
         AND dtmvtolt = rw_crapdat.dtmvtolt;
    -- Numero sequencia
    vr_nrsequen VARCHAR2(6);    
  BEGIN 
    -- Busca da sequencia atual para a COOP 
    OPEN cr_gncontr;
    FETCH cr_gncontr
     INTO pr_nrseqarq;
    -- Se n�o encontrar
    IF cr_gncontr%NOTFOUND THEN 
      -- Fechar o cursor
      CLOSE cr_gncontr;
      -- Gravar a pr�xima sequencia 
      pc_obtem_atualiza_sequencia(pr_rw_gnconve => pr_rw_gnconve
                                 ,pr_nrseqarq => pr_nrseqarq 
                                 ,pr_cdcritic => pr_cdcritic 
                                 ,pr_dscritic => pr_dscritic);
      -- Se retornou erro 
      IF pr_cdcritic <> 0 OR pr_dscritic IS NOT NULL THEN 
        -- Retornar pois houve erro 
        RETURN;
      END IF;
    ELSE 
      -- Apenas fechar o cursor e continuar 
      CLOSE cr_gncontr;
    END IF;    
    
    -- Montagem das variaveis do arquivo / linhas 
    vr_nrsequen := to_char(pr_nrseqarq,'fm000000');
    
    -- Tratamento especifico da CASAN 
    IF pr_rw_gnconve.cdconven = 4 THEN
      pr_nragenci := '1294';
    END IF;
    
    -- Nomenclatura padr�o 
    pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                || to_char(rw_crapdat.dtmvtolt,'mmdd') 
                || '.' || SUBSTR(vr_nrsequen,4,3);
    
    -- Alterar o nome conforme a configura��o do nome do arquivo 
    IF SUBSTR(pr_rw_gnconve.nmarqdeb,5,2)  = 'MM' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,7,2)  = 'DD' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,10,3) = 'TXT' THEN 
      -- 
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                  || to_char(rw_crapdat.dtmvtolt,'mmdd') 
                  || '.txt';
                   
    ELSIF SUBSTR(pr_rw_gnconve.nmarqdeb,5,2)  = 'DD' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,7,2)  = 'MM' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,10,3) = 'RET' THEN 
      --
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                  || to_char(rw_crapdat.dtmvtolt,'ddmm') 
                  || '.ret';
    ELSIF SUBSTR(pr_rw_gnconve.nmarqdeb,5,2)  = 'CP' /* Cooperativa */
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,7,2)  = 'MM' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,9,2)  = 'DD' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,12,3) = 'SEQ' THEN 
      --
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,4)) 
                  || TO_CHAR(pr_rw_gnconve.cdcooper,'FM00')      
                  || to_char(rw_crapdat.dtmvtolt,'mmdd') 
                  || '.' || SUBSTR(vr_nrsequen,4,3);
    
    ELSIF SUBSTR(pr_rw_gnconve.nmarqdeb,4,1)  = 'C' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,5,4)  = 'SEQU' 
      AND SUBSTR(pr_rw_gnconve.nmarqdeb,10,3) = 'RET' THEN 
      --
      pr_nmarqdat := TRIM(SUBSTR(pr_rw_gnconve.nmarqdeb,1,3)) 
                  || TO_CHAR(pr_rw_gnconve.cdcooper,'fm0')       
                  || SUBSTR(vr_nrsequen,3,4) || '.ret';
    END IF;
    
    -- Montar o nome com a pasta de grava��o 
    pr_nmarqped := 'salvar/' || pr_nmarqdat;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado - Rotina pc_nomeia_arquivos - '||sqlerrm;
  
  END pc_nomeia_arquivos;
   
  -- Chamar a atualiza��o do Controle e Devolu��o as Empresas 
  PROCEDURE pc_atualiza_controle(pr_rw_gnconve IN cr_gnconve%ROWTYPE
                                ,pr_nrseqarq   IN NUMBER 
                                ,pr_camicoop   IN VARCHAR2
                                ,pr_nmarqped   IN VARCHAR2
                                ,pr_nmarqdat   IN VARCHAR2
                                ,pr_dtmvtopr   IN DATE 
                                ,pr_nrseqdig      IN NUMBER
                                ,pr_cdconven      IN NUMBER
                                ,pr_tot_vlfatura  IN NUMBER
                                ,pr_tot_vltarifa  IN NUMBER
                                ,pr_tot_vlapagar  IN NUMBER
                                ,pr_cdcritic OUT number
                                ,pr_dscritic OUT VARCHAR2) IS  
    -- Tratamento de comandos no Sistema Operacional
    vr_typsaida VARCHAR2(3);    
  BEGIN 
    -- Caso n�o seja conv�nio unificado 
    IF pr_rw_gnconve.flgcvuni = 0 THEN 
      
      IF pr_cdconven > 0 THEN
        -- Registra parametros para uso interno da rotina
        begin         
          insert 
            into crapprm (nmsistem
                         ,cdcooper
                         ,cdacesso
                         ,dstexprm
                         ,dsvlrprm)
          values        ('CRED'
                         ,pr_cdcooper
                         ,'PRM_HCONVE_CRPS388_OUT'
                         ,'Parametro de entrada do Crps388, auxilia na homologacao dos convenios.'
                         ,vr_camicop||'/'||vr_nmarqped);
        exception
          when dup_val_on_index then
            update crapprm prm
               set prm.dsvlrprm = vr_camicop||'/'||vr_nmarqped
             where prm.cdcooper = pr_cdcooper
               and prm.cdacesso = 'PRM_HCONVE_CRPS388_OUT';
          when others then          
            -- gerando a critica
            pr_dscritic := 'Erro ao inserir dados na tabela crapprm: '||sqlerrm;        
        end;
      END IF;
    
    
      -- Para Internet e E-Sales 
      IF pr_rw_gnconve.tpdenvio IN(1,2) THEN
        -- Vamos converter para DOS 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'ux2dos '||pr_camicoop||'/'||pr_nmarqped ||' >> '||pr_camicoop||'/converte/'||pr_nmarqdat
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
        IF NVL(vr_typsaida,' ') != 'ERR' THEN          
        -- Para e-Sales
        IF pr_rw_gnconve.tpdenvio = 2 THEN 
          -- Copiar para o diret�rio e-Sales
          gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_camicoop||'/converte/'||pr_nmarqdat ||' '||gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_ENVIO_ESALES')
                                     ,pr_typ_saida   => vr_typsaida
                                       ,pr_des_saida   => vr_dscritic);
        ELSE 
          -- Enviaremos email 
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => vr_cdprogra
                                    ,pr_des_destino     => pr_rw_gnconve.dsenddeb
                                    ,pr_des_assunto     => 'ARQUIVO DEBITO AUTOMATICO DA '||rw_crapcop.nmrescop
                                    ,pr_des_corpo       => ' '
                                    ,pr_des_anexo       => pr_camicoop||'/converte/'||pr_nmarqdat
                                    ,pr_flg_remove_anex => 'N'
                                    ,pr_flg_enviar      => 'N'
                                    ,pr_des_erro        => vr_dscritic);        
          END IF;
        END IF;
      -- Para Nexxera 
      ELSIF pr_rw_gnconve.tpdenvio = 3 THEN
        -- Copiar para o diret�rio espec�fico 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_camicoop||'/'||pr_nmarqped ||' '||gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_NEXXERA')
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
      -- Para AccessStage 
      ELSIF pr_rw_gnconve.tpdenvio = 5 THEN
        -- Copiar para o diret�rio arq 
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_camicoop||'/'||pr_nmarqped ||' '||pr_camicoop||'/arq'
                                   ,pr_typ_saida   => vr_typsaida
                                   ,pr_des_saida   => vr_dscritic);
      -- Para WebService
      ELSIF pr_rw_gnconve.tpdenvio = 6 THEN  
        -- Chamar grava��o do arquivo para retorno posterior via WebService
        conv0002.pc_armazena_arquivo_conven(pr_rw_gnconve.cdconven
                                           ,rw_crapdat.dtmvtolt
                                           ,'F' /* Retorno a empresa */
                                           ,0   /* Nao retornado ainda */
                                           ,pr_camicoop||'/salvar'
                                           ,pr_nmarqdat
                                           ,vr_cdcritic
                                           ,vr_dscritic);
        -- Critica 202 � Sucesso no recebimento do arquivo
        IF vr_cdcritic = 202 THEN
          -- Limpar criticas
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        END IF;
      END IF;     
    END IF;  
  
  
    -- Nao cria registro de controle se convenio for unificado e a 
    -- execucao for na Cecred, pois quando roda programa que faz a 
    -- unificacao nao atualiza a sequencia do convenio 
    IF pr_cdcooper <> 3 OR pr_rw_gnconve.flgcvuni = 0 THEN
      -- Criaremos registro de controle 
      UPDATE gncontr        
         SET dtcredit = pr_dtmvtopr
            ,nmarquiv = pr_nmarqdat
            ,qtdoctos = pr_nrseqdig
            ,vldoctos = pr_tot_vlfatura
            ,vltarifa = pr_tot_vltarifa
            ,vlapagar = pr_tot_vlapagar
       WHERE cdcooper = pr_cdcooper 
         AND tpdcontr = 4 
         AND cdconven = pr_rw_gnconve.cdconven
         AND dtmvtolt = rw_crapdat.dtmvtopr
         AND nrsequen = pr_nrseqarq;
    END IF;
    
    -- Gerar LOG se houve encontro de critica
    IF nvl(vr_cdcritic,0) <> 0 OR nvl(vr_typsaida,' ') = 'ERR' THEN 
      -- Gerar log no proc_message e continuar 
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> Erro no retorno do arquivo para a empresa --> ' || vr_dscritic 
                                                 || ' Convenio --> '|| pr_rw_gnconve.cdconven);
      -- Limpar erros                                    
      vr_cdcritic := 0;
      vr_dscritic := null;    
    END IF;
    
  EXCEPTION 
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado - Rotina pc_atualiza_controle - '||sqlerrm;
  END pc_atualiza_controle; 
  
  -- Codigo principal da rotina  
  BEGIN
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 057;
      RAISE vr_excsaida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calend�rio da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
     
    rw_crapdat.dtmvtolt := to_date('07022019','ddmmyyyy');
    rw_crapdat.dtmvtopr := to_date('08022019','ddmmyyyy'); 
    rw_crapdat.dtmvtoan := to_date('06022019','ddmmyyyy'); 
    rw_crapdat.dtmvtocd := to_date('07022019','ddmmyyyy');
    
    -- Se n�o encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_excsaida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Valida��es iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro � <> 0
    IF nvl(vr_cdcritic,0) <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_excsaida;
    END IF;
    
    -- Carregar tabela de contas migradas
    FOR rw_tco IN cr_craptco LOOP 
      -- Carregar a tabela 
      vr_tab_tco(rw_tco.nrdconta).cdcopant := rw_tco.cdcopant;
      vr_tab_tco(rw_tco.nrdconta).nrctaant := rw_tco.nrctaant;
      vr_tab_tco(rw_tco.nrdconta).cdagectl := rw_tco.cdagectl;
    END LOOP;
    
    -- Busca do caminho da Cooperativa
    vr_camicop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper);
    
    -- Montagem das informa��es para os comunidados as empresas
    vr_nmciddat := trim(rw_crapcop.nmcidade) ||', ' 
                                             || to_char(rw_crapdat.dtmvtolt,'dd "de" FMMONTH "de" YYYY','nls_date_language = ''BRAZILIAN PORTUGUESE''');
    vr_nmcidade := trim(rw_crapcop.nmcidade) ||' - '||trim(rw_crapcop.cdufdcop);
    
    -- Montagem de auxiliares para os arquivos 
    vr_dtmvtolt := to_char(rw_crapdat.dtmvtolt,'rrrrmmdd');
    vr_flgfirst := true;

    -- Analisa se esta sendo homologado 
    -- algum convenio (busca parametros)
    open cr_hconven (pr_cdcooper);
    fetch cr_hconven into rw_hconven;
    
    -- Se encontrou limita loop de convenios
    if cr_hconven%found then
      vr_cdconven := rw_hconven.dsvlrprm;
    end if;
    
    close cr_hconven;

    -- Busca de todos os conv�nios de debito autom�tico vinculados a Cooperativa
    FOR rw_gnconve IN cr_gnconve (vr_cdconven) LOOP 
      -- Montagem da data de repassa
      /*IF rw_gnconve.tprepass = 1 THEN 
        -- D+1*/
        vr_dtmvtopr := rw_crapdat.dtmvtopr;
      /*ELSE
        -- D+2 
        vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper 
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtopr+1
                                                  ,pr_tipo => 'P') ;
      END IF;     */ 
      
      -- Reiniciar totais e controladores por conv�nio
      vr_flgfirst := TRUE;
      vr_nrseqdig := 0;
      vr_vlfatura := 0;
      vr_vltarifa := 0;
      vr_vlapagar := 0;
      vr_nrseqndb := 0;
      vr_vlfatndb := 0;
      vr_flgrelat := FALSE;
      vr_nrseqret := 0;
      vr_vldocto2 := 0; 
      vr_tot_vlfatura := 0;
      vr_tot_vlapagar := 0;
      vr_tot_vltarifa := 0;
      
      -- Busca dos lan�amentos efetivados no dia
      FOR rw_craplcm IN cr_craplcm(rw_gnconve.cdhisdeb) LOOP 
        -- Reiniciar controladores por lan�amentos 
        vr_dsobserv := NULL;
        vr_ctamigra := FALSE; 

        -- Armazenar agencia da Cooperativa
        vr_nragenci := to_char(rw_crapcop.cdagectl, 'fm0000');
        
        -- Verificar se existe autoriza��o de d�bito especifica para CASAN
        IF rw_gnconve.cdconven = 4 THEN 
          
          OPEN cr_crapatr_casan(pr_nrdconta => rw_craplcm.nrdconta
                               ,pr_cdhistor => rw_craplcm.cdhistor
                               ,pr_cdpesqbb => rw_craplcm.cdpesqbb);
          FETCH cr_crapatr_casan 
           INTO vr_atrcasan;
          -- Se encontrar
          IF cr_crapatr_casan%FOUND THEN 
            -- Usar c�digo fixo
            vr_nragenci := '1294';
          END IF;
          CLOSE cr_crapatr_casan; 
          
        END IF;  
        
        
        -- Para o primeiro registro do arquivo 
        IF vr_flgfirst THEN 
          -- Nomea��o dos arquivos 
          pc_nomeia_arquivos(pr_rw_gnconve => rw_gnconve
                            ,pr_nrseqarq => vr_nrseqarq
                            ,pr_nragenci => vr_nragenci
                            ,pr_nmarqdat => vr_nmarqdat
                            ,pr_nmarqped => vr_nmarqped
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          -- Se houve erro 
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
            -- Sair 
            RAISE vr_excsaida;
          END IF;
          
          -- Abrir os CLOBs para Arquivo e Relat�rios
          vr_clobarqu := NULL;
          dbms_lob.createtemporary(vr_clobarqu, TRUE);
          dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
          vr_clobrela := NULL;
          dbms_lob.createtemporary(vr_clobrela, TRUE);
          dbms_lob.open(vr_clobrela, dbms_lob.lob_readwrite);
          
          -- Enviar Header do Arquivo 
          gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,'A2'
                                ||RPAD(rw_gnconve.nrcnvfbr,20,' ')
                                ||RPAD(substr(rw_gnconve.nmempres,1,20),20,' ')
                                ||to_char(rw_gnconve.cddbanco,'fm000')
                                ||RPAD(substr(rw_gnconve.nmrescop,1,20),20,' ')
                                ||vr_dtmvtolt
                                ||to_char(vr_nrseqarq,'fm000000')
                                ||LPAD(rw_gnconve.nrlayout,2,'0')
                                ||'DEBITO AUTOMATICO'
                                ||RPAD(' ',52,' ')
                                ||CHR(10));          
          
          -- Inicilizar as informa��es do Relat�rio
          gene0002.pc_escreve_xml(vr_clobrela
                                 ,vr_txtorela
                                 ,'<?xml version="1.0" encoding="utf-8"?><crrl350 nmarqdat="'||vr_nmarqdat||'" dtmvtopr="'||to_char(vr_dtmvtopr,'dd/mm/rrrr')||'" nmempcov="'||rw_gnconve.nmempres||'"><lcts>');          
          
          -- Atualizar as Flags
          vr_flgfirst := FALSE;
          vr_flgrelat := TRUE;
        END IF;
        
        -- Checar se a conta � migrada 
        IF vr_tab_tco.exists(rw_craplcm.nrdconta) THEN 
          vr_ctamigra := true;
        ELSE 
          vr_ctamigra := false;
        END IF;        
        
        -- Verificar se existe o lan�amento migrada 
        OPEN cr_craplau(pr_cdcooper
                       ,rw_craplcm.nrdconta
                       ,rw_craplcm.cdhistor
                       ,rw_craplcm.dtmvtolt
                       ,rw_craplcm.cdpesqbb);
                       
        FETCH cr_craplau INTO rw_craplau;
        
        -- Se n�o encontrar 
        IF cr_craplau%NOTFOUND THEN 

          CLOSE cr_craplau;

          /** Verifica se eh conta migrada e se foi enviado 
              para agendamento na coop. anterior ***/
          IF vr_ctamigra THEN      
                   
            -- Buscar na Cooperativa anterior
            OPEN cr_craplau(vr_tab_tco(rw_craplcm.nrdconta).cdcopant
                           ,vr_tab_tco(rw_craplcm.nrdconta).nrctaant
                           ,rw_craplcm.cdhistor
                           ,rw_craplcm.dtmvtolt
                           ,rw_craplcm.cdpesqbb);
                           
            FETCH cr_craplau INTO rw_craplau;

            -- Se n�o encontrar 
            IF cr_craplau%NOTFOUND THEN 
              CLOSE cr_craplau;
              -- Gerar critica 501 no proc_message
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(501) 
                                                         || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                         || ' Documento = ' || rw_craplcm.nrdocmto);
              -- Ir ao pr�ximo registro (Ignorar LCM)
              CONTINUE;   

            ELSE
              CLOSE cr_craplau;
            END IF;

          ELSE

            -- Gerar critica 501 no proc_message
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(501) 
                                                       || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                       || ' Documento = ' || rw_craplcm.nrdocmto);
            -- Ir ao pr�ximo registro (Ignorar LCM)
            CONTINUE;   

          END IF;
        ELSE 
          CLOSE cr_craplau;
        END IF;        
        
        -- Verificar se existe autoriza��o de d�bito (antigo e novo)
        OPEN cr_crapatr(rw_craplcm.nrdconta
                       ,rw_craplau.cdhistor
                       ,rw_craplau.nrcrcard
                       ,rw_craplau.nrdocmto);
        FETCH cr_crapatr
         INTO rw_crapatr;
        -- Se n�o encontrar 
        IF cr_crapatr%NOTFOUND THEN 
          CLOSE cr_crapatr;
          -- Gerar critica 453
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(453) 
                                                     || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                     || ' Documento = ' || rw_craplcm.nrdocmto);
          -- Ir ao pr�ximo registro (Ignorar LCM)
          CONTINUE;   
        ELSE 
          CLOSE cr_crapatr;
        END IF;       
        
        -- Convenio 1 n�o pode ter referencia com mais de 11 posi��es
        IF rw_gnconve.cdconven = 1 AND  LENGTH(to_char(rw_crapatr.cdrefere,'fm999999999999990')) > 11 THEN
          -- Gerar critica 654
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> ' || gene0001.fn_busca_critica(654)
                                                     || ' Conta = '|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)
                                                     || ' Documento = ' || rw_craplcm.nrdocmto);
          -- Ir ao pr�ximo registro (Ignorar LCM)
          CONTINUE;  
        END IF;
         
        -- Referencia diferenciada para o conv�nio 1
        IF rw_gnconve.cdconven = 1 THEN 
          vr_cdrefere := gene0002.fn_mask(rw_crapatr.cdrefere,'999.999.999.9');
        ELSIF rw_gnconve.cdconven IN(9,16,24,31,33,34,53,54) THEN 
          /* 31 DAE Navegantes */
          /* 33 Aguas de Joinville */
          /* 34 SEMASA Itajai */
          /* 53 Foz do Brasil */
          /* 54 Aguas de Massaranduba */
          vr_cdrefere := gene0002.fn_mask(rw_crapatr.cdrefere,'9999.999.9');        
        ELSE 
          vr_cdrefere := substr(to_char(rw_crapatr.cdrefere,'fm9999999999999999999999990'),1,13);
        END IF;
        
        -- Acumular valores 
        vr_nrseqdig := vr_nrseqdig + 1;
        vr_tot_vlfatura := vr_tot_vlfatura + rw_craplcm.vllanmto;
        
        -- MOntagem prefixo da Cooperativa 
        IF (   rw_gnconve.cdcooper = pr_cdcooper 
            OR pr_cdcooper = 1                 
            OR rw_gnconve.flgagenc = 1 /*TRUE*/
            OR rw_crapatr.dtiniatr  > to_date('01/09/2013','dd/mm/rrrr')) 
            /*32 UNIODONTO*/ 
            /*38 UNIM.PLAN.NORTE*/
            /*43 SERVMED*/
            /*46 UNIODONTO FEDER.*/
            /*47 UNIMED CREDCREA*/
            /*55 LIBERTY*/
            /*57 RBS*/
            /*58 PORTO SEGURO*/
            AND (rw_gnconve.cdconven NOT IN(22,32,38,43,46,47,55,57,58)) THEN 
          vr_cdcooper := ' ';
        ELSE
          vr_cdcooper := '9' || TO_CHAR(pr_cdcooper,'fm000');
        END IF;

        -- Montagem do prefixo Cooperativa em caso de Migra��o
        IF vr_ctamigra THEN 
          -- Se a cooperativa anterior igual ao do agendamento 
          IF (   rw_craplau.cdcooper = vr_tab_tco(rw_craplau.nrdconta).cdcopant 
              OR rw_craplau.cdcritic = 951                
              OR UPPER(rw_craplau.dscodbar) = 'MIGRADO') THEN
            -- Tratamento conforme os conv�nios 
              /*32 UNIODONTO*/ 
              /*38 UNIM.PLAN.NORTE*/
              /*43 SERVMED*/
              /*46 UNIODONTO FEDER.*/
              /*47 UNIMED CREDCREA*/
              /*55 LIBERTY*/
              /*57 RBS*/
              /*58 PORTO SEGURO*/
            IF vr_tab_tco(rw_craplau.nrdconta).cdcopant = 1 AND (rw_gnconve.cdconven NOT IN(22,32,38,43,46,47,55,57,58)) THEN 
              vr_cdcooper := ' ';
            ELSE
              IF rw_gnconve.flgagenc = 1 /*true*/ THEN
                vr_cdcooper := ' '; 
              ELSE   
                vr_cdcooper := '9' || TO_CHAR(vr_tab_tco(rw_craplau.nrdconta).cdcopant,'fm000');
              END IF;  
            END IF;
            -- Montar observa��o 
            vr_dsobserv := 'Debito migrado.';
            -- Usar agencia da Cooperativa Anterior
            vr_nragenci := to_char(vr_tab_tco(rw_craplau.nrdconta).cdagectl,'fm9999');
          END IF;
        END IF;  
        
        -- Se n�o conseguirmos montar a Cooperativa ainda
        IF vr_cdcooper = ' ' THEN 
          -- Para convenios 9, 74 e 75 
          IF rw_gnconve.cdconven IN(9,74,75) THEN 
            -- Para conta migrada 
            IF vr_ctamigra AND vr_dsobserv IS NOT NULL THEN 
              vr_nrdconta := to_char(vr_tab_tco(rw_craplcm.nrdconta).nrctaant,'fm00000000000000');
            ELSE 
              vr_nrdconta := to_char(rw_craplcm.nrdconta,'fm00000000000000');
            END IF;
          ELSE 
            -- Para conta migrada 
            IF vr_ctamigra AND vr_dsobserv IS NOT NULL THEN 
              vr_nrdconta := to_char(vr_tab_tco(rw_craplcm.nrdconta).nrctaant,'fm00000000');
            ELSE 
              vr_nrdconta := to_char(rw_craplcm.nrdconta,'fm00000000');
            END IF;
          END IF;
        ELSE           
          -- Para o conv�nio 9
          IF rw_gnconve.cdconven = 9 THEN 
            -- Incluir dois espa�os na frente
            vr_nrdconta := '  ';
          ELSE
            vr_nrdconta := NULL;
          END IF;
          -- Incluir a Cooperativa
          vr_nrdconta := vr_nrdconta||to_char(vr_cdcooper,'fm0000');          
          -- Para conta migrada 
          IF vr_ctamigra AND vr_dsobserv IS NOT NULL THEN 
            vr_nrdconta := vr_nrdconta||to_char(vr_tab_tco(rw_craplcm.nrdconta).nrctaant,'fm00000000');
          ELSE 
            vr_nrdconta := vr_nrdconta||to_char(rw_craplcm.nrdconta,'fm00000000');
          END IF;          
        END IF;
        
        -- Remover espa�os
        vr_cdrefere := TRIM(vr_cdrefere);
        
        -- Enviar registro para o relat�rio 
        gene0002.pc_escreve_xml(vr_clobrela
                               ,vr_txtorela
                               , '<lcto>'
                               || ' <nrdconta>'||gene0002.fn_mask_conta(rw_craplcm.nrdconta)||'</nrdconta>'
                               || ' <cdrefere>'||vr_cdrefere||'</cdrefere>'
                               || ' <vllanmto>'||to_char(rw_craplcm.vllanmto,'fm999G999G999G999G990d00')||'</vllanmto>'
                               || ' <dtmvtolt>'||to_char(rw_craplcm.dtmvtolt,'dd/mm/rrrr')||'</dtmvtolt>'
                               || ' <dsobserv>'||vr_dsobserv||'</dsobserv>'
                               ||'</lcto>');
        
        -- Buscar referencia formatada
        conv0001.pc_retorna_referencia_conv(pr_cdconven => rw_gnconve.cdconven
                                           ,pr_cdhistor => 0
                                           ,pr_cdrefere => rw_crapatr.cdrefere
                                           ,pr_nrrefere => vr_nrrefere
                                           ,pr_qtdigito => vr_qtdigito
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        
        IF rw_gnconve.nrlayout = 5 THEN
      
          -- CERSAD e SANEPAR
          IF vr_qtdigito <> 0 THEN
            vr_dslinreg := 'F' 
                    || vr_nrrefere
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')                       
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';

          /* Celesc Distribuicao */  
          /* Aguas Pres.Getulio  */
          ELSIF rw_gnconve.cdconven IN (30,45) THEN                   
            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm000000000')
                    || RPAD(' ',16,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')                       
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
                    
          /* CASAN */           
          /* AGUAS ITAPEMA */           
          /* DAE NAVEGANTES */           
          /* AGUAS JOINVILLE */           
          /* SEMASA ITAJAI */           
          /* Foz do Brasil */           
          /* AGUAS DE MASSARANDUBA */ 
      /* 108 - AGUAS DE GUARAMIRIM */
          ELSIF rw_gnconve.cdconven IN (4,24,31,33,34,53,54,108) THEN  

            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm00000000')
                    || RPAD(' ',17,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt                          
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
                    
          /* TIM Celular */          
          /* HDI */          
          /* LIBERTY */          
          /* PORTO SEGURO */          
          /* PREVISUL */          
          ELSIF rw_gnconve.cdconven IN (48,50,55,58,66) THEN  
                         
            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm00000000000000000000')
                    || RPAD(' ',5,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
                    
          /* UNIMED CREDCREA */          
          /* RBS */
          ELSIF rw_gnconve.cdconven IN (47,57) THEN  

            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm00000000000000000')
                    || RPAD(' ',8,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
                    
          /* UNIMED */          
          /* UNIODONTO */          
          /* UNIM.PLAN.NORTE */           
          /* UNIODONTO FEDERACAO */          
          /* AZUL SEGUROS */   
          ELSIF rw_gnconve.cdconven IN (22,32,38,46,64) THEN   
                
            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm0000000000000000000000000')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || vr_dtmvtolt
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
             
          /* VIVO */       
          ELSIF rw_gnconve.cdconven IN (15)   THEN 

            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm00000000000')
                    || LPAD(' ',14,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00'                                   
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
                    
          /*SAMAE Jaragua*/           
          /*SAMAE Gaspar */           
          /*SAMAE Blumenau CECRED*/           
          /*SAMAE Timbo CECRED*/           
          /*SAMAE Rio Negrinho*/           
          ELSIF rw_gnconve.cdconven IN (9,19,20,16,49) THEN  
                
            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm000000')
                    || LPAD(' ',19,' ')
                    || to_char(vr_nragenci,'fm0000')
                    || RPAD(vr_nrdconta,14,' ')
                    || TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    ||'00'
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
          
          /* BRASIL TELECOM/SC */
          /* SAMAE BRUSQUE */
          /* SAMAE POMERODE */
          /* AGUAS DE JOINVILLE */
          /* SEGURO AUTO */
          /* SAMAE SAO BENTO */
          /* SERVMED */
          /* AGUAS DE ITAPOCOROY */           
          ELSIF rw_gnconve.cdconven IN (1,25,26,33,39,41,43,62) THEN
                
            vr_dslinreg := 'F' 
                    || to_char(rw_crapatr.cdrefere,'fm0000000000')
                    || LPAD(' ',15,' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
            
          /* MAPFRE VERA CRUZ SEG */        
          ELSIF rw_gnconve.cdconven IN (74,75) THEN
                
            vr_dslinreg := 'F' 
                    || rw_crapatr.cdrefere 
                    || LPAD(' ',25 - length(rw_crapatr.cdrefere),' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
                    
          ELSIF rw_gnconve.cdconven = 112 THEN -- chubb seguros
              vr_dslinreg := 'F'
                    || to_char(rw_crapatr.cdrefere,'fm00000000000000000000000')
                    || RPAD(' ',2,' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
          ELSE
              vr_dslinreg := 'F'
                    || to_char(rw_crapatr.cdrefere,'fm0000000000000000000000')
                    || RPAD(' ',3,' ') 
                    || to_char(vr_nragenci,'fm0000') 
                    || RPAD(vr_nrdconta,14,' ') 
                    || vr_dtmvtolt 
                    || to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                    || '00' 
                    || rpad(rw_craplau.cdseqtel,60,' ') 
                    || to_char(rw_craplau.tppessoa_dest,'fm0') 
                    || to_char(rw_craplau.nrcpfcgc_dest,'fm000000000000000') 
                    || RPAD(' ',4,' ') || '0';
          END IF;
       
       ELSE
    
          -- Enviar informa��es para o arquivo conforme especificidades do conv�nio

          IF vr_qtdigito <> 0 THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||vr_nrrefere
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||RPAD(' ',20,' ')||'0';       
          
          
          /* 30 - Celesc Distribuicao */
          /* 45 - Aguas Pres.Getulio  */
          ELSIF rw_gnconve.cdconven IN(30,45) THEN    
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||to_char(rw_crapatr.cdrefere,'fm000000000')
                        ||RPAD(' ',16,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||RPAD(' ',20,' ')||'0';       
          /* 4  - CASAN */
          /* 24 - AGUAS ITAPEMA */
          /* 31 - DAE NAVEGANTES */
          /* 33 - AGUAS JOINVILLE */
          /* 34 - SEMASA ITAJAI */
          /* 53 - Foz do Brasil */
          /* 54 - AGUAS DE MASSARANDUBA */  
      /* 108 - AGUAS DE GUARAMIRIM */
          ELSIF rw_gnconve.cdconven IN(4,24,31,33,34,53,54,108) THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||to_char(rw_crapatr.cdrefere,'fm00000000')
                        ||RPAD(' ',17,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||RPAD(' ',20,' ')||'0';
          /* 48 - TIM Celular */
          /* 50 - HDI */
          /* 55 - LIBERTY */
          /* 58 - PORTO SEGURO */
          /* 66 - PREVISUL */        
          ELSIF rw_gnconve.cdconven IN(48,50,55,58,66) THEN  
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||to_char(rw_crapatr.cdrefere,'fm00000000000000000000')
                        ||RPAD(' ',5,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||TO_CHAR(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';
          /* 47 - UNIMED CREDCREA */
          /* 57 - RBS */
          ELSIF rw_gnconve.cdconven IN(47,57) THEN     
            -- Enviar linha ao arquivo 
            vr_dslinreg :='F'
                        ||to_char(rw_crapatr.cdrefere,'fm00000000000000000')
                        ||RPAD(' ',8,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||TO_CHAR(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';
          /* 22 - UNIMED */
          /* 32 - UNIODONTO */
          /* 38 - UNIM.PLAN.NORTE */ 
          /* 46 - UNIODONTO FEDERACAO */
          /* 64 - AZUL SEGUROS */   
          ELSIF rw_gnconve.cdconven IN(22,32,38,46,64) THEN   
            -- Enviar linha ao arquivo 
            vr_dslinreg :='F'
                        ||to_char(rw_crapatr.cdrefere,'fm0000000000000000000000000')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||TO_CHAR(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';
          /* 15 - VIVO */
          ELSIF rw_gnconve.cdconven = 15 THEN 
            -- Enviar linha ao arquivo 
            vr_dslinreg :='F'
                        ||to_char(rw_crapatr.cdrefere,'fm00000000000')
                        ||LPAD(' ',14,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||RPAD(' ',20,' ')||'0';
          /* 9 - SAMAE Jaragua*/
          /*19 - SAMAE Gaspar */
          /*20 - SAMAE Blumenau CECRED*/
          /*16 - SAMAE Timbo CECRED*/
          /*49 - SAMAE Rio Negrinho*/
          ELSIF rw_gnconve.cdconven IN(9,19,20,16,49) THEN  
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||to_char(rw_crapatr.cdrefere,'fm000000')
                        ||LPAD(' ',19,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||TO_CHAR(rw_craplau.dtmvtopg,'rrrrmmdd')
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||RPAD(' ',20,' ')||'0';
          /*  1 - BRASIL TELECOM/SC */
          /* 25 - SAMAE BRUSQUE */
          /* 26 - SAMAE POMERODE */
          /* 33 - AGUAS DE JOINVILLE */
          /* 39 - SEGURO AUTO */
          /* 41 - SAMAE SAO BENTO */
          /* 43 - SERVMED */
          /* 62 - AGUAS DE ITAPOCOROY */ 
          ELSIF rw_gnconve.cdconven IN(1,25,26,33,39,41,43,62) THEN 
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||to_char(rw_crapatr.cdrefere,'fm0000000000')
                        ||LPAD(' ',15,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||TO_CHAR(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';        
          /* 74 e 75 - MAPFRE VERA CRUZ SEG */ 
          ELSIF rw_gnconve.cdconven IN(74,75) THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||rw_crapatr.cdrefere
                      ||LPAD(' ',25-length(rw_crapatr.cdrefere),' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||RPAD(' ',20,' ')||'0';
        ELSIF rw_gnconve.cdconven = 112 THEN -- chubb seguros
            -- Enviar linha ao arquivo 
            vr_dslinreg := 'F'
                        ||to_char(rw_crapatr.cdrefere,'fm00000000000000000000000')
                        ||LPAD(' ',2,' ')
                        ||to_char(vr_nragenci,'fm0000')
                        ||RPAD(vr_nrdconta,14,' ')
                        ||vr_dtmvtolt
                        ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                        ||'00'
                        ||rpad(rw_craplau.cdseqtel,60,' ')
                        ||TO_CHAR(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';              
        ELSE
          -- Todos outros casos 
          -- Enviar linha ao arquivo 
          vr_dslinreg := 'F'
                      ||to_char(rw_crapatr.cdrefere,'fm0000000000000000000000')
                      ||LPAD(' ',3,' ')
                      ||to_char(vr_nragenci,'fm0000')
                      ||RPAD(vr_nrdconta,14,' ')
                      ||vr_dtmvtolt
                      ||to_char((rw_craplcm.vllanmto * 100),'fm000000000000000')
                      ||'00'
                      ||rpad(rw_craplau.cdseqtel,60,' ')
                      ||TO_CHAR(vr_dtmvtopr,'rrrrmmdd')
                      ||RPAD(' ',12,' ')||'0';              
          END IF;
        END IF;
          
        
        -- Enviar para o arquivo 
        gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,vr_dslinreg||CHR(10));    
        
        -- Criar registro unificado 
        IF rw_gnconve.flgcvuni = 1 THEN 
          BEGIN 
            INSERT INTO gncvuni(cdcooper
                               ,cdconven
                               ,dtmvtolt
                               ,flgproce
                               ,nrseqreg
                               ,dsmovtos
                               ,tpdcontr)
                         VALUES(pr_cdcooper
                               ,rw_gnconve.cdconven
                               ,rw_crapdat.dtmvtolt
                               ,0 /*FALSE*/
                               ,vr_nrseqdig
                               ,vr_dslinreg
                               ,2); /* DEB. AUTOMATICO */
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro na gravacao da gncvuni --> '||sqlerrm;
              RAISE vr_excsaida;
          END;
        END IF;
      
      END LOOP; -- Loop lan�amentos do dia 
      
      -- Sequencia unificada 
      vr_nrsequni := vr_nrseqdig;
      
      -- Buscar lan�amentos n�o efetuados do conv�nio 
      FOR rw_crapndb IN cr_crapndb(rw_gnconve.cdhisdeb) LOOP
        -- Para o primeiro registro do arquivo 
        IF vr_flgfirst THEN 
          -- Nomea��o dos arquivos 
          pc_nomeia_arquivos(pr_rw_gnconve => rw_gnconve
                            ,pr_nrseqarq => vr_nrseqarq
                            ,pr_nragenci => vr_nragenci
                            ,pr_nmarqdat => vr_nmarqdat
                            ,pr_nmarqped => vr_nmarqped
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
          -- Se houve erro 
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
            -- Sair 
            RAISE vr_excsaida;
          END IF;
          
          -- Abrir os CLOBs para Arquivo 
          vr_clobarqu := NULL;
          dbms_lob.createtemporary(vr_clobarqu, TRUE);
          dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
          
          -- Enviar Header do Arquivo 
          gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,'A2'
                                ||RPAD(rw_gnconve.nrcnvfbr,20,' ')
                                ||RPAD(substr(rw_gnconve.nmempres,1,20),20,' ')
                                ||to_char(RW_gnconve.cddbanco,'fm000')
                                ||RPAD(substr(rw_gnconve.nmrescop,1,20),20,' ')
                                ||vr_dtmvtolt
                                ||to_char(vr_nrseqarq,'fm000000')
                                ||LPAD(rw_gnconve.nrlayout,2,'0')
                                ||'DEBITO AUTOMATICO'
                                ||RPAD(' ',52,' ')
                                ||CHR(10));          
          
          -- Atualizar as Flags
          vr_flgfirst := FALSE;
        END IF;
        
        --Se conv�nvio utiliza vers�o 5 do layout fefraban
        IF rw_gnconve.nrlayout = 5 THEN

          IF rw_gnconve.cdconven = 19 THEN

            vr_dslinreg := RPAD(SUBSTR(rw_crapndb.dstexarq,1,127),127,' ')
                     || RPAD(' ',2,' ')
                     || SUBSTR(rw_crapndb.dstexarq,130,1) 
                     || SUBSTR(rw_crapndb.dstexarq,131,15)
                     || RPAD(' ',4,' ') || '0';

          ELSIF rw_gnconve.cdconven IN (4,15,16,45,50,9,74,75) THEN
            
            -- Enviar linha ao arquivo 
            vr_dslinreg := RPAD(rw_crapndb.dstexarq,150,' ');
            
          ELSE
            
            /* Gravar o gncvuni */
            vr_dslinreg := RPAD(SUBSTR(rw_crapndb.dstexarq,1,129),129,' ') 
                     || SUBSTR(rw_crapndb.dstexarq,130,1) 
                     || SUBSTR(rw_crapndb.dstexarq,131,15)
                     || RPAD(' ',4,' ') || '0';
                     
          END IF;
          
        ELSE
               
          /* Convenio 19 */ 
          IF rw_gnconve.cdconven = 19 THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := RPAD(SUBSTR(rw_crapndb.dstexarq,1,127),127+22,' ') ||'0';
          -- Outros casos espec�ficos 
          ELSIF rw_gnconve.cdconven IN(4,15,16,45,50,9,74,75) THEN
            -- Enviar linha ao arquivo 
            vr_dslinreg := RPAD(rw_crapndb.dstexarq,150,' ');
          ELSE
            -- Todos outros casos 
            vr_dslinreg := RPAD(SUBSTR(rw_crapndb.dstexarq,1,129),129,' ')
                        ||to_char(vr_dtmvtopr,'rrrrmmdd')
                        ||RPAD(' ',12,' ')||'0';              
          END IF;
          
        END IF;
        
        -- Enviar para o arquivo 
        gene0002.pc_escreve_xml(vr_clobarqu
                               ,vr_txtoarqu
                               ,vr_dslinreg||CHR(10));   
        
        -- Criar registro unificado 
        IF rw_gnconve.flgcvuni = 1 THEN 
          -- INcrementar o contador 
          vr_nrsequni := vr_nrsequni + 1;          
          BEGIN 
            INSERT INTO gncvuni(cdcooper
                               ,cdconven
                               ,dtmvtolt
                               ,flgproce
                               ,nrseqreg
                               ,dsmovtos
                               ,tpdcontr)
                         VALUES(pr_cdcooper
                               ,rw_gnconve.cdconven
                               ,rw_crapdat.dtmvtolt
                               ,0 /*FALSE*/
                               ,vr_nrsequni
                               ,vr_dslinreg
                               ,2); /* DEB. AUTOMATICO */
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro na gravacao da gncvuni --> '||sqlerrm;
              RAISE vr_excsaida;
          END;
        END IF;
        
        -- Acumular totalizadores
        vr_nrseqndb := vr_nrseqndb + 1;
        vr_vllanmto := nvl(to_number(TRIM(SUBSTR(rw_crapndb.dstexarq,53,15))),0);
        vr_vllanmto := vr_vllanmto / 100;
        vr_vlfatndb := vr_vlfatndb + vr_vllanmto;        
      
      END LOOP;
      
      -- Se conv�nio gera registro "J"
      IF rw_gnconve.flggeraj = 1 THEN 
        -- Buscar os registro pendentes de envio 
        FOR rw_gnarqrx IN cr_gnarqrx(rw_gnconve.cdconven) LOOP 
          -- Para o primeiro registro do arquivo 
          IF vr_flgfirst THEN 
            -- Nomea��o dos arquivos 
            pc_nomeia_arquivos(pr_rw_gnconve => rw_gnconve
                              ,pr_nrseqarq => vr_nrseqarq
                              ,pr_nragenci => vr_nragenci
                              ,pr_nmarqdat => vr_nmarqdat
                              ,pr_nmarqped => vr_nmarqped
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
            -- Se houve erro 
            IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
              -- Sair 
              RAISE vr_excsaida;
            END IF;
            
            -- Abrir os CLOBs para Arquivo 
            vr_clobarqu := NULL;
            dbms_lob.createtemporary(vr_clobarqu, TRUE);
            dbms_lob.open(vr_clobarqu, dbms_lob.lob_readwrite);
            
            -- Enviar Header do Arquivo 
            gene0002.pc_escreve_xml(vr_clobarqu
                                   ,vr_txtoarqu
                                   ,'A2'
                                  ||RPAD(rw_gnconve.nrcnvfbr,20,' ')
                                  ||RPAD(substr(rw_gnconve.nmempres,1,20),20,' ')
                                  ||to_char(rw_gnconve.cddbanco,'fm000')
                                  ||RPAD(substr(rw_gnconve.nmrescop,1,20),20,' ')
                                  ||vr_dtmvtolt
                                  ||to_char(vr_nrseqarq,'fm000000')
                                  ||LPAD(rw_gnconve.nrlayout,2,'0')
                                  ||'DEBITO AUTOMATICO'
                                  ||RPAD(' ',52,' ')
                                  ||CHR(10));          
            
            -- Atualizar as Flags
            vr_flgfirst := FALSE;
          END IF;
          
          -- Enviar registro para o Arquivo 
          gene0002.pc_escreve_xml(vr_clobarqu
                                 ,vr_txtoarqu
                                 ,'J'
                                ||to_char(rw_gnarqrx.nrsequen,'fm000000')
                                ||to_char(rw_gnarqrx.dtgerarq,'rrrr')
                                ||to_char(rw_gnarqrx.dtgerarq,'mm') 
                                ||to_char(rw_gnarqrx.dtgerarq,'dd')
                                ||to_char(rw_gnarqrx.qtregarq,'fm000000')
                                ||to_char((rw_gnarqrx.vltotarq  * 100),'fm00000000000000000')
                                ||to_char(rw_gnarqrx.dtmvtolt,'rrrr')
                                ||to_char(rw_gnarqrx.dtmvtolt,'mm') 
                                ||to_char(rw_gnarqrx.dtmvtolt,'dd')
                                ||RPAD(' ',104,' ')
                                ||CHR(10));              
          -- Atualizar o registro como retornado 
          BEGIN 
            UPDATE gnarqrx
               SET flgretor = 1 -- TRUE 
             WHERE rowid = rw_gnarqrx.nrrowid;
          EXCEPTION
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro na atualizacao da tabela gnarqrx --> '||sqlerrm;
              RAISE vr_excsaida;
          END;
          
          -- Incrementar o contador 
          vr_nrseqret := vr_nrseqret + 1;
        END LOOP;
      END IF;
      
      -- Ao final, se foi gerada alguma informa��o 
      IF NOT vr_flgfirst THEN 
        
        -- Acumular totais para envio ao arquivo 
        vr_tot_vltarifa := vr_nrseqdig * rw_gnconve.vltrfdeb;
        vr_tot_vlapagar := vr_tot_vlfatura - vr_tot_vltarifa;
        vr_nrseqtot := vr_nrseqdig + vr_nrseqndb + vr_nrseqret;
        vr_vltotarq := vr_tot_vlfatura + vr_vlfatndb;
        
        -- Enviar trailler para o arquivo 
        gene0002.pc_escreve_xml(vr_clobarqu
                               ,vr_txtoarqu
                               ,'Z'
                              ||to_char(vr_nrseqtot+2,'fm000000')
                              ||to_char((vr_vltotarq*100),'fm00000000000000000')
                              ||RPAD(' ',126,' ')
                              ||CHR(10)
                              ,true);        
        
        -- Chamar gera��o do arquivo 
        GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper          --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra          --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobarqu          --> Arquivo XML de dados
                                           ,pr_dsarqsaid => vr_camicop||'/'||vr_nmarqped --> Path/Nome do arquivo PDF gerado
                                           ,pr_flg_impri => 'N'                  --> Chamar a impress�o (Imprim.p)
                                           ,pr_flg_gerar => 'S'                  --> Gerar o arquivo na hora
                                           ,pr_nmformul  => '234dh'              --> Nome do formul�rio para impress�o
                                           ,pr_des_erro  => vr_dscritic);        --> Retorno de Erro
        -- Liberando a mem�ria alocada pro CLOB
        dbms_lob.close(vr_clobarqu);
        dbms_lob.freetemporary(vr_clobarqu);

        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_excsaida;
        END IF;
        
        -- Somente se houver informa��es no CLOB de relat�rio
        IF vr_flgrelat THEN
          
          -- Envio das informa��es para a ultima p�gina
          gene0002.pc_escreve_xml(vr_clobrela
                                 ,vr_txtorela
                                 , '</lcts>'
                                 ||'<totais>'
                                 || ' <nrseqdig>'||to_char(vr_nrseqdig,'fm999G999G999G999G990')||'</nrseqdig>'
                                 || ' <tot_vlfatura>'||to_char(vr_tot_vlfatura,'fm999G999G999G999G990d00')||'</tot_vlfatura>'
                                 || ' <tot_vltarifa>'||to_char(vr_tot_vltarifa,'fm999G999G999G999G990d00')||'</tot_vltarifa>'
                                 || ' <tot_vlapagar>'||to_char(vr_tot_vlapagar,'fm999G999G999G999G990d00')||'</tot_vlapagar>'
                                 || ' <nmciddat>'||vr_nmciddat||'</nmciddat>'
                                 || ' <nmcidade>'||vr_nmcidade||'</nmcidade>'
                                 || ' <nmextcop>'||rw_crapcop.nmextcop||'</nmextcop>'
                                 ||'</totais>');
          -- Encerrar a tag raiz
          gene0002.pc_escreve_xml(vr_clobrela
                                 ,vr_txtorela
                                 , '</crrl350>'
                                 ,true);        
          
          -- Solicitar o relat�rio 
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobrela         --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl350/lcts/lcto'          --> N� base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl350.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Sem parametros
                                     ,pr_dsarqsaid => vr_camicop||'/rl/crrl350_c' || to_char(rw_gnconve.cdconven,'fm0000')||'.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 80                  --> 132 colunas
                                     ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impress�o (Imprim.p)
                                     ,pr_nmformul  => '80d'            --> Nome do formul�rio para impress�o
                                     ,pr_nrcopias  => 1                   --> N�mero de c�pias
                                     ,pr_flg_gerar => 'N'                 --> gerar na hora 
                                     ,pr_des_erro  => vr_dscritic);       --> Sa�da com erro

          -- Liberando a mem�ria alocada pro CLOB
          dbms_lob.close(vr_clobrela);
          dbms_lob.freetemporary(vr_clobrela);

          -- TEstar saida do relatorio
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            raise vr_excsaida;
          END IF;
        END IF;  
      
        -- Chamar a atualiza��o do Controle e Devolu��o as Empresas 
        pc_atualiza_controle(rw_gnconve
                            ,vr_nrseqarq
                            ,vr_camicop
                            ,vr_nmarqped
                            ,vr_nmarqdat
                            ,vr_dtmvtopr
                            ,vr_nrseqdig
                            ,vr_cdconven
                            ,vr_tot_vlfatura
                            ,vr_tot_vltarifa
                            ,vr_tot_vlapagar
                            ,vr_cdcritic
                            ,vr_dscritic);
        -- Testar retorno de problema
        IF vr_cdcritic <> 0 AND vr_dscritic IS NOT NULL THEN 
          RAISE vr_excsaida;
        END IF;
      END IF;
      -- Commit a cada conv�nio 
      commit;      
    END LOOP; -- Loop conv�nios 
    
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informa��es atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_excfimpr THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;
    WHEN vr_excsaida THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos c�digo e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
End pc_crps388_i;


begin
  FOR reg IN (SELECT a.cdcooper
              FROM crapcop a 
              WHERE a.flgativo = 1 
                ORDER BY a.cdcooper) LOOP
              
    pc_crps388_i(pr_cdcooper => reg.cdcooper
                ,pr_flgresta => 0
                ,pr_stprogra => wpr_stprogra
                ,pr_infimsol => wpr_infimsol
                ,pr_cdcritic => wpr_cdcritic
                ,pr_dscritic => wpr_dscritic);
    IF wpr_cdcritic IS NOT NULL THEN
      dbms_output.put_line('Erro: '||SQLERRM||' e '||wpr_dscritic);
    END IF;
    
    dbms_output.put_line('Gerou coop '||reg.cdcooper);
      
  END LOOP;
  
end;
0
0
