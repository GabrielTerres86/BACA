/* 
Solicita��o: INC0014961
Objetivo   : Inserir os munic�pios de abrang�ncia (tabela tbgen_cid_atuacao_coop) da cooperativa CREDIFIESC.
             Atualmente essa cooperativa n�o possui nenhum munic�pio na tabela supracitada. H� uma falha na tela CADCOP
             op��o "M" que n�o est� permitindo inserir munic�pios quando n�o h� nenhum inserido para a cooperativa. 
Autor      : Edmar
*/

INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8105 /* FLORIANOPOLIS */           , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8327 /* SAO JOSE */                , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8233 /* PALHO�A */                 , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8045 /* BIGUA�U */                 , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8309 /* SANTO AMARO DA IMPERATRIZ*/, NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8111 /* GOVERNADOR CELSO RAMOS*/   , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8023 /* ANTONIO CARLOS*/           , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8011 /* AGUAS MORNAS*/             , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 944  /* SAO PEDRO DE ALCANTRA*/    , NULL);
COMMIT;