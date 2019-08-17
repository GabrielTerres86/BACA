DECLARE

  VR_NOME_BACA VARCHAR2(100);
  VR_NMDIRETO  VARCHAR2(4000);

  VR_EXC_ERRO  EXCEPTION;
  VR_EXC_SAIDA EXCEPTION;

  VR_TYP_SAIDA VARCHAR2(100);
  VR_DES_SAIDA VARCHAR2(1000);

  VR_NMARQLOG   VARCHAR2(100);
  VR_NMARQREL   VARCHAR2(100);
  VR_IND_ARQLOG UTL_FILE.FILE_TYPE;

  VR_VLUTILIZ NUMBER;
  VR_TEMNRC   NUMBER;

  VR_CDCOOPER       CRAPNRC.CDCOOPER%TYPE := 1;
  VR_CDAGENCI       CRAPASS.CDAGENCI%TYPE := 34;
  VR_NRDCONTA       CRAPNRC.NRDCONTA%TYPE := 874639;
  VR_VLUTLRAT       CRAPNRC.VLUTLRAT%TYPE;
  VR_DTEFTRAT       CRAPNRC.DTEFTRAT%TYPE;
  VR_NRCTRRAT       CRAPNRC.NRCTRRAT%TYPE;
  VR_TPCTRRAT       CRAPNRC.TPCTRRAT%TYPE;
  VR_FLGORIGE       CRAPNRC.FLGORIGE%TYPE;
  VR_INDRISCO       CRAPNRC.INDRISCO%TYPE;
  VR_CDOPERAD       CRAPNRC.CDOPERAD%TYPE;
  VR_NRNOTRAT       CRAPNRC.NRNOTRAT%TYPE;
  VR_DTMVTOLT       CRAPNRC.DTMVTOLT%TYPE;
  VR_NRNOTATL       CRAPNRC.NRNOTATL%TYPE;
  VR_INRISCTL       CRAPNRC.INRISCTL%TYPE;
  VR_PROGRESS_RECID CRAPNRC.PROGRESS_RECID%TYPE;

  VR_TAB_ERRO CECRED.GENE0001.TYP_TAB_ERRO;
  VR_DES_RETO VARCHAR2(4000);

  VR_CDCRITIC CRAPCRI.CDCRITIC%TYPE;
  VR_DSCRITIC VARCHAR2(4000);

  VR_RISATUAL VARCHAR2(300);

  CURSOR CR_CRAPASS(PR_CDCOOPER IN CRAPASS.CDCOOPER%TYPE,
                    PR_CDAGENCI IN CRAPASS.CDAGENCI%TYPE,
                    PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE) IS
    SELECT *
      FROM CRAPASS C
     WHERE C.CDCOOPER = PR_CDCOOPER
       AND C.CDAGENCI = PR_CDAGENCI
       AND C.NRDCONTA = PR_NRDCONTA
       AND ((SELECT MAX(INPREJUZ)
               FROM CRAPEPR EPR
              WHERE EPR.CDCOOPER = C.CDCOOPER
                AND EPR.NRDCONTA = C.NRDCONTA
                AND EPR.INPREJUZ = 1
                AND EPR.VLSDPREJ > 0) = 1 OR C.DTELIMIN IS NULL);
  RW_CRAPASS CR_CRAPASS%ROWTYPE;

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

  VR_DES_XML        CLOB;
  VR_TEXTO_COMPLETO VARCHAR2(32600);
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE PC_ESCREVE_XML(PR_DES_DADOS IN VARCHAR2,
                           PR_FECHA_XML IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    GENE0002.PC_ESCREVE_XML(VR_DES_XML,
                            VR_TEXTO_COMPLETO,
                            PR_DES_DADOS,
                            PR_FECHA_XML);
  END;

BEGIN
  VR_NOME_BACA := 'DESATIVA_RATING_874639';
  VR_NMDIRETO  := '/micros/cpd/bacas/INC0031615';

  -- Incluir nome do módulo logado
  GENE0001.PC_INFORMA_ACESSO(PR_MODULE => VR_NOME_BACA, PR_ACTION => NULL);

  IF NOT GENE0001.FN_EXIS_DIRETORIO(VR_NMDIRETO) THEN
    -- Efetuar a criação do mesmo
    GENE0001.PC_OSCOMMAND_SHELL(PR_DES_COMANDO => 'mkdir ' || VR_NMDIRETO ||
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
                                                  VR_NMDIRETO ||
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

  VR_NMARQREL := VR_NOME_BACA || '.txt';
  VR_NMARQLOG := 'LOG_' || VR_NOME_BACA || '_' ||
                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '.txt';
  /* ############# LOG ########################### */
  --Criar arquivo de log
  GENE0001.PC_ABRE_ARQUIVO(PR_NMDIRETO => VR_NMDIRETO --> Diretorio do arquivo
                          ,
                           PR_NMARQUIV => VR_NMARQLOG --> Nome do arquivo
                          ,
                           PR_TIPABERT => 'W' --> modo de abertura (r,w,a)
                          ,
                           PR_UTLFILEH => VR_IND_ARQLOG --> handle do arquivo aberto
                          ,
                           PR_DES_ERRO => VR_DSCRITIC); --> erro
  -- em caso de crítica
  IF VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_ERRO;
  END IF;

  GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Inicio Processo');
  GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Inicio ' || VR_NOME_BACA);

  -- Inicializar o CLOB
  VR_DES_XML := NULL;
  DBMS_LOB.CREATETEMPORARY(VR_DES_XML, TRUE);
  DBMS_LOB.OPEN(VR_DES_XML, DBMS_LOB.LOB_READWRITE);
  VR_TEXTO_COMPLETO := NULL;

  OPEN CR_CRAPDAT(PR_CDCOOPER => VR_CDCOOPER);
  FETCH CR_CRAPDAT
    INTO RW_CRAPDAT;
  CLOSE CR_CRAPDAT;

  FOR RW_CRAPASS IN CR_CRAPASS(VR_CDCOOPER, VR_CDAGENCI, VR_NRDCONTA) LOOP
  
    GENE0005.PC_SALDO_UTILIZA(PR_CDCOOPER    => RW_CRAPASS.CDCOOPER --> Código da Cooperativa
                             ,
                              PR_TPDECONS    => 2 --> Tipo da consulta (Ver observações da rotina)
                             ,
                              PR_CDAGENCI    => RW_CRAPASS.CDAGENCI --> Código da agência
                             ,
                              PR_NRDCAIXA    => 999 --> Número do caixa
                             ,
                              PR_CDOPERAD    => 1 --> Código do operador
                             ,
                              PR_NRDCONTA    => RW_CRAPASS.NRDCONTA --> OU Consulta pela conta
                             ,
                              PR_NRCPFCGC    => NULL --> OU Consulta pelo Numero do cpf ou cgc do associado
                             ,
                              PR_IDSEQTTL    => 1 --> Sequencia de titularidade da conta
                             ,
                              PR_IDORIGEM    => 1 --> Indicador da origem da chamada
                             ,
                              PR_DSCTRLIQ    => '' --> Numero do contrato de liquidacao
                             ,
                              PR_CDPROGRA    => 'RATI0001' --> Código do programa chamador
                             ,
                              PR_TAB_CRAPDAT => RW_CRAPDAT --> Tipo de registro de datas
                             ,
                              PR_INUSATAB    => FALSE --> Indicador de utilização da tabela de juros
                             ,
                              PR_VLUTILIZ    => VR_VLUTILIZ --> Valor utilizado do credito
                             ,
                              PR_CDCRITIC    => VR_CDCRITIC --> Código de retorno da critica
                             ,
                              PR_DSCRITIC    => VR_DSCRITIC); --> Mensagem de retorno da critica
  
    IF VR_DSCRITIC IS NOT NULL THEN
      PC_ESCREVE_XML('SALDO - Coop: ' || RW_CRAPASS.CDCOOPER ||
                     ' - Conta: ' || RW_CRAPASS.NRDCONTA || ' - ' ||
                     VR_DSCRITIC || CHR(10));
      CONTINUE;
    END IF;
  
    VR_RISATUAL := '';
    VR_RISATUAL := RISC0004.FN_TRADUZ_RISCO(RISC0004.FN_BUSCA_RISCO_ULT_CENTRAL(RW_CRAPASS.CDCOOPER,
                                                                                RW_CRAPASS.NRDCONTA,
                                                                                RW_CRAPDAT.DTULTDMA));
  
    IF VR_VLUTILIZ IS NOT NULL THEN
      IF VR_VLUTILIZ < 50000 THEN
        BEGIN
          SELECT C.CDCOOPER,
                 C.NRDCONTA,
                 C.VLUTLRAT,
                 C.DTEFTRAT,
                 C.DTMVTOLT,
                 C.NRCTRRAT,
                 C.TPCTRRAT,
                 C.FLGORIGE,
                 C.INDRISCO,
                 C.CDOPERAD,
                 C.NRNOTRAT,
                 C.NRNOTATL,
                 C.INRISCTL,
                 C.PROGRESS_RECID
            INTO VR_CDCOOPER,
                 VR_NRDCONTA,
                 VR_VLUTLRAT,
                 VR_DTEFTRAT,
                 VR_DTMVTOLT,
                 VR_NRCTRRAT,
                 VR_TPCTRRAT,
                 VR_FLGORIGE,
                 VR_INDRISCO,
                 VR_CDOPERAD,
                 VR_NRNOTRAT,
                 VR_NRNOTATL,
                 VR_INRISCTL,
                 VR_PROGRESS_RECID
            FROM CRAPNRC C
           WHERE INSITRAT = 2
             AND FLGATIVO = 1
             AND CDCOOPER = RW_CRAPASS.CDCOOPER
             AND NRDCONTA = RW_CRAPASS.NRDCONTA;
        
          PC_ESCREVE_XML('UPDATE crapnrc ' || 'SET crapnrc.flgativo = 1' ||
                         ', crapnrc.insitrat = 2' ||
                         ', crapnrc.cdcooper = ' || VR_CDCOOPER ||
                         ', crapnrc.nrdconta = ' || VR_NRDCONTA ||
                         ', crapnrc.vlutlrat = ''' || VR_VLUTLRAT || '''' ||
                         ', crapnrc.dteftrat = ''' ||
                         TO_CHAR(VR_DTEFTRAT, 'DD/MM/YYYY') || '''' ||
                         ', crapnrc.DTMVTOLT = ''' ||
                         TO_CHAR(VR_DTMVTOLT, 'DD/MM/YYYY') || '''' ||
                         ', crapnrc.nrctrrat = ' || VR_NRCTRRAT ||
                         ', crapnrc.tpctrrat = ' || VR_TPCTRRAT ||
                         ', crapnrc.INDRISCO = ''' || VR_INDRISCO || '''' ||
                         ', crapnrc.CDOPERAD = ' || VR_CDOPERAD ||
                         ', crapnrc.NRNOTRAT = ' || VR_NRNOTRAT ||
                         ', crapnrc.NRNOTATL = ' || VR_NRNOTATL ||
                         ', crapnrc.INRISCTL = ''' || VR_INRISCTL || '''' ||
                         ', crapnrc.flgorige = ' || VR_FLGORIGE || ' ' ||
                         'WHERE crapnrc.progress_recid = ' ||
                         VR_PROGRESS_RECID || ';' || CHR(10));
        
          -- Grava os dados do relatorio
          PC_ESCREVE_XML('MENOR' || ';' || VR_CDCOOPER || ';' || -- Cooper
                         RW_CRAPASS.CDAGENCI || ';' || -- PA
                         VR_NRDCONTA || ';' || -- Conta
                         VR_VLUTLRAT || ';' || -- Valor Rating
                         TO_CHAR(VR_DTEFTRAT, 'DD/MM/YYYY') || ';' || -- Efetivacao
                         VR_VLUTILIZ || ';' || -- Divida Atual
                         VR_RISATUAL || ';' || CHR(10)); -- Ult Fechamento
        
          RATI0001.PC_DESATIVA_RATING(PR_CDCOOPER   => RW_CRAPASS.CDCOOPER,
                                      PR_CDAGENCI   => RW_CRAPASS.CDAGENCI,
                                      PR_NRDCAIXA   => 999,
                                      PR_CDOPERAD   => 1,
                                      PR_RW_CRAPDAT => RW_CRAPDAT,
                                      PR_NRDCONTA   => RW_CRAPASS.NRDCONTA,
                                      PR_TPCTRRAT   => VR_TPCTRRAT,
                                      PR_NRCTRRAT   => VR_NRCTRRAT,
                                      PR_FLGEFETI   => 'N',
                                      PR_IDSEQTTL   => 1,
                                      PR_IDORIGEM   => 1,
                                      PR_INUSATAB   => FALSE,
                                      PR_NMDATELA   => 'RATI0001',
                                      PR_FLGERLOG   => 'S',
                                      PR_DES_RETO   => VR_DES_RETO,
                                      PR_TAB_ERRO   => VR_TAB_ERRO);
          COMMIT;
        
          BEGIN
            SELECT 1
              INTO VR_TEMNRC
              FROM CRAPNRC C
             WHERE INSITRAT = 2
               AND FLGATIVO = 1
               AND CDCOOPER = RW_CRAPASS.CDCOOPER
               AND NRDCONTA = RW_CRAPASS.NRDCONTA;
          
            PC_ESCREVE_XML('SELECT * ' || '  FROM CRAPNRC ' ||
                           ' WHERE INSITRAT = 2' || '   AND FLGATIVO = 1' ||
                           '   AND CDCOOPER = ' || RW_CRAPASS.CDCOOPER ||
                           '   AND NRDCONTA = ' || RW_CRAPASS.NRDCONTA || ';' ||
                           CHR(10));
          
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              PC_ESCREVE_XML('DESATIVADO - Coop: ' || RW_CRAPASS.CDCOOPER ||
                             ' - Conta: ' || RW_CRAPASS.NRDCONTA ||
                             CHR(10));
          END;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            CONTINUE;
          WHEN OTHERS THEN
            CECRED.PC_INTERNAL_EXCEPTION;
            PC_ESCREVE_XML('ROLLBACK - Coop: ' || RW_CRAPASS.CDCOOPER ||
                           ' - Conta: ' || RW_CRAPASS.NRDCONTA || CHR(10));
            ROLLBACK;
        END;
      ELSE
        BEGIN
          SELECT 1
            INTO VR_TEMNRC
            FROM CRAPNRC
           WHERE INSITRAT = 2
             AND FLGATIVO = 1
             AND CDCOOPER = RW_CRAPASS.CDCOOPER
             AND NRDCONTA = RW_CRAPASS.NRDCONTA
             AND ROWNUM = 1;
          PC_ESCREVE_XML('ATIVO' || ';' || RW_CRAPASS.CDCOOPER || ';' || -- Cooper
                         RW_CRAPASS.CDAGENCI || ';' || -- PA
                         RW_CRAPASS.NRDCONTA || ';' || -- Conta
                         ';' || -- Valor Rating
                         ';' || -- Efetivacao
                         VR_VLUTILIZ || ';' || -- Divida Atual
                         VR_RISATUAL || ';' || CHR(10)); -- Ult Fechamento
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              -- Grava os dados do relatorio
              PC_ESCREVE_XML('MAIOR' || ';' || RW_CRAPASS.CDCOOPER || ';' || -- Cooper
                             RW_CRAPASS.CDAGENCI || ';' || -- PA
                             RW_CRAPASS.NRDCONTA || ';' || -- Conta
                             ';' || -- Valor Rating
                             ';' || -- Efetivacao
                             VR_VLUTILIZ || ';' || -- Divida Atual
                             VR_RISATUAL || ';' || CHR(10)); -- Ult Fechamento
            END;
        END;
      END IF;
    END IF;
  END LOOP;

  PC_ESCREVE_XML(' ', TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(VR_DES_XML,
                              VR_NMDIRETO,
                              TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') || '_' ||
                              VR_NMARQREL,
                              NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  DBMS_LOB.CLOSE(VR_DES_XML);
  DBMS_LOB.FREETEMPORARY(VR_DES_XML);

  GENE0001.PC_ESCR_LINHA_ARQUIVO(VR_IND_ARQLOG,
                                 TO_CHAR(SYSDATE, 'ddmmyyyy_hh24miss') ||
                                 ' - Fim Processo com sucesso');
  GENE0001.PC_FECHA_ARQUIVO(PR_UTLFILEH => VR_IND_ARQLOG); --> Handle do arquivo aberto;

EXCEPTION
  WHEN VR_EXC_SAIDA THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    RAISE_APPLICATION_ERROR(-20001,
                            'ERRO NA EXECUCAO, AVISAR SOLICITANTE: ' ||
                            VR_DSCRITIC);
    COMMIT;
  WHEN VR_EXC_ERRO THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    RAISE_APPLICATION_ERROR(-20001,
                            'ERRO NA EXECUCAO, AVISAR SOLICITANTE: ' ||
                            VR_DSCRITIC);
    COMMIT;
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    RAISE_APPLICATION_ERROR(-20001,
                            'ERRO NA EXECUCAO, AVISAR SOLICITANTE: ' ||
                            SQLERRM);
    COMMIT;
END;
