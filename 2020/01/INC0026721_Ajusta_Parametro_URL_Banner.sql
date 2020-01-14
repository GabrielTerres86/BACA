/*
INC0026721 - Atualizar parâmetro de URL para carregamento de imagens de banner na Conta Online e app Mobile
Edmar Soares de Oliveira - 14/01/2020
*/

UPDATE TBGEN_BANNER_PARAM P
SET P.DSURLSERVER = 'https://conteudo.cecred.coop.br/imagens/banners/ibank/ '
WHERE P.CDCANAL = 3; -- Conta Online

UPDATE TBGEN_BANNER_PARAM P
SET P.DSURLSERVER = 'https://conteudo.cecred.coop.br/imagens/banners/mobile/'
WHERE P.CDCANAL = 10; -- Mobile

COMMIT;