/* 
Solicitação: INC0014961
Objetivo   : Inserir os municípios de abrangência (tabela tbgen_cid_atuacao_coop) da cooperativa CREDIFIESC.
             Atualmente essa cooperativa não possui nenhum município na tabela supracitada. Há uma falha na tela CADCOP
             opção "M" que não está permitindo inserir municípios quando não há nenhum inserido para a cooperativa. 
Autor      : Edmar
*/

INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8105 /* FLORIANOPOLIS */           , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8327 /* SAO JOSE */                , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8233 /* PALHOÇA */                 , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8045 /* BIGUAÇU */                 , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8309 /* SANTO AMARO DA IMPERATRIZ*/, NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8111 /* GOVERNADOR CELSO RAMOS*/   , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8023 /* ANTONIO CARLOS*/           , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 8011 /* AGUAS MORNAS*/             , NULL);
INSERT INTO tbgen_cid_atuacao_coop VALUES (6 /*CREDIFIESC */, 944  /* SAO PEDRO DE ALCANTRA*/    , NULL);
COMMIT;