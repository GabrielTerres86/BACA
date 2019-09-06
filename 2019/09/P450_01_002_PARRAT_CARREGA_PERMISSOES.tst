PL/SQL Developer Test script 3.0
147
/* Libera acesso a tela PARRAT para os operadores do  cdcooper = 3. */
declare
  
  -- INFORME CDCOOPER CURSOR cr_crapcop -- QUAIS COOPERATIVAS
  -- INFORME cddepart CURSOR cr_crapdpo_consulta QUAIS grupos liberados para consulta
  -- INFORME cddepart CURSOR cr_crapdpo_alterar QUAIS grupos liberados para Alteração e consultar 
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
      from crapope
     where cdcooper = pr_cdcooper
       and cddepart = pr_cddepart;
  rw_crapope  cr_crapope%ROWTYPE;
  v_contcons  number := 0;
  v_contalter number := 0;
   
begin
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
    -- busca os grupos definidos para acessar sistema para consulta 
    for rw_crapdpo_consulta in cr_crapdpo_consulta(rw_crapcop.cdcooper) LOOP
    
      --FAZ O INSERT PARA OPERADORES DO GRUPOS APENAS  CONSULTAR
      FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper,
                                   rw_crapdpo_consulta.cddepart) LOOP
        v_contcons := nvl(v_contcons,0) + 1;
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
      END LOOP; -- FIM CURSOR OPERADORES
         dbms_output.put_line('Coop: '||rw_crapcop.cdcooper||'-'||rw_crapcop.NMRESCOP||' Concedido permissões Consulta grupo: '||rw_crapdpo_consulta.cddepart||' - '||rw_crapdpo_consulta.dsdepart||'. Totais de registros: '||v_contcons);
    end loop; -- FIM GRUPO PARA CONSULTA 
  
    ------------------------------------------------------------------------
    -- busca os grupos definidos para acessar sistema para alteração 
    for rw_crapdpo_alterar in cr_crapdpo_alterar(rw_crapcop.cdcooper) LOOP
    
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
    END LOOP;  -- fim grupos operadores
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
