 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : Tela ATENDA->DESCONTOS->TITULOS->LIMITES - Script de carga
    Projeto     : 403 - Desconto de Títulos - Release 3
    Autor       : Lucas Lazari (GFT)
    Data        : Maio/2018
    Objetivo    : Cadastra os registros de parâmetros e mensageria para as funcionalidades da Release 3
  ---------------------------------------------------------------------------------------------------------------------*/

begin

-- Permissões para as telas de proposta e contrato da tela ATENDA->DESCONTOS->TITULOS
INSERT INTO craptel (nmdatela,
                     nrmodulo,
                     cdopptel,
                     tldatela,
                     tlrestel,
                     flgteldf,
                     flgtelbl,
                     nmrotina,
                     lsopptel,
                     inacesso,
                     cdcooper,
                     idsistem,
                     idevento,
                     nrordrot,
                     nrdnivel,
                     nmrotpai,
                     idambtel)
             SELECT 'ATENDA',
                    5,
                    '@,A,X,C,I,M,N,D,F',
                    'Propostas de Limite de Desconto de Titulo',
                    'Propostas Desc. Tit.',
                    0,
                    1,
                    'DSC TITS - PROPOSTA',
                    'ACESSO,ALTERACAO,CANCELAMENTO,CONSULTA,INCLUSAO,IMPRESSAO,ANALISE,DETALHAMENTO,EFETIVACAO',
                    2,
                    cdcooper,
                    1,
                    0,
                    0,
                    3,
                    'DSC TITS',
                    2
               FROM crapcop
              WHERE flgativo = 1;               

INSERT INTO craptel 
  (nmdatela,
   nrmodulo,
   cdopptel,
   tldatela,
   tlrestel,
   flgteldf,
   flgtelbl,
   nmrotina,
   lsopptel,
   inacesso,
   cdcooper,
   idsistem,
   idevento,
   nrordrot,
   nrdnivel,
   nmrotpai,
   idambtel)
  SELECT 'ATENDA',
          5,
          '@,X,C,M,D',
          'Contratos de Limite de Desconto de Titulo',
          'Contratos Desc. Tit.',
          0,
          1,
          'DSC TITS - CONTRATO',
          'ACESSO,CANCELAMENTO,CONSULTA,IMPRESSAO,DETALHAMENTO',
          2,
          cdcooper,
          1,
          0,
          0,
          3,
          'DSC TITS',
          2
     FROM crapcop
    WHERE flgativo = 1;  

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
           '@', 
           ope.cdoperad,
           'DSC TITS - CONTRATO',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = '@'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'X', 
           ope.cdoperad,
           'DSC TITS - CONTRATO',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'X'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'C', 
           ope.cdoperad,
           'DSC TITS - CONTRATO',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'C'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'M', 
           ope.cdoperad,
           'DSC TITS - CONTRATO',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'D', 
           ope.cdoperad,
           'DSC TITS - CONTRATO',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'D'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           '@', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = '@'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'X', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'X'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'C', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'C'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'M', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'M'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'D', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'D'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'A', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'A'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'I', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'I'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'N', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'N'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
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
           'F', 
           ope.cdoperad,
           'DSC TITS - PROPOSTA',
           acn.cdcooper,
           acn.nrmodulo,
           acn.idevento,
           acn.idambace
      FROM crapcop cop,
           crapope ope,
           crapace acn
     WHERE cop.flgativo = 1
       AND ope.cdsitope = 1 
       AND cop.cdcooper = ope.cdcooper
       AND acn.cdcooper = ope.cdcooper
       AND trim(upper(acn.cdoperad)) = trim(upper(ope.cdoperad))
       AND acn.cddopcao = 'F'
       AND acn.nmrotina = 'DSC TITS - LIMITE'
       AND acn.nmdatela = 'ATENDA'
       AND acn.idambace = 2;

--Delete as permissoes que nao vao ser mais usadas dos usuarios
DELETE FROM crapace WHERE nmrotina='DSC TITS - LIMITE' AND nmdatela='ATENDA' AND cddopcao NOT IN ('@', 'U', 'V');

--Atualiza o acesso apenas para os que restaram
UPDATE craptel SET cdopptel='@,U,V', lsopptel='ACESSO,MANUTENCAO,RENOVACAO'  WHERE nmdatela='ATENDA' AND nmrotina='DSC TITS - LIMITE';

commit;
end;