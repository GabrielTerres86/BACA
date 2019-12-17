----  inclusao do valor minimo para solicitar deposito identificado SAQUE E PAGUE na tab CRAPPRM
INSERT INTO crapprm( nmsistem
                   , cdcooper
                   , cdacesso
                   , dstexprm
                   , dsvlrprm )
             VALUES( 'CRED'
                   , 0
                   , 'SAQUE_PAGUE_VALOR_SAQUE'
                   , 'Saque e Pague - Valor minimo para solicitar deposito identificado'
                   , '10000');

COMMIT;