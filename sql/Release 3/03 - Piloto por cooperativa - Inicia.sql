 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Piloto por cooperativa
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : "Virade chave" do piloto por cooperativa da funcionalidade de borderôs de desconto de títulos
  ---------------------------------------------------------------------------------------------------------------------*/

begin

UPDATE crapprm SET dsvlrprm = '1' WHERE cdacesso = 'FL_VIRADA_BORDERO' AND cdcooper IN (14);

UPDATE craptel
   SET idambtel = 2  
 WHERE nmdatela IN ('TITCTO')
  AND  cdcooper IN (SELECT cdcooper FROM crapprm WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = '1');

commit;
end;