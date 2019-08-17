-- baca para atualizar o nome dos seguintes cartorios abaixo
begin
  UPDATE tbcobran_cartorio_protesto SET nmcartorio = 'OFICIO UNICO DE CANTAGALO' WHERE idcartorio = 2185;
  UPDATE tbcobran_cartorio_protesto SET nmcartorio = '1 TABELIONATO BOCAIUVA' WHERE idcartorio = 3104;
  
  commit;
end;