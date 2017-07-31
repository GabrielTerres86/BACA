CREATE OR REPLACE PACKAGE CECRED.COBR0010 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0010
  --  Sistema  : Procedimentos para  gerais da cobranca
  --  Sigla    : CRED
  --  Autor    : Demetrius Wolff - Mouts
  --  Data     : Abril/2017.                   Ultima atualizacao: 12/04/2017
  --
  -- Objetivo  : Rotinas referente a Instru��es Banc�rias para T�tulos
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Procedimento do internetbank opera��o 66 - Comandar Instru��es Banc�rias para T�tulos */
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
                              pr_xml_dsmsgerr OUT VARCHAR2,
                              pr_cdcritic     OUT INTEGER,
                              pr_dscritic     OUT VARCHAR2);

  /* Comandar Instru��es Banc�rias para T�tulos atrav�s da tela COBRAN */
  PROCEDURE pc_grava_instr_boleto(pr_cdcooper IN INTEGER,     --> Cooperativa
                                  pr_dtmvtolt IN DATE,        --> Data
                                  pr_cdoperad IN VARCHAR2,    --> Operador
                                  pr_cdinstru IN INTEGER,     --> Instru��o
                                  pr_nrdconta IN INTEGER,     --> Conta
                                  pr_nrcnvcob IN INTEGER,     --> Convenio
                                  pr_nrdocmto IN INTEGER,     --> Boleto
                                  pr_vlabatim IN NUMBER,      --> Valor de Abatimento
                                  pr_dtvencto IN DATE,        --> Data de Vencimetno
                                  pr_cdcritic OUT INTEGER,    --> Codigo da Critica
                                  pr_dscritic OUT VARCHAR2);  --> Descricao da Critica

  --> Comandar baixa efetiva de boletos pagos no dia fora da cooperativo(interbancaria)
  PROCEDURE pc_gera_baixa_eft_interbca( pr_cdcooper IN INTEGER,      --> Cooperativa
                                        pr_dtmvtolt IN DATE,         --> Data
                                        pr_cdcritic OUT INTEGER,     --> Codigo da Critica
                                        pr_dscritic OUT VARCHAR2);   --> Descricao da Critica                                  

