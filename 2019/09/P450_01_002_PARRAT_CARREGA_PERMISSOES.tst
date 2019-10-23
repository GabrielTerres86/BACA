PL/SQL Developer Test script 3.0
275
/* Libera acesso a tela PARRAT para os operadores do  cdcooper = 3. */
declare
  
  -- SIGLA_TELA := 'PARRAT'; 
  SIGLA_TELA VARCHAR2(100) := 'PARRAT';
  /****************************************/
  -- busca cooperativas
  cursor cr_crapcop is
    select cdcooper,NMRESCOP
      from crapcop
     where flgativo = 1
       and cdcooper = 3;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- busca cooperativas
  cursor cr_cop_todas is
    select cdcooper,NMRESCOP
      from crapcop
     where flgativo = 1
       and cdcooper <> 3;
  rw_cop_todas cr_cop_todas%ROWTYPE;



  --- busca operadores do grupo e coopertiva 
  cursor cr_crapope(pr_cdcooper in crapcop.cdcooper%TYPE,
                    pr_cddepart in crapope.cddepart%TYPE) is
    select cdoperad
      from crapope t
     where cdcooper = pr_cdcooper
--       and cddepart = pr_cddepart
       AND upper(t.cdoperad) IN ('F0031090','F0030689','F0030517','F0031803','F0030688','F0030567','F0030539')
       ;
  rw_crapope  cr_crapope%ROWTYPE;

  CURSOR cr_tab036 IS
    SELECT nmdatela, 
            nrmodulo, 
            cdopptel, 
            tldatela, 
            tlrestel, 
            flgteldf, 
            flgtelbl, 
            nmrotina, 
            lsopptel, 
            inacesso, 
            cdcooper, 
            idsistem, 
            idevento, 
            nrordrot, 
            nrdnivel, 
            nmrotpai, 
            idambtel
      FROM craptel t
      WHERE t.nmdatela = 'TAB036'
      AND rowNUM = 1;
  rw_tab036    cr_tab036%ROWTYPE;
  



  v_contcons  number := 0;
  v_contalter number := 0;
   
BEGIN
  
  DELETE FROM crapace a
        WHERE a.cdcooper = 3
          AND UPPER(NMDATELA) = UPPER('PARRAT') 
          AND UPPER(NMROTINA) = UPPER(' ');
  COMMIT;
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
      --faz o insert para operadores do grupo   consultar/ altearção 
      FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper,
                                   NULL) LOOP
          v_contalter := nvl(v_contalter,0) + 1;
       begin
          insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (SIGLA_TELA,
           'A',
           rw_crapope.cdoperad,
           ' ',
           rw_crapcop.cdcooper,
           8,
           0,
           2);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;
      
      
      begin
        insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (SIGLA_TELA,
           'C',
           rw_crapope.cdoperad,
           ' ',
           rw_crapcop.cdcooper,
           8,
           0,
           2);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;
      
       begin
          insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (SIGLA_TELA,
           'B',
           rw_crapope.cdoperad,
           ' ',
           rw_crapcop.cdcooper,
           8,
           0,
           2);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;
      
      
      
       begin
          insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (SIGLA_TELA,
           'P',
           rw_crapope.cdoperad,
           ' ',
           rw_crapcop.cdcooper,
           8,
           0,
           2);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;
      
         begin
          insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (SIGLA_TELA,
           'M',
           rw_crapope.cdoperad,
           ' ',
           rw_crapcop.cdcooper,
           8,
           0,
           2);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;    


     END LOOP; -- fim operadores

  END LOOP;    -- fim cooperativas
  COMMIT;
  
  
  open  cr_tab036;
   fetch cr_tab036 into rw_tab036;
  
  
  FOR rw_cop_todas IN cr_cop_todas LOOP

    --faz o insert para operadores do grupo   consultar/ altearção 
    FOR rw_crapope IN cr_crapope(rw_cop_todas.cdcooper,
                                 NULL) LOOP
      begin
          insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (rw_tab036.nmdatela,
           'A',
           rw_crapope.cdoperad,
           rw_tab036.nmrotina,
           rw_crapcop.cdcooper,
           rw_tab036.nrmodulo,
           rw_tab036.idevento,
           rw_tab036.idambtel);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;
      
         begin
          insert into crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        values
          (rw_tab036.nmdatela,
           'C',
           rw_crapope.cdoperad,
           rw_tab036.nmrotina,
           rw_crapcop.cdcooper,
           rw_tab036.nrmodulo,
           rw_tab036.idevento,
           rw_tab036.idambtel);
      EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
      end;   

    END LOOP;
  END LOOP;
  COMMIT;

EXCEPTION
  WHEN dup_val_on_index THEN
    NULL;
  when others then
    dbms_output.put_line('Encontrado erro' ||sqlcode);
end;
0
0
