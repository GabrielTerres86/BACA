BEGIN
    INSERT INTO cecred.parametromobile (parametromobileid, nome, descricao,valor, sistema) VALUES (55, 'AvaliacaoLimiteDiario', 'Quantidade limite de avaliação diária no app', '1000', 1);
    INSERT INTO cecred.parametromobile (parametromobileid, nome, descricao,valor, sistema) VALUES (56, 'AvaliacaoLimiteMensal', 'Quantidade limite de avaliação mensal no app', '5000', 1);
    INSERT INTO cecred.parametromobile (parametromobileid, nome, descricao,valor, sistema) VALUES (57, 'AvaliacaoIntervalo', 'Intervalo em dias entre uma avaliação de um cooperado e outro', '365', 1);
    INSERT INTO cecred.parametromobile (parametromobileid, nome, descricao,valor, sistema) VALUES (58, 'AvaliacaoHabilitada', 'Flag que determina se o fluxo de avaliação inapp está disponivel', '1', 1);
    INSERT INTO cecred.parametromobile (parametromobileid, nome, descricao,valor, sistema) VALUES (59, 'TextoAtualizacaoAndroid', 'Texto retornado em caso de atualização no Android', '<p>Há uma nova versão do aplicativo disponível, atualize o app para continuar aproveitando o melhor dos nossos serviços</p>', 1);
    INSERT INTO cecred.parametromobile (parametromobileid, nome, descricao,valor, sistema) VALUES (60, 'TextoAtualizacaoiOS', 'Texto retornado em caso de atualização no iOS', '<p>Há uma nova versão do aplicativo disponível, atualize o app para continuar aproveitando o melhor dos nossos serviços</p>', 1);
    COMMIT;
END;