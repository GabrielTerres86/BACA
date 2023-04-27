CREATE OR REPLACE PACKAGE CECRED.CONV0003 AS


  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONV0003
  --  Sistema  : Convenios RFB
  --  Sigla    : CRED
  --  Autor    : Jose Gracik - Mouts
  --  Data     : Abril/2021.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para integração de convenios com a RFB
  --
  ---------------------------------------------------------------------------------------------------------------

  FUNCTION fn_convenio_rfb_ativo RETURN NUMBER;

  FUNCTION fn_verifica_convenio_ativo(pr_cdcooper IN  NUMBER,       --> CODIGO DA COOPERATIVA  
                                      pr_cdempres IN  VARCHAR2)     --> CODIGO EMPRESA/CONVENIO
                                      RETURN NUMBER;

  FUNCTION fn_verifica_canal_ativo_rfb(pr_cdcooper IN  NUMBER,      --> CODIGO DA COOPERATIVA  
                                       pr_cdempres IN  VARCHAR2,    --> CODIGO EMPRESA/CONVENIO
                                       pr_cddcanal IN  NUMBER)      --> CODIGO CANAL (2=CAIXA, 3=INTERNET e MOBILE, 4=TAA)
                                       RETURN NUMBER;

  FUNCTION fn_verifica_canal_ativo_rfb_agencia(pr_cdcooper IN  NUMBER,     --> CODIGO DA COOPERATIVA  
                                               pr_cdempres IN  VARCHAR2,   --> CODIGO EMPRESA/CONVENIO
                                               pr_cdagenci IN  NUMBER)     --> CODIGO AGENCIA (90 = IB e MOBILE, 90 <> CAIXA)
                                               RETURN NUMBER;

  PROCEDURE pc_envia_email_erro (pr_conteudo IN  VARCHAR2,
                                 pr_nmarquiv IN  VARCHAR2,
                                 pr_nmrotina IN  VARCHAR2,
                                 pr_dscritic OUT VARCHAR2);
  
  -- Procedure para o controle de execução do envio de remessas para a RFB
  PROCEDURE pc_job_envia_remessa_rfb (pr_dscritic OUT VARCHAR2);

  -- Procedure para o controle de execução de processamento de retornos da RFB
  PROCEDURE pc_job_proc_retorno_rfb (pr_dscritic OUT VARCHAR2);

                                     
