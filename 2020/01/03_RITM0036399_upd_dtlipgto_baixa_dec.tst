PL/SQL Developer Test script 3.0
198
DECLARE

  CURSOR CR_CRAPAGE IS
    SELECT AGE.CDCOOPER, AGE.CDAGENCI
      FROM CRAPAGE AGE, CRAPCOP COP
     WHERE AGE.CDCOOPER = COP.CDCOOPER
       AND COP.FLGATIVO = 1
     ORDER BY AGE.CDCOOPER, AGE.CDAGENCI;

  CURSOR CR_CRAPCOP IS
    SELECT CDCOOPER, CDBCOCTL
      FROM CRAPCOP
     WHERE CRAPCOP.FLGATIVO = 1
     ORDER BY CDCOOPER;

  --Selecionar informacoes convenios
  CURSOR CR_CRAPCCO_ATIVO(PR_CDCOOPER IN CRAPCCO.CDCOOPER%TYPE
                         ,PR_CDDBANCO IN CRAPCCO.CDDBANCO%TYPE) IS
    SELECT CRAPCCO.CDCOOPER,
           CRAPCCO.NRCONVEN,
           CRAPCCO.NRDCTABB,
           CRAPCCO.CDDBANCO,
           CRAPCCO.CDAGENCI,
           CRAPCCO.CDBCCXLT,
           CRAPCCO.NRDOLOTE,
           CRAPCCO.DSORGARQ
      FROM CRAPCCO
     WHERE CRAPCCO.CDCOOPER = PR_CDCOOPER
       AND CRAPCCO.CDDBANCO = PR_CDDBANCO
       AND CRAPCCO.FLGREGIS = 1;

  VR_IDPARALE  INTEGER;
  VR_EXC_SAIDA EXCEPTION;
  VR_DSCRITIC  VARCHAR2(1000);
  VR_QTDJOBS   NUMBER;
  VR_CDPROGRA  VARCHAR2(50) := 'DTLIPGTO';
  VR_INDEX     NUMBER := 0;
  VR_JOBNAME   VARCHAR2(30);
  VR_DSPLSQL   VARCHAR2(4000);

