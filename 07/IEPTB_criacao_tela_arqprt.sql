BEGIN
    --TEL
    insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
    values ('ARQPRT', 10, '@', 'INFORMAÇÕES DO LOG DE ARQUIVOS IEPTB', 'ARQ. PRT.', 0, 1, ' ', 'ACESSO', 1, 3, 1, 0, 1, 1, ' ', 2);

    --RDR
    insert into craprdr (NMPROGRA, DTSOLICI)
    values ('TELA_ARQPRT', SYSDATE);

    --PRG
    insert into CRAPPRG (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
    values ('CRED', 'ARQPRT', 'INFORMAÇÕES DO LOG DE ARQUIVOS IEPTB', ' ', ' ', ' ', 50, 10001, 1, 0, 0, 0, 0, 0, 1, 3, null);
    commit;
    
    --ACA
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('BUSCA_LISTA_LOG', 'TELA_ARQPRT', 'pc_buscar_lista_log', 'pr_dtgeracao_ini,pr_dtgeracao_fim,pr_tipo_arquivo,pr_pagina,pr_tamanho_pagina', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'TELA_ARQPRT'));

    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('BUSCA_ITEM_LOG', 'TELA_ARQPRT', 'pc_buscar_item_log', 'pr_cdidlog,pr_pagina_detalhe,pr_tamanho_pagina_detalhe', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'TELA_ARQPRT'));

    COMMIT;
END;