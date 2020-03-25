CREATE OR REPLACE PROCEDURE CECRED.PC_BAIXA_DECPRZ_DTLIPGTO(PR_CDCOOPER IN CRAPCOB.CDCOOPER%TYPE
                                                           ,PR_NRCNVCOB IN CRAPCOB.NRCNVCOB%TYPE
                                                           ,PR_IDPARALE IN INTEGER
                                                           ,PR_IDPROGRA IN CRAPPRG.CDPROGRA%TYPE
                                                           ,PR_CDCRITIC OUT NUMBER
                                                           ,PR_DSCRITIC OUT VARCHAR2) IS

  CURSOR CR_CRAPCOP(PR_CDCOOPER CRAPCOB.CDCOOPER%TYPE) IS
    SELECT CDBCOCTL, CDAGECTL
      FROM CRAPCOP
     WHERE CRAPCOP.CDCOOPER = PR_CDCOOPER;
  RW_CRAPCOP CR_CRAPCOP%ROWTYPE;

  --Selecionar titulos baixa decurso prazo
  CURSOR CR_CRAPCOB_ABERTO(PR_CDCOOPER CRAPCCO.CDCOOPER%TYPE
                          ,PR_NRCONVEN CRAPCCO.NRCONVEN%TYPE
                          ,PR_DTMVTOLT CRAPDAT.DTMVTOLT%TYPE) IS
    SELECT CRAPCOB.ROWID
      FROM CRAPCOB, CRAPCEB
     WHERE CRAPCEB.CDCOOPER = PR_CDCOOPER
       AND CRAPCEB.NRCONVEN = PR_NRCONVEN
       AND CRAPCOB.CDCOOPER = CRAPCEB.CDCOOPER
       AND CRAPCOB.NRDCONTA = CRAPCEB.NRDCONTA
       AND CRAPCOB.NRCNVCOB = CRAPCEB.NRCONVEN
       AND CRAPCOB.DTLIPGTO < PR_DTMVTOLT
       AND CRAPCOB.INCOBRAN = 0;

  TYPE TYP_DECPRAZO IS RECORD(
    COBROWID ROWID);
  TYPE TYP_DECPRAZOS IS TABLE OF TYP_DECPRAZO INDEX BY BINARY_INTEGER;
  VR_PRAZOS TYP_DECPRAZOS;

  VR_DSERRO    VARCHAR2(100);
  VR_EXC_SAIDA EXCEPTION;
  VR_DSPARAME  VARCHAR2(1000);
  VR_COUNT     NUMBER := 0;
  VR_DTMVTOLT  CRAPDAT.DTMVTOLT%TYPE := TRUNC(SYSDATE) - 1;

  VR_CDPROGRA TBGEN_PRGLOG.CDPROGRAMA%TYPE := 'DTLIPGTO_' ||
                                              LPAD(PR_IDPROGRA, 3, '0') || '_' ||
                                              LPAD(PR_CDCOOPER, 2, '0') || '_' ||
                                              LPAD(PR_NRCNVCOB, 8, '0');
  VR_IDPRGLOG TBGEN_PRGLOG.IDPRGLOG%TYPE   := 0;

