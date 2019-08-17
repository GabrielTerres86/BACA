declare
  vr_nrseqrdr number;
BEGIN

  UPDATE tbgen_motivo mot
   SET mot.dsmotivo = 'Conjuge com Operacoes em Atraso teste (Valor de Operacoes)'
  WHERE mot.idmotivo = 54;
  
  INSERT INTO tbgen_motivo(IDMOTIVO, DSMOTIVO, CDPRODUTO, FLGRESERVA_SISTEMA) VALUES(69, 'Eliminado via carga manual.', 25, 1);
  INSERT INTO tbgen_motivo(IDMOTIVO, DSMOTIVO, CDPRODUTO, FLGRESERVA_SISTEMA) VALUES(72, 'Solicitado via Aimaro pelo operador.', 4, 1);
  INSERT INTO tbgen_motivo(IDMOTIVO, DSMOTIVO, CDPRODUTO, FLGRESERVA_SISTEMA) VALUES(73, 'Situação da conta regularizada.', 25,1);
  INSERT INTO tbgen_motivo(IDMOTIVO, DSMOTIVO, CDPRODUTO, FLGRESERVA_SISTEMA) VALUES(74, 'Reliberado pois prazo de bloqueio expirou.', 25, 1);
  INSERT INTO tbgen_motivo(IDMOTIVO, DSMOTIVO, CDPRODUTO, FLGRESERVA_SISTEMA) VALUES(75, 'Titular cadastrado na CADCYB', 25, 1);
  INSERT INTO tbgen_motivo(IDMOTIVO, DSMOTIVO, CDPRODUTO, FLGRESERVA_SISTEMA) VALUES(76, 'Titular cadastrado na BLQJUD', 25, 1);
  


  INSERT INTO craptel (nmdatela,nrmodulo,cdopptel,flgteldf,flgtelbl,nmrotina,lsopptel,inacesso,cdcooper,idsistem,idevento,nrordrot,nrdnivel,idambtel)
               VALUES ('CADMOT',5,'@,A,I',0,1,' ','ACESSO,ALTERAR,INCLUIR',2,3,1,0,2,1,2);
  
  insert into CRApprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'CADMOT', 'Cadastro de Motivos', ' ', ' ', ' ', 995, 500, 1, 0, 0, 0, 0, 0, 1, 3, null);
  
  INSERT INTO craprdr(nmprogra,dtsolici)
               VALUES('CADMOT',SYSDATE)
           RETURNING nrseqrdr INTO vr_nrseqrdr;  
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'LISTA_MOTIVOS','TELA_CADMOT','pc_lista_motivos','pr_nrregist,pr_nriniseq');
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'LISTA_COMOBO_PRODUTOS','TELA_CADMOT','pc_lista_produtos','');
  
  INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
               VALUES(vr_nrseqrdr, 'MANTEM_MOTIVO','TELA_CADMOT','pc_mantem_motivo','pr_idmotivo,pr_dsmotivo,pr_cdproduto,pr_flgreserva_sistema,pr_flgativo');
               
  commit;
end;
