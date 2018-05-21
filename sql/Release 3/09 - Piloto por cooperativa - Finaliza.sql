 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Piloto por cooperativa
    Projeto     : 403 - Desconto de T�tulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Finaliza a "virada de chave" do piloto por cooperativa da funcionalidade de border�s de desconto de t�tulos
  ---------------------------------------------------------------------------------------------------------------------*/

begin

UPDATE crapprm SET dsvlrprm = '1' WHERE cdacesso = 'FL_VIRADA_BORDERO' AND dsvlrprm = 'P';

commit;
end;