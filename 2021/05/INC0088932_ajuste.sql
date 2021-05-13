BEGIN 
       UPDATE TBCC_LANCAMENTOS_PENDENTES
       SET    IDSITUACAO = 'M',
              DSCRITICA =  'INC0088932 - Ajustado manualmente, Contas se encontravam em Prejuizo.'
       WHERE  IDTRANSACAO IN (9503921)
       AND    IDSITUACAO = 'E';
COMMIT;
END;