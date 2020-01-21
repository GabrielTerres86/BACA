
--criação na crapaca
DECLARE
  vr_nrseqrdr NUMBER;
   
BEGIN

INSERT INTO craprdr (nmprogra,dtsolici) VALUES ('TELA_IMPBVT',SYSDATE)
RETURNING nrseqrdr INTO vr_nrseqrdr;

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('IMPBVT_IMPORTA_ARQUIVO_PF', 'TELA_IMPBVT', 'pc_importar_arquivo_pf', 'pr_dsarquivo,pr_dsdireto', vr_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('IMPBVT_IMPORTA_ARQUIVO_PJ', 'TELA_IMPBVT', 'pc_importar_arquivo_pj', 'pr_dsarquivo,pr_dsdireto', vr_nrseqrdr);

INSERT INTO crapprg
    (nmsistem,
     cdprogra,
     dsprogra##1,
     dsprogra##2,
     dsprogra##3,
     dsprogra##4,
     nrsolici,
     nrordprg,
     inctrprg,
     cdrelato##1,
     cdrelato##2,
     cdrelato##3,
     cdrelato##4,
     cdrelato##5,
     inlibprg,
     cdcooper) 
    SELECT 'CRED',
           'IMPBVT',
           'IMPORTACAO DADOS CADASTRAIS LAYOUT BOA VISTA',
           '.',
           '.',
           '.',
           50,
           (select max(crapprg.nrordprg) + 1 from crapprg where crapprg.cdcooper = crapcop.cdcooper and crapprg.nrsolici = 50),
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           cdcooper
      FROM crapcop          
     WHERE flgativo = 1; 

insert into craptel 
(NMDATELA, 
 NRMODULO, 
 CDOPPTEL, 
 TLDATELA, 
 TLRESTEL, 
 FLGTELDF, 
 FLGTELBL, 
 NMROTINA, 
 LSOPPTEL, 
 INACESSO, 
 CDCOOPER, 
 IDSISTEM, 
 IDEVENTO, 
 NRORDROT, 
 NRDNIVEL, 
 NMROTPAI, 
 IDAMBTEL, 
 PROGRESS_RECID)
 SELECT 'IMPBVT', 
       6, 
     '@,F,J', 
     'IMPORTACAO DADOS CADASTRAIS LAYOUT BOA VISTA', 
     'CON.IMP.BVT.', 
     0, 
     1, 
     ' ', 
     'ACESSO,CONSULTAR,IMPORTAR', 
     1,
     cdcooper, 
     1, 
     0, 
     1, 
     1, 
     ' ', 
     2,
     NULL FROM crapcop
     where flgativo = 1
	  and  cdcooper =3; 

	  
	  

 
COMMIT;

END; 