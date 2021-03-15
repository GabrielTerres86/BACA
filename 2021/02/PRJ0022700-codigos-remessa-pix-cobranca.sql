BEGIN

INSERT INTO tbfin_remessa_fluxo_caixa (cdremessa, nmremessa, cdoperador, dtalteracao, tpfluxo_entrada, tpfluxo_saida, flremessa_dinamica)
VALUES(25, 'PIX COB', 1, SYSDATE, 1, 2, 1);

INSERT INTO tbfin_remessa_fluxo_caixa (cdremessa, nmremessa, cdoperador, dtalteracao, tpfluxo_entrada, tpfluxo_saida, flremessa_dinamica)
VALUES(26, 'DEV PIX COB', 1, SYSDATE, 1, 2, 1);

COMMIT;

EXCEPTION 
  WHEN OTHERS THEN
    sistema.excecaointerna(pr_compleme => 'PRJ0022700: Não foi possível inserir códigos de remessa pix cobrança');

END;