END CONV0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CONV0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONV0003
  --  Sistema  : Convenios RFB
  --  Sigla    : CRED
  --  Autor    : Jose Gracik - Mouts
  --  Data     : Abril/2021.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para integração de convenios com a RFB
  --
  -- 25-04-2023 Adicionado validação por data de apuração e data de vencimento(data limite na craplft)
  ---------------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------------------------


  FUNCTION fn_retorna_barras_duplicado_lft(pr_cdbarras       IN craplft.cdbarras%TYPE,
                                           pr_progress_recid IN craplft.progress_recid%TYPE)
                                           RETURN VARCHAR2 IS
  
    CURSOR cr_craplft2(pr_cdbarras       IN craplft.cdbarras%TYPE,
                       pr_progress_recid IN craplft.progress_recid%TYPE) IS
      SELECT 'Coop:'||to_char(lft.cdcooper,'fm00')||
             ' Conta:'||to_char(lft.nrdconta,'fm999999990')||
             ' Cod.Barras:'||trim(lft.cdbarras)||
             ' Valor:'||to_char(lft.vllanmto,'fm999999990.00')
             descricao
        FROM craplft lft
       WHERE UPPER(lft.cdbarras)   = UPPER(pr_cdbarras)
         AND lft.progress_recid   <> pr_progress_recid
         AND lft.cdcooper          = lft.cdcooper
         AND lft.insitfat          = 1;
    rw_craplft2 cr_craplft2%ROWTYPE;
         
    vr_dsdescricao VARCHAR2(200);
    
  BEGIN
    
    OPEN cr_craplft2(pr_cdbarras       => pr_cdbarras,
                     pr_progress_recid => pr_progress_recid);
    FETCH cr_craplft2 INTO rw_craplft2;

    IF cr_craplft2%FOUND THEN
       vr_dsdescricao := rw_craplft2.descricao;
    ELSE
       vr_dsdescricao := '';
    END IF;
    -- Fechar o cursor pois haverá raise
    CLOSE cr_craplft2;
    
    RETURN NVL(vr_dsdescricao,' ');
    
  END fn_retorna_barras_duplicado_lft;

  FUNCTION fn_convenio_rfb_ativo RETURN NUMBER IS
    CURSOR cr_liberacao_ativas IS
     SELECT c.flgliberado
       FROM tbconv_liberacao t,
            tbconv_canalcoop_liberado c
      WHERE t.tparrecadacao = 4 --RFB
        AND c.idseqconvelib = t.idseqconvelib
        AND c.flgliberado = 1;

     vr_flgativo NUMBER;   

    BEGIN
      OPEN cr_liberacao_ativas;
      FETCH cr_liberacao_ativas INTO vr_flgativo;
      CLOSE cr_liberacao_ativas;

      RETURN NVL(vr_flgativo,0);
  END fn_convenio_rfb_ativo;


  FUNCTION fn_verifica_convenio_ativo(pr_cdcooper IN  NUMBER,
                                      pr_cdempres IN  VARCHAR2) RETURN NUMBER IS
  
    CURSOR cr_liberacao_ativas IS
     SELECT c.flgliberado
       FROM crapcop p,
            tbconv_liberacao t,
            tbconv_canalcoop_liberado c
      WHERE ((pr_cdcooper <> 0 AND p.cdcooper = pr_cdcooper AND t.cdcooper = p.cdcooper) OR pr_cdcooper = 0)
        AND t.tparrecadacao = 4 --RFB
        AND t.cdempres = pr_cdempres
        AND c.idseqconvelib = t.idseqconvelib
        AND c.flgliberado = 1;

     vr_flgativo NUMBER;   

    BEGIN
      OPEN cr_liberacao_ativas;
      FETCH cr_liberacao_ativas INTO vr_flgativo;
      CLOSE cr_liberacao_ativas;
      
      RETURN NVL(vr_flgativo,0);
   END fn_verifica_convenio_ativo;


  FUNCTION fn_verifica_canal_ativo_rfb(pr_cdcooper IN  NUMBER,
                                        pr_cdempres IN  VARCHAR2,
                                        pr_cddcanal IN  NUMBER) RETURN NUMBER IS
  
    CURSOR cr_liberacao_ativas IS
     SELECT c.flgliberado
       FROM crapcop p,
            tbconv_liberacao t,
            tbconv_canalcoop_liberado c
      WHERE p.flgativo = 1
        AND p.cdcooper = pr_cdcooper
        AND t.cdcooper = p.cdcooper
        AND t.tparrecadacao = 4 -- RFB
        AND t.cdempres = pr_cdempres
        AND c.cdcanal = pr_cddcanal
        AND c.idseqconvelib = t.idseqconvelib;

    vr_flgativo  NUMBER;

  BEGIN
      OPEN cr_liberacao_ativas;
      FETCH cr_liberacao_ativas INTO vr_flgativo;
      CLOSE cr_liberacao_ativas;
      
      RETURN NVL(vr_flgativo,0);
      
  END fn_verifica_canal_ativo_rfb;
  
  FUNCTION fn_verifica_canal_ativo_rfb_agencia(pr_cdcooper IN  NUMBER,
                                               pr_cdempres IN  VARCHAR2,
                                               pr_cdagenci IN  NUMBER) RETURN NUMBER IS
  
    CURSOR cr_liberacao_ativas IS
     SELECT c.flgliberado
       FROM crapcop p,
            tbconv_liberacao t,
            tbconv_canalcoop_liberado c
      WHERE p.flgativo = 1
        AND p.cdcooper = pr_cdcooper
        AND t.cdcooper = p.cdcooper
        AND t.tparrecadacao = 4 -- RFB
        AND t.cdempres = pr_cdempres
        AND c.cdcanal = (CASE WHEN pr_cdagenci = 90 THEN 3 ELSE 2 END)
        AND c.idseqconvelib = t.idseqconvelib;

    vr_flgativo  NUMBER;

  BEGIN
      OPEN cr_liberacao_ativas;
      FETCH cr_liberacao_ativas INTO vr_flgativo;
      CLOSE cr_liberacao_ativas;
      
      RETURN NVL(vr_flgativo,0);
      
  END fn_verifica_canal_ativo_rfb_agencia;

  
  PROCEDURE pc_envia_email_erro (pr_conteudo IN  VARCHAR2,
                                 pr_nmarquiv IN  VARCHAR2,
                                 pr_nmrotina IN  VARCHAR2,
                                 pr_dscritic OUT VARCHAR2) IS
  
    vr_email_dest  crapprm.dsvlrprm%TYPE;
    vr_dscritic    VARCHAR2(100);
    vr_conteudo    VARCHAR2(1000);    
  BEGIN
    --Email Destino
    vr_email_dest:= gene0001.fn_param_sistema('CRED',0,'EMAIL_REM_RFB');

    -- Conteúdo do e-mail
    vr_conteudo:= 'ATENCAO!!<br><br>Voce esta recebendo este email pois o programa responsavel ' ||
                  'pelo envio dos arquivos de remessa da RFB falhou em sua execucao.<br>' ||
                  'Arquivo: ' || pr_nmarquiv || '.<br>' ||
                  'Rotina: '  || pr_nmrotina || '.<br>' ||
                  'Erro: ' || pr_conteudo || '.<br>' ||
                  '<br><br>Data: ' || to_char(SYSDATE,'DD/MM/YYYY') ||
                  '<br>Hora: '|| TO_CHAR(SYSDATE,'HH24:MI:SS');

    --Enviar Email
    gene0003.pc_solicita_email(pr_cdcooper        => 3
                              ,pr_cdprogra        => 'CONV0003'
                              ,pr_des_destino     => vr_email_dest
                              ,pr_des_assunto     => 'RFB - Falha no processamento'
                              ,pr_des_corpo       => vr_conteudo
                              ,pr_des_anexo       => pr_nmarquiv
                              ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                              ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                              ,pr_des_erro        => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
       pr_dscritic := vr_dscritic;
    END IF;

  END pc_envia_email_erro;


  PROCEDURE pc_gera_arquivos_cb_rfb(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_dtproxim  IN DATE                  --> Próxima data útil
                                   ,pr_qtdregis  IN OUT NUMBER            --> Quantidade de registros processados
                                   ,pr_cdempcon  IN INTEGER               --> Codigo da empresa convenio
                                   ,pr_cdsegmto  IN INTEGER               --> Codigo do segmento do convenio
                                   ,pr_flbarras  IN INTEGER               --> Indicador de Há Codigo de Barras (0=Não/1=Tem) 
                                   ,pr_nmarquiv OUT VARCHAR2              --> Nome do arquivo de remessa com código de barras
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Codigo de Erro
                                   ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro
   /* ..........................................................................

     Procedure: pc_gera_arquivos_cb
     Autor    : Jose Gracik (Mouts)
     Data     : Abril/2021.                     Ultima atualizacao:  /  /

     Dados referentes ao programa:

     Frequencia: Diário.
     Objetivo  : Gerar arquivos de remessa de DARF, DAS, DAE para RFB

     Alteracoes: 
    ..........................................................................*/

    ------------------------- VARIAVEIS DE EXCEÇÃO ------------------------------
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_dscriti2 VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdparece tbgen_analise_fraude.cdparecer_analise%TYPE;
    vr_dslinreg VARCHAR2(500);
    vr_seqident INTEGER;
    vr_qtdregis NUMBER  := 0;
    vr_vlrarrec NUMBER  := 0;
    vr_idremessa tbconv_remessa_pagfor.idremessa%TYPE;
    vr_tab_itens_remessa SICR0003.typ_tab_itens_remessa;
    vr_index    PLS_INTEGER := 0;
    vr_dsseqarq VARCHAR2(5);
    vr_cdhistor craphis.cdhistor%TYPE;
    vr_nrdigito INTEGER;
    vr_database VARCHAR2(100);
    vr_dsambien VARCHAR2(100);
    vr_dstptrib VARCHAR2(100);
    vr_tipopagt CHAR(1);
    vr_nmprimtl crapass.nmprimtl%TYPE;
    vr_tpfatura INTEGER;
    vr_dsbarras_duplicado VARCHAR2(200);
    vr_dsprotoc crappro.dsprotoc%TYPE;
    vr_dscomprovante crappro.dscomprovante_parceiro%TYPE;
    vr_cdagectl     VARCHAR2(10);

    -- Variaveis de controle de comandos shell
    vr_comando      VARCHAR2(500);
    vr_typ_saida    VARCHAR2(1000);
    vr_cdcnvpfo     VARCHAR2(10);

    -- Variáveis contendo os códigos de pagamentos de acordo com os tipos de identificação do contribuinte
    vr_cdpgto_cpf       crapprm.dsvlrprm%TYPE;
    vr_cdpgto_cnpj      crapprm.dsvlrprm%TYPE;
    vr_cdpgto_cei       crapprm.dsvlrprm%TYPE;
    vr_cdpgto_debcad    crapprm.dsvlrprm%TYPE;
    vr_cdpgto_nitpispas crapprm.dsvlrprm%TYPE;
    vr_cdpgto_titulo    crapprm.dsvlrprm%TYPE;
    vr_cdpgto_referen   crapprm.dsvlrprm%TYPE;
    vr_cdpgto_nb        crapprm.dsvlrprm%TYPE;
    vr_tpidentc         INTEGER;    
    -------------------------- VARIAVEIS ARQUIVOS -------------------------------
    vr_hand_arq      UTL_FILE.file_type;
    vr_nmarquiv_tmp  VARCHAR2(100);
    vr_nmarquiv      VARCHAR2(100);
    vr_nmdireto      VARCHAR2(100);
    vr_dsdirenv      VARCHAR2(1000);  
    vr_cdconven      VARCHAR2(10);

    -- Buscar lançamentos de DARF
    CURSOR cr_craplft (pr_cdcooper IN craplft.cdcooper%TYPE
                      ,pr_dtmvtant IN craplft.dtvencto%TYPE
                      ,pr_dtmvtolt IN craplft.dtvencto%TYPE
                      ,pr_cdhistor IN craplft.cdhistor%TYPE
                      ,pr_tpfatura IN craplft.tpfatura%TYPE
                      ,pr_cdempcon IN crapscn.cdempcon%TYPE
                      ,pr_cdempco2 IN crapscn.cdempco2%TYPE
                      ,pr_cdsegmto IN crapscn.cdsegmto%TYPE) IS
      SELECT lft.idanafrd
            ,lft.cdempcon
            ,lft.cdtribut
            ,lft.cdagenci
            ,lft.cdbarras
            ,lft.nrrefere
            ,lft.dtlimite
            ,lft.vllanmto
            ,lft.vlrjuros
            ,lft.vlrmulta
            ,lft.cdsegmto
            ,lft.dtmvtolt
            ,lft.cdbccxlt
            ,lft.nrdolote
            ,lft.vlpercen
            ,lft.vlrecbru
            ,lft.nrcpfcgc
            ,lft.dtapurac
            ,lft.nrdconta
            ,lft.rowid
            ,lft.cdcooper
            ,lft.nrautdoc
            ,lft.cdorigem
            ,lft.nrseqdig
            ,lft.cdhistor
            ,DECODE(NVL(ass.cdagenci,0),0,lft.cdagenci,ass.cdagenci) cdagenci_coop
            ,lft.progress_recid
        FROM craplft lft
            ,crapass ass
       WHERE lft.cdcooper  = pr_cdcooper
         AND lft.dtvencto  BETWEEN pr_dtmvtant AND pr_dtmvtolt
         AND lft.insitfat  = 1
         AND lft.tpfatura  = pr_tpfatura
         AND lft.cdhistor  = pr_cdhistor
         AND to_char(lft.cdsegmto) = pr_cdsegmto
         AND ((lft.cdempcon  IN (pr_cdempcon, pr_cdempco2)
         AND TRIM(lft.cdbarras) IS NOT NULL)
          OR (pr_cdempcon = 0 AND trim(lft.cdbarras) IS NULL AND lft.cdtribut <> '6106'))
         AND ass.cdcooper (+) = lft.cdcooper
         AND ass.nrdconta (+) = lft.nrdconta         
    ORDER BY lft.dtvencto; /* SICREDI */

    -- Cadastros de tributos do convenio SICREDI - DARF
    CURSOR cr_crapscn (pr_cdempcon IN crapscn.cdempcon%TYPE) IS
      SELECT scn.dsnomcnv
            ,scn.cdempres
            ,scn.dsdianor
            ,scn.nrrenorm
            ,scn.cdempcon
            ,scn.cdempco2
            ,scn.cdsegmto
        FROM crapscn scn
       WHERE (pr_cdempcon IN (385,64,153)      -- DARF CB
              AND  scn.cdempcon = pr_cdempcon
              AND  scn.cdsegmto = 5
              AND  scn.dtencemp IS NULL
              AND  scn.cdempres IN ('D0385','D0064','D0153'))
          OR (pr_cdempcon = 100                      -- DARF SB
              AND scn.cdempcon = 0 AND scn.cdempres = 'D0100')
          OR (pr_cdempcon = 328                      -- DAS
              AND scn.dsoparre <> 'E'
              AND (scn.cdempcon = pr_cdempcon OR scn.cdempco2 = pr_cdempcon)
              AND scn.cdsegmto = 5
              AND scn.dtencemp IS NULL
              AND scn.cdempres IN ('D0328'))
          OR (pr_cdempcon = 432                      -- DAE
              AND scn.dsoparre <> 'E'
              AND scn.cdsegmto = 5
              AND scn.dtencemp IS NULL
              AND scn.cdempres IN ('D0432'));
    rw_crapscn cr_crapscn%ROWTYPE;

    -- Buscar nome do cooperado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Buscar informacoes da cooperativa
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nrctasic
            ,cop.cdagebcb
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = DECODE(pr_cdcooper, 3,cop.cdcooper, pr_cdcooper)
       ORDER BY cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Buscar Autenticacoes dos lançamentos de Tributos Pagos
    CURSOR cr_crapaut (pr_cdcooper IN crapaut.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE
                      ,pr_cdagenci IN crapaut.cdagenci%TYPE
                      ,pr_nrsequen IN crapaut.nrsequen%TYPE
                      ,pr_nrdocmto IN crapaut.nrdocmto%TYPE
                      ,pr_vldocmto IN crapaut.vldocmto%TYPE) IS
      SELECT aut.*
        FROM crapaut aut
       WHERE aut.cdcooper = pr_cdcooper
         AND aut.dtmvtolt = pr_dtmvtolt
         AND aut.cdagenci = pr_cdagenci
         AND aut.nrsequen = pr_nrsequen
         AND aut.nrdocmto = pr_nrdocmto
         AND aut.vldocmto = pr_vldocmto;
    rw_crapaut cr_crapaut%ROWTYPE;

  BEGIN

    -- Buscar data do sistema
    -- Verifica se a cooperativa esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    END IF;
    CLOSE btch0001.cr_crapdat;

    -- Cód. convênio Pagfor
    vr_cdcnvpfo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'CONVENIO_RFB');

    --Definido com a Receita Federal, que devemos mandar Fixo 0001 na agencia
    vr_cdagectl := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'RFB_AGENCIA_ARQ');

    -- Nome dos arquivo temporário
    vr_nmarquiv_tmp := 'ARQ_RFB_' || to_char(SYSDATE, 'SSSSS');
 
    --Buscar diretorio da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                        ,pr_cdcooper => 3
                                        ,pr_nmsubdir => '/arq');
 
    -- Abre arquivo de remessa
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto       --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv_tmp       --> Nome do arquivo
                            ,pr_tipabert => 'W'               --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_hand_arq       --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);     --> Retorno da critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Cabeçalho do arquivo CSV - DARF Normal
    IF  pr_cdempcon = 100 THEN  -- DARF Sem Barras
        vr_dslinreg := 'CODIGO_EMPRESA;NOME_CONVENIOS;DATA_ARRECADACAO;VALOR_ARRECADACAO;NOME_CONTRIBUINTE;CODIGO_RECEITA;' ||
                       'TIPO_IDENTIFICACAO_CONTRIBUINTE;IDENTIFICACAO_CONTRIBUINTE;IDENTIFICACAO_TRIBUTO;PERIODO;NUMERO_REFERENCIA;' ||
                       'VALOR_PRINCIPAL;VALOR_MULTA;VALOR_JUROS;DATA_VENCIMENTO;IDENTIFICADOR;AUTENTICACAO;CAIXA;CANAL;BANCO;AGENCIA;DV_AGENCIA';          
        vr_cdhistor := 3465;               
    ELSIF pr_cdempcon IN (64,153,100,385,328,432) THEN -- DARF com barras, DAE e DAS
        vr_dslinreg := 'CODIGO_EMPRESA;NOME_CONVENIOS;DATA_ARRECADACAO;VALOR_ARRECACACAO;CODIGO_BARRAS;IDENTIFICADOR;AUTENTICACAO;CAIXA;CANAL;BANCO;AGENCIA;DV_AGENCIA';
        vr_cdhistor := 3464;
    END IF;
    
    -- Grava linha no arquivo de remessa com codigo de barras
    gene0001.pc_escr_linha_arquivo(vr_hand_arq, vr_dslinreg);

    IF pr_cdempcon IN (64,153,100,385) THEN
       vr_tpfatura := 2;
    ELSIF pr_cdempcon = 328 THEN   
       vr_tpfatura := 1;
    ELSIF pr_cdempcon = 432 THEN   
       vr_tpfatura := 4;
    END IF;

    -- DARF, DAE e DAS
    IF pr_cdempcon IN (64,153,100,385,328,432) THEN
   
       -- Itera sobre todas as cooperativas
       FOR rw_crapcop IN cr_crapcop (pr_cdcooper => pr_cdcooper) LOOP

        -- Verificacao do DV da Agencia Arrecadador - atraves do modulo 11
        CXON0014.pc_verifica_digito (pr_nrcalcul => rw_crapcop.cdagectl   --Numero a ser calculado
                                    ,pr_poslimit => 0                     --Utilizado para validação de dígito adicional de DAS
                                    ,pr_nrdigito => vr_nrdigito);         --Digito verificador

         FOR rw_crapscn IN cr_crapscn (pr_cdempcon => pr_cdempcon) LOOP

           FOR rw_craplft IN cr_craplft(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtmvtant => rw_crapdat.dtmvtocd - 5
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                       ,pr_cdhistor => vr_cdhistor
                                       ,pr_tpfatura => vr_tpfatura
                                       ,pr_cdempcon => rw_crapscn.cdempcon
                                       ,pr_cdempco2 => rw_crapscn.cdempco2
                                       ,pr_cdsegmto => rw_crapscn.cdsegmto) LOOP
  
             IF nvl(rw_craplft.idanafrd,0) > 0 THEN
               -- Verificar se está aprovado pelo OFSAA
               AFRA0001.pc_ret_sit_analise_fraude(pr_idanafra => rw_craplft.idanafrd
                                                 ,pr_cdparece => vr_cdparece
                                                 ,pr_dscritic => vr_dscritic);

               IF vr_cdparece <> 1 THEN
                 CONTINUE;
               END IF;
             END IF;

             -- Verifica se possui a autenticacao
             OPEN cr_crapaut(pr_cdcooper => rw_craplft.cdcooper
                            ,pr_dtmvtolt => rw_craplft.dtmvtolt
                            ,pr_cdagenci => rw_craplft.cdagenci
                            ,pr_nrsequen => rw_craplft.nrautdoc
                            ,pr_nrdocmto => rw_craplft.nrseqdig
                            ,pr_vldocmto => (rw_craplft.vllanmto +
                                             rw_craplft.vlrmulta +
                                             rw_craplft.vlrjuros));
             FETCH cr_crapaut INTO rw_crapaut;
             -- Se não encontrar
             IF cr_crapaut%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapaut;

               -- Fechar os arquivos
               gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);

               -- Busca ambiente conectado
               vr_database := GENE0001.fn_database_name;
               vr_dsambien := CASE WHEN instr(upper(vr_database),'P',1) > 0 THEN 'P.' ELSE 'H.' END;

               IF    pr_cdempcon IN ('64','100','153') THEN 
                     -- DARF NAO NUMERADO = DARF 064 (cb), DARF 100 (sb) e DARF 153 (cb)
                     vr_dstptrib := 'DNN.';
               ELSIF pr_cdempcon = '385' THEN 
                     -- DARF NUMERADO = DARF 385 (cb)
                     vr_dstptrib := 'DNU.';
               ELSIF pr_cdempcon = '328' THEN 
                     -- DAS 328 (cb) - Simples Nacional
                     vr_dstptrib := 'DAS.';
               ELSIF pr_cdempcon = '432' THEN 
                     -- DAE 432 (cb) - Arrecadação Estadual
                     vr_dstptrib := 'DAE.';
               ELSE      
                     vr_dstptrib := 'NNN.';
               END IF;
                 
               vr_nmarquiv := 'RFB.' || vr_dsambien || vr_dstptrib || trim(to_char(pr_cdempcon, '000')) || '.' || '99999' || '.NO.PP.' || to_char(SYSDATE, 'YYYYMMDD') ||'.REM_ERRO';

               -- Comando para renomear nome do arquivo temporário para o nome final
               vr_comando:= 'mv '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' '|| vr_nmdireto || '/' || vr_nmarquiv || ' 2> /dev/null';

               --Executar o comando no unix
               GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                    ,pr_des_comando => vr_comando
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_dscritic);

               --Se ocorreu erro dar RAISE
               IF vr_typ_saida = 'ERR' THEN
                  vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
                  -- Levantar exceção
                  RAISE vr_exc_erro;
               END IF;

               -- Montar mensagem de critica
               vr_dscritic := 'Autenticacao nao encontrada. Cooperativa: ' || to_char(rw_craplft.cdcooper) ||
                              ' Conta: ' || to_char(rw_craplft.nrdconta);

               pc_envia_email_erro(pr_conteudo => vr_dscritic,
                                   pr_nmarquiv => vr_nmdireto || '/' ||vr_nmarquiv,
                                   pr_nmrotina => 'pc_gera_arquivos_cb_rfb',
                                   pr_dscritic => vr_dscriti2);
               RAISE vr_exc_erro;
             END IF;
             CLOSE cr_crapaut;

             -- Verifica se ha codigo de barras duplicados no envio do arquivo  
             IF  pr_cdempcon <> 100 THEN

                  vr_dsbarras_duplicado := fn_retorna_barras_duplicado_lft(pr_cdbarras       => rw_craplft.cdbarras,
                                                                           pr_progress_recid => rw_craplft.progress_recid);

                IF  NVL(vr_dsbarras_duplicado,' ') <> ' ' THEN  
                    -- Codigo de Barras Duplicado, fecha o arq. e envia msg de erro
                    -- Fechar os arquivos
                    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);

                    -- Busca ambiente conectado
                    vr_database := GENE0001.fn_database_name;
                    vr_dsambien := CASE WHEN instr(upper(vr_database),'P',1) > 0 THEN 'P.' ELSE 'H.' END;

                    IF    pr_cdempcon IN ('64','100','153') THEN 
                          -- DARF NAO NUMERADO = DARF 064 (cb), DARF 100 (sb) e DARF 153 (cb)
                          vr_dstptrib := 'DNN.';
                    ELSIF pr_cdempcon = '385' THEN 
                          -- DARF NUMERADO = DARF 385 (cb)
                          vr_dstptrib := 'DNU.';
                    ELSIF pr_cdempcon = '328' THEN 
                          -- DAS 328 (cb) - Simples Nacional
                          vr_dstptrib := 'DAS.';
                    ELSIF pr_cdempcon = '432' THEN 
                          -- DAE 432 (cb) - Arrecadação Estadual
                          vr_dstptrib := 'DAE.';
                    ELSE      
                          vr_dstptrib := 'NNN.';
                    END IF;
                    
                    vr_nmarquiv := 'RFB.' || vr_dsambien || vr_dstptrib || trim(to_char(pr_cdempcon, '000')) || '.' || '99999' || '.NO.PP.'|| to_char(SYSDATE, 'YYYYMMDD')||'.REM_ERRO';

                    -- Comando para renomear nome do arquivo temporário para o nome final
                    vr_comando:= 'mv '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' '|| vr_nmdireto || '/' || vr_nmarquiv ||' 2> /dev/null';

                    --Executar o comando no unix
                    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                         ,pr_des_comando => vr_comando
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);

                   --Se ocorreu erro dar RAISE
                   IF vr_typ_saida = 'ERR' THEN
                      vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
                      -- Levantar exceção
                      RAISE vr_exc_erro;
                   END IF;

                   -- Montar mensagem de critica
                   vr_dscritic := 'Codigo de Barras Duplicado . Cooperativa: ' || to_char(rw_craplft.cdcooper) ||
                                  ' Conta: ' || to_char(rw_craplft.nrdconta) || ' com o Tributo '||vr_dsbarras_duplicado;

                   pc_envia_email_erro(pr_conteudo => vr_dscritic,
                                       pr_nmarquiv => vr_nmdireto || '/' ||vr_nmarquiv,
                                       pr_nmrotina => 'pc_gera_arquivos_cb_rfb',
                                       pr_dscritic => vr_dscriti2);

                   RAISE vr_exc_erro;
                END IF;
             END IF;
             
             -- Gera sequencial do identificador Sicredi
             vr_seqident := SICR0003.fn_sequence_pagfor_identi;
             IF rw_craplft.cdagenci = 90 THEN    /* Pagamento feito pela Internet */
                vr_tipopagt := '3';
             ELSE /* Pagamento no Caixa */
                -- 1- Boca de caixa
                vr_tipopagt := '1';
             END IF;

             IF  pr_cdempcon = 100 THEN
                 -- Se foi informado o número da conta
                 IF rw_craplft.nrdconta > 0 THEN
                    OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_nrdconta => rw_craplft.nrdconta);
                    FETCH cr_crapass INTO rw_crapass;

                    IF cr_crapass%NOTFOUND THEN
                       vr_nmprimtl := 'AILOS';
                    ELSE
                       vr_nmprimtl := rw_crapass.nmprimtl;
                    END IF;
                    -- Fechar cursor
                    CLOSE cr_crapass;
                 ELSE
                    vr_nmprimtl := 'AILOS';
                 END IF;
       
                 vr_dslinreg := 'D0100'                                           || ';' || -- CODIGO_EMPRESA;
                                to_char(rw_crapscn.dsnomcnv)                      || ';' || -- NOME_CONVENIOS;
                                to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')         || ';' || -- DATA_ARRECADACAO;
                                to_char((rw_craplft.vllanmto +
                                         rw_craplft.vlrmulta +
                                         rw_craplft.vlrjuros) * 100)              || ';' || -- VALOR_ARRECADACAO;
                                SUBSTR(vr_nmprimtl,1,30)                          || ';' || -- NOME_CONTRIBUINTE;
                                to_char(rw_craplft.cdtribut)                      || ';' || -- CODIGO_RECEITA;
                                (CASE
                                   WHEN length(rw_craplft.nrcpfcgc) = 14 THEN '1'
                                   ELSE '2'
                                 END)                                             || ';' || -- TIPO_IDENTIFICACAO_CONTRIBUINTE;
                                to_char(rw_craplft.nrcpfcgc)                      || ';' || -- IDENTIFICACAO_CONTRIBUINTE;
                                '16'                                              || ';' || -- IDENTIFICACAO_TRIBUTO;
                                to_char(rw_craplft.dtapurac, 'DD/MM/RRRR')        || ';' || -- PERIODO;
                                to_char(rw_craplft.nrrefere)                      || ';' || -- NUMERO_REFERENCIA
                                to_char(rw_craplft.vllanmto * 100)                || ';' || -- VALOR_PRINCIPAL;
                                to_char(rw_craplft.vlrmulta * 100)                || ';' || -- VALOR_MULTA;
                                to_char(rw_craplft.vlrjuros * 100)                || ';' || -- VALOR_JUROS;
                                to_char(rw_craplft.dtlimite, 'DD/MM/RRRR')        || ';' || -- DATA_VENCIMENTO;
                                to_char(vr_seqident)                              || ';' || -- IDENTIFICADOR;                     
                                LPAD(rw_craplft.nrautdoc,8, '0')                  || ';' || -- AUTENTICACAO
                                to_char(SUBSTR(rw_craplft.nrdolote,3,3))          || ';' || -- CAIXA
                                vr_tipopagt                                       || ';' || -- CANAL
                                to_char(rw_crapcop.cdbcoctl,'FM000')              || ';' || -- BANCO
                                to_char(vr_cdagectl,'FM0000')                     || ';' || -- AGENCIA    
                                to_char(vr_nrdigito);                                       -- DV AGENCIA    
             ELSE
                 -- Gera linha para o arquivo de remessa com codigo de barras
                 vr_dslinreg := to_char(rw_crapscn.cdempres)              || ';' || -- CODIGO_EMPRESA
                                to_char(rw_crapscn.dsnomcnv)              || ';' || -- NOME_CONVENIOS
                                to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR') || ';' || -- DATA_ARRECADACAO
                                to_char(rw_craplft.vllanmto * 100)        || ';' || -- VALOR_ARRECACACAO
                                to_char(rw_craplft.cdbarras)              || ';' || -- CODIGO_BARRAS
                                to_char(vr_seqident)                      || ';' || -- IDENTIFICADOR    
                                LPAD(rw_craplft.nrautdoc,8, '0')          || ';' || -- AUTENTICACAO
                                to_char(SUBSTR(rw_craplft.nrdolote,3,3))  || ';' || -- CAIXA
                                vr_tipopagt                               || ';' || -- CANAL
                                to_char(rw_crapcop.cdbcoctl,'FM000')      || ';' || -- BANCO
                                to_char(vr_cdagectl,'FM0000')             || ';' || -- AGENCIA    
                                to_char(vr_nrdigito);                               -- DV AGENCIA    
             END IF;
        
             -- Grava linha no arquivo de remessa com codigo de barras
             gene0001.pc_escr_linha_arquivo(vr_hand_arq, vr_dslinreg);
             -- Atualizar registro para Enviado
             BEGIN
               UPDATE craplft lft
                  SET lft.insitfat = 2 -- Enviado
                     ,lft.dtdenvio = pr_dtproxim
                     ,lft.idsicred = vr_seqident
                WHERE lft.rowid = rw_craplft.rowid;
             EXCEPTION
              WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao atualizar craplft: ' || SQLERRM;
                 RAISE vr_exc_erro;
             END;

             -- Incrementa quantidade de registros processados
             pr_qtdregis := pr_qtdregis + 1;

             -- Armazenar dados do pagamento para registro na base de dados
             vr_qtdregis := vr_qtdregis + 1;
             IF  pr_cdempcon = 100 THEN
               vr_vlrarrec := vr_vlrarrec + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
             ELSE
               vr_vlrarrec := vr_vlrarrec + rw_craplft.vllanmto;  
             END IF;
             
             vr_index := vr_tab_itens_remessa.count() + 1;
             vr_tab_itens_remessa(vr_index).idsicredi                := vr_seqident;
             vr_tab_itens_remessa(vr_index).vlrpagamento             := (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
             vr_tab_itens_remessa(vr_index).cdcooper                 := rw_craplft.cdcooper;
             vr_tab_itens_remessa(vr_index).nrdconta                 := rw_craplft.nrdconta;
             vr_tab_itens_remessa(vr_index).cdagenci                 := rw_craplft.cdagenci;
             vr_tab_itens_remessa(vr_index).nrdolote                 := rw_craplft.nrdolote;
             vr_tab_itens_remessa(vr_index).cdhistor                 := rw_craplft.cdhistor;
             vr_tab_itens_remessa(vr_index).cdempresa_documento      := rw_crapscn.cdempres;
             vr_tab_itens_remessa(vr_index).nrautenticacao_documento := rw_craplft.nrautdoc;

             IF pr_cdempcon IN (64,153,100,385) THEN
                vr_tab_itens_remessa(vr_index).tppagamento           := 2;
             ELSIF pr_cdempcon IN (328,432) THEN   
                vr_tab_itens_remessa(vr_index).tppagamento           := 3;
             END IF;

           END LOOP;
         END LOOP;
       END LOOP;
    END IF;
    
    -- Fechar os arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);

    -- Se arquivo estiver vazio
    IF vr_qtdregis = 0 THEN
      -- Se nome do diretório e nome do arquivo foram informados
      IF TRIM(vr_nmdireto) IS NOT NULL AND
         TRIM(vr_nmarquiv_tmp) IS NOT NULL THEN
        -- Comando para remover arquivo vazio
        vr_comando:= 'rm '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE
      -- Obter sequencial arquivo
      vr_dsseqarq := TRIM(to_char(SICR0003.fn_sequence_pagfor_arq(rw_crapdat.dtmvtocd),'00000'));

      -- Montar nome do arquivo
      -- Busca ambiente conectado
      vr_database := GENE0001.fn_database_name;
      vr_dsambien := CASE WHEN instr(upper(vr_database),'P',1) > 0 THEN 'P.' ELSE 'H.' END;

      IF    pr_cdempcon IN ('64','100','153') THEN 
            -- DARF NAO NUMERADO = DARF 064 (cb), DARF 100 (sb) e DARF 153 (cb)
            vr_dstptrib := 'DNN.';
      ELSIF pr_cdempcon = '385' THEN 
            -- DARF NUMERADO = DARF 385 (cb)
            vr_dstptrib := 'DNU.';
      ELSIF pr_cdempcon = '328' THEN 
            -- DAS 328 (cb) - Simples Nacional
            vr_dstptrib := 'DAS.';
      ELSIF pr_cdempcon = '432' THEN 
            -- DAE 432 (cb) - Arrecadação Estadual
            vr_dstptrib := 'DAE.';
      ELSE      
            vr_dstptrib := 'NNN.';
      END IF;         
          
      vr_cdconven := trim(to_char(pr_cdempcon, '000'));
      
      vr_nmarquiv := 'RFB.' || vr_dsambien || vr_dstptrib || vr_cdconven || '.' || vr_dsseqarq || '.NO.PP.' || to_char(SYSDATE, 'YYYYMMDD')||'.REM';

      SICR0003.pc_registra_remessa_pagfor(pr_cdconvenio_pagfor    => vr_cdcnvpfo,
                                          pr_dtmovimento          => rw_crapdat.dtmvtocd,
                                          pr_dhenvio_remessa      => SYSDATE,
                                          pr_nmarquivo            => vr_nmarquiv,
                                          pr_tpsegmento           => 'O',
                                          pr_nrsequencia_arquivo  => to_number(vr_dsseqarq),
                                          pr_qtdregistros         => vr_qtdregis,
                                          pr_vlrarrecadacao       => vr_vlrarrec,
                                          pr_cdagente_arrecadacao => 4, -- 4-RFB
                                          pr_tab_itens_remessa    => vr_tab_itens_remessa,
                                          pr_idreenvio            => 0, -- Reenvio Não
                                          pr_idremessa            => vr_idremessa,
                                          pr_dscritic             => vr_dscritic);

      --Atualizar os registros na tbconv_registro_remessa_pagfor para identificar que já foram enviados para Tivit
      FOR vr_item IN vr_tab_itens_remessa.first .. vr_tab_itens_remessa.last LOOP
        BEGIN
           UPDATE tbconv_registro_remessa_pagfor reg
              SET reg.cdstatus_processamento              = 1,  -- Retorno Pendente
                  reg.dhinclusao_processamento            = SYSDATE,
                  reg.nmarquivo_inclusao                  = vr_nmarquiv
            WHERE reg.idsicredi = vr_tab_itens_remessa(vr_item).idsicredi;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar registro da remessa na tbconv_registro_remessa_pagfor. ID Remessa: ' ||
                           vr_tab_itens_remessa(vr_item).idsicredi  || '. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP;
       
      --Se ocorreu erro no registro da remessa na base
      IF vr_dscritic IS NOT NULL AND TRIM(vr_dscritic) <> ' ' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Comando para renomear nome do arquivo temporário para o nome final
      vr_comando:= 'mv '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' '|| vr_nmdireto || '/' || vr_nmarquiv || ' 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;

      -- Diretório para Connect Direct consumir arquivo e encaminhar remessa para TIVIT
      vr_dsdirenv := gene0001.fn_param_sistema('CRED',0,'DIR_TIVIT_CONNECT_ENV');    
              
      -- Comando para copiar o arquivo para a pasta de envio para o Connect
      vr_comando:= 'cp '||vr_nmdireto||'/'||vr_nmarquiv||' '||vr_dsdirenv||' 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
      -- Levantar exceção
         RAISE vr_exc_erro;
      END IF;

      -- Retorna nome do arquivo
      pr_nmarquiv := vr_nmarquiv;
    END IF;

    -- Efetuar commit
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se crítica possui código sem descrição
      IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Atribuir crítica de retorno
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Se arquivo está aberto
      IF utl_file.IS_OPEN(vr_hand_arq) THEN
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);
      END IF;

       pc_envia_email_erro(pr_conteudo => pr_dscritic,
                           pr_nmarquiv => '',
                           pr_nmrotina => 'pc_gera_arquivos_cb_rfb',
                           pr_dscritic => vr_dscritic);


      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Setar crítica não tratada
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || SQLERRM;

      -- Se arquivo está aberto
      IF utl_file.IS_OPEN(vr_hand_arq) THEN
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);
      END IF;

       pc_envia_email_erro(pr_conteudo => pr_dscritic,
                           pr_nmarquiv => '',
                           pr_nmrotina => 'pc_gera_arquivos_cb_rfb',
                           pr_dscritic => vr_dscritic);

      -- Efetuar rollback
      ROLLBACK;
  END pc_gera_arquivos_cb_rfb;



  PROCEDURE pc_reenvia_arquivos_cb_rfb_lft(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                          ,pr_dtproxim  IN DATE                  --> Próxima data útil
                                          ,pr_nmarquiv OUT VARCHAR2              --> Nome do arquivo de remessa com código de barras
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Codigo de Erro
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro
   /* ..........................................................................

     Procedure: pc_reenvia_arquivos_cb_rfb_lft
     Autor    : Jose Gracik (Mouts)
     Data     : Abril/2021.                     Ultima atualizacao:  /  /

     Dados referentes ao programa:

     Frequencia: Diário.
     Objetivo  : Reenvia arquivos de remessa de DARF, DAS, DAE para RFB

     Alteracoes: 
    ..........................................................................*/

    ------------------------- VARIAVEIS DE EXCEÇÃO ------------------------------
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_dscriti2 VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdparece tbgen_analise_fraude.cdparecer_analise%TYPE;
    vr_dslinreg VARCHAR2(500);
    vr_seqident INTEGER;
    vr_qtdregis NUMBER  := 0;
    vr_vlrarrec NUMBER  := 0;
    vr_idremessa tbconv_remessa_pagfor.idremessa%TYPE;
    vr_tab_itens_remessa SICR0003.typ_tab_itens_remessa;
    vr_index    PLS_INTEGER := 0;
    vr_dsseqarq VARCHAR2(5);
    vr_nrdigito INTEGER;
    vr_database VARCHAR2(100);
    vr_dsambien VARCHAR2(100);
    vr_dstptrib VARCHAR2(100);
    vr_tipopagt CHAR(1);
    vr_nmprimtl crapass.nmprimtl%TYPE;
    vr_flgfirst BOOLEAN := TRUE;
    vr_cdempcon craplft.cdempcon%TYPE;
    vr_cdreproc INTEGER;
    vr_dsreproc VARCHAR2(4);
    vr_dsbarras_duplicado VARCHAR2(200);
    vr_cdagectl     VARCHAR2(10);
       
    -- Variaveis de controle de comandos shell
    vr_comando      VARCHAR2(500);
    vr_typ_saida    VARCHAR2(1000);
    vr_cdcnvpfo     VARCHAR2(10);

    -------------------------- VARIAVEIS ARQUIVOS -------------------------------
    vr_hand_arq      UTL_FILE.file_type;
    vr_nmarquiv_tmp  VARCHAR2(100);
    vr_nmarquiv      VARCHAR2(100);
    vr_nmdireto      VARCHAR2(100);
    vr_dsdirenv      VARCHAR2(1000);  
    vr_cdconven      VARCHAR2(10);

    -- Buscar lançamentos de DARF
    CURSOR cr_craplft (pr_dtmvtocd IN craplft.dtmvtolt%TYPE) IS
      SELECT lft.idanafrd
            ,lft.cdempcon
            ,lft.cdtribut
            ,lft.cdagenci
            ,lft.cdbarras
            ,lft.nrrefere
            ,lft.dtlimite
            ,lft.vllanmto
            ,lft.vlrjuros
            ,lft.vlrmulta
            ,lft.cdsegmto
            ,lft.dtmvtolt
            ,lft.cdbccxlt
            ,lft.nrdolote
            ,lft.vlpercen
            ,lft.vlrecbru
            ,lft.nrcpfcgc
            ,lft.dtapurac
            ,lft.nrdconta
            ,lft.rowid
            ,lft.cdcooper
            ,lft.nrautdoc
            ,lft.cdorigem
            ,lft.nrseqdig
            ,lft.idsicred
            ,lft.cdhistor
            ,lft.progress_recid
            ,scn.dsnomcnv
            ,scn.cdempres
            ,reg.idremessa
            ,reg.cdempresa_documento
            ,reg.cdreprocessamento
        FROM tbconv_registro_remessa_pagfor reg
            ,craplft lft
            ,crapscn scn
       WHERE reg.cdreprocessamento IN (1,2)
         AND lft.dtvencto BETWEEN (pr_dtmvtocd - 30) AND pr_dtmvtocd   --5
         AND lft.idsicred  = reg.idsicredi
         AND lft.insitfat  = 1
         AND lft.cdhistor IN (3464,3465)
         AND scn.cdempres  = reg.cdempresa_documento
    ORDER BY reg.idsicredi; /* SICREDI */


    -- Buscar nome do cooperado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Buscar Autenticacoes dos lançamentos de Tributos Pagos
    CURSOR cr_crapaut (pr_cdcooper IN crapaut.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapaut.dtmvtolt%TYPE
                      ,pr_cdagenci IN crapaut.cdagenci%TYPE
                      ,pr_nrsequen IN crapaut.nrsequen%TYPE
                      ,pr_nrdocmto IN crapaut.nrdocmto%TYPE
                      ,pr_vldocmto IN crapaut.vldocmto%TYPE) IS
      SELECT aut.*
        FROM crapaut aut
       WHERE aut.cdcooper = pr_cdcooper
         AND aut.dtmvtolt = pr_dtmvtolt
         AND aut.cdagenci = pr_cdagenci
         AND aut.nrsequen = pr_nrsequen
         AND aut.nrdocmto = pr_nrdocmto
         AND aut.vldocmto = pr_vldocmto;
    rw_crapaut cr_crapaut%ROWTYPE;

    -- Buscar informacoes da cooperativa
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nrctasic
            ,cop.cdagebcb
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = DECODE(pr_cdcooper, 3,cop.cdcooper, pr_cdcooper)
       ORDER BY cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN

    -- Buscar data do sistema
    -- Verifica se a cooperativa esta cadastrada
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    END IF;
    CLOSE btch0001.cr_crapdat;

    -- Cód. convênio Pagfor
    vr_cdcnvpfo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'CONVENIO_RFB');

    vr_cdagectl := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'RFB_AGENCIA_ARQ');

    -- Nome dos arquivo temporário
    vr_nmarquiv_tmp := 'ARQ_RFB_' || to_char(SYSDATE, 'SSSSS');
 
    --Buscar diretorio da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                        ,pr_cdcooper => 3
                                        ,pr_nmsubdir => '/arq');
 
    -- Abre arquivo de remessa
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto       --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv_tmp       --> Nome do arquivo
                            ,pr_tipabert => 'W'               --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_hand_arq       --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);     --> Retorno da critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  
    FOR rw_craplft IN cr_craplft(pr_dtmvtocd => rw_crapdat.dtmvtocd) LOOP

      -- Verifica se o convenio está desativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => pr_cdcooper, pr_cdempres => TRIM(rw_craplft.cdempresa_documento)) = 0 THEN
         CONTINUE;
      END IF;
       
      IF nvl(rw_craplft.idanafrd,0) > 0 THEN
        -- Verificar se está aprovado pelo OFSAA
        AFRA0001.pc_ret_sit_analise_fraude(pr_idanafra => rw_craplft.idanafrd
                                          ,pr_cdparece => vr_cdparece
                                          ,pr_dscritic => vr_dscritic);

        IF vr_cdparece <> 1 THEN
          CONTINUE;
        END IF;
      END IF;

      vr_cdempcon  := rw_craplft.cdempcon;
      
      IF vr_cdempcon = 0 THEN
         vr_cdempcon := '100';
      END IF;   
      
      -- Localiza a cooperativa
      OPEN cr_crapcop(pr_cdcooper => rw_craplft.cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
         CLOSE cr_crapcop;
         vr_dscritic:= 'Erro. Cooperativa nao localizada: '|| to_char(rw_craplft.cdcooper);
         -- Levantar exceção
         RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapcop;

      -- Verifica se possui a autenticacao
      OPEN cr_crapaut(pr_cdcooper => rw_craplft.cdcooper
                     ,pr_dtmvtolt => rw_craplft.dtmvtolt
                     ,pr_cdagenci => rw_craplft.cdagenci
                     ,pr_nrsequen => rw_craplft.nrautdoc
                     ,pr_nrdocmto => rw_craplft.nrseqdig
                     ,pr_vldocmto => (rw_craplft.vllanmto +
                                      rw_craplft.vlrmulta +
                                      rw_craplft.vlrjuros));
      FETCH cr_crapaut INTO rw_crapaut;
      -- Se não encontrar
      IF cr_crapaut%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapaut;

         -- Fechar os arquivos
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);

         -- Busca ambiente conectado
         vr_database := GENE0001.fn_database_name;
         vr_dsambien := CASE WHEN instr(upper(vr_database),'P',1) > 0 THEN 'P.' ELSE 'H.' END;

         IF    vr_cdempcon IN ('64','100','153') THEN 
               -- DARF NAO NUMERADO = DARF 064 (cb), DARF 100 (sb) e DARF 153 (cb)
               vr_dstptrib := 'DNN.';
         ELSIF vr_cdempcon = '385' THEN 
               -- DARF NUMERADO = DARF 385 (cb)
               vr_dstptrib := 'DNU.';
         ELSIF vr_cdempcon = '328' THEN 
               -- DAS 328 (cb) - Simples Nacional
               vr_dstptrib := 'DAS.';
         ELSIF vr_cdempcon = '432' THEN 
               -- DAE 432 (cb) - Arrecadação Estadual
               vr_dstptrib := 'DAE.';
         ELSE      
               vr_dstptrib := 'NNN.';
         END IF;

         vr_dsreproc := CASE WHEN vr_cdreproc = 1 THEN 'CO.' ELSE 'CA.' END;

         vr_nmarquiv := 'RFB.' || vr_dsambien || vr_dstptrib || trim(to_char(vr_cdempcon, '000')) || '.' || '99999' || '.' || vr_dsreproc ||'PP.'|| to_char(SYSDATE, 'YYYYMMDD')||'.REM_ERRO';

         -- Comando para renomear nome do arquivo temporário para o nome final
         vr_comando:= 'mv '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' '|| vr_nmdireto || '/' || vr_nmarquiv || ' 2> /dev/null';

         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
            -- Levantar exceção
            RAISE vr_exc_erro;
         END IF;

         -- Montar mensagem de critica
         vr_dscritic := 'Autenticacao nao encontrada. Cooperativa: ' || to_char(rw_craplft.cdcooper) ||
                        ' Conta: ' || to_char(rw_craplft.nrdconta);

         pc_envia_email_erro(pr_conteudo => vr_dscritic,
                             pr_nmarquiv => vr_nmdireto || '/' || vr_nmarquiv,
                             pr_nmrotina => 'pc_reenvia_arquivos_cb_rfb_lft',
                             pr_dscritic => vr_dscriti2);
         RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapaut;

      IF  vr_flgfirst THEN
          -- Cabeçalho do arquivo CSV - DARF Normal
          IF  TRIM(rw_craplft.cdbarras) IS NULL THEN  -- DARF Sem Barras
              vr_dslinreg := 'CODIGO_EMPRESA;NOME_CONVENIOS;DATA_ARRECADACAO;VALOR_ARRECADACAO;NOME_CONTRIBUINTE;CODIGO_RECEITA;' ||
                             'TIPO_IDENTIFICACAO_CONTRIBUINTE;IDENTIFICACAO_CONTRIBUINTE;IDENTIFICACAO_TRIBUTO;PERIODO;NUMERO_REFERENCIA;' ||
                             'VALOR_PRINCIPAL;VALOR_MULTA;VALOR_JUROS;DATA_VENCIMENTO;IDENTIFICADOR;AUTENTICACAO;CAIXA;CANAL;BANCO;AGENCIA;DV_AGENCIA';          
          ELSE  -- DARF com barras, DAE e DAS
              vr_dslinreg := 'CODIGO_EMPRESA;NOME_CONVENIOS;DATA_ARRECADACAO;VALOR_ARRECACACAO;CODIGO_BARRAS;IDENTIFICADOR;AUTENTICACAO;CAIXA;CANAL;BANCO;AGENCIA;DV_AGENCIA';
          END IF;
    
          -- Grava linha no arquivo de remessa com codigo de barras
          gene0001.pc_escr_linha_arquivo(vr_hand_arq, vr_dslinreg);
    
          vr_cdempcon  := rw_craplft.cdempcon;
          vr_cdreproc  := rw_craplft.cdreprocessamento;
          vr_idremessa := rw_craplft.idremessa;
          vr_flgfirst  := FALSE;
      END IF;

      /** Verificacao do DV da Agencia Arrecadador - atraves do modulo 11 **/
      CXON0014.pc_verifica_digito (pr_nrcalcul => rw_crapcop.cdagectl   --Numero a ser calculado
                                  ,pr_poslimit => 0                     --Utilizado para validação de dígito adicional de DAS
                                  ,pr_nrdigito => vr_nrdigito);         --Digito verificador

      -- Gera sequencial do identificador Sicredi
      vr_seqident := SICR0003.fn_sequence_pagfor_identi;
      IF rw_craplft.cdagenci = 90 THEN    /* Pagamento feito pela Internet */
         vr_tipopagt := '3';
      ELSE /* Pagamento no Caixa */
         -- 1- Boca de caixa
         vr_tipopagt := '1';
      END IF;

      -- Verifica se ha codigo de barras duplicados no envio do arquivo  
      IF  TRIM(rw_craplft.cdbarras) IS NOT NULL THEN

          vr_dsbarras_duplicado := fn_retorna_barras_duplicado_lft(pr_cdbarras       => rw_craplft.cdbarras,
                                                                   pr_progress_recid => rw_craplft.progress_recid);

          IF  NVL(vr_dsbarras_duplicado,' ') <> ' ' THEN  
              -- Codigo de Barras Duplicado, fecha o arq. e envia msg de erro
              -- Fechar os arquivos
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);

              -- Busca ambiente conectado
              vr_database := GENE0001.fn_database_name;
              vr_dsambien := CASE WHEN instr(upper(vr_database),'P',1) > 0 THEN 'P.' ELSE 'H.' END;

              IF    vr_cdempcon IN ('64','100','153') THEN 
                    -- DARF NAO NUMERADO = DARF 064 (cb), DARF 100 (sb) e DARF 153 (cb)
                    vr_dstptrib := 'DNN.';
              ELSIF vr_cdempcon = '385' THEN 
                    -- DARF NUMERADO = DARF 385 (cb)
                    vr_dstptrib := 'DNU.';
              ELSIF vr_cdempcon = '328' THEN 
                    -- DAS 328 (cb) - Simples Nacional
                    vr_dstptrib := 'DAS.';
              ELSIF vr_cdempcon = '432' THEN 
                    -- DAE 432 (cb) - Arrecadação Estadual
                    vr_dstptrib := 'DAE.';
              ELSE      
                    vr_dstptrib := 'NNN.';
              END IF;         

              vr_dsreproc := CASE WHEN vr_cdreproc = 1 THEN 'CO.' ELSE 'CA.' END;

              vr_nmarquiv := 'RFB.' || vr_dsambien || vr_dstptrib || trim(to_char(vr_cdempcon, '000')) || '.' || '99999' || '.' || vr_dsreproc ||'PP.'|| to_char(SYSDATE, 'YYYYMMDD')||'.REM_ERRO';

              -- Comando para renomear nome do arquivo temporário para o nome final
              vr_comando:= 'mv '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' '|| vr_nmdireto || '/' || vr_nmarquiv || ' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                   ,pr_des_comando => vr_comando
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);

              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
                 vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
                 -- Levantar exceção
                 RAISE vr_exc_erro;
              END IF;

              -- Montar mensagem de critica
              vr_dscritic := 'Codigo de Barras Duplicado . Cooperativa: ' || to_char(rw_craplft.cdcooper) ||
                             ' Conta: ' || to_char(rw_craplft.nrdconta) || ' com o Tributo '||vr_dsbarras_duplicado;              

              pc_envia_email_erro(pr_conteudo => vr_dscritic,
                                  pr_nmarquiv => vr_nmdireto || '/' || vr_nmarquiv,
                                  pr_nmrotina => 'pc_reenvia_arquivos_cb_rfb_lft',
                                  pr_dscritic => vr_dscriti2);
              RAISE vr_exc_erro;
          END IF;
      END IF;


      IF  TRIM(rw_craplft.cdbarras) IS NULL THEN
          -- Se foi informado o número da conta
          IF rw_craplft.nrdconta > 0 THEN
             OPEN cr_crapass(pr_cdcooper => rw_craplft.cdcooper
                            ,pr_nrdconta => rw_craplft.nrdconta);
             FETCH cr_crapass INTO rw_crapass;

             IF cr_crapass%NOTFOUND THEN
                vr_nmprimtl := 'AILOS';
             ELSE
                vr_nmprimtl := rw_crapass.nmprimtl;
             END IF;
             -- Fechar cursor
             CLOSE cr_crapass;
          ELSE
             vr_nmprimtl := 'AILOS';
          END IF;

          vr_dslinreg := 'D0100'                                           || ';' || -- CODIGO_EMPRESA;
                         to_char(rw_craplft.dsnomcnv)                      || ';' || -- NOME_CONVENIOS;
                         to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')         || ';' || -- DATA_ARRECADACAO;
                         to_char((rw_craplft.vllanmto +
                                  rw_craplft.vlrmulta +
                                  rw_craplft.vlrjuros) * 100)              || ';' || -- VALOR_ARRECADACAO;
                         SUBSTR(vr_nmprimtl,1,30)                          || ';' || -- NOME_CONTRIBUINTE;
                         to_char(rw_craplft.cdtribut)                      || ';' || -- CODIGO_RECEITA;
                         (CASE
                            WHEN length(rw_craplft.nrcpfcgc) = 14 THEN '1'
                            ELSE '2'
                          END)                                             || ';' || -- TIPO_IDENTIFICACAO_CONTRIBUINTE;
                         to_char(rw_craplft.nrcpfcgc)                      || ';' || -- IDENTIFICACAO_CONTRIBUINTE;
                         '16'                                              || ';' || -- IDENTIFICACAO_TRIBUTO;
                         to_char(rw_craplft.dtapurac, 'DD/MM/RRRR')        || ';' || -- PERIODO;
                         to_char(rw_craplft.nrrefere)                      || ';' || -- NUMERO_REFERENCIA
                         to_char(rw_craplft.vllanmto * 100)                || ';' || -- VALOR_PRINCIPAL;
                         to_char(rw_craplft.vlrmulta * 100)                || ';' || -- VALOR_MULTA;
                         to_char(rw_craplft.vlrjuros * 100)                || ';' || -- VALOR_JUROS;
                         to_char(rw_craplft.dtlimite, 'DD/MM/RRRR')        || ';' || -- DATA_VENCIMENTO;
                         to_char(rw_craplft.idsicred)                      || ';' || -- IDENTIFICADOR;                     
                         LPAD(rw_craplft.nrautdoc,8, '0')                  || ';' || -- AUTENTICACAO
                         to_char(SUBSTR(rw_craplft.nrdolote,3,3))          || ';' || -- CAIXA
                         vr_tipopagt                                       || ';' || -- CANAL
                         to_char(rw_crapcop.cdbcoctl,'FM000')              || ';' || -- BANCO
                         to_char(vr_cdagectl,'FM0000')                     || ';' || -- AGENCIA    
                         to_char(vr_nrdigito);                                       -- DV AGENCIA    
 
      ELSE
          -- Gera linha para o arquivo de remessa com codigo de barras
          vr_dslinreg := to_char(rw_craplft.cdempres)              || ';' || -- CODIGO_EMPRESA
                         to_char(rw_craplft.dsnomcnv)              || ';' || -- NOME_CONVENIOS
                         to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR') || ';' || -- DATA_ARRECADACAO
                         to_char(rw_craplft.vllanmto * 100)        || ';' || -- VALOR_ARRECACACAO
                         to_char(rw_craplft.cdbarras)              || ';' || -- CODIGO_BARRAS
                         to_char(rw_craplft.idsicred)              || ';' || -- IDENTIFICADOR    
                         LPAD(rw_craplft.nrautdoc,8, '0')          || ';' || -- AUTENTICACAO
                         to_char(SUBSTR(rw_craplft.nrdolote,3,3))  || ';' || -- CAIXA
                         vr_tipopagt                               || ';' || -- CANAL
                         to_char(rw_crapcop.cdbcoctl,'FM000')      || ';' || -- BANCO
                         to_char(vr_cdagectl,'FM0000')             || ';' || -- AGENCIA    
                         to_char(vr_nrdigito);                               -- DV AGENCIA    
                         
      END IF;
 
      -- Grava linha no arquivo de remessa com codigo de barras
      gene0001.pc_escr_linha_arquivo(vr_hand_arq, vr_dslinreg);
      -- Atualizar registro para Enviado
      BEGIN
        UPDATE craplft lft
           SET lft.insitfat = 2 -- Enviado
              ,lft.dtdenvio = pr_dtproxim
         WHERE lft.rowid = rw_craplft.rowid;
      EXCEPTION
       WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar craplft: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Armazenar dados do pagamento para registro na base de dados
      vr_qtdregis := vr_qtdregis + 1;
      IF  TRIM(rw_craplft.cdbarras) IS NULL THEN
        vr_vlrarrec := vr_vlrarrec + (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
      ELSE
        vr_vlrarrec := vr_vlrarrec + rw_craplft.vllanmto;  
      END IF;
      
      vr_index := vr_tab_itens_remessa.count() + 1;
      vr_tab_itens_remessa(vr_index).idsicredi                := rw_craplft.idsicred;
      vr_tab_itens_remessa(vr_index).vlrpagamento             := (rw_craplft.vllanmto + rw_craplft.vlrmulta + rw_craplft.vlrjuros);
      vr_tab_itens_remessa(vr_index).cdcooper                 := rw_craplft.cdcooper;
      vr_tab_itens_remessa(vr_index).nrdconta                 := rw_craplft.nrdconta;
      vr_tab_itens_remessa(vr_index).cdagenci                 := rw_craplft.cdagenci;
      vr_tab_itens_remessa(vr_index).nrdolote                 := rw_craplft.nrdolote;
      vr_tab_itens_remessa(vr_index).cdhistor                 := rw_craplft.cdhistor;
      vr_tab_itens_remessa(vr_index).cdempresa_documento      := rw_craplft.cdempres;
      vr_tab_itens_remessa(vr_index).nrautenticacao_documento := rw_craplft.nrautdoc;

      IF rw_craplft.cdempcon IN (64,153,100,385) THEN
         vr_tab_itens_remessa(vr_index).tppagamento           := 2;
      ELSIF rw_craplft.cdempcon IN (328,432) THEN   
         vr_tab_itens_remessa(vr_index).tppagamento           := 3;
      END IF;

    END LOOP;
    
    -- Fechar os arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);

    -- Se arquivo estiver vazio
    IF vr_qtdregis = 0 THEN
      -- Se nome do diretório e nome do arquivo foram informados
      IF TRIM(vr_nmdireto) IS NOT NULL AND
         TRIM(vr_nmarquiv_tmp) IS NOT NULL THEN
        -- Comando para remover arquivo vazio
        vr_comando:= 'rm '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
    ELSE
      -- Obter sequencial arquivo
      vr_dsseqarq := TRIM(to_char(SICR0003.fn_sequence_pagfor_arq(rw_crapdat.dtmvtocd),'00000'));
            
      -- Montar nome do arquivo
      -- Busca ambiente conectado
      vr_database := GENE0001.fn_database_name;
      vr_dsambien := CASE WHEN instr(upper(vr_database),'P',1) > 0 THEN 'P.' ELSE 'H.' END;

      IF    vr_cdempcon IN ('64','100','153') THEN 
            -- DARF NAO NUMERADO = DARF 064 (cb), DARF 100 (sb) e DARF 153 (cb)
            vr_dstptrib := 'DNN.';
      ELSIF vr_cdempcon = '385' THEN 
            -- DARF NUMERADO = DARF 385 (cb)
            vr_dstptrib := 'DNU.';
      ELSIF vr_cdempcon = '328' THEN 
            -- DAS 328 (cb) - Simples Nacional
            vr_dstptrib := 'DAS.';
      ELSIF vr_cdempcon = '432' THEN 
            -- DAE 432 (cb) - Arrecadação Estadual
            vr_dstptrib := 'DAE.';
      ELSE      
            vr_dstptrib := 'NNN.';
      END IF;         

      vr_dsreproc := CASE WHEN vr_cdreproc = 1 THEN 'CO.' ELSE 'CA.' END;

      vr_nmarquiv := 'RFB.' || vr_dsambien || vr_dstptrib || trim(to_char(vr_cdempcon, '000')) || '.' || vr_dsseqarq || '.' || vr_dsreproc ||'PP.'|| to_char(SYSDATE, 'YYYYMMDD')||'.REM';

      BEGIN
         UPDATE tbconv_remessa_pagfor rem
            SET rem.dtmovimento              = rw_crapdat.dtmvtocd,
                rem.dhenvio_remessa          = SYSDATE,
                rem.nmarquivo                = vr_nmarquiv,
                rem.nrsequencia_arquivo      = vr_dsseqarq,
                rem.qtdregistros             = vr_qtdregis,
                rem.vlrarrecadacao           = vr_vlrarrec,
                rem.cdstatus_remessa         = 1, -- Remessa Enviada com Sucesso
                rem.cdstatus_retorno         = 1, -- Aguardando Retorno
                rem.flgocorrencia            = 0, -- Sem Ocorrência de Rejeição
                rem.cdagente_arrecadacao     = 4, -- 4-RFB
                rem.nmarquivo_serpro         = '',
                rem.dhenvio_remessa_serpro   = NULL,
                rem.cdstatus_remessa_serpro  = 0
          WHERE rem.idremessa = vr_idremessa;
      EXCEPTION
         WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar registro da remessa na tbconv_remessa_pagfor. ID Remessa: ' ||
                             vr_idremessa  || '. ' || SQLERRM;
              RAISE vr_exc_erro;
      END;

      FOR vr_item IN vr_tab_itens_remessa.first .. vr_tab_itens_remessa.last LOOP

          BEGIN
             UPDATE tbconv_registro_remessa_pagfor reg
                SET reg.cdstatus_processamento              = 1,  -- Retorno Pendente
                    reg.dhinclusao_processamento            = SYSDATE,
                    reg.nmarquivo_inclusao                  = vr_nmarquiv
              WHERE reg.idsicredi = vr_tab_itens_remessa(vr_item).idsicredi;
          EXCEPTION
              WHEN OTHERS THEN
                   pr_dscritic := 'Erro ao atualizar registro da remessa na tbconv_registro_remessa_pagfor. ID Remessa: ' ||
                                  vr_tab_itens_remessa(vr_item).idsicredi  || '. ' || SQLERRM;
                   RAISE vr_exc_erro;
           END;
       END LOOP;

      -- Comando para renomear nome do arquivo temporário para o nome final
      vr_comando:= 'mv '|| vr_nmdireto || '/' || vr_nmarquiv_tmp ||' '|| vr_nmdireto || '/' || vr_nmarquiv ||' 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;

      -- Diretório para Connect Direct consumir arquivo e encaminhar remessa para TIVIT
      vr_dsdirenv := gene0001.fn_param_sistema('CRED',0,'DIR_TIVIT_CONNECT_ENV');    
              
      -- Comando para copiar o arquivo para a pasta de envio para o Connect
      vr_comando:= 'cp '||vr_nmdireto||'/'||vr_nmarquiv||' '||vr_dsdirenv||' 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
      -- Levantar exceção
         RAISE vr_exc_erro;
      END IF;

      -- Retorna nome do arquivo
      pr_nmarquiv := vr_nmarquiv;
    END IF;

    -- Efetuar commit
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se crítica possui código sem descrição
      IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Atribuir crítica de retorno
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Se arquivo está aberto
      IF utl_file.IS_OPEN(vr_hand_arq) THEN
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);
      END IF;

      pc_envia_email_erro(pr_conteudo => pr_dscritic,
                          pr_nmarquiv => '',
                          pr_nmrotina => 'pc_reenvia_arquivos_cb_rfb_lft',
                          pr_dscritic => vr_dscritic);
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Setar crítica não tratada
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || SQLERRM;

      -- Se arquivo está aberto
      IF utl_file.IS_OPEN(vr_hand_arq) THEN
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hand_arq);
      END IF;

      pc_envia_email_erro(pr_conteudo => pr_dscritic,
                          pr_nmarquiv => '',
                          pr_nmrotina => 'pc_reenvia_arquivos_cb_rfb_lft',
                          pr_dscritic => vr_dscritic);

      -- Efetuar rollback
      ROLLBACK;
  END pc_reenvia_arquivos_cb_rfb_lft;



  PROCEDURE pc_gera_arquivos_rfb(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_cdcritic OUT PLS_INTEGER           --> Codigo de Erro
                                ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro

      ------------------------- VARIAVEIS DE EXCEÇÃO ------------------------------
      vr_cdcritic PLS_INTEGER;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_tab_erro gene0001.typ_tab_erro;
      vr_exc_erro EXCEPTION;

      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_nmprogra    VARCHAR2(30) := 'PC_GERA_ARQUIVOS_RFB';
      vr_des_assunto VARCHAR2(500);
      vr_email_dest  crapprm.dsvlrprm%TYPE;
      vr_conteudo    VARCHAR2(4000);
      vr_dsdirarq    VARCHAR2(1000);
      vr_dsdirslv    VARCHAR2(1000);
      vr_dsdirenv    VARCHAR2(1000);
      vr_dtproxim    DATE;
      vr_qtdregis    INTEGER := 0;

      -- Variaveis de controle de comandos shell
      vr_comando     VARCHAR2(500);
      vr_typ_saida   VARCHAR2(1000);
      
      -- Arquivos
      vr_lsarquiv        VARCHAR2(4000);
      vr_lsarquiv_tivit  VARCHAR2(4000);
      vr_nmarq_cb        VARCHAR2(50); -- DARF/DAS/Contas de consumo com código de barras
      vr_nmarq_darf_sb   VARCHAR2(50); -- DARF Sem código de barras
      vr_lsarquiv_split  gene0002.typ_split;
      vr_nmarquiv        VARCHAR2(100);
      vr_dsdireto        VARCHAR2(100);

      -- Buscar informacoes dos feriados
      CURSOR cr_crapfer (pr_cdcooper crapfer.cdcooper%TYPE
                        ,pr_dtrepass crapfer.dtferiad%TYPE) IS
        SELECT 1
          FROM crapfer fer
         WHERE fer.cdcooper = pr_cdcooper
           AND fer.dtferiad = pr_dtrepass;
      rw_crapfer cr_crapfer%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Informar acesso
      gene0001.pc_informa_acesso(pr_module => 'CONV0003');
      
      -- Buscar data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      vr_dtproxim := rw_crapdat.dtmvtopr + 1;

      --Procura pela proxima data */
      WHILE TRUE
      LOOP
        OPEN cr_crapfer(pr_cdcooper => pr_cdcooper
                       ,pr_dtrepass => vr_dtproxim);
        FETCH cr_crapfer INTO rw_crapfer;
        -- Verifica se é feriado ou final de semana
        IF to_char(vr_dtproxim,'d') NOT IN (1,7) AND
           cr_crapfer%NOTFOUND THEN
          CLOSE cr_crapfer;
          EXIT;
        END IF;
        CLOSE cr_crapfer;
        -- Acrescenta data
        vr_dtproxim := vr_dtproxim + 1;
      END LOOP;  -- Fim do DO WHILE TRUE

      -- Buscar diretório dos arquivos gerados
      vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3, pr_nmsubdir => '/arq');

      --------- DARF/DAS/DAE EXCLUSIVO DO RFB ---------

      ------- REENVIO DE CORRECOES E CANCELAMENTOS --------          
