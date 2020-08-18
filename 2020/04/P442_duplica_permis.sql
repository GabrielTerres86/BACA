/*
Duplicacao de permissoes de tela
Darlei Zillmer - Supero
*/
BEGIN
  DECLARE
  
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop
       WHERE flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    CURSOR cr_crapace(pr_cdcooper IN crapace.cdcooper%TYPE
                     ,pr_nmdatela IN crapace.nmdatela%TYPE
                     ,pr_cddopcao IN crapace.cddopcao%TYPE) IS
      SELECT DISTINCT(UPPER(a.cdoperad)) cdoperad
        FROM crapace a
       WHERE cdcooper = pr_cdcooper
         AND UPPER(nmdatela) = UPPER(pr_nmdatela)
         AND UPPER(cddopcao) = UPPER(pr_cddopcao);
    rw_crapace cr_crapace%ROWTYPE;
  
    vr_cddopcao_nova VARCHAR(50) := 'RC,IC'; -- opcoes/permissoes da tela que serao adicionadas
    vr_nmdatela      VARCHAR(10) := 'GRAVAM'; -- tela que serao liberadas as permissoes
    vr_cddopcao      VARCHAR(2) := 'M'; -- opcao da tela que as permissoes serao copiadas
    vr_lista         GENE0002.typ_split;
  
  BEGIN

    vr_lista := GENE0002.fn_quebra_string(pr_string => vr_cddopcao_nova, pr_delimit => ',');
  
    FOR vr_idx_lst IN 1 .. vr_lista.COUNT LOOP
      -- Loop cooperativas ativas
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Loop registros da tela
        FOR rw_crapace IN cr_crapace(pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_nmdatela => vr_nmdatela,
                                     pr_cddopcao => vr_cddopcao) LOOP
        
          INSERT INTO CRAPACE
            (NMDATELA,
             CDDOPCAO,
             CDOPERAD,
             NMROTINA,
             CDCOOPER,
             NRMODULO,
             IDEVENTO,
             IDAMBACE)
          VALUES
            (vr_nmdatela,
             vr_lista(vr_idx_lst),
             rw_crapace.cdoperad,
             ' ',
             rw_crapcop.cdcooper,
             1,
             1,
             1);
        
          INSERT INTO CRAPACE
            (NMDATELA,
             CDDOPCAO,
             CDOPERAD,
             NMROTINA,
             CDCOOPER,
             NRMODULO,
             IDEVENTO,
             IDAMBACE)
          VALUES
            (vr_nmdatela,
             vr_lista(vr_idx_lst),
             rw_crapace.cdoperad,
             ' ',
             rw_crapcop.cdcooper,
             1,
             1,
             2);
        
        END LOOP;
      END LOOP;
    END LOOP;
    
    COMMIT;
  
  END;
END;
