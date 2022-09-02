BEGIN

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,119
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,120
    ,sysdate
  );

  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,121
    ,sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,122
    ,sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
          iditem_menu_multcontas
         ,cditem_menu
         ,dhcadastro
  ) VALUES (
    (select NVL(max(iditem_menu_multcontas),0) from INTERNETBANKING.tbib_itens_menu_multcontas)+1
    ,123
    ,sysdate
  );
  

  commit;
end;
