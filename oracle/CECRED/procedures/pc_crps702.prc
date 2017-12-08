CREATE OR REPLACE PROCEDURE CECRED.pc_crps702 (pr_cdcooper IN crapcop.cdcooper%TYPE) IS   --> Cooperativa solicitada
                                              
                                              
  /* .............................................................................

     Programa: pc_crps702 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana(AMcom)
     Data    : Maio/2016                     Ultima atualizacao: 08/12/2017

     Dados referentes ao programa:

     Frequencia: Job Oracle - 15 em 15 Minutos - JBCOBRAN_CRPS702
     Objetivo  : Atualização do status do convênio de cobrança dos cooperados.

     Alteracoes: 08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                              (SD#791193 - AJFink)
  ............................................................................ */


  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS702';
  vr_nomdojob CONSTANT VARCHAR2(100) := 'JBCOBRAN_CRPS702';

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_prox   EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------------- CURSORES ---------------------------------
  
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = decode(pr_cdcooper,3,cop.cdcooper,pr_cdcooper)
       AND cop.flgativo = 1;     
  
  -- Busca convenios pendentes
  CURSOR cr_crapceb (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT ass.inpessoa,
           ass.nrcpfcgc,
           ceb.cdcooper,
           ceb.nrdconta
      FROM crapceb ceb
          ,crapcco cco
          ,crapass ass
     WHERE cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = 85
       AND ceb.cdcooper = cco.cdcooper
       AND ceb.nrconven = cco.nrconven
       AND ceb.insitceb = 3 -- pendente
       AND ass.cdcooper = ceb.cdcooper
       AND ass.nrdconta = ceb.nrdconta;
  
  -- Busca convenios pendentes
  CURSOR cr_crapceb_pend (pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT *
      FROM crapceb
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND insitceb = 3; -- pendente
  
  --> Buscar beneficiarios que ficaram inaptos      
  CURSOR cr_sitbnf_inapto IS
    SELECT "CNPJ_CPFBenfcrio" nrcpfcgc
      FROM cecredleg.VWJDDDABNF_Sit_Beneficiario@jdnpcsql
     WHERE "DtHrSitBenfcrio" >= to_number(to_char(SYSDATE, 'RRRRMMDD') || '000000')
       AND "SITIF" = 'I';
       
  -- Busca convenios nao bloqueados
  CURSOR cr_crapceb_nbloq (pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
    SELECT ceb.nrconven,
           ceb.nrcnvceb,
           ceb.nrdconta,
           ceb.insitceb,
           ceb.cdcooper,
           dat.dtmvtolt dat_dtmvtolt,
           dat.dtmvtoan dat_dtmvtoan,
           dat.inproces dat_inproces
      FROM crapceb ceb
          ,crapass ass
          ,crapcop cop
          ,crapcco cco
          ,crapdat dat
     WHERE cop.cdcooper > 0
       AND cop.flgativo = 1
       AND ass.cdcooper = cop.cdcooper
       AND ass.nrcpfcgc = pr_nrcpfcgc
       AND ass.dtdemiss IS NULL       
       AND ceb.cdcooper = ass.cdcooper
       AND ceb.nrdconta = ass.nrdconta
       AND ceb.insitceb <> 4       
       AND cco.cdcooper = ceb.cdcooper
       AND cco.nrconven = ceb.nrconven
       AND cco.flgregis = 1 --> Somente convenio de boletos com registro 
       AND dat.cdcooper = cop.cdcooper
       AND dat.inproces = 1; --> Apenas buscará os convenios se a coop, 
                             --> ja conclui o processo. para nao gerar baixa durante o processo
 
  --> Buscar boletos em aberto
  CURSOR cr_crapcob(pr_cdcooper  crapcob.cdcooper%TYPE,
                    pr_nrdconta  crapcob.nrdconta%TYPE,
                    pr_nrconven  crapcob.nrcnvcob%TYPE) IS
    SELECT cob.cdcooper
          ,cob.nrdconta
          ,cob.nrcnvcob
          ,cob.incobran
          ,cob.nrdocmto
          ,cob.cdbandoc
          ,cob.nrdctabb
          ,cob.vltitulo
          ,cob.flgregis
          ,cob.inserasa
          ,cob.insitcrt
          ,cob.rowid
      FROM crapcob cob
          ,crapcco cco
     WHERE cob.cdcooper = pr_cdcooper
       AND cob.nrdconta = pr_nrdconta
       AND cob.nrcnvcob = pr_nrconven       
       AND cob.incobran = 0
       AND cco.cdcooper = cob.cdcooper
       AND cco.nrconven = cob.nrcnvcob
       AND cob.nrdctabb = cco.nrdctabb
       AND cob.cdbandoc = cco.cddbanco;
  
  --> Buscar titulos de bordero em aberto
  CURSOR cr_craptdb(pr_cdcooper  craptdb.cdcooper%TYPE,
                    pr_nrdconta  craptdb.nrdconta%TYPE,
                    pr_nrconven  craptdb.nrcnvcob%TYPE,
                    pr_nrdocmto  craptdb.nrdocmto%TYPE) IS
    SELECT bdt.cdagenci,
           bdt.cdbccxlt,           
           bdt.nrdolote,
           bdt.dtmvtolt
      FROM craptdb tdb,
           crapbdt bdt
     WHERE bdt.cdcooper = tdb.cdcooper
       AND bdt.nrborder = tdb.nrborder
       AND tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = pr_nrdconta
       AND tdb.nrcnvcob = pr_nrconven
       AND tdb.nrdocmto = pr_nrdocmto
       AND tdb.insittit = 4; --> boleto em aberto e liberado
  rw_craptdb cr_craptdb%ROWTYPE;
       
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  vr_tab_titulos         PAGA0001.typ_tab_titulos;
  
  ------------------------------- VARIAVEIS -------------------------------
  vr_cdoperad     crapope.cdoperad%TYPE := '1';                
  vr_insitif      VARCHAR2(10);
  vr_insitcip     VARCHAR2(10);
  vr_dsdmensg     VARCHAR2(500);
  vr_dsdemail_dst VARCHAR2(100);
  vr_dslogmes     VARCHAR2(100);
  vr_insitceb_new crapceb.insitceb%TYPE;
  vr_idxcob       VARCHAR2(20);
  vr_flgerlog     BOOLEAN;
  
  --------------------------- SUBROTINAS INTERNAS --------------------------
  --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    
    --> Controlar geração de log de execução dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
      
  END pc_controla_log_batch;
  
  
  
BEGIN

  --------------- VALIDACOES INICIAIS -----------------

  vr_flgerlog := FALSE;
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  vr_dslogmes := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
  
  IF to_char(SYSDATE,'D') IN (1,7) THEN
    RETURN;
  END IF;
  
  -->>>>>>>>>>>>>>>> 1º ETAPA - VERIFICAR CONVENIOS PENDENTES <<<<<<<<<<<<--
 --> Aprovacao somente acontecerá de forma manual pela tela COBRAN -> opcao S 
/*  FOR rw_crapcop IN cr_crapcop LOOP
    
    --> Buscar convenios pendentes
    FOR rw_crapceb IN cr_crapceb(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      pc_controla_log_batch(pr_dstiplog => 'I');  
      
      --> Buscar situacao do benificiario na cip
      vr_insitif  := NULL;
      vr_insitcip := NULL;
      DDDA0001.pc_ret_sit_beneficiario( pr_inpessoa  => rw_crapceb.inpessoa,  --> Tipo de pessoa
                                        pr_nrcpfcgc  => rw_crapceb.nrcpfcgc,  --> CPF/CNPJ do beneficiario
                                        pr_insitif   => vr_insitif,           --> Retornar situação IF
                                        pr_insitcip  => vr_insitcip,          --> Retorna situação na CIP
                                        pr_dscritic  => vr_dscritic);         --> Retorna critica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Se situacao estiver como A-Apto ou I-Inapto
      IF vr_insitif IN ('A','I') THEN
        CASE vr_insitif 
          WHEN 'A' THEN vr_insitceb_new := 5;
          WHEN 'I' THEN vr_insitceb_new := 6;
          ELSE vr_insitceb_new := 0;
        END CASE;
        
        IF vr_insitceb_new = 0 THEN
          vr_dscritic := 'Erro ao definir nova situacao do convenio';
          RAISE vr_exc_saida;
        END IF;
         
        --> Buscar todos os convenios pendentes do cooperado
        FOR rw_crapceb_pend IN cr_crapceb_pend (pr_cdcooper => rw_crapceb.cdcooper,
                                                pr_nrdconta => rw_crapceb.nrdconta) LOOP
        
          BEGIN
            
            SAVEPOINT vr_trans_crps702;
            ------->> ATUALIZAR CONVENIO <<--------
            COBR0008.pc_alter_insitceb(pr_idorigem => 7, --BATCH                --> Sistema origem
                                       pr_cdcooper => rw_crapceb_pend.cdcooper, --> Codigo da cooperativa
                                       pr_cdoperad => vr_cdoperad,                        --> Codigo do operador
                                       pr_nrdconta => rw_crapceb_pend.nrdconta, --> Numero da conta do cooperado
                                       pr_nrconven => rw_crapceb_pend.nrconven, --> Numero do convenio
                                       pr_nrcnvceb => rw_crapceb_pend.nrcnvceb, --> Numero do bloqueto
                                       pr_insitceb => vr_insitceb_new,          --> Nova situação(5 Aprovado, 6 Nao Aprovado)
                                       pr_dscritic => vr_dscritic);             --> Retorna critica
                                                 
            IF vr_dscritic IS NOT NULL THEN              
              RAISE vr_exc_prox;
            END IF;
            
            -- Se o convenio foi aprovado
            IF vr_insitceb_new = 5 THEN
            
              ------->> GRAVAR MENSAGEM IBANK <<--------
              vr_dsdmensg := 'Seus convênios de cobrança foram Aprovados.' || '\n' ||
                             'Favor dirigir-se ao seu PA de relacionamento.';

              -- Insere na tabela de mensagens (CRAPMSG)
              GENE0003.pc_gerar_mensagem
                         (pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_nrdconta => rw_crapceb_pend.nrdconta
                         ,pr_idseqttl => 0           \* Titular *\
                         ,pr_cdprogra => vr_cdprogra \* Programa *\
                         ,pr_inpriori => 0
                         ,pr_dsdmensg => vr_dsdmensg \* corpo da mensagem *\
                         ,pr_dsdassun => 'Convênio de Cobrança Aprovado' \* Assunto *\
                         ,pr_dsdremet => rw_crapcop.nmrescop 
                         ,pr_dsdplchv => 'Cobranca'
                         ,pr_cdoperad => vr_cdoperad
                         ,pr_cdcadmsg => 0
                         ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_prox;
              END IF;
              
              ------->> NOTIFICAR SAC <<--------
              vr_dsdmensg := 'Convênio de cobrança do cooperado: ' || rw_crapceb_pend.nrdconta || 
                             ' foi <b>Aprovado</b> - Cooperativa: ' || rw_crapcop.nmrescop ||
                             '<br>Favor entrar em contato com o mesmo para dirigir-se ao'||
                             ' seu PA de relacionamento  e assinar o Termo de Adesão';
                      
              -->  Buscar destinatario de email
              vr_dsdemail_dst := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                            pr_cdcooper => rw_crapcop.cdcooper, 
                                                            pr_cdacesso => 'EMAIL_CONV_APROVADO');  
              
              \* Envio do arquivo detalhado via e-mail *\
              gene0003.pc_solicita_email(
                        pr_cdcooper        => rw_crapcop.cdcooper
                       ,pr_cdprogra        => vr_cdprogra
                       ,pr_des_destino     => vr_dsdemail_dst
                       ,pr_des_assunto     => 'Aprovacao de Convenio de Cobranca - ' || rw_crapcop.nmrescop
                       ,pr_des_corpo       => vr_dsdmensg
                       ,pr_des_anexo       => NULL
                       ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                       ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                       ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                       ,pr_des_erro        => vr_dscritic);                  
            
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_prox;
              END IF;
            END IF; --> FIM IF vr_insitceb_new = 5
            
          EXCEPTION
            WHEN vr_exc_prox THEN
              ROLLBACK TO vr_trans_crps702;
              vr_dscritic := 'Erro ao atualizar convenio '||rw_crapceb_pend.nrconven||
                               ' Cooper: '||rw_crapceb_pend.cdcooper||' Conta: '||rw_crapceb_pend.nrdconta ||
                               ' :'||vr_dscritic;
                               
              \* Se aconteceu erro deve gera o log *\
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                         pr_nmarqlog     => vr_dslogmes);
              vr_dscritic := NULL;
              
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar convenio '||rw_crapceb_pend.nrconven||
                               ' Cooper: '||rw_crapceb_pend.cdcooper||' Conta: '||rw_crapceb_pend.nrdconta ||
                               ' :'||SQLERRM;
              RAISE vr_exc_saida;
          END;          
        END LOOP; -- Fim lop ceb_pendente
      END IF;
    
    END LOOP; --> Fim loop ceb
  END LOOP; --> Fim loop crapcop
*/  
  -->>>>>>>>>>>>>> 2º ETAPA - BLOQUEAR CONVENIOS INAPTOS <<<<<<<<<<<<--
  
  --> Buscar beneficiarios que ficaram inaptos      
  FOR rw_sitbnf_inapto IN cr_sitbnf_inapto LOOP
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'I');
  
    -- Busca convenios nao bloqueados
    FOR rw_crapceb_nbloq IN cr_crapceb_nbloq(pr_nrcpfcgc => rw_sitbnf_inapto.nrcpfcgc ) LOOP
          
      BEGIN
--        SAVEPOINT vr_trans_crps702;
        ------->> ATUALIZAR CONVENIO <<--------
        COBR0008.pc_alter_insitceb(pr_idorigem => 7, --BATCH                 --> Sistema origem
                                   pr_cdcooper => rw_crapceb_nbloq.cdcooper, --> Codigo da cooperativa
                                   pr_cdoperad => vr_cdoperad,               --> Codigo do operador
                                   pr_nrdconta => rw_crapceb_nbloq.nrdconta, --> Numero da conta do cooperado
                                   pr_nrconven => rw_crapceb_nbloq.nrconven, --> Numero do convenio
                                   pr_nrcnvceb => rw_crapceb_nbloq.nrcnvceb, --> Numero do bloqueto
                                   pr_insitceb => 4, --BLOQUEADO             --> Nova situação(5 Aprovado, 6 Nao Aprovado)
                                   pr_dscritic => vr_dscritic);              --> Retorna critica
                                                 
        IF vr_dscritic IS NOT NULL THEN              
          RAISE vr_exc_prox;
        END IF; 
        
        vr_tab_lat_consolidada.delete;
        
        --> Buscar boletos em aberto
        FOR rw_crapcob IN cr_crapcob (pr_cdcooper => rw_crapceb_nbloq.cdcooper,
                                      pr_nrdconta => rw_crapceb_nbloq.nrdconta,
                                      pr_nrconven => rw_crapceb_nbloq.nrconven) LOOP
                                      
                                        
          --> Buscar titulos de bordero em aberto
          OPEN cr_craptdb(pr_cdcooper  => rw_crapcob.cdcooper,
                          pr_nrdconta  => rw_crapcob.nrdconta,
                          pr_nrconven  => rw_crapcob.nrcnvcob,
                          pr_nrdocmto  => rw_crapcob.nrdocmto);
          FETCH cr_craptdb INTO rw_craptdb;                
          
          -- Se encontrar desconto de titulo, deve resgata-lo
          IF cr_craptdb%FOUND THEN
            CLOSE cr_craptdb;
            
            -- Sempre envia somente 1
            vr_tab_titulos.delete;
            --Montar indice para tabela memoria titulos
            vr_idxcob:= vr_tab_titulos.Count + 1;
            vr_tab_titulos(vr_idxcob).cdbandoc:= rw_crapcob.cdbandoc;
            vr_tab_titulos(vr_idxcob).nrdctabb:= rw_crapcob.nrdctabb;
            vr_tab_titulos(vr_idxcob).nrcnvcob:= rw_crapcob.nrcnvcob;
            vr_tab_titulos(vr_idxcob).nrdconta:= rw_crapcob.nrdconta;
            vr_tab_titulos(vr_idxcob).nrdocmto:= rw_crapcob.nrdocmto;
            vr_tab_titulos(vr_idxcob).vltitulo:= rw_crapcob.vltitulo;
            vr_tab_titulos(vr_idxcob).flgregis:= rw_crapcob.flgregis = 1;
            
            --> Efetuar resgate de titulos de um determinado bordero 
            DSCT0001.pc_efetua_resgate_tit_bord ( pr_cdcooper    => rw_crapceb_nbloq.cdcooper  --> Codigo Cooperativa
                                                 ,pr_cdagenci    => rw_craptdb.cdagenci        --> Codigo Agencia do bordero de desconto
                                                 ,pr_nrdcaixa    => 0                          --> Numero Caixa
                                                 ,pr_cdoperad    => vr_cdoperad                --> Codigo operador
                                                 ,pr_dtmvtolt    => rw_craptdb.dtmvtolt        --> Data Movimento do bordero de desconto
                                                 ,pr_dtmvtoan    => rw_crapceb_nbloq.dat_dtmvtoan        --> Data anterior do movimento
                                                 ,pr_inproces    => rw_crapceb_nbloq.dat_inproces        --> Indicador processo
                                                 ,pr_dtresgat    => rw_crapceb_nbloq.dat_dtmvtolt        --> Data do resgate
                                                 ,pr_idorigem    => 7 --BATCH                  --> Identificador Origem pagamento
                                                 ,pr_nrdconta    => rw_crapceb_nbloq.cdcooper  --> Numero da conta
                                                 ,pr_cdbccxlt    => rw_craptdb.cdbccxlt        --> codigo do banco
                                                 ,pr_nrdolote    => rw_craptdb.nrdolote        --> Numero do lote do bordero de desconto                                       
                                                 ,pr_tab_titulos => vr_tab_titulos             --> Titulos a serem resgatados
                                                 ---- OUT ----
                                                 ,pr_cdcritic    => vr_cdcritic                --> Codigo Critica
                                                 ,pr_dscritic    => vr_dscritic                --> Descricao Critica
                                                 );
            
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_prox; 
            END IF;   
          ELSE
            CLOSE cr_craptdb;
          END IF;
          
          -- Se possuir protesto cujo a situação seja : 1 - C/Inst Protesto
          --                                            2 - Rem Cartorio
          --                                            3 - Em Cartorio          
          IF rw_crapcob.insitcrt IN (1,2,3) THEN
            --> Sustar e Baixar  boleto 
--            paga0001.pc_inst_sustar_baixar
            COBR0007.pc_inst_sustar_baixar 
                              (pr_cdcooper => rw_crapcob.cdcooper    -- Codigo Cooperativa
                              ,pr_nrdconta => rw_crapcob.nrdconta    -- Numero da Conta
                              ,pr_nrcnvcob => rw_crapcob.nrcnvcob    -- Numero Convenio
                              ,pr_nrdocmto => rw_crapcob.nrdocmto    -- Numero Documento
                              ,pr_dtmvtolt => rw_crapceb_nbloq.dat_dtmvtolt -- Data pagamento
                              ,pr_cdoperad => vr_cdoperad            -- Operador
                              ,pr_nrremass => 0                      -- Numero Remessa
                              ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                              ,pr_cdcritic  => vr_cdcritic           -- Codigo da Critica
                              ,pr_dscritic  => vr_dscritic );        -- Descricao da critica
            
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_prox; 
            END IF;
            
          ELSE           
            --> Baixar  boleto 
--            paga0001.pc_inst_pedido_baixa
            COBR0007.pc_inst_pedido_baixa 
                              (pr_idregcob  => rw_crapcob.rowid         -- Rowid da Cobranca
                              ,pr_cdocorre  => 9                        -- Codigo Ocorrencia
                              ,pr_dtmvtolt  => rw_crapceb_nbloq.dat_dtmvtolt  -- Data movimento
                              ,pr_cdoperad  => vr_cdoperad              -- Operador
                              ,pr_nrremass  => 0                        -- Numero da Remessa
                              ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                              ,pr_cdcritic  => vr_cdcritic              -- Codigo da Critica
                              ,pr_dscritic  => vr_dscritic );           -- Descricao da critica
            
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_prox; 
            END IF;
          END IF;

          --> Verificar se foi enviado ao serasa
          IF rw_crapcob.inserasa IN (1 -- Pendente Envio
                                    ,2 -- Solicitacao
                                    ,5 -- Negativada
                                    ,7) THEN -- Acao Judicial
             SSPC0002.pc_cancelar_neg_serasa(pr_cdcooper => rw_crapcob.cdcooper,
                                             pr_nrcnvcob => rw_crapcob.nrcnvcob,
                                             pr_nrdconta => rw_crapcob.nrdconta,
                                             pr_nrdocmto => rw_crapcob.nrdocmto,
                                             pr_nrremass => 0,
                                             pr_cdoperad => vr_cdoperad,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic );
            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_prox;
            END IF;                             
          END IF;
          
        END LOOP;  --> Fim loop cr_crapcob  
        
        --> Lancamento Tarifas
        PAGA0001.pc_efetua_lancto_tarifas_lat 
                            (pr_cdcooper             => rw_crapceb_nbloq.cdcooper     -- Codigo Cooperativa
                            ,pr_dtmvtolt             => rw_crapceb_nbloq.dat_dtmvtolt -- Data Movimento
                            ,pr_tab_lat_consolidada  => vr_tab_lat_consolidada        -- Tabela Lancamentos
                            ,pr_cdcritic             => vr_cdcritic                   -- Codigo Erro
                            ,pr_dscritic             => vr_dscritic);                 -- Descricao Erro
        
        --Se Ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_prox;
        END IF;
      
      EXCEPTION
        WHEN vr_exc_prox THEN
--          ROLLBACK TO vr_trans_crps702;
          /* Se aconteceu erro deve gera o log */
          vr_dscritic := 'Erro ao atualizar convenio '||rw_crapceb_nbloq.nrconven||
                           ' Cooper: '||rw_crapceb_nbloq.cdcooper||' Conta: '||rw_crapceb_nbloq.nrdconta ||
                           ' :'||vr_dscritic;
                    
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, --> erro tratado
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                     pr_nmarqlog     => vr_dslogmes);
          vr_dscritic := NULL;
              
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar convenio '||rw_crapceb_nbloq.nrconven||
                           ' Cooper: '||rw_crapceb_nbloq.cdcooper||' Conta: '||rw_crapceb_nbloq.nrdconta ||
                           ' :'||SQLERRM;
          RAISE vr_exc_saida;
      END;
    END LOOP;
    
  END LOOP; --> Fim Loop cr_sitbnf_ianpto
  
  ----------------- ENCERRAMENTO DO PROGRAMA -------------------                                                     
  
  --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
  pc_controla_log_batch(pr_dstiplog => 'F');
  
  -- Salvar informações atualizadas
  COMMIT;
  npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS702_1');

EXCEPTION  
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
                                         
    -- Efetuar rollback
    ROLLBACK;
    npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS702_2');
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := SQLERRM;                           
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;
    npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS702_3');
END pc_crps702;
/
