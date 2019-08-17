ALTER TABLE CECRED.TBDOMIC_LIQTRANS_PDV ADD tppontovenda VARCHAR2(2);
comment on column CECRED.TBDOMIC_LIQTRANS_PDV.tppontovenda is 'Tipo de ponto de venda <TpPontoVenda>';
ALTER TABLE CECRED.TBDOMIC_LIQTRANS_PDV ADD tpvlpagamento VARCHAR2(2);
comment on column CECRED.TBDOMIC_LIQTRANS_PDV.tpvlpagamento is 'Tipo do valor de pagamento <TpVlrPgto>';