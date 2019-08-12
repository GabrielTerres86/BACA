-- Autor: Rafael Cechet
-- Data: 06/08/2019
-- Objetivo: Baca para pagar TEDs de custas ao IEPTB entre os dias 01/08 a 06/08;

declare 
  -- Local variables here
  vr_cdproint           VARCHAR2 (100); -- Posiciona procedure interna - 09/11/2018 - SCTASK0034650
  vr_cdcritic           crapcri.cdcritic%TYPE;
  vr_dscritic           VARCHAR2 (4000);
  vr_nmarquiv           VARCHAR2(500)         := NULL;  
	texto CLOB; 
  vr_cdprogra VARCHAR2(32) := 'BACA_TEDS_IEPTB';  
  vr_idprglog NUMBER := 0;     
  vr_exc_erro EXCEPTION;  
  --
  CURSOR cr_conta(pr_nrdconta tbfin_recursos_conta.nrdconta%TYPE
                 ) IS
    SELECT cdcooper
          ,nrdconta
          ,cdagenci
          ,nmtitular
          ,dscnpj_titular
          ,tpconta
          ,nmrecurso
          ,dtabertura
      FROM tbfin_recursos_conta
     WHERE nrdconta = pr_nrdconta
       AND flgativo = 1;
  --
  rw_conta cr_conta%ROWTYPE;
  --
  -- Tipo de registro TED
  TYPE typ_reg_ted IS RECORD
    (vr_cdcooper crapcop.cdcooper%TYPE                             -- Cooperativa
    ,vr_cdagenci tbfin_recursos_movimento.cdagenci_debitada%TYPE   -- Agencia Remetente
    ,vr_nrdconta tbfin_recursos_movimento.dsconta_debitada%TYPE    -- Conta Remetente
    ,vr_tppessoa tbfin_recursos_movimento.inpessoa_debitada%TYPE   -- Tipo de pessoa Remetente
    ,vr_origem   INTEGER                                           -- Fixo 7 -- Processo autom·tico
    ,vr_nrispbif tbfin_recursos_movimento.nrispbif%TYPE            -- Banco destino
    ,vr_cdageban tbfin_recursos_movimento.cdagenci_creditada%TYPE  -- Agencia destino
    ,vr_nrctatrf tbfin_recursos_movimento.dsconta_creditada%TYPE   -- Conta destino                          
    ,vr_nmtitula tbfin_recursos_movimento.nmtitular_creditada%TYPE -- Nnome do titular destino
    ,vr_nrcpfcgc tbfin_recursos_movimento.nrcnpj_creditada%TYPE    -- CPF do titular destino
    ,vr_intipcta tbfin_recursos_movimento.tpconta_creditada%TYPE   -- Tipo de conta destino
    ,vr_inpessoa tbfin_recursos_movimento.inpessoa_debitada%TYPE   -- Tipo de pessoa destino
    ,vr_vllanmto tbfin_recursos_movimento.vllanmto%TYPE            -- Valor do lanÁamento
    ,vr_cdfinali INTEGER                                           -- Finalidade TED
    ,vr_operador VARCHAR2(2)                                       -- Fixo 1 -- Processo autom·tico
		,vr_cdhistor tbfin_recursos_movimento.cdhistor%TYPE            -- CÛdigo do histÛrico
		,vr_tpregist VARCHAR2(100)                                     -- Tipo registro
		,vr_tporigem VARCHAR2(100)                                     -- Tabela de origem
		);
	-- Tabela de tipo TED
	TYPE typ_tab_ted IS TABLE OF typ_reg_ted INDEX BY PLS_INTEGER;
	-- Tabela que contem as TEDs
	vr_tab_ted typ_tab_ted;
	-- Registro de TED
	vr_reg_ted typ_reg_ted;
  

  
  -- Remove caracteres especiais
  FUNCTION fun_remove_char_esp(pr_texto IN VARCHAR2
                              ) 
    RETURN VARCHAR2 
  IS
  /* ..........................................................................
    
  Procedure: fun_remove_char_esp
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Autor    : xxx
  Data     : 00/00/00                        Ultima atualizacao: 03/11/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : funÁ„o de remove char especial
    
  Alteracoes:     
  ............................................................................. */
  BEGIN
    --
    RETURN translate(pr_texto,'—¡…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’ƒÀœ÷‹«Ò·ÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ı‰ÎÔˆ¸Á.-!"''`#$%().:[/]{}®+?;∫™∞ß&¥*<>','NAEIOUAEIOUAEIOUAOAEIOUCnaeiouaeiouaeiouaoaeiouc');
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => 3
                                   ,pr_compleme => 'pr_texto:' || pr_texto
                                   );
      RETURN pr_texto;  
	END fun_remove_char_esp;  
    
  --
  PROCEDURE pc_enviar_ted_IEPTB (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa
                          ,pr_cdagenci IN TBFIN_RECURSOS_MOVIMENTO.cdagenci_debitada%TYPE  --> Agencia Remetente
                          ,pr_nrdconta IN TBFIN_RECURSOS_MOVIMENTO.dsconta_debitada%TYPE  --> Conta Remetente
                          ,pr_tppessoa IN TBFIN_RECURSOS_MOVIMENTO.inpessoa_debitada%TYPE  --> Tipo de pessoa Remetente
                          
                          ,pr_origem  IN INTEGER -- > 3. pr_idorigem ser· internet banking? R: Se o processo for autom·tico (JOB ou pc_crpsXXX), ent„o o pr_idorigem ser· "7". Sen„o, ser· "1" - AYLLOS.
                          
                          ,pr_nrispbif IN TBFIN_RECURSOS_MOVIMENTO.nrispbif%TYPE  --> Banco destino
                          ,pr_cdageban IN TBFIN_RECURSOS_MOVIMENTO.cdagenci_creditada%TYPE  --> Agencia destino
                          ,pr_nrctatrf IN TBFIN_RECURSOS_MOVIMENTO.dsconta_creditada%TYPE  --> Conta destino                          
                          ,pr_nmtitula IN TBFIN_RECURSOS_MOVIMENTO.nmtitular_creditada%TYPE  --> nome do titular destino

                          ,pr_nrcpfcgc IN TBFIN_RECURSOS_MOVIMENTO.nrcnpj_creditada%TYPE  --> CPF do titular destino
                          ,pr_intipcta IN TBFIN_RECURSOS_MOVIMENTO.tpconta_creditada%TYPE  --> Tipo de conta destino
                          ,pr_inpessoa IN TBFIN_RECURSOS_MOVIMENTO.inpessoa_debitada%TYPE --> Tipo de pessoa destino

                          ,pr_vllanmto IN TBFIN_RECURSOS_MOVIMENTO.vllanmto%TYPE  --> Valor do lanÁamento
                          ,pr_cdfinali IN INTEGER                --> Finalidade TED
                          
                          ,pr_operador IN VARCHAR2               --> CÛdigo do operador que est· realizando a operaÁ„o (1:Job;xxx:Outros)

                          ,pr_cdhistor IN TBFIN_RECURSOS_MOVIMENTO.cdhistor%TYPE --> CÛdigo do histÛrico da TBFIN_RECURSOS_MOVIMENTO.cdhistor

                          -- saida
                          ,pr_idlancto OUT TBFIN_RECURSOS_MOVIMENTO.IDLANCTO%TYPE --> ID do lanÁamento
                          ,pr_nrdocmto OUT INTEGER               --> Documento TED
                          ,pr_cdcritic OUT INTEGER               --> Codigo do erro
                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do erro

      -- Buscar informaÁıes das contas administradoras de recursos
      CURSOR cr_tbfin_rec_con(pr_cdcooper tbfin_recursos_conta.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_conta.nrdconta%TYPE
                             ,pr_cdagenci tbfin_recursos_conta.cdagenci%TYPE) IS
        SELECT rc.cdcooper
              ,rc.nrdconta
              ,rc.cdagenci
              ,rc.flgativo
              ,rc.tpconta
              ,rc.nmtitular
              ,rc.dscnpj_titular
          FROM tbfin_recursos_conta rc
         WHERE rc.cdcooper = pr_cdcooper
           AND rc.nrdconta = pr_nrdconta
           AND rc.cdagenci = pr_cdagenci
           AND rc.flgativo = 1;
      rw_tbfin_rec_con cr_tbfin_rec_con%ROWTYPE;
      
      -- Buscar informaÁıes do banco da conta administradora de recursos
      CURSOR cr_crapban(pr_nrispbif crapban.nrispbif%TYPE) IS
        SELECT rb.cdbccxlt
          FROM crapban rb
        WHERE rb.nrispbif = pr_nrispbif;
       rw_crapban cr_crapban%ROWTYPE;

      -- Buscar registro de saldo do dia atual das contas administradoras de recursos
      CURSOR cr_tbfin_rec_sal(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
                             ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE) IS
        SELECT rs.dtmvtolt
              ,rs.vlsaldo_inicial
              ,rs.vlsaldo_final
          FROM tbfin_recursos_saldo rs
         WHERE rs.cdcooper = pr_cdcooper
           AND rs.nrdconta = pr_nrdconta
           AND dtmvtolt = pr_dtmvtolt;
      rw_tbfin_rec_sal cr_tbfin_rec_sal%ROWTYPE;


      -- Buscar registro saldo do dia anterior das contas administradoras de recursos
      CURSOR cr_tbfin_rec_sal_ant(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
                             ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE) IS
        SELECT rs.vlsaldo_final
          FROM tbfin_recursos_saldo rs
         WHERE rs.cdcooper = pr_cdcooper
           AND rs.nrdconta = pr_nrdconta
           AND dtmvtolt = (pr_dtmvtolt - 1);
      rw_tbfin_rec_sal_ant cr_tbfin_rec_sal_ant%ROWTYPE;
      
      -- Buscar informaÁıes da cooperativa
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
             SELECT c.nmrescop, c.flgoppag, c.flgopstr, c.cdagectl
             FROM crapcop c
             WHERE c.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
                       ,pr_cdhistor craphis.cdhistor%TYPE
                       ) IS
        SELECT craphis.indebcre
          FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = pr_cdhistor; 
      --
      rw_craphis cr_craphis%ROWTYPE;
      ---
      
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_exc_erro EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(4000);
      
      -- Cursor genÈrico de calend·rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      
      vr_nrseqted crapmat.nrseqted%type;
      vr_aux_flgreccon BOOLEAN;
      vr_aux_flgrecsal BOOLEAN;
      vr_nrctrlif VARCHAR2(500);
      vr_aux_nrseqdig VARCHAR2(500);
      vr_aux_dtmvtolt VARCHAR2(500);
      vr_aux_sal_ant tbfin_recursos_saldo.vlsaldo_final%type;      
      vr_aux_cdhistor tbfin_recursos_movimento.cdhistor%type;
      
      vr_indebcre craphis.indebcre%TYPE;
      vr_cddbanco INTEGER;
      vr_des_erro VARCHAR2(1000);   
      
      -- variaveis copiadas da CXON0020 (Cechet)
      vr_trace_nmmensagem tbspb_msg_enviada.nmmensagem%TYPE;
      vr_nrseq_mensagem10 tbspb_msg_enviada_fase.nrseq_mensagem%type;
      vr_nrseq_mensagem20 tbspb_msg_enviada_fase.nrseq_mensagem%type;
      vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type := null;      

      -------------------- Programa Principal -----------------
      BEGIN        

        --> Buscar dados cooperativa
        OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
          
        --> verificar se encontra registro
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          vr_cdcritic := 651;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapcop;
        END IF;

        -- Validar data cooper
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        -- Se n„o encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
           CLOSE btch0001.cr_crapdat;

          vr_cdcritic := 0;
          vr_dscritic := 'Sistema sem data de movimento.';
          RAISE vr_exc_erro;
        ELSE
           CLOSE btch0001.cr_crapdat;
        END IF;
        
        IF rw_crapcop.flgoppag = 0 /*FALSE*/ AND  -- N„o operando com o pag. (camara de compensacao) 
           rw_crapcop.flgopstr = 0 /*FALSE*/ THEN -- N„o opera com o str. 
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa nao esta operando no SPB.';
          RAISE vr_exc_erro;
        END IF;
        
        OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                       ,pr_cdhistor => pr_cdhistor
                       );
        --
        FETCH cr_craphis INTO rw_craphis;
        --
        IF cr_craphis%NOTFOUND THEN
          --
          vr_cdcritic := 0;
          vr_dscritic := 'HistÛrico n„o encontrado!';
          --
          RAISE vr_exc_erro;
          --
        ELSE
          --
          vr_indebcre := rw_craphis.indebcre;
          --
        END IF;
        --
        CLOSE cr_craphis;
        
        /* Busca a proxima sequencia do campo CRAPMAT.NRSEQTED */
        vr_nrseqted := fn_sequence( 'CRAPMAT'
                                   ,'NRSEQTED'
                                   ,pr_cdcooper
                                   ,'N');
                                   
        -- Busca a proxima sequencia do campo TBFIN_RECURSOS_MOVIMENTO.idlancto
        pr_idlancto := fn_sequence(pr_nmtabela => 'TBFIN_RECURSOS_MOVIMENTO'
                                  ,pr_nmdcampo => 'IDLANCTO'
                                  ,pr_dsdchave => 'IDLANCTO'
                                  );
                                  
        -- retornar numero do documento
        pr_nrdocmto := vr_nrseqted;
        
        -- Se alterar numero de controle, ajustar procedure atualiza-doc-ted
        vr_nrctrlif := '9'||to_char(rw_crapdat.dtmvtocd,'RRMMDD')
                          ||to_char(rw_crapcop.cdagectl,'fm0000')
                          ||to_char(pr_nrdocmto,'fm00000000')
                          || 'P';

        /* Verifica se a TED È destinada a uma conta administradora de recursos */
        OPEN cr_tbfin_rec_con(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdagenci => pr_cdagenci);                            
                              
                              
        FETCH cr_tbfin_rec_con
        INTO rw_tbfin_rec_con;
        -- Se encontrar
        IF cr_tbfin_rec_con%FOUND THEN
          vr_aux_flgreccon := TRUE; 
        END IF;
        CLOSE cr_tbfin_rec_con;

        
        --
        OPEN cr_crapban(pr_nrispbif);
        FETCH cr_crapban
        INTO rw_crapban;

        IF cr_crapban%FOUND THEN
          vr_cddbanco := rw_crapban.cdbccxlt;
        ELSE
          vr_dscritic := 'Banco da conta de administraÁ„o de recursos n„o encontrado';
          -- Sair da rotina
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapban;
        
        -- copiado da CXON0020 com orientacao do Diego Vicentini      
        -- Fase 10 - controle mensagem SPB
        sspb0003.pc_grava_trace_spb(pr_cdfase                 => 10
                                   ,pr_idorigem               => 'E'
                                   ,pr_nmmensagem             => 'MSG_TEMPORARIA'
                                   ,pr_nrcontrole             => vr_nrctrlif
                                   ,pr_nrcontrole_str_pag     => NULL
                                   ,pr_nrcontrole_dev_or      => NULL
                                   ,pr_dhmensagem             => sysdate
                                   ,pr_insituacao             => 'OK'
                                   ,pr_dsxml_mensagem         => null
                                   ,pr_dsxml_completo         => null
                                   ,pr_nrseq_mensagem_xml     => null
                                   ,pr_nrdconta               => pr_nrdconta
                                   ,pr_cdcooper               => pr_cdcooper
                                   ,pr_cdproduto              => 30 -- TED
                                   ,pr_nrseq_mensagem         => vr_nrseq_mensagem10
                                   ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                   ,pr_dscritic               => vr_dscritic
                                   ,pr_des_erro               => vr_des_erro);
        -- Se ocorreu erro
        IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levantar Excecao
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;
        
        -- copiado da CXON0020 com orientacao do Diego Vicentini              
        -- Fase 20 - controle mensagem SPB
        sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                   ,pr_nmmensagem             => 'N„o utiliza OFSAA'
                                   ,pr_nrcontrole             => vr_nrctrlif
                                   ,pr_nrcontrole_str_pag     => NULL
                                   ,pr_nrcontrole_dev_or      => NULL
                                   ,pr_dhmensagem             => sysdate
                                   ,pr_insituacao             => 'OK'
                                   ,pr_dsxml_mensagem         => null
                                   ,pr_dsxml_completo         => null
                                   ,pr_nrseq_mensagem_xml     => null
                                   ,pr_nrdconta               => pr_nrdconta
                                   ,pr_cdcooper               => pr_cdcooper
                                   ,pr_cdproduto              => 30 -- TED
                                   ,pr_nrseq_mensagem         => vr_nrseq_mensagem20
                                   ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                   ,pr_dscritic               => vr_dscritic
                                   ,pr_des_erro               => vr_des_erro);
        -- Se ocorreu erro
        IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Levantar Excecao
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;        
        
        SSPB0001.pc_proc_envia_tec_ted
                          (pr_cdcooper => pr_cdcooper -- INTEGER
                          ,pr_cdagenci => pr_cdagenci -- INTEGER
                          ,pr_nrdcaixa => 1           -- INTEGER
                          ,pr_cdoperad => pr_operador -- VARCHAR2
                          ,pr_titulari => FALSE       -- BOOLEAN            -- Mesma titularidade
                          ,pr_vldocmto => pr_vllanmto -- NUMBER
                          ,pr_nrctrlif => vr_nrctrlif -- VARCHAR2
                          ,pr_nrdconta => pr_nrdconta -- INTEGER
                          ,pr_cdbccxlt => vr_cddbanco -- INTEGER
                          ,pr_cdagenbc => pr_cdageban -- INTEGER
                          ,pr_nrcctrcb => pr_nrctatrf -- NUMBER
                          ,pr_cdfinrcb => pr_cdfinali -- INTEGER
                          ,pr_tpdctadb => 1 -- CC     -- INTEGER
                          ,pr_tpdctacr => 1 -- CC     -- INTEGER
                          ,pr_nmpesemi => rw_tbfin_rec_con.nmtitular -- VARCHAR2
                          ,pr_nmpesde1 => NULL        -- VARCHAR2             -- Nome de 2TTL
                          ,pr_cpfcgemi => rw_tbfin_rec_con.dscnpj_titular -- NUMBER
                          ,pr_cpfcgdel => 0           -- NUMBER             -- CPF sec TTL
                          ,pr_nmpesrcb => pr_nmtitula -- VARCHAR2
                          ,pr_nmstlrcb => NULL        -- VARCHAR2             -- Nome para 2TTL
                          ,pr_cpfcgrcb => pr_nrcpfcgc -- NUMBER
                          ,pr_cpstlrcb => 0           -- NUMBER             -- CPF para 2TTL
													,pr_tppesemi => pr_tppessoa -- INTEGER             
                          ,pr_tppesrec => pr_inpessoa -- INTEGER 
													,pr_flgctsal => FALSE       -- BOOLEAN             -- CC Sal
                          ,pr_cdidtran => ''          -- VARCHAR2
													,pr_cdorigem => pr_origem   -- INTEGER
                          ,pr_dtagendt => NULL        -- DATE             -- Data agendamento
                          ,pr_nrseqarq => 0           -- INTEGER             -- Nr. seq arq.
                          ,pr_cdconven => 0           -- INTEGER             -- Cod convenio
                          ,pr_dshistor => pr_cdhistor -- VARCHAR2
                          ,pr_hrtransa => to_number(to_char(sysdate,'sssss')) -- INTEGER -- Hora transacao
                          ,pr_cdispbif => pr_nrispbif -- INTEGER
													
                          -- SAIDA
                          ,pr_cdcritic =>  vr_cdcritic     --> Codigo do erro
                          ,pr_dscritic =>  vr_dscritic);   --> Descricao do erro

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN     
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND 
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;  
        
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'N„o foi possivel enviar a TED: ' || nvl(vr_dscritic, SQLERRM);

  END pc_enviar_ted_IEPTB;  
  
  -- Processa as TED geradas em memÛria e realiza o envio das mesmas
  PROCEDURE pc_envia_teds(pr_cdcritic OUT NUMBER
                         ,pr_dscritic OUT VARCHAR2
                         ) IS
  /* ..........................................................................
    
  Procedure: pc_envia_teds
  Sistema  : Conta-Corrente - Cooperativa de Credito
  Autor    : xxx
  Data     : 00/00/0000                        Ultima atualizacao: 09/11/2018
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : envia teds
    
  Alteracoes: 
   09/11/2018 - Padronizar as mensagens
              (Envolti - Belli - SCTASK0034650)    
  ............................................................................. */
    --
    vr_index_ted NUMBER  := 0;
    --
    vr_idlancto  tbfin_recursos_movimento.idlancto%TYPE;
    vr_nrdocmto  NUMBER;
    -- Trata os erros especÌficos dentro da procedure - 09/11/2018 - SCTASK0034650
    vr_cdcritic        crapcri.cdcritic%TYPE := NULL;
    vr_dscritic        VARCHAR2(4000)        := NULL;
    vr_exc_erro        EXCEPTION;
		--
	BEGIN
    -- Posiciona procedure - 09/11/2018 - SCTASK0034650
    vr_cdproint := vr_cdprogra || '.pc_envia_teds';
    -- Inclus„o do mÛdulo e aÁ„o logado
    GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
    -- Inicializa retorno
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
		--
		IF vr_tab_ted.count() > 0 THEN
			--
			WHILE vr_index_ted IS NOT NULL LOOP
				--
				pc_enviar_ted_IEPTB(pr_cdcooper => vr_tab_ted(vr_index_ted).vr_cdcooper
				                            ,pr_cdagenci => vr_tab_ted(vr_index_ted).vr_cdagenci
																		,pr_nrdconta => vr_tab_ted(vr_index_ted).vr_nrdconta
																		,pr_tppessoa => vr_tab_ted(vr_index_ted).vr_tppessoa
																		,pr_origem   => vr_tab_ted(vr_index_ted).vr_origem
																		,pr_nrispbif => vr_tab_ted(vr_index_ted).vr_nrispbif
																		,pr_cdageban => vr_tab_ted(vr_index_ted).vr_cdageban
																		,pr_nrctatrf => vr_tab_ted(vr_index_ted).vr_nrctatrf
																		,pr_nmtitula => vr_tab_ted(vr_index_ted).vr_nmtitula
																		,pr_nrcpfcgc => vr_tab_ted(vr_index_ted).vr_nrcpfcgc
																		,pr_intipcta => vr_tab_ted(vr_index_ted).vr_intipcta
																		,pr_inpessoa => vr_tab_ted(vr_index_ted).vr_inpessoa
																		,pr_vllanmto => vr_tab_ted(vr_index_ted).vr_vllanmto
																		,pr_cdfinali => vr_tab_ted(vr_index_ted).vr_cdfinali
																		,pr_operador => vr_tab_ted(vr_index_ted).vr_operador
																		,pr_cdhistor => vr_tab_ted(vr_index_ted).vr_cdhistor
																		,pr_idlancto => vr_idlancto
																		,pr_nrdocmto => vr_nrdocmto
																		,pr_cdcritic => vr_cdcritic
																		,pr_dscritic => vr_dscritic
																		);
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
        END IF;
        
        -- Retorna mÛdulo e aÁ„o logado
        GENE0001.pc_set_modulo(pr_module => vr_cdproint, pr_action => NULL);
				-- PrÛximo registro
				vr_index_ted := vr_tab_ted.next(vr_index_ted);
				--
			END LOOP;
			--
		END IF;
		--
		-- Incluido tratamento de erro -e sai esta forma de programaÁ„o - pr_dscritic := vr_dscritic;
		--
	EXCEPTION
    -- Tratamento de erro - 09/11/2018 - SCTASK0034650
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
		WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => 3);    
      -- Monta mensagem
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     vr_cdproint ||
                     '. ' || SQLERRM; 
	END pc_envia_teds;    
  
