declare
  v_erro   varchar2(2000);
begin

	SICR0003.pc_retorno_api_bancoob(
		3384265
		,1
		,''
		,'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDExLzA2LzIwMjEgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjE4OjI2ICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4OTAwMDAwNjEgMzc3NDAzMjgyMTMKICAgICAgICAgICAgICAgICAgICAgICAgIDI2MDcyMDIxMTYyIDM0MTQzNDAxMDQ0CgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4xMS8wNi8yMDIxClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi42LjEzNyw3NAotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAxMTA2MjEgMDU4IDAwMDAuLi4uNi4xMzcsNzQgMDUwMQoNQ0k6NDQyMDEzICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg0zRTdCMDc0Mi1DMzIyLTRGQTMtODZBNy00QTNGMDBCMTU1RUUKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0='
		,211620129055
		,v_erro
	);

	commit;

exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20003, v_erro);
end;
