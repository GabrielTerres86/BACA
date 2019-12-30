--PERMISS�ES DE ACESSO PARA USU�RIOS AO CAMPO 'DA��O DE BENS'
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
       AND upper(t.cdoperad) IN ('F0020295'); -- Pendente incluir lista de usu�rios.
  rw_crapope cr_crapope%ROWTYPE;
  sigla_tela  VARCHAR2(400);
  rotina_tela VARCHAR2(400);
  vr_contador INTEGER;
BEGIN
  -- Lista de rotinas que precisam ser criadas a Op��o T
  vr_tab_rotinas(1) := 'PRESTACOES';
 
  FOR rw_crapcop IN cr_crapcop LOOP
    
    dbms_output.put_line('COOP: ' || rw_crapcop.cdcooper );
    
    -- APAGAR OS REGISTROS DE QUEM JA TEM ACESSO A OP��O ALTERAR RATING DOS PRODUTOS
    sigla_tela := 'ATENDA';
    FOR vr_contador IN 1..vr_tab_rotinas.count LOOP
      BEGIN
        DELETE FROM crapace t
         WHERE t.cdcooper = rw_crapcop.cdcooper
           AND UPPER(t.nmdatela) = UPPER(sigla_tela)
           AND UPPER(T.NMROTINA) = UPPER(vr_tab_rotinas(vr_contador))
           AND UPPER(CDDOPCAO)   = UPPER('R');
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Exclus�o ACESSO n�o realizada!'  ||
                                ' Coop:' || rw_crapcop.cdcooper 
                             || ' OP��O R'
                             || ' TELA: ' || sigla_tela
                             || ' Rotina: ' || vr_tab_rotinas(vr_contador)
                                  );
      END;
    END LOOP;
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper) LOOP
      dbms_output.put_line('  OPERAD: ' || rw_crapope.cdoperad);
      sigla_tela := 'ATENDA';
      FOR vr_contador IN 1..vr_tab_rotinas.count LOOP
        dbms_output.put_line('    Rotina: ' || vr_tab_rotinas(vr_contador));
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
            ,'R'
            ,rw_crapope.cdoperad
            ,vr_tab_rotinas(vr_contador)
            ,rw_crapcop.cdcooper
            ,1
            ,0
            ,2);
          dbms_output.put_line('Inser��o em crapace  realizada com sucesso!  ' ||
                               ' TELA: ' || sigla_tela || 
                               ' Rotina: ' || vr_tab_rotinas(vr_contador)
                            || ' Opcao R' 
                            || ' Coop:'    || rw_crapcop.cdcooper 
                            || ' Operador ' || rw_crapope.cdoperad);
        EXCEPTION
          WHEN dup_val_on_index THEN
            dbms_output.put_line('Inser��o em crapace n�o realizada.  J� EXISTE REGISTRO PARA  OPERADOR ' ||
                                 rw_crapope.cdoperad ||
                                  ' Coop:' || rw_crapcop.cdcooper || ' OP��O R'
                               || ' TELA: ' || sigla_tela || ' Rotina: ' || vr_tab_rotinas(vr_contador)
                                  );
        END;
      END LOOP; -- Fim do loop das rotinas Atenda
     
    END LOOP;
  END LOOP;
  COMMIT;
END;