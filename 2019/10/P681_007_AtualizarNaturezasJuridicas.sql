BEGIN

  /* ATUALIZAR AS NATUREZAS JURÍDICAS DISPONIVEIS AO ENTE PÚBLICO */

	UPDATE gncdntj 
	   SET flentpub = 1
		   , cdgrpnat = 2
	WHERE cdnatjur IN (1031 --Órgão Público do Poder Executivo Municipal
                    ,1066 --Órgão Público do Poder Legislativo Municipal
                    ,1120 --Autarquia Municipal
                    ,1155 --Fundação Pública de Direito Público Municipal (Fundacao Municipal )
                    ,1180 --Órgão Público Autônomo Municipal
                    ,1201 --Fundo Publico 
                    ,1210 --Associacao Publica
                    ,1228 --Consórcio Público de Direito Privado
                    ,1279 --Fundação Pública de Direito Privado Municipal
                    ,1309 --Fundo Público da Administração Indireta Municipal
                    ,1333 --Fundo Público da Administração Direta Municipal
	                  );
	
  UPDATE gncdntj 
     SET flentpub = 1
       , cdgrpnat = 1
   WHERE cdnatjur = 1244; --Município
	
  UPDATE gncdntj 
	   SET flentpub = 1
		   , cdgrpnat = 3
	WHERE cdnatjur IN (2011 --Empresa Publica 
                    ,2038 --Sociedade de Economia Mista 
	                  );
  
  /* INCLUSÃO DE NOVAS NATUREZAS JURÍDICAS QUE À PRINCIPIO NÃO ESTÃO NA BASE DE DADOS */
  
  -- Insere apenas se não existe
  DECLARE
    v_qtd INTEGER;
  BEGIN
    /***** 1244 *****/
    SELECT COUNT(1)
      INTO v_qtd
      FROM gncdntj g
     WHERE g.cdnatjur = 1244;
  
    IF v_qtd = 0 THEN
      INSERT INTO gncdntj
        (cdnatjur,dsnatjur,rsnatjur,flgprsoc,flentpub,cdgrpnat)
      VALUES
        (1244,'Municipio','MUNICIPIO',0,1,1);
    END IF;
    
    /***** 1279 *****/
    SELECT COUNT(1)
      INTO v_qtd
      FROM gncdntj g
     WHERE g.cdnatjur = 1279;
  
    IF v_qtd = 0 THEN
      INSERT INTO gncdntj
        (cdnatjur,dsnatjur,rsnatjur,flgprsoc,flentpub,cdgrpnat)
      VALUES
        (1279,'Fundacao Publica de Direito Privado Municipal','FUND PB.PV.MUN',0,1,2);
    END IF;
    
    /***** 1309 *****/
    SELECT COUNT(1)
      INTO v_qtd
      FROM gncdntj g
     WHERE g.cdnatjur = 1309;
  
    IF v_qtd = 0 THEN
      INSERT INTO gncdntj
        (cdnatjur,dsnatjur,rsnatjur,flgprsoc,flentpub,cdgrpnat)
      VALUES
        (1309,'Fundo Publico da Administracao Indireta Municipal','FUNDO ADM IND',0,1,2);
    END IF;
    
    /***** 1309 *****/
    SELECT COUNT(1)
      INTO v_qtd
      FROM gncdntj g
     WHERE g.cdnatjur = 1333;
  
    IF v_qtd = 0 THEN
      INSERT INTO gncdntj
        (cdnatjur,dsnatjur,rsnatjur,flgprsoc,flentpub,cdgrpnat)
      VALUES
        (1333,'Fundo Publico da Administracao Direta Municipal','FUNDO ADM DIR',0,1,2);
    END IF;
    
    /***** 1228 *****/
    SELECT COUNT(1)
      INTO v_qtd
      FROM gncdntj g
     WHERE g.cdnatjur = 1228;
  
    IF v_qtd = 0 THEN
      INSERT INTO gncdntj
        (cdnatjur,dsnatjur,rsnatjur,flgprsoc,flentpub,cdgrpnat)
      VALUES
        (1228,'Consorcio Publico de Direito Privado','CONSR.PB.DIR.PV',0,1,2);
    END IF;
    
  END;
  
  --
  COMMIT;
  --
  
  /* INCLUSÃO DO DOMINIO DA TABELA */
  
  BEGIN
    -- Incluir o dominio dos grupos de natureza jurídica
    INSERT INTO tbcc_dominio_campo
      (nmdominio,cddominio,dscodigo)
    VALUES
      ('GNCDNTJ.CDGRPNAT','1','ADMINISTRAÇÃO DIRETA');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20000,'Erro ao adicionar dominio: '||SQLERRM);
  END;
  
  BEGIN
    -- Incluir o dominio dos grupos de natureza jurídica
    INSERT INTO tbcc_dominio_campo
      (nmdominio,cddominio,dscodigo)
    VALUES
      ('GNCDNTJ.CDGRPNAT','2','ADMINISTRAÇÃO INDIRETA');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20001,'Erro ao adicionar dominio: '||SQLERRM);
  END;
  
  BEGIN
    -- Incluir o dominio dos grupos de natureza jurídica
    INSERT INTO tbcc_dominio_campo
      (nmdominio,cddominio,dscodigo)
    VALUES
      ('GNCDNTJ.CDGRPNAT','3','ATIVIDADES EMPRESARIAIS');
  EXCEPTION 
    WHEN dup_val_on_index THEN
      NULL;
    WHEN OTHERS THEN
      raise_application_error(-20002,'Erro ao adicionar dominio: '||SQLERRM);
  END;
  
  --
  COMMIT;
  --
                              
END;
