BEGIN
    INSERT INTO cecred.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
    ('CRED',
    0,
    'ATIVO_VALIDA_INSS_RL',
    'Indica se o serviço de validação com base na macica INSS está ativo, impedindo creditos de RL ou Titular com divergencia de CPFs.',
    'S');

    INSERT INTO cecred.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
    ('CRED',
    0,
    'HOST_API_INSS_RL',
    'Host para buscar dados no Sicredi para funcionalidades Representante Legal.',
    'https://conveniosapi.prod.app.ailos.coop.br');

    INSERT INTO cecred.crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
    ('CRED',
    0,
    'URL_API_INSS_GET_NB_RL',
    'URL para consultar dados de NB no Sicredi para os casos de créditos recebidos que não foram informados na maciça.',
    '/v1/beneficiarios/validacoes/inativos');

    COMMIT;
END;