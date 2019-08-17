 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela TAB089 - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Cassia de Oliveira (GFT)
    Data        : Setembro/2018
    Objetivo    : Criar parametro na tabela CRAPPRM para a tela TAB089 
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- Insere o valor maximo por cooperativa de estorno permitido sem autorização para desconto de titulo
INSERT INTO crapprm
	(nmsistem, 
	 cdcooper, 
	 cdacesso, 
	 dstexprm, 
	 dsvlrprm)
	SELECT 'CRED', 
           cdcooper, 
           'VL_MAX_ESTORN_DST', 
           'Vl. máx. de estorno perm. sem autorização da coordenação/gerência para desconto de titulo', 
           SUBSTR(dstextab,40,12)
	  FROM craptab
	 WHERE nmsistem = 'CRED' 
       AND tptabela = 'USUARI'
       AND cdempres = 11
       AND cdacesso = 'PAREMPREST'
       AND tpregist = 01;

commit;
end;

