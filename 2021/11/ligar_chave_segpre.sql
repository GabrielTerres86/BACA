begin
update crapprm c set c.dsvlrprm = 'S' where cdacesso = 'UTILIZA_REGRAS_SEGPRE';
commit;
end;