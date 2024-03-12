BEGIN
    UPDATE cecred.parametromobile SET descricao = 'Quantidade limite de avaliação diária no app' WHERE parametromobileid = 55;
    UPDATE cecred.parametromobile SET descricao = 'Quantidade limite de avaliação mensal no app' WHERE parametromobileid = 56;
    UPDATE cecred.parametromobile SET descricao = 'Intervalo em dias entre uma avaliação de um cooperado e outro' WHERE parametromobileid = 57;
    UPDATE cecred.parametromobile SET descricao = 'Flag que determina se o fluxo de avaliação inapp está disponivel' WHERE parametromobileid = 58;
    UPDATE cecred.parametromobile SET descricao = 'Texto retornado em caso de atualização no Android', valor = '<p>Há uma nova versão do aplicativo disponível, atualize o app para continuar aproveitando o melhor dos nossos serviços</p>' WHERE parametromobileid = 59;
    UPDATE cecred.parametromobile SET descricao = 'Texto retornado em caso de atualização no iOS', valor = '<p>Há uma nova versão do aplicativo disponível, atualize o app para continuar aproveitando o melhor dos nossos serviços</p>' WHERE parametromobileid = 60;
    COMMIT;
END;