END COBR0010;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0010 IS

  /* Procedimento do internetbank opera��o 66 - Comandar Instru��es Banc�rias para T�tulos */
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
      Objetivo  : Comandar Instru��es Banc�rias para T�tulos - Cob. Registrada
          
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
                               de instrucoes. O Controle do hor�rio ficar� agora 
                               com a b1wgen0088. (Rafael)
                             
                  28/08/2013 - Incluso o parametro tt-lat-consolidada nas procedures
                               de instrucao (inst-) e incluso a include b1wgen0010tt.i
                               (Daniel)
                             
                  05/11/2013 - Incluso chamada para a procedure efetua-lancamento-tarifas-lat
                               (Daniel)  
                             
                  28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede 
                               (Daniel/Rafael/Reinert)   

                  04/02/2016 - Ajuste Projeto Negativa��o Serasa (Daniel)   
                                 
                  13/10/2016 - Inclusao opcao 95 e 96, para Enviar e cancelar
                               SMS de vencimento. PRJ319 - SMS Cobranca (Odirlei-AMcom)
                                    

     .................................................................................*/
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Par�metros do cadastro de cobran�a
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
      
    --> Verificar cobran�a
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
    --> Verificar cobran�a
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
    vr_tab_instrucao(1).qtdiaprt := rw_crapcob.qtdiaprt;
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
                                    pr_flremarq            => 0,            --> Identifica se � uma remessa via arquivo(1-Sim, 0-N�o)
                                    pr_tab_instrucao       => vr_tab_instrucao, --> Tabela de Cobranca
                                    pr_rec_header          => pr_rec_header, --> Dados do Header do Arquivo
                                    pr_tab_rejeitado       => vr_tab_rejeitado, --> Tabela de rejeitados
                                    pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                                    pr_cdcritic            => vr_cdcritic, --> Codigo da Critica
                                    pr_dscritic            => vr_dscritic); --> Descricao da Critica
                              
     -- Se ocorreu critica escreve no proc_message.log
     -- N�o para o processo
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
   -- N�o para o processo
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
    -- N�o para o processo
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
 
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- se possui codigo, por�m n�o possui descri��o     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- buscar descri��o
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      END IF; 
      
      -- definir retorno
      pr_xml_dsmsgerr := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
                                
    WHEN OTHERS THEN
      
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado no processamento de instrucoes. Tente novamente ou contacte seu PA';
      pr_xml_dsmsgerr := '<dsmsgerr>' || pr_dscritic || ' - ' || SQLERRM || '</dsmsgerr>';
      
  END pc_InternetBank66;

  /* Comandar Instru��es Banc�rias para T�tulos atrav�s da tela COBRAN */
  PROCEDURE pc_grava_instr_boleto(pr_cdcooper IN INTEGER,      --> Cooperativa
                                  pr_dtmvtolt IN DATE,         --> Data
                                  pr_cdoperad IN VARCHAR2,     --> Operador
                                  pr_cdinstru IN INTEGER,      --> Instru��o
                                  pr_nrdconta IN INTEGER,      --> Conta
                                  pr_nrcnvcob IN INTEGER,      --> Convenio
                                  pr_nrdocmto IN INTEGER,      --> Boleto
                                  pr_vlabatim IN NUMBER,       --> Valor de Abatimento
                                  pr_dtvencto IN DATE,         --> Data de Vencimetno
                                  pr_cdcritic OUT INTEGER,     --> Codigo da Critica
                                  pr_dscritic OUT VARCHAR2) IS --> Descricao da Critica
  
    /* ..........................................................................
    
     Programa : pc_grava_instr_boleto        Antiga: b1wgen0010.grava_instrucoes
     Sistema : Internet - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Douglas Quisinski
     Data    : Junho/2017
    
     Dados referentes ao programa:
      
     Frequencia: Sempre que for chamado (On-Line)
     Objetivo  : Comandar Instru��es Banc�rias para T�tulos - Cob. Registrada
         
     Alteracoes:                   
    
    .................................................................................*/
  
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Par�metros do cadastro de cobran�a
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
  
    --> Verificar cobran�a
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
    --> Verificar cobran�a
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
    vr_tab_instrucao(1).qtdiaprt := rw_crapcob.qtdiaprt;
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
                                    pr_flremarq            => 0,            --> Identifica se � uma remessa via arquivo(1-Sim, 0-N�o)
                                    pr_tab_instrucao       => vr_tab_instrucao, --> Tabela de Cobranca
                                    pr_rec_header          => vr_rec_header, --> Dados do Header do Arquivo
                                    pr_tab_rejeitado       => vr_tab_rejeitado, --> Tabela de rejeitados
                                    pr_tab_lat_consolidada => vr_tab_lat_consolidada, --> Tabela tarifas
                                    pr_cdcritic            => vr_cdcritic, --> Codigo da Critica
                                    pr_dscritic            => vr_dscritic); --> Descricao da Critica
  
    -- Se ocorreu critica escreve no proc_message.log
    -- N�o para o processo
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
    -- N�o para o processo
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
    -- N�o para o processo
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
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- se possui codigo, por�m n�o possui descri��o     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- buscar descri��o
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
    
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado no processamento de instrucoes. Tente novamente ou contacte seu PA' ||
                     ' - ' || SQLERRM;
    
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
         
     Alteracoes:                   
    
    .................................................................................*/
  
    ----------------> CURSORES <--------------- 
    --> Buscar boletos pagos no dia
    CURSOR cr_crapcob IS 
      SELECT cob.ROWID rowid_cob            
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.dtdpagto = pr_dtmvtolt
         AND cob.indpagto <> 0
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
      -- Se possui codigo, por�m n�o possui descri��o     
      IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar descri��o
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
    
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
    
      -- definir retorno
      pr_cdcritic := 0;
      pr_dscritic := 'Erro inesperado ao pc_gera_baixa_eft_interbca:' || SQLERRM;
    
  END pc_gera_baixa_eft_interbca;

END COBR0010;
/
