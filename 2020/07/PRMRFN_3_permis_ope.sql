-- Created on 21/07/2020 by T0032717 
DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  vr_cddopcao_nova VARCHAR(50) := '@,C,H,D'; -- opcoes/permissoes da tela que serao adicionadas
  -- Operadores a serem permitidos
  vr_operadores VARCHAR2(2000) := 'f0030689,f0030516,f0032113,f0020517,f0032005,f0030835';

  vr_nmdatela VARCHAR(10) := 'PRMRFN'; -- tela que serao liberadas as permissoes

  vr_lista     GENE0002.typ_split;
  vr_lista_ope GENE0002.typ_split;
BEGIN

  vr_lista     := GENE0002.fn_quebra_string(pr_string => vr_cddopcao_nova, pr_delimit => ',');
  vr_lista_ope := GENE0002.fn_quebra_string(pr_string => vr_operadores, pr_delimit => ',');

  FOR vr_idx_lst IN 1 .. vr_lista.COUNT LOOP
    FOR vr_idx_ope IN 1 .. vr_lista_ope.COUNT LOOP
      FOR rw_crapcop IN cr_crapcop LOOP
        INSERT INTO CRAPACE
          (NMDATELA,
           CDDOPCAO,
           CDOPERAD,
           NMROTINA,
           CDCOOPER,
           NRMODULO,
           IDEVENTO,
           IDAMBACE)
        VALUES
          (vr_nmdatela,
           vr_lista(vr_idx_lst),
           vr_lista_ope(vr_idx_ope),
           ' ',
           rw_crapcop.cdcooper,
           1,
           1,
           1);
      
        INSERT INTO CRAPACE
          (NMDATELA,
           CDDOPCAO,
           CDOPERAD,
           NMROTINA,
           CDCOOPER,
           NRMODULO,
           IDEVENTO,
           IDAMBACE)
        VALUES
          (vr_nmdatela,
           vr_lista(vr_idx_lst),
           vr_lista_ope(vr_idx_ope),
           ' ',
           rw_crapcop.cdcooper,
           1,
           1,
           2);
      END LOOP;
    END LOOP;
  END LOOP;
  COMMIT;
END;
