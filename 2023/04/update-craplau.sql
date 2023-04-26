begin

update cecred.craplau l
  set l.dtmvtolt = to_date('27/10/2022','dd/mm/yyyy')
where l.cdseqtel in ('202300828719','202300387441','202300387476','202300810658','202300959926','202300803915','202300386754','202300826415');

commit;
end;