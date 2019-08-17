 /*-------------------------------------------------------------------------------------------------------------------------
    Programa    : CRPS734
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Luis Fernando (GFT)
    Data        : 07/01/2019
    Objetivo    : Inserir na tabela de programas a nova CRPS734, Calculo do vencimento dos vencimentos dos titulos. (DIARIA)
  --------------------------------------------------------------------------------------------------------------------------*/ 

  
BEGIN
  DECLARE
    TYPE Cooperativas IS TABLE OF integer;
    coop Cooperativas := Cooperativas(14); -- EX: Cooperativas(1,3,7,11);

    -- dados para buscar o programa atual
    vr_nrordprg_atual crapprg.nrordprg%TYPE; --> armazenar o nrordprg do programa que deve ficar antes do novo.
    vr_cdcooper       crapprg.cdcooper%TYPE;
    vr_cdprogra_atual crapprg.cdprogra%TYPE; --> Nome do programa atual a procurar a ordem.
    vr_nrsolici       crapprg.nrsolici%TYPE;

    -- dados para o novo programa
    vr_nmsistem_novo  crapprg.nmsistem%TYPE;
    vr_cdprogra_novo  crapprg.cdprogra%TYPE;
    vr_nrordprg_novo  crapprg.nrordprg%TYPE; --> nrordprg do novo programa que está sendo inserido.
    vr_dsprogra_novo  crapprg.dsprogra##1%TYPE;

    CURSOR cr_prog_atual (pr_cdcooper crapprg.cdcooper%TYPE
                         ,pr_nrsolici crapprg.nrsolici%TYPE
                         ,pr_cdprogra crapprg.cdprogra%TYPE) IS
      SELECT g.nrordprg
        FROM crapprg g
       WHERE g.cdcooper = pr_cdcooper
         AND g.nrsolici = pr_nrsolici
         AND g.cdprogra = pr_cdprogra;
--    rw_prog_atual cr_prog_atual%ROWTYPE;
  BEGIN
  FOR i IN coop.FIRST .. coop.LAST
  LOOP
      vr_cdcooper := coop(i);
      
      --================================================================
      -- DADOS DO PROGRAMA ATUAL PROCURADO.
      vr_cdprogra_atual := 'CRPS720';
      vr_nrsolici := 1;

      -- DADOS PARA INSERÇÃO DO NOVO PROGRAMA.
      vr_nmsistem_novo := 'CRED';
      vr_cdprogra_novo := 'CRPS734';
      vr_dsprogra_novo := 'Calculo do vencimento dos vencimentos dos titulos.';

      --================================================================
      --================================================================

      -- encontrando o número de ordem anterior ao que será criado.
      OPEN cr_prog_atual (pr_cdcooper => vr_cdcooper
                         ,pr_nrsolici => vr_nrsolici
                         ,pr_cdprogra => vr_cdprogra_atual);
      FETCH cr_prog_atual INTO vr_nrordprg_atual;
      CLOSE cr_prog_atual;

      -- definindo o número de ordem a criar para o programa novo
      vr_nrordprg_novo := vr_nrordprg_atual+1;

      -- Adicionando 1 a ordem de todos os programas posteriores ao atual,
      -- para liberar o número que será utilizado no novo programa.
      UPDATE crapprg c
         SET c.nrordprg = c.nrordprg+1
       WHERE c.nrsolici = vr_nrsolici
         AND c.cdcooper = vr_cdcooper
         AND c.nrordprg > vr_nrordprg_atual;

      -- Insere o registro de cadastro do programa na ordem necessária.
      INSERT INTO crapprg
        (nmsistem
        ,cdprogra
        ,dsprogra##1
        ,dsprogra##2
        ,dsprogra##3
        ,dsprogra##4
        ,nrsolici
        ,nrordprg
        ,inctrprg
        ,cdrelato##1
        ,cdrelato##2
        ,cdrelato##3
        ,cdrelato##4
        ,cdrelato##5
        ,inlibprg
        ,cdcooper)
      VALUES
        (vr_nmsistem_novo
        ,vr_cdprogra_novo
        ,vr_dsprogra_novo
        ,'.'
        ,'.'
        ,'.'
        ,vr_nrsolici
        ,vr_nrordprg_novo
        ,1
        ,0
        ,0
        ,0
        ,0
        ,0
        ,1
        ,vr_cdcooper);
    END LOOP;
    COMMIT;
  END;
END;
/
