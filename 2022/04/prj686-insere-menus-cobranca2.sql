BEGIN

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,101
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,109
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,104
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,105
    ,sysdate
  );
  commit;
end;
