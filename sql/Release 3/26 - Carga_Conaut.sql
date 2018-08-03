DECLARE
  /* Cursor das cooperativas */
  CURSOR cr_crapcop IS
    SELECT cdcooper
    FROM crapcop
  ;rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  OPEN cr_crapcop();
  LOOP FETCH cr_crapcop INTO rw_crapcop;
    EXIT WHEN cr_crapcop%NOTFOUND;
    /* Borderô de Títulos  Física  R$ 0,00  SPC  309 */         
    BEGIN
      INSERT INTO crappcb(cdcooper, inprodut, cdbircon, inpessoa, vlinicio, cdmodbir)
        VALUES(rw_crapcop.cdcooper,
                5, /* 5 - Desc. Titulo                      */
                1, /* 1 - SPC    ; 2 - Serasa ; 3 - Bacen   */
                1, /* 1 - Fisica ; 2 - Juridica             */
                0, /* Valor de inicio                       */
                1  /* 1 - 309/Relato Mais    ; 2 - 482        */
      );
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Já existente crappcb na Coop: '|| rw_crapcop.cdcooper || ' Desc.Tit;PF;0;SPC;309');
    END;
    
    /* Borderô de Títulos  Física  R$ 5.000,00  SPC  482 */
    BEGIN
      INSERT INTO crappcb(cdcooper, inprodut, cdbircon, inpessoa, vlinicio, cdmodbir)
        VALUES(rw_crapcop.cdcooper,
                5, /* 5 - Desc. Titulo        */
                1, /* 1 - SPC    ; 2 - Serasa ; 3 - Bacen     */
                1, /* 1 - Fisica ; 2 - Juridica */
                5000, /* Valor de inicio         */
                2  /* 1 - 309/Relato Mais    ; 2 - 482        */
      );
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Já existente crappcb na Coop: '|| rw_crapcop.cdcooper || ' Desc.Tit;PF;5000;SPC;482');
    END;
    
    /* Borderô de Títulos  Jurídica  R$ 0,00  Serasa  Relato Mais */
    BEGIN
      INSERT INTO crappcb(cdcooper, inprodut, cdbircon, inpessoa, vlinicio, cdmodbir)
        VALUES(rw_crapcop.cdcooper,
                5, /* 5 - Desc. Titulo                        */
                2, /* 1 - SPC    ; 2 - Serasa ; 3 - Bacen     */
                2, /* 1 - Fisica ; 2 - Juridica               */
                0, /* Valor de inicio                         */
                1  /* 1 - 309/Relato Mais    ; 2 - 482        */
      );
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Já existente crappcb na Coop: '|| rw_crapcop.cdcooper || ' Desc.Tit;PJ;0;SERASA;RELATO MAIS');
    END;
    
    /* Borderô de Títulos  Física  15 */
    BEGIN
      INSERT INTO craprbi(cdcooper, inprodut, inpessoa, qtdiarpv)
        VALUES(rw_crapcop.cdcooper,
                5, /* 5 - Desc. Titulo           */
                1, /* 1 - Fisica ; 2 - Juridica  */
               15 /* Qtd Dias                    */
      );
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Já existente craprbi na Coop: '|| rw_crapcop.cdcooper || ' Desc.Tit;PF;15');
    END;
    
    /* Borderô de Títulos  Jurídica  15 */
    BEGIN
      INSERT INTO craprbi(cdcooper, inprodut, inpessoa, qtdiarpv)
        VALUES(rw_crapcop.cdcooper,
                5, /* 5 - Desc. Titulo           */
                2, /* 1 - Fisica ; 2 - Juridica  */
               15 /* Qtd Dias                    */
      );
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        dbms_output.put_line('Já existente craprbi na Coop: '|| rw_crapcop.cdcooper || ' Desc.Tit;PJ;15');
    END;
  END LOOP;
END;