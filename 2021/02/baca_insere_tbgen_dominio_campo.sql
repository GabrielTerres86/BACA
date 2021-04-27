BEGIN
	-- tpProdutoEmprestimo       CONSTANT NUMBER := 0;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPPRODUTO_RECIPROCIDADE'
																 ,'0'
																 ,'Empr�stimo'
																 );
	-- tpCategCotas              CONSTANT NUMBER := 0;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'0'
																 ,'Cotas'
																 );

	-- tpCategInvestimentos      CONSTANT NUMBER := 1;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'1'
																 ,'Investimentos'
																 );

	-- tpCategLimiteCredito      CONSTANT NUMBER := 2;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'2'
																 ,'Limite Cr�dito'
																 );

	-- tpCategLimiteEmpresarial  CONSTANT NUMBER := 3;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'3'
																 ,'Limite Empresarial'
																 );

	-- tpCategDomicilioBancario  CONSTANT NUMBER := 4;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'4'
																 ,'Domic�lio Banc�rio'
																 );

	-- tpCategConvenioFolhaPag   CONSTANT NUMBER := 5;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'5'
																 ,'Conv�nio Folha Pagamento'
																 );

	-- tpCategConvenioConsigado  CONSTANT NUMBER := 6;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'6'
																 ,'Conv�nio Consignado'
																 );

	-- tpCategConvenioCDC        CONSTANT NUMBER := 7;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'7'
																 ,'Conv�nio CDC'
																 );

	-- tpCategConsorcio          CONSTANT NUMBER := 8;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'8'
																 ,'Cons�rcio'
																 );

	-- tpCategSeguroEmpresarial  CONSTANT NUMBER := 9;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'9'
																 ,'Seguro Empresarial'
																 );

	-- tpCategSeguroAuto         CONSTANT NUMBER := 10;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'10'
																 ,'Seguro Auto'
																 );

	-- tpCategSeguroVida         CONSTANT NUMBER := 11;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'11'
																 ,'Seguro Vida'
																 );

	-- tpCategSeguroResidencia   CONSTANT NUMBER := 12;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'12'
																 ,'Seguro Resid�ncia'
																 );

	-- tpCategCartaoCred         CONSTANT NUMBER := 13;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'13'
																 ,'Cart�o Cr�dito'
																 );

	-- tpCategPix                CONSTANT NUMBER := 14;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'14'
																 ,'Pix'
																 );

	-- tpCategServico            CONSTANT NUMBER := 15;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'15'
																 ,'Servi�o'
																 );

	-- tpCategAutoatendimento    CONSTANT NUMBER := 16;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'16'
																 ,'Autoatendimento'
																 );

	-- tpCategPrevidencia        CONSTANT NUMBER := 17;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'17'
																 ,'Previd�ncia'
																 );

	-- tpCategRecebSalario       CONSTANT NUMBER := 18;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'18'
																 ,'Recebimento Sal�rio'
																 );
  
	-- tpCategCartaoCred         CONSTANT NUMBER := 19;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'19'
																 ,'Cart�o Cr�dito Cabal'
																 );

	-- tpCategCartaoCred         CONSTANT NUMBER := 20;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'20'
																 ,'Cart�o Cr�dito Cl�ssico'
																 );																 

	-- tpCategCartaoCred         CONSTANT NUMBER := 21;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'21'
																 ,'Cart�o Cr�dito Gold'
																 );		

	-- tpCategCartaoCred         CONSTANT NUMBER := 22;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'22'
																 ,'Cart�o Cr�dito Platinum'
																 );

	-- tpCategCartaoCred         CONSTANT NUMBER := 23;
	INSERT INTO tbgen_dominio_campo(nmdominio
																 ,cddominio
																 ,dscodigo
																 )
													 VALUES('TPCATEG_RECIPROCIDADE'
																 ,'23'
																 ,'Cart�o Cr�dito Empres�rial'
																 );
  COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;  
