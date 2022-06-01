begin

update cecred.craplem lem set lem.cdagenci = 9, lem.NRDOLOTE = 600013
where lem.cdcooper = 5
and lem.nrdconta = 302694
and lem.nrctremp = 56507
and lem.dtmvtolt = to_date('31/05/2022','DD/MM/YYYY')
and lem.vllanmto = 907.14;

update cecred.craplem lem set lem.cdagenci = 1, lem.NRDOLOTE = 600013
where lem.cdcooper = 14
and lem.nrdconta = 160296
and lem.nrctremp = 39477
and lem.dtmvtolt = to_date('31/05/2022','DD/MM/YYYY')
and lem.vllanmto = 96.66;

commit;
end;
