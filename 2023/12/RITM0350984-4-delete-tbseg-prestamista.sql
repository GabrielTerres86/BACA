begin

  delete cecred.tbseg_prestamista where nrproposta in ('770353866737',
													   '770357396352',
													   '770353866699',
													   '770357396310',
													   '770354701766',
													   '770354701758');

commit;
end;


