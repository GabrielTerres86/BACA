DECLARE
 vr_nrseqrdr number;
 vr_nrseqaca number;
BEGIN
  
    /*Cadastros ACA*/
    insert into craprdr(nrseqrdr, 
                        nmprogra, 
                        dtsolici)
                 values(null,
                        'TELA_ANALISE_CREDITO',
                        sysdate) returning nrseqrdr into vr_nrseqrdr;
      
    insert into crapaca(nrseqaca, 
                        nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                values (null,
                        'GERA_TOKEN_IBRATAN',
                        'TELA_ANALISE_CREDITO',
                        'PC_GERA_TOKEN_IBRATAN',
                        'pr_cdcooper,pr_cdoperad,pr_cdagenci,pr_fltoken',
                        vr_nrseqrdr);

    insert into crapaca(nrseqaca, 
                        nmdeacao, 
                        nmpackag, 
                        nmproced, 
                        lstparam, 
                        nrseqrdr) 
                values (null,
                        'CONSULTA_XML',
                        'TELA_ANALISE_CREDITO',
                        'pc_consulta_analise_creditoweb',
                        'pr_nrdconta,pr_tpproduto,pr_nrcontrato',
                        vr_nrseqrdr);

  FOR rw_crapcop IN ( SELECT * FROM crapcop )LOOP
 
      insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
      values ('TELUNI', 5, 'C', 'Tela Única de Análise', 'Tela Única de Análise', 0, 1, ' ', 'CONSULTAR', 1, rw_crapcop.cdcooper, 1, 0, 1, 1, ' ', 2);
      
      insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER)
      values ('CRED', 'TELUNI', 'Tela Única de Análise', ' ', ' ', ' ', 50, (SELECT MAX(g.nrordprg)+1 FROM crapprg g WHERE g.cdcooper = rw_crapcop.cdcooper AND g.nrsolici = 50), 1, 0, 0, 0, 0, 0, 1, rw_crapcop.cdcooper);
      
  END LOOP;
  
  /*Cadastro do birô*/
  insert into crapbir values ((select max(cdbircon)+1 from crapbir),'BV Score','BVSSCORE');

  /*Cadastro modalidades birô*/
  insert into crapmbr values (4,1,'BV Score PF',1,'PF12M',1);
  insert into crapmbr values (4,2,'BV Score PJ',2,'PJ12M',1);
  
  UPDATE crapbir b
     SET b.nmtagbir = 'BACENCOMPLETO'
   WHERE b.cdbircon = 3;   
   
  INSERT INTO crapace
    (nmdatela,
     cddopcao,
     cdoperad,
     nmrotina,
     cdcooper,
     nrmodulo,
     idevento,
     idambace)
    SELECT 'TELUNI' nmdatela,
           'C' cddopcao,
           ope.cdoperad cdoperad,
           ' ' nmrotina,
           ope.cdcooper cdcooper,
           1 nrmodulo,
           1 idevento,
           2 idambace
      FROM crapcop cop, crapope ope
     WHERE cop.cdcooper = ope.cdcooper
       AND NOT EXISTS (SELECT 1
                         FROM crapace a
                        WHERE a.cdcooper = cop.cdcooper
                          AND upper(a.nmdatela) = 'TELUNI'
                          AND a.cdoperad = ope.cdoperad
                          AND upper(a.cddopcao) = 'C' )
       AND upper(ope.cdoperad) IN ('F0030513',
                                   'F0032630',
                                   'F0032631',
                                   'F0030542',
                                   'F0030567',
                                   'F0031993',
                                   'F0031810',
                                   'F0030584',
                                   'F0030401',
                                   'F0030978',
                                   'F0030539',
                                   'F0030616',
                                   'F0030481',
                                   'F0030688',
                                   'F0032005',
                                   'F0032386',
                                   'F0030306',
                                   'F0032632',
                                   'F0030066',
                                   'F0030835',
                                   'F0030517',
								   'F0010309',
								   'F0010586',
								   'F0030566');
 
   
  
  COMMIT;
END;
