begin

delete cecred.crapsol s where s.dtrefere = to_date('13/09/2022','DD/MM/YYYY');

commit;
end;
