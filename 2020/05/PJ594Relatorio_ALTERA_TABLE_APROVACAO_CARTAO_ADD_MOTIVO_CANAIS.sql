ALTER TABLE tbcrd_aprovacao_cartao
ADD dsmotivo_canais VARCHAR2(100) NULL;

COMMENT ON COLUMN tbcrd_aprovacao_cartao.dsmotivo_canais
IS 'Salva o motivo da nao autorizacao da proposta de cartao enviada aos canais.'
  
COMMIT;