declare
  v_erro   varchar2(2000);
begin

	SICR0003.pc_retorno_api_bancoob(
		3538135
		,1
		,''
		,'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDE1LzA3LzIwMjEgLSAyIFZJQSBDT01QUk9WQU5URSAtIDA5OjM0OjU3ICAgCiAgICAgICAgICAgIERFIFBBR0FNRU5UTyBERSBDT05WRU5JTyAgICAgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCiAgICAgICAgQ09PUDogNDQ2OCAgIC0gICBQQUM6IDggLSBFVk9MVUEgICAgICAgIAogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKTi4gREEgVFJBTlNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uMDAwMDAzNTM4MTM1CkNPTlZFTklPOi4uLi4uLi4uLi4uLi4uLi4uLi5HUFMgQ8OTRElHTyBERSBCQVJSQVMKQ09ESUdPIERFIEJBUlJBUzoKODU4MjAwMDAwMDEgMjEwMDAyNzAxNDcgMzAwMDIwOTQ5ODUgNzQyOTIwMjEwNjMgCk5TVTouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjIxMTk1MDI5NDczMQpEQVRBIERPIFBBR0FNRU5UTzouLi4uLi4uLi4uLi4uLi4uLi4uLjE0LzA3LzIwMjEKVkFMT1IgRE9DVU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMTIxLDAwClZBTE9SIEpVUk9TOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMCwwMApWQUxPUiBNVUxUQTouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAsMDAKVkFMT1IgREVTQ09OVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wLDAwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjEyMSwwMAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCgpBVVRFTlRJQ0FDQU86Cjg2N0EzNkRGLUM0NDQtNDU5Mi05MkI4LUZCNTRGQkFDRTRDRgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KCiAgICAgICAgIE9VVklET1JJQSBCQU5DT09COiAwODAwNjQ2NDAwMSAgICAgICAgIAotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ=='
		,211950294731
		,v_erro
	);

	commit;

exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20003, v_erro);
end;
