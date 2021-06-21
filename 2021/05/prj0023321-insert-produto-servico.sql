begin
 INSERT INTO tbapi_produto_servico (
        idservico_api,
        cdproduto,
        dsservico_api,
        idapi_cooperado,
        dspermissao_api
    ) VALUES (
        3,
        53,
        'API PIX',
        1,
        'api-ailos-cobranca-pix'
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            sistema.excecaointerna(pr_compleme => 'prj0023321');
            ROLLBACK;
        END;
END;