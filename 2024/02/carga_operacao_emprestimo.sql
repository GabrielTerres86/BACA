DECLARE
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_principal(pr_cdcooper IN INTEGER) IS
    SELECT o.rowid rowid_ope
          ,e.*
      FROM gestaoderisco.tbrisco_central_carga c
          ,gestaoderisco.tbrisco_carga_operacao o
          ,gestaoderisco.tbrisco_operacao_emprestimo e
          ,cecred.crapdat d
     WHERE c.idcentral_carga = o.idcentral_carga
       AND e.idcarga_operacao = o.idcarga_operacao
       AND d.cdcooper = c.cdcooper
       AND c.dtrefere = d.dtmvcentral
       AND c.cdcooper = pr_cdcooper
       AND c.tpproduto = 90;
  rw_principal cr_principal%ROWTYPE;
  
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      BEGIN
        UPDATE gestaoderisco.tbrisco_carga_operacao o
           SET o.dtvencimento = rw_principal.dtultpar
              ,o.dtproxima_parcela = rw_principal.dtprxpar
              ,o.vlproxima_parcela = rw_principal.vlprxpar
              ,o.cdmodalidade = rw_principal.cdmodali
              ,o.cdrisco_refinanciamento = rw_principal.inrisref
        WHERE o.rowid = rw_principal.rowid_ope;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Erro ao atualizar rowid: ' || rw_principal.rowid_ope || ' - ' || SQLERRM);
      END;
    END LOOP;
  END LOOP;

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, 'Erro: ' || SQLERRM);
END;
