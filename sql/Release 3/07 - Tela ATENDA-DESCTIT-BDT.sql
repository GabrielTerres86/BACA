 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- remove qualquer "lixo" de BD que possa ter  
/*
DELETE FROM crapace acn 
      WHERE acn.cddopcao IN ('P','I','R','A')
        AND acn.nmrotina = 'DSC TITS - BORDERO'
        AND acn.nmdatela = 'ATENDA'
        AND acn.idambace = 2;
*/

-- Atualiza as permissões das telas de borderô
UPDATE craptel 
   SET cdopptel = '@,N,C,M,L,P,I,R,A,E',
       lsopptel = 'ACESSO,ANALISE,CONSULTA,IMPRESSAO,LIBERACAO,PAGAR,INCLUIR,REJEITAR,ALTERAR,EXCLUIR',
       idambtel = 2 -- Ayllos Web
 WHERE nmrotina = 'DSC TITS - BORDERO'
   AND nmdatela = 'ATENDA'
   AND cdcooper IN (7,14);

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
           'P', -- Pagar
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.cdcooper IN (7,14)
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

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
           'I', -- Incluir
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.cdcooper IN (7,14)
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

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
           'R', -- Rejeitar
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.cdcooper IN (7,14)
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

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
           'A', -- Alterar
           ope.cdoperad,
           acn.nmrotina,
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.cdcooper IN (7,14)
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - BORDERO'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

commit;
end;