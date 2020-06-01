PL/SQL Developer Test script 3.0
128
declare
  cursor cr_crapope is
    select cdoperad, cdcooper
      from crapope 
     where ( cdcooper = 1
             and UPPER(cdoperad) IN ('F0011233',
                                     'F0010417',
                                     'F0012108')
           )
      OR ( CDCOOPER = 2
            AND UPPER(cdoperad) IN ('F0020294')
          )
      OR ( CDCOOPER = 5
            AND UPPER(cdoperad) IN ('F0050084',
                                    'F0050200',
                                    'F0050040')
          )
      OR ( CDCOOPER = 6
            AND UPPER(cdoperad) IN ('F0060070',
                                    'F0060125',
                                    'F0060053',
                                    'F0060067')
          )
      OR ( CDCOOPER = 7
            AND UPPER(cdoperad) IN ('F0070149',
                                    'F0070446',
                                    'F0070359',
                                    'F0070032')
          )
      OR ( CDCOOPER = 8
            AND UPPER(cdoperad) IN ('F0080040',
                               'F0080077')
          )
      OR ( CDCOOPER = 9 
            AND UPPER(cdoperad) IN ('F0090103',
                                    'F0090315')
          )
      OR ( CDCOOPER = 10
            AND UPPER(cdoperad) IN ('F0100105',
                                    'F0100107')
          )
      OR ( CDCOOPER = 11
            AND UPPER(cdoperad) IN ('F0110296',
                                    'F0110025')
          )
      OR ( CDCOOPER = 12
            AND UPPER(cdoperad) IN ('F0120072',
                                    'F0120064')
          )
      OR ( CDCOOPER = 13
            AND UPPER(cdoperad) IN ('F0130198',
                                    'F0130116')
          )
      OR ( CDCOOPER = 14
            AND UPPER(cdoperad) IN ('F0140108',
                                    'F0140136',
                                    'F0140162')
          )
      OR ( CDCOOPER = 16
            AND UPPER(cdoperad) IN ('F0160017',
                                    'F0160160',
                                    'F0160351')
          )
      OR ( CDCOOPER = 3
            AND UPPER(cdoperad) IN ('F0030614',
                                    'F0032714')
           );
  
  SIGLA_TELA varchar2(400);
begin

  SIGLA_TELA := 'RCONSI';
    --FAZ O INSERT PARA OPERADORES DO GRUPO CONTROLE CONSULTAR
    FOR rw_crapope IN cr_crapope LOOP
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
             rw_crapope.cdcooper,
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
             'R',
             rw_crapope.cdoperad,
             ' ',
             rw_crapope.cdcooper,
             1,
             0,
             2);        
        EXCEPTION
          WHEN OTHERS THEN
            :result := 'Erro: ' || SQLERRM;
        END;
        
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
