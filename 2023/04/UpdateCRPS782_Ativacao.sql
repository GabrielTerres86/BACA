begin

update  cecred.tbgen_batch_param
set qtparalelo =20
WHERE cdcooper = 1
AND cdprograma = 'CRPS782';

commit;

end;
