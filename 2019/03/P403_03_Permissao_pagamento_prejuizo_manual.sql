 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de T�tulos - Release 4
    Autor       : Cassia de Oliveira (GFT)
    Data        : Agosto/2018
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->T�TULOS->BORDER�S->PREJUIZO 
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- Atualiza as permiss�es das telas de border�
UPDATE craptel 
   SET cdopptel = concat(cdopptel, ',D,B'), 
       lsopptel = concat (lsopptel, ',PREJUIZO,ABONO PREJUIZO')
 WHERE nmdatela = 'ATENDA' 
   AND nmrotina = 'DSC TITS - BORDERO'
   AND cdcooper IN (7);
   
-- Fornece as permiss�es de acesso dos bot�es novos para os usu�rios que j� possuem permiss�o na tela de border�s
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
       AND acn.cddopcao = 'C' -- copia permiss�es do bot�o "consultar"
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

commit;

-- Fornece as permiss�es de acesso dos bot�es novos para os usu�rios que j� possuem permiss�o na tela de border�s
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
       AND acn.cddopcao = 'A' -- copia permiss�es de concess�o de abono de empr�stimos
       AND acn.nmrotina = 'PRESTACOES'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

commit;
end;