begin
  -- Test statements here

  FOR rw IN (SELECT t.dtmvtolt, t.nrdconta, t.cdhistor, t.dsdebcre, vllanmto FROM tbfin_recursos_movimento t
              WHERE t.dtmvtolt BETWEEN  to_date('07/08/2019','DD/MM/RRRR') 
                                   AND  to_date('09/08/2019','DD/MM/RRRR') 
                AND t.cdhistor IN ( 2646, 2642)
                AND t.dsdebcre = 'D'
              ORDER BY t.dtmvtolt, t.nrdconta, t.nrdocmto) LOOP
  
        -- Envia a TED para o CRA SP com o total das custas cobradas
        --IF nvl(vr_tot_sp_cra_custas, 0) > 0 THEN
        IF rw.nrdconta = 20000006 AND 
           rw.cdhistor = 2642 THEN
          --
          OPEN cr_conta(20000006
                       );
          --
          FETCH cr_conta INTO rw_conta;
          --
          IF cr_conta%NOTFOUND THEN
            vr_cdcritic := 1401; -- Conta nao cadastrada para o CRA SP
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' (1)';
            RAISE vr_exc_erro;
            --
          ELSE
            --
            vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
            vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
            vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
            vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
            vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
            vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
            vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
            vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
            vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
            vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
            vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
            vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
            vr_reg_ted.vr_vllanmto := rw.vllanmto;
            vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
            vr_reg_ted.vr_operador := 1;                                                       -- Fixo
            vr_reg_ted.vr_cdhistor := 2642;                                                    -- Fixo
            vr_reg_ted.vr_tpregist := 'vr_tot_sp_cra_custas';                                  -- Fixo
            vr_reg_ted.vr_tporigem := 'RET';                                             
            --
            vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
            --
          END IF;
          --
          CLOSE cr_conta;
          --
        END IF;
        --
        rw_conta := NULL;
        -- Envia a TED para o Outros CRAs com o total das custas cobradas
        --IF nvl(vr_tot_outros_cra_custas, 0) > 0 THEN
        IF rw.nrdconta = 10000003 AND 
           rw.cdhistor = 2642 THEN        
          --
          OPEN cr_conta(10000003
                       );
          --
          FETCH cr_conta INTO rw_conta;
          --
          IF cr_conta%NOTFOUND THEN
            vr_cdcritic := 1402; -- Conta nao cadastrada para o CRA Nacional
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' (1)';
            RAISE vr_exc_erro;
            --
          ELSE
            --
            vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
            vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
            vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
            vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
            vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
            vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
            vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
            vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
            vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
            vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
            vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
            vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
            vr_reg_ted.vr_vllanmto := rw.vllanmto;
            vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
            vr_reg_ted.vr_operador := 1;                                                       -- Fixo
            vr_reg_ted.vr_cdhistor := 2642;                                                    -- Fixo
            vr_reg_ted.vr_tpregist := 'vr_tot_outros_cra_custas';                              -- Fixo
            vr_reg_ted.vr_tporigem := 'RET'; 
            --
            vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
            --
          END IF;
          --
          CLOSE cr_conta;
          --
        END IF;
        --
        rw_conta := NULL;
        -- Envia a TED para o CRA SP com o total das tarifas cobradas
        --IF nvl(vr_tot_sp_cra_tarifa, 0) > 0 THEN
        IF rw.nrdconta = 20000006 AND 
           rw.cdhistor = 2646 THEN        
          --
          OPEN cr_conta(20000006
                       );
          --
          FETCH cr_conta INTO rw_conta;
          --
          IF cr_conta%NOTFOUND THEN
            vr_cdcritic := 1401; -- Conta nao cadastrada para o CRA SP
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' (2)';
            RAISE vr_exc_erro;
            --
          ELSE
            --
            vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
            vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
            vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
            vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
            vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
            vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
            vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
            vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
            vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
            vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
            vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
            vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
            vr_reg_ted.vr_vllanmto := rw.vllanmto;
            vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
            vr_reg_ted.vr_operador := 1;                                                       -- Fixo
            vr_reg_ted.vr_cdhistor := 2646;                                                    -- Fixo
            vr_reg_ted.vr_tpregist := 'vr_tot_sp_cra_tarifa';                                  -- Fixo
            vr_reg_ted.vr_tporigem := 'RET';
            --
            vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
            --
          END IF;
          --
          CLOSE cr_conta;
          --
        END IF;
        --
        rw_conta := NULL;
        -- Envia a TED para o Outros CRAs com o total das tarifas cobradas
        --IF nvl(vr_tot_outros_cra_tarifa, 0) > 0 THEN
        IF rw.nrdconta = 10000003 AND 
           rw.cdhistor = 2646 THEN                
          --
          OPEN cr_conta(10000003
                       );
          --
          FETCH cr_conta INTO rw_conta;
          --
          IF cr_conta%NOTFOUND THEN
            vr_cdcritic := 1402; -- Conta nao cadastrada para o CRA Nacional
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' (2)';
            RAISE vr_exc_erro;
            --
          ELSE
            --
            vr_reg_ted.vr_cdcooper := 3;                                                       -- Cooperativa
            vr_reg_ted.vr_cdagenci := rw_conta.cdagenci;                                       -- Agencia Remetente
            vr_reg_ted.vr_nrdconta := rw_conta.nrdconta;                                       -- Conta Remetente
            vr_reg_ted.vr_tppessoa := 2;                                                       -- Tipo de Pessoa Remetente
            vr_reg_ted.vr_origem   := 7;                                                       -- Origem do Processo
            vr_reg_ted.vr_nrispbif := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 1); -- Banco Destino
            vr_reg_ted.vr_cdageban := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 2); -- Agencia Destino
            vr_reg_ted.vr_nrctatrf := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 3); -- Conta Destino
            vr_reg_ted.vr_nmtitula := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 4); -- Nome do Titular Destino 
            vr_reg_ted.vr_nrcpfcgc := fun_remove_char_esp(pr_texto => cobr0011.fn_busca_dados_conta_destino(pr_idoption => 5)); -- CPF do Titular Destino
            vr_reg_ted.vr_intipcta := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 6); -- Tipo de Conta Destino
            vr_reg_ted.vr_inpessoa := cobr0011.fn_busca_dados_conta_destino(pr_idoption => 7); -- Tipo de Pessoa Destino
            vr_reg_ted.vr_vllanmto := rw.vllanmto;
            vr_reg_ted.vr_cdfinali := 10;                                                      -- Finalidade TED
            vr_reg_ted.vr_operador := 1;                                                       -- Fixo
            vr_reg_ted.vr_cdhistor := 2646;                                                    -- Fixo
            vr_reg_ted.vr_tpregist := 'vr_tot_outros_cra_tarifa';                              -- Fixo
            vr_reg_ted.vr_tporigem := 'RET';                                             
            --
						vr_tab_ted(vr_tab_ted.count()) := vr_reg_ted;
						--
					END IF;
					--
					CLOSE cr_conta;
					--
				END IF;
        
  END LOOP;

  BEGIN  
    pc_envia_teds(pr_cdcritic => vr_cdcritic
                 ,pr_dscritic => vr_dscritic);
                 
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Trata erro 
      RAISE vr_exc_erro;  
    END IF;
    
    pc_log_programa(pr_dstiplog      => 'E'
                   ,pr_cdprograma    => vr_cdprogra 
                   ,pr_cdcooper      => 3
                   ,pr_tpexecucao    => 2 -- job
                   ,pr_tpocorrencia  => 4
                   ,pr_cdcriticidade => 0 -- baixa
                   ,pr_dsmensagem    => 'Baca executado com sucesso.'
                   ,pr_idprglog      => vr_idprglog
                   ,pr_nmarqlog      => NULL
                   );    

    commit;  
  
  EXCEPTION
    WHEN OTHERS THEN
      pc_log_programa(pr_dstiplog      => 'E'
                     ,pr_cdprograma    => vr_cdprogra 
                     ,pr_cdcooper      => 3
                     ,pr_tpexecucao    => 2 -- job
                     ,pr_tpocorrencia  => 4
                     ,pr_cdcriticidade => 0 -- baixa
                     ,pr_dsmensagem    => SQLERRM
                     ,pr_idprglog      => vr_idprglog
                     ,pr_nmarqlog      => NULL
                     );
                     
    ROLLBACK;
  END;
  
end;
