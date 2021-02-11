-- Created on 11/02/2021 by T0032717 
BEGIN
  DECLARE
    -- nome da rotina
    wk_rotina varchar2(200) := 'Criação dos parâmetros da Renegociação Facilitada para Canais (tabela crapprm)';
    CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop cop
     WHERE cop.flgativo = 1;
  BEGIN
    -- Percorrer as cooperativas do cursor
    FOR rw_crapcop IN cr_crapcop LOOP
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_DIASMINPARC_RENCAN', 'Dias para data minima da primeira parcela', '3');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'QT_DIASMAXPARC_RENCAN', 'Dias para data maxima da primeira parcela', '30');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_LINHAPP_RENCAN', 'Linha de credito padrao para pp', '0');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_LINHAPOS_RENCAN', 'Linha de credito padrao para pos', '0');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_FINALI_RENCAN', 'Finalidade pdrao para renegociacoes por canais', '0');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'ID_CARENCIAPOS_RENCAN', 'Carência Pós', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'TP_CONVERSAOTR_RENCAN', 'Padrão para contratos TR/CC', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_FINANCIAIOF_RENCAN', 'Financiar Tarifa/IOF', '1');
      INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) values ('CRED', rw_crapcop.cdcooper, 'CD_CANCLIMITE_RENCAN', 'Cancelar Limite de Crédito', '1');
    END LOOP;

    UPDATE crapaca SET lstparam = lstparam || ',pr_qtdiamin,pr_qtdiamax,pr_cdlcrcpp,pr_cdlcrpos,pr_cdfincan,pr_idcarenc,pr_tptrrene,pr_flgfinta,pr_flglimcr' WHERE nmdeacao = 'TAB089_ALTERAR';

    COMMIT;
    dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: ' || wk_rotina ||' --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
    ROLLBACK;
  END;
END;