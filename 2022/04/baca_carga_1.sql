begin
update tbepr_carga_pre_aprv t
set t.indsituacao_carga = 2
where t.idcarga in (16821);
commit;
end;
