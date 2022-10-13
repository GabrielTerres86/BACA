begin
  update cecred.crapsqu set cecred.crapsqu.nrseqatu = 234
  where upper(cecred.crapsqu.nmtabela) = 'GNCONVE' and upper(cecred.crapsqu.nmdcampo) = 'NRSEQCXA' and cecred.crapsqu.dsdchave = 'FGTS';
  commit;
end;
