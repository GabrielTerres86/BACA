PL/SQL Developer Test script 3.0
116
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
  -- busca grupo departamento para  consultar
  cursor cr_crapdpo_consulta(pr_cdcooper in crapcop.cdcooper%TYPE) IS
    select cddepart, dsdepart
      from crapdpo
     where cdcooper = pr_cdcooper
       and cddepart in (null); /* PARRAT TODOS ACESSOS ALTERAR E CONSLUTAR*/
  rw_crapdpo_consulta cr_crapdpo_consulta%ROWTYPE;
  -- busca grupo departamento para  consultar / Altearr
  cursor cr_crapdpo_alterar(pr_cdcooper in crapcop.cdcooper%TYPE) IS
    select cddepart, dsdepart
      from crapdpo
     where cdcooper = pr_cdcooper
       and cddepart in (7, 11, 9,14);
  rw_crapdpo_alterar cr_crapdpo_alterar%ROWTYPE;

  --- busca operadores do grupo e coopertiva 
  cursor cr_crapope(pr_cdcooper in crapcop.cdcooper%TYPE,
                    pr_cddepart in crapope.cddepart%TYPE) is
    select cdoperad
      from crapope t
     where cdcooper = pr_cdcooper
--       and cddepart = pr_cddepart
       AND t.cdoperad IN ('f0031090','f0030689','f0030517','f0031803','f0030688','f0030567','f0030539')
       ;
  rw_crapope  cr_crapope%ROWTYPE;
  v_contcons  number := 0;
  v_contalter number := 0;
   
BEGIN
  
  DELETE FROM crapace a  --CDCOOPER, UPPER(NMDATELA), UPPER(NMROTINA), UPPER(CDDOPCAO), UPPER(CDOPERAD), IDAMBACE
        WHERE a.cdcooper = 3
          AND UPPER(NMDATELA) = UPPER('PARRAT') 
          AND UPPER(NMROTINA) = UPPER(' ');
  COMMIT;
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
      --faz o insert para operadores do grupo   consultar/ altearção 
      FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper,
                                   rw_crapdpo_alterar.cddepart) LOOP
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
      END LOOP; -- fim operadores
       
     dbms_output.put_line('Coop: '||rw_crapcop.cdcooper||'-'||rw_crapcop.NMRESCOP||' Concedido permissões Alteração/consulta grupo: '||rw_crapdpo_alterar.cddepart||' - '||rw_crapdpo_alterar.dsdepart||'. Totais de registros: '||v_contalter);

  END LOOP;    -- fim cooperativas
  COMMIT;

EXCEPTION
  WHEN dup_val_on_index THEN
    NULL;
  when others then
    dbms_output.put_line('Encontrado erro' ||sqlcode);
end;
0
0
