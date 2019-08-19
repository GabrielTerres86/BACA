 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Cassia de Oliveira (GFT)
    Data        : Novembro/2018
    Objetivo    : Realiza o cadastro do relatorio de estorno de desconto de titulo 
  ---------------------------------------------------------------------------------------------------------------------*/
begin

INSERT INTO 
	craprel(
		dsdemail,
		indaudit,
		ingerpdf,
		inimprel,
		nmdestin,
		nmformul,
		nmrelato,
		nrmodulo,
		nrseqpri,
		nrviadef,
		nrviamax,
		periodic,
		tprelato,
		cdrelato,
		cdcooper,
		cdfilrel
	) 
SELECT 
	dsdemail,
	indaudit,
	ingerpdf,
	inimprel,
	nmdestin,
	nmformul,
	nmrelato,
	nrmodulo,
	nrseqpri,
	nrviadef,
	nrviamax,
	periodic,
	tprelato,
	770,
	cdcooper,
	cdfilrel 
FROM 
	craprel 
WHERE 
	cdrelato = 710;
	
commit;
end;