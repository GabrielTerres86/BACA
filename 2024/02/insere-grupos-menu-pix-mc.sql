BEGIN
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    82,
    sysdate
  );
  
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    83,
    sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    84,
    sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    90,
    sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    136,
    sysdate
  );
  
  INSERT INTO INTERNETBANKING.tbib_itens_menu_multcontas (
    IDITEM_MENU_MULTCONTAS,
    CDITEM_MENU,
    DHCADASTRO
  ) VALUES (
    (SELECT max(IDITEM_MENU_MULTCONTAS) + 1 FROM tbib_itens_menu_multcontas),
    87,
    sysdate
  );
  
  commit;
END;