BEGIN
  -- Gerar o ID para o paralelismo
  VR_IDPARALE := GENE0001.FN_GERA_ID_PARALELO;
  -- Se houver algum erro, o id vira zerado
  IF VR_IDPARALE = 0 THEN
    -- Levantar exceção
    VR_DSCRITIC := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
    RAISE VR_EXC_SAIDA;
  END IF;
  -- Buscar quantidade parametrizada de Jobs
  VR_QTDJOBS := 10;

  -- Para cada agencia
  FOR RW_CRAPAGE IN CR_CRAPAGE LOOP

    VR_INDEX := VR_INDEX + 1;

    -- Cadastra o programa paralelo
    GENE0001.PC_ATIVA_PARALELO(PR_IDPARALE => VR_IDPARALE
                              ,PR_IDPROGRA => VR_INDEX --> Indice sera id programa
                              ,PR_DES_ERRO => VR_DSCRITIC);
    -- Testar saida com erro
    IF VR_DSCRITIC IS NOT NULL THEN
      -- Levantar exceçao
      RAISE VR_EXC_SAIDA;
    END IF;

    -- Montar o bloco PLSQL que será executado
    VR_DSPLSQL := 'DECLARE' || CHR(13)
               || '  VR_CDCRITIC NUMBER;' || CHR(13)
               || '  VR_DSCRITIC VARCHAR2(4000);' || CHR(13)
               || 'BEGIN' || CHR(13)
               || '  CECRED.PC_UPDATE_DTLIPGTO_CRAPCOB_AGE(PR_CDCOOPER => ' || RW_CRAPAGE.CDCOOPER
               ||                                        ',PR_CDAGENCI => ' || RW_CRAPAGE.CDAGENCI
               ||                                        ',PR_IDPARALE => ' || VR_IDPARALE
               ||                                        ',PR_IDPROGRA => ' || VR_INDEX
               ||                                        ',PR_CDCRITIC => VR_CDCRITIC'
               ||                                        ',PR_DSCRITIC => VR_DSCRITIC);' || CHR(13)
               || 'END;';

    -- Montar o prefixo do código do programa para o jobname
    VR_JOBNAME := VR_CDPROGRA || '_' || VR_INDEX || '$';
    -- Faz a chamada ao programa paralelo atraves de JOB
    GENE0001.PC_SUBMIT_JOB(PR_CDCOOPER => RW_CRAPAGE.CDCOOPER --> Código da cooperativa
                          ,PR_CDPROGRA => VR_CDPROGRA --> Código do programa
                          ,PR_DSPLSQL  => VR_DSPLSQL --> Bloco PLSQL a executar
                          ,PR_DTHREXE  => SYSTIMESTAMP --> Executar nesta hora
                          ,PR_INTERVA  => NULL --> Sem intervalo execução, apenas 1 vez
                          ,PR_JOBNAME  => VR_JOBNAME --> Nome randomico criado
                          ,PR_DES_ERRO => VR_DSCRITIC);
    -- Testar saida com erro
    IF VR_DSCRITIC IS NOT NULL THEN
      -- Levantar exceçao
      RAISE VR_EXC_SAIDA;
    END IF;

    -- Chama rotina que irá pausar este processo controlador
    -- caso tenhamos excedido a quantidade de JOBS em execuçao
    GENE0001.PC_AGUARDA_PARALELO(PR_IDPARALE => VR_IDPARALE
                                ,PR_QTDPROCE => VR_QTDJOBS
                                ,PR_DES_ERRO => VR_DSCRITIC);
    -- Testar saida com erro
    IF VR_DSCRITIC IS NOT NULL THEN
      -- Levantar exceçao
      RAISE VR_EXC_SAIDA;
    END IF;

  END LOOP; -- Para cada agencia

  -- Chama rotina de aguardo agora passando 0, para esperarmos
  -- até que todos os Jobs tenha finalizado seu processamento
  GENE0001.PC_AGUARDA_PARALELO(PR_IDPARALE => VR_IDPARALE
                              ,PR_QTDPROCE => 0
                              ,PR_DES_ERRO => VR_DSCRITIC);
  -- Testar saida com erro
  IF VR_DSCRITIC IS NOT NULL THEN
    -- Levantar exceçao
    RAISE VR_EXC_SAIDA;
  END IF;

  -- Para cada cooperativa
  FOR RW_CRAPCOP IN CR_CRAPCOP LOOP
    -- Busca todos os convenios
    FOR RW_CRAPCCO IN CR_CRAPCCO_ATIVO(PR_CDCOOPER => RW_CRAPCOP.CDCOOPER
                                      ,PR_CDDBANCO => RW_CRAPCOP.CDBCOCTL) LOOP

      VR_INDEX := VR_INDEX + 1;

      -- Cadastra o programa paralelo
      GENE0001.PC_ATIVA_PARALELO(PR_IDPARALE => VR_IDPARALE
                                ,PR_IDPROGRA => VR_INDEX --> Indice sera id programa
                                ,PR_DES_ERRO => VR_DSCRITIC);
      -- Testar saida com erro
      IF VR_DSCRITIC IS NOT NULL THEN
        -- Levantar exceçao
        RAISE VR_EXC_SAIDA;
      END IF;

      -- Montar o bloco PLSQL que será executado
      VR_DSPLSQL := 'DECLARE' || CHR(13)
                 || '  VR_CDCRITIC NUMBER;' || CHR(13)
                 || '  VR_DSCRITIC VARCHAR2(4000);' || CHR(13)
                 || 'BEGIN' || CHR(13)
                 || '  CECRED.PC_BAIXA_DECPRZ_DTLIPGTO(PR_CDCOOPER => ' || RW_CRAPCCO.CDCOOPER
                 ||                                  ',PR_NRCNVCOB => ' || RW_CRAPCCO.NRCONVEN
                 ||                                  ',PR_IDPARALE => ' || VR_IDPARALE
                 ||                                  ',PR_IDPROGRA => ' || VR_INDEX
                 ||                                  ',PR_CDCRITIC => VR_CDCRITIC'
                 ||                                  ',PR_DSCRITIC => VR_DSCRITIC);' || CHR(13)
                 || 'END;';

      -- Montar o prefixo do código do programa para o jobname
      VR_JOBNAME := VR_CDPROGRA || '_' || VR_INDEX || '$';
      -- Faz a chamada ao programa paralelo atraves de JOB
      GENE0001.PC_SUBMIT_JOB(PR_CDCOOPER => RW_CRAPCCO.CDCOOPER --> Código da cooperativa
                            ,PR_CDPROGRA => VR_CDPROGRA --> Código do programa
                            ,PR_DSPLSQL  => VR_DSPLSQL --> Bloco PLSQL a executar
                            ,PR_DTHREXE  => SYSTIMESTAMP --> Executar nesta hora
                            ,PR_INTERVA  => NULL --> Sem intervalo execução, apenas 1 vez
                            ,PR_JOBNAME  => VR_JOBNAME --> Nome randomico criado
                            ,PR_DES_ERRO => VR_DSCRITIC);
      -- Testar saida com erro
      IF VR_DSCRITIC IS NOT NULL THEN
        -- Levantar exceçao
        RAISE VR_EXC_SAIDA;
      END IF;

      -- Chama rotina que irá pausar este processo controlador
      -- caso tenhamos excedido a quantidade de JOBS em execuçao
      GENE0001.PC_AGUARDA_PARALELO(PR_IDPARALE => VR_IDPARALE
                                  ,PR_QTDPROCE => VR_QTDJOBS
                                  ,PR_DES_ERRO => VR_DSCRITIC);
      -- Testar saida com erro
      IF VR_DSCRITIC IS NOT NULL THEN
        -- Levantar exceçao
        RAISE VR_EXC_SAIDA;
      END IF;

    END LOOP; -- Busca todos os convenios
  END LOOP; -- Para cada cooperativa

  -- Chama rotina de aguardo agora passando 0, para esperarmos
  -- até que todos os Jobs tenha finalizado seu processamento
  GENE0001.PC_AGUARDA_PARALELO(PR_IDPARALE => VR_IDPARALE
                              ,PR_QTDPROCE => 0
                              ,PR_DES_ERRO => VR_DSCRITIC);
  -- Testar saida com erro
  IF VR_DSCRITIC IS NOT NULL THEN
    -- Levantar exceçao
    RAISE VR_EXC_SAIDA;
  END IF;

EXCEPTION
  WHEN VR_EXC_SAIDA THEN
    DBMS_OUTPUT.PUT_LINE(VR_DSCRITIC);
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION(PR_COMPLEME => 'DTLIPGTO');
END;
0
0
