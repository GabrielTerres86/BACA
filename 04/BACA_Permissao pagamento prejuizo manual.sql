 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 4
    Autor       : Lucas Lazari da Silva (GFT)
    Data        : Abril/2019
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS->PREJUIZO
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- Atualiza as permissões das telas de borderô
UPDATE craptel 
   SET cdopptel = concat(cdopptel, ',D,B'), 
       lsopptel = concat (lsopptel, ',PREJUIZO,ABONO PREJUIZO')
 WHERE nmdatela = 'ATENDA' 
   AND nmrotina = 'DSC TITS - BORDERO'
   AND cdcooper NOT IN (7,3)
   AND cdcooper IN (SELECT cdcooper from crapcop cop where cop.flgativo = 1);
   
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
     WHERE cop.cdcooper NOT IN (7,3) /*14);*/ 
       AND cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND upper(acn.cddopcao) = 'C' -- copia permissões do botão "consultar"
       AND upper(acn.nmrotina) = 'DSC TITS - BORDERO'
       AND upper(acn.nmdatela) = 'ATENDA'
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
     WHERE cop.cdcooper NOT IN (7,3) /*14);*/ 
       AND cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND upper(acn.cddopcao) = 'A' -- copia permissões de concessão de abono de empréstimos
       AND upper(acn.nmrotina) = 'PRESTACOES'
       AND upper(acn.nmdatela) = 'ATENDA'
       AND acn.idambace = 2;

commit;
end;