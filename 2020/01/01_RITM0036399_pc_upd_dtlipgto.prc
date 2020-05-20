CREATE OR REPLACE PROCEDURE CECRED.PC_UPDATE_DTLIPGTO_CRAPCOB_AGE(PR_CDCOOPER IN  CRAPCOB.CDCOOPER%TYPE
                                                                 ,PR_CDAGENCI IN  CRAPAGE.CDAGENCI%TYPE
                                                                 ,PR_IDPARALE IN  INTEGER
                                                                 ,PR_IDPROGRA IN  CRAPPRG.CDPROGRA%TYPE
                                                                 ,PR_CDCRITIC OUT NUMBER
                                                                 ,PR_DSCRITIC OUT VARCHAR2) IS

  CURSOR CR_CRAPASS(PR_CDCOOPER CRAPCOB.CDCOOPER%TYPE
                   ,PR_CDAGENCI CRAPAGE.CDAGENCI%TYPE) IS
    SELECT CRAPASS.NRDCONTA
      FROM CRAPASS
     WHERE CRAPASS.CDCOOPER = PR_CDCOOPER
       AND CRAPASS.CDAGENCI = PR_CDAGENCI;

  CURSOR CR_CRAPCOB(PR_CDCOOPER CRAPCOB.CDCOOPER%TYPE
                   ,PR_NRDCONTA CRAPCOB.NRDCONTA%TYPE) IS
    SELECT CRAPCOB.ROWID,
           CASE CRAPCOB.INSERASA
             WHEN 0 THEN
              CASE CRAPCOB.INSITCRT
                WHEN 0 THEN
                 (CRAPCOB.DTVENCTO +
                 NVL(DECODE(CRAPCCO.DSORGARQ,
                             'EMPRESTIMO',
                             0,
                             'DESCONTO DE TITULO',
                             0,
                             'ACORDO',
                             CRAPCCO.QTDECATE,
                             CRAPCEB.QTDECPRZ),
                      CRAPCCO.QTDECINI))
                WHEN 4 THEN
                 (CRAPCOB.DTVENCTO +
                 NVL(DECODE(CRAPCCO.DSORGARQ,
                             'EMPRESTIMO',
                             0,
                             'DESCONTO DE TITULO',
                             0,
                             'ACORDO',
                             CRAPCCO.QTDECATE,
                             CRAPCEB.QTDECPRZ),
                      CRAPCCO.QTDECINI))
                ELSE
                 ADD_MONTHS((CRAPCOB.DTVENCTO +
                            NVL(DECODE(CRAPCCO.DSORGARQ,
                                        'EMPRESTIMO',
                                        0,
                                        'DESCONTO DE TITULO',
                                        0,
                                        'ACORDO',
                                        CRAPCCO.QTDECATE,
                                        CRAPCEB.QTDECPRZ),
                                 CRAPCCO.QTDECINI)),
                            60)
              END
             ELSE
              ADD_MONTHS((CRAPCOB.DTVENCTO +
                         NVL(DECODE(CRAPCCO.DSORGARQ,
                                     'EMPRESTIMO',
                                     0,
                                     'DESCONTO DE TITULO',
                                     0,
                                     'ACORDO',
                                     CRAPCCO.QTDECATE,
                                     CRAPCEB.QTDECPRZ),
                              CRAPCCO.QTDECINI)),
                         60)
           END DTLIPGTO
      FROM CRAPCOB, CRAPCEB, CRAPCCO
     WHERE CRAPCOB.CDCOOPER = CRAPCEB.CDCOOPER(+)
       AND CRAPCOB.NRCNVCOB = CRAPCEB.NRCONVEN(+)
       AND CRAPCOB.NRDCONTA = CRAPCEB.NRDCONTA(+)
       AND CRAPCCO.CDCOOPER = CRAPCOB.CDCOOPER
       AND CRAPCCO.NRCONVEN = CRAPCOB.NRCNVCOB
       AND CRAPCCO.CDDBANCO = 85
       AND CRAPCOB.NRDIDENT > 0
       AND CRAPCOB.CDCOOPER = PR_CDCOOPER
       AND CRAPCOB.NRDCONTA = PR_NRDCONTA
       AND CRAPCOB.INCOBRAN = 0;

  TYPE TYP_DECPRAZO IS RECORD(
    COBROWID ROWID,
    DTLIPGTO CRAPCOB.DTLIPGTO%TYPE);
  TYPE TYP_DECPRAZOS IS TABLE OF TYP_DECPRAZO INDEX BY BINARY_INTEGER;
  VR_PRAZOS TYP_DECPRAZOS;

  VR_EXC_SAIDA EXCEPTION;
  VR_DSPARAME  VARCHAR2(1000);
  VR_COUNT     NUMBER := 0;

  VR_CDPROGRA TBGEN_PRGLOG.CDPROGRAMA%TYPE := 'DTLIPGTO_' ||
                                              LPAD(PR_IDPROGRA, 3, '0') || '_' ||
                                              LPAD(PR_CDCOOPER, 2, '0') || '_' ||
                                              LPAD(PR_CDAGENCI, 3, '0');
  VR_IDPRGLOG TBGEN_PRGLOG.IDPRGLOG%TYPE   := 0;

