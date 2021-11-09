begin
update crapprm c set c.dsvlrprm = 'N' where cdacesso = 'UTILIZA_REGRAS_SEGPRE';
commit;
end;