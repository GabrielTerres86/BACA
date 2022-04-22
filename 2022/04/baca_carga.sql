begin
update tbepr_carga_pre_aprv t
set t.indsituacao_carga = 2
where t.idcarga in (16815,16814,16816);
commit;
end;
