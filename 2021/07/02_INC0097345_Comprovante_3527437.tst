declare
  v_erro   varchar2(2000);
begin

	SICR0003.pc_retorno_api_bancoob(
		3527437
		,1
		,''
		,'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDEzLzA3LzIwMjEgLSAyIFZJQSBDT01QUk9WQU5URSAtIDEwOjQ2OjI2ICAgCiAgICAgICAgICAgIERFIFBBR0FNRU5UTyBERSBDT05WRU5JTyAgICAgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCiAgICAgIENPT1A6IDMyMzkgICAtICAgUEFDOiA3MyAtIFZJQUNSRURJICAgICAgCiAgICAgIENBTkFMIERFIFBBR0FNRU5UTyBJTlRFUk5FVCBCQU5LSU5HICAgICAgCgpOLiBEQSBUUkFOU0FDQU86Li4uLi4uLi4uLi4uLi4uLi4uLi4wMDAwMDM1Mjc0MzcKQ09OVkVOSU86Li4uLi4uLi4uLi4uLi4uLi4uLkdQUyBDw5NESUdPIERFIEJBUlJBUwpDT0RJR08gREUgQkFSUkFTOgo4NTgzMDAwMDAxMiA2OTczMDI3MDIwMCAzMTcwNjUyMTEwMCAwMTA1MjAyMTA2OSAKTlNVOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMjExOTMwNzc1NDU4CkRBVEEgRE8gUEFHQU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uMTIvMDcvMjAyMQpWQUxPUiBET0NVTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMS4yNjksNzMKVkFMT1IgSlVST1M6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wLDAwClZBTE9SIE1VTFRBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMCwwMApWQUxPUiBERVNDT05UTzouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAsMDAKVkFMT1IgVE9UQUw6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjEuMjY5LDczCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KCkFVVEVOVElDQUNBTzoKNkFDQkEwODctRTFCOC00MjkxLUIyRkUtRkYxM0ZCOEQ1RjVCCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwoKICAgICAgICAgT1VWSURPUklBIEJBTkNPT0I6IDA4MDA2NDY0MDAxICAgICAgICAgCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t'
		,211930775458
		,v_erro
	);

	commit;

exception
  when others then
    v_erro := sqlerrm;
    rollback;
    raise_application_error(-20003, v_erro);
end;