BEGIN

  PR_CDCRITIC := 0;
  PR_DSCRITIC := NULL;

  PC_LOG_PROGRAMA(PR_DSTIPLOG   => 'I'
                 ,PR_CDPROGRAMA => VR_CDPROGRA
                 ,PR_CDCOOPER   => 0
                 ,PR_TPEXECUCAO => 0
                 ,PR_IDPRGLOG   => VR_IDPRGLOG);

  VR_DSPARAME := '. pr_cdcooper:' || PR_CDCOOPER
              || ', pr_cdagenci:' || PR_CDAGENCI
              || ', pr_idparale:' || PR_IDPARALE
              || ', pr_idprogra:' || PR_IDPROGRA;

  VR_COUNT := 0;
  FOR RW_CRAPASS IN CR_CRAPASS(PR_CDCOOPER => PR_CDCOOPER
                              ,PR_CDAGENCI => PR_CDAGENCI) LOOP

    OPEN CR_CRAPCOB(PR_CDCOOPER => PR_CDCOOPER
                   ,PR_NRDCONTA => RW_CRAPASS.NRDCONTA);
    LOOP
      FETCH CR_CRAPCOB BULK COLLECT
        INTO VR_PRAZOS LIMIT 1000;

      VR_COUNT := VR_COUNT + VR_PRAZOS.COUNT;

      BEGIN
        FORALL VR_IND IN 1..VR_PRAZOS.COUNT SAVE EXCEPTIONS
          UPDATE CRAPCOB
             SET DTLIPGTO = VR_PRAZOS(VR_IND).DTLIPGTO
           WHERE ROWID = VR_PRAZOS(VR_IND).COBROWID;
      EXCEPTION
        WHEN OTHERS THEN
          FOR VR_ERR IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
            PC_LOG_PROGRAMA(PR_DSTIPLOG      => 'E' -- Erro
                           ,PR_CDPROGRAMA    => VR_CDPROGRA
                           ,PR_CDCOOPER      => PR_CDCOOPER
                           ,PR_TPEXECUCAO    => 2 -- Job
                           ,PR_TPOCORRENCIA  => 4 -- Informação
                           ,PR_CDCRITICIDADE => 0 -- Baixa
                           ,PR_CDMENSAGEM    => 0
                           ,PR_DSMENSAGEM    => SQL%BULK_EXCEPTIONS(VR_ERR).ERROR_INDEX
                                     || ': ' || SQL%BULK_EXCEPTIONS(VR_ERR).ERROR_CODE
                                     || '. ' || VR_DSPARAME
                           ,PR_IDPRGLOG      => VR_IDPRGLOG);
          END LOOP;
      END;

      COMMIT;

      EXIT WHEN VR_PRAZOS.COUNT = 0;

    END LOOP;
    IF CR_CRAPCOB%ISOPEN THEN
      CLOSE CR_CRAPCOB;
    END IF;

  END LOOP;

  PC_LOG_PROGRAMA(PR_DSTIPLOG     => 'O'
                 ,PR_CDPROGRAMA   => VR_CDPROGRA
                 ,PR_CDCOOPER     => PR_CDCOOPER
                 ,PR_TPEXECUCAO   => 2
                 ,PR_TPOCORRENCIA => 4
                 ,PR_DSMENSAGEM   => 'Titulos: ' || LPAD(VR_COUNT, 12, '0')
                         || ' - ' || 'Cooperativa: ' || LPAD(PR_CDCOOPER, 2, '0')
                         || ' - ' || 'Agencia: ' || LPAD(PR_CDAGENCI, 3, '0')
                 ,PR_IDPRGLOG     => VR_IDPRGLOG);

  PC_LOG_PROGRAMA(PR_DSTIPLOG   => 'F'
                 ,PR_CDPROGRAMA => VR_CDPROGRA
                 ,PR_CDCOOPER   => 0
                 ,PR_TPEXECUCAO => 0
                 ,PR_FLGSUCESSO => 1
                 ,PR_IDPRGLOG   => VR_IDPRGLOG);

  COMMIT;

  -- Encerrar o job do processamento paralelo dessa procedure
  GENE0001.PC_ENCERRA_PARALELO(PR_IDPARALE => PR_IDPARALE
                              ,PR_IDPROGRA => PR_IDPROGRA
                              ,PR_DES_ERRO => PR_DSCRITIC);
  -- Testar saida com erro
  IF PR_DSCRITIC IS NOT NULL THEN
    -- Levantar exceçao
    RAISE VR_EXC_SAIDA;
  END IF;

EXCEPTION
  WHEN VR_EXC_SAIDA THEN
    NULL;
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION(PR_COMPLEME => 'DTLIPGTO: ' || VR_DSPARAME);
END PC_UPDATE_DTLIPGTO_CRAPCOB_AGE;
/
