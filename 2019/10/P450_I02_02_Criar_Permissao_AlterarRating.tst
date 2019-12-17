PL/SQL Developer Test script 3.0
154
DECLARE

  TYPE typ_tab_rotinas IS
    TABLE OF VARCHAR2(30)
      INDEX BY PLS_INTEGER;
  vr_tab_rotinas typ_tab_rotinas;

  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1
       AND cdcooper <> 3
     ORDER BY cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cdoperad
      FROM crapope t
     WHERE cdcooper = pr_cdcooper
       AND upper(t.cdoperad) IN (upper('F0031166')
                                ,upper('F0030444')
                                ,upper('F0030269')
                                );
  rw_crapope cr_crapope%ROWTYPE;
  sigla_tela  VARCHAR2(400);
  rotina_tela VARCHAR2(400);
  vr_contador INTEGER;
BEGIN


  -- Lista de rotinas que precisam ser criadas a Opção T
  vr_tab_rotinas(1) := 'DSC CHQS - LIMITE';
  vr_tab_rotinas(2) := 'DSC TITS - LIMITE';
  vr_tab_rotinas(3) := 'DSC TITS - PROPOSTA';
  vr_tab_rotinas(4) := 'EMPRESTIMOS';
  vr_tab_rotinas(5) := 'LIMITE CRED';


  FOR rw_crapcop IN cr_crapcop LOOP
--    dbms_output.put_line('COOP: ' || rw_crapcop.cdcooper );

    -- APAGAR OS REGISTROS DE QUEM JA TEM ACESSO A OPÇÃO "A" RATMOV
    BEGIN
      DELETE FROM crapace t
       WHERE t.cdcooper = rw_crapcop.cdcooper
         AND upper(t.nmdatela) = UPPER('RATMOV')
         AND UPPER(CDDOPCAO)   = UPPER('A');
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Exclusão ACESSO não realizada - RATMOV |' ||
                              ' Coop:' || rw_crapcop.cdcooper);
    END;

    -- APAGAR OS REGISTROS DE QUEM JA TEM ACESSO A OPÇÃO ALTERAR RATING DOS PRODUTOS
    sigla_tela := 'ATENDA';
    FOR vr_contador IN 1..vr_tab_rotinas.count LOOP
      BEGIN
        DELETE FROM crapace t
         WHERE t.cdcooper = rw_crapcop.cdcooper
           AND UPPER(t.nmdatela) = UPPER(sigla_tela)
           AND UPPER(T.NMROTINA) = UPPER(vr_tab_rotinas(vr_contador))
           AND UPPER(CDDOPCAO)   = UPPER('Z');
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Exclusão ACESSO não realizada!'  ||
                                ' Coop:' || rw_crapcop.cdcooper 
                             || ' OPÇÃO Z'
                             || ' TELA: ' || sigla_tela
                             || ' Rotina: ' || vr_tab_rotinas(vr_contador)
                                  );
      END;
    END LOOP;


    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper) LOOP
--      dbms_output.put_line('  OPERAD: ' || rw_crapope.cdoperad);

      sigla_tela := 'ATENDA';
      FOR vr_contador IN 1..vr_tab_rotinas.count LOOP
--        dbms_output.put_line('    Rotina: ' || vr_tab_rotinas(vr_contador));
        BEGIN
          INSERT INTO crapace
            (nmdatela
            ,cddopcao
            ,cdoperad
            ,nmrotina
            ,cdcooper
            ,nrmodulo
            ,idevento
            ,idambace)
          VALUES
            (sigla_tela
            ,'Z'
            ,rw_crapope.cdoperad
            ,vr_tab_rotinas(vr_contador)
            ,rw_crapcop.cdcooper
            ,1
            ,0
            ,2);
          dbms_output.put_line('Inserção em crapace  realizada com sucesso!  ' ||
                               ' TELA: ' || sigla_tela || 
                               ' Rotina: ' || vr_tab_rotinas(vr_contador)
                            || ' Opcao Z' 
                            || ' Coop:'    || rw_crapcop.cdcooper 
                            || ' Operador ' || rw_crapope.cdoperad);
        EXCEPTION
          WHEN dup_val_on_index THEN
            dbms_output.put_line('Inserção em crapace não realizada.  JÁ EXISTE REGISTRO PARA  OPERADOR ' ||
                                 rw_crapope.cdoperad ||
                                  ' Coop:' || rw_crapcop.cdcooper || ' OPÇÃO Z'
                               || ' TELA: ' || sigla_tela || ' Rotina: ' || vr_tab_rotinas(vr_contador)
                                  );
        END;
      END LOOP; -- Fim do loop das rotinas Atenda
      
      -- Permissoes RATMOV
      sigla_tela := 'RATMOV';
      BEGIN
          INSERT INTO crapace
            (nmdatela
            ,cddopcao
            ,cdoperad
            ,nmrotina
            ,cdcooper
            ,nrmodulo
            ,idevento
            ,idambace)
          VALUES
            (sigla_tela
            ,'A'
            ,rw_crapope.cdoperad
            ,' '
            ,rw_crapcop.cdcooper
            ,8
            ,0
            ,2);
          dbms_output.put_line('Inserção em crapace  realizada com sucesso!  ' ||
                               ' TELA: ' || sigla_tela
                               || ' Coop:'    || rw_crapcop.cdcooper 
                               || ' Operador ' || rw_crapope.cdoperad);
        EXCEPTION
          WHEN dup_val_on_index THEN
            dbms_output.put_line('Inserção em crapace não realizada.  JÁ EXISTE REGISTRO PARA  OPERADOR ' ||
                                 rw_crapope.cdoperad ||
                                  ' Coop:' || rw_crapcop.cdcooper || ' OPÇÃO A'
                               || ' TELA: ' || sigla_tela
                                  );
        END;
    END LOOP;

  END LOOP;

  COMMIT;
END;
0
4
rw_crapope.cdoperad
rw_crapcop.cdcooper
vr_tab_rotinas(vr_contador)
sigla_tela
