/*---------------------------------------------------------------------------------------------------------------------
  Programa    : Tela ATENDA->DESCONTOS->TITULOS->BORDEROS - Script de carga
  Projeto     : 403 - Desconto de Títulos - Release 4
  Autor       : Lucas Lazari da Silva (GFT)
  Data        : Abril/2019
  Objetivo    : Realiza o cadastro das novas funcionalidades da tela ATENDA->DESCONTOS->TÍTULOS->BORDERÔS->PREJUIZO
---------------------------------------------------------------------------------------------------------------------*/

BEGIN

  -- Atualiza as permissões das telas de borderô
  /*
  UPDATE craptel
     SET cdopptel = concat(cdopptel, ',D,B'),
         lsopptel = concat(lsopptel, ',PREJUIZO,ABONO PREJUIZO')
   WHERE nmdatela = 'ATENDA'
     AND nmrotina = 'DSC TITS - BORDERO'
     AND cdcooper NOT IN (7, 3)
     AND cdcooper IN (SELECT cdcooper
                        FROM crapcop cop
                       WHERE cop.flgativo = 1);
                       */

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
     WHERE cop.cdcooper NOT IN (7, 3)
       AND cop.flgativo = 1
       AND ope.cdsitope = 1
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND TRIM(upper(acn.cdoperad)) = TRIM(upper(ope.cdoperad))
       AND upper(acn.cddopcao) = 'C' -- copia permissões do botão "consultar"
       AND upper(acn.nmrotina) = 'DSC TITS - BORDERO'
       AND upper(acn.nmdatela) = 'ATENDA'
       AND acn.idambace = 2
       AND NOT EXISTS (SELECT 1
          FROM crapace a
         WHERE upper(a.nmdatela) = upper(acn.nmdatela)
           AND upper(a.cddopcao) = 'D' -- Prejuizo
           AND upper(a.cdoperad) = upper(ope.cdoperad)
           AND upper(a.nmrotina) = upper(acn.nmrotina)
           AND a.cdcooper = acn.cdcooper
         --  AND a.nrmodulo = acn.nrmodulo
         --  AND a.idevento = acn.idevento
           AND a.idambace = acn.idambace);
           
           
     --      CDCOOPER, UPPER(NMDATELA), UPPER(NMROTINA), UPPER(CDDOPCAO), UPPER(CDOPERAD), IDAMBACE

--  COMMIT;

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
     WHERE cop.cdcooper NOT IN (7, 3)
       AND cop.flgativo = 1
       AND ope.cdsitope = 1
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND TRIM(upper(acn.cdoperad)) = TRIM(upper(ope.cdoperad))
       AND upper(acn.cddopcao) = 'A' -- copia permissões de concessão de abono de empréstimos
       AND upper(acn.nmrotina) = 'PRESTACOES'
       AND upper(acn.nmdatela) = 'ATENDA'
       AND acn.idambace = 2
       
       AND NOT EXISTS (SELECT 1
          FROM crapace a
         WHERE upper(a.nmdatela) = acn.nmdatela
           AND upper(a.cddopcao) = 'B' -- Abono Prejuizo
           AND upper(a.cdoperad) = upper(ope.cdoperad)
           AND upper(a.nmrotina) = acn.nmrotina
           AND a.cdcooper = acn.cdcooper
         --  AND a.nrmodulo = acn.nrmodulo
         --  AND a.idevento = acn.idevento
           AND a.idambace = acn.idambace);
       

  COMMIT;
END;
