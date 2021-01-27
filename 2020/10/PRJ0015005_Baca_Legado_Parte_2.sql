begin 

  -- Criação dos acessos de novas telas
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop) LOOP 
    -- Criação LOGPIX 
    insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    values ('LOGPIX', 5, '@,C,D,S', 'Listagem de Transações PIX', 'Controle de Chaves PIX', 0, 1, ' ', 'ACESSO,CONSULTA,DETALHAMENTO DE TRANSAÇÃO,SALVAR COMO CSV', 2, rw_crapcop.cdcooper, 1, 0, 0, 0, ' ', 0);
    insert into CRAPPRG (nmsistem,cdprogra,dsprogra##1,dsprogra##2,dsprogra##3,dsprogra##4,nrsolici,nrordprg,inctrprg,cdrelato##1,cdrelato##2,cdrelato##3,cdrelato##4,cdrelato##5,inlibprg,cdcooper)
    values ('CRED','LOGPIX', 'Listagem de Transações PIX',NULL,NULL,NULL,980,999,1,0,0,0,0,0,0,RW_CRAPCOP.CDCOOPER);
  END LOOP;
  
  -- Copiar todos que tem acesso na LOGSPB para os acessos de @-Acesso, C-Consultar, D-Detalhar Chave e S-Salvar como CSV
  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LOGPIX','@',crapace.cdoperad,crapace.nmrotina,crapace.cdcooper,crapace.nrmodulo,crapace.idevento,crapace.idambace
  from crapace 
      ,crapope 
  where crapace.nmdatela = 'LOGSPB' AND crapace.CDDOPCAO = 'C' 
    and crapace.cdcooper = crapope.cdcooper
    and upper(crapace.cdoperad) = upper(crapope.cdoperad)
    and crapope.cdsitope = 1;

  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LOGPIX','C',crapace.cdoperad,crapace.nmrotina,crapace.cdcooper,crapace.nrmodulo,crapace.idevento,crapace.idambace
  from crapace 
      ,crapope 
  where crapace.nmdatela = 'LOGSPB' AND crapace.CDDOPCAO = 'C' 
    and crapace.cdcooper = crapope.cdcooper
    and upper(crapace.cdoperad) = upper(crapope.cdoperad)
    and crapope.cdsitope = 1;

  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LOGPIX','D',crapace.cdoperad,crapace.nmrotina,crapace.cdcooper,crapace.nrmodulo,crapace.idevento,crapace.idambace
  from crapace 
      ,crapope 
  where crapace.nmdatela = 'LOGSPB' AND crapace.CDDOPCAO = 'C' 
    and crapace.cdcooper = crapope.cdcooper
    and upper(crapace.cdoperad) = upper(crapope.cdoperad)
    and crapope.cdsitope = 1;

  insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace)
  select 'LOGPIX','S',crapace.cdoperad,crapace.nmrotina,crapace.cdcooper,crapace.nrmodulo,crapace.idevento,crapace.idambace
  from crapace 
      ,crapope 
  where crapace.nmdatela = 'LOGSPB' AND crapace.CDDOPCAO = 'C' 
    and crapace.cdcooper = crapope.cdcooper
    and upper(crapace.cdoperad) = upper(crapope.cdoperad)
    and crapope.cdsitope = 1;
  
  -- Inicializar tabela com controle de disponibilidade de sistema 
  insert into tbgen_disp_sistema
                     (fldisponibilidade
                     ,cdorigem_atualizacao
                     ,dhultima_atualizacao
                     ,cdusuario_ultima_atualizacao)
               values(2 /* Em manutenção*/
                     ,2 /* Manual */
                     ,sysdate
                     ,'PROCESSO DE LIBERACAO');
  
  insert into tbgen_disp_sistema_logs
                    (fldisponibilidade
                    ,cdorigem_atualizacao
                    ,dhultima_atualizacao
                    ,cdusuario_ultima_atualizacao)
              values(2 /* Em manutenção*/
                    ,2 /* Manual */
                    ,sysdate
                    ,'PROCESSO DE LIBERACAO');
  
  commit;
  
end;  
