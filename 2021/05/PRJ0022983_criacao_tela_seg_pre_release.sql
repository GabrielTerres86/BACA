-- Insere a tela
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
         '@,A',
         'PARAMETROS SEGURO PRESTAMISTA',
         'SEG. PRT.',
         0,
         1, -- bloqueio da tela 
         ' ',
         'Acesso,Alterar',
         1,
         cdcooper, -- cooperativa
         1,
         0,
         1,
         1,
         '',
         2
    FROM crapcop
   WHERE cdcooper = 3;

-- Permissões de consulta para os usuários pré-definidos pela CECRED                       
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

-- Insere o registro de cadastro do programa
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
  ' PR_CDCOPER, PR_TPPESSOA, PR_CDSEGURA, PR_TPDPAGTO, PR_QTPARCEL, PR_PIEDIAS, PR_PIEPARCE, PR_IFTTDIAS, PR_IFTTPARC, PR_TPCUSTEI, PR_TPADESAO, PR_VIGENCIA, PR_NRAPOLIC, PR_ENDERFTP, PR_LOGINFTP, PR_SENHAFTP, PR_FLGELEPF, PR_FLGINDEN, PR_IDADEMIN, PR_IDADEMAX, PR_SEGMAT65, PR_SEGMAP65, PR_SEGIAT65, PR_SEGIAP65, PR_PIELIMIT, PR_PIETAXA, PR_IFTTLIMI, PR_IFTTTAXA, PR_LMPSELEG, PR_VLCOMISS, PR_LIMITDPS, PR_CAPITMIN, PR_CAPITMAX ', 
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

commit;
