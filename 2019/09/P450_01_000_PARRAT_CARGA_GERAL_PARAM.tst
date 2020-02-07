PL/SQL Developer Test script 3.0
56
begin
  for reg in (
              
              SELECT cdcooper, PRODUTO, PFISICAJURIDICA
                FROM crapcop,
                      (SELECT 1 PFISICAJURIDICA      FROM DUAL  UNION
                       SELECT 2 PFISICAJURIDICA      FROM DUAL) PESSOA,
                      (SELECT 90 PRODUTO             FROM DUAL  UNION
                       SELECT 1 PRODUTO              FROM DUAL  UNION
                       SELECT 2 PRODUTO              FROM DUAL  UNION
                       SELECT 3 PRODUTO              FROM DUAL  ) PROD
               WHERE flgativo = 1         
               Order by 1, 3, 2) loop
    
    begin 
    insert into cecred.TBRAT_PARAM_GERAL
      (CDCOOPER,
       INPESSOA,
       TPPRODUTO,
       QTDIAS_NIVEIS_REDUCAO,
       IDNIVEL_RISCO_PERMITE_REDUCAO,
       QTDIAS_ATENCEDE_ATUALIZACAO,
       QTDIAS_REAPROVEITAMENTO,
       QTMESES_EXPIRACAO_NOTA,
       QTDIAS_ATUALIZACAO_AUTOM_BAIXO,
       QTDIAS_ATUALIZACAO_AUTOM_MEDIO,
       QTDIAS_ATUALIZACAO_AUTOM_ALTO,
       QTDIAS_ATUALIZACAO_MANUAL,
       INCONTINGENCIA,
       INPERMITE_ALTERAR)
    values
      (reg.cdcooper,
       reg.PFISICAJURIDICA,
       reg.PRODUTO,
       0,
       'B,C,D,',
       15,
       15,
       6,
       30,
       30,
       30,
       15,
       0,
       0);
    dbms_output.put_line('Inseriu : coop: '||
                         reg.cdcooper || ' Tipo Pessoa ' ||
                         reg.PFISICAJURIDICA || ' Produto ' || reg.PRODUTO);
  EXCEPTION 
   WHEN dup_val_on_index THEN
        NULL;
    end;
  end loop ;
  
  commit;
end;
0
0
