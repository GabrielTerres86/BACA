BEGIN
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    137,
    sysdate
  );
  
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    138,
    sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    139,
    sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    140,
    sysdate
  );
  
  commit;
END;
