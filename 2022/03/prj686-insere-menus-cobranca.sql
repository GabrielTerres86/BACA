BEGIN

--Cobrança Bancaria > Pagadores > Cadastrar
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,106
    ,sysdate
  );

--Cobrança Bancaria > Pagadores > Gerenciar Pagadores
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,107
    ,sysdate
  );

--Cobrança Bancaria > Relatorios > Relatorios do Movimento
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,108
    ,sysdate
  );

--Cobrança Bancaria > Relatorios > Relatorios de Beneficiario
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,110
    ,sysdate
  );
  commit;
end;
