CREATE OR REPLACE PACKAGE CECRED.COBR0010 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0010
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Demetrius Wolff - Mouts
  --  Data     : Abril/2017.                   Ultima atualizacao: 02/02/2018
  --
  -- Objetivo  : Rotinas referente a Instruções Bancárias para Títulos
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Procedimento do internetbank operação 66 - Comandar Instruções Bancárias para Títulos */
  PROCEDURE pc_InternetBank66(pr_cdcooper     IN crapcop.cdcooper%TYPE,
                              pr_nrdconta     IN crapass.nrdconta%TYPE,
                              pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE,
                              pr_nrdocmto     IN crapcob.nrdocmto%TYPE,
                              pr_cdocorre     IN NUMBER,
                              pr_dtmvtolt     IN crapcob.dtmvtolt%TYPE,
                              pr_cdoperad     IN crapcob.cdoperad%TYPE,
                              pr_nrremass     IN INTEGER,
                              pr_vlabatim     IN crapcob.vlabatim%TYPE,
                              pr_dtvencto     IN crapcob.dtvencto%TYPE,
                              pr_vldescto     IN crapcob.vldescto%TYPE,
                              pr_cdtpinsc     IN crapcob.cdtpinsc%TYPE,	
                              pr_nrcelsac     IN crapsab.nrcelsac%TYPE,
                              pr_qtdiaprt     IN crapcob.qtdiaprt%TYPE,                              
                              pr_inavisms     IN crapcob.inavisms%TYPE,                                                            
                              pr_xml_dsmsgerr OUT VARCHAR2,
                              pr_cdcritic     OUT INTEGER,
                              pr_dscritic     OUT VARCHAR2);

  /* Comandar Instruções Bancárias para Títulos através da tela COBRAN */
  PROCEDURE pc_grava_instr_boleto(pr_cdcooper IN INTEGER,     --> Cooperativa
                                  pr_dtmvtolt IN DATE,        --> Data
                                  pr_cdoperad IN VARCHAR2,    --> Operador
                                  pr_cdinstru IN INTEGER,     --> Instrução
                                  pr_nrdconta IN INTEGER,     --> Conta
                                  pr_nrcnvcob IN INTEGER,     --> Convenio
                                  pr_nrdocmto IN INTEGER,     --> Boleto
                                  pr_vlabatim IN NUMBER,      --> Valor de Abatimento
                                  pr_dtvencto IN DATE,        --> Data de Vencimetno
                                  pr_qtdiaprt IN NUMBER,      --> Quantidade de dias para protesto
                                  pr_cdcritic OUT INTEGER,    --> Codigo da Critica
                                  pr_dscritic OUT VARCHAR2);  --> Descricao da Critica

  --> Comandar baixa efetiva de boletos pagos no dia fora da cooperativo(interbancaria)
  PROCEDURE pc_gera_baixa_eft_interbca( pr_cdcooper IN INTEGER,      --> Cooperativa
                                        pr_dtmvtolt IN DATE,         --> Data
                                        pr_cdcritic OUT INTEGER,     --> Codigo da Critica
                                        pr_dscritic OUT VARCHAR2);   --> Descricao da Critica                                  

  PROCEDURE pc_imp_carta_anuencia(pr_cdcooper     IN crapcop.cdcooper%TYPE,
                                  pr_nrdconta     IN crapass.nrdconta%TYPE,
                                  pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE,
                                  pr_nrdocmto     IN crapcob.nrdocmto%TYPE,
                                  pr_dtmvtolt     IN crapcob.dtmvtolt%TYPE,
                                  pr_cdoperad     IN crapcob.cdoperad%TYPE,
                                  pr_dtliqdiv     IN DATE, -- data de liquidacao da divida
                                  pr_xml_dsmsgerr OUT VARCHAR2,
                                  pr_cdcritic     OUT INTEGER,
                                  pr_dscritic     OUT VARCHAR2);                                        

  /* Procedimento do internetbank - Comandar Baixa Multipla de Boletos */
  PROCEDURE pc_gera_baixa_multipla(pr_cdcooper     IN crapcop.cdcooper%TYPE, --> Cooperativa
                                   pr_nrdconta     IN crapass.nrdconta%TYPE, --> Nro da Conta do Cooperado
                                   pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE, --> Nro do Convenio
                                   pr_nrdocmto     IN VARCHAR2,              --> Nros dos documentos separados por ";" (ponto e virgula) 
                                   pr_dtmvtolt     IN crapcob.dtmvtolt%TYPE, --> Data de Movimentacao
                                   pr_cdoperad     IN crapcob.cdoperad%TYPE, --> Codigo do Operador
                                   pr_xml_dsmsgerr OUT VARCHAR2,             --> XML de retorno
                                   pr_cdcritic     OUT INTEGER,              --> Codigo da Critica
                                   pr_dscritic     OUT VARCHAR2);            --> Descricao da Critica

