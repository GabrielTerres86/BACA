DECLARE
  CURSOR c_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  
  CURSOR c_grupo1 IS
    SELECT 'F0030010' cdoperad FROM dual UNION
    SELECT 'F0030159' FROM dual UNION
    SELECT 'F0030445' FROM dual UNION
    SELECT 'F0030907' FROM dual UNION
    SELECT 'F0030350' FROM dual UNION
    SELECT 'F0030803' FROM dual UNION
    SELECT 'F0030271' FROM dual UNION
    SELECT 'F0032325' FROM dual; 
  
  CURSOR c_opcao1 IS
    SELECT 'T' cddopcao FROM dual UNION
    SELECT 'N' FROM dual UNION
    SELECT 'S' FROM dual;
  
  CURSOR c_grupo2 IS
    SELECT 'F0030476' cdoperad FROM dual UNION
    SELECT 'F0030803' FROM dual UNION
    SELECT 'F0030271' FROM dual;

  CURSOR c_opcao2 IS
    SELECT 'T' cddopcao FROM dual UNION
    SELECT 'N' FROM dual UNION
    SELECT 'S' FROM dual UNION
    SELECT 'I' FROM dual UNION
    SELECT 'A' FROM dual UNION
    SELECT 'X' FROM dual UNION
    SELECT 'B' FROM dual UNION
    SELECT 'O' FROM dual;
  
  CURSOR c_grupo3 IS
    SELECT 'F0030173' cdoperad FROM dual UNION
    SELECT 'F0030530' FROM dual UNION
    SELECT 'F0030588' FROM dual UNION
    SELECT 'F0031053' FROM dual UNION
    SELECT 'F0030563' FROM dual UNION
    SELECT 'F0030517' FROM dual UNION
    SELECT 'F0030516' FROM dual UNION
    SELECT 'F0030566' FROM dual UNION
    SELECT 'F0031090' FROM dual UNION
    SELECT 'F0030689' FROM dual;

  CURSOR c_opcao3 IS
    SELECT 'N' cddopcao FROM dual;

  CURSOR c_grupo4 IS
    SELECT 'F9010007' cdoperad FROM dual;

  CURSOR c_opcao4 IS
    SELECT 'S' cddopcao FROM dual;
BEGIN
  --Exclusões
  DELETE crapace c
   WHERE UPPER(c.nmdatela) = 'HISTOR'
     AND UPPER(c.cdoperad) IN ('F0030173','F0030530','F0030588','F0031053','F0030268','F0030424'
                              ,'F0030438','F0030531','F0030657','F0030762','F0031168','F0031186'
                              ,'F0032007','F0032146','F0032183','F0032522','F0090068')
     AND UPPER(c.cddopcao) <> 'C';

  DELETE crapace c
   WHERE UPPER(c.nmdatela) = 'HISTOR'
     AND UPPER(c.cdoperad) = 'F0060141'
     AND UPPER(c.cddopcao) NOT IN ('C','B','O');

  FOR r_cop IN c_cop LOOP
    --Incluir as opções T, N e S - para todas as cooperativas
    FOR r_grupo1 IN c_grupo1 LOOP
      FOR r_opcao1 IN c_opcao1 LOOP
        BEGIN
          INSERT INTO crapace(nmdatela,cddopcao,cdoperad,cdcooper,idambace)
                       VALUES('HISTOR',r_opcao1.cddopcao,r_grupo1.cdoperad,r_cop.cdcooper,2);
        EXCEPTION
          WHEN dup_val_on_index THEN
            --Se já estiver liberado, ignora
            NULL;
        END;
      END LOOP;
    END LOOP;
    
    --Incluir todas as opções I, A, T, X, B, O N e S - para todas as cooperativas
    FOR r_grupo2 IN c_grupo2 LOOP
      FOR r_opcao2 IN c_opcao2 LOOP
        BEGIN
          INSERT INTO crapace(nmdatela,cddopcao,cdoperad,cdcooper,idambace)
                       VALUES('HISTOR',r_opcao2.cddopcao,r_grupo2.cdoperad,r_cop.cdcooper,2);
        EXCEPTION
          WHEN dup_val_on_index THEN
            --Se já estiver liberado, ignora
            NULL;
        END;
      END LOOP;
    END LOOP;
    
    --Incluir a nova opção N - para todas as cooperativas
    FOR r_grupo3 IN c_grupo3 LOOP
      FOR r_opcao3 IN c_opcao3 LOOP
        BEGIN
          INSERT INTO crapace(nmdatela,cddopcao,cdoperad,cdcooper,idambace)
                       VALUES('HISTOR',r_opcao3.cddopcao,r_grupo3.cdoperad,r_cop.cdcooper,2);
        EXCEPTION
          WHEN dup_val_on_index THEN
            --Se já estiver liberado, ignora
            NULL;
        END;
      END LOOP;
    END LOOP;
    
    --Incluir a nova opção S - para todas as cooperativas - manter a opção C, B e O já cadastrada   
    FOR r_grupo4 IN c_grupo4 LOOP
      FOR r_opcao4 IN c_opcao4 LOOP
        BEGIN
          INSERT INTO crapace(nmdatela,cddopcao,cdoperad,cdcooper,idambace)
                       VALUES('HISTOR',r_opcao4.cddopcao,r_grupo4.cdoperad,r_cop.cdcooper,2);
        EXCEPTION
          WHEN dup_val_on_index THEN
            --Se já estiver liberado, ignora
            NULL;
        END;
      END LOOP;
    END LOOP;
  END LOOP;
  
  COMMIT;
END;