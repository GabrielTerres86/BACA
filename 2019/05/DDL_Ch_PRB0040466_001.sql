DECLARE
  -- DDLs Chamado DDL_Ch_PRB0040466_001
  -- 09/01/2019 - Belli - Envolti 
  -- Inclusão de parâmetros
  --
  -- Selecionar lista de Cooperativas ativas
  CURSOR cr_crapcop_ativas  IS
    SELECT cop.cdcooper
    FROM crapcop cop
    WHERE cop.flgativo        = 1
	AND   NVL(cop.cdcooper,0) <> 3
    ORDER BY cop.cdcooper;
  rw_crapcop_ativas cr_crapcop_ativas%ROWTYPE;
  
  vr_exc_saida          EXCEPTION;
  
  vr_totcoop            NUMBER(4) := 0;
  vr_nmsistem           crapprm.nmsistem%TYPE := 'CRED';
  vr_cdcooper           crapprm.cdcooper%TYPE;
  vr_cdacesso           crapprm.cdacesso%TYPE;
  vr_dstexprm           crapprm.dstexprm%TYPE;
  vr_dsvlrprm           crapprm.dsvlrprm%TYPE;
  --
  vr_cdprogra           crapprg.cdprogra%TYPE;
  vr_dsprogra##1        crapprg.dsprogra##1%TYPE;
  vr_nrordprg           crapprg.nrordprg%TYPE;
  --
  vr_existe             VARCHAR2(1);  
  --
  PROCEDURE PC_2 IS
  BEGIN
    --
    BEGIN
      SELECT 'S' INTO vr_existe
      FROM   crapprm
      WHERE  nmsistem  = vr_nmsistem
      AND    cdcooper  = vr_cdcooper
      AND    cdacesso  = vr_cdacesso;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_existe := 'N';
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception;       
    END;
    --
    IF vr_existe = 'N' THEN
      BEGIN
        INSERT INTO crapprm (
         nmsistem       --VARCHAR2(4),
        ,cdcooper       --NUMBER(10),
        ,cdacesso       --VARCHAR2(24),
        ,dstexprm       --VARCHAR2(4000),
        ,dsvlrprm       --VARCHAR2(4000),
        ,progress_recid --NUMBER
        ) VALUES ( 
         vr_nmsistem
        ,vr_cdcooper
        ,vr_cdacesso
        ,vr_dstexprm
        ,vr_dsvlrprm
        ,NULL
        );
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception;   
      END;
    END IF;
  END;
  
  PROCEDURE PC_1 IS
  BEGIN
    -- selecionar todas cooperativas ativas
    FOR rw_crapcop_ativas IN cr_crapcop_ativas  LOOP
        
      -- verifica a quantidade de cooperativas a processar
      vr_totcoop     := vr_totcoop + 1;            
      vr_cdcooper    := rw_crapcop_ativas.cdcooper;      
      --
      vr_cdacesso := 'QTD_EXEC_PREJU_TRF';
      vr_dstexprm := 'Quantidade de execuções da Processo PREJ0001.pc_controla_exe_job';
      vr_dsvlrprm := '1';
      PC_2;
	  --
      vr_cdacesso := 'CTRL_PREJU_TRF_EXEC';
      vr_dstexprm := 'Controle de execução da Processo PREJ0001.pc_controla_exe_job';
      vr_dsvlrprm := '05/01/2019#0';
      PC_2;
	  --
    END LOOP;
  END;
  --       
BEGIN      -- INICIO
  --   
  --*********
  vr_cdacesso := 'PREJU_TRF_HOR_EXE'; -- Controle do horário de execução
  vr_dstexprm := 'Horário padrão: 1)Horario execução. 2)Tempo de reagendamento. 3)Horário limite execução';	  
  vr_cdcooper := 0;     
  vr_dsvlrprm := '07:00;00:15;18:00';
  PC_2;
  --
  --*********
  --
  PC_1;
  COMMIT;  
EXCEPTION 
  WHEN vr_exc_saida THEN
    NULL;
  WHEN OTHERS THEN
    -- No caso de erro de programa gravar tabela especifica de log  
    CECRED.pc_internal_exception;
END;


               
                
