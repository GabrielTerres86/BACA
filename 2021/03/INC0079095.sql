DECLARE

  CURSOR cr_cpf IS
    SELECT COUNT(t.cpf) count_cpf
          ,t.cpf
          ,t.nm_cpf
      FROM (SELECT cecred.gene0002.fn_mask_cpf_cnpj(to_number(regexp_replace(crapcbf.dsfraude,'[^0-9]','')),1) cpf
                  ,to_number(regexp_replace(crapcbf.dsfraude, '[^0-9]', '')) nm_cpf
              FROM crapcbf
             WHERE tpfraude = 2) t
     GROUP BY t.cpf
             ,t.nm_cpf
    HAVING COUNT(t.cpf) > 1;

  CURSOR cr_cnpj IS
    SELECT COUNT(t.cnpj) count_cnpj
          ,t.cnpj
          ,t.nm_cnpj
      FROM (SELECT cecred.gene0002.fn_mask_cpf_cnpj(to_number(regexp_replace(crapcbf.dsfraude,'[^0-9]','')),2) cnpj
                  ,to_number(regexp_replace(crapcbf.dsfraude, '[^0-9]', '')) nm_cnpj
              FROM crapcbf
             WHERE tpfraude = 3) t
     GROUP BY t.cnpj
             ,t.nm_cnpj
    HAVING COUNT(t.cnpj) > 1;

BEGIN

  FOR rw_cpf IN cr_cpf LOOP
    DELETE crapcbf
     WHERE rownum < rw_cpf.count_cpf
       AND to_number(regexp_replace(crapcbf.dsfraude, '[^0-9]', '')) = rw_cpf.nm_cpf;
  END LOOP;

  UPDATE crapcbf
     SET dsfraude = cecred.gene0002.fn_mask_cpf_cnpj(to_number(regexp_replace(dsfraude,'[^0-9]','')),1)
   WHERE tpfraude = 2;

  FOR rw_cnpj IN cr_cnpj LOOP
    DELETE crapcbf
     WHERE rownum < rw_cnpj.count_cnpj
       AND to_number(regexp_replace(crapcbf.dsfraude, '[^0-9]', '')) = rw_cnpj.nm_cnpj;
  END LOOP;

  UPDATE crapcbf
     SET dsfraude = cecred.gene0002.fn_mask_cpf_cnpj(to_number(regexp_replace(dsfraude,'[^0-9]','')),2)
   WHERE tpfraude = 3;

  COMMIT;
END;
/
