 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Piloto por cooperativa
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Finaliza a "virada de chave" do piloto por cooperativa da funcionalidade de borderôs de desconto de títulos
  ---------------------------------------------------------------------------------------------------------------------*/

begin

UPDATE crapprm SET dsvlrprm = '1' WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = 'P';

commit;
end;