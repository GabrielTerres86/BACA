begin
update GED.TBGED_ASSINA_CONF 
set cdtpdoc = 283,
    cdhmac = 'a7a2564970a9fcd558dbad81c6c2301d32303e96278c008fafb9a7a5390e32a3',
    cduuidcof = '31b892dd-b10f-4340-8de7-6f4fa55413b2'
where cdconfig = 1;
commit;
end;