 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Cassia de Oliveira (GFT)
    Data        : Agosto/2018
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS->PREJUIZO 
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- Atualiza as permissões das telas de borderô
UPDATE craptel 
   SET cdopptel = concat(cdopptel, ',D,B'), 
       lsopptel = concat (lsopptel, ',PREJUIZO,ABONO PREJUIZO')
 WHERE nmdatela = 'ATENDA' 
   AND nmrotina = 'DSC TITS - BORDERO'
   AND cdcooper IN (7);
   
-- Fornece as permissões de acesso dos botões novos para os usuários que já possuem permissão na tela de borderôs
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
           'D', -- Prejuizo
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.cdcooper IN (7) /*14);*/ 
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'C' -- copia permissões do botão "consultar"
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

commit;

-- Fornece as permissões de acesso dos botões novos para os usuários que já possuem permissão na tela de borderôs
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
           'B', -- Abono Prejuizo
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.cdcooper IN (7) /*14);*/ 
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'A' -- copia permissões de concessão de abono de empréstimos
       AND acn.nmrotina = 'PRESTACOES'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

commit;
end;