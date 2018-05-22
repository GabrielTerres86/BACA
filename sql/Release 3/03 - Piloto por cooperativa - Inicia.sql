 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Piloto por cooperativa
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Inicia a "virada de chave" do piloto por cooperativa da funcionalidade de borderôs de desconto de títulos
  ---------------------------------------------------------------------------------------------------------------------*/

begin

UPDATE crapprm SET dsvlrprm = 'P' WHERE cdacesso = 'FL_VIRADA_BORDERO' AND cdcooper IN (7,14);

-- Inclui a nova opção na tela TITCTO
UPDATE craptel
   SET idambtel = 2,
       cdopptel = 'C,F,L,Q,S,T,B',
       lsopptel = 'CONSULTA,FECHAMENTO,LOTES,QUEM,SALDO,PESQUISA,BORDERO'
 WHERE nmdatela = 'TITCTO'
  AND  cdcooper IN (7,14);

-- Insere a permissão da nova opção
INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,   
     nmrotina,   
     cdcooper,   
     nrmodulo,   
     idevento,   
     idambace)
    SELECT acn.nmdatela, 
           'B', 
           ope.cdoperad,
           ' ',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND cop.cdcooper IN (7,14)
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'L'
       AND acn.nmrotina = ' '
       AND acn.nmdatela = 'TITCTO'
       AND acn.idambace = 2;

commit;
end;