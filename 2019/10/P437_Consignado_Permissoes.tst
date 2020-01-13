PL/SQL Developer Test script 3.0
104
declare
  cursor cr_crapcop is
    select cdcooper
      from crapcop
     where flgativo = 1
       and cdcooper <> 3;

  cursor cr_crapope_central(pr_cdcooper in crapcop.cdcooper%TYPE) is
    select cdoperad 
      from crapope 
     where cdcooper = pr_cdcooper
       and UPPER(cdoperad) IN ('F0020294',
                                'F0030513',
                                'F0030614');
  
  SIGLA_TELA varchar2(400);
begin

  SIGLA_TELA := 'CONSIG';
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
    
    --FAZ O INSERT PARA OPERADORES DO GRUPO CONTROLE CONSULTAR
    FOR rw_crapope_central IN cr_crapope_central(rw_crapcop.cdcooper) LOOP
        BEGIN
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
             rw_crapope_central.cdoperad,
             ' ',
             rw_crapcop.cdcooper,
             1,
             0,
             2);        
        EXCEPTION
          WHEN OTHERS THEN
            :result := 'Erro: ' || SQLERRM;
        END;
        
        BEGIN
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
             'H',
             rw_crapope_central.cdoperad,
             ' ',
             rw_crapcop.cdcooper,
             1,
             0,
             2);        
        EXCEPTION
          WHEN OTHERS THEN
            :result := 'Erro: ' || SQLERRM;
        END;
        
        BEGIN
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
             'D',
             rw_crapope_central.cdoperad,
             ' ',
             rw_crapcop.cdcooper,
             1,
             0,
             2);        
        EXCEPTION
          WHEN OTHERS THEN
            :result := 'Erro: ' || SQLERRM;
        END;      
        
    END LOOP;
  
  END LOOP;
  
  COMMIT;
  
  :result := 'Sucesso';
end;
1
result
1
Sucesso
5
0