BEGIN

  PC_LOG_PROGRAMA(PR_DSTIPLOG   => 'I'
                 ,PR_CDPROGRAMA => VR_CDPROGRA
                 ,PR_CDCOOPER   => 0
                 ,PR_TPEXECUCAO => 0
                 ,PR_IDPRGLOG   => VR_IDPRGLOG);

  VR_DSPARAME := '. pr_cdcooper:' || PR_CDCOOPER
              || ', pr_nrcnvcob:' || PR_NRCNVCOB
              || ', pr_idparale:' || PR_IDPARALE
              || ', pr_idprogra:' || PR_IDPROGRA;

  OPEN  CR_CRAPCOP(PR_CDCOOPER);
  FETCH CR_CRAPCOP INTO RW_CRAPCOP;
  CLOSE CR_CRAPCOP;

  VR_COUNT := 0;
  OPEN CR_CRAPCOB_ABERTO(PR_CDCOOPER => PR_CDCOOPER
                        ,PR_NRCONVEN => PR_NRCNVCOB
                        ,PR_DTMVTOLT => VR_DTMVTOLT);
  LOOP
    FETCH CR_CRAPCOB_ABERTO BULK COLLECT
      INTO VR_PRAZOS LIMIT 1000;

    VR_COUNT := VR_COUNT + VR_PRAZOS.COUNT;

    BEGIN
      FORALL VR_IND IN 1..VR_PRAZOS.COUNT SAVE EXCEPTIONS
        UPDATE CRAPCOB
           SET INCOBRAN = 3, DTDBAIXA = VR_DTMVTOLT
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
                         ,PR_DSMENSAGEM    => SQL%BULK_EXCEPTIONS(VR_ERR).ERROR_INDEX || ': '
                                           || SQL%BULK_EXCEPTIONS(VR_ERR).ERROR_CODE || '. '
                                           || VR_DSPARAME
                         ,PR_IDPRGLOG      => VR_IDPRGLOG);
        END LOOP;
    END;

    FOR VR_IND IN 1..VR_PRAZOS.COUNT LOOP
    
      -- Criar log de baixa
      PAGA0001.PC_CRIA_LOG_COBRANCA(PR_IDTABCOB => VR_PRAZOS(VR_IND).COBROWID
                                   ,PR_CDOPERAD => '1'
                                   ,PR_DTMVTOLT => VR_DTMVTOLT
                                   ,PR_DSMENSAG => 'Titulo baixado por decurso de prazo'
                                   ,PR_DES_ERRO => VR_DSERRO
                                   ,PR_DSCRITIC => PR_DSCRITIC);
    
      -- Preparar Lote de Retorno Cooperado
      COBR0006.PC_PREP_RETORNO_COOPER_90(PR_IDREGCOB => VR_PRAZOS(VR_IND).COBROWID --ROWID da cobranca
                                        ,PR_CDOCORRE => 09 -- Baixa --Codigo Ocorrencia
                                        ,PR_CDMOTIVO => '09' -- Comandada pelo Banco --Codigo Motivo
                                        ,PR_VLTARIFA => 0
                                        ,PR_CDBCOCTL => RW_CRAPCOP.CDBCOCTL
                                        ,PR_CDAGECTL => RW_CRAPCOP.CDAGECTL
                                        ,PR_DTMVTOLT => VR_DTMVTOLT --Data Movimento
                                        ,PR_CDOPERAD => 1 --Codigo Operador
                                        ,PR_NRREMASS => 0 --Numero Remessa
                                        ,PR_CDCRITIC => PR_CDCRITIC --Codigo Critica
                                        ,PR_DSCRITIC => PR_DSCRITIC); --Descricao Critica
    
    END LOOP;

    COMMIT;

    EXIT WHEN VR_PRAZOS.COUNT = 0;

  END LOOP;
  IF CR_CRAPCOB_ABERTO%ISOPEN THEN
    CLOSE CR_CRAPCOB_ABERTO;
  END IF;
      
  PC_LOG_PROGRAMA(PR_DSTIPLOG     => 'O'
                 ,PR_CDPROGRAMA   => VR_CDPROGRA
                 ,PR_CDCOOPER     => PR_CDCOOPER
                 ,PR_TPEXECUCAO   => 2
                 ,PR_TPOCORRENCIA => 4
                 ,PR_DSMENSAGEM   => 'Titulos: '     || LPAD(VR_COUNT, 12, '0') || ' - '
                                  || 'Cooperativa: ' || LPAD(PR_CDCOOPER, 2, '0') || ' - '
                                  || 'Convenio: '    || LPAD(PR_NRCNVCOB, 8, '0')
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
    CECRED.PC_INTERNAL_EXCEPTION(PR_COMPLEME => VR_DSPARAME);
end PC_BAIXA_DECPRZ_DTLIPGTO;
/
