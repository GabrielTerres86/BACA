PL/SQL Developer Test script 3.0
194
declare
  cursor cr_crapcop is
    select cdcooper
      from crapcop
     where flgativo = 1
       and cdcooper <> 3;

  cursor cr_crapope(pr_cdcooper in crapcop.cdcooper%TYPE) is
    select cdoperad 
      from crapope 
     where cdcooper = pr_cdcooper;
  
  cursor cr_crapope_central(pr_cdcooper in crapcop.cdcooper%TYPE) is
    select cdoperad 
      from crapope 
     where cdcooper = pr_cdcooper
       and UPPER(cdoperad) IN ('F0011233',
'F0010417',
'F0012108',
'F0050084',
'F0050200',
'F0050040',
'F0060137',
'F0060070',
'F0060125',
'F0060053',
'F0060067',
'F0070149',
'F0070446',
'F0070359',
'F0070032',
'F0080040',
'F0080077',
'F0090103',
'F0090315',
'F0100105',
'F0100107',
'F0110242',
'F0110245',
'F0110296',
'F0110025',
'F0120072',
'F0120064',
'F0130198',
'E0130031',
'F0140108',
'F0140136',
'F0140162',
'F0160017',
'F0160160',
'F0160351');
  
  SIGLA_TELA varchar2(400);
begin

  SIGLA_TELA := 'CONSIG';
  --PARA CADA COOPERATIVA CADASTRADA
  FOR rw_crapcop IN cr_crapcop LOOP
  
    --FAZ O INSERT PARA OPERADORES DO GRUPO CONTROLE CONSULTAR
    FOR rw_crapope IN cr_crapope(rw_crapcop.cdcooper) LOOP
    
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
           '@',
           rw_crapope.cdoperad,
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
           'C',
           rw_crapope.cdoperad,
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
