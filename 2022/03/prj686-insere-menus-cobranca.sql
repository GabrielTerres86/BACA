BEGIN

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,106
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,107
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,108
    ,sysdate
  );

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
