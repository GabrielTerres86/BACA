delete
  from crapace c
 where c.nmdatela = 'SEGPRE';
 
delete
  from craptel c
 where c.nmdatela = 'SEGPRE';
 
delete
 from crapprg c
where c.cdprogra = 'SEGPRE';

delete
  from crapaca c
 where c.nmpackag = 'TELA_SEGPRE';

delete
 from CRAPRDR c
where c.nmprogra = 'TELA_SEGPRE';

insert into crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
values ('SEGPRE', '@', 'f0031993', ' ', 3, 1, 0, 2);
 
insert into crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
values ('SEGPRE', 'A', 'f0031993', ' ', 3, 1, 0, 2);

insert into crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
values ('SEGPRE', 'C', 'f0031993', ' ', 3, 1, 0, 2);


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
  SELECT 'SEGPRE',
         12,
         '@,A,C',
         'PARAMETROS SEGURO PRESTAMISTA',
         'SEG. PRT.',
         0,
         1, 
         ' ',
         'Acesso,Alterar,Consultar',
         1,
         cdcooper, 
         1,
         0,
         1,
         1,
         '',
         2
    FROM crapcop
   WHERE cdcooper = 3;

INSERT INTO crapace
  (nmdatela,
   cddopcao,
   cdoperad,
   nmrotina,
   cdcooper,
   nrmodulo,
   idevento,
   idambace)
  (SELECT 'SEGPRE',
          cddopcao,
          cdoperad,
          'SEG. PRT.',
          cdcooper,
          12,
          idevento,
          idambace
     FROM crapace
    WHERE nmdatela = 'TAB049'
      and cdcooper = 3);

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
         'SEGPRE',
         'SEG. PRT.',
         '.',
         '.',
         '.',
         0,
         NULL,
         1,
         0,
         0,
         0,
         0,
         0,
         1,
         cdcooper
    FROM crapcop
   WHERE cdcooper IN 3;

INSERT INTO CRAPRDR (nmprogra, dtsolici) values ('TELA_SEGPRE', sysdate);

insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'SEGPRE_ALTERAR',
   'TELA_SEGPRE',
   'pc_alterar',
   'PR_CDCOPER,PR_TPPESSOA,PR_CDSEGURA,PR_TPDPAGTO,PR_MODALIDA ,PR_QTPARCEL ,PR_PIEDIAS  ,PR_PIEPARCE ,PR_IFTTDIAS ,PR_IFTTPARC ,PR_TPCUSTEI ,PR_TPADESAO ,PR_VIGENCIA ,PR_NRAPOLIC ,PR_ENDERFTP ,PR_LOGINFTP ,PR_SENHAFTP ,PR_FLGELEPF ,PR_FLGINDEN ,PR_IDADEMIN ,PR_IDADEMAX ,PR_GBIDAMIN ,PR_GBIDAMAX ,PR_PIELIMIT ,PR_PIETAXA  ,PR_IFTTLIMI ,PR_IFTTTAXA ,PR_LMPSELEG ,PR_VLCOMISS ,PR_LIMITDPS ,PR_CAPITMIN ,PR_CAPITMAX ,PR_GBSEGMIN ,PR_GBSEGMAX ,PR_IDADEDPS', 
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'TELA_SEGPRE'));

insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'SEGPRE_CONSULTA_SEGURADORAS',
   'TELA_SEGPRE',
   'pc_carrega_seguradoras',
   'pr_cdcoper',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'TELA_SEGPRE'));

insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'SEGPRE_CONSULTAR',
   'TELA_SEGPRE',
   'pc_consultar',
   'PR_CDCOPER,   PR_TPPESSOA,   PR_CDSEGURA',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'TELA_SEGPRE'));
   
insert into crapaca
  (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values
  ((select max(NRSEQACA) + 1 from crapaca),
   'SEGPRE_CONSULTA_COOPERATIVAS',
   'TELA_SEGPRE',
   'pc_carrega_cooperativas',
   '',
   (select nrseqrdr from CRAPRDR WHERE NMprogra = 'TELA_SEGPRE'));   
   
commit;
/