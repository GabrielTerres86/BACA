declare
--
vr_limite_tituloleg number(20);
vr_limite_opleg number(20);
vr_number number(20);
--
begin
--
select max(to_number("IdTituloLeg")), max(to_number("IdOpLeg")) into vr_limite_tituloleg, vr_limite_opleg
from tbjdnpcdstleg_jd2lg_optit@jdnpcbisql
where "CdLeg" = 'LEG'
and "ISPBAdministrado" = 5463212;
--
vr_limite_opleg := vr_limite_opleg + 10000;
--
vr_number := 0;
--
loop
--
exit when vr_number > vr_limite_tituloleg;
--
select seqcob_idtitleg.NEXTVAL into vr_number
from dual;
--
end loop;
--
vr_number := 0;
--
loop
--
exit when vr_number > vr_limite_opleg;
--
select seqcob_idopeleg.NEXTVAL into vr_number
from dual;
--
end loop;
--
end;
