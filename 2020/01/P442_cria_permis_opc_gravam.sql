/*
Baca para gerar opcoes na permis (caracter)
Para liberar permissoes deve ser alterada a crapace
Darlei Zillmer - Supero
*/
BEGIN
  DECLARE
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop
       WHERE flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    CURSOR cr_craptel(pr_cdcooper IN craptel.cdcooper%TYPE
                     ,pr_nmdatela IN craptel.nmdatela%TYPE) IS
      SELECT cdopptel
            ,lsopptel
        FROM craptel
       WHERE UPPER(nmdatela) = UPPER(pr_nmdatela)
         AND cdcooper = pr_cdcooper;
    rw_craptel cr_craptel%ROWTYPE;
  
    vr_cdopptel     VARCHAR(2000);
    vr_lsopptel     VARCHAR(2000);
    vr_cdopptel_add VARCHAR(2000) := ',RC,IC';                     -- Novos cdopcao para permis
    vr_lsopptel_add VARCHAR(2000) := ',REG.CONTRATO,IMG.CONTRATO'; -- Novos descritivos da permis
    vr_nmdatela     VARCHAR(10) := 'GRAVAM';
  BEGIN
    -- Loop cooperativas ativas
    FOR rw_crapcop IN cr_crapcop LOOP
      -- Loop registros da tela
      FOR rw_craptel IN cr_craptel(pr_cdcooper => rw_crapcop.cdcooper, pr_nmdatela => vr_nmdatela) LOOP
        -- Atualizando valores
        vr_cdopptel := rw_craptel.cdopptel || vr_cdopptel_add;
        vr_lsopptel := rw_craptel.lsopptel || vr_lsopptel_add;
      
        UPDATE craptel
           SET cdopptel = vr_cdopptel
              ,lsopptel = vr_lsopptel
         WHERE UPPER(nmdatela) = UPPER(vr_nmdatela)
           AND cdcooper = rw_crapcop.cdcooper;
      
        vr_cdopptel := '';
        vr_lsopptel := '';
      END LOOP;
    END LOOP;
  
    COMMIT;
  
  END;
END;
