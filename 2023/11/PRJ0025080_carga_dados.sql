DECLARE
  TYPE TREG IS RECORD(
    idproduto         RAW(16),
    nmproduto         VARCHAR2(20),
    dsmascara_arquivo VARCHAR2(50),
    cdproduto         VARCHAR2(3),
    dhregistro        DATE);

  TYPE TNESTED IS TABLE OF TREG INDEX BY BINARY_INTEGER;

  NTAB TNESTED;

  vseq_tab NUMBER;

  vtem INTEGER;

  CURSOR C1(pcdproduto VARCHAR2) IS
    SELECT *
      FROM pagamento.TAVANS_PRODUTO
     WHERE DHINATIVACAO IS NULL
       AND cdproduto = pcdproduto;
  R1 C1%ROWTYPE;

  CURSOR C2(p_nrcnpj NUMBER) IS
    SELECT *
      FROM pagamento.tbvans_van
     WHERE DHINATIVACAO IS NULL
       AND nrcnpj = p_nrcnpj;
  R2 C2%ROWTYPE;

  CURSOR C3(p_cdcooperativa    NUMBER
           ,p_nrconta_corrente NUMBER) IS
    SELECT *
      FROM pagamento.tbvans_van_cooperado
     WHERE DHINATIVACAO IS NULL
       AND cdcooperativa = p_cdcooperativa
       AND nrconta_corrente = p_nrconta_corrente;
  R3 C3%ROWTYPE;

  v_idvan           RAW(16) := NULL;
  v_idvan_cooperado RAW(16) := NULL;

BEGIN

  OPEN c2(03813865000165);
  FETCH c2
    INTO r2;
  IF c2%NOTFOUND THEN
    v_idvan := SYS_GUID();
    INSERT INTO pagamento.tbvans_van
      (idvan
      ,nmvan
      ,nmrazao_social
      ,nrcnpj
      ,dspasta_envia
      ,dspasta_enviados
      ,dspasta_recebe
      ,dspasta_recebidos)
    VALUES
      (v_idvan
      ,'Nexxera'
      ,'Nexxera Tecnologia e Serviços'
      ,03813865000165
      ,'/usr/connect/nexxera/envia'
      ,'/usr/connect/nexxera/enviados'
      ,'/usr/connect/nexxera/recebe'
      ,'/usr/connect/nexxera/recebidos');
  ELSE
    v_idvan := r2.idvan;
  END IF;
  CLOSE c2;

  vseq_tab := 0;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Custódia de cheques';
  ntab(vseq_tab).dsmascara_arquivo := 'CST_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'CST';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Extrato C/C';
  ntab(vseq_tab).dsmascara_arquivo := 'EXT_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'EXT';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'TED/Transferência';
  ntab(vseq_tab).dsmascara_arquivo := 'TED_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'TED';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Folha de Pagamento';
  ntab(vseq_tab).dsmascara_arquivo := 'FOL_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'FOL';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Pagamentos';
  ntab(vseq_tab).dsmascara_arquivo := 'PGT_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'PGT';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Cobrança Bancária';
  ntab(vseq_tab).dsmascara_arquivo := 'CBR_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'CBR';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Transferência PIX';
  ntab(vseq_tab).dsmascara_arquivo := 'PIX_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'PIX';
  ntab(vseq_tab).dhregistro := SYSDATE;

  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto := SYS_GUID();
  ntab(vseq_tab).nmproduto := 'Recebimento DDA';
  ntab(vseq_tab).dsmascara_arquivo := 'DDA_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto := 'DDA';
  ntab(vseq_tab).dhregistro := SYSDATE;

  FOR x IN 1 .. ntab.count LOOP
    OPEN c1(ntab(x).cdproduto);
    FETCH c1
      INTO r1;
  
    IF c1%NOTFOUND THEN
      INSERT INTO pagamento.TAVANS_PRODUTO
        (idproduto
        ,nmproduto
        ,dsmascara_arquivo
        ,cdproduto
        ,dhregistro)
      VALUES
        (ntab(x).idproduto
        ,ntab(x).nmproduto
        ,ntab(x).dsmascara_arquivo
        ,ntab(x).cdproduto
        ,ntab(x).dhregistro);
    
    END IF;
    CLOSE c1;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;
    IF c2%ISOPEN THEN
      CLOSE c2;
    END IF;
    IF c3%ISOPEN THEN
      CLOSE c3;
    END IF;
  
    cecred.pc_internal_exception(pr_compleme => 'PRJ0025080_carga_dados');
  
    ROLLBACK;
END;
