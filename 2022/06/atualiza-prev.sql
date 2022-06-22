begin

              update tbcadast_colaborador t
              set t.flgativo = 'I'
               WHERE t.nrcpfcgc = '02222355940'
               and t.cdcooper = 3
                 AND t.flgativo = 'A';

commit;

end;