END COBR0010;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0010 IS

  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop,
             cop.cdbcoctl,
             cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Parâmetros do cadastro de cobrança
    CURSOR cr_crapcco(pr_cdcooper IN crapcob.cdcooper%type,
                      pr_nrconven IN crapcco.nrconven%TYPE) IS
      SELECT cco.cddbanco,
             cco.cdagenci,
             cco.cdbccxlt,
             cco.nrdolote,
             cco.cdhistor,
             cco.nrdctabb,
             cco.flgutceb,
             cco.flgregis
        FROM crapcco cco
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar Ultimo Controle Cobranca
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%type,
                      pr_nrdconta IN crapceb.nrdconta%type,
                      pr_nrconven IN crapceb.nrconven%type) IS
      SELECT ceb.flceeexp, ceb.flserasa, ceb.flgregon, ceb.flgpgdiv
          FROM crapceb ceb
         WHERE ceb.cdcooper = pr_cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = pr_nrconven
         ORDER BY ceb.progress_recid DESC;
      rw_crapceb cr_crapceb%ROWTYPE;

    -- Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrcpfcgc, ass.inpessoa
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

    --> Busca as informacoes da cobranca
    CURSOR cr_crapcob (pr_cdcooper crapcob.cdcooper%TYPE,
                       pr_nrdconta crapcob.nrdconta%TYPE,
                       pr_cdbandoc crapcob.cdbandoc%TYPE,
                       pr_nrdctabb crapcob.nrdctabb%TYPE,
                       pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                       pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT cob.vltitulo,
             cob.nrnosnum,
             cob.nrinssac,
             cob.dsendsac,
             cob.nmbaisac,
             cob.nrcepsac,
             cob.nmcidsac,
             cob.cdufsaca,
             cob.qtdiaprt,
             cob.dsdoccop,
             cob.cdbandoc,
             cob.nrdctabb,
             cob.inemiten,
             cob.dtretcob,
             cob.inavisms,
             cob.insmsant,
             cob.insmsvct,
             cob.insmspos,
             cob.rowid
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper 
         AND cob.cdbandoc = pr_cdbandoc 
         AND cob.nrdctabb = pr_nrdctabb 
         AND cob.nrcnvcob = pr_nrcnvcob 
         AND cob.nrdconta = pr_nrdconta 
         AND cob.nrdocmto = pr_nrdocmto;
      rw_crapcob cr_crapcob%ROWTYPE;

  /* Procedimento do internetbank operação 66 - Comandar Instruções Bancárias para Títulos */
  PROCEDURE pc_InternetBank66(pr_cdcooper     IN crapcop.cdcooper%TYPE,
                              pr_nrdconta     IN crapass.nrdconta%TYPE,
                              pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE,
                              pr_nrdocmto     IN crapcob.nrdocmto%TYPE,
                              pr_cdocorre     IN NUMBER,
                              pr_dtmvtolt     IN crapcob.dtmvtolt%TYPE,
                              pr_cdoperad     IN crapcob.cdoperad%TYPE,
                              pr_nrremass     IN INTEGER,
                              pr_vlabatim     IN crapcob.vlabatim%TYPE,
                              pr_dtvencto     IN crapcob.dtvencto%TYPE,
                              pr_vldescto     IN crapcob.vldescto%TYPE,
                              pr_cdtpinsc     IN crapcob.cdtpinsc%TYPE,
                              pr_nrcelsac     IN crapsab.nrcelsac%TYPE,
                              pr_qtdiaprt     IN crapcob.qtdiaprt%TYPE,
                              pr_inavisms     IN crapcob.inavisms%TYPE,
                              pr_xml_dsmsgerr OUT VARCHAR2,
                              pr_cdcritic     OUT INTEGER,
                              pr_dscritic     OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_InternetBank66        Antiga: sistema/internet/fontes/InternetBank66.p
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Demetrius Wolff - Mouts
      Data    : Abril/2017.
   
      Dados referentes ao programa:
       
      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Comandar Instruções Bancárias para Títulos - Cob. Registrada
          
      Alteracoes: 31/05/2011 - Adicionado verificacao de operacao ao carregar
                               Passado horario de operacao para XML (Jorge).
                        
                  22/06/2011 - Adicionado parametro de XML idesthor no retorno de
                              <LIMITE> e verificao caso seja cob. reg. (Jorge).
                            
                  14/07/2011 - Retirado duplicidade de codigo da linha 49 - 65
                               (Jorge).
                             
                  26/12/2011 - Utilizar data do dia - crapdat.dtmvtocd (Rafael).
                
                  10/01/2012 - Incluido rotina de geracao de log. (Rafael)
                
                  04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                               (Lucas R.)
                             
                  25/04/2013 - Adicionado cdocorre 7 e 8, add param de entrada
                               par_vldescto. (Jorge)    
                             
                  10/06/2013 - Ajustado log de conceder/cancelar descto. (Rafael)
                
                  12/07/2013 - Nao verificar horario de operacao para o comando
                               de instrucoes. O Controle do horário ficará agora 
                               com a b1wgen0088. (Rafael)
                             
                  28/08/2013 - Incluso o parametro tt-lat-consolidada nas procedures
                               de instrucao (inst-) e incluso a include b1wgen0010tt.i
                               (Daniel)
                             
                  05/11/2013 - Incluso chamada para a procedure efetua-lancamento-tarifas-lat
                               (Daniel)  
                             
                  28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                               (Daniel/Rafael/Reinert)   

                  04/02/2016 - Ajuste Projeto Negativação Serasa (Daniel)   
                                 
                  13/10/2016 - Inclusao opcao 95 e 96, para Enviar e cancelar
                               SMS de vencimento. PRJ319 - SMS Cobranca (Odirlei-AMcom)
                                    
                  08/12/2017 - Inclusão de commit/rollback para finalizar a transação
                               e possibilitar a chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                               (SD#791193 - AJFink)											   

                  04/05/2018 - Inclusao de parametro qtdiaprt referente a quantidade de dias 
                               para protesto automatico - instrução 80. PRJ352 - Protesto (Supero)

                  01/06/2018 - Adicionar o Numero de Celular do Sacado como parametro, para que seja 
                               processado na instrução 95. PRJ285 - Nova Conta Online (Douglas)

                  22/10/2018 - Incluir parametro pr_inavisms na chamada do IB66 (Lucas Ranghetti INC0025087)
     .................................................................................*/
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Parâmetros do cadastro de cobrança
    CURSOR cr_crapcco(pr_cdcooper IN crapcob.cdcooper%type,
                      pr_nrconven IN crapcco.nrconven%TYPE) IS
      SELECT cco.cddbanco,
             cco.cdagenci,
             cco.cdbccxlt,
             cco.nrdolote,
             cco.cdhistor,
             cco.nrdctabb,
             cco.flgutceb,
             cco.flgregis
        FROM crapcco cco
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar Ultimo Controle Cobranca
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%type,
                      pr_nrdconta IN crapceb.nrdconta%type,
                      pr_nrconven IN crapceb.nrconven%type) IS
      SELECT ceb.flceeexp, ceb.flserasa, ceb.flgregon, ceb.flgpgdiv
          FROM crapceb ceb
         WHERE ceb.cdcooper = pr_cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = pr_nrconven
         ORDER BY ceb.progress_recid DESC;
      rw_crapceb cr_crapceb%ROWTYPE;

    -- Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrcpfcgc, ass.inpessoa
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

    --> Busca as informacoes da cobranca
    CURSOR cr_crapcob (pr_cdcooper crapcob.cdcooper%TYPE,
                       pr_nrdconta crapcob.nrdconta%TYPE,
                       pr_cdbandoc crapcob.cdbandoc%TYPE,
                       pr_nrdctabb crapcob.nrdctabb%TYPE,
                       pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                       pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT cob.vltitulo,
             cob.nrnosnum,
             cob.nrinssac,
             cob.dsendsac,
             cob.nmbaisac,
             cob.nrcepsac,
             cob.nmcidsac,
             cob.cdufsaca,
             cob.qtdiaprt,
             cob.dsdoccop,
             cob.cdbandoc,
             cob.nrdctabb,
             cob.inemiten,
             cob.dtretcob,
             cob.inavisms,
             cob.insmsant,
             cob.insmsvct,
             cob.insmspos,
             cob.rowid
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper 
         AND cob.cdbandoc = pr_cdbandoc 
         AND cob.nrdctabb = pr_nrdctabb 
         AND cob.nrcnvcob = pr_nrcnvcob 
         AND cob.nrdconta = pr_nrdconta 
         AND cob.nrdocmto = pr_nrdocmto;
      rw_crapcob cr_crapcob%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    pr_rec_header           COBR0006.typ_rec_header;
--    vr_rec_header           COBR0006.typ_rec_header;
    vr_tab_instrucao        COBR0006.typ_tab_instrucao;
    vr_tab_lat_consolidada  PAGA0001.typ_tab_lat_consolidada;

    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_tab_rejeitado COBR0006.typ_tab_rejeitado;
    vr_dscritic  VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
        
  BEGIN
    
    --Inicializa variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;    
       
    --> Verificar cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Cooperativa de destino nao cadastrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
      
    --> Verificar cobrança
    OPEN cr_crapcco(pr_cdcooper => pr_cdcooper, pr_nrconven => pr_nrcnvcob);

    FETCH cr_crapcco
      INTO rw_crapcco;
    IF cr_crapcco%NOTFOUND THEN
      CLOSE cr_crapcco;
      vr_dscritic := 'Registro de cobranca nao cadastrado.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapcco;
    END IF;

--
    --> Verificar cobrança
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrconven => pr_nrcnvcob);

    FETCH cr_crapceb
      INTO rw_crapceb;
    IF cr_crapceb%NOTFOUND THEN
      CLOSE cr_crapceb;
      vr_dscritic := 'Registro de emissao de boleto nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapceb;
    END IF;

    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Conta/DV Informado Header Arquivo nao pertence a um cooperado cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    --> Busca as informacoes da cobranca
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_cdbandoc => rw_crapcco.cddbanco,
                    pr_nrdctabb => rw_crapcco.nrdctabb,
                    pr_nrcnvcob => pr_nrcnvcob,
                    pr_nrdocmto => pr_nrdocmto);
    FETCH cr_crapcob
      INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      CLOSE cr_crapcob;
      vr_dscritic := 'Informacoes da cobranca nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcob;
    END IF;

    vr_tab_instrucao.delete;
    vr_tab_instrucao(1).cdcooper := pr_cdcooper;
    vr_tab_instrucao(1).nrdconta := pr_nrdconta;
    vr_tab_instrucao(1).nrcnvcob := pr_nrcnvcob;
    vr_tab_instrucao(1).nrdocmto := pr_nrdocmto;
    vr_tab_instrucao(1).nrremass := pr_nrremass;
    vr_tab_instrucao(1).cdocorre := pr_cdocorre;
    vr_tab_instrucao(1).vltitulo := rw_crapcob.vltitulo;
    vr_tab_instrucao(1).vldescto := pr_vldescto;
    vr_tab_instrucao(1).vlabatim := pr_vlabatim;
    vr_tab_instrucao(1).dtvencto := pr_dtvencto;
    vr_tab_instrucao(1).nrnosnum := rw_crapcob.nrnosnum;
    vr_tab_instrucao(1).nrinssac := rw_crapcob.nrinssac;
    vr_tab_instrucao(1).dsendsac := rw_crapcob.dsendsac;
    vr_tab_instrucao(1).nmbaisac := rw_crapcob.nmbaisac;
    vr_tab_instrucao(1).nrcepsac := rw_crapcob.nrcepsac;
    vr_tab_instrucao(1).nmcidsac := rw_crapcob.nmcidsac;
    vr_tab_instrucao(1).cdufsaca := rw_crapcob.cdufsaca;
    vr_tab_instrucao(1).qtdiaprt := pr_qtdiaprt; -- rw_crapcob.qtdiaprt;
    vr_tab_instrucao(1).dsdoccop := rw_crapcob.dsdoccop;
    vr_tab_instrucao(1).cdbandoc := rw_crapcob.cdbandoc;
    vr_tab_instrucao(1).nrdctabb := rw_crapcob.nrdctabb;
    vr_tab_instrucao(1).inemiten := rw_crapcob.inemiten;
    vr_tab_instrucao(1).dtemscob := rw_crapcob.dtretcob;
    vr_tab_instrucao(1).inavisms := nvl(pr_inavisms,rw_crapcob.inavisms);
    vr_tab_instrucao(1).insmsant := rw_crapcob.insmsant;
    vr_tab_instrucao(1).insmsvct := rw_crapcob.insmsvct;
    vr_tab_instrucao(1).insmspos := rw_crapcob.insmspos;
    vr_tab_instrucao(1).nrcelsac := pr_nrcelsac; -- Celular do Sacado   rw_crapsab.nrcelsac;

    -- Carregar todas as informacoes do Header
    pr_rec_header.nrremass := 0; --vr_nrremass;
    pr_rec_header.cdbancbb := rw_crapcco.cddbanco;
    pr_rec_header.cdagenci := rw_crapcco.cdagenci;
    pr_rec_header.cdbccxlt := rw_crapcco.cdbccxlt;
    pr_rec_header.nrdolote := rw_crapcco.nrdolote;
    pr_rec_header.cdhistor := rw_crapcco.cdhistor;
    pr_rec_header.nrdctabb := rw_crapcco.nrdctabb;
    pr_rec_header.cdbandoc := rw_crapcco.cddbanco;
    pr_rec_header.nrcnvcob := pr_nrcnvcob;
    pr_rec_header.flgutceb := rw_crapcco.flgutceb;
    pr_rec_header.flgregis := rw_crapcco.flgregis;
    pr_rec_header.flceeexp := rw_crapceb.flceeexp;
    pr_rec_header.inpessoa := rw_crapass.inpessoa;
    pr_rec_header.flserasa := rw_crapceb.flserasa;
--    pr_rec_header.flgregon := rw_crapceb.flgregon;
--    pr_rec_header.flgpgdiv := rw_crapceb.flgpgdiv;

    -- Apos a importacao, processar PL TABLE das instrucoes
    COBR0006.pc_processa_instrucoes(pr_cdcooper            => pr_cdcooper, --> Codigo da Cooperativa
                                    pr_dtmvtolt            => pr_dtmvtolt, --> Data de Movimento
                                    pr_cdoperad            => pr_cdoperad, --> Operador
                                    pr_flremarq            => 0,            --> Identifica se é uma remessa via arquivo(1-Sim, 0-Não)
                                    pr_tab_instrucao       => vr_tab_instrucao, --> Tabela de Cobranca
                                    pr_rec_header          => pr_rec_header, --> Dados do Header do Arquivo
                                    pr_tab_rejeitado       => vr_tab_rejeitado, --> Tabela de rejeitados
                                    pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                                    pr_cdcritic            => vr_cdcritic, --> Codigo da Critica
                                    pr_dscritic            => vr_dscritic); --> Descricao da Critica
                              
     -- Se ocorreu critica escreve no proc_message.log
     -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' - ERRO no processamento das instrucoes: ' || 
                                                   vr_cdcritic || ' - ' || vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      RAISE vr_exc_erro;
          
    END IF;
                
    -- Apos a importacao, processar PL TABLE de rejeitados
    COBR0006.pc_processa_rejeitados(pr_tab_rejeitado => vr_tab_rejeitado, --> Tabela de rejeitados
                                    pr_cdcritic      => vr_cdcritic, --> Codigo da Critica
                                    pr_dscritic      => vr_dscritic); --> Descricao da Critica
                               
   -- Se ocorreu critica escreve no proc_message.log
   -- Não para o processo
   IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' - ERRO no processamento dos rejeitados: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

     RAISE vr_exc_erro;
          
    END IF;
                             
    PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => pr_cdcooper,
                                          pr_dtmvtolt            => pr_dtmvtolt,
                                          pr_tab_lat_consolidada => vr_tab_lat_consolidada,
                                          pr_cdcritic            => vr_cdcritic,
                                          pr_dscritic            => vr_dscritic);
                                             
    -- Se ocorreu critica escreve no proc_message.log
    -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' - ERRO no lancamento de tarifas: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      RAISE vr_exc_erro;
          
    END IF;
 
    commit;
    npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_1');

  EXCEPTION
    WHEN vr_exc_erro THEN
    begin
      rollback;
      npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_2');
      
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
    end;
    WHEN OTHERS THEN
    begin
      rollback;
      npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_3');
      
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado no processamento de instrucoes. Tente novamente ou contacte seu PA';
      pr_xml_dsmsgerr := '<dsmsgerr>' || pr_dscritic || ' - ' || SQLERRM || '</dsmsgerr>';
    end;
  END pc_InternetBank66;

  /* Comandar Instruções Bancárias para Títulos através da tela COBRAN */
  PROCEDURE pc_grava_instr_boleto(pr_cdcooper IN INTEGER,      --> Cooperativa
                                  pr_dtmvtolt IN DATE,         --> Data
                                  pr_cdoperad IN VARCHAR2,     --> Operador
                                  pr_cdinstru IN INTEGER,      --> Instrução
                                  pr_nrdconta IN INTEGER,      --> Conta
                                  pr_nrcnvcob IN INTEGER,      --> Convenio
                                  pr_nrdocmto IN INTEGER,      --> Boleto
                                  pr_vlabatim IN NUMBER,       --> Valor de Abatimento
                                  pr_dtvencto IN DATE,         --> Data de Vencimetno
                                  pr_qtdiaprt IN NUMBER,       --> Quantidade de dias para protesto
                                  pr_cdcritic OUT INTEGER,     --> Codigo da Critica
                                  pr_dscritic OUT VARCHAR2     --> Descricao da Critica
                                 ) IS 
  
    /* ..........................................................................
    
     Programa : pc_grava_instr_boleto        Antiga: b1wgen0010.grava_instrucoes
     Sistema : Internet - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Douglas Quisinski
     Data    : Junho/2017
    
     Dados referentes ao programa:
      
     Frequencia: Sempre que for chamado (On-Line)
     Objetivo  : Comandar Instruções Bancárias para Títulos - Cob. Registrada
         
     Alteracoes: 08/12/2017 - Inclusão de commit/rollback para finalizar a transação
                              e possibilitar a chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                              (SD#791193 - AJFink)
    
                 02/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto    
    .................................................................................*/
  
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Parâmetros do cadastro de cobrança
    CURSOR cr_crapcco(pr_cdcooper IN crapcob.cdcooper%type,
                      pr_nrconven IN crapcco.nrconven%TYPE) IS
      SELECT cco.cddbanco,
             cco.cdagenci,
             cco.cdbccxlt,
             cco.nrdolote,
             cco.cdhistor,
             cco.nrdctabb,
             cco.flgutceb,
             cco.flgregis
        FROM crapcco cco
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;
  
    --Selecionar Ultimo Controle Cobranca
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%type,
                      pr_nrdconta IN crapceb.nrdconta%type,
                      pr_nrconven IN crapceb.nrconven%type) IS
      SELECT ceb.flceeexp, ceb.flserasa, ceb.flgregon, ceb.flgpgdiv
        FROM crapceb ceb
       WHERE ceb.cdcooper = pr_cdcooper
         AND ceb.nrdconta = pr_nrdconta
         AND ceb.nrconven = pr_nrconven
       ORDER BY ceb.progress_recid DESC;
    rw_crapceb cr_crapceb%ROWTYPE;
  
    -- Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrcpfcgc, ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    --> Busca as informacoes da cobranca
    CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE,
                      pr_nrdconta crapcob.nrdconta%TYPE,
                      pr_cdbandoc crapcob.cdbandoc%TYPE,
                      pr_nrdctabb crapcob.nrdctabb%TYPE,
                      pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                      pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT cob.vltitulo,
             cob.nrnosnum,
             cob.nrinssac,
             cob.dsendsac,
             cob.nmbaisac,
             cob.nrcepsac,
             cob.nmcidsac,
             cob.cdufsaca,
             cob.qtdiaprt,
             cob.dsdoccop,
             cob.cdbandoc,
             cob.nrdctabb,
             cob.inemiten,
             cob.dtretcob,
             cob.inavisms,
             cob.insmsant,
             cob.insmsvct,
             cob.insmspos,
             cob.rowid
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.cdbandoc = pr_cdbandoc
         AND cob.nrdctabb = pr_nrdctabb
         AND cob.nrcnvcob = pr_nrcnvcob
         AND cob.nrdconta = pr_nrdconta
         AND cob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;
  
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_rec_header          COBR0006.typ_rec_header;
    vr_tab_instrucao       COBR0006.typ_tab_instrucao;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  
    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_tab_rejeitado COBR0006.typ_tab_rejeitado;
    vr_dscritic      VARCHAR2(4000);
  
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    --Inicializa variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;
  
    --> Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Cooperativa de destino nao cadastrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
  
    --> Verificar cobrança
    OPEN cr_crapcco(pr_cdcooper => pr_cdcooper, pr_nrconven => pr_nrcnvcob);
  
    FETCH cr_crapcco
      INTO rw_crapcco;
    IF cr_crapcco%NOTFOUND THEN
      CLOSE cr_crapcco;
      vr_dscritic := 'Registro de cobranca nao cadastrado.';
      RAISE vr_exc_erro;
    
    ELSE
      CLOSE cr_crapcco;
    END IF;
  
    --
    --> Verificar cobrança
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrconven => pr_nrcnvcob);
  
    FETCH cr_crapceb
      INTO rw_crapceb;
    IF cr_crapceb%NOTFOUND THEN
      CLOSE cr_crapceb;
      vr_dscritic := 'Registro de emissao de boleto nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapceb;
    END IF;
  
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Conta/DV Informado Header Arquivo nao pertence a um cooperado cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
  
    --> Busca as informacoes da cobranca
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_cdbandoc => rw_crapcco.cddbanco,
                    pr_nrdctabb => rw_crapcco.nrdctabb,
                    pr_nrcnvcob => pr_nrcnvcob,
                    pr_nrdocmto => pr_nrdocmto);
    FETCH cr_crapcob
      INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      CLOSE cr_crapcob;
      vr_dscritic := 'Informacoes da cobranca nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcob;
    END IF;
  
    vr_tab_instrucao.delete;
    vr_tab_instrucao(1).cdcooper := pr_cdcooper;
    vr_tab_instrucao(1).nrdconta := pr_nrdconta;
    vr_tab_instrucao(1).nrcnvcob := pr_nrcnvcob;
    vr_tab_instrucao(1).nrdocmto := pr_nrdocmto;
    -- No progress no numero de remessa do associado estava sempre zero 
    vr_tab_instrucao(1).nrremass := 0;
    vr_tab_instrucao(1).cdocorre := pr_cdinstru;
    vr_tab_instrucao(1).vltitulo := rw_crapcob.vltitulo;
    vr_tab_instrucao(1).vlabatim := pr_vlabatim;
    vr_tab_instrucao(1).dtvencto := pr_dtvencto;
    vr_tab_instrucao(1).nrnosnum := rw_crapcob.nrnosnum;
    vr_tab_instrucao(1).nrinssac := rw_crapcob.nrinssac;
    vr_tab_instrucao(1).dsendsac := rw_crapcob.dsendsac;
    vr_tab_instrucao(1).nmbaisac := rw_crapcob.nmbaisac;
    vr_tab_instrucao(1).nrcepsac := rw_crapcob.nrcepsac;
    vr_tab_instrucao(1).nmcidsac := rw_crapcob.nmcidsac;
    vr_tab_instrucao(1).cdufsaca := rw_crapcob.cdufsaca;
    
    vr_tab_instrucao(1).dsdoccop := rw_crapcob.dsdoccop;
    vr_tab_instrucao(1).cdbandoc := rw_crapcob.cdbandoc;
    vr_tab_instrucao(1).nrdctabb := rw_crapcob.nrdctabb;
    vr_tab_instrucao(1).inemiten := rw_crapcob.inemiten;
    vr_tab_instrucao(1).dtemscob := rw_crapcob.dtretcob;
    vr_tab_instrucao(1).inavisms := rw_crapcob.inavisms;
    vr_tab_instrucao(1).insmsant := rw_crapcob.insmsant;
    vr_tab_instrucao(1).insmsvct := rw_crapcob.insmsvct;
    vr_tab_instrucao(1).insmspos := rw_crapcob.insmspos;
    vr_tab_instrucao(1).nrcelsac := NULL; -- Celular do Sacado   rw_crapsab.nrcelsac;
  	
    IF NVL(pr_qtdiaprt,0) > 0 THEN
    vr_tab_instrucao(1).qtdiaprt := pr_qtdiaprt;
    ELSE
       vr_tab_instrucao(1).qtdiaprt := rw_crapcob.qtdiaprt;
    END IF;		
  
    -- Carregar todas as informacoes do Header
    vr_rec_header.nrremass := 0; --vr_nrremass;
    vr_rec_header.cdbancbb := rw_crapcco.cddbanco;
    vr_rec_header.cdagenci := rw_crapcco.cdagenci;
    vr_rec_header.cdbccxlt := rw_crapcco.cdbccxlt;
    vr_rec_header.nrdolote := rw_crapcco.nrdolote;
    vr_rec_header.cdhistor := rw_crapcco.cdhistor;
    vr_rec_header.nrdctabb := rw_crapcco.nrdctabb;
    vr_rec_header.cdbandoc := rw_crapcco.cddbanco;
    vr_rec_header.nrcnvcob := pr_nrcnvcob;
    vr_rec_header.flgutceb := rw_crapcco.flgutceb;
    vr_rec_header.flgregis := rw_crapcco.flgregis;
    vr_rec_header.flceeexp := rw_crapceb.flceeexp;
    vr_rec_header.inpessoa := rw_crapass.inpessoa;
    vr_rec_header.flserasa := rw_crapceb.flserasa;
  
    -- Apos a importacao, processar PL TABLE das instrucoes
    COBR0006.pc_processa_instrucoes(pr_cdcooper            => pr_cdcooper, --> Codigo da Cooperativa
                                    pr_dtmvtolt            => pr_dtmvtolt, --> Data de Movimento
                                    pr_cdoperad            => pr_cdoperad, --> Operador
                                    pr_flremarq            => 0,            --> Identifica se é uma remessa via arquivo(1-Sim, 0-Não)
                                    pr_tab_instrucao       => vr_tab_instrucao, --> Tabela de Cobranca
                                    pr_rec_header          => vr_rec_header, --> Dados do Header do Arquivo
                                    pr_tab_rejeitado       => vr_tab_rejeitado, --> Tabela de rejeitados
                                    pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                                    pr_cdcritic            => vr_cdcritic, --> Codigo da Critica
                                    pr_dscritic            => vr_dscritic); --> Descricao da Critica
  
    -- Se ocorreu critica escreve no proc_message.log
    -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED',
                                                                              pr_cdcooper,
                                                                              'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ERRO no processamento das instrucoes: ' ||
                                                    vr_cdcritic || ' - ' ||
                                                    vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      RAISE vr_exc_erro;
    
    END IF;
  
    -- Apos a importacao, processar PL TABLE de rejeitados
    COBR0006.pc_processa_rejeitados(pr_tab_rejeitado => vr_tab_rejeitado, --> Tabela de rejeitados
                                    pr_cdcritic      => vr_cdcritic, --> Codigo da Critica
                                    pr_dscritic      => vr_dscritic); --> Descricao da Critica
  
    -- Se ocorreu critica escreve no proc_message.log
    -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED',
                                                                              pr_cdcooper,
                                                                              'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ERRO no processamento dos rejeitados: ' ||
                                                    vr_cdcritic || ' - ' ||
                                                    vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      RAISE vr_exc_erro;
    
    END IF;
  
    PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => pr_cdcooper,
                                          pr_dtmvtolt            => pr_dtmvtolt,
                                          pr_tab_lat_consolidada => vr_tab_lat_consolidada,
                                          pr_cdcritic            => vr_cdcritic,
                                          pr_dscritic            => vr_dscritic);
  
    -- Se ocorreu critica escreve no proc_message.log
    -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED',
                                                                              pr_cdcooper,
                                                                              'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ERRO no lancamento de tarifas: ' ||
                                                    vr_cdcritic || ' - ' ||
                                                    vr_dscritic);
      RAISE vr_exc_erro;
    
    END IF;
  
    commit;
    npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_4');

  EXCEPTION
    WHEN vr_exc_erro THEN
    begin
      rollback;
      npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_5');
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    end;
    WHEN OTHERS THEN
    begin
      rollback;
      npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_6');
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado no processamento de instrucoes. Tente novamente ou contacte seu PA' ||
                     ' - ' || SQLERRM;
    end;
  END pc_grava_instr_boleto;
  
  --> Comandar baixa efetiva de boletos pagos no dia fora da cooperativo(interbancaria)
  PROCEDURE pc_gera_baixa_eft_interbca( pr_cdcooper IN INTEGER,      --> Cooperativa
                                        pr_dtmvtolt IN DATE,         --> Data
                                        pr_cdcritic OUT INTEGER,     --> Codigo da Critica
                                        pr_dscritic OUT VARCHAR2) IS --> Descricao da Critica
  
    /* ..........................................................................
    
     Programa : pc_gera_baixa_eft_interbca       
     Sistema : Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Julho/2017
    
     Dados referentes ao programa:
      
     Frequencia: Sempre que for chamado (On-Line)
     Objetivo  : Comandar baixa efetiva de boletos pagos no dia fora da cooperativo(interbancaria)
         
     Alteracoes: 01/08/2017 - Ajustado indpagto para "zero" referente aos boletos 085
	                          pagos fora da cooperativa. (Rafael)                  
    
    .................................................................................*/
  
    ----------------> CURSORES <--------------- 
    --> Buscar boletos pagos no dia
    CURSOR cr_crapcob IS 
      SELECT cob.ROWID rowid_cob            
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.dtdpagto = pr_dtmvtolt
         AND cob.indpagto = 0
         AND cob.flgcbdda = 1
         AND cob.incobran = 5
         AND cob.nrdident > 0
         ;     
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    TYPE typ_tab_crapcob IS TABLE OF cr_crapcob%ROWTYPE
         INDEX BY PLS_INTEGER;
    vr_tab_crapcob typ_tab_crapcob;
    
    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(4000);
  
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    --Inicializa variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    
    -- Buscar boletos pagos no dia
    OPEN cr_crapcob;     
    FETCH cr_crapcob BULK COLLECT INTO vr_tab_crapcob;     
    CLOSE cr_crapcob;
       
    --> Criar crapdda
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crapcob SAVE EXCEPTIONS 
        INSERT INTO crapdda
                 (  cdcooper, 
                    dtsolici, 
                    dtmvtolt,
                    flgerado, 
                    cobrowid)                                
            VALUES (pr_cdcooper, --> cdcooper
                    SYSDATE,     --> dtsolici
                    pr_dtmvtolt, --> dtmvtolt
                    'N',         --> flgerado
                    vr_tab_crapcob(idx).rowid_cob);                  
    EXCEPTION
       WHEN others THEN
         -- Gerar erro
         vr_dscritic := 'Erro ao inserir na tabela crapdda. '||
                        SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
        RAISE vr_exc_erro;
    END;      
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
    
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado ao pc_gera_baixa_eft_interbca:' || SQLERRM;
    
  END pc_gera_baixa_eft_interbca;

  /* Procedimento para registrar impressao de carta de anuencia */
  PROCEDURE pc_imp_carta_anuencia(pr_cdcooper     IN crapcop.cdcooper%TYPE,
                                  pr_nrdconta     IN crapass.nrdconta%TYPE,
                                  pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE,
                                  pr_nrdocmto     IN crapcob.nrdocmto%TYPE,
                                  pr_dtmvtolt     IN crapcob.dtmvtolt%TYPE,
                                  pr_cdoperad     IN crapcob.cdoperad%TYPE,
                                  pr_dtliqdiv     IN DATE, -- data de liquidacao da divida
                                  pr_xml_dsmsgerr OUT VARCHAR2,
                                  pr_cdcritic     OUT INTEGER,
                                  pr_dscritic     OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_Imp_Carta_Anutencia
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Rafael Cechet
      Data    : Março/2018.
   
      Dados referentes ao programa:
       
      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Registrar movimentação de impressão de carta de anuência
          
      Alteracoes:                   

     .................................................................................*/
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop,
             cop.cdbcoctl,
             cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Parâmetros do cadastro de cobrança
    CURSOR cr_crapcco(pr_cdcooper IN crapcob.cdcooper%type,
                      pr_nrconven IN crapcco.nrconven%TYPE) IS
      SELECT cco.cddbanco,
             cco.cdagenci,
             cco.cdbccxlt,
             cco.nrdolote,
             cco.cdhistor,
             cco.nrdctabb,
             cco.flgutceb,
             cco.flgregis
        FROM crapcco cco
       WHERE cco.cdcooper = pr_cdcooper
         AND cco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar Ultimo Controle Cobranca
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%type,
                      pr_nrdconta IN crapceb.nrdconta%type,
                      pr_nrconven IN crapceb.nrconven%type) IS
      SELECT ceb.flceeexp, ceb.flserasa, ceb.flgregon, ceb.flgpgdiv
          FROM crapceb ceb
         WHERE ceb.cdcooper = pr_cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = pr_nrconven
         ORDER BY ceb.progress_recid DESC;
      rw_crapceb cr_crapceb%ROWTYPE;

    -- Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrcpfcgc, ass.inpessoa
       FROM crapass ass
      WHERE ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

    --> Busca as informacoes da cobranca
    CURSOR cr_crapcob (pr_cdcooper crapcob.cdcooper%TYPE,
                       pr_nrdconta crapcob.nrdconta%TYPE,
                       pr_cdbandoc crapcob.cdbandoc%TYPE,
                       pr_nrdctabb crapcob.nrdctabb%TYPE,
                       pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                       pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT cob.vltitulo,
             cob.nrnosnum,
             cob.nrinssac,
             cob.dsendsac,
             cob.nmbaisac,
             cob.nrcepsac,
             cob.nmcidsac,
             cob.cdufsaca,
             cob.qtdiaprt,
             cob.dsdoccop,
             cob.cdbandoc,
             cob.nrdctabb,
             cob.inemiten,
             cob.dtretcob,
             cob.inavisms,
             cob.insmsant,
             cob.insmsvct,
             cob.insmspos,
             cob.insrvprt, -- servico de protesto (0-Nenhum,1-IEPTB,2-BB)
             cob.rowid
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper 
         AND cob.cdbandoc = pr_cdbandoc 
         AND cob.nrdctabb = pr_nrdctabb 
         AND cob.nrcnvcob = pr_nrcnvcob 
         AND cob.nrdconta = pr_nrdconta 
         AND cob.nrdocmto = pr_nrdocmto;
      rw_crapcob cr_crapcob%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    vr_tab_lat_consolidada  PAGA0001.typ_tab_lat_consolidada;    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;    
    
    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    vr_index_lat VARCHAR2(60);    
    
    --Variaveis de Excecao
    vr_des_erro VARCHAR2(10);
    vr_exc_erro  EXCEPTION;
        
  BEGIN
    
    --Inicializa variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;   
    
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
       CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 0;
      vr_dscritic := 'Sistema sem data de movimento.';
      RAISE vr_exc_erro;
    ELSE
       CLOSE btch0001.cr_crapdat;
    END IF;     
       
    --> Verificar cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Cooperativa de destino nao cadastrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
      
    --> Verificar cobrança
    OPEN cr_crapcco(pr_cdcooper => pr_cdcooper, pr_nrconven => pr_nrcnvcob);

    FETCH cr_crapcco
      INTO rw_crapcco;
    IF cr_crapcco%NOTFOUND THEN
      CLOSE cr_crapcco;
      vr_dscritic := 'Registro de cobranca nao cadastrado.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapcco;
    END IF;

    --> Verificar cobrança
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrconven => pr_nrcnvcob);

    FETCH cr_crapceb
      INTO rw_crapceb;
    IF cr_crapceb%NOTFOUND THEN
      CLOSE cr_crapceb;
      vr_dscritic := 'Registro de emissao de boleto nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapceb;
    END IF;

    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Conta/DV Informado Header Arquivo nao pertence a um cooperado cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    --> Busca as informacoes da cobranca
    OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_cdbandoc => rw_crapcco.cddbanco,
                    pr_nrdctabb => rw_crapcco.nrdctabb,
                    pr_nrcnvcob => pr_nrcnvcob,
                    pr_nrdocmto => pr_nrdocmto);
    FETCH cr_crapcob
      INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      CLOSE cr_crapcob;
      vr_dscritic := 'Informacoes da cobranca nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcob;
    END IF;
                              
    -- não permitir geracao de carta de anuencia para boletos protestados pelo BB 
    -- ou sem servico de protesto    
    IF rw_crapcob.insrvprt <> 1 THEN
      vr_dscritic := 'Servico temporariamente indisponivel para este tipo de boleto.';
      RAISE vr_exc_erro;      
    END IF;
                              
     -- Se ocorreu critica escreve no proc_message.log
     -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' - ERRO no processamento da impressao de carta de anuencia: ' || 
                                                   vr_cdcritic || ' - ' || vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      RAISE vr_exc_erro;
          
    END IF;
    
    -- 98 - Registro de impressao de carta de anuencia
    COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob.rowid
                                       ,pr_cdocorre => 98   -- 98 - Registro de impressao de carta de anuencia
                                       ,pr_cdmotivo => 'F2' -- Motivo 
                                       ,pr_vltarifa => 0    -- Valor da Tarifa  
                                       ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                       ,pr_cdagectl => rw_crapcop.cdagectl
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrremass => 0
                                       ,pr_dtcatanu => pr_dtliqdiv -- data de liquidacao da divida
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
    -- Verifica se ocorreu erro durante a execucao
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    --Montar Indice para lancamento tarifa
    vr_index_lat:= lpad(pr_cdcooper,10,'0')||
                   lpad(pr_nrdconta,10,'0')||
                   lpad(pr_nrcnvcob,10,'0')||
                   lpad(98,10,'0')||
                   lpad('0',10,'0')||
                   lpad(vr_tab_lat_consolidada.Count+1,10,'0');
    -- Gerar registro Tarifa 
    vr_tab_lat_consolidada(vr_index_lat).cdcooper:= pr_cdcooper;
    vr_tab_lat_consolidada(vr_index_lat).nrdconta:= pr_nrdconta;
    vr_tab_lat_consolidada(vr_index_lat).nrdocmto:= pr_nrdocmto;
    vr_tab_lat_consolidada(vr_index_lat).nrcnvcob:= pr_nrcnvcob;
    vr_tab_lat_consolidada(vr_index_lat).dsincide:= 'RET';
    vr_tab_lat_consolidada(vr_index_lat).cdocorre:= 98;    -- 98 - Registro de impressao de carta de anuencia
    vr_tab_lat_consolidada(vr_index_lat).cdmotivo:= 'F2';  -- Motivo
    vr_tab_lat_consolidada(vr_index_lat).vllanmto:= rw_crapcob.vltitulo;       
                                                                            
    PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => pr_cdcooper,
                                          pr_dtmvtolt            => rw_crapdat.dtmvtolt,
                                          pr_tab_lat_consolidada => vr_tab_lat_consolidada,
                                          pr_cdcritic            => vr_cdcritic,
                                          pr_dscritic            => vr_dscritic);
                                             
    -- Se ocorreu critica escreve no proc_message.log
    -- Não para o processo
    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                        ' - ERRO no lancamento de tarifas: ' || 
                                                        vr_cdcritic || ' - ' || vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      RAISE vr_exc_erro;
          
    END IF;
    
    PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                , pr_cdoperad => pr_cdoperad
                                , pr_dtmvtolt => pr_dtmvtolt
                                , pr_dsmensag => 'Impressao de carta de anuencia. Liquidacao da divida em ' || to_char(pr_dtliqdiv,'DD/MM/RRRR')
                                , pr_des_erro => vr_des_erro
                                , pr_dscritic => vr_dscritic);
                                
    IF trim(vr_des_erro) <> 'OK' OR trim(vr_dscritic) IS NOT NULL THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
 
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
                                
    WHEN OTHERS THEN
      
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado no registro de impressao de carta de anuencia. Tente novamente ou contacte seu PA';
      pr_xml_dsmsgerr := '<dsmsgerr>' || pr_dscritic || ' - ' || SQLERRM || '</dsmsgerr>';
      
  END pc_imp_carta_anuencia;  

  /* Procedimento do internetbank - Comandar Baixa Multipla de Boletos */
  PROCEDURE pc_gera_baixa_multipla(pr_cdcooper     IN crapcop.cdcooper%TYPE,
                                   pr_nrdconta     IN crapass.nrdconta%TYPE,
                                   pr_nrcnvcob     IN crapcob.nrcnvcob%TYPE,
                                   pr_nrdocmto     IN VARCHAR2,
                                   pr_dtmvtolt     IN crapcob.dtmvtolt%TYPE,
                                   pr_cdoperad     IN crapcob.cdoperad%TYPE,
                                   pr_xml_dsmsgerr OUT VARCHAR2,
                                   pr_cdcritic     OUT INTEGER,
                                   pr_dscritic     OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_gera_baixa_multipla               Antiga: 
      Sistema : Internet - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Andre Clemer - Supero
      Data    : Setembro/2018.
   
      Dados referentes ao programa:
       
      Frequencia: Sempre que for chamado (On-Line)
      Objetivo  : Comandar Baixa Multipla de Boletos
          
      Alteracoes: 

     .................................................................................*/

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    pr_rec_header           COBR0006.typ_rec_header;
    vr_tab_instrucao        COBR0006.typ_tab_instrucao;
    vr_tab_lat_consolidada  PAGA0001.typ_tab_lat_consolidada;
    vr_boletos              gene0002.typ_split;

    ----------------> VARIAVEIS <---------------
    --Variaveis de Erro
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_tab_rejeitado COBR0006.typ_tab_rejeitado;
    vr_dscritic  VARCHAR2(4000);
    
    --Variaveis de Excecao
    vr_exc_erro  EXCEPTION;
        
  BEGIN
    
    --Inicializa variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;    
    
    vr_boletos := gene0002.fn_quebra_string(pr_nrdocmto, ';');
    
    IF vr_boletos.count = 0 THEN
      vr_dscritic := 'Nao foram encontrados boletos para efetuar a baixa.';
      RAISE vr_exc_erro;
    ELSIF vr_boletos.count > 20 THEN
      vr_dscritic := 'O limite de boletos para baixa nao pode ser superior a 20.';
      RAISE vr_exc_erro;
    END IF;
       
    --> Verificar cooperativa
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'Cooperativa de destino nao cadastrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
      
    --> Verificar cobrança
    OPEN cr_crapcco(pr_cdcooper => pr_cdcooper, pr_nrconven => pr_nrcnvcob);

    FETCH cr_crapcco
      INTO rw_crapcco;
    IF cr_crapcco%NOTFOUND THEN
      CLOSE cr_crapcco;
      vr_dscritic := 'Registro de cobranca nao cadastrado.';
      RAISE vr_exc_erro;
      
    ELSE
      CLOSE cr_crapcco;
    END IF;

--
    --> Verificar cobrança
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrconven => pr_nrcnvcob);

    FETCH cr_crapceb
      INTO rw_crapceb;
    IF cr_crapceb%NOTFOUND THEN
      CLOSE cr_crapceb;
      vr_dscritic := 'Registro de emissao de boleto nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapceb;
    END IF;

    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Conta/DV Informado Header Arquivo nao pertence a um cooperado cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    FOR ind_registro IN vr_boletos.first..vr_boletos.last LOOP
      --> Busca as informacoes da cobranca
      OPEN cr_crapcob(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_cdbandoc => rw_crapcco.cddbanco,
                      pr_nrdctabb => rw_crapcco.nrdctabb,
                      pr_nrcnvcob => pr_nrcnvcob,
                      pr_nrdocmto => vr_boletos(ind_registro));
      FETCH cr_crapcob
        INTO rw_crapcob;
      IF cr_crapcob%NOTFOUND THEN
        CLOSE cr_crapcob;
        pr_dscritic := pr_dscritic || vr_boletos(ind_registro) || ':Informacoes do boleto nao encontradas;';
        -- RAISE vr_exc_erro;
        CONTINUE;
      ELSE
        CLOSE cr_crapcob;
      END IF;

      vr_tab_instrucao.delete;
      vr_tab_instrucao(1).cdcooper := pr_cdcooper;
      vr_tab_instrucao(1).nrdconta := pr_nrdconta;
      vr_tab_instrucao(1).nrcnvcob := pr_nrcnvcob;
      vr_tab_instrucao(1).nrdocmto := vr_boletos(ind_registro);
      vr_tab_instrucao(1).cdocorre := 2;
      vr_tab_instrucao(1).vltitulo := rw_crapcob.vltitulo;
      vr_tab_instrucao(1).nrnosnum := rw_crapcob.nrnosnum;
      vr_tab_instrucao(1).nrinssac := rw_crapcob.nrinssac;
      vr_tab_instrucao(1).dsendsac := rw_crapcob.dsendsac;
      vr_tab_instrucao(1).nmbaisac := rw_crapcob.nmbaisac;
      vr_tab_instrucao(1).nrcepsac := rw_crapcob.nrcepsac;
      vr_tab_instrucao(1).nmcidsac := rw_crapcob.nmcidsac;
      vr_tab_instrucao(1).cdufsaca := rw_crapcob.cdufsaca;
      vr_tab_instrucao(1).dsdoccop := rw_crapcob.dsdoccop;
      vr_tab_instrucao(1).cdbandoc := rw_crapcob.cdbandoc;
      vr_tab_instrucao(1).nrdctabb := rw_crapcob.nrdctabb;
      vr_tab_instrucao(1).inemiten := rw_crapcob.inemiten;
      vr_tab_instrucao(1).dtemscob := rw_crapcob.dtretcob;
      vr_tab_instrucao(1).inavisms := rw_crapcob.inavisms;
      vr_tab_instrucao(1).insmsant := rw_crapcob.insmsant;
      vr_tab_instrucao(1).insmsvct := rw_crapcob.insmsvct;
      vr_tab_instrucao(1).insmspos := rw_crapcob.insmspos;

      -- Carregar todas as informacoes do Header
      pr_rec_header.nrremass := 0; --vr_nrremass;
      pr_rec_header.cdbancbb := rw_crapcco.cddbanco;
      pr_rec_header.cdagenci := rw_crapcco.cdagenci;
      pr_rec_header.cdbccxlt := rw_crapcco.cdbccxlt;
      pr_rec_header.nrdolote := rw_crapcco.nrdolote;
      pr_rec_header.cdhistor := rw_crapcco.cdhistor;
      pr_rec_header.nrdctabb := rw_crapcco.nrdctabb;
      pr_rec_header.cdbandoc := rw_crapcco.cddbanco;
      pr_rec_header.nrcnvcob := pr_nrcnvcob;
      pr_rec_header.flgutceb := rw_crapcco.flgutceb;
      pr_rec_header.flgregis := rw_crapcco.flgregis;
      pr_rec_header.flceeexp := rw_crapceb.flceeexp;
      pr_rec_header.inpessoa := rw_crapass.inpessoa;
      pr_rec_header.flserasa := rw_crapceb.flserasa;
  --    pr_rec_header.flgregon := rw_crapceb.flgregon;
  --    pr_rec_header.flgpgdiv := rw_crapceb.flgpgdiv;

      -- Apos a importacao, processar PL TABLE das instrucoes
      COBR0006.pc_processa_instrucoes(pr_cdcooper            => pr_cdcooper, --> Codigo da Cooperativa
                                      pr_dtmvtolt            => pr_dtmvtolt, --> Data de Movimento
                                      pr_cdoperad            => pr_cdoperad, --> Operador
                                      pr_flremarq            => 0,            --> Identifica se é uma remessa via arquivo(1-Sim, 0-Não)
                                      pr_tab_instrucao       => vr_tab_instrucao, --> Tabela de Cobranca
                                      pr_rec_header          => pr_rec_header, --> Dados do Header do Arquivo
                                      pr_tab_rejeitado       => vr_tab_rejeitado, --> Tabela de rejeitados
                                      pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                                      pr_cdcritic            => vr_cdcritic, --> Codigo da Critica
                                      pr_dscritic            => vr_dscritic); --> Descricao da Critica
                                
       -- Se ocorreu critica escreve no proc_message.log
       -- Não para o processo
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                      ' - ERRO no processamento das instrucoes: ' || 
                                                     vr_cdcritic || ' - ' || vr_dscritic);
        -- pr_cdcritic := vr_cdcritic;
        -- pr_dscritic := vr_dscritic;

        pr_dscritic := pr_dscritic || vr_boletos(ind_registro) || ':Erro no processamento das instrucoes (' || vr_cdcritic || ' - ' || vr_dscritic || ');';
        -- RAISE vr_exc_erro;
        CONTINUE;
            
      END IF;
                  
      -- Apos a importacao, processar PL TABLE de rejeitados
      COBR0006.pc_processa_rejeitados(pr_tab_rejeitado => vr_tab_rejeitado, --> Tabela de rejeitados
                                      pr_cdcritic      => vr_cdcritic, --> Codigo da Critica
                                      pr_dscritic      => vr_dscritic); --> Descricao da Critica
                                 
     -- Se ocorreu critica escreve no proc_message.log
     -- Não para o processo
     IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                          ' - ERRO no processamento dos rejeitados: ' || 
                                                          vr_cdcritic || ' - ' || vr_dscritic);
        -- pr_cdcritic := vr_cdcritic;
        -- pr_dscritic := vr_dscritic;

        pr_dscritic := pr_dscritic || vr_boletos(ind_registro) || ':Erro no processamento dos rejeitados (' || vr_cdcritic || ' - ' || vr_dscritic || ');';
        -- RAISE vr_exc_erro;
        CONTINUE;
            
      END IF;
                               
      PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => pr_cdcooper,
                                            pr_dtmvtolt            => pr_dtmvtolt,
                                            pr_tab_lat_consolidada => vr_tab_lat_consolidada,
                                            pr_cdcritic            => vr_cdcritic,
                                            pr_dscritic            => vr_dscritic);
                                               
      -- Se ocorreu critica escreve no proc_message.log
      -- Não para o processo
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_nmarqlog     => gene0001.fn_param_sistema('CRED', pr_cdcooper, 'NOME_ARQ_LOG_MESSAGE'),
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                          ' - ERRO no lancamento de tarifas: ' || 
                                                          vr_cdcritic || ' - ' || vr_dscritic);
        -- pr_cdcritic := vr_cdcritic;
        -- pr_dscritic := vr_dscritic;

        pr_dscritic := pr_dscritic || vr_boletos(ind_registro) || ':Erro no lancamento de tarifas (' || vr_cdcritic || ' - ' || vr_dscritic || ');';
        -- RAISE vr_exc_erro;
        CONTINUE;
            
      END IF;
    END LOOP;
 
    COMMIT;
    npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_1');
    
    IF TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
    BEGIN
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_2');
      
      -- se possui codigo, porém não possui descrição     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- buscar descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF TRIM(pr_dscritic) IS NOT NULL THEN
        vr_dscritic := pr_dscritic;
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
    END;
    WHEN OTHERS THEN
    BEGIN
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc('COBR0010_3');
      
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado no processamento de instrucoes. Tente novamente ou contacte seu PA';
      pr_xml_dsmsgerr := '<dsmsgerr>' || pr_dscritic || ' - ' || SQLERRM || '</dsmsgerr>';
    END;
  END pc_gera_baixa_multipla;

END COBR0010;
/
