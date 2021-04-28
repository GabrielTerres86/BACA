begin 

  -- Setar valor default debito cartão
  UPDATE crapadc adc
     set adc.vllimdeb = CASE adc.CDADMCRD
                          WHEN 14 THEN 10000
                          WHEN 15 THEN 10000
                          ELSE 5000
                        END;

  -- Setar o valor PIX Cooperativa conforme o maior valor entre cartão debito ou de TED
  for rw_coop in (select cdcooper from crapcop where flgativo = 1 and cdagectl <> 0) loop
    update CRAPSNH S
       set s.vllimite_pix = (SELECT greatest(nvl(s.vllimted,0),(SELECT nvl(max(C.VLLIMDEB),0)
                                                                  FROM CRAPCRD A
                                                                 INNER JOIN CRAWCRD B
                                                                    ON A.CDCOOPER = B.CDCOOPER
                                                                   AND A.NRDCONTA = B.NRDCONTA
                                                                   AND A.NRCRCARD = B.NRCRCARD
                                                                 INNER JOIN CRAPADC C
                                                                    ON A.CDCOOPER = C.CDCOOPER
                                                                   AND A.CDADMCRD = C.CDADMCRD
                                                                 WHERE A.CDCOOPER = s2.CDCOOPER
                                                                   AND A.NRDCONTA = s2.NRDCONTA
                                                                   AND B.INSITCRD IN (3, 4)))
                                FROM CRAPSNH S2
                               WHERE S2.CDCOOPER = S.CDCOOPER
                                 AND S2.NRDCONTA = S.NRDCONTA
                                 AND S2.TPDSENHA = S.TPDSENHA
                                 AND S2.IDSEQTTL = S.IDSEQTTL
                                 AND S2.CDSITSNH = S.CDSITSNH)
     WHERE s.cdcooper = rw_coop.cdcooper
       AND S.TPDSENHA = 1 -- TIPO DE SENHA = INTERNET
       AND S.CDSITSNH = 1; -- SITUAÇÃO DA SENHA = ATIVO

    -- Copiar o valor PIX Cooperativa para Cooperado e garantir que valor limite web não fique inferior
    update CRAPSNH S
       set s.vllimite_pix_cooperado = s.vllimite_pix
     WHERE s.cdcooper = rw_coop.cdcooper
       AND S.TPDSENHA = 1 -- TIPO DE SENHA = INTERNET
       AND S.CDSITSNH = 1;-- SITUAÇÃO DA SENHA = ATIVO
  
  END LOOP;
  
  -- Gravação
  commit;
end;                          
                        
                        
