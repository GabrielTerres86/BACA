BEGIN

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPENDERECOENTREGAUNICRED', '10', 'Residêncial', 1);

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPENDERECOENTREGAUNICRED', '13', 'Correspondência', 1);

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPENDERECOENTREGAUNICRED', '14', 'Complementar', 1);

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPENDERECOENTREGAUNICRED', '9', 'Comercial', 1);

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPENDERECOENTREGAUNICRED', '90', 'PA', 1);

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPENDERECOENTREGAUNICRED', '91', 'Outro PA', 1);

	INSERT INTO tbcrd_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)
	VALUES ('TPFUNCIONALIDADEENTREGA', '2', 'Envio de cartão de crédito VISA - Unicred para o endereço do cooperado', 1);
  	
	DECLARE
   TYPE array_tpenvio IS VARRAY(6) OF PLS_INTEGER;
   codigos array_tpenvio := array_tpenvio(9, 10, 13, 14, 90, 91);	
	 
	 vr_xml_def  VARCHAR2(500);
	 vr_xml      XMLTYPE;
	 vr_xmllog   VARCHAR2(32000);
	 vr_cdcritic crapcri.cdcritic%TYPE;
	 vr_dscritic crapcri.dscritic%TYPE;
	 vr_xmlout   XMLTYPE;
	 vr_nmdcampo VARCHAR2(100);
	 vr_des_erro VARCHAR2(100);
	 
	  CURSOR cr_crapcop IS 
		   SELECT cdcooper
			   FROM crapcop c
				WHERE c.flgativo = 1
				  AND c.cdcooper <> 3;
					
		CURSOR cr_agenci(pr_cdcooper crapage.cdcooper%TYPE) IS
			SELECT listagg(age.cdagenci, ',') agencias
				FROM crapage age
			 WHERE age.cdcooper = pr_cdcooper;
		rw_agenci cr_agenci%ROWTYPE;
	BEGIN					
	   FOR cooper IN cr_crapcop LOOP
			   
		     OPEN  cr_agenci(cooper.cdcooper);
				 FETCH cr_agenci INTO rw_agenci;
				 CLOSE cr_agenci;
			   
			   FOR i IN 1..codigos.count LOOP
							vr_xml_def := '<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>TELA_PARECC</nmprogra>' ||
														'<nmeacao>ALTERA_PARAMS_PARECC</nmeacao><cdcooper>'||cooper.cdcooper||'</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem>' ||
														'<cdoperad>f0030641</cdoperad></params></Root>';                   
							vr_xml := XMLType.createXML(vr_xml_def);
									
							tela_parecc.pc_altera_params_parecc(
										pr_cdcooperativa => cooper.cdcooper
										,pr_idfuncionalidade => 2 
										,pr_flghabilitar => 1
										,pr_idtipoenvio => codigos(i)
										,pr_cdcooppodenviar => rw_agenci.agencias
										,pr_xmllog => vr_xmllog   
										,pr_cdcritic => vr_cdcritic 
										,pr_dscritic => vr_dscritic 
										,pr_retxml => vr_xml
										,pr_nmdcampo => vr_nmdcampo 
										,pr_des_erro => vr_des_erro 						 
							);
         END LOOP;
		 END LOOP;
	END;
	
	COMMIT;
END;
