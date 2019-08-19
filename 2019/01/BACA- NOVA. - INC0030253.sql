DECLARE

  CURSOR CR_CRAPASS IS
    SELECT *
      FROM CRAPASS S
     WHERE S.CDCOOPER = 1
       AND S.NRDCONTA = 1526588;
  RW_CRAPASS CR_CRAPASS%ROWTYPE;    
  
  VR_CDCRITIC PLS_INTEGER; --> Código da crítica
  VR_DSCRITIC VARCHAR2(4000);
  VR_NMDCAMPO VARCHAR2(4000);
  VR_DES_ERRO VARCHAR2(4000);
  VR_IDPRGLOG TBGEN_PRGLOG.IDPRGLOG%TYPE;

BEGIN
-- alterando o tipo de devolução para 4 pra deixar devolver as cotas do cooperado  
  UPDATE TBCOTAS_DEVOLUCAO D 
  SET D.TPDEVOLUCAO = 4  
    WHERE  D.CDCOOPER = 1
      AND  D.NRDCONTA IN (1526588,6663435, 9154167);    

  FOR RW_CRAPASS IN CR_CRAPASS LOOP
    -- Call the procedure
    CECRED.CADA0003.PC_EFETUAR_DESLIGAMENTO_BACEN(PR_CDCOOPER => RW_CRAPASS.CDCOOPER,
                                                  PR_NRDCONTA => RW_CRAPASS.NRDCONTA,
                                                  PR_IDORIGEM => 1,
                                                  PR_CDOPERAD => 1,
                                                  PR_NRDCAIXA => 999,
                                                  PR_NMDATELA => 'INC0030253',
                                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                                  PR_CDCRITIC => VR_CDCRITIC,
                                                  PR_DSCRITIC => VR_DSCRITIC,
                                                  PR_NMDCAMPO => VR_NMDCAMPO,
                                                  PR_DES_ERRO => VR_DES_ERRO);
  
    VR_DSCRITIC := 'CDCRITIC = ' || VR_CDCRITIC || ' DSCRITIC = ' ||
                   VR_DSCRITIC || ' NMDCAMPO = ' || VR_NMDCAMPO;
    CECRED.PC_LOG_PROGRAMA(PR_DSTIPLOG      => 'E',
                           PR_CDPROGRAMA    => 'INC0030253',
                           PR_CDCOOPER      => RW_CRAPASS.CDCOOPER,
                           PR_TPEXECUCAO    => 0,
                           PR_TPOCORRENCIA  => 2,
                           PR_CDCRITICIDADE => 0,
                           PR_CDMENSAGEM    => 0,
                           PR_DSMENSAGEM    => 'Agencia: ' ||
                                               RW_CRAPASS.CDAGENCI ||
                                               ' Module: INC0030253 ' ||
                                               VR_DSCRITIC,
                           PR_IDPRGLOG      => VR_IDPRGLOG);
  
    COMMIT;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION(PR_COMPLEME => '' || VR_CDCRITIC || ' - ' ||
                                                VR_DSCRITIC || ' - ' ||
                                                SQLERRM);
    ROLLBACK;
END;