DECLARE

  TYPE TYP_REG_RAT IS RECORD(
    CDCOOPER CRAPCOP.CDCOOPER%TYPE,
    NRDCONTA CRAPASS.NRDCONTA%TYPE,
    TPCTRRAT VARCHAR(3),
    NRCTRRAT NUMBER,
    CDRATCAL VARCHAR2(1),
    ACUMULAD VARCHAR(30));
  TYPE TYP_TAB_RAT IS TABLE OF TYP_REG_RAT INDEX BY PLS_INTEGER;
  VR_TAB_RAT TYP_TAB_RAT;

  CURSOR CR_CRAPASS(PR_CDCOOPER CRAPCOP.CDCOOPER%TYPE,
                    PR_NRDCONTA CRAPASS.NRDCONTA%TYPE) IS
    SELECT *
      FROM CRAPASS
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA;
  RW_CRAPASS CR_CRAPASS%ROWTYPE;

  CURSOR CR_CRAPNRC(PR_CDCOOPER CRAPCOP.CDCOOPER%TYPE,
                    PR_NRDCONTA CRAPASS.NRDCONTA%TYPE,
                    PR_NRCTRRAT CRAPEPR.NRCTREMP%TYPE) IS
    SELECT C.ROWID, C.*
      FROM CRAPNRC C
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND NRCTRRAT = PR_NRCTRRAT;
  RW_CRAPNRC CR_CRAPNRC%ROWTYPE;

  CURSOR CR_CRAPNRC_ATIVO(PR_CDCOOPER CRAPCOP.CDCOOPER%TYPE,
                          PR_NRDCONTA CRAPASS.NRDCONTA%TYPE) IS
    SELECT C.ROWID, C.*
      FROM CRAPNRC C
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND FLGATIVO = 1
       AND INSITRAT = 1
     ORDER BY NRNOTRAT DESC, DTMVTOLT;
  RW_CRAPNRC_ATIVO CR_CRAPNRC_ATIVO%ROWTYPE;

  CURSOR CR_CRAPNRC_BACKUP(PR_CDCOOPER CRAPCOP.CDCOOPER%TYPE,
                           PR_NRDCONTA CRAPASS.NRDCONTA%TYPE) IS
    SELECT C.ROWID, C.*
      FROM CRAPNRC C
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA;
  RW_CRAPNRC_BACKUP CR_CRAPNRC_BACKUP%ROWTYPE;

  CURSOR CR_CRAPNRC_EFETIVO(PR_CDCOOPER CRAPCOP.CDCOOPER%TYPE,
                            PR_NRDCONTA CRAPASS.NRDCONTA%TYPE) IS
    SELECT C.ROWID, C.*
      FROM CRAPNRC C
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND INSITRAT = 2;
  RW_CRAPNRC_EFETIVO CR_CRAPNRC_EFETIVO%ROWTYPE;

  CURSOR CR_CRAPNRC_ROW(PR_ROWIDNRC IN ROWID) IS
    SELECT C.ROWID, C.* FROM CRAPNRC C WHERE C.ROWID = PR_ROWIDNRC;
  RW_CRAPNRC_ROW CR_CRAPNRC_ROW%ROWTYPE;

  CURSOR CR_CRAPEPR(PR_CDCOOPER IN CRAPEPR.CDCOOPER%TYPE,
                    PR_NRCTREMP IN CRAPEPR.NRCTREMP%TYPE,
                    PR_NRDCONTA IN CRAPEPR.NRDCONTA%TYPE) IS
    SELECT CRAPEPR.CDCOOPER,
           CRAPEPR.NRDCONTA,
           CRAPEPR.NRCTREMP,
           CRAPEPR.DTDPAGTO,
           CRAPEPR.INDPAGTO,
           CRAPEPR.INLIQUID,
           CRAPEPR.ROWID
      FROM CRAPEPR
     WHERE CRAPEPR.CDCOOPER = PR_CDCOOPER
       AND CRAPEPR.NRCTREMP = PR_NRCTREMP
       AND CRAPEPR.NRDCONTA = PR_NRDCONTA;
  RW_CRAPEPR CR_CRAPEPR%ROWTYPE;

  CURSOR CR_CRAPEPR2(PR_CDCOOPER IN CRAPEPR.CDCOOPER%TYPE,
                     PR_NRDCONTA IN CRAPEPR.NRDCONTA%TYPE) IS
    SELECT CRAPEPR.CDCOOPER,
           CRAPEPR.NRDCONTA,
           CRAPEPR.NRCTREMP,
           CRAPEPR.DTDPAGTO,
           CRAPEPR.INDPAGTO,
           CRAPEPR.INLIQUID,
           CRAPEPR.ROWID
      FROM CRAPEPR
     WHERE CRAPEPR.CDCOOPER = PR_CDCOOPER
       AND CRAPEPR.NRDCONTA = PR_NRDCONTA
       AND CRAPEPR.INLIQUID = 0;
  RW_CRAPEPR2 CR_CRAPEPR2%ROWTYPE;

  CURSOR CR_CRAPLIM(PR_CDCOOPER IN CRAPEPR.CDCOOPER%TYPE,
                    PR_NRDCONTA IN CRAPEPR.NRDCONTA%TYPE) IS
    SELECT *
      FROM CRAPLIM
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND INSITLIM = 2;
  RW_CRAPLIM CR_CRAPLIM%ROWTYPE;

  CURSOR CR_CRAPDAT2(PR_CDCOOPER IN CRAPTAB.CDCOOPER%TYPE,
                     PR_DTMVTOLT IN CRAPDAT.DTMVTOLT%TYPE) IS
    SELECT PR_DTMVTOLT DTMVTOLT,
           GENE0005.FN_VALIDA_DIA_UTIL(PR_CDCOOPER => PR_CDCOOPER,
                                       PR_DTMVTOLT => PR_DTMVTOLT + 1) DTMVTOPR,
           GENE0005.FN_VALIDA_DIA_UTIL(PR_CDCOOPER => PR_CDCOOPER,
                                       PR_DTMVTOLT => PR_DTMVTOLT - 1,
                                       PR_TIPO     => 'A') DTMVTOAN,
           (SELECT INPROCES FROM CRAPDAT WHERE CDCOOPER = PR_CDCOOPER) INPROCES,
           (SELECT QTDIAUTE FROM CRAPDAT WHERE CDCOOPER = PR_CDCOOPER) QTDIAUTE,
           (SELECT CDPRGANT FROM CRAPDAT WHERE CDCOOPER = PR_CDCOOPER) CDPRGANT,
           PR_DTMVTOLT DTMVTOCD,
           TRUNC(PR_DTMVTOLT, 'mm') DTINIMES -- Pri. Dia Mes Corr.
          ,
           TRUNC(ADD_MONTHS(PR_DTMVTOLT, 1), 'mm') DTPRIDMS -- Pri. Dia mes Seguinte
          ,
           LAST_DAY(ADD_MONTHS(PR_DTMVTOLT, -1)) DTULTDMA -- Ult. Dia Mes Ant.
          ,
           LAST_DAY(PR_DTMVTOLT) DTULTDIA -- Utl. Dia Mes Corr.
          ,
           ROWID
      FROM DUAL;
  RW_CRAPDAT2 CR_CRAPDAT2%ROWTYPE;

  CURSOR CR_CRAPDAT(PR_CDCOOPER IN CRAPTAB.CDCOOPER%TYPE) IS
    SELECT DAT.DTMVTOLT,
           DAT.DTMVTOPR,
           DAT.DTMVTOAN,
           DAT.INPROCES,
           DAT.QTDIAUTE,
           DAT.CDPRGANT,
           DAT.DTMVTOCD,
           TRUNC(DAT.DTMVTOLT, 'mm') DTINIMES -- Pri. Dia Mes Corr.
          ,
           TRUNC(ADD_MONTHS(DAT.DTMVTOLT, 1), 'mm') DTPRIDMS -- Pri. Dia mes Seguinte
          ,
           LAST_DAY(ADD_MONTHS(DAT.DTMVTOLT, -1)) DTULTDMA -- Ult. Dia Mes Ant.
          ,
           LAST_DAY(DAT.DTMVTOLT) DTULTDIA -- Utl. Dia Mes Corr.
          ,
           ROWID
      FROM CRAPDAT DAT
     WHERE DAT.CDCOOPER = PR_CDCOOPER;
  RW_CRAPDAT CR_CRAPDAT%ROWTYPE;

  VR_VLUTILIZ NUMBER;
  VR_CDCRITIC NUMBER;
  VR_DSCRITIC CRAPCRI.DSCRITIC%TYPE;

  -- Variaveis para busca na craptab
  VR_DSTEXTAB CRAPTAB.DSTEXTAB%TYPE;
  VR_INUSATAB BOOLEAN;

  VR_TIPO_CONTRATO        NUMBER;
  VR_NUM_CONTRATO         NUMBER;
  VR_EXISTE               BOOLEAN;
  VR_ATIVO                BOOLEAN;
  VR_TEMLIM               NUMBER;
  VR_FLGCRIAR             INTEGER := 1;
  PR_TAB_RATING_SING      RATI0001.TYP_TAB_CRAPRAS;
  VR_TAB_IMPRESS_RISCO_TL RATI0001.TYP_TAB_IMPRESS_RISCO;
  VR_TAB_ERRO             CECRED.GENE0001.TYP_TAB_ERRO;

  VR_INDRISCO VARCHAR2(2000);
  VR_NRNOTRAT CRAPNRC.NRNOTRAT%TYPE;
  VR_DES_RETO VARCHAR2(2000);

  VR_NOMEBACA VARCHAR2(200);
  VR_ARQ_PATH VARCHAR2(1000);
  VR_NMARQUIV VARCHAR2(200);
  VR_ARQSAIDA VARCHAR2(200);
  VR_ARQRELAT VARCHAR2(200);

  VR_DES_XML         CLOB;
  VR_TEXTO_COMPLETO  VARCHAR2(32600);
  VR_DES_REL         CLOB;
  VR_TEXTO_RELATORIO VARCHAR2(32600);

  VR_CHAVE PLS_INTEGER;
  VR_EXC_ERRO EXCEPTION;

  VR_UTL_FILE UTL_FILE.FILE_TYPE;
  VR_DSTXTRET VARCHAR2(1000);
  VR_TXTAUXIL VARCHAR2(200);

  VR_ROWIDNRC ROWID;
  VR_DTMVTOLT CRAPNRC.DTMVTOLT%TYPE;

  PROCEDURE PC_ESCREVE_XML(PR_DES_DADOS IN VARCHAR2,
                           PR_FECHA_XML IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    GENE0002.PC_ESCREVE_XML(VR_DES_XML,
                            VR_TEXTO_COMPLETO,
                            PR_DES_DADOS,
                            PR_FECHA_XML);
  END;

  PROCEDURE PC_ESCREVE_REL(PR_DES_DADOS IN VARCHAR2,
                           PR_FECHA_XML IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    GENE0002.PC_ESCREVE_XML(VR_DES_REL,
                            VR_TEXTO_RELATORIO,
                            PR_DES_DADOS,
                            PR_FECHA_XML);
  END;

  PROCEDURE PC_IMPRIME_DADOS(PR_ROWIDNRC IN ROWID,
                             PR_MENSAGEM IN VARCHAR2,
                             PR_DSOUTROS IN VARCHAR2 DEFAULT NULL) IS
    CURSOR CR_CRAPNRC2 IS
      SELECT * FROM CRAPNRC WHERE ROWID = PR_ROWIDNRC;
    RW_CRAPNRC2 CR_CRAPNRC2%ROWTYPE;
    VR_DSOUTROS VARCHAR2(4000);
  BEGIN
    VR_DSOUTROS := ';' || VR_TAB_RAT(VR_CHAVE).NRCTRRAT || ';' || VR_TAB_RAT(VR_CHAVE)
                  .CDRATCAL || ';' || VR_TAB_RAT(VR_CHAVE).ACUMULAD;
    IF NVL(PR_DSOUTROS, ' ') <> ' ' THEN
      VR_DSOUTROS := VR_DSOUTROS || ';' || PR_DSOUTROS;
    END IF;
    IF CR_CRAPNRC2%ISOPEN THEN
      CLOSE CR_CRAPNRC2;
    END IF;
    OPEN CR_CRAPNRC2;
    FETCH CR_CRAPNRC2
      INTO RW_CRAPNRC2;
    IF CR_CRAPNRC2%FOUND THEN
      PC_ESCREVE_REL(PR_MENSAGEM || ';' || RW_CRAPASS.CDCOOPER || ';' ||
                     RW_CRAPASS.CDAGENCI || ';' || RW_CRAPASS.NRDCONTA || ';' ||
                     RW_CRAPNRC2.NRCTRRAT || ';' || RW_CRAPNRC2.INDRISCO || ';' ||
                     RW_CRAPNRC2.NRNOTRAT || ';' || RW_CRAPNRC2.VLUTLRAT || ';' ||
                     RW_CRAPNRC2.DTEFTRAT || VR_DSOUTROS || CHR(10));
      /*      
            DBMS_OUTPUT.PUT_LINE(PR_MENSAGEM || ';' || RW_CRAPASS.CDCOOPER || ';' ||
                                 RW_CRAPASS.CDAGENCI || ';' ||
                                 RW_CRAPASS.NRDCONTA || ';' ||
                                 RW_CRAPNRC2.NRCTRRAT || ';' ||
                                 RW_CRAPNRC2.INDRISCO || ';' ||
                                 RW_CRAPNRC2.NRNOTRAT || ';' ||
                                 RW_CRAPNRC2.VLUTLRAT || ';' ||
                                 RW_CRAPNRC2.DTEFTRAT || VR_DSOUTROS);
      */
    ELSE
      PC_ESCREVE_REL(PR_MENSAGEM || ';' || RW_CRAPASS.CDCOOPER || ';' ||
                     RW_CRAPASS.CDAGENCI || ';' || RW_CRAPASS.NRDCONTA ||
                     ';;;;;' || VR_DSOUTROS || CHR(10));
      /*      
            DBMS_OUTPUT.PUT_LINE(PR_MENSAGEM || ';' || RW_CRAPASS.CDCOOPER || ';' ||
                                 RW_CRAPASS.CDAGENCI || ';' ||
                                 RW_CRAPASS.NRDCONTA || ';;;;;' || VR_DSOUTROS);
      */
    END IF;
    IF CR_CRAPNRC2%ISOPEN THEN
      CLOSE CR_CRAPNRC2;
    END IF;
  END;

  FUNCTION FN_BUSCA_DATA_CTR(PR_CDCOOPER IN CRAPCOP.CDCOOPER%TYPE,
                             PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE,
                             PR_NRCTRATO IN CRAPNRC.NRCTRRAT%TYPE,
                             PR_TPCTRATO IN CRAPNRC.TPCTRRAT%TYPE)
    RETURN DATE IS
    VR_DTCTRATO DATE;
  BEGIN
    IF PR_TPCTRATO = 90 THEN
      SELECT DTMVTOLT
        INTO VR_DTCTRATO
        FROM CRAPEPR
       WHERE CDCOOPER = PR_CDCOOPER
         AND NRDCONTA = PR_NRDCONTA
         AND NRCTREMP = PR_NRCTRATO;
    ELSE
      SELECT DTINIVIG
        INTO VR_DTCTRATO
        FROM CRAPLIM
       WHERE CDCOOPER = PR_CDCOOPER
         AND NRDCONTA = PR_NRDCONTA
         AND NRCTRLIM = PR_NRCTRATO;
    END IF;
    RETURN VR_DTCTRATO;
  END FN_BUSCA_DATA_CTR;

  /* Retornar o Rating Proposto com pior nota. */
  PROCEDURE PC_PROCURA_PIOR_NOTA(PR_CDCOOPER IN CRAPCOP.CDCOOPER%TYPE --> Código da Cooperativa
                                ,
                                 PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE --> Conta do associado
                                ,
                                 PR_ROWIDNRC OUT ROWID --> Rowid do pior rating
                                ,
                                 PR_DTMVTOLT OUT CRAPNRC.DTMVTOLT%TYPE,
                                 PR_CDCRITIC OUT CRAPCRI.CDCRITIC%TYPE --> Critica encontrada no processo
                                ,
                                 PR_DSCRITIC OUT VARCHAR2) IS --> Descritivo do erro
  BEGIN
    /* ..........................................................................
    
       Programa: pc_procura_pior_nota         Antigo: b1wgen0043 --> procura_pior_nota
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Marcos Ernani Martini
       Data    : Junho/2013.                          Ultima Atualizacao: 28/06/2017
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que chamado por outros programas.
       Objetivo  : Retornar o rating com pior nota
    
       Alteracoes: 04/06/2013 - Conversão Progress -> Oracle - Marcos (Supero)
    
                   28/06/2017 - Inclusão para setar o modulo de todas procedures da Package
                               ( Belli - Envolti - 28/06/2017 - Chamado 660306).
    
    ............................................................................. */
    DECLARE
      -- Busca de rating com pior nota
      CURSOR CR_CRAPNRC IS
        SELECT ROWID, INDRISCO, NRCTRRAT, TPCTRRAT, DTMVTOLT
          FROM CRAPNRC
         WHERE CDCOOPER = PR_CDCOOPER
           AND NRDCONTA = PR_NRDCONTA
           AND FLGATIVO = 1 -- Yes
           AND INSITRAT = 1 -- Proposto
         ORDER BY NRNOTRAT, DTMVTOLT DESC;
    BEGIN
    
      -- Incluir nome do módulo logado - Chamado 660306 28/06/2017
      GENE0001.PC_SET_MODULO(PR_MODULE => NULL,
                             PR_ACTION => 'RATI0001.pc_procura_pior_nota');
      PR_DTMVTOLT := '01/01/1800';
      -- Para cada registro de rating
      FOR RW_CRAPNRC IN CR_CRAPNRC LOOP
        -- Copiar as informações aos parâmetros de saída
        PR_ROWIDNRC := RW_CRAPNRC.ROWID;
        PR_DTMVTOLT := RW_CRAPNRC.DTMVTOLT;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/06/2018 - Chamado 660306        
        CECRED.PC_INTERNAL_EXCEPTION(PR_CDCOOPER => PR_CDCOOPER);
        -- Retorno não OK
        PR_CDCRITIC := 0;
        -- Gerar erro
        PR_DSCRITIC := 'Erro não tratado na rotina RATI0001.pc_procura_pior_nota. Detalhes: ' ||
                       SQLERRM;
    END;
  END PC_PROCURA_PIOR_NOTA;

BEGIN

  VR_NOMEBACA := 'INC0032616';
  VR_ARQ_PATH := GENE0001.FN_DIRETORIO(PR_TPDIRETO => 'M', PR_CDCOOPER => 0) ||
                 'cpd/bacas/' || VR_NOMEBACA;
  VR_NMARQUIV := VR_NOMEBACA || '_IN.csv';
  VR_ARQSAIDA := VR_NOMEBACA || '_OUT.txt';
  VR_ARQRELAT := VR_NOMEBACA || '_REL.txt';

  -- Inicializar o CLOB
  VR_DES_XML := NULL;
  DBMS_LOB.CREATETEMPORARY(VR_DES_XML, TRUE);
  DBMS_LOB.OPEN(VR_DES_XML, DBMS_LOB.LOB_READWRITE);
  VR_TEXTO_COMPLETO := NULL;

  VR_DES_REL := NULL;
  DBMS_LOB.CREATETEMPORARY(VR_DES_REL, TRUE);
  DBMS_LOB.OPEN(VR_DES_REL, DBMS_LOB.LOB_READWRITE);
  VR_TEXTO_RELATORIO := NULL;

  -- Efetuar abertura do arquivo para processamento
  GENE0001.PC_ABRE_ARQUIVO(PR_NMDIRETO => VR_ARQ_PATH --> Diretorio do arquivo
                          ,
                           PR_NMARQUIV => VR_NMARQUIV --> Nome do arquivo
                          ,
                           PR_TIPABERT => 'R' --> Modo de abertura (R,W,A)
                          ,
                           PR_UTLFILEH => VR_UTL_FILE --> Handle do arquivo aberto
                          ,
                           PR_DES_ERRO => VR_DSCRITIC); --> Erro

  IF VR_DSCRITIC IS NOT NULL THEN
    --Levantar Excecao
    VR_DSCRITIC := 'Erro na leitura do arquivo --> ' || VR_DSCRITIC;
    DBMS_OUTPUT.PUT_LINE(VR_DSCRITIC);
    PC_ESCREVE_REL(VR_DSCRITIC || CHR(10));
    RAISE VR_EXC_ERRO;
  END IF;

  --Verifica se o arquivo esta aberto
  IF UTL_FILE.IS_OPEN(VR_UTL_FILE) THEN
    BEGIN
      -- Laço para efetuar leitura de todas as linhas do arquivo 
      LOOP
        -- Leitura da linha
        GENE0001.PC_LE_LINHA_ARQUIVO(PR_UTLFILEH => VR_UTL_FILE --> Handle do arquivo aberto
                                    ,
                                     PR_DES_TEXT => VR_DSTXTRET); --> Texto lido
        -- Ignorar o cabeçalho
        IF VR_CHAVE IS NULL THEN
          VR_CHAVE := 0;
          CONTINUE;
        END IF;
      
        -- Efetuar leitura dos dados
        BEGIN
          VR_CHAVE := VR_CHAVE + 1;
          VR_TAB_RAT(VR_CHAVE).CDCOOPER := TRIM(GENE0002.FN_BUSCA_ENTRADA(PR_POSTEXT     => 1,
                                                                          PR_DSTEXT      => VR_DSTXTRET,
                                                                          PR_DELIMITADOR => ';'));
          VR_TAB_RAT(VR_CHAVE).NRDCONTA := TRIM(GENE0002.FN_BUSCA_ENTRADA(PR_POSTEXT     => 2,
                                                                          PR_DSTEXT      => VR_DSTXTRET,
                                                                          PR_DELIMITADOR => ';'));
          VR_TXTAUXIL := TRIM(GENE0002.FN_BUSCA_ENTRADA(PR_POSTEXT     => 4,
                                                        PR_DSTEXT      => VR_DSTXTRET,
                                                        PR_DELIMITADOR => ';'));
          VR_TAB_RAT(VR_CHAVE).TPCTRRAT := VR_TXTAUXIL;
          VR_TAB_RAT(VR_CHAVE).NRCTRRAT := TRIM(GENE0002.FN_BUSCA_ENTRADA(PR_POSTEXT     => 5,
                                                                          PR_DSTEXT      => VR_DSTXTRET,
                                                                          PR_DELIMITADOR => ';'));
          VR_TAB_RAT(VR_CHAVE).CDRATCAL := TRIM(GENE0002.FN_BUSCA_ENTRADA(PR_POSTEXT     => 6,
                                                                          PR_DSTEXT      => VR_DSTXTRET,
                                                                          PR_DELIMITADOR => ';'));
          VR_TXTAUXIL := REPLACE(REPLACE(GENE0002.FN_BUSCA_ENTRADA(PR_POSTEXT     => 7,
                                                                   PR_DSTEXT      => VR_DSTXTRET,
                                                                   PR_DELIMITADOR => ';'),
                                         '.',
                                         ''),
                                 CHR(13),
                                 '');
          VR_TAB_RAT(VR_CHAVE).ACUMULAD := TRIM(VR_TXTAUXIL);
        
        EXCEPTION
          WHEN OTHERS THEN
            VR_DSCRITIC := 'Erro na leitura do arquivo2 --> ' ||
                           VR_TXTAUXIL || SQLERRM;
            DBMS_OUTPUT.PUT_LINE(VR_DSCRITIC);
            PC_ESCREVE_REL(VR_DSCRITIC || CHR(10));
            RAISE VR_EXC_ERRO;
        END;
      
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- fechar arquivo
        GENE0001.PC_FECHA_ARQUIVO(PR_UTLFILEH => VR_UTL_FILE);
    END;
  END IF;

  PC_ESCREVE_REL('Mensagem;Coop;PA;Conta;Contrato Efetivado;Rating Efetivado;' ||
                 'Nota Efetivada;Valor Efetivado;Efetivação;Contrato Origem;' ||
                 'Rating Origem;Valor Origem;Saldo Devedor;Data Saldo Devedor' || CHR(10));
  /*
    DBMS_OUTPUT.PUT_LINE('Mensagem;Coop;PA;Conta;Contrato Efetivado;Rating Efetivado;' ||
                         'Nota Efetivada;Valor Efetivado;Efetivação;Contrato Origem;' ||
                         'Rating Origem;Valor Origem;Saldo Devedor;Data Saldo Devedor');
  */

  VR_CHAVE := VR_TAB_RAT.FIRST;

  WHILE VR_CHAVE IS NOT NULL LOOP
  
    IF CR_CRAPASS%ISOPEN THEN
      CLOSE CR_CRAPASS;
    END IF;
    OPEN CR_CRAPASS(VR_TAB_RAT(VR_CHAVE).CDCOOPER,
                    VR_TAB_RAT(VR_CHAVE).NRDCONTA);
    FETCH CR_CRAPASS
      INTO RW_CRAPASS;
    IF CR_CRAPASS%NOTFOUND THEN
      IF CR_CRAPASS%ISOPEN THEN
        CLOSE CR_CRAPASS;
      END IF;
      PC_ESCREVE_REL('ASSOCIADO NAO EXISTE;' || VR_TAB_RAT(VR_CHAVE)
                     .CDCOOPER || ';' || VR_TAB_RAT(VR_CHAVE).NRDCONTA || CHR(10));
      VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
      CONTINUE;
    END IF;
    IF CR_CRAPASS%ISOPEN THEN
      CLOSE CR_CRAPASS;
    END IF;
  
    PC_ESCREVE_XML('UPDATE CRAPASS SET DTRISCTL = ''' ||
                   RW_CRAPASS.DTRISCTL || ''', INRISCTL = ''' ||
                   RW_CRAPASS.INRISCTL || ''', NRNOTATL = ''' ||
                   RW_CRAPASS.NRNOTATL || ''' WHERE PROGRESS_RECID = ' ||
                   RW_CRAPASS.PROGRESS_RECID || ';' || CHR(10));
    FOR RW_CRAPNRC_BACKUP IN CR_CRAPNRC_BACKUP(RW_CRAPASS.CDCOOPER,
                                               RW_CRAPASS.NRDCONTA) LOOP
      PC_ESCREVE_XML('UPDATE CRAPNRC SET CDCOOPER=' ||
                     RW_CRAPNRC_BACKUP.CDCOOPER || ', NRDCONTA=' ||
                     RW_CRAPNRC_BACKUP.NRDCONTA || ', NRCTRRAT=' ||
                     RW_CRAPNRC_BACKUP.NRCTRRAT || ', TPCTRRAT=' ||
                     RW_CRAPNRC_BACKUP.TPCTRRAT || ', INDRISCO=''' ||
                     RW_CRAPNRC_BACKUP.INDRISCO || ''', DTEFTRAT=''' ||
                     RW_CRAPNRC_BACKUP.DTEFTRAT || ''', CDOPERAD=''' ||
                     RW_CRAPNRC_BACKUP.CDOPERAD || ''', INSITRAT=' ||
                     RW_CRAPNRC_BACKUP.INSITRAT || ', NRNOTRAT=''' ||
                     RW_CRAPNRC_BACKUP.NRNOTRAT || ''', VLUTLRAT=''' ||
                     RW_CRAPNRC_BACKUP.VLUTLRAT || ''', DTMVTOLT=''' ||
                     RW_CRAPNRC_BACKUP.DTMVTOLT || ''', FLGATIVO=' ||
                     RW_CRAPNRC_BACKUP.FLGATIVO || ', FLGORIGE=' ||
                     RW_CRAPNRC_BACKUP.FLGORIGE || ', NRNOTATL=''' ||
                     RW_CRAPNRC_BACKUP.NRNOTATL || ''', INRISCTL=''' ||
                     RW_CRAPNRC_BACKUP.INRISCTL || ''' WHERE CDCOOPER=' ||
                     RW_CRAPNRC_BACKUP.CDCOOPER || ' AND NRDCONTA=' ||
                     RW_CRAPNRC_BACKUP.NRDCONTA || ' AND NRCTRRAT=' ||
                     RW_CRAPNRC_BACKUP.NRCTRRAT || ' AND TPCTRRAT=' ||
                     RW_CRAPNRC_BACKUP.TPCTRRAT || ';' || CHR(10));
    END LOOP;
  
    --///
    COMMIT;
    --///
  
    -- Verificar se usa tabela juros
    VR_DSTEXTAB := TABE0001.FN_BUSCA_DSTEXTAB(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                              PR_NMSISTEM => 'CRED',
                                              PR_TPTABELA => 'USUARI',
                                              PR_CDEMPRES => 11,
                                              PR_CDACESSO => 'TAXATABELA',
                                              PR_TPREGIST => 0);
    -- Se a primeira posição do campo dstextab for diferente de zero
    VR_INUSATAB := SUBSTR(VR_DSTEXTAB, 1, 1) != '0';
  
    IF VR_TAB_RAT(VR_CHAVE).TPCTRRAT = 'CTA' THEN
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
      OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_EFETIVO
        INTO RW_CRAPNRC_EFETIVO;
      IF CR_CRAPNRC_EFETIVO%FOUND THEN
        IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_TAB_RAT(VR_CHAVE).NRCTRRAT THEN
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'CTA: CONTRATO ESTAVA EFETIVADO');
        ELSE
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'CTA: OUTRO CONTRATO ESTAVA EFETIVADO');
        END IF;
        IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
          CLOSE CR_CRAPNRC_EFETIVO;
        END IF;
        VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
        CONTINUE;
      END IF;
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
    
      IF CR_CRAPDAT%ISOPEN THEN
        CLOSE CR_CRAPDAT;
      END IF;
      OPEN CR_CRAPDAT(RW_CRAPASS.CDCOOPER);
      FETCH CR_CRAPDAT
        INTO RW_CRAPDAT;
      IF CR_CRAPDAT%ISOPEN THEN
        CLOSE CR_CRAPDAT;
      END IF;
    
      RATI0001.PC_CALCULA_ENDIVIDAMENTO(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                        PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                        PR_NRDCAIXA   => 999,
                                        PR_CDOPERAD   => 1,
                                        PR_RW_CRAPDAT => RW_CRAPDAT,
                                        PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                        PR_DSLIQUID   => '',
                                        PR_IDSEQTTL   => 1,
                                        PR_IDORIGEM   => 1,
                                        PR_INUSATAB   => VR_INUSATAB,
                                        PR_VLUTILIZ   => VR_VLUTILIZ,
                                        PR_CDCRITIC   => VR_CDCRITIC,
                                        PR_DSCRITIC   => VR_DSCRITIC);
    
      IF VR_VLUTILIZ < 50000 THEN
        PC_IMPRIME_DADOS(NULL,
                         'CTA: MENOR QUE 50 MIL',
                         VR_VLUTILIZ || ';' || RW_CRAPDAT.DTMVTOLT);
        VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
        CONTINUE;
      END IF;
    
      IF CR_CRAPNRC_ATIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_ATIVO;
      END IF;
      OPEN CR_CRAPNRC_ATIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_ATIVO
        INTO RW_CRAPNRC_ATIVO;
      IF CR_CRAPNRC_ATIVO%NOTFOUND THEN
        FOR RW_CRAPNRC_BACKUP IN CR_CRAPNRC_BACKUP(RW_CRAPASS.CDCOOPER,
                                                   RW_CRAPASS.NRDCONTA) LOOP
          IF RW_CRAPNRC_BACKUP.TPCTRRAT = 90 THEN
            IF CR_CRAPEPR%ISOPEN THEN
              CLOSE CR_CRAPEPR;
            END IF;
            OPEN CR_CRAPEPR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                            PR_NRCTREMP => RW_CRAPNRC_BACKUP.NRCTRRAT,
                            PR_NRDCONTA => RW_CRAPASS.NRDCONTA);
            FETCH CR_CRAPEPR
              INTO RW_CRAPEPR;
            IF CR_CRAPEPR%FOUND THEN
              IF RW_CRAPEPR.INLIQUID = 0 THEN
                /* Em aberto */
                IF RW_CRAPNRC_BACKUP.FLGATIVO = 0 THEN
                  /* Desativado */
                  UPDATE CRAPNRC
                     SET CRAPNRC.FLGATIVO = 1
                   WHERE CRAPNRC.ROWID = RW_CRAPNRC_BACKUP.ROWID;
                END IF;
              END IF;
            END IF;
            IF CR_CRAPEPR%ISOPEN THEN
              CLOSE CR_CRAPEPR;
            END IF;
          ELSE
            BEGIN
              VR_TEMLIM := 0;
              SELECT 1
                INTO VR_TEMLIM
                FROM CRAPLIM
               WHERE CDCOOPER = RW_CRAPASS.CDCOOPER
                 AND NRDCONTA = RW_CRAPASS.NRDCONTA
                 AND NRCTRLIM = RW_CRAPNRC_BACKUP.NRCTRRAT
                 AND TPCTRLIM = RW_CRAPNRC_BACKUP.TPCTRRAT
                 AND INSITLIM = 2;
              IF VR_TEMLIM = 1 THEN
                UPDATE CRAPNRC
                   SET CRAPNRC.FLGATIVO = VR_TEMLIM
                 WHERE CRAPNRC.ROWID = RW_CRAPNRC_BACKUP.ROWID;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          END IF;
        END LOOP;
      END IF;
      IF CR_CRAPNRC_ATIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_ATIVO;
      END IF;
    
      PC_PROCURA_PIOR_NOTA(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                           PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                           PR_ROWIDNRC => VR_ROWIDNRC,
                           PR_DTMVTOLT => VR_DTMVTOLT,
                           PR_CDCRITIC => VR_CDCRITIC,
                           PR_DSCRITIC => VR_DSCRITIC);
    
      IF VR_DTMVTOLT = '01/01/1800' THEN
        VR_DTMVTOLT := RW_CRAPDAT.DTMVTOLT;
      END IF;
    
      IF CR_CRAPDAT2%ISOPEN THEN
        CLOSE CR_CRAPDAT2;
      END IF;
      OPEN CR_CRAPDAT2(RW_CRAPASS.CDCOOPER, VR_DTMVTOLT);
      FETCH CR_CRAPDAT2
        INTO RW_CRAPDAT2;
      IF CR_CRAPDAT2%ISOPEN THEN
        CLOSE CR_CRAPDAT2;
      END IF;
    
      RATI0001.PC_DESATIVA_RATING(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                  PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                  PR_NRDCAIXA   => 999,
                                  PR_CDOPERAD   => 1,
                                  PR_RW_CRAPDAT => RW_CRAPDAT,
                                  PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                  PR_TPCTRRAT   => 0,
                                  PR_NRCTRRAT   => 0,
                                  PR_FLGEFETI   => 'S',
                                  PR_IDSEQTTL   => 1,
                                  PR_IDORIGEM   => 1,
                                  PR_INUSATAB   => VR_INUSATAB,
                                  PR_NMDATELA   => 'RATI0001',
                                  PR_FLGERLOG   => 0,
                                  PR_DES_RETO   => VR_DES_RETO,
                                  PR_TAB_ERRO   => VR_TAB_ERRO);
    
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
      OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_EFETIVO
        INTO RW_CRAPNRC_EFETIVO;
      IF CR_CRAPNRC_EFETIVO%FOUND THEN
        IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_NUM_CONTRATO THEN
          IF VR_EXISTE THEN
            BEGIN
              VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                               PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                               PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                               PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
              UPDATE CRAPNRC
                 SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
               WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
            END;
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                             'CTA: CONTRATO EFETIVADO');
          ELSE
            BEGIN
              VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                               PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                               PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                               PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
              UPDATE CRAPNRC
                 SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
               WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
            END;
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                             'CTA: CONTRATO CRIADO');
            PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                           RW_CRAPNRC_EFETIVO.ROWID || ''';' || CHR(10));
          END IF;
        ELSE
          BEGIN
            VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                             PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                             PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                             PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
            UPDATE CRAPNRC
               SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
             WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
          END;
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'CTA: OUTRO CONTRATO EFETIVADO');
          IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
            CLOSE CR_CRAPNRC_EFETIVO;
          END IF;
          VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
          CONTINUE;
        END IF;
      END IF;
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
    
      RATI0001.PC_CALCULA_ENDIVIDAMENTO(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                        PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                        PR_NRDCAIXA   => 999,
                                        PR_CDOPERAD   => 1,
                                        PR_RW_CRAPDAT => RW_CRAPDAT2,
                                        PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                        PR_DSLIQUID   => '',
                                        PR_IDSEQTTL   => 1,
                                        PR_IDORIGEM   => 1,
                                        PR_INUSATAB   => VR_INUSATAB,
                                        PR_VLUTILIZ   => VR_VLUTILIZ,
                                        PR_CDCRITIC   => VR_CDCRITIC,
                                        PR_DSCRITIC   => VR_DSCRITIC);
    
      IF VR_VLUTILIZ < 50000 THEN
        PC_IMPRIME_DADOS(NULL,
                         'CTA: MENOR QUE 50 MIL',
                         VR_VLUTILIZ || ';' || RW_CRAPDAT2.DTMVTOLT);
        VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
        CONTINUE;
      END IF;
    
      VR_EXISTE := FALSE;
      IF CR_CRAPNRC_ATIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_ATIVO;
      END IF;
      OPEN CR_CRAPNRC_ATIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_ATIVO
        INTO RW_CRAPNRC_ATIVO;
      IF CR_CRAPNRC_ATIVO%NOTFOUND THEN
        VR_ATIVO := FALSE;
        FOR RW_CRAPEPR2 IN CR_CRAPEPR2(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                       PR_NRDCONTA => RW_CRAPASS.NRDCONTA) LOOP
          VR_ATIVO := TRUE;
          RATI0001.PC_PROC_CALCULA(PR_CDCOOPER             => RW_CRAPASS.CDCOOPER,
                                   PR_CDAGENCI             => RW_CRAPASS.CDAGENCI,
                                   PR_NRDCAIXA             => 999,
                                   PR_CDOPERAD             => 1,
                                   PR_NRDCONTA             => RW_CRAPASS.NRDCONTA,
                                   PR_TPCTRATO             => 90,
                                   PR_NRCTRATO             => RW_CRAPEPR2.NRCTREMP,
                                   PR_FLGCRIAR             => VR_FLGCRIAR,
                                   PR_IDORIGEM             => 1,
                                   PR_NMDATELA             => 'RATI0001',
                                   PR_INPROCES             => RW_CRAPDAT.INPROCES,
                                   PR_INSITRAT             => 1,
                                   PR_ROWIDNRC             => NULL,
                                   PR_TAB_RATING_SING      => PR_TAB_RATING_SING,
                                   PR_TAB_IMPRESS_RISCO_TL => VR_TAB_IMPRESS_RISCO_TL,
                                   PR_INDRISCO             => VR_INDRISCO,
                                   PR_NRNOTRAT             => VR_NRNOTRAT,
                                   PR_TAB_ERRO             => VR_TAB_ERRO,
                                   PR_DES_RETO             => VR_DES_RETO);
          BEGIN
            SELECT ROWID
              INTO VR_ROWIDNRC
              FROM CRAPNRC
             WHERE CDCOOPER = RW_CRAPASS.CDCOOPER
               AND NRDCONTA = RW_CRAPASS.NRDCONTA
               AND NRCTRRAT = RW_CRAPEPR2.NRCTREMP;
            PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                           VR_ROWIDNRC || ''';' || CHR(10));
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END LOOP;
        FOR RW_CRAPLIM IN CR_CRAPLIM(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                     PR_NRDCONTA => RW_CRAPASS.NRDCONTA) LOOP
          VR_ATIVO := TRUE;
          RATI0001.PC_PROC_CALCULA(PR_CDCOOPER             => RW_CRAPASS.CDCOOPER,
                                   PR_CDAGENCI             => RW_CRAPASS.CDAGENCI,
                                   PR_NRDCAIXA             => 999,
                                   PR_CDOPERAD             => 1,
                                   PR_NRDCONTA             => RW_CRAPASS.NRDCONTA,
                                   PR_TPCTRATO             => RW_CRAPLIM.TPCTRLIM,
                                   PR_NRCTRATO             => RW_CRAPLIM.NRCTRLIM,
                                   PR_FLGCRIAR             => VR_FLGCRIAR,
                                   PR_IDORIGEM             => 1,
                                   PR_NMDATELA             => 'RATI0001',
                                   PR_INPROCES             => RW_CRAPDAT.INPROCES,
                                   PR_INSITRAT             => 1,
                                   PR_ROWIDNRC             => NULL,
                                   PR_TAB_RATING_SING      => PR_TAB_RATING_SING,
                                   PR_TAB_IMPRESS_RISCO_TL => VR_TAB_IMPRESS_RISCO_TL,
                                   PR_INDRISCO             => VR_INDRISCO,
                                   PR_NRNOTRAT             => VR_NRNOTRAT,
                                   PR_TAB_ERRO             => VR_TAB_ERRO,
                                   PR_DES_RETO             => VR_DES_RETO);
          BEGIN
            SELECT ROWID
              INTO VR_ROWIDNRC
              FROM CRAPNRC
             WHERE CDCOOPER = RW_CRAPASS.CDCOOPER
               AND NRDCONTA = RW_CRAPASS.NRDCONTA
               AND NRCTRRAT = RW_CRAPLIM.NRCTRLIM;
            PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                           VR_ROWIDNRC || ''';' || CHR(10));
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END LOOP;
        IF VR_ATIVO = FALSE THEN
          PC_IMPRIME_DADOS(NULL, 'CTA: SEM CONTRATO ATIVO');
        ELSE
          IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
            CLOSE CR_CRAPNRC_EFETIVO;
          END IF;
          OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
          FETCH CR_CRAPNRC_EFETIVO
            INTO RW_CRAPNRC_EFETIVO;
          IF CR_CRAPNRC_EFETIVO%FOUND THEN
            BEGIN
              VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                               PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                               PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                               PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
              UPDATE CRAPNRC
                 SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
               WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
            END;
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                             'CTA: RATING EFETIVADO');
            IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
              CLOSE CR_CRAPNRC_EFETIVO;
            END IF;
            IF CR_CRAPNRC_ATIVO%ISOPEN THEN
              CLOSE CR_CRAPNRC_ATIVO;
            END IF;
            VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
            CONTINUE;
          END IF;
          IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
            CLOSE CR_CRAPNRC_EFETIVO;
          END IF;
        END IF;
      END IF;
      IF CR_CRAPNRC_ATIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_ATIVO;
      END IF;
    
      RATI0001.PC_DESATIVA_RATING(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                  PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                  PR_NRDCAIXA   => 999,
                                  PR_CDOPERAD   => 1,
                                  PR_RW_CRAPDAT => RW_CRAPDAT2,
                                  PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                  PR_TPCTRRAT   => 0,
                                  PR_NRCTRRAT   => 0,
                                  PR_FLGEFETI   => 'S',
                                  PR_IDSEQTTL   => 1,
                                  PR_IDORIGEM   => 1,
                                  PR_INUSATAB   => VR_INUSATAB,
                                  PR_NMDATELA   => 'RATI0001',
                                  PR_FLGERLOG   => 0,
                                  PR_DES_RETO   => VR_DES_RETO,
                                  PR_TAB_ERRO   => VR_TAB_ERRO);
    
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
      OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_EFETIVO
        INTO RW_CRAPNRC_EFETIVO;
      IF CR_CRAPNRC_EFETIVO%FOUND THEN
        IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_NUM_CONTRATO THEN
          IF VR_EXISTE THEN
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                             'CTA: CONTRATO EFETIVADO');
          ELSE
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                             'CTA: CONTRATO CRIADO');
            PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                           RW_CRAPNRC_EFETIVO.ROWID || ''';' || CHR(10));
          END IF;
        ELSE
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'CTA: OUTRO CONTRATO EFETIVADO');
        END IF;
      END IF;
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
      VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
      CONTINUE;
    ELSE
      IF CR_CRAPDAT%ISOPEN THEN
        CLOSE CR_CRAPDAT;
      END IF;
      OPEN CR_CRAPDAT(RW_CRAPASS.CDCOOPER);
      FETCH CR_CRAPDAT
        INTO RW_CRAPDAT;
      IF CR_CRAPDAT%ISOPEN THEN
        CLOSE CR_CRAPDAT;
      END IF;
    
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
      OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_EFETIVO
        INTO RW_CRAPNRC_EFETIVO;
      IF CR_CRAPNRC_EFETIVO%FOUND THEN
        IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_TAB_RAT(VR_CHAVE).NRCTRRAT THEN
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'CONTRATO ESTAVA EFETIVADO');
        ELSE
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'OUTRO CONTRATO ESTAVA EFETIVADO');
        END IF;
        IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
          CLOSE CR_CRAPNRC_EFETIVO;
        END IF;
        VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
        CONTINUE;
      END IF;
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
    
      RATI0001.PC_CALCULA_ENDIVIDAMENTO(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                        PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                        PR_NRDCAIXA   => 999,
                                        PR_CDOPERAD   => 1,
                                        PR_RW_CRAPDAT => RW_CRAPDAT,
                                        PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                        PR_DSLIQUID   => '',
                                        PR_IDSEQTTL   => 1,
                                        PR_IDORIGEM   => 1,
                                        PR_INUSATAB   => VR_INUSATAB,
                                        PR_VLUTILIZ   => VR_VLUTILIZ,
                                        PR_CDCRITIC   => VR_CDCRITIC,
                                        PR_DSCRITIC   => VR_DSCRITIC);
    
      IF VR_VLUTILIZ < 50000 THEN
        PC_IMPRIME_DADOS(NULL,
                         'MENOR QUE 50 MIL',
                         VR_VLUTILIZ || ';' || RW_CRAPDAT.DTMVTOLT);
        VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
        CONTINUE;
      END IF;
    
      PC_PROCURA_PIOR_NOTA(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                           PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                           PR_ROWIDNRC => VR_ROWIDNRC,
                           PR_DTMVTOLT => VR_DTMVTOLT,
                           PR_CDCRITIC => VR_CDCRITIC,
                           PR_DSCRITIC => VR_DSCRITIC);
    
      IF VR_DTMVTOLT = '01/01/1800' THEN
        VR_DTMVTOLT := RW_CRAPDAT.DTMVTOLT;
      END IF;
    
      IF CR_CRAPDAT2%ISOPEN THEN
        CLOSE CR_CRAPDAT2;
      END IF;
      OPEN CR_CRAPDAT2(RW_CRAPASS.CDCOOPER, VR_DTMVTOLT);
      FETCH CR_CRAPDAT2
        INTO RW_CRAPDAT2;
      IF CR_CRAPDAT2%ISOPEN THEN
        CLOSE CR_CRAPDAT2;
      END IF;
    
      VR_EXISTE := TRUE;
      IF CR_CRAPNRC%ISOPEN THEN
        CLOSE CR_CRAPNRC;
      END IF;
      OPEN CR_CRAPNRC(RW_CRAPASS.CDCOOPER,
                      RW_CRAPASS.NRDCONTA,
                      VR_TAB_RAT(VR_CHAVE).NRCTRRAT);
      FETCH CR_CRAPNRC
        INTO RW_CRAPNRC;
      IF CR_CRAPNRC%NOTFOUND THEN
        VR_NUM_CONTRATO := VR_TAB_RAT(VR_CHAVE).NRCTRRAT;
        VR_EXISTE       := FALSE;
      ELSE
        VR_NUM_CONTRATO := RW_CRAPNRC.NRCTRRAT;
      END IF;
      IF CR_CRAPNRC%ISOPEN THEN
        CLOSE CR_CRAPNRC;
      END IF;
    
      VR_TIPO_CONTRATO := 0;
      IF VR_TAB_RAT(VR_CHAVE)
       .TPCTRRAT = 'EMP' OR VR_TAB_RAT(VR_CHAVE).TPCTRRAT = 'FIN' THEN
        VR_TIPO_CONTRATO := 90;
      ELSIF VR_TAB_RAT(VR_CHAVE).TPCTRRAT = 'DCH' THEN
        VR_TIPO_CONTRATO := 2;
      ELSIF VR_TAB_RAT(VR_CHAVE).TPCTRRAT = 'DTI' THEN
        VR_TIPO_CONTRATO := 3;
      END IF;
    
      RATI0001.PC_DESATIVA_RATING(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                  PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                  PR_NRDCAIXA   => 999,
                                  PR_CDOPERAD   => 1,
                                  PR_RW_CRAPDAT => RW_CRAPDAT2,
                                  PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                  PR_TPCTRRAT   => 0,
                                  PR_NRCTRRAT   => 0,
                                  PR_FLGEFETI   => 'S',
                                  PR_IDSEQTTL   => 1,
                                  PR_IDORIGEM   => 1,
                                  PR_INUSATAB   => VR_INUSATAB,
                                  PR_NMDATELA   => 'RATI0001',
                                  PR_FLGERLOG   => 0,
                                  PR_DES_RETO   => VR_DES_RETO,
                                  PR_TAB_ERRO   => VR_TAB_ERRO);
    
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
      OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
      FETCH CR_CRAPNRC_EFETIVO
        INTO RW_CRAPNRC_EFETIVO;
      IF CR_CRAPNRC_EFETIVO%FOUND THEN
        IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_TAB_RAT(VR_CHAVE).NRCTRRAT THEN
          IF VR_EXISTE THEN
            BEGIN
              VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                               PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                               PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                               PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
              UPDATE CRAPNRC
                 SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
               WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
            
            END;
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                             'CONTRATO EFETIVADO');
            IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
              CLOSE CR_CRAPNRC_EFETIVO;
            END IF;
            VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
            CONTINUE;
          ELSE
            PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID, 'CONTRATO CRIADO');
            PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                           RW_CRAPNRC_EFETIVO.ROWID || ''';' || CHR(10));
            IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
              CLOSE CR_CRAPNRC_EFETIVO;
            END IF;
            VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
            CONTINUE;
          END IF;
        ELSE
          BEGIN
            VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                             PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                             PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                             PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
            UPDATE CRAPNRC
               SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
             WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
          
          END;
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'OUTRO CONTRATO EFETIVADO');
          IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
            CLOSE CR_CRAPNRC_EFETIVO;
          END IF;
          VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
          CONTINUE;
        END IF;
      ELSE
        IF VR_EXISTE THEN
          IF RW_CRAPNRC.TPCTRRAT = 90 THEN
            IF CR_CRAPEPR%ISOPEN THEN
              CLOSE CR_CRAPEPR;
            END IF;
            OPEN CR_CRAPEPR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                            PR_NRCTREMP => RW_CRAPNRC.NRCTRRAT,
                            PR_NRDCONTA => RW_CRAPASS.NRDCONTA);
            FETCH CR_CRAPEPR
              INTO RW_CRAPEPR;
            IF CR_CRAPEPR%FOUND THEN
              IF RW_CRAPEPR.INLIQUID = 0 THEN
                /* Em aberto */
                IF RW_CRAPNRC.FLGATIVO = 0 THEN
                  /* Desativado */
                  UPDATE CRAPNRC
                     SET CRAPNRC.FLGATIVO = 1
                   WHERE CRAPNRC.ROWID = RW_CRAPNRC.ROWID;
                END IF;
              END IF;
            END IF;
            IF CR_CRAPEPR%ISOPEN THEN
              CLOSE CR_CRAPEPR;
            END IF;
          END IF;
        END IF;
      
        RATI0001.PC_DESATIVA_RATING(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                    PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                    PR_NRDCAIXA   => 999,
                                    PR_CDOPERAD   => 1,
                                    PR_RW_CRAPDAT => RW_CRAPDAT2,
                                    PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                    PR_TPCTRRAT   => 0,
                                    PR_NRCTRRAT   => 0,
                                    PR_FLGEFETI   => 'S',
                                    PR_IDSEQTTL   => 1,
                                    PR_IDORIGEM   => 1,
                                    PR_INUSATAB   => VR_INUSATAB,
                                    PR_NMDATELA   => 'RATI0001',
                                    PR_FLGERLOG   => 0,
                                    PR_DES_RETO   => VR_DES_RETO,
                                    PR_TAB_ERRO   => VR_TAB_ERRO);
      
        IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
          CLOSE CR_CRAPNRC_EFETIVO;
        END IF;
        OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER, RW_CRAPASS.NRDCONTA);
        FETCH CR_CRAPNRC_EFETIVO
          INTO RW_CRAPNRC_EFETIVO;
        IF CR_CRAPNRC_EFETIVO%FOUND THEN
          BEGIN
            VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                             PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                             PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                             PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
            UPDATE CRAPNRC
               SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
             WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
          
          END;
          PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                           'CONTRATO ATIVADO E EFETIVADO');
        ELSE
          IF CR_CRAPNRC%ISOPEN THEN
            CLOSE CR_CRAPNRC;
          END IF;
          OPEN CR_CRAPNRC(RW_CRAPASS.CDCOOPER,
                          RW_CRAPASS.NRDCONTA,
                          VR_TAB_RAT(VR_CHAVE).NRCTRRAT);
          FETCH CR_CRAPNRC
            INTO RW_CRAPNRC;
          IF CR_CRAPNRC%FOUND THEN
            VR_TEMLIM := 0;
            IF RW_CRAPNRC.FLGATIVO = 0 THEN
              BEGIN
                SELECT 1
                  INTO VR_TEMLIM
                  FROM CRAPLIM
                 WHERE CDCOOPER = RW_CRAPASS.CDCOOPER
                   AND NRDCONTA = RW_CRAPASS.NRDCONTA
                   AND NRCTRLIM = VR_TAB_RAT(VR_CHAVE).NRCTRRAT
                   AND INSITLIM = 2;
                UPDATE CRAPNRC
                   SET FLGATIVO = VR_TEMLIM
                 WHERE CRAPNRC.ROWID = RW_CRAPNRC.ROWID;
              
                RATI0001.PC_DESATIVA_RATING(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                            PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                            PR_NRDCAIXA   => 999,
                                            PR_CDOPERAD   => 1,
                                            PR_RW_CRAPDAT => RW_CRAPDAT2,
                                            PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                            PR_TPCTRRAT   => 0,
                                            PR_NRCTRRAT   => 0,
                                            PR_FLGEFETI   => 'S',
                                            PR_IDSEQTTL   => 1,
                                            PR_IDORIGEM   => 1,
                                            PR_INUSATAB   => VR_INUSATAB,
                                            PR_NMDATELA   => 'RATI0001',
                                            PR_FLGERLOG   => 0,
                                            PR_DES_RETO   => VR_DES_RETO,
                                            PR_TAB_ERRO   => VR_TAB_ERRO);
                IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                  CLOSE CR_CRAPNRC_EFETIVO;
                END IF;
                OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER,
                                        RW_CRAPASS.NRDCONTA);
                FETCH CR_CRAPNRC_EFETIVO
                  INTO RW_CRAPNRC_EFETIVO;
                IF CR_CRAPNRC_EFETIVO%FOUND THEN
                  IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_TAB_RAT(VR_CHAVE)
                    .NRCTRRAT THEN
                    IF VR_EXISTE THEN
                      BEGIN
                        VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                         PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                         PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                         PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                        UPDATE CRAPNRC
                           SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                         WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                      
                      END;
                      PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                       'CONTRATO EFETIVADO');
                      IF CR_CRAPNRC%ISOPEN THEN
                        CLOSE CR_CRAPNRC;
                      END IF;
                      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                        CLOSE CR_CRAPNRC_EFETIVO;
                      END IF;
                      VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                      CONTINUE;
                    ELSE
                      PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                       'CONTRATO CRIADO');
                      PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                                     RW_CRAPNRC_EFETIVO.ROWID || ''';' ||
                                     CHR(10));
                      IF CR_CRAPNRC%ISOPEN THEN
                        CLOSE CR_CRAPNRC;
                      END IF;
                      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                        CLOSE CR_CRAPNRC_EFETIVO;
                      END IF;
                      VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                      CONTINUE;
                    END IF;
                  ELSE
                    BEGIN
                      VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                       PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                       PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                       PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                      UPDATE CRAPNRC
                         SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                       WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                    
                    END;
                    PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                     'OUTRO CONTRATO EFETIVADO');
                    IF CR_CRAPNRC%ISOPEN THEN
                      CLOSE CR_CRAPNRC;
                    END IF;
                    IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                      CLOSE CR_CRAPNRC_EFETIVO;
                    END IF;
                    VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                    CONTINUE;
                  END IF;
                END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  NULL;
              END;
            END IF;
          ELSE
          
            RATI0001.PC_PROC_CALCULA(PR_CDCOOPER             => RW_CRAPASS.CDCOOPER,
                                     PR_CDAGENCI             => RW_CRAPASS.CDAGENCI,
                                     PR_NRDCAIXA             => 999,
                                     PR_CDOPERAD             => 1,
                                     PR_NRDCONTA             => RW_CRAPASS.NRDCONTA,
                                     PR_TPCTRATO             => VR_TIPO_CONTRATO,
                                     PR_NRCTRATO             => VR_TAB_RAT(VR_CHAVE)
                                                                .NRCTRRAT,
                                     PR_FLGCRIAR             => VR_FLGCRIAR,
                                     PR_IDORIGEM             => 1,
                                     PR_NMDATELA             => 'RATI0001',
                                     PR_INPROCES             => RW_CRAPDAT.INPROCES,
                                     PR_INSITRAT             => 1,
                                     PR_ROWIDNRC             => RW_CRAPNRC.ROWID,
                                     PR_TAB_RATING_SING      => PR_TAB_RATING_SING,
                                     PR_TAB_IMPRESS_RISCO_TL => VR_TAB_IMPRESS_RISCO_TL,
                                     PR_INDRISCO             => VR_INDRISCO,
                                     PR_NRNOTRAT             => VR_NRNOTRAT,
                                     PR_TAB_ERRO             => VR_TAB_ERRO,
                                     PR_DES_RETO             => VR_DES_RETO);
          
            IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
              CLOSE CR_CRAPNRC_EFETIVO;
            END IF;
            OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER,
                                    RW_CRAPASS.NRDCONTA);
            FETCH CR_CRAPNRC_EFETIVO
              INTO RW_CRAPNRC_EFETIVO;
            IF CR_CRAPNRC_EFETIVO%FOUND THEN
              IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_TAB_RAT(VR_CHAVE)
                .NRCTRRAT THEN
                IF VR_EXISTE THEN
                  BEGIN
                    VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                     PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                     PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                     PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                    UPDATE CRAPNRC
                       SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                     WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                  
                  END;
                  PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                   'CONTRATO EFETIVADO');
                  IF CR_CRAPNRC%ISOPEN THEN
                    CLOSE CR_CRAPNRC;
                  END IF;
                  IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                    CLOSE CR_CRAPNRC_EFETIVO;
                  END IF;
                  VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                  CONTINUE;
                ELSE
                  GENE0001.PC_PRINT('');
                  BEGIN
                    VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                     PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                     PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                     PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                    UPDATE CRAPNRC
                       SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                     WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                  
                  END;
                  PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                   'CONTRATO CRIADO');
                  PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                                 RW_CRAPNRC_EFETIVO.ROWID || ''';' ||
                                 CHR(10));
                  IF CR_CRAPNRC%ISOPEN THEN
                    CLOSE CR_CRAPNRC;
                  END IF;
                  IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                    CLOSE CR_CRAPNRC_EFETIVO;
                  END IF;
                  VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                  CONTINUE;
                END IF;
              ELSE
                BEGIN
                  VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                   PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                   PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                   PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                  UPDATE CRAPNRC
                     SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                   WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                
                END;
                PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                 'OUTRO CONTRATO EFETIVADO');
                IF CR_CRAPNRC%ISOPEN THEN
                  CLOSE CR_CRAPNRC;
                END IF;
                IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                  CLOSE CR_CRAPNRC_EFETIVO;
                END IF;
                VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                CONTINUE;
              END IF;
            END IF;
          
          END IF;
          IF CR_CRAPNRC%ISOPEN THEN
            CLOSE CR_CRAPNRC;
          END IF;
        
          IF CR_CRAPNRC_ROW%ISOPEN THEN
            CLOSE CR_CRAPNRC_ROW;
          END IF;
          OPEN CR_CRAPNRC_ROW(PR_ROWIDNRC => VR_ROWIDNRC);
          FETCH CR_CRAPNRC_ROW
            INTO RW_CRAPNRC_ROW;
          IF CR_CRAPNRC_ROW%FOUND THEN
            RATI0001.PC_PROC_CALCULA(PR_CDCOOPER             => RW_CRAPASS.CDCOOPER,
                                     PR_CDAGENCI             => RW_CRAPASS.CDAGENCI,
                                     PR_NRDCAIXA             => 999,
                                     PR_CDOPERAD             => 1,
                                     PR_NRDCONTA             => RW_CRAPASS.NRDCONTA,
                                     PR_TPCTRATO             => RW_CRAPNRC_ROW.TPCTRRAT,
                                     PR_NRCTRATO             => RW_CRAPNRC_ROW.NRCTRRAT,
                                     PR_FLGCRIAR             => VR_FLGCRIAR,
                                     PR_IDORIGEM             => 1,
                                     PR_NMDATELA             => 'RATI0001',
                                     PR_INPROCES             => RW_CRAPDAT.INPROCES,
                                     PR_INSITRAT             => 1,
                                     PR_ROWIDNRC             => RW_CRAPNRC_ROW.ROWID,
                                     PR_TAB_RATING_SING      => PR_TAB_RATING_SING,
                                     PR_TAB_IMPRESS_RISCO_TL => VR_TAB_IMPRESS_RISCO_TL,
                                     PR_INDRISCO             => VR_INDRISCO,
                                     PR_NRNOTRAT             => VR_NRNOTRAT,
                                     PR_TAB_ERRO             => VR_TAB_ERRO,
                                     PR_DES_RETO             => VR_DES_RETO);
          
            IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
              CLOSE CR_CRAPNRC_EFETIVO;
            END IF;
            OPEN CR_CRAPNRC_EFETIVO(RW_CRAPASS.CDCOOPER,
                                    RW_CRAPASS.NRDCONTA);
            FETCH CR_CRAPNRC_EFETIVO
              INTO RW_CRAPNRC_EFETIVO;
            IF CR_CRAPNRC_EFETIVO%FOUND THEN
              IF RW_CRAPNRC_EFETIVO.NRCTRRAT = VR_TAB_RAT(VR_CHAVE)
                .NRCTRRAT THEN
                IF VR_EXISTE THEN
                  BEGIN
                    VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                     PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                     PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                     PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                    UPDATE CRAPNRC
                       SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                     WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                  
                  END;
                  PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                   'CONTRATO EFETIVADO');
                  IF CR_CRAPNRC_ROW%ISOPEN THEN
                    CLOSE CR_CRAPNRC_ROW;
                  END IF;
                  IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                    CLOSE CR_CRAPNRC_EFETIVO;
                  END IF;
                  VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                  CONTINUE;
                ELSE
                  PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                   'CONTRATO CRIADO');
                  PC_ESCREVE_XML('DELETE FROM CRAPNRC WHERE CRAPNRC.ROWID = ''' ||
                                 RW_CRAPNRC_EFETIVO.ROWID || ''';' ||
                                 CHR(10));
                  IF CR_CRAPNRC_ROW%ISOPEN THEN
                    CLOSE CR_CRAPNRC_ROW;
                  END IF;
                  IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                    CLOSE CR_CRAPNRC_EFETIVO;
                  END IF;
                  VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                  CONTINUE;
                END IF;
              ELSE
                BEGIN
                  VR_DTMVTOLT := FN_BUSCA_DATA_CTR(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                   PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                   PR_NRCTRATO => RW_CRAPNRC_EFETIVO.NRCTRRAT,
                                                   PR_TPCTRATO => RW_CRAPNRC_EFETIVO.TPCTRRAT);
                  UPDATE CRAPNRC
                     SET CRAPNRC.DTEFTRAT = VR_DTMVTOLT
                   WHERE ROWID = RW_CRAPNRC_EFETIVO.ROWID;
                
                END;
                PC_IMPRIME_DADOS(RW_CRAPNRC_EFETIVO.ROWID,
                                 'OUTRO CONTRATO EFETIVADO');
                IF CR_CRAPNRC_ROW%ISOPEN THEN
                  CLOSE CR_CRAPNRC_ROW;
                END IF;
                IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
                  CLOSE CR_CRAPNRC_EFETIVO;
                END IF;
                VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
                CONTINUE;
              END IF;
            END IF;
          END IF;
          IF CR_CRAPNRC_ROW%ISOPEN THEN
            CLOSE CR_CRAPNRC_ROW;
          END IF;
        
          PC_IMPRIME_DADOS(NULL, 'NAO FOI POSSIVEL EFETIVAR');
        
        END IF;
        IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
          CLOSE CR_CRAPNRC_EFETIVO;
        END IF;
        VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
        CONTINUE;
      
      END IF;
      IF CR_CRAPNRC_EFETIVO%ISOPEN THEN
        CLOSE CR_CRAPNRC_EFETIVO;
      END IF;
    
    END IF;
  
    VR_CHAVE := VR_TAB_RAT.NEXT(VR_CHAVE);
  END LOOP;

  PC_ESCREVE_XML(' ', TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(VR_DES_XML,
                              VR_ARQ_PATH,
                              TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '_' ||
                              VR_ARQSAIDA,
                              NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  DBMS_LOB.CLOSE(VR_DES_XML);
  DBMS_LOB.FREETEMPORARY(VR_DES_XML);

  PC_ESCREVE_REL(' ', TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(VR_DES_REL,
                              VR_ARQ_PATH,
                              TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '_' ||
                              VR_ARQRELAT,
                              NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  DBMS_LOB.CLOSE(VR_DES_REL);
  DBMS_LOB.FREETEMPORARY(VR_DES_REL);

  COMMIT;
EXCEPTION
  WHEN VR_EXC_ERRO THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    DBMS_OUTPUT.PUT_LINE('Excecao ' || SQLERRM);
    ROLLBACK;
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    DBMS_OUTPUT.PUT_LINE('Excecao others ' || SQLERRM ||
                         RW_CRAPASS.NRDCONTA);
    ROLLBACK;
END;