/*      pc_reenvia_arquivos_cb_rfb_lft(pr_cdcooper => pr_cdcooper   --> Cooperativa
                                    ,pr_dtproxim => vr_dtproxim   --> Próxima data útil
                                    ,pr_nmarquiv => vr_nmarq_cb   --> Nome do arquivo de remessa de Convenio
                                    ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                                    ,pr_dscritic => vr_dscritic); --> Descrição da crítica

      -- Verificar se retornou alguma crítica
      IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
         vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

         --Gerar erro
         GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => 1 -- cdagenci
                              ,pr_nrdcaixa => 1 -- nrdcaixa
                              ,pr_nrsequen => 1 -- sequencia
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              ,pr_tab_erro => vr_tab_erro);

         -- Limpar as variáveis de crítica
         vr_cdcritic := 0;
         vr_dscritic := '';
      END IF;
*/
      -- Verifica se o convenio está ativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => 0, pr_cdempres => 'D0064') = 1 THEN

         -- DARF 64
         pc_gera_arquivos_cb_rfb(pr_cdcooper => pr_cdcooper   --> Cooperativa
                                ,pr_dtproxim => vr_dtproxim   --> Próxima data útil
                                ,pr_qtdregis => vr_qtdregis   --> Quantidade de registros processados
                                ,pr_cdempcon => 64            --> Codigo da empresa convenio
                                ,pr_cdsegmto => 5             --> Codigo do segmento do convenio
                                ,pr_flbarras => 1             --> Indicador de Há Codigo de Barras (0=Não/1=Tem) 
                                ,pr_nmarquiv => vr_nmarq_cb   --> Nome do arquivo de remessa de Convenio
                                ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                                ,pr_dscritic => vr_dscritic); --> Descrição da crítica

         -- Verificar se retornou alguma crítica
         IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

            --Gerar erro
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 1 /* cdagenci */
                                 ,pr_nrdcaixa => 1 /* nrdcaixa */
                                 ,pr_nrsequen => 1 /* sequencia */
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);

            -- Limpar as variáveis de crítica
            vr_cdcritic := 0;
            vr_dscritic := '';
         END IF;
      END IF;

      -- Verifica se o convenio está ativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => 0, pr_cdempres => 'D0100') = 1 THEN

        -- DARF 100
        pc_gera_arquivos_cb_rfb(pr_cdcooper => pr_cdcooper      --> Cooperativa
                               ,pr_dtproxim => vr_dtproxim      --> Próxima data útil
                               ,pr_qtdregis => vr_qtdregis      --> Quantidade de registros processados
                               ,pr_cdempcon => 100              --> Codigo da empresa convenio
                               ,pr_cdsegmto => 5                --> Codigo do segmento do convenio
                               ,pr_flbarras => 0                --> Indicador de Há Codigo de Barras (0=Não/1=Tem)
                               ,pr_nmarquiv => vr_nmarq_darf_sb --> Nome do arquivo de remessa de Convenio
                               ,pr_cdcritic => vr_cdcritic      --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic);    --> Descrição da crítica

        -- Verificar se retornou alguma crítica
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

           --Gerar erro
           GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => 1 /* cdagenci */
                                ,pr_nrdcaixa => 1 /* nrdcaixa */
                                ,pr_nrsequen => 1 /* sequencia */
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

           -- Limpar as variáveis de crítica
           vr_cdcritic := 0;
           vr_dscritic := '';
        END IF;
      END IF;
      
      -- Verifica se o convenio está ativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => 0, pr_cdempres => 'D0153') = 1 THEN

        -- DARF 153
        pc_gera_arquivos_cb_rfb(pr_cdcooper => pr_cdcooper   --> Cooperativa
                               ,pr_dtproxim => vr_dtproxim   --> Próxima data útil
                               ,pr_qtdregis => vr_qtdregis   --> Quantidade de registros processados
                               ,pr_cdempcon => 153           --> Codigo da empresa convenio
                               ,pr_cdsegmto => 5             --> Codigo do segmento do convenio
                               ,pr_flbarras => 1             --> Indicador de Há Codigo de Barras (0=Não/1=Tem)
                               ,pr_nmarquiv => vr_nmarq_cb   --> Nome do arquivo de remessa de Convenio
                               ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic); --> Descrição da crítica

        -- Verificar se retornou alguma crítica
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

           --Gerar erro
           GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => 1 /* cdagenci */
                                ,pr_nrdcaixa => 1 /* nrdcaixa */
                                ,pr_nrsequen => 1 /* sequencia */
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

           -- Limpar as variáveis de crítica
           vr_cdcritic := 0;
           vr_dscritic := '';
        END IF;
      END IF;
      
      -- Verifica se o convenio está ativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => 0, pr_cdempres => 'D0385') = 1 THEN

        -- DARF 385
        pc_gera_arquivos_cb_rfb(pr_cdcooper => pr_cdcooper   --> Cooperativa
                               ,pr_dtproxim => vr_dtproxim   --> Próxima data útil
                               ,pr_qtdregis => vr_qtdregis   --> Quantidade de registros processados
                               ,pr_cdempcon => 385           --> Codigo da empresa convenio
                               ,pr_cdsegmto => 5             --> Codigo do segmento do convenio
                               ,pr_flbarras => 1             --> Indicador de Há Codigo de Barras (0=Não/1=Tem) 
                               ,pr_nmarquiv => vr_nmarq_cb   --> Nome do arquivo de remessa de Convenio
                               ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic); --> Descrição da crítica

        -- Verificar se retornou alguma crítica
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

           --Gerar erro
           GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => 1 /* cdagenci */
                                ,pr_nrdcaixa => 1 /* nrdcaixa */
                                ,pr_nrsequen => 1 /* sequencia */
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

           -- Limpar as variáveis de crítica
           vr_cdcritic := 0;
           vr_dscritic := '';
        END IF;
      END IF;
      
      -- Verifica se o convenio está ativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => 0, pr_cdempres => 'D0328') = 1 THEN
      
        -- DAS 328
        pc_gera_arquivos_cb_rfb(pr_cdcooper => pr_cdcooper   --> Cooperativa
                               ,pr_dtproxim => vr_dtproxim   --> Próxima data útil
                               ,pr_qtdregis => vr_qtdregis   --> Quantidade de registros processados
                               ,pr_cdempcon => 328           --> Codigo da empresa convenio
                               ,pr_cdsegmto => 5             --> Codigo do segmento do convenio
                               ,pr_flbarras => 1             --> Indicador de Há Codigo de Barras (0=Não/1=Tem) 
                               ,pr_nmarquiv => vr_nmarq_cb   --> Nome do arquivo de remessa de Convenio
                               ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic); --> Descrição da crítica

        -- Verificar se retornou alguma crítica
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

           --Gerar erro
           GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => 1 /* cdagenci */
                                ,pr_nrdcaixa => 1 /* nrdcaixa */
                                ,pr_nrsequen => 1 /* sequencia */
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

           -- Limpar as variáveis de crítica
           vr_cdcritic := 0;
           vr_dscritic := '';
        END IF;
      END IF;

      -- Verifica se o convenio está ativado para a RFB
      IF fn_verifica_convenio_ativo(pr_cdcooper => 0, pr_cdempres => 'D0432') = 1 THEN

        -- DAE 432
        pc_gera_arquivos_cb_rfb(pr_cdcooper => pr_cdcooper   --> Cooperativa
                               ,pr_dtproxim => vr_dtproxim   --> Próxima data útil
                               ,pr_qtdregis => vr_qtdregis   --> Quantidade de registros processados
                               ,pr_cdempcon => 432           --> Codigo da empresa convenio
                               ,pr_cdsegmto => 5             --> Codigo do segmento do convenio
                               ,pr_flbarras => 1             --> Indicador de Há Codigo de Barras (0=Não/1=Tem) 
                               ,pr_nmarquiv => vr_nmarq_cb   --> Nome do arquivo de remessa de Convenio
                               ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic); --> Descrição da crítica

        -- Verificar se retornou alguma crítica
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           vr_dscritic := 'Erro Arquivo Segmento O (Com Barras): ' || vr_dscritic;

           --Gerar erro
           GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => 1 /* cdagenci */
                                ,pr_nrdcaixa => 1 /* nrdcaixa */
                                ,pr_nrsequen => 1 /* sequencia */
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => vr_tab_erro);

           -- Limpar as variáveis de crítica
           vr_cdcritic := 0;
           vr_dscritic := '';
        END IF;
      END IF;


      -- Listar arquivos para o anexo
      IF TRIM(vr_nmarq_cb)        IS NOT NULL THEN  vr_lsarquiv       := vr_lsarquiv        || vr_dsdirarq || '/' || vr_nmarq_cb        || ';'; END IF; -- DARF/DAS/DAE
      IF TRIM(vr_nmarq_darf_sb)   IS NOT NULL THEN  vr_lsarquiv_tivit := vr_lsarquiv_tivit  || vr_dsdirarq || '/' || vr_nmarq_darf_sb   || ';'; END IF; -- DARF Normal sem barras

      -- Se foi gerado algum arquivo de remessa
      IF TRIM(vr_lsarquiv) IS NOT NULL THEN
        -- Remover último ';'
        vr_lsarquiv := substr(vr_lsarquiv,1,LENGTH(vr_lsarquiv)-1);
        -- Separa os arquivos
        vr_lsarquiv_split := gene0002.fn_quebra_string(pr_string => vr_lsarquiv
                                                      ,pr_delimit => ';');

        FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP

          -- Separa diretorio e nmarquivo
          gene0001.pc_separa_arquivo_path(pr_caminho => vr_lsarquiv_split(vr_idx),
                                          pr_direto  => vr_dsdireto,
                                          pr_arquivo => vr_nmarquiv);
                            
          -- Diretório para SOA consumir arquivo e encaminhar remessa para API Bancoob
          vr_dsdirenv := gene0001.fn_param_sistema('CRED',0,'DIR_ENVIA_API_BANCOOB');    
          
          -- Comando para copiar o arquivo para a pasta de envio para SOA consumir
          vr_comando:= 'cp '||vr_dsdirarq||'/'||vr_nmarquiv||' '||vr_dsdirenv||' 2> /dev/null';
          
          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF;
        END LOOP;
      END IF;
        

      ---------------------------- ENVIO DE E-MAIL ----------------------------

      IF TRIM(vr_lsarquiv) IS NOT NULL OR TRIM(vr_lsarquiv_tivit) IS NOT NULL OR vr_tab_erro.count > 0 THEN
        
        -- Concatenar lista de arquivos da TIVIT com demais arquivos
        IF TRIM(vr_lsarquiv) IS NOT NULL AND TRIM(vr_lsarquiv_tivit) IS NOT NULL THEN
          vr_lsarquiv := vr_lsarquiv || ';' || vr_lsarquiv_tivit;
        ELSIF TRIM(vr_lsarquiv) IS NULL AND TRIM(vr_lsarquiv_tivit) IS NOT NULL THEN
          vr_lsarquiv := vr_lsarquiv_tivit;
        END IF;      

        -- Se retornou algum erro
        IF vr_tab_erro.count > 0 THEN
          --Assunto do e-mail
          vr_des_assunto:= 'RFB - Envio dos arquivos de remessa (COM ERROS)';

          -- Conteúdo do e-mail
          vr_conteudo:= 'Arquivos de remessa foram gerados com inconsistencias.<br>OBS: Rotina está sendo executada com integração via API Bancoob/TIVIT.<br><br>' ||
                        'Abaixo lista dos arquivos enviados:<br><br>' ||
                        'Arquivo DARF/DAS/DAE com codigo de barras: ' || (CASE WHEN TRIM(vr_nmarq_cb) IS NULL THEN
                                                  'Nao gerado<br>'
                                                  ELSE
                                                  vr_nmarq_cb || '<br>' END) ||                                             
                        'Arquivo de DARF sem codigo de barras: ' || (CASE WHEN TRIM(vr_nmarq_darf_sb) IS NULL THEN
                                                  'Nao gerado<br>'
                                                  ELSE
                                                  vr_nmarq_darf_sb || '<br>' END) ||
                        '<br>Criticas retornadas:<br><br>';                          

          -- Iterar sobre os erros registrados
          FOR idx in vr_tab_erro.FIRST .. vr_tab_erro.LAST LOOP

            -- Concatenar erros no conteudo do e-mail
            vr_conteudo := vr_conteudo ||
                           nvl(vr_tab_erro(idx).cdcritic, '9999') || ' - ' || vr_tab_erro(idx).dscritic || '.<br>';

          END LOOP;
        ELSE
          --Assunto do e-mail
          vr_des_assunto:= 'RFB - Envio dos arquivos de remessa';

          -- Conteúdo do e-mail
          vr_conteudo:= 'Arquivos de remessa foram gerados com sucesso.<br>OBS: Rotina está sendo executada com integração via API Bancoob/TIVIT.<br><br>' ||
                        'Abaixo lista dos arquivos enviados:<br><br>' ||
                        'Arquivo Contas de consumo: ' ||
                        'Arquivo DARF/DAS/DAE com codigo de barras: ' ||
                        (CASE WHEN TRIM(vr_nmarq_cb) IS NULL THEN
                           'Nao gerado<br>'
                         ELSE
                           vr_nmarq_cb || '<br>' END) ||
                        'Arquivo de DARF sem codigo de barras: ' ||
                        (CASE WHEN TRIM(vr_nmarq_darf_sb) IS NULL THEN
                           'Nao gerado<br>'
                         ELSE
                           vr_nmarq_darf_sb || '<br>' END);
        END IF;

        -- Conteúdo do e-mail
        vr_conteudo := vr_conteudo ||
                       '<br>Data: ' || to_char(SYSDATE,'DD/MM/YYYY') ||
                       '<br>Hora: '|| TO_CHAR(SYSDATE,'HH24:MI:SS');
        --Email Destino
        vr_email_dest:= gene0001.fn_param_sistema('CRED',0,'EMAIL_REM_PAGFOR');

        --Enviar Email
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => vr_nmprogra
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => vr_des_assunto
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => vr_lsarquiv
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);

        -- Verificar se retornou alguma crítica
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;
            
      -- Se foi gerado algum arquivo de remessa
      IF TRIM(vr_lsarquiv) IS NOT NULL THEN        
        -- Diretório salvar da cooperativa
        vr_dsdirslv := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                            ,pr_cdcooper => 3
                                            ,pr_nmsubdir => '/salvar/');

        -- Separa os arquivos
        vr_lsarquiv_split := gene0002.fn_quebra_string(pr_string => vr_lsarquiv
                                                      ,pr_delimit => ';');

        FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP
          
          IF TRIM(vr_lsarquiv_split(vr_idx)) IS NOT NULL THEN 

            -- Separa diretorio e nmarquivo
            gene0001.pc_separa_arquivo_path(pr_caminho => vr_lsarquiv_split(vr_idx),
                                            pr_direto  => vr_dsdireto,
                                            pr_arquivo => vr_nmarquiv);

            -- Comando para mover os arquivos para a pasta salvar
            vr_comando:= 'mv '||vr_dsdirarq||'/'||vr_nmarquiv||' '||vr_dsdirslv||'/'|| vr_nmarquiv || ' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);

            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
              -- Levantar exceção
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se crítica possui código sem descrição
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Atribuir crítica de retorno
        pr_dscritic := vr_dscritic;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_gera_arquivos_rfb',
                            pr_dscritic => vr_dscritic);
      WHEN OTHERS THEN
        -- Setar crítica não tratada
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || SQLERRM;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_gera_arquivos_rfb',
                            pr_dscritic => vr_dscritic);

        -- Controlar geração de log de execução dos jobs
        CECRED.pc_internal_exception(pr_cdcooper => 3);

  END pc_gera_arquivos_rfb;

  PROCEDURE pc_job_envia_remessa_rfb (pr_dscritic OUT VARCHAR2) IS
    
      ------------------------------- CURSORES ------------------------------------
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      ------------------------- VARIAVEIS DE EXCEÇÃO ------------------------------
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;

      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_hrinienv INTEGER;
      vr_hrfimenv INTEGER;
      vr_hrinterv INTEGER;
      vr_dhultexe DATE;
      vr_dhexecuc DATE;
      vr_flgexecu BOOLEAN := FALSE;
      vr_dtmvtolt DATE;
      vr_plnctlpf VARCHAR2(1);

    BEGIN
      -- Verificar se data de execução é dia útil
      vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                              ,pr_dtmvtolt => trunc(SYSDATE));

      -- Executar somente em dias úteis
      IF vr_dtmvtolt <> trunc(SYSDATE) THEN
         RETURN;
      END IF;      

      -- Buscar horário atual de execução
      vr_dhexecuc := SYSDATE;
      -- Buscar horário de início de envio dos arquivos de remessa da RFB
      vr_hrinienv := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => 0
                                                        ,pr_cdacesso => 'HRINI_ENV_REM_RFB'));
      -- Buscar horário final de envio dos arquivos de remessa da RFB
      vr_hrfimenv := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => 0
                                                        ,pr_cdacesso => 'HRFIM_ENV_REM_RFB'));
      -- Buscar tempo de intervalo de envio dos arquivos de remessa da RFB
      vr_hrinterv := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => 0
                                                        ,pr_cdacesso => 'HRINTERV_ENV_REM_RFB'));
      -- Buscar último dia/hora de envio dos arquivos de remessa da RFB
      vr_dhultexe := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                      ,pr_cdcooper => 0
                                                      ,pr_cdacesso => 'DHULT_ENV_REM_RFB'), 'DD/MM/RRRR HH24:MI');

      -- Se horário de execução está entre os horários de início e fim da execução
      IF to_char(vr_dhexecuc,'SSSSS') >= vr_hrinienv AND TO_CHAR(vr_dhexecuc,'SSSSS') <= vr_hrfimenv THEN

         -- Se última execução foi no dia anterior
         IF trunc(vr_dhultexe) < trunc(vr_dhexecuc) THEN
            -- Executar procedimento
            vr_flgexecu := TRUE;
         -- Senão, última execução ocorreu no mesmo dia
         ELSE

            -- Se horário da última execução + intervalo de tempo for menor que horário atual
            IF (vr_dhultexe + vr_hrinterv/1440) <= vr_dhexecuc THEN
              -- Executar procedimento
              vr_flgexecu := TRUE;
            END IF;
         END IF;

         -- Se deve executar envio
         IF vr_flgexecu THEN
            -- Atualizar parâmetro de horário de última execução
            BEGIN
              UPDATE crapprm prm
                 SET prm.dsvlrprm = to_char(vr_dhexecuc, 'DD/MM/RRRR HH24:MI')
               WHERE prm.cdcooper = 0
                 AND prm.nmsistem = 'CRED'
                 AND prm.cdacesso = 'DHULT_ENV_REM_RFB';

              COMMIT;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 9999;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' Erro ao atualizar horário de última execução: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            -- Executar proc para envio dos arquivos
            pc_gera_arquivos_rfb(pr_cdcooper => 3
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

            -- Verificar se retornou alguma crítica
            IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
              -- Levantar exceçao
              RAISE vr_exc_erro;
            END IF;

         END IF;

      END IF;
        
      -- Executar rotina de atualização do registro de resumo das remessas do dia
      -- Nessa chamada não vamos tratar a saída de erro
      -- Somente se estiver arrecadando através da API do Bancoob
      IF vr_plnctlpf = 'C' THEN
         OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
         FETCH btch0001.cr_crapdat INTO rw_crapdat;
         -- Se não encontrar
         IF btch0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_cdcritic := 1;
            RAISE vr_exc_erro;
         END IF;
         CLOSE btch0001.cr_crapdat;          
        
         SICR0003.pc_atualiza_reg_remessa_pagfor (pr_cdcooper => 3
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                                 ,pr_dscritic => vr_dscritic);   

      END IF;
      -- Efetuar commit
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se crítica possui código sem descrição
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Atribuir crítica de retorno
        pr_dscritic := vr_dscritic;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_job_envia_remessa_rfb',
                            pr_dscritic => vr_dscritic);

      WHEN OTHERS THEN
        -- Setar crítica não tratada
        vr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || SQLERRM;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_job_envia_remessa_rfb',
                            pr_dscritic => vr_dscritic);

        -- Controlar geração de log de execução dos jobs
        CECRED.pc_internal_exception(pr_cdcooper => 3);

  END pc_job_envia_remessa_rfb;

  PROCEDURE pc_registra_retorno_serpro(pr_nmdirret   IN VARCHAR2,
                                       pr_nmarqret   IN VARCHAR2,
                                       pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE,
                                       pr_dscritic  OUT VARCHAR2) IS
  -----------------------------------------------------------------
    CURSOR cr_craplft_serpro_com_barras (pr_cdbarras IN craplft.cdbarras%TYPE
                                        ,pr_vllanmto IN craplft.vllanmto%TYPE) IS
      SELECT lft.idsicred
            ,lft.cdempcon
            ,lft.nrcpfcgc
            ,lft.dtapurac
            ,lft.nrdconta
            ,lft.cdcooper
            ,lft.nrautdoc
            ,lft.cdorigem
            ,lft.vllanmto
            ,lft.dtdenvio
            ,lft.vlrmulta
            ,lft.vlrjuros
            ,lft.vlpercen
            ,DECODE(NVL(ass.cdagenci,0),0,lft.cdagenci,ass.cdagenci) cdagenci_coop
            ,reg.idremessa
        FROM tbconv_registro_remessa_pagfor reg
            ,craplft                        lft
            ,crapass                        ass
       WHERE UPPER(lft.cdbarras)       =  UPPER(pr_cdbarras) 
         AND lft.dtmvtolt BETWEEN (pr_dtmvtolt - 5) AND pr_dtmvtolt
         AND lft.cdcooper               = lft.cdcooper
         AND lft.vllanmto + 
             lft.vlrmulta +
             lft.vlrjuros               = pr_vllanmto
         AND reg.idsicredi              = lft.idsicred 
         AND reg.cdstatus_processamento IN (1,2,3)
         AND ass.cdcooper (+)           = lft.cdcooper
         AND ass.nrdconta (+)           = lft.nrdconta;
    rw_craplft_serpro_com_barras cr_craplft_serpro_com_barras%ROWTYPE;

    CURSOR cr_craplft_serpro_cpfcgc (pr_nrcpfcgc IN craplft.nrcpfcgc%TYPE
                                    ,pr_vlltotal IN craplft.vllanmto%TYPE
                                    ,pr_vllprinc IN craplft.vllanmto%TYPE
                                    ,pr_vlrmulta IN craplft.vlrmulta%TYPE
                                    ,pr_vlrjuros IN craplft.vlrjuros%TYPE
                                    ,pr_nrrefere IN craplft.nrrefere%TYPE
                                    ,pr_dtmvtolt IN craplft.dtmvtolt%TYPE
                                    ,pr_dtapurac IN craplft.dtapurac%TYPE
                                    ,pr_dtvencto IN craplft.dtvencto%TYPE) IS
      SELECT lft.idsicred
            ,lft.cdempcon
            ,lft.nrcpfcgc
            ,lft.dtapurac
            ,lft.nrdconta
            ,lft.cdcooper
            ,lft.nrautdoc
            ,lft.cdorigem
            ,lft.vllanmto
            ,lft.dtdenvio
            ,lft.vlrmulta
            ,lft.vlrjuros
            ,lft.vlpercen
            ,DECODE(NVL(ass.cdagenci,0),0,lft.cdagenci,ass.cdagenci) cdagenci_coop
            ,reg.idremessa
        FROM tbconv_registro_remessa_pagfor reg
            ,craplft                        lft
            ,crapass                        ass
       WHERE UPPER(lft.nrcpfcgc)        =  UPPER(TRIM(pr_nrcpfcgc))
         AND lft.dtmvtolt              >= pr_dtmvtolt
         AND lft.dtapurac               = TRUNC(pr_dtapurac)
         AND lft.dtlimite               = TRUNC(pr_dtvencto)
         AND lft.cdcooper               = lft.cdcooper
         AND lft.vllanmto + 
             lft.vlrmulta +
             lft.vlrjuros               = pr_vlltotal
         AND lft.vllanmto               = pr_vllprinc
         AND lft.vlrmulta               = pr_vlrmulta
         AND lft.vlrjuros               = pr_vlrjuros
         AND (pr_nrrefere               IS NULL    
              OR pr_nrrefere            IS NOT NULL 
              AND TRIM(lft.nrrefere)    = pr_nrrefere)
         AND reg.idsicredi              = lft.idsicred 
         AND reg.cdstatus_processamento IN (1,2,3)
         AND ass.cdcooper (+)           = lft.cdcooper
         AND ass.nrdconta (+)           = lft.nrdconta;
    rw_craplft_serpro_cpfcgc cr_craplft_serpro_cpfcgc%ROWTYPE;

    CURSOR cr_registro_remessa_identificar_conv (pr_idsicredi IN tbconv_registro_remessa_pagfor.idsicredi%TYPE) IS
      SELECT rem.cdempresa_documento
        FROM tbconv_registro_remessa_pagfor rem
       WHERE rem.idsicredi  = pr_idsicredi;
    rw_registro_remessa_identificar_conv cr_registro_remessa_identificar_conv%ROWTYPE;

    CURSOR cr_registro_remessa_valida_total (pr_cdempresa_documento IN tbconv_registro_remessa_pagfor.cdempresa_documento%TYPE
                                            ,pr_dtmvtolt IN craplft.dtmvtolt%TYPE) IS
      SELECT COUNT(1) quantidade_total,
             SUM(rem.vlrpagamento) valor_total
        FROM tbconv_registro_remessa_pagfor rem
       WHERE rem.cdempresa_documento = pr_cdempresa_documento
         AND TRUNC(rem.dhinclusao_processamento) = pr_dtmvtolt
         AND rem.cdstatus_processamento = 3;
    rw_registro_remessa_valida_total cr_registro_remessa_valida_total%ROWTYPE;

     
    vr_exc_erro              EXCEPTION;
    vr_exc_erro_valida_total EXCEPTION;
    vr_dhleitura             DATE;
    vr_linha_arq             VARCHAR2(4000);
    vr_qtlinhas              NUMBER := 0;
    vr_handle_arq            utl_file.file_type;
    vr_idremessa             tbconv_remessa_pagfor.idremessa%TYPE;
    vr_idsicredi             craplft.idsicred%TYPE;
    vr_cdbarras              craplft.cdbarras%TYPE;
    vr_vlltotal              craplft.vllanmto%TYPE;
    vr_vlrmulta              craplft.vlrmulta%TYPE;
    vr_vlrjuros              craplft.vlrjuros%TYPE;
    vr_vlrprinc              craplft.vllanmto%TYPE;
    vr_nrcpfcgc              craplft.nrcpfcgc%TYPE;
    vr_nrrefere              craplft.nrrefere%TYPE;
    vr_dtapurac              craplft.dtapurac%TYPE;
    vr_dtvencto              craplft.dtvencto%TYPE;
    vr_dsproces              tbconv_registro_remessa_pagfor.dsprocessamento_serpro%TYPE; 
    vr_flcnfenv              BOOLEAN;
    vr_dsdirrec              VARCHAR2(200);
    vr_comando               VARCHAR2(500);      
    vr_typ_saida             VARCHAR2(1000);
    vr_dscritic              VARCHAR2(4000);
    vr_idremessa_serpro      tbconv_registro_remessa_pagfor.idremessa_serpro%TYPE; 
    vr_cdempresa_documento   tbconv_registro_remessa_pagfor.cdempresa_documento%TYPE;
    vr_quantidade_total      NUMBER(5);
    vr_valor_total           tbconv_registro_remessa_pagfor.vlrpagamento%TYPE;
    vr_erro_validacao_total  BOOLEAN;
    vr_vlrauxiliar           NUMBER(1);      
  BEGIN
    vr_dhleitura        := SYSDATE;
    vr_idremessa        := 0;
    vr_idsicredi        := 0;
    vr_flcnfenv         := FALSE;
    vr_idremessa_serpro := 0;
    pr_dscritic         := '';
    vr_cdempresa_documento  := '';    
    vr_erro_validacao_total := FALSE;
    
    gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmdirret || pr_nmarqret,
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_handle_arq,
                             pr_des_erro => pr_dscritic);

    IF TRIM(pr_dscritic) IS NOT NULL THEN
       pr_dscritic := 'Erro na leitura do arquivo de retorno:  ' || pr_nmarqret ||
                      '. ' || pr_dscritic;
       RAISE vr_exc_erro;
    END IF;

    LOOP
      BEGIN
        gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);

        vr_linha_arq := CONVERT(vr_linha_arq,'US7ASCII','UTF8');
        vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,chr(13),''),chr(10),'');
        vr_qtlinhas  := vr_qtlinhas + 1;

        --Primeira linha do arquivo contém nome dos campos do CSV
        IF vr_qtlinhas = 1 THEN
            IF pr_nmarqret LIKE '%TXOK' OR pr_nmarqret LIKE '%TXNOK' THEN
               vr_flcnfenv := TRUE;     -- Confirmacao do Envio do Arquivo          
               vr_dsproces := vr_linha_arq;
            --Verificar se layout do arquivo está ok quando retorno da SERPRO (via AUTOSCP)
            ELSIF SUBSTR(vr_linha_arq,17,8) <> 'A05438BA'  OR
                  SUBSTR(vr_linha_arq,25,3) <> '085'       THEN
               pr_dscritic := 'Layout invalido ou Banco invalido. Arquivo Retorno: ' || pr_nmarqret || '.';
               RAISE vr_exc_erro;
            END IF;
            
            IF SUBSTR(vr_linha_arq,17,8) = 'A05438BA'  AND
               SUBSTR(vr_linha_arq,25,3) = '085'       THEN
               vr_idremessa_serpro := to_number(SUBSTR(vr_linha_arq,28,4)); 
            END IF;
            
            CONTINUE;
        END IF;

        IF  vr_flcnfenv = TRUE THEN  -- Retorno do Envio da 2a perna
            BEGIN
               UPDATE tbconv_registro_remessa_pagfor reg
                  SET reg.dsprocessamento_serpro          = vr_dsproces,
                      reg.cdstatus_processamento_serpro   = 
                                   (CASE WHEN SUBSTR(vr_dsproces,1,29) = 'RECIBO DE RECEPCAO DE ARQUIVO'  THEN 2 ELSE 1 END)  -- Resposta da SERPRO
                WHERE reg.nmarquivo_inclusao_serpro LIKE SUBSTR(pr_nmarqret,01,39) || '%';
            EXCEPTION
               WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao atualizar registro da registro na tbconv_registro_remessa_pagfo. Arquivo: ' ||
                                   SUBSTR(pr_nmarqret,01,39) || '. ' || SQLERRM;
                    RAISE vr_exc_erro;
            END;

            BEGIN
               UPDATE tbconv_remessa_pagfor rem
                  SET rem.cdstatus_remessa_serpro   = 
                                   (CASE WHEN SUBSTR(vr_dsproces,1,29) = 'RECIBO DE RECEPCAO DE ARQUIVO'  THEN 1 ELSE 2 END),  -- Resposta da SERPRO
                      rem.flgocorrencia_serpro      =
                                   (CASE WHEN SUBSTR(vr_dsproces,1,29) = 'RECIBO DE RECEPCAO DE ARQUIVO'  THEN 0 ELSE 1 END)  -- Resposta da SERPRO
                WHERE rem.nmarquivo_serpro = SUBSTR(pr_nmarqret,01,39);
            EXCEPTION
               WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao atualizar registro da registro na tbconv_remessa_pagfo. Arquivo: ' ||
                                   SUBSTR(pr_nmarqret,01,39) || '. ' || SQLERRM;
                    RAISE vr_exc_erro;
            END;
        END IF;   

        IF  SUBSTR(vr_linha_arq,1,1) <> '9' AND
            vr_flcnfenv = FALSE             THEN   -- Detalhe
            vr_vlltotal := to_number(substr(vr_linha_arq, 130, 15)) / 100;
            vr_nrcpfcgc := TRIM(SUBSTR(vr_linha_arq,18,14)); 
            vr_idremessa := 0;
            vr_idsicredi := 0;
            
            IF  SUBSTR(vr_linha_arq,17,1) <> '4' THEN
                vr_cdbarras := LTRIM(SUBSTR(vr_linha_arq,18,44));
                OPEN cr_craplft_serpro_com_barras(pr_cdbarras => vr_cdbarras, 
                                                  pr_vllanmto => vr_vlltotal);
                FETCH cr_craplft_serpro_com_barras INTO rw_craplft_serpro_com_barras;
                -- Se não encontrar
                IF cr_craplft_serpro_com_barras%NOTFOUND THEN
                   -- Fechar o cursor pois haverá raise
                   CLOSE cr_craplft_serpro_com_barras;

                   pr_dscritic := 'Registro não localizado. Cod. Barras: ' || vr_cdbarras || 
                                  ' CPF/CNPJ:' || vr_nrcpfcgc ||'. Valor: ' || vr_vlltotal;

                   pc_envia_email_erro(pr_conteudo => pr_dscritic,
                                       pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                                       pr_nmrotina => 'pc_registra_retorno_serpro',
                                       pr_dscritic => vr_dscritic);
                   CONTINUE;
                END IF;

                CLOSE cr_craplft_serpro_com_barras;

                vr_idremessa := rw_craplft_serpro_com_barras.idremessa;
                vr_idsicredi := rw_craplft_serpro_com_barras.idsicred;

            ELSE                
                -- Localizacao DARF 100 (sem Barras)
                vr_vlrmulta := to_number(substr(vr_linha_arq, 100, 15)) / 100;
                vr_vlrjuros := to_number(substr(vr_linha_arq, 115, 15)) / 100;
                vr_vlrprinc := to_number(substr(vr_linha_arq,  85, 15)) / 100;
                vr_nrrefere := LTRIM(TRIM(SUBSTR(vr_linha_arq,61,17)),'0'); 
                vr_dtapurac := to_date(TRIM(SUBSTR(vr_linha_arq,40,8)),'DDMMYYYY');
                vr_dtvencto := to_date(TRIM(SUBSTR(vr_linha_arq,32,8)),'DDMMYYYY');
               
                OPEN cr_craplft_serpro_cpfcgc(pr_nrcpfcgc => vr_nrcpfcgc, 
                                              pr_vlltotal => vr_vlltotal,
                                              pr_vllprinc => vr_vlrprinc,
                                              pr_vlrmulta => vr_vlrmulta,
                                              pr_vlrjuros => vr_vlrjuros,
                                              pr_nrrefere => vr_nrrefere,
                                              pr_dtmvtolt => pr_dtmvtolt,
                                              pr_dtapurac => vr_dtapurac,
                                              pr_dtvencto => vr_dtvencto);
                                              
                FETCH cr_craplft_serpro_cpfcgc INTO rw_craplft_serpro_cpfcgc;
                -- Se não encontrar
                IF cr_craplft_serpro_cpfcgc%NOTFOUND THEN
                   -- Fechar o cursor pois haverá raise
                   CLOSE cr_craplft_serpro_cpfcgc;

                   -- Montar mensagem de critica
                   pr_dscritic := 'Registro não localizado. Nr. Referencia: ' || vr_nrrefere || 
                                  ' CPF/CNPJ:' || vr_nrcpfcgc ||'. Valor: ' || vr_vlltotal;

                   pc_envia_email_erro(pr_conteudo => pr_dscritic,
                                       pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                                       pr_nmrotina => 'pc_registra_retorno_serpro',
                                       pr_dscritic => vr_dscritic);
                   CONTINUE;
                END IF;
               
                CLOSE cr_craplft_serpro_cpfcgc;

                vr_idremessa := rw_craplft_serpro_cpfcgc.idremessa;
                vr_idsicredi := rw_craplft_serpro_cpfcgc.idsicred;
               
            END IF;

        
            --verifica se o cursor ficou aberto
            IF cr_craplft_serpro_com_barras%ISOPEN THEN
            CLOSE cr_craplft_serpro_com_barras;
            END IF;
      
            IF  vr_idsicredi = 0 THEN
                vr_idremessa := rw_craplft_serpro_com_barras.idremessa;
                vr_idsicredi := rw_craplft_serpro_com_barras.idsicred;
            END IF;     

            IF vr_flcnfenv = TRUE THEN
               vr_vlrauxiliar := 1;
            ELSE
               vr_vlrauxiliar := 3;   
            END IF;

            BEGIN
               UPDATE tbconv_registro_remessa_pagfor reg
                  SET reg.nmarquivo_inclusao_serpro       = pr_nmarqret,
                      reg.dhinclusao_processamento_serpro = vr_dhleitura,
                     -- Quando Envio 1a perna => Remessa enviada para processamento para SERPRO = 1 OU
                     -- Quando Envio 2a perna => Encaminhado para processamento SERPRO = 3
                      reg.cdstatus_processamento_serpro   = vr_vlrauxiliar,
                      reg.cdreprocessamento               = 0,  -- Remessa Normal
                      reg.idremessa_serpro                = vr_idremessa_serpro 
                WHERE reg.idsicredi = vr_idsicredi;
            EXCEPTION
                WHEN OTHERS THEN
                     pr_dscritic := 'Erro ao atualizar registro da registro na tbconv_registro_remessa_pagfo. ID Sicredi: ' ||
                                    vr_idsicredi || '. ' || SQLERRM;
                     RAISE vr_exc_erro;
            END;
               
            BEGIN
               UPDATE tbconv_remessa_pagfor rem
                  SET rem.nmarquivo_serpro         = pr_nmarqret,
                      rem.dhenvio_remessa_serpro   = vr_dhleitura,
                      rem.cdstatus_remessa_serpro  = 1, -- Enviado com sucesso
                      rem.idremessa_serpro         = vr_idremessa_serpro
                WHERE rem.idremessa = vr_idremessa;
            EXCEPTION
                WHEN OTHERS THEN
                      pr_dscritic := 'Erro ao atualizar registro da remessa na tbconv_remessa_pagfor. ID Remessa: ' ||
                                      vr_idremessa  || '. ' || SQLERRM;
                      RAISE vr_exc_erro;
            END;


            IF  vr_cdempresa_documento IS NULL THEN
                OPEN cr_registro_remessa_identificar_conv(pr_idsicredi => vr_idsicredi);
                FETCH cr_registro_remessa_identificar_conv INTO rw_registro_remessa_identificar_conv;

                IF cr_registro_remessa_identificar_conv%FOUND THEN
                   vr_cdempresa_documento := rw_registro_remessa_identificar_conv.cdempresa_documento;
                END IF;
            
                CLOSE cr_registro_remessa_identificar_conv;
             END IF;


        END IF;
    
        IF  SUBSTR(vr_linha_arq,1,1) = '9' AND    -- Trailer
            vr_idremessa <> 0              AND
            vr_flcnfenv = FALSE            THEN

            -- Valida os Totais do Arquivo com os totais dos lançamentos 
            vr_erro_validacao_total := FALSE;  

            -- Arquivo
            vr_valor_total := TO_NUMBER(SUBSTR(vr_linha_arq, 34, 17)) / 100;
            vr_quantidade_total := TO_NUMBER(SUBSTR(vr_linha_arq,28,06)) - 2 ; 

            -- Totais dos Lançamentos
            OPEN cr_registro_remessa_valida_total (pr_cdempresa_documento => vr_cdempresa_documento, 
                                                   pr_dtmvtolt => pr_dtmvtolt);
            FETCH cr_registro_remessa_valida_total INTO rw_registro_remessa_valida_total; 
            -- Se não encontrar
            IF cr_registro_remessa_valida_total%FOUND THEN
            
               IF  vr_quantidade_total <> rw_registro_remessa_valida_total.quantidade_total OR
                   vr_valor_total <> rw_registro_remessa_valida_total.valor_total THEN
                   vr_erro_validacao_total := TRUE;
               END IF;  
           
            END IF; 
            CLOSE cr_registro_remessa_valida_total;

        END IF;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --Fecha o arquivo se não tem mais linhas para ler
            GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
            EXIT;
      END;
    END LOOP;

    COMMIT;

    -- Fechar os arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);

    IF  vr_erro_validacao_total = TRUE THEN
        vr_dsdirrec := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_SERPRO_ERRO');                                                  
   
        -- Comando para mover os arquivos para a pasta recebidos
        vr_comando:= 'mv '||pr_nmdirret||pr_nmarqret||' '||vr_dsdirrec||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => pr_dscritic);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
           pr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||pr_dscritic;
           -- Levantar exceção
           RAISE vr_exc_erro;
        END IF;
  
        RAISE vr_exc_erro_valida_total;
    END IF;

    IF  vr_flcnfenv = FALSE THEN 
        -- Envia para TIVIT
        vr_dsdirrec := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_SERPRO_ENV');                                                  

        -- Comando para mover os arquivos para a pasta recebidos
        vr_comando:= 'cp '||pr_nmdirret||pr_nmarqret||' '||vr_dsdirrec||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => pr_dscritic);

        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
           pr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||pr_dscritic;
           -- Levantar exceção
           RAISE vr_exc_erro;
        END IF;
    END IF;

    IF  vr_flcnfenv = TRUE THEN  -- Retorno do TXOK ou TXNOK
        -- Diretorio de backup dos arquivos recebidos TIVIT
        vr_dsdirrec := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_SERPRO_RECBS');                                                  
    ELSE
        -- Diretorio de backup dos arquivos recebidos SERPRO
        vr_dsdirrec := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'DIR_TIVIT_CONNECT_RECBS');                                                  
    END IF;
    
    -- Comando para mover os arquivos para a pasta recebidos
    vr_comando:= 'mv '||pr_nmdirret||pr_nmarqret||' '||vr_dsdirrec|| ' 2> /dev/null';

    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => pr_dscritic);

    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
       pr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||pr_dscritic;
       -- Levantar exceção
       RAISE vr_exc_erro;
    END IF;


    EXCEPTION
      WHEN vr_exc_erro THEN
        
        IF utl_file.IS_OPEN(vr_handle_arq) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
        END IF;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                            pr_nmrotina => 'pc_registra_retorno_serpro',
                            pr_dscritic => vr_dscritic);

        ROLLBACK;
      WHEN vr_exc_erro_valida_total THEN

        pr_dscritic := 'Totais dos lancamentos estao diferentes do total do arquivo. ' ||
                       'Convenio: ' || vr_cdempresa_documento || 
                       ', Arquivo - Quantidade:  ' || vr_quantidade_total || 
                       ', - Total:' || vr_valor_total ||
                       ', Lancamentos - Quantidade: ' || rw_registro_remessa_valida_total.quantidade_total ||
                       ' - Total: ' || rw_registro_remessa_valida_total.valor_total;
        
        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                            pr_nmrotina => 'pc_registra_retorno_serpro',
                            pr_dscritic => vr_dscritic);

      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina CONV0003.pc_registra_retorno_serpro. ' ||
                       'Arquivo de retorno:  ' || pr_nmarqret || ' - ' || SQLERRM;

        IF utl_file.IS_OPEN(vr_handle_arq) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
        END IF;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                            pr_nmrotina => 'pc_registra_retorno_serpro',
                            pr_dscritic => vr_dscritic);
                            
        ROLLBACK;
  END pc_registra_retorno_serpro;

  --> Registro do retorno da remessa na base de dados
  PROCEDURE pc_registra_retorno_rfb(pr_dtmvtolt           IN crapdat.dtmvtolt%TYPE,
                                    pr_nmdirret           IN VARCHAR2,
                                    pr_nmarqret           IN VARCHAR2,
                                    pr_tab_inconsistencia IN OUT SICR0003.typ_tab_inconsistencia,
                                    pr_tab_status_retorno IN OUT SICR0003.typ_tab_status_retorno,
                                    pr_dscritic          OUT VARCHAR2) IS
  -----------------------------------------------------------------
    CURSOR cr_crapcop IS
      SELECT c.nmrescop,
             c.cdcooper
        FROM crapcop c
       WHERE c.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;

    vr_exc_erro    EXCEPTION;
    vr_rej_erro    EXCEPTION;
    vr_dscritic    VARCHAR2(4000);
    vr_idx         VARCHAR2(20);
    vr_dhleitura   DATE;
    vr_linha_arq   VARCHAR2(4000);
    vr_qtlinhas    NUMBER := 0;
    vr_linha_split gene0002.typ_split;
    vr_qtdcolun    NUMBER := 0;
    vr_handle_arq  utl_file.file_type;

    vr_tab_itens_retorno SICR0003.typ_tab_itens_retorno;
    vr_tab_coop          SICR0003.typ_tab_coop;
    vr_tab_linhas        GENE0009.typ_tab_linhas;

    vr_idsicredi                      VARCHAR2(2000);
    vr_dsprocessamento                tbconv_registro_remessa_pagfor.dsprocessamento%TYPE;
    vr_cdprocessamento                VARCHAR2(10);
    vr_cdstatus_processamento         tbconv_registro_remessa_pagfor.cdstatus_processamento%TYPE;
    vr_dsautenticacao                 VARCHAR2(1000);
    vr_cdagente                       NUMBER;
    vr_idxctrl                        NUMBER := 0; --indice controle layout tivit
    vr_flsegper                      BOOLEAN := FALSE; -- Identifica 2a Perna
  BEGIN
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_tab_coop(rw_crapcop.cdcooper).nmrescop := rw_crapcop.nmrescop;
    END LOOP;

    vr_dhleitura                       := SYSDATE;
    pr_tab_status_retorno(pr_nmarqret) := 0;

    -- Retorno via Nexxera ou TIVIT
    gene0001.pc_abre_arquivo(pr_nmcaminh => pr_nmdirret || pr_nmarqret,
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_handle_arq,
                             pr_des_erro => vr_dscritic);

    IF TRIM(vr_dscritic) IS NOT NULL THEN
       vr_dscritic := 'Erro na leitura do arquivo de retorno:  ' || pr_nmarqret ||
                      '. ' || vr_dscritic;
       RAISE vr_exc_erro;
    END IF;

    LOOP
      BEGIN
        gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);

        vr_linha_arq := CONVERT(vr_linha_arq,'US7ASCII','UTF8');
        vr_linha_arq := REPLACE(REPLACE(TRIM(vr_linha_arq),chr(13),''),chr(10),'');
        vr_qtlinhas  := vr_qtlinhas + 1;

        vr_linha_split := gene0002.fn_quebra_string(pr_string  => vr_linha_arq,
                                                    pr_delimit => ';');
        vr_qtdcolun    := vr_linha_split.count;

        --Primeira linha do arquivo contém nome dos campos do CSV
        IF vr_qtlinhas = 1 THEN

          IF (vr_qtdcolun < 4) THEN
             vr_dscritic := 'Layout do arquivo de retorno inválido. Arquivo Retorno: ' || pr_nmarqret || '.';
             RAISE vr_exc_erro;
          END IF;

          -- 1a PERNA - Quando o campo codigo_situacao esta presente temos um campo a mais
          IF TRIM(vr_linha_split(vr_qtdcolun)) = 'CODIGO_SITUACAO' THEN
             vr_idxctrl  := 1;
             vr_flsegper := FALSE;
          -- 2a PERNA - Quando o campo codigo_situacao_receita esta presente temos um campo a mais    
          ELSIF TRIM(vr_linha_split(vr_qtdcolun)) = 'CODIGO_SITUACAO_RECEITA' THEN
             vr_idxctrl  := 2;
             vr_flsegper := TRUE;
          END IF;

          IF  TRIM(vr_linha_split(vr_qtdcolun - (2 + vr_idxctrl)))  <> 'SITUACAO'              OR
              TRIM(vr_linha_split(vr_qtdcolun - (1 + vr_idxctrl)))  <> 'AGENTE_ARRECADADOR'    OR
              TRIM(vr_linha_split(vr_qtdcolun - vr_idxctrl))        <> 'AUTENTICACAO_MECANICA' THEN
              vr_dscritic := 'Layout do arquivo de retorno inválido. Arquivo Retorno: ' || pr_nmarqret || '.';
              RAISE vr_exc_erro;
          END IF;

          IF  vr_flsegper = FALSE AND 
              TRIM(vr_linha_split(vr_qtdcolun)) <> 'CODIGO_SITUACAO'     THEN
              vr_dscritic := 'Layout do arquivo de retorno inválido. Arquivo Retorno: ' || pr_nmarqret || '.';
              RAISE vr_exc_erro;
          END IF;

          IF  vr_flsegper = TRUE                                              AND 
             (TRIM(vr_linha_split(vr_qtdcolun - 1)) <> 'CODIGO_SITUACAO'      OR
              TRIM(vr_linha_split(vr_qtdcolun)) <> 'CODIGO_SITUACAO_RECEITA') THEN
              vr_dscritic := 'Layout do arquivo de retorno inválido. Arquivo Retorno: ' || pr_nmarqret || '.';
              RAISE vr_exc_erro;
          END IF;


          --Primeira linha não precisa ser conciliada
          CONTINUE;
        END IF;

        vr_dsprocessamento := gene0007.fn_caract_acento(TRIM(vr_linha_split(vr_qtdcolun - (2 + vr_idxctrl))));
        vr_cdagente        := TO_NUMBER(TRIM(vr_linha_split(vr_qtdcolun - (1 + vr_idxctrl))));
        vr_dsautenticacao  := TRIM(vr_linha_split(vr_qtdcolun - vr_idxctrl));
        vr_idsicredi       := TRIM(vr_linha_split(vr_qtdcolun - (9 + vr_idxctrl)));    

        IF TRIM(vr_linha_split(vr_qtdcolun)) = '01' THEN
          vr_cdprocessamento := 'BD'; -- Pagamento incluído na fila de processamento com sucesso
        ELSIF TRIM(vr_linha_split(vr_qtdcolun)) in ('02', '04') THEN
          vr_cdprocessamento := '00'; -- Pagamento processado e liquidado com sucesso
        ELSIF TRIM(vr_linha_split(vr_qtdcolun)) = '03' THEN
          vr_cdprocessamento := 'ZZ'; -- Código fixo para identificar que houve uma ocorrência de rejeição
        ELSE
          vr_cdprocessamento := 'ZZ'; -- Código fixo para identificar que houve uma ocorrência de rejeição
        END IF;

        SICR0003.pc_trata_linha_retorno (pr_nmarqret           => pr_nmarqret,
                                         pr_dhleitura          => vr_dhleitura,
                                         pr_dtmvtolt           => pr_dtmvtolt,
                                         pr_flgplano           => 'C',
                                         pr_idsicredi          => vr_idsicredi,
                                         pr_cdprocessamento    => vr_cdprocessamento,
                                         pr_dsprocessamento    => vr_dsprocessamento,
                                         pr_tab_coop           => vr_tab_coop,
                                         pr_dscomprovante      => '',
                                         pr_cdagente           => vr_cdagente,
                                         pr_dsautenticacao     => vr_dsautenticacao,
                                         pr_statushttp         => 0,
                                         pr_codigoErro         => 0,
                                         pr_cdsegunda_perna    => vr_flsegper,
                                         pr_tab_inconsistencia => pr_tab_inconsistencia,
                                         pr_tab_status_retorno => pr_tab_status_retorno,
                                         pr_tab_itens_retorno  => vr_tab_itens_retorno);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --Fecha o arquivo se não tem mais linhas para ler
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
          EXIT;
      END;
    END LOOP;

    vr_cdstatus_processamento := 0;

    IF vr_tab_itens_retorno.COUNT > 0 THEN
      vr_idx := vr_tab_itens_retorno.FIRST;
      WHILE vr_idx IS NOT NULL LOOP
        BEGIN
          IF  vr_tab_itens_retorno(vr_idx).cdstatus_processamento = 4 THEN
              vr_cdstatus_processamento := 4;
          END IF;                  

          IF  vr_flsegper = TRUE THEN  -- 2a Perna

              vr_idsicredi := vr_tab_itens_retorno(vr_idx).idsicredi;

              UPDATE tbconv_registro_remessa_pagfor r
                SET r.cdstatus_processamento_serpro   = vr_tab_itens_retorno(vr_idx).cdstatus_processamento,
                    r.dhretorno_processamento_serpro  = vr_tab_itens_retorno(vr_idx).dhretorno_processamento,
                    r.nmarquivo_retorno_serpro        = vr_tab_itens_retorno(vr_idx).nmarquivo_retorno,
                    r.dsprocessamento_serpro          = vr_tab_itens_retorno(vr_idx).dsprocessamento
              WHERE r.idsicredi = vr_tab_itens_retorno(vr_idx).idsicredi;
          ELSE  -- 1a Perna
              UPDATE tbconv_registro_remessa_pagfor r
                SET r.cdstatus_processamento   = vr_tab_itens_retorno(vr_idx).cdstatus_processamento,
                    r.dhinclusao_processamento = vr_tab_itens_retorno(vr_idx).dhinclusao_processamento,
                    r.dhretorno_processamento  = vr_tab_itens_retorno(vr_idx).dhretorno_processamento,
                    r.nmarquivo_inclusao       = vr_tab_itens_retorno(vr_idx).nmarquivo_inclusao,
                    r.nmarquivo_retorno        = vr_tab_itens_retorno(vr_idx).nmarquivo_retorno,
                    r.dsprocessamento          = vr_tab_itens_retorno(vr_idx).dsprocessamento
              WHERE r.idsicredi = vr_tab_itens_retorno(vr_idx).idsicredi;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            SICR0003.pc_registra_inconsistencia(pr_idsicred => vr_tab_itens_retorno(vr_idx).idsicredi,
                                                pr_nmarqret => pr_nmarqret,
                                                pr_flgocorr => 0,
                                                pr_dscritic => 'Erro ao atualizar informações de retorno. Arquivo: ' ||
                                                               pr_nmarqret || ' - IDArrecadacao: ' ||
                                                               vr_tab_itens_retorno(vr_idx).idsicredi || ' - ' || SQLERRM,
                                                pr_tab_inconsistencia => pr_tab_inconsistencia);

            pr_tab_status_retorno(pr_nmarqret) := 1; -- Inconsistência no registro

            vr_idx := vr_tab_itens_retorno.NEXT(vr_idx);
            CONTINUE;
        END;

        vr_idx := vr_tab_itens_retorno.NEXT(vr_idx);
      END LOOP;
 
      BEGIN
        IF  vr_flsegper = TRUE THEN  -- 2a Perna
            --Atualiza Status da Remessa
            UPDATE tbconv_remessa_pagfor rem
               SET rem.cdstatus_retorno_serpro   =  (CASE WHEN vr_cdstatus_processamento = 4 THEN 4 ELSE 3 END),   
                   rem.flgocorrencia_serpro      =  (CASE WHEN vr_cdstatus_processamento = 4 THEN 1 ELSE 0 END)   
             WHERE rem.idremessa =  (SELECT det.idremessa 
                                       FROM tbconv_registro_remessa_pagfor det 
                                      WHERE det.idsicredi = vr_idsicredi);
        ELSE
            --Atualiza Status da Remessa
            UPDATE tbconv_remessa_pagfor rem
               SET rem.cdstatus_retorno          =  (CASE WHEN vr_cdstatus_processamento = 4 THEN 4 ELSE 3 END),   
                   rem.flgocorrencia             =  (CASE WHEN vr_cdstatus_processamento = 4 THEN 1 ELSE 0 END)   
             WHERE rem.idremessa =  (SELECT det.idremessa 
                                       FROM tbconv_registro_remessa_pagfor det 
                                      WHERE det.idsicredi = vr_idsicredi);
        END IF;                             
      EXCEPTION
          WHEN OTHERS THEN
            SICR0003.pc_registra_inconsistencia(pr_idsicred => vr_idsicredi,
                                                pr_nmarqret => pr_nmarqret,
                                                pr_flgocorr => 0,
                                                pr_dscritic => 'Erro ao atualizar informações de retorno. Arquivo: ' ||
                                                               pr_nmarqret || ' - IDArrecadacao: ' ||
                                                               vr_idsicredi || ' - ' || SQLERRM,
                                                pr_tab_inconsistencia => pr_tab_inconsistencia);

            pr_tab_status_retorno(pr_nmarqret) := 1; -- Inconsistência no registro
      END;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;  
    
      SICR0003.pc_registra_inconsistencia(pr_idsicred => 0,
                                          pr_nmarqret => pr_nmarqret,
                                          pr_flgocorr => 0,
                                          pr_dscritic => vr_dscritic,
                                          pr_tab_inconsistencia => pr_tab_inconsistencia);

      pr_tab_status_retorno(pr_nmarqret) := 2; -- Erro no processamento

      IF utl_file.IS_OPEN(vr_handle_arq) THEN
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
      END IF;

      pc_envia_email_erro(pr_conteudo => pr_dscritic,
                          pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                          pr_nmrotina => 'pc_registra_retorno_rfb',
                          pr_dscritic => vr_dscritic);

      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina CONV0003.pc_registra_retorno_pagfor. ' ||
                     'Arquivo de retorno:  ' || pr_nmarqret || ' - ' || SQLERRM;

      SICR0003.pc_registra_inconsistencia(pr_idsicred => 0,
                                          pr_nmarqret => pr_nmarqret,
                                          pr_flgocorr => 0,
                                          pr_dscritic => pr_dscritic,
                                          pr_tab_inconsistencia => pr_tab_inconsistencia);

      pr_tab_status_retorno(pr_nmarqret) := 2; -- Erro no processamento

      IF utl_file.IS_OPEN(vr_handle_arq) THEN
        -- Fechar arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
      END IF;

      pc_envia_email_erro(pr_conteudo => pr_dscritic,
                          pr_nmarquiv => pr_nmdirret||pr_nmarqret,
                          pr_nmrotina => 'pc_registra_retorno_rfb',
                          pr_dscritic => vr_dscritic);

      ROLLBACK;
  END pc_registra_retorno_rfb;


  PROCEDURE pc_importa_arquivos_rfb(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Codigo de Erro
                                   ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro

      -- Buscar convenios RFB --
      CURSOR cr_crapscn IS
         SELECT scn.cdempres
           FROM crapscn scn
          WHERE scn.cdempres IN ('D0432','D0328','D0064','D0385','D0153','D0100');
      rw_crapscn cr_crapscn%ROWTYPE;

      ------------------------- VARIAVEIS DE EXCEÇÃO ------------------------------
      vr_cdcritic PLS_INTEGER;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_exc_erro EXCEPTION;

      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_dtmvtolt       DATE;
      vr_nmprogra       VARCHAR2(30) := 'PC_IMPORTA_ARQUIVOS_RFB';
      vr_des_assunto    VARCHAR2(500);
      vr_conteudo       VARCHAR2(4000);
      vr_cdcnvpfo       VARCHAR2(10);
      vr_dsdireto       VARCHAR2(200);
      vr_dsdirrec       VARCHAR2(200);
      vr_dsdirslv       VARCHAR2(200);
      vr_dsdirspr       VARCHAR2(200);
      vr_dsdirenv       VARCHAR2(200);
      vr_lsarquiv       VARCHAR2(4000);
      vr_lsarquiv_split gene0002.typ_split;
      vr_plnctlpf       VARCHAR2(1);
      vr_handlarq       UTL_FILE.file_type;
      vr_handlarq_e     UTL_FILE.file_type;
      vr_handlarq_r     UTL_FILE.file_type;

      vr_tab_inconsistencia SICR0003.typ_tab_inconsistencia;
      vr_tab_status_retorno SICR0003.typ_tab_status_retorno;

      -- Variaveis de controle de comandos shell
      vr_comando   VARCHAR2(500);
      vr_typ_saida VARCHAR2(1000);

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Verificar se data de execução é dia útil
      vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                                ,pr_dtmvtolt => trunc(SYSDATE));

      -- Executar somente em dias úteis
      IF vr_dtmvtolt <> trunc(SYSDATE) THEN
         RETURN;
      END IF;

      -- Informar acesso
      gene0001.pc_informa_acesso(pr_module => 'CONV0003');

      -- Buscar data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      -- Cód. convênio Pagfor
      vr_cdcnvpfo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'CONVENIO_RFB');

      -- Plano de controle dos arquivos de remessa (A - Arquivos CSV Nexxera > Sicredi / B - Arquivos CNAB Connect:Direct > Sicredi / C - CSV SOA > API Bancoob/TIVIT)
      vr_plnctlpf := upper(trim(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                         ,pr_cdcooper => 0
                                                         ,pr_cdacesso => 'PLN_CTRL_PAGFOR')));

      -- Diretorio que possui os arquivos recebidos TIVIT
      vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_TIVIT_CONNECT_REC');

      -- Diretorio de backup dos arquivos recebidos TIVIT
      vr_dsdirrec := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_TIVIT_CONNECT_RECBS');                                                  

      -- Diretorio que possui os arquivos recebidos SERPRO
      vr_dsdirspr := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'DIR_SERPRO_REC');

      FOR rw_crapscn IN cr_crapscn LOOP

          -- Buscar arquivo a ser importado
          gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto 
                                    ,pr_pesq     => vr_cdcnvpfo || '.RET'
                                    ,pr_listarq  => vr_lsarquiv
                                    ,pr_des_erro => vr_dscritic);

          -- Se ocorrer erro ao recuperar lista de arquivos
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             vr_dscritic := 'Erro ao localizar arquivos: '||vr_dscritic;
             RAISE vr_exc_erro;
          END IF;

          IF TRIM(vr_lsarquiv) IS NOT NULL THEN
             -- Separa os arquivos
             vr_lsarquiv_split := gene0002.fn_quebra_string(pr_string => vr_lsarquiv
                                                           ,pr_delimit => ',');

             -- Itera pelos arquivos para realizar conciliação
             FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP

                 pc_registra_retorno_rfb(pr_dtmvtolt           => rw_crapdat.dtmvtocd
                                        ,pr_nmdirret           => vr_dsdireto 
                                        ,pr_nmarqret           => vr_lsarquiv_split(vr_idx)
                                        ,pr_tab_inconsistencia => vr_tab_inconsistencia
                                        ,pr_tab_status_retorno => vr_tab_status_retorno
                                        ,pr_dscritic           => vr_dscritic);

                 IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_erro;
                 END IF;

              END LOOP;

              SICR0003.pc_trata_email_log_retorno (pr_cdcooper           => pr_cdcooper
                                                  ,pr_lsarquiv           => vr_lsarquiv
                                                  ,pr_tab_inconsistencia => vr_tab_inconsistencia
                                                  ,pr_plnctlpf           => vr_plnctlpf
                                                  ,pr_dscritic           => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                 RAISE vr_exc_erro;
              END IF;

              -- Itera pelos arquivos para copiar e mover para os diretórios de backup
              FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP

                  vr_dsdirslv := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                                      ,pr_cdcooper => 3
                                                      ,pr_nmsubdir => '/salvar/');

                  -- Comando para copiar os arquivos para a pasta salvar
                  vr_comando:= 'cp '||vr_dsdireto||vr_lsarquiv_split(vr_idx)||' '|| vr_dsdirslv ||'/'|| vr_lsarquiv_split(vr_idx) || ' 2> /dev/null';

                  --Executar o comando no unix
                  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                       ,pr_des_comando => vr_comando
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);

                  --Se ocorreu erro dar RAISE
                  IF vr_typ_saida = 'ERR' THEN
                     vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
                     -- Levantar exceção
                     RAISE vr_exc_erro;
                  END IF;

                  -- Comando para mover os arquivos para a pasta recebidos
                  vr_comando:= 'mv '||vr_dsdireto||vr_lsarquiv_split(vr_idx)||' '||vr_dsdirrec|| ' 2> /dev/null';

                  --Executar o comando no unix
                  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                       ,pr_des_comando => vr_comando
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);

                  --Se ocorreu erro dar RAISE
                  IF vr_typ_saida = 'ERR' THEN
                     vr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||vr_dscritic;
                     -- Levantar exceção
                     RAISE vr_exc_erro;
                  END IF;

              END LOOP;
          END IF; -- Se encontrou arquivos
      END LOOP;

      FOR rw_crapscn IN cr_crapscn LOOP

          -- Tratamento para os arquivos RFB
          vr_cdcnvpfo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 0
                                                  ,pr_cdacesso => 'ENVIO_SERPRO_' || rw_crapscn.cdempres);


          -- Buscar arquivo a ser importado
          gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto 
                                    ,pr_pesq     => vr_cdcnvpfo
                                    ,pr_listarq  => vr_lsarquiv
                                    ,pr_des_erro => vr_dscritic);

         -- Se ocorrer erro ao recuperar lista de arquivos
         IF TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Erro ao localizar arquivos: '||vr_dscritic;
            RAISE vr_exc_erro;
         END IF;

         IF TRIM(vr_lsarquiv) IS NOT NULL THEN
            -- Separa os arquivos
            vr_lsarquiv_split := gene0002.fn_quebra_string(pr_string => vr_lsarquiv
                                                          ,pr_delimit => ',');

            -- Itera pelos arquivos para realizar conciliação
            FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP

                pc_registra_retorno_serpro(pr_nmdirret   => vr_dsdireto 
                                          ,pr_nmarqret   => vr_lsarquiv_split(vr_idx)
                                          ,pr_dtmvtolt   => rw_crapdat.dtmvtocd
                                          ,pr_dscritic   => vr_dscritic);

            END LOOP;

            IF TRIM(vr_dscritic) IS NOT NULL THEN
               RAISE vr_exc_erro;
            END IF;
         END IF; -- Se encontrou arquivos
      END LOOP;

      -- Tratamento para os arquivos RFB - SERPRO - RETORNO DA CONFIRMACAO DA 2a PERNA
      -- Buscar arquivo a ser importado
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdirspr 
                                ,pr_pesq     => '%.TX%'
                                ,pr_listarq  => vr_lsarquiv
                                ,pr_des_erro => vr_dscritic);

      -- Se ocorrer erro ao recuperar lista de arquivos
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Erro ao localizar arquivos: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      IF TRIM(vr_lsarquiv) IS NOT NULL THEN
        -- Separa os arquivos
        vr_lsarquiv_split := gene0002.fn_quebra_string(pr_string => vr_lsarquiv
                                                      ,pr_delimit => ',');

        -- Itera pelos arquivos para realizar conciliação
        FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP

          pc_registra_retorno_serpro(pr_nmdirret   => vr_dsdirspr 
                                    ,pr_nmarqret   => vr_lsarquiv_split(vr_idx)
                                    ,pr_dtmvtolt   => rw_crapdat.dtmvtocd - 5
                                    ,pr_dscritic   => vr_dscritic);

        END LOOP;

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF; -- Se encontrou arquivos


      vr_dsdirenv := gene0001.fn_param_sistema('CRED',0,'DIR_TIVIT_CONNECT_ENV');

      FOR rw_crapscn IN cr_crapscn LOOP

          -- Tratamento para os arquivos RFB
          vr_cdcnvpfo := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => 0
                                                  ,pr_cdacesso => 'RETORNO_SERPRO_' || rw_crapscn.cdempres);


          -- Tratamento para os arquivos RFB - SERPRO - RETORNO DA 2a PERNA
          -- Buscar arquivo a ser importado
          gene0001.pc_lista_arquivos(pr_path     => vr_dsdirspr 
                                    ,pr_pesq     => vr_cdcnvpfo
                                    ,pr_listarq  => vr_lsarquiv
                                    ,pr_des_erro => vr_dscritic);

          -- Se ocorrer erro ao recuperar lista de arquivos
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             vr_dscritic := 'Erro ao localizar arquivos: '||vr_dscritic;
             RAISE vr_exc_erro;
          END IF;

          IF TRIM(vr_lsarquiv) IS NOT NULL THEN
             -- Separa os arquivos
             vr_lsarquiv_split := gene0002.fn_quebra_string(pr_string => vr_lsarquiv
                                                           ,pr_delimit => ',');

             -- Itera pelos arquivos para realizar conciliação
             FOR vr_idx IN vr_lsarquiv_split.first..vr_lsarquiv_split.last LOOP

                 -- Comando para mover os arquivos para a pasta recebidos
                 vr_comando:= 'mv '||vr_dsdirspr||vr_lsarquiv_split(vr_idx)||' '||vr_dsdirenv||' 2> /dev/null';

                 --Executar o comando no unix
                 GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                      ,pr_des_comando => vr_comando
                                      ,pr_typ_saida   => vr_typ_saida
                                      ,pr_des_saida   => pr_dscritic);

                 --Se ocorreu erro dar RAISE
                 IF vr_typ_saida = 'ERR' THEN
                    pr_dscritic:= 'Erro ao executar comando unix: '|| vr_comando ||'. Erro: '||pr_dscritic;
                    -- Levantar exceção
                    RAISE vr_exc_erro;
                 END IF;

             END LOOP;

             IF TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
             END IF;
          END IF; -- Se encontrou arquivos
      END LOOP;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se arquivo está aberto
        IF utl_file.IS_OPEN(vr_handlarq) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handlarq);
        END IF;

        -- Se arquivo está aberto
        IF utl_file.IS_OPEN(vr_handlarq_e) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handlarq_e);
        END IF;

        -- Se arquivo está aberto
        IF utl_file.IS_OPEN(vr_handlarq_r) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handlarq_r);
        END IF;

        -- Se crítica possui código sem descrição
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_dscritic := vr_dscritic;
  
        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_importa_arquivos_rfb',
                            pr_dscritic => vr_dscritic);

      WHEN OTHERS THEN
        -- Se arquivo está aberto
        IF utl_file.IS_OPEN(vr_handlarq) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handlarq);
        END IF;

        -- Se arquivo está aberto
        IF utl_file.IS_OPEN(vr_handlarq_e) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handlarq_e);
        END IF;

        -- Se arquivo está aberto
        IF utl_file.IS_OPEN(vr_handlarq_r) THEN
          -- Fechar arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handlarq_r);
        END IF;

        -- Setar crítica não tratada
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic) || SQLERRM;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_importa_arquivos_rfb',
                            pr_dscritic => vr_dscritic);

        -- Controlar geração de log de execução dos jobs
        CECRED.pc_internal_exception(pr_cdcooper => 3);
  
  END pc_importa_arquivos_rfb;

  
  PROCEDURE pc_job_proc_retorno_rfb (pr_dscritic OUT VARCHAR2) IS

      ------------------------- VARIAVEIS DE EXCEÇÃO ------------------------------
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;

      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_hriniret INTEGER;
      vr_hrfimret INTEGER;
      vr_dhexecuc DATE;
      vr_dtmvtolt DATE;

    BEGIN    
      -- Verificar se data de execução é dia útil
      vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                                ,pr_dtmvtolt => trunc(SYSDATE));

      -- Executar somente em dias úteis
      IF vr_dtmvtolt <> trunc(SYSDATE) THEN
         RETURN;
      END IF;

      -- Buscar horário atual de execução
      vr_dhexecuc := SYSDATE;
      -- Buscar horário de início de envio dos arquivos de remessa da PAGFOR
      vr_hriniret := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => 0
                                                        ,pr_cdacesso => 'HRINI_ENV_RET_RFB'));
      -- Buscar horário final de envio dos arquivos de remessa da PAGFOR
      vr_hrfimret := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                        ,pr_cdcooper => 0
                                                        ,pr_cdacesso => 'HRFIM_ENV_RET_RFB'));

      -- Se horário de execução está entre os horários de início e fim da execução
      IF to_char(vr_dhexecuc,'SSSSS') >= vr_hriniret AND TO_CHAR(vr_dhexecuc,'SSSSS') <= vr_hrfimret THEN

         -- Executar proc para envio dos arquivos
         pc_importa_arquivos_rfb(pr_cdcooper => 3
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

         -- Verificar se retornou alguma crítica
         IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_erro;
         END IF;

      END IF;

      -- Efetuar commit
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se crítica possui código sem descrição
        IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NULL THEN
          -- Buscar descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Atribuir crítica de retorno
        pr_dscritic := vr_dscritic;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_job_proc_retorno_rfb',
                            pr_dscritic => vr_dscritic);
							
		-- Efetuar rollback
		ROLLBACK;

      WHEN OTHERS THEN
        -- Setar crítica não tratada
        vr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || SQLERRM;

        pc_envia_email_erro(pr_conteudo => pr_dscritic,
                            pr_nmarquiv => '',
                            pr_nmrotina => 'pc_job_proc_retorno_rfb',
                            pr_dscritic => vr_dscritic);

        -- Controlar geração de log de execução dos jobs
        CECRED.pc_internal_exception(pr_cdcooper => 3);
		
		-- Efetuar rollback
		ROLLBACK;

  END pc_job_proc_retorno_rfb;

END CONV0003;
/