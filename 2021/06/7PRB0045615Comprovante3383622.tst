declare
  v_erro   varchar2(2000);
begin

	SICR0003.pc_retorno_api_bancoob(
		3383622
		,1
		,''
		,'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDExLzA2LzIwMjEgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjE4OjU2ICAgCiAgICAgICAgICAgIERFIFBBR0FNRU5UTyBERSBDT05WRU5JTyAgICAgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCiAgICAgIENPT1A6IDMyNjUgICAtICAgUEFDOiA4IC0gQUNSRURJQ09PUCAgICAgIAogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKTi4gREEgVFJBTlNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uMDAwMDAzMzgzNjIyCkNPTlZFTklPOi4uLi4uLi4uLi4uLi4uLi4uLi5HUFMgQ8OTRElHTyBERSBCQVJSQVMKQ09ESUdPIERFIEJBUlJBUzoKODU4MjAwMDAwMjIgMjk5NDAyNzAyMDAgMzI5NDc0NTE1MDAgMDEwNTIwMjEwNTcgCk5TVTouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjIxMTYyMDA2OTc2NgpEQVRBIERPIFBBR0FNRU5UTzouLi4uLi4uLi4uLi4uLi4uLi4uLjExLzA2LzIwMjEKVkFMT1IgRE9DVU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjIuMjI5LDk0ClZBTE9SIEpVUk9TOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMCwwMApWQUxPUiBNVUxUQTouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAsMDAKVkFMT1IgREVTQ09OVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wLDAwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4yLjIyOSw5NAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCgpBVVRFTlRJQ0FDQU86CkEyMUY1RTNCLTJBMzctNDkwQS1BRjEyLUI2Q0E0NzI1N0Y5MQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KCiAgICAgICAgIE9VVklET1JJQSBCQU5DT09COiAwODAwNjQ2NDAwMSAgICAgICAgIAotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ=='
		,211620069766
		,v_erro
	);

	commit;

exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20003, v_erro);
end;
