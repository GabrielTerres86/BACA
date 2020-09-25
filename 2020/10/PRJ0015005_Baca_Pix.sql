begin 
  -- Produto PIX
  insert into tbcc_produto (cdproduto
                         ,dsproduto
                         ,flgitem_soa
                         ,flgutiliza_interface_padrao
                         ,flgenvia_sms
                         ,flgcobra_tarifa
                         ,idfaixa_valor
                         ,flgproduto_api)
                   values(49
                         ,'Pix - PAGAMENTOS INSTANTANEOS'
                         ,0
                         ,1
                         ,0
                         ,0
                         ,0
                         ,1);

  -- Permitir durante Batch 
  update craptel 
     set craptel.inacesso = 2
   where craptel.nmdatela IN('EXTRAT','TAB085','CADFRA','FLUXOS','CADTEL');
     
  -- Nova opção TAB085 + Permiter durante Batch    
  update craptel tel
     set inacesso = 2
        ,cdopptel = cdopptel||',P'
        ,lsopptel = lsopptel||',PARAMETROS PIX'
   where nmdatela = 'TAB085';

  -- Criação dos acessos de novas telas
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop) LOOP 
    -- CADPIX 
    insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    values ('CADPIX', 5, '@,C,D,E,X,S,I', 'Consulta e Gerenciamento de Chaves PIX', 'Controle de Chaves PIX', 0, 1, ' ', 'ACESSO,CONSULTA,DETALHAMENTO DE CHAVE,EXCLUSAO DE CHAVE,EXCLUSAO DE REIVINDICACAO,SALVAR COMO CSV,INCLUSAO MANUAL', 2, rw_crapcop.cdcooper, 1, 0, 0, 0, ' ', 0);
    insert into CRAPPRG (nmsistem,cdprogra,dsprogra##1,dsprogra##2,dsprogra##3,dsprogra##4,nrsolici,nrordprg,inctrprg,cdrelato##1,cdrelato##2,cdrelato##3,cdrelato##4,cdrelato##5,inlibprg,cdcooper)
    values ('CRED','CADPIX', 'Consulta e Gerenciamento de Chaves PIX',NULL,NULL,NULL,990,999,1,0,0,0,0,0,0,RW_CRAPCOP.CDCOOPER);
  END LOOP;
  
  -- Opções de Menu Mobile 
  INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
    VALUES (1009,30,'PIX',1,0,1,'2.11.0.0',NULL);
  INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
    VALUES (1010,1009,'Cadastramento de chaves',1,0,1,'2.11.0.0',NULL);
  INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
    VALUES (1011,1009,'Pagamento Pix',1,0,1,'2.12.0.0',NULL);
  INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
    VALUES (1012,1009,'Recebimento Pix',1,0,1,'2.12.0.0',NULL);
  INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
    VALUES (1013,1009,'Sobre o Pix',1,0,1,'2.11.0.0',NULL);
  INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
    VALUES (1014,1009,'Devolucao Pix',1,0,1,'2.12.0.0',NULL);

  commit;
  
end;  
