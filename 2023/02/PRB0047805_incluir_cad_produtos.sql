DECLARE

   CURSOR cr_crapcop IS
     SELECT c.cdcooper, t.inpessoa, t.cdtipo_conta
       FROM cecred.tbcc_tipo_conta_coop t
          , cecred.crapcop c
      WHERE t.cdcooper = c.cdcooper
        AND c.flgativo = 1
        AND c.cdcooper <> 3;
        
BEGIN
  
  INSERT INTO cecred.tbcc_produto
                 (cdproduto
                 ,dsproduto
                 ,flgitem_soa
                 ,flgutiliza_interface_padrao
                 ,flgenvia_sms
                 ,flgcobra_tarifa
                 ,idfaixa_valor
                 ,flgproduto_api)
          VALUES (60
                 ,'POUPANCA'
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0);
  
  FOR dados IN cr_crapcop LOOP
    
    INSERT INTO cecred.tbcc_produtos_coop
                   (cdcooper
                   ,tpconta
                   ,cdproduto
                   ,nrordem_exibicao
                   ,tpproduto
                   ,inpessoa)
             VALUES(dados.cdcooper
                   ,dados.cdtipo_conta
                   ,60
                   ,40
                   ,2
                   ,dados.inpessoa);
    
  END LOOP;
  
  INSERT INTO cecred.tbcc_produto
                 (cdproduto
                 ,dsproduto
                 ,flgitem_soa
                 ,flgutiliza_interface_padrao
                 ,flgenvia_sms
                 ,flgcobra_tarifa
                 ,idfaixa_valor
                 ,flgproduto_api)
          VALUES (61
                 ,'PACOTE DE SERVICOS'
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0);
  
  FOR dados IN cr_crapcop LOOP
    
    INSERT INTO cecred.tbcc_produtos_coop
                   (cdcooper
                   ,tpconta
                   ,cdproduto
                   ,nrordem_exibicao
                   ,tpproduto
                   ,inpessoa)
             VALUES(dados.cdcooper
                   ,dados.cdtipo_conta
                   ,61
                   ,41
                   ,2
                   ,dados.inpessoa);
    
  END LOOP;
  
  INSERT INTO cecred.tbcc_produto
                 (cdproduto
                 ,dsproduto
                 ,flgitem_soa
                 ,flgutiliza_interface_padrao
                 ,flgenvia_sms
                 ,flgcobra_tarifa
                 ,idfaixa_valor
                 ,flgproduto_api)
          VALUES (62
                 ,'CREDITO IMOBILIARIO'
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0);
  
  FOR dados IN cr_crapcop LOOP
    
    INSERT INTO cecred.tbcc_produtos_coop
                   (cdcooper
                   ,tpconta
                   ,cdproduto
                   ,nrordem_exibicao
                   ,tpproduto
                   ,inpessoa)
             VALUES(dados.cdcooper
                   ,dados.cdtipo_conta
                   ,62
                   ,42
                   ,2
                   ,dados.inpessoa);
    
  END LOOP;
  
  INSERT INTO cecred.tbcc_produto
                 (cdproduto
                 ,dsproduto
                 ,flgitem_soa
                 ,flgutiliza_interface_padrao
                 ,flgenvia_sms
                 ,flgcobra_tarifa
                 ,idfaixa_valor
                 ,flgproduto_api)
          VALUES (63
                 ,'APLICACAO LCI'
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0);
  
  FOR dados IN cr_crapcop LOOP
    
    INSERT INTO cecred.tbcc_produtos_coop
                   (cdcooper
                   ,tpconta
                   ,cdproduto
                   ,nrordem_exibicao
                   ,tpproduto
                   ,inpessoa)
             VALUES(dados.cdcooper
                   ,dados.cdtipo_conta
                   ,63
                   ,43
                   ,2
                   ,dados.inpessoa);
    
  END LOOP;
  
  COMMIT;
  
END;
