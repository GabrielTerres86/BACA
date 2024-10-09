begin
  
update cecred.tbconv_liberacao l
  set l.flgautdb = 1
where  l.cdcooper = 3
  and  l.cdconven = 142
  and  l.idseqconvelib = 5839;
commit;  

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 212, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 213, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 229, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 246, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 247, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 248, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 249, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 253, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 254, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 255, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 258, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 259, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 260, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 261, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 262, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 263, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 265, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 268, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 271, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 272, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 273, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 274, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 276, 1);

insert into cecred.tbconv_liberacao (TPARRECADACAO, CDCOOPER, CDEMPRES, CDCONVEN, FLGAUTDB)
values (3, 3, '0', 278, 1);

commit;
end;
