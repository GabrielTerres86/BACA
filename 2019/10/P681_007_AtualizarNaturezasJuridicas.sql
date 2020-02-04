BEGIN

	UPDATE gncdntj 
	   SET flentpub = 1
		  ,cdgrpnat = 2
	WHERE cdnatjur IN (
	1031 --�rg�o P�blico do Poder Executivo Municipal
	,1066 --�rg�o P�blico do Poder Legislativo Municipal
	,1120 --Autarquia Municipal
	,1155 --Funda��o P�blica de Direito P�blico Municipal (Fundacao Municipal )
	,1180 --�rg�o P�blico Aut�nomo Municipal
	,1279 --Funda��o P�blica de Direito Privado Municipal
	,1309 --Fundo P�blico da Administra��o Indireta Municipal
	,1333 --Fundo P�blico da Administra��o Direta Municipal
	);
	
	UPDATE gncdntj 
	   SET flentpub = 1
		  ,cdgrpnat = 1
	WHERE cdnatjur = 1244; --Munic�pio
	
	-- Insere apenas se n�o existe
	declare
	  v_qtd  integer;
	begin
	  select count(1) 
	    into v_qtd 
	    from gncdntj g 
	   where g.cdnatjur = 1244;
	 
	  if v_qtd = 0 then
	    INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1244, 'Municipio', 'MUNICIPIO', 0, 1, 1);
	  end if;

	  select count(1) 
	    into v_qtd 
	    from gncdntj g 
	   where g.cdnatjur = 1279;
	 
	  if v_qtd = 0 then
	    INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1279, 'Fundacao Publica de Direito Privado Municipal', 'FUND PB.PV.MUN', 0, 1, 2);
	  end if;

	  select count(1) 
	    into v_qtd 
	    from gncdntj g 
	   where g.cdnatjur = 1309;
	 
	  if v_qtd = 0 then
	    INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1309, 'Fundo Publico da Administracao Indireta Municipal', 'FUNDO ADM IND', 0, 1, 2);
	  end if;
	
	  select count(1) 
	    into v_qtd 
	    from gncdntj g 
	   where g.cdnatjur = 1309;
	 
	  if v_qtd = 0 then
	    INSERT INTO gncdntj (CDNATJUR, DSNATJUR, RSNATJUR, FLGPRSOC, FLENTPUB, CDGRPNAT) VALUES (1333, 'Fundo Publico da Administracao Direta Municipal', 'FUNDO ADM DIR', 0, 1, 2);
	  end if;
		 
	end;

	COMMIT;
    
  -- Incluir o dominio dos grupos de natureza jur�dica
  INSERT INTO tbcc_dominio_campo(nmdominio,
                                 cddominio,
                                 dscodigo)
                          VALUES('GNCDNTJ.CDGRPNAT'
                                ,'1'
                                ,'ADMINISTRA��O DIRETA');
  
  -- Incluir o dominio dos grupos de natureza jur�dica
  INSERT INTO tbcc_dominio_campo(nmdominio,
                                 cddominio,
                                 dscodigo)
                          VALUES('GNCDNTJ.CDGRPNAT'
                                ,'2'
                                ,'ADMINISTRA��O INDIRETA');

  -- Incluir o dominio dos grupos de natureza jur�dica
  INSERT INTO tbcc_dominio_campo(nmdominio,
                                 cddominio,
                                 dscodigo)
                          VALUES('GNCDNTJ.CDGRPNAT'
                                ,'3'
                                ,'ATIVIDADES EMPRESARIAIS');
                                
  COMMIT;
                                
END;
