DECLARE

  VR_INDEX       INTEGER;
  VR_COUNTCOMMIT NUMBER := 0;

  VR_CDOPERAD CRAPOPE.CDOPERAD%TYPE;
  VR_CDCRITIC CRAPCRI.CDCRITIC%TYPE;
  VR_DSCRITIC CRAPCRI.DSCRITIC%TYPE;
  VR_DES_ERRO CRAPCRI.DSCRITIC%TYPE;
  VR_EXC_SAIDA EXCEPTION;
  VR_TYP_SAIDA VARCHAR2(100);
  VR_DES_SAIDA VARCHAR2(1000);
  VR_EXC_ERRO EXCEPTION;

  VR_ARQ_PATH VARCHAR2(1000); --> Diretorio que sera criado o relatorio
  VR_ROWID    ROWID;

  VR_DES_XML        CLOB;
  VR_TEXTO_COMPLETO VARCHAR2(32600);
  VR_HUTLFILE       UTL_FILE.FILE_TYPE;

  /* Tipo para armazenamento as criticas identificadas */
  TYPE TYP_REC_ASS IS RECORD(
    CDCOOPER CRAPASS.CDCOOPER%TYPE,
    NRDCONTA CRAPASS.NRDCONTA%TYPE,
    INPESSOA CRAPASS.INPESSOA%TYPE,
    PACOTE   NUMBER);

  TYPE TYP_TAB_ASS IS TABLE OF TYP_REC_ASS INDEX BY PLS_INTEGER;

  VR_TAB_ASS TYP_TAB_ASS;

  -- Cursor genérico de calendário
  RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

  CURSOR C_COP IS
    SELECT CDCOOPER FROM CRAPCOP WHERE CDCOOPER IN (16);
  R_COP C_COP%ROWTYPE;

  PROCEDURE PC_ESCREVE_XML(PR_DES_DADOS IN VARCHAR2,
                           PR_FECHA_XML IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    GENE0002.PC_ESCREVE_XML(VR_DES_XML,
                            VR_TEXTO_COMPLETO,
                            PR_DES_DADOS,
                            PR_FECHA_XML);
  END;

  PROCEDURE PC_INCLUIR_PACOTE(PR_CDCOOPER           IN INTEGER --> codigo cooperativa
                             ,
                              PR_IDORIGEM           IN INTEGER --> Origem da transação
                             ,
                              PR_CDOPERAD           IN CRAPOPE.CDOPERAD%TYPE --> Codigo Opelrador
                             ,
                              PR_CDPACOTE           IN INTEGER --> codigo do pacote
                             ,
                              PR_DTDIADEBITO        IN INTEGER --> Dia do debito
                             ,
                              PR_PERDESCONTO_MANUAL IN INTEGER --> % desconto manual
                             ,
                              PR_QTDMESES_DESCONTO  IN INTEGER --> qtd de meses de desconto
                             ,
                              PR_NRDCONTA           IN CRAPASS.NRDCONTA%TYPE --> nr da conta
                             ,
                              PR_IDPARAME_RECIPROCI IN INTEGER --> codigo de reciprocidade
                             ,
                              PR_INPESSOA           IN INTEGER --> Tipo pessoa
                             ,
                              PR_DTULTDIA           IN CRAPDAT.DTULTDIA%TYPE --> Ultimo dia mes
                             ,
                              PR_DTMVTOLT           IN CRAPDAT.DTMVTOLT%TYPE --> Data corrente
                             ,
                              PR_CDCRITIC           OUT PLS_INTEGER --> Código da crítica
                             ,
                              PR_DSCRITIC           OUT VARCHAR2 --> Descrição da crítica
                             ,
                              PR_DES_ERRO           OUT VARCHAR2 --> Saida OK/NOK
                             ,
                              PR_ROWID              OUT ROWID) IS
    --> Rowid do registro inserido
  
    -- Busca valor da tarifa
    CURSOR CR_VLTARIFA(PR_CDCOOPER IN CRAPCOP.CDCOOPER%TYPE,
                       PR_CDPACOTE IN TBTARIF_PACOTES_COOP.CDPACOTE%TYPE,
                       PR_DTMVTOLT IN CRAPDAT.DTMVTOLT%TYPE,
                       PR_INPESSOA IN CRAPASS.INPESSOA%TYPE) IS
      SELECT TO_CHAR(FCO.VLTARIFA, 'fm999g999g999g990d00') VLTARIFA
        FROM TBTARIF_PACOTES      TPAC,
             TBTARIF_PACOTES_COOP TCOOP,
             CRAPFCO              FCO,
             CRAPFVL              FVL
       WHERE TCOOP.CDCOOPER = PR_CDCOOPER
         AND TCOOP.CDPACOTE = PR_CDPACOTE
         AND TCOOP.FLGSITUACAO = 1
         AND TCOOP.DTINICIO_VIGENCIA <= PR_DTMVTOLT
         AND TPAC.CDPACOTE = TCOOP.CDPACOTE
         AND TPAC.TPPESSOA = PR_INPESSOA
         AND FCO.CDCOOPER = TCOOP.CDCOOPER
         AND FCO.CDFAIXAV = FVL.CDFAIXAV
         AND FCO.FLGVIGEN = 1
         AND FVL.CDTARIFA = TPAC.CDTARIFA_LANCAMENTO;
    RW_VLTARIFA CR_VLTARIFA%ROWTYPE;
  
    -- Busca tipo de pessoa
    CURSOR CR_CRAPASS(PR_CDCOOPER IN CRAPCOP.CDCOOPER%TYPE,
                      PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE) IS
      SELECT INPESSOA
        FROM CRAPASS
       WHERE CDCOOPER = PR_CDCOOPER
         AND NRDCONTA = PR_NRDCONTA;
    RW_CRAPASS CR_CRAPASS%ROWTYPE;
  
    --- VARIAVEIS ---
    VR_CDCRITIC CRAPCRI.CDCRITIC%TYPE;
    VR_DSCRITIC CRAPCRI.DSCRITIC%TYPE;
  
    --Variáveis auxiliares
    VR_EXISTE_PACOTE      VARCHAR2(1);
    VR_DTINICIO_VIGENCIA  DATE;
    VR_IDPARAME_RECIPROCI TBRECIP_PARAME_CALCULO.IDPARAME_RECIPROCI%TYPE;
    VR_INDICADOR_GERAL    GENE0002.TYP_SPLIT;
    VR_INDICADOR_DADOS    GENE0002.TYP_SPLIT;
    VR_DSTRANSA           VARCHAR2(1000);
    VR_NRDROWID           ROWID;
    VR_FLGFOUND           BOOLEAN;
  
    -- Variaveis de log
    VR_CDCOOPER CRAPCOP.CDCOOPER%TYPE;
    VR_CDOPERAD VARCHAR2(100);
    VR_NMDATELA VARCHAR2(100);
    VR_NMEACAO  VARCHAR2(100);
    VR_CDAGENCI VARCHAR2(100);
    VR_NRDCAIXA VARCHAR2(100);
    VR_IDORIGEM VARCHAR2(100);
  
    --Controle de erro
    VR_EXC_ERRO EXCEPTION;
  
    VR_TBTARIF_PACOTES TELA_ADEPAC.TYP_TAB_TBTARIF_PACOTES;
  
  BEGIN
  
    PR_DES_ERRO := 'OK';
  
    VR_CDCOOPER := PR_CDCOOPER;
    VR_CDOPERAD := PR_CDOPERAD;
    VR_IDORIGEM := PR_IDORIGEM;
  
    -- Pega o primeiro dia do proximo mes
    VR_DTINICIO_VIGENCIA := TO_DATE(TRUNC(ADD_MONTHS(SYSDATE, 1), 'mm'),
                                    'DD/MM/RRRR');
  
    /*  
      OPEN cr_vltarifa (pr_cdcooper => vr_cdcooper
                       ,pr_cdpacote => pr_cdpacote
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_inpessoa => pr_inpessoa);
      FETCH cr_vltarifa INTO rw_vltarifa;
      vr_flgfound := cr_vltarifa%FOUND;
      CLOSE cr_vltarifa;
      IF NOT vr_flgfound THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor da tarifa não encontrado';
        RAISE vr_exc_erro;
      END IF;
    */
  
    VR_DSTRANSA := 'Adesão serviços cooperativos';
  
    --Insere novo pacote
    BEGIN
      INSERT INTO TBTARIF_CONTAS_PACOTE
        (CDCOOPER,
         NRDCONTA,
         CDPACOTE,
         DTADESAO,
         DTINICIO_VIGENCIA,
         NRDIADEBITO,
         INDORIGEM,
         FLGSITUACAO,
         PERDESCONTO_MANUAL,
         QTDMESES_DESCONTO,
         CDRECIPROCIDADE,
         CDOPERADOR_ADESAO,
         DTCANCELAMENTO)
      VALUES
        (VR_CDCOOPER,
         PR_NRDCONTA,
         PR_CDPACOTE,
         PR_DTMVTOLT,
         VR_DTINICIO_VIGENCIA,
         PR_DTDIADEBITO,
         1 -- Ayllos
        ,
         1 -- Ativo
        ,
         PR_PERDESCONTO_MANUAL,
         PR_QTDMESES_DESCONTO,
         PR_IDPARAME_RECIPROCI,
         VR_CDOPERAD,
         NULL)
      RETURNING ROWID INTO PR_ROWID;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        PR_ROWID := NULL;
      WHEN OTHERS THEN
        VR_DSCRITIC := 'Erro ao inserir novo servico cooperativo. ' ||
                       SQLERRM;
        RAISE VR_EXC_ERRO;
    END;
  
    -- Gerar informacoes do log
    GENE0001.PC_GERA_LOG(PR_CDCOOPER => VR_CDCOOPER,
                         PR_CDOPERAD => VR_CDOPERAD,
                         PR_DSCRITIC => ' ',
                         PR_DSORIGEM => GENE0001.VR_VET_DES_ORIGENS(VR_IDORIGEM),
                         PR_DSTRANSA => VR_DSTRANSA,
                         PR_DTTRANSA => TRUNC(SYSDATE),
                         PR_FLGTRANS => 1 --> TRUE
                        ,
                         PR_HRTRANSA => GENE0002.FN_BUSCA_TIME,
                         PR_IDSEQTTL => 1,
                         PR_NMDATELA => 'ATENDA',
                         PR_NRDCONTA => PR_NRDCONTA,
                         PR_NRDROWID => VR_NRDROWID);
  
    -- Gerar informacoes do item
    GENE0001.PC_GERA_LOG_ITEM(PR_NRDROWID => VR_NRDROWID,
                              PR_NMDCAMPO => 'Codigo do servico',
                              PR_DSDADANT => NULL,
                              PR_DSDADATU => PR_CDPACOTE);
    -- Gerar informacoes do item
    GENE0001.PC_GERA_LOG_ITEM(PR_NRDROWID => VR_NRDROWID,
                              PR_NMDCAMPO => 'Valor',
                              PR_DSDADANT => NULL,
                              PR_DSDADATU => '0,00');
    -- Gerar informacoes do item
    GENE0001.PC_GERA_LOG_ITEM(PR_NRDROWID => VR_NRDROWID,
                              PR_NMDCAMPO => 'Dia do debito',
                              PR_DSDADANT => NULL,
                              PR_DSDADATU => PR_DTDIADEBITO);
    -- Gerar informacoes do item
    GENE0001.PC_GERA_LOG_ITEM(PR_NRDROWID => VR_NRDROWID,
                              PR_NMDCAMPO => 'Inicio da vigencia',
                              PR_DSDADANT => NULL,
                              PR_DSDADATU => TO_CHAR(VR_DTINICIO_VIGENCIA,
                                                     'DD/MM/RRRR'));
  
    -- Efetua commit
    COMMIT;
    PR_DES_ERRO := 'OK';
  
  EXCEPTION
    WHEN VR_EXC_ERRO THEN
      -- Retorno não OK          
      PR_DES_ERRO := 'NOK';
    
      IF NVL(VR_CDCRITIC, 0) > 0 THEN
        VR_DSCRITIC := GENE0001.FN_BUSCA_CRITICA(VR_CDCRITIC);
      END IF;
    
      -- Erro
      PR_CDCRITIC := VR_CDCRITIC;
      PR_DSCRITIC := VR_DSCRITIC;
    
    WHEN OTHERS THEN
      -- Retorno não OK
      PR_DES_ERRO := 'NOK';
    
      -- Erro
      PR_CDCRITIC := 0;
      PR_DSCRITIC := 'Erro na TELA_ADEPAC.PC_INCLUIR_PACOTE: ' || SQLERRM;
    
  END PC_INCLUIR_PACOTE;

BEGIN

  -- Iniciar Variáveis     
  VR_ARQ_PATH := GENE0001.FN_DIRETORIO(PR_TPDIRETO => 'M', PR_CDCOOPER => 0) ||
                 'cpd/bacas/RITM0015405/';

  IF NOT GENE0001.FN_EXIS_DIRETORIO(VR_ARQ_PATH) THEN
    -- Efetuar a criação do mesmo
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'mkdir ' || VR_ARQ_PATH ||
                                                  ' 1> /dev/null',
                                PR_TYP_SAIDA   => VR_TYP_SAIDA,
                                PR_DES_SAIDA   => VR_DES_SAIDA);
    --Se ocorreu erro dar RAISE
    IF VR_TYP_SAIDA = 'ERR' THEN
      VR_DSCRITIC := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                     VR_DES_SAIDA;
      RAISE VR_EXC_ERRO;
    END IF;
    -- Adicionar permissão total na pasta
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'chmod 777 ' ||
                                                  VR_ARQ_PATH ||
                                                  ' 1> /dev/null',
                                PR_TYP_SAIDA   => VR_TYP_SAIDA,
                                PR_DES_SAIDA   => VR_DES_SAIDA);
    --Se ocorreu erro dar RAISE
    IF VR_TYP_SAIDA = 'ERR' THEN
      VR_DSCRITIC := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                     VR_DES_SAIDA;
      RAISE VR_EXC_ERRO;
    END IF;
  END IF;

  -- Inicializar o CLOB
  VR_DES_XML := NULL;
  DBMS_LOB.CREATETEMPORARY(VR_DES_XML, TRUE);
  DBMS_LOB.OPEN(VR_DES_XML, DBMS_LOB.LOB_READWRITE);
  VR_TEXTO_COMPLETO := NULL;

  FOR R_COP IN C_COP LOOP
  
    VR_TAB_ASS.DELETE;
    VR_INDEX := 0;
  
    BEGIN
      SELECT B.CDCOOPER,
             B.NRDCONTA,
             B.INPESSOA,
             DECODE(B.INPESSOA, 1, 61, 2, 62) PACOTE BULK COLLECT
        INTO VR_TAB_ASS
        FROM CRAPASS B
       WHERE B.CDCOOPER = R_COP.CDCOOPER
         AND B.INPESSOA IN (1, 2)
         AND B.DTDEMISS IS NULL
         AND NOT EXISTS (SELECT 1
                FROM TBTARIF_CONTAS_PACOTE C
               WHERE C.CDCOOPER = B.CDCOOPER
                 AND C.NRDCONTA = B.NRDCONTA
                 AND C.FLGSITUACAO = 1
                 AND C.DTCANCELAMENTO IS NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        VR_DSCRITIC := 'Dados não encontrados';
        RAISE VR_EXC_SAIDA;
      WHEN OTHERS THEN
        ROLLBACK;
    END;
  
    -- Leitura do calendário da cooperativa
    OPEN BTCH0001.CR_CRAPDAT(R_COP.CDCOOPER);
    FETCH BTCH0001.CR_CRAPDAT
      INTO RW_CRAPDAT;
    -- Se não encontrar
    IF BTCH0001.CR_CRAPDAT%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.CR_CRAPDAT;
      -- Montar mensagem de critica
      VR_CDCRITIC := 1;
      VR_DSCRITIC := GENE0001.FN_BUSCA_CRITICA(PR_CDCRITIC => 1);
      RAISE VR_EXC_SAIDA;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.CR_CRAPDAT;
    END IF;
  
    FOR VR_INDEX IN 1 .. VR_TAB_ASS.COUNT LOOP
    
      PC_INCLUIR_PACOTE(PR_CDCOOPER           => VR_TAB_ASS(VR_INDEX)
                                                 .CDCOOPER --> codigo cooperativa
                       ,
                        PR_IDORIGEM           => 5 --> Origem da transação
                       ,
                        PR_CDOPERAD           => '1' --> Codigo Operador
                       ,
                        PR_CDPACOTE           => VR_TAB_ASS(VR_INDEX).PACOTE --> codigo do pacote
                       ,
                        PR_DTDIADEBITO        => 1 --> Dia do debito
                       ,
                        PR_PERDESCONTO_MANUAL => 0 --> % desconto manual
                       ,
                        PR_QTDMESES_DESCONTO  => 0 --> qtd de meses de desconto
                       ,
                        PR_NRDCONTA           => VR_TAB_ASS(VR_INDEX)
                                                 .NRDCONTA --> nr da conta
                       ,
                        PR_IDPARAME_RECIPROCI => 0 --> codigo de reciprocidade
                       ,
                        PR_INPESSOA           => VR_TAB_ASS(VR_INDEX)
                                                 .INPESSOA --> tipo pessoa
                       ,
                        PR_DTULTDIA           => RW_CRAPDAT.DTULTDIA --> Ultimo dia
                       ,
                        PR_DTMVTOLT           => RW_CRAPDAT.DTMVTOLT --> Data corrente
                       ,
                        PR_CDCRITIC           => VR_CDCRITIC --> Código da crítica
                       ,
                        PR_DSCRITIC           => VR_DSCRITIC --> Descrição da crítica
                       ,
                        PR_DES_ERRO           => VR_DES_ERRO --> OK/NOK
                       ,
                        PR_ROWID              => VR_ROWID); --> Rowid do registro inserido
    
      IF VR_DES_ERRO = 'NOK' OR TRIM(VR_DSCRITIC) IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(VR_DSCRITIC);
        ROLLBACK;
      END IF;
    
      --Caso a procedure encontre valor duplicado na hora de inserir
      --o rowid vira nulo
      IF VR_ROWID IS NULL THEN
        CONTINUE;
      END IF;
    
      PC_ESCREVE_XML('DELETE FROM TBTARIF_CONTAS_PACOTE WHERE ROWID = ''' ||
                     VR_ROWID || '''' || ';' || CHR(10));
    
      VR_COUNTCOMMIT := VR_COUNTCOMMIT + 1;
      IF VR_COUNTCOMMIT = 1000 THEN
        VR_COUNTCOMMIT := 1;
        COMMIT;
      END IF;
    
    END LOOP;
  
  END LOOP;

  PC_ESCREVE_XML(' ', TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(VR_DES_XML,
                              VR_ARQ_PATH,
                              'BKP_PACOTE_TARIFA_16.txt',
                              NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  DBMS_LOB.CLOSE(VR_DES_XML);
  DBMS_LOB.FREETEMPORARY(VR_DES_XML);

  COMMIT;
EXCEPTION
  WHEN VR_EXC_SAIDA THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    -- Liberando a memória alocada pro CLOB
    DBMS_LOB.CLOSE(VR_DES_XML);
    DBMS_LOB.FREETEMPORARY(VR_DES_XML);
    DBMS_OUTPUT.PUT_LINE(VR_DSCRITIC);
  
    ROLLBACK;
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    -- Liberando a memória alocada pro CLOB
    DBMS_LOB.CLOSE(VR_DES_XML);
    DBMS_LOB.FREETEMPORARY(VR_DES_XML);
    DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
  
    ROLLBACK;
END;
