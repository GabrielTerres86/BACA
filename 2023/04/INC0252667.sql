BEGIN
    UPDATE cecred.parametromobile
    SET valor = 'https://conteudo.cecred.coop.br/imagens/notificacoes/banners/'
    WHERE parametromobileid = 46
      AND nome = 'UrlImagensBannersNotificacao';
    COMMIT;
END;