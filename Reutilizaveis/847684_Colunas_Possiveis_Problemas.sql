/*Lista as Tabelas/Colunas com possíveis problemas favor validar*/

SELECT *
  FROM cecreddba.tbcampos_criptografados
 WHERE nmtarefa IN (SELECT task_name
                      FROM dbms_parallel_execute_chunks$
                     WHERE status <> 2);
