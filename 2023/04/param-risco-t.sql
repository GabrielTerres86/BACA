DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper FROM cecred.crapcop WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    UPDATE cecred.crapprm
       SET dsvlrprm = dsvlrprm || ';0'
     WHERE cdcooper = rw_crapcop.cdcooper
       AND UPPER(nmsistem) = 'CRED' 
       AND UPPER(cdacesso) = 'RISCO_CARTAO_BACEN';
  END LOOP;
  COMMIT;

  INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (1,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (2,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (3,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (5,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (6,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (7,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (8,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (9,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (10,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (11,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (12,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (13,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (14,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (16,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 97, 0);
COMMIT;

INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (1,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (2,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (3,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (5,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (6,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (7,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (8,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (9,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (10,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (11,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (12,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (13,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (14,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
INSERT INTO gestaoderisco.tbrisco_central_carga (cdcooper, dtrefere, dhinicar_aimaro, dhfimcar_aimaro, cdstatus, tpproduto, qtoperacoes) VALUES (16,to_date('23/05/2023', 'dd/mm/yyyy'), sysdate, sysdate, 2, 98, 0);
COMMIT;

END;
