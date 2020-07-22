--inc0034467 update para cancelar apólice lançada em duplicidade (Carlos)
UPDATE tbseg_contratos c SET c.indsituacao = 'E', c.dtcancela = '21/06/2019', c.flgvigente = 0 WHERE c.idcontrato = 60676;
COMMIT;
