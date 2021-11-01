declare
  cursor cr_crapcop is select cdcooper from crapcop where flgativo = 1 order by cdcooper;
  vr_nrseqrdr craprdr.nrseqrdr%type;
  vr_nmdatela varchar2(20) := 'PROACO';
  vr_cddopcao varchar2(5) := 'A';
  vr_nrmodulo number := 3;
begin
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('SITUACAO_ACORDO', '1', 'Ativo');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('SITUACAO_ACORDO', '2', 'Quitado');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('SITUACAO_ACORDO', '3', 'Cancelado');
  
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('TIPO_MODELO_ACORDO', '1', 'Simples');
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('TIPO_MODELO_ACORDO', '2', 'Reformulado');
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('TIPO_MODELO_ACORDO', '3', 'Renegociação');
  
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('SITUACAO_PROC_ACORDO', '2', 'Aguardando Renegociacao');
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('SITUACAO_PROC_ACORDO', '3', 'Em Processamento Renegociacao');
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('SITUACAO_PROC_ACORDO', '4', 'Processado Renegociacao');
  insert into recuperacao.tbrecup_dominio_campo (nmdominio, cddominio, dscodigo) values('SITUACAO_PROC_ACORDO', '5', 'Erro Processamento');

  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('CDORIGEM_CONTRATO', '1', 'Estouro de Conta');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('CDORIGEM_CONTRATO', '2', 'Empréstimo');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('CDORIGEM_CONTRATO', '3', 'Empréstimo');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('CDORIGEM_CONTRATO', '4', 'Desconto de Título');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('CDORIGEM_CONTRATO', '5', 'Fatura Cartão');
  insert into recuperacao.tbrecup_dominio_campo(nmdominio, cddominio, dscodigo) values('CDORIGEM_CONTRATO', '6', 'Tarifa');

  insert into craprdr(nmprogra,dtsolici) values('TELA_PROACO',sysdate) returning nrseqrdr into vr_nrseqrdr;
  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) values('PROACO_OBTER_ACORDOS', 'TELA_PROACO', 'ObterAcordos', 'pr_nracordo, pr_nrdconta', vr_nrseqrdr);
  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) values('PROACO_OBTER_LOG_ACORDO', 'TELA_PROACO', 'ObterLogProcessAcordo', 'pr_nracordo, pr_nrcontrato, pr_cdorigem', vr_nrseqrdr);
  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) values('PROACO_OBTER_CTRACORDO', 'TELA_PROACO', 'ObterContratosAcordo', 'pr_nracordo', vr_nrseqrdr);

  for rw_crapcop in cr_crapcop loop

    insert into crapprg(nmsistem, cdprogra, dsprogra##1, dsprogra##2, dsprogra##3, dsprogra##4, nrsolici, nrordprg, inctrprg, cdrelato##1, cdrelato##2, cdrelato##3, cdrelato##4, cdrelato##5, inlibprg, cdcooper, qtminmed)
    values ('CRED', vr_nmdatela, 'Processamento Acordo', ' ', ' ', ' ', 50, (select max(nrordprg)+1 from crapprg where cdcooper = rw_crapcop.cdcooper), 1, 0, 0, 0, 0, 0, 1, rw_crapcop.cdcooper, null);

    insert into craptel(nmdatela, nrmodulo, cdopptel, tldatela, tlrestel, flgteldf, flgtelbl, nmrotina, lsopptel, inacesso, cdcooper, idsistem, idevento, nrordrot, nrdnivel, nmrotpai, idambtel)
    values (vr_nmdatela, vr_nrmodulo, vr_cddopcao, 'Processamento Acordo', 'Proc. Acordo', 0, 1, ' ', 'Acompanhar processamento Acordo', 1, rw_crapcop.cdcooper, 1, 0, 1, 1, ' ', 2);

    insert into crapace
    (nmdatela
    ,cddopcao
    ,cdoperad
    ,nmrotina
    ,cdcooper
    ,nrmodulo
    ,idevento
    ,idambace)
    select vr_nmdatela as nmdatela
          ,vr_cddopcao as cddopcao
          ,ope.cdoperad as cdoperad
          ,' ' as nmrotina
          ,ope.cdcooper as cdcooper
          ,vr_nrmodulo as nrmodulo
          ,0 as idevento
          ,2 as idambace
      from crapope ope
     where ope.cdcooper = rw_crapcop.cdcooper     
       AND ope.cdsitope = 1
       AND ope.flgdonet = 1
       and lower(ope.dsdemail) in ('juliana.ottersbach@ailos.coop.br',
                                   'beatriz.weege@ailos.coop.br',
                                   'juliana@ailos.coop.br',
                                   'sandro.kistner@ailos.coop.br',
                                   'rene.santos@ailos.coop.br',
                                   'heloiza.silva@ailos.coop.br',
                                   'karine.kupas@ailos.coop.br',
                                   'ligia.pickler@ailos.coop.br')
       and not exists (select 1
              from crapace x
             where x.cdcooper = ope.cdcooper
               and upper(x.cdoperad) = upper(ope.cdoperad)
               and upper(x.nmdatela) = upper(vr_nmdatela)
               and x.cddopcao = vr_cddopcao
               and upper(x.nrmodulo) = upper(vr_nrmodulo));

  end loop;

  COMMIT;

END;
