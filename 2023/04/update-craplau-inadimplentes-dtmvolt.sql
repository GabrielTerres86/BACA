begin

	update cecred.craplau l
	   set l.dtmvtolt = to_date('29/10/2022','dd/mm/yyyy')
	 where l.cdseqtel in ('202300387522','202300387518','202301012871');
	 
	update cecred.craplau l
	   set l.dtmvtolt = to_date('30/10/2022','dd/mm/yyyy')
	 where l.cdseqtel in ('202300387520');
	 
	 commit;
	 
end;