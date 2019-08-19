SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 13
   AND lcm.nrdconta = 744
   AND lcm.dtmvtolt BETWEEN '10/08/2018' AND '14/02/2019' --10/08/2018 a 14/02/2019
   AND lcm.cdhistor in (548, 575);

