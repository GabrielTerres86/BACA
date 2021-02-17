ALTER TABLE crapffm ADD vltotpixcob NUMERIC(25,2) DEFAULT 0 NOT NULL;
COMMENT ON COLUMN crapffm.vltotpixcob IS 'Valor total das movimentacoes do PIX Cobrança';

ALTER TABLE crapffm ADD vldevpixcob NUMERIC(25,2) DEFAULT 0 NOT NULL;
COMMENT ON COLUMN crapffm.vldevpixcob IS 'Valor total das movimentacoes de devolucoes do PIX Cobrança';

INSERT INTO tbfin_remessa_fluxo_caixa (cdremessa, nmremessa, cdoperador, dtalteracao, tpfluxo_entrada, tpfluxo_saida, flremessa_dinamica)
VALUES(25, 'PIX COB', 1, SYSDATE, 1, 2, 1);

INSERT INTO tbfin_remessa_fluxo_caixa (cdremessa, nmremessa, cdoperador, dtalteracao, tpfluxo_entrada, tpfluxo_saida, flremessa_dinamica)
VALUES(26, 'DEV PIX COB', 1, SYSDATE, 1, 2, 1);

COMMIT;
