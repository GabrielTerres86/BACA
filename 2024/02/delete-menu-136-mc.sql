BEGIN
  
  DELETE INTERNETBANKING.tbib_itens_menu_multcontas a where a.cditem_menu = 136;
  commit;
  
END;
