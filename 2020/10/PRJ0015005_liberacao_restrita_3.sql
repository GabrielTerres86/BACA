-- Created on 30/09/2020 by E0030208 
declare 
  -- Local variables here
  i integer;
  cursor cr_registros is
  with dados as (select 1 CodCop, 'VIACREDI' NomeCop, 11194014 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11194898 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11195592 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11196165 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11196793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11198141 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11200995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11201029 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11202319 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11203013 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11203340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11204435 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11204559 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11204745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11206330 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11206829 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11209593 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11210656 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11216280 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11217502 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11219343 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11219700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11224746 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11226315 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11226978 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11227575 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11228180 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11228512 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11228580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11229187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11232960 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11233800 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11234709 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11236337 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11238666 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11239581 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11241128 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11241527 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11244119 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11245751 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11245948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11248343 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11249854 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11249862 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11250925 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11251220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11254980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11255854 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11256281 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11256311 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11257199 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11258195 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11259205 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11259590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11262532 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11262850 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11263121 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11263288 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11265370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11265523 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11268280 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11268840 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11270632 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11273585 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11273747 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11273836 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11274000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11274360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11275669 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11277394 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11279397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11279826 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11280808 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11283858 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11284404 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11284471 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11289422 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11295350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11295465 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11298243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11299746 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11300060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11300540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11300817 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11301546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11302372 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11303697 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11309032 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11309725 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11310111 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11310200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11316470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11318350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11318473 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11323701 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11324104 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11324511 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11325100 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11326719 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11326786 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11328096 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11329084 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11329475 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11329793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11332638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11334240 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11334681 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11335637 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11337150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11342684 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11344830 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11347031 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11347775 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11347961 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11348429 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11348615 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11349166 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11351390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11351896 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11354054 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11354860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11355492 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11355514 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11355530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11356766 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11358017 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11358904 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11359137 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11359315 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11360135 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11360828 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11361697 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11362910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11363339 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11363401 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11364319 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11364548 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11365471 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11367741 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11368039 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11368420 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11368829 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11371374 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11372052 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11372150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11372710 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11374004 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11376198 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11376562 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11377364 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11377542 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11377623 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11378506 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11379014 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11379235 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11379456 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11380144 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11380799 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11381477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11382945 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11383151 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11384239 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11385294 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11387378 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11388340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11388455 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11388587 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11389214 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11389559 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11390735 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11391502 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11392126 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11392568 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11396105 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11396687 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11397152 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11397357 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11397373 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11397853 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11399325 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400250 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400404 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400625 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400692 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400730 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400765 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400889 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11400960 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11401524 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11401559 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11401575 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11401664 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11402296 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11402660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11402741 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11402954 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11403292 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11403373 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11404477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11404540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11404892 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11404990 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11405350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11405449 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11405490 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11405775 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11406151 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11406178 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11406208 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11406496 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11406950 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11407468 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11407514 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11407522 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11407603 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11407662 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11407980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11408626 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11409088 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11409304 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11409622 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11409665 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11409924 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11410604 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11410868 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11410949 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411007 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411163 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411597 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411643 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411651 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411821 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11411830 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11412356 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11412445 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11412917 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11413085 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11413409 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11413611 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11413999 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11414073 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11415177 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11415991 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11416211 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11416335 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11416866 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11416920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11417048 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11417277 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11417323 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11417447 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11417633 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11417986 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11418206 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11418273 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11418370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11418419 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11418524 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11418699 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11419148 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11419300 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11420502 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11421282 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11422220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11422483 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11423196 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11423935 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11425334 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11425407 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11425679 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11425911 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11426730 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11427230 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11427370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11427604 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11427744 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11428643 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11428716 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11428830 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11429399 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11429747 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11429755 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11430443 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11430460 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11430567 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11430818 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11431067 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11431210 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11431326 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11431709 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11431903 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11432780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11433159 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11433779 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11434333 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11434970 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11435003 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11435038 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11435062 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11435208 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11435330 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11436263 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11436611 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11437057 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11437286 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11437391 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11437537 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11437782 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11438410 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11438541 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11438568 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11438789 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11440031 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11440384 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11440856 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11441186 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11441569 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11441623 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11441798 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11441860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442115 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442140 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442174 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442352 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442581 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442662 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11442948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11443138 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11443243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11443340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11444231 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11444452 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11444525 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11444541 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11445149 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11445289 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11445793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11446617 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11446668 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11446706 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11446765 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11446951 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11447060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11447419 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11447745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11447915 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11448008 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11448555 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11448598 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11448962 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449144 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449241 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449497 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449675 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449845 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11450533 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11450550 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11450665 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11451190 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11451483 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11451866 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11451939 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11452692 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11452838 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11453150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11453249 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11453397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11453710 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11453982 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11454393 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11455110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11455519 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11455900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11456302 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11456396 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11456604 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11457201 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11457503 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11457880 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11458186 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11458259 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11458496 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11458607 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11458771 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11459751 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11460687 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11460768 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11460938 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11460989 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11461039 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11461390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11461640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11461748 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11461845 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11462337 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11462450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11462922 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11463082 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11464194 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11465026 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11465263 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11465425 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11465948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11466049 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11466146 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11466197 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11466561 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11466910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11466995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11467622 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11468084 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11469153 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11470577 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11470836 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11470909 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11471182 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11471581 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11471662 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11471956 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11471972 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472278 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472359 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472367 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472448 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472707 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11473568 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11473606 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11474025 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11475102 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11475196 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11477288 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11477539 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11477997 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11478012 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11479094 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11479477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11479868 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11479892 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11480416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11480661 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11480670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11480840 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481250 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481315 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481358 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481404 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481595 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481722 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11481862 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11482346 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11482389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11482524 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11482877 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11482974 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11483059 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11483350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11483822 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11484063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11484551 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11484659 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11485370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11485477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11486996 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11487070 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11487682 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11487704 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11487941 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11489049 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11489774 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11491213 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11491388 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11493127 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11493607 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11493682 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11493836 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11493925 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11494174 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11494298 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11494549 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11494859 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11495499 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11496231 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11496509 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11496770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11497041 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11499575 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11501618 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11502240 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11502681 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11503793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11503939 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11504013 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11504331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11504501 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11505990 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11506555 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11506660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11507314 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11507764 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11507853 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11508809 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11508949 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11509120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11510269 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11511435 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11511966 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11512342 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11513136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11513586 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11513853 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11514060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11514205 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11514710 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11514957 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11515171 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11515686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11516011 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11517280 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11517360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11517573 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518146 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518464 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518588 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518596 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518626 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518634 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11518936 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11519428 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11520116 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11520183 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11520388 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11521031 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11521716 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11523212 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11523255 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11523727 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11523948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11524383 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11524804 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11524847 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11524960 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11526041 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11526610 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11527390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11527781 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11528389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11528559 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11529202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11530332 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11530847 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11531266 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11531932 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11532203 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11532270 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11532467 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11532777 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11533862 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534320 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534346 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534800 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534834 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534842 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534907 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11534958 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11535415 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536276 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536551 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536667 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536772 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536837 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11536993 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11537191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11537400 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11537590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11538120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11538511 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11539518 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11539690 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540230 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540494 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540664 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540702 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540729 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540869 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11542640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11544031 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11544163 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11544384 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11544481 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11544651 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11544783 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11545046 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11545429 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11546123 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11547685 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11548940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549211 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549254 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549378 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549963 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549971 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11549980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11550066 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11550104 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11550163 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11550554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11553901 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11554193 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11555890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11556072 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11556749 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11556943 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11557699 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11558164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11558326 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11559306 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11559810 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11560479 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11561998 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11562013 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11562153 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11562382 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11562544 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11562722 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11563338 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11563389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11563923 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11564431 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11566221 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11566663 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11567031 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11567716 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11568267 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11569620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11569697 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11569719 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11569743 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11569891 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11571063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11571594 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11571845 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11571896 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11571942 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11572205 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11572981 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11573759 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11573864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11573929 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11574208 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11574844 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11574992 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11575069 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11575263 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11575379 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11575654 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11576197 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11576200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11577126 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11577290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11577673 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11577860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11578220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11578629 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11578920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11578998 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11580410 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11580720 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11580828 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11580909 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11581140 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11581492 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11581565 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11581867 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11582022 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11582421 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11582820 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11583584 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11584050 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11584394 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11584530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11584564 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11584793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11585390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11585420 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11585544 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11585552 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11586354 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11586486 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11586915 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11587156 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11587245 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11589817 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11590220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11590637 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11590653 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11591196 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11591331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11591668 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11591773 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11591870 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11592478 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11592737 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11593202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11593318 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11594349 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11594497 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11595000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11595132 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11596627 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11596813 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11596961 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11597208 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11597364 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11598247 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11598271 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11598867 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11599090 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11599219 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11599430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11600306 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11600446 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11600578 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11600829 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11600845 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11601167 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11601299 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11601329 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11601574 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11603259 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11603356 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11604166 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11604590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11605081 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11605898 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11606932 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11607955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11608048 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11609125 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11610263 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11610476 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11611243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11611995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11612614 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11613408 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11613670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11613696 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11614242 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11614633 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11615354 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11615419 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11615648 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11615834 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11618248 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11618485 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11618973 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11619929 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11620072 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11621206 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11621745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11624299 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11626801 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11628014 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11629614 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11630302 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11630345 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11630922 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11631619 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11633131 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11633484 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11634820 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11636041 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11640278 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11643684 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11643803 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11646659 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11650028 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11650869 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11656727 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11657049 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11658002 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11659912 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11666382 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11673672 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11679174 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11696982 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 22097732 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 74138952 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80004903 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80005900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80007864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80019170 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80023550 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80029710 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80031706 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80046991 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80048943 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80062792 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80063632 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80064957 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80066372 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80068332 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80086233 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80091369 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80094686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80094902 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80098479 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80099980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80101127 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80101186 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80101470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80101933 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80102379 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80108067 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80113907 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80115624 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80127916 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80128173 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80134505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80137555 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80142176 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80146570 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80148310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80148832 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80149480 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80149529 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80149618 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80174248 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80174450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80174922 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80176461 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80180620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80181287 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80183506 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80192211 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80214096 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80232051 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80232400 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80234216 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80243061 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80245404 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80245498 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80249426 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80249906 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80271006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80271685 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80274722 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80277900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80279856 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80279910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80280943 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80282636 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80287026 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80289339 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80292399 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80322000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80324681 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80324690 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80326005 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80326951 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80329675 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80330223 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80336167 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80336507 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80341586 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80344062 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80345980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80347681 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80348157 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80357580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80358349 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80360130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80362516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80363296 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80363504 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80364063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80364969 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80365078 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80365736 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80368794 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80369472 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80369928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80411185 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80411207 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80419860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80427090 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80427421 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80431011 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80431399 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80435130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80435823 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80475477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80476015 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80476252 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80477097 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80480160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80480527 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80481604 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80483755 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80493890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80494226 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80497365 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80500234 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80500960 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80577679 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80579485 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90050606 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90051386 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90053311 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90053842 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90054776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90074360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90075293 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90075650 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90077253 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90110560 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90122518 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90122607 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90122950 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90167627 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90260040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 90262590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10004149 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10004661 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10005030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10005072 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10006940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10009558 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10011684 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10016007 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10019685 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10020101 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10020403 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10020527 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10021841 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10022945 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10023640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10024913 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10024948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10030123 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10034218 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10034889 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10048995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10052836 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10054715 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10060367 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10066535 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10067833 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10068074 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10069216 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10072608 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10080961 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10083928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10085734 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10086757 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10088008 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10093630 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10094962 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10099085 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10103546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10105808 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10106553 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10107665 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10108963 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10109463 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10110135 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10116036 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10116311 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10118896 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10131574 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10133135 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10143912 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10149120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10157310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10158219 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10158480 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10159614 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10173293 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10173919 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10177353 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10177655 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10183639 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10184759 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10185151 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10190180 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10191844 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10191860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10205152 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10207651 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10210555 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10216910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10223320 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10226052 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10227750 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10232389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10236970 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10237267 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10246533 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10250603 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10254358 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10254919 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10255338 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10270191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10288988 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10291610 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10294295 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10296182 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10306498 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10311246 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10311467 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10314580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10325050 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10331638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10337598 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10340238 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10340491 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10345035 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10353194 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10361006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10367900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10368817 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10386254 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10399941 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10400354 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10401482 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10405976 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10409220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10425896 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10426540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10431411 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10435530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10438750 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10440437 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10441689 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10442499 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10444912 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10446699 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10446745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10448195 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10451544 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10455655 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10458948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10459707 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10467505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10473556 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10473890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10477349 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10478426 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10478507 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10489339 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10493948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10495207 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10508023 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10508589 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10514651 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10515844 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10533397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10536078 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10541683 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10546260 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10555145 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10557032 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10559086 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10561 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10567550 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10572104 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10575618 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10575936 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10577041 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10580913 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10588787 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10597980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10600981 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10604812 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10609318 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10609717 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10615164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10620818 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10626700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10632859 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10633723 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10636501 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10643249 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10644873 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10647341 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10652728 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10655492 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10665862 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10680454 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10687823 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10695192 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10696091 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10701184 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10707301 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10709088 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10710973 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10714006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10716327 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10719113 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10739912 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10747311 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10762655 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10765280 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10767525 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10768181 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10771557 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10774203 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10777652 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10782524 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10800522 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10808205 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10810170 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10810358 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10812318 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10815082 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10820450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10827056 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10837523 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10838295 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10845453 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10847251 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10848851 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10850880 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10857486 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10878211 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10883398 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10883614 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10885978 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10886273 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10896384 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10896872 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10899537 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10921397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10926054 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10945164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10947116 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10954147 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10956271 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10968954 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10986049 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10995277 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10997130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10997636 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 10999655 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11012102 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11012650 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11014768 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11017449 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11019522 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11019980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11044039 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11045558 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11048131 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11069996 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11070862 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11071230 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11071737 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11072709 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11074850 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11075627 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11081562 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11081708 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11082771 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11083530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11083638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11085690 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11091436 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11094060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11096810 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11098554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11099216 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11100540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11100664 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11102004 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11102438 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11103000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11106379 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11112433 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11115521 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11115661 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11129891 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11144602 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11150254 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11159200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11162201 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11166290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11183683 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11191945 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11192453 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11195231 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11195649 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11197420 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11200030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11206624 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11207230 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11208201 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11224363 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11225165 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11244801 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11251891 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11253355 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11254122 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11254262 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11254696 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11257865 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11262818 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11271353 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11285117 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11295287 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11299002 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11303093 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11324449 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11344091 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11346574 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11351136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11355948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11362553 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11378700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11379260 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11390786 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11391910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11402202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11420774 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11426888 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11449098 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11469943 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11472510 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11476222 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11492430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11493003 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11505184 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11515317 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11517581 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11531029 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11540214 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11556269 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11556595 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11569590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11579030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11580062 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11581298 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11581484 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11582790 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11583096 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11585935 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11589582 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11593059 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11593172 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11597887 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11598034 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11598115 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11599693 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11600187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11615770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11625040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11634430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11638761 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11639920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11641010 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11643951 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11644117 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11644729 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11644923 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11648546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11655518 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11657898 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11658290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11658860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11659211 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11667303 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11673907 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11674148 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11675713 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11680911 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11691204 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 11726326 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1233653 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1325523 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1329430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1329928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1356836 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1427946 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1508954 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1510690 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1515187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1518402 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1520709 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1714830 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 17256 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1826654 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1827227 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1829220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1832000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1832310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1832484 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1833413 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1838199 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1839411 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1854658 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1860062 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1865480 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1872850 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1878859 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1879006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1879561 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1879790 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1880888 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1885146 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1885634 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1885944 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 18864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1900358 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1900900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1903675 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1907506 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1924710 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1926152 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1926381 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1926403 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1926454 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1926578 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1926934 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1927337 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1928104 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1930451 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1932128 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1935623 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1939424 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1940155 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1941160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1945556 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1946447 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1949055 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1977407 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1983792 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1995928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1997084 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 1997270 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2001748 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2003309 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2007860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2011832 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2013932 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2014726 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2014823 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2016001 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2017202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2017504 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2017679 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2017695 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2017997 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2019558 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2023610 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2023857 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2026600 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2032333 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2036070 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2037955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2039079 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2039745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2043700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2045621 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2045907 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2046377 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2047080 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2047861 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2048191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2048280 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2051150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2056666 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2057700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2058618 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2060388 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2066670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2066866 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2070405 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2071088 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2071878 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2072785 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2073315 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2073986 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2074745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2075326 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2075440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2086824 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2088100 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2092905 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2095122 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2095564 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2095700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2095904 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2096099 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2097060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2097079 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2098431 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2119560 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2121131 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2124726 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2126125 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2126370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2126877 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2139308 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2143275 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2145685 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2151707 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2157560 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2157721 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2168219 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2176408 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2177641 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2182777 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2187400 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2187523 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2188864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2190389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2194244 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2195399 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2196441 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2196476 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2197740 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2198479 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2202999 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2203316 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2203383 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2203600 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2203774 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2204568 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2204649 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2205815 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2208393 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2209586 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2211556 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2212340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2219867 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2236192 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2237180 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2238349 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2242516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2253674 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2267446 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2269082 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2269201 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2269686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2269791 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2269864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2273640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2282666 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2286165 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2290286 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2291673 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2295520 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2306786 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2308207 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 23086 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2310350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2310759 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2310864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2312220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2319900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2322242 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2323591 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2323702 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2323966 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2324458 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2324504 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2324768 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2325020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2325071 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2325080 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2325136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2326485 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2328038 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2328089 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2328615 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2329344 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2331187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2334682 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2335379 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2338483 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2338947 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2341280 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2345650 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2348942 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2354969 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2363127 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2373823 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2374811 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2375389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2381516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2388952 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2393077 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2393930 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2394120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2394863 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2395282 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2396556 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2398885 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2417286 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2421569 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2422107 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2422263 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2423871 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2425092 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2432269 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2434172 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2434342 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2434350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2434377 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2435071 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2435217 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2435411 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2435560 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2441403 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2442876 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2447444 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2451506 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 24538 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2453940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2463890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2465620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2465620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2465701 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2468875 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2468913 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2469146 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2471477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2476886 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2477491 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2477998 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2479885 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2480689 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2489341 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2492644 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2494647 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2495627 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2503263 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2510561 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2514745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2515199 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2528622 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2537982 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2540371 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2547562 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2553546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2554305 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2555310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2555956 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2564386 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2565471 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2570670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2581485 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2594013 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2603993 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2607875 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2608995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2609665 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2610108 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2612666 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2616351 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2621967 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2639238 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2639351 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2642409 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2643812 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2645645 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2645670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2645866 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2645998 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2646161 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2653729 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2654008 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2657422 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2660717 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2660776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2664259 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2669439 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2670046 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2670291 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2676184 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2676680 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2677717 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2682087 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2682494 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2685191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2686058 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2690918 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2692856 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2697939 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2698552 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2699028 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2700700 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2701006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2701570 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2701880 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2705265 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2706733 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2708248 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2710374 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2713381 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2713624 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2714400 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2715767 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2722658 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2723735 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2728800 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2729970 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2730081 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2730430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2737469 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2741776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2743620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2744015 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2751976 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2754495 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2755920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2765004 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2765527 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2770512 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2772582 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2785323 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2798611 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2801809 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2807459 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2812886 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2816067 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2816121 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2817136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2817659 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2821648 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2824108 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2826801 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2835533 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2837161 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2843340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2843455 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2843536 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2843919 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2844443 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2844591 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2846314 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2850265 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2850290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2860554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2861283 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2861356 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2864096 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2864410 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2864533 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2869713 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2873605 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2874008 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2891859 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2892120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2905345 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2906040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2918080 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2926911 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2930617 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2934728 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2938260 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2939002 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2941686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2942534 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2944871 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2945045 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2946645 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2947030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2948222 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2949997 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2950057 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2950855 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2952807 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2953889 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2954818 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2955989 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2960753 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2961040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2963094 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2963647 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2965330 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2970074 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2974967 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2975629 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2985470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2991160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2992892 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2996332 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 2998947 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3005356 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3005500 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3006859 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3013286 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3013529 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3013545 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3019373 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3025098 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3026922 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3037029 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3042014 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3043606 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3044130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3048020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3061809 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3073190 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3077527 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3078906 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3082652 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3083454 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3084264 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3084850 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3085180 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3086682 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3095770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3101487 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3111687 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3118010 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3122360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3125637 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3126331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3127664 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3129233 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3129470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3131440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3131971 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3134431 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3136507 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3137589 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3141837 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3143880 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3146790 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3148300 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3150054 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3150631 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3152693 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3154548 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3154556 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3162052 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3164187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3167720 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3188019 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3210103 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 337 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3500225 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3500713 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3502597 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3507688 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3507696 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3507858 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3508404 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3509796 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3513874 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3514609 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3515460 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3520790 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3522857 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3522881 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3523020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3524833 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3526798 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3528898 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3528910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3537250 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3541967 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3547175 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3555909 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3564576 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3569713 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3571513 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3571920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3576809 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3578089 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3592294 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3595226 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3598217 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3598500 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3600114 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3601390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3603776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3604144 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3609278 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3609383 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3609421 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3613518 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3614093 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3614522 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3614573 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3617718 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3626180 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3629007 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3629040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3634450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3635546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3642348 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3649563 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3652483 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3652670 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3654990 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3657604 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3658511 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3661962 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3663310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3664015 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3664953 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3671151 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3684458 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3689107 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3689778 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3690954 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3692574 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3694186 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3698874 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3700054 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3702359 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3704866 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3705064 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3705340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3706060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3709515 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3710696 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3710831 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3714055 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3714799 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3715221 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3716066 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3717690 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3720241 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3721124 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3727343 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3728625 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3740358 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3742458 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3747220 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3754146 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3754324 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3754456 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3755002 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3755649 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3756513 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3756955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3761070 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3761240 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3761789 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3762491 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3775704 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3778126 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3778665 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3781038 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3781631 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3783154 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3790991 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3791955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3792129 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3796264 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3797350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3798380 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3800334 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3801098 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3803899 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3813339 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3814947 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3816940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3818780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3822478 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3829626 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3836770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3840140 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3840638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3840972 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3841057 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3841669 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3842053 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3842479 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3844609 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3844986 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3845630 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3845656 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3848728 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3853721 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3856194 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3857360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3860736 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3862003 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3865711 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3868168 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3869113 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3869407 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3870065 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3870227 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3874338 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3877787 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3878155 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3878570 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3880109 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3883418 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3886883 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3897923 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3898474 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3901793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3903478 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3907546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3916634 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3921867 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3924491 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3927890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3928063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3929736 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3931447 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3933024 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3935620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3946304 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3946541 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3953319 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3956113 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3956555 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3959082 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3964906 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3965996 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3966658 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3979156 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3981541 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3981800 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3989895 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3991814 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 3999858 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4002539 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4007630 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4019172 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4022653 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4029178 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4032110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4032306 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4036212 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4038142 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4040449 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4041500 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4042948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4044150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4047540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4049390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4049780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4051386 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4058119 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4061993 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4069765 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4075552 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4080602 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4083431 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4368371 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4369181 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4373634 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 4521986 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 493 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 5555558 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 582 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 582 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6000355 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6004083 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6005675 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6007597 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6007856 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6007929 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6008348 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6009735 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6010385 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6010580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6025250 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6025595 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6030262 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6031390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6032516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 604 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6040470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6042643 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6042945 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6044808 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6046860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6049192 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6057381 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6059139 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6072720 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6073921 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6074200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6090290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6090931 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6101046 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6130526 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6133789 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6137601 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6138527 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6139310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6139736 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6141005 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6142168 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6142524 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6146503 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6147755 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6158153 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6164013 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6165761 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6169007 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6169090 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6170382 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6170897 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6170978 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6171516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6172083 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6173500 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6175171 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6175694 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6190731 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6204317 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6211674 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6216870 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6225810 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6237070 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6238580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6242529 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6244416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6251641 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6257712 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6258050 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6259138 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 626007 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6270646 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6275168 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6278272 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6279635 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6281478 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6292798 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6301231 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6302262 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6304451 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6304940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6306810 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6311830 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6312004 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6312330 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6312780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6313450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6315364 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6321003 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6335748 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6336353 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6336949 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6337899 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6353495 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6357644 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6377734 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6381324 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6382002 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6382550 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6383343 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6383831 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6390374 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6396070 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6398030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6399088 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6411371 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6411533 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6412416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6413137 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6417418 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6418953 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6418970 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6420001 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6424333 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6424473 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6424708 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6428150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6429505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6429785 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6438857 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6447929 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6449204 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6449786 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 644986 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6455093 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 646407 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6473539 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6473970 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6477577 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6480179 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6480454 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6481248 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 648248 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6484816 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6485510 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6487505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6494005 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 649481 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6495460 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6496776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6504507 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6506445 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6514200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6516033 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6516130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6516645 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6524583 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6525172 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6529160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6535410 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6538380 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6539610 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6549764 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6562000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6564771 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6567240 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6568955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6570119 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6576745 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6577040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6578179 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6578535 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6578560 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6578713 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6582516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6582656 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6584080 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6584713 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6587216 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6588042 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6588131 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6588603 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 658863 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6589260 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6589588 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6589650 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6590055 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6595960 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6603548 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6604153 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6617182 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6622143 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6623697 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6633080 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6634508 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6639402 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6640443 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6650899 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6654266 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6663729 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6668810 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6669468 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6669646 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6675522 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6679099 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6686230 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6687660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6688896 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6688985 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6696910 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6700985 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6701914 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6702210 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6704999 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6705707 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6707122 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6707190 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6707807 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6708331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6709770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6712720 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6713564 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6715273 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6717772 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6718825 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6723306 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6723390 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6724051 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6731490 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6738109 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6744036 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6750850 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6752888 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6755623 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6759998 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6760147 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6762948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6766870 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6767214 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6767834 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6767842 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6768458 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6768725 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6771742 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6772919 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6773214 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6773630 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6774679 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6775071 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6790100 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6796451 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6797792 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6799515 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6801692 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6806643 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6813151 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6814913 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6815049 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6819656 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6820166 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6820239 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6822150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6833683 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6837204 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6837530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6841023 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6848702 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6850197 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6851495 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6858317 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6862420 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6863272 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6864287 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6866131 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6870732 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6875963 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6882919 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6887660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6889930 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6891020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6891438 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6900500 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6917445 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6918883 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6930638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6930794 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6935117 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6939724 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6941478 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6945945 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6946933 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6950051 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6950370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6952003 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6957137 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6962068 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6963480 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6969488 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6969640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6973191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6975364 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6985335 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6988539 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6997635 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 6999930 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7003820 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7009020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7010940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7011598 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7015160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7026382 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7029063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7029616 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7029870 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7030347 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7033338 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7034920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7043805 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7047509 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7049099 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7062176 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7068557 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7072651 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7075170 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7076932 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7083939 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7084234 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7090200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7096356 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7100132 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7113889 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7116640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7118490 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7125020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7125224 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7132476 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7138202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7144091 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7145896 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7149352 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7151284 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7152191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7152213 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7162200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7164548 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7175213 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7175477 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7176147 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7177917 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7187068 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7191979 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7193890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7208600 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7224893 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7225164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7229410 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7230630 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7233442 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7239602 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7248954 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 726389 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7272243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7272871 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7279728 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7282052 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7282516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7283482 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7284675 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7287011 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7290411 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7295553 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7297769 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7302371 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7310595 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7311290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7311648 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7312385 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7314183 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7314647 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7315481 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7320698 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7327323 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7331819 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7335865 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7335911 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7339879 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7342977 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7347243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7347278 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7347839 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7348835 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7350988 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7351321 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7357923 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7360509 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7364695 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7365250 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7369506 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7390327 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7391447 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7392940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7397240 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7397623 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7400330 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7401752 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7401795 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7402619 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7403348 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7403836 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7403941 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7405138 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 740934 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7410000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 74138944 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7414862 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7423110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7425708 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7432674 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7444370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7446683 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7447930 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7455097 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7455518 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7455909 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7455984 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7458959 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7460414 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7464363 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7466684 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7467397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7470118 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 748056 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7486383 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7489498 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 749346 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7494238 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7495110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7496931 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7497580 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7498934 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7499000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7502613 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7503350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7503750 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7504071 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7504284 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7509120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7511051 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7512570 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7521081 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7526636 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7528 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7528116 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7529317 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7535864 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7544413 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7546416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7552505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7552998 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7553714 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7556420 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7558465 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7561512 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7562284 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7562772 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7567030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7572697 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7574010 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7574347 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7575050 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7575122 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7575742 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7583486 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7584172 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7587090 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7591098 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7593090 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7601360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7601476 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7603690 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7604467 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7625 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7627084 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7639546 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7640609 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7641761 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7644639 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7645961 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7652658 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7654006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7660472 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7662025 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7662122 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7662777 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7677880 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7696728 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7710607 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7714858 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7714980 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7715846 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7715854 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7717881 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7719000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7734441 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7735251 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 774030 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7740620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7743661 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7745141 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7746563 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7751591 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7754000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7754159 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7756160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7765304 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7771592 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7771630 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7776918 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7777302 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7777493 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7777990 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7784112 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7786999 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7789130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7799497 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7800622 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7801505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7802374 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7809484 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7820062 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7825870 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7828110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7833407 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7834110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7834578 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7834721 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7847955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7851928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7853467 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7853904 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7860609 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7863292 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7863780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7865260 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7868960 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7869797 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7869878 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7883331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7885717 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7887370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7887868 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7888155 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7888333 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7892209 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7894538 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7894953 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7899602 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7900554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7905017 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 790850 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7909136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 791164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 791440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7916019 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 791652 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7917112 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 792179 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 792314 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 792764 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7928041 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7928394 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7931948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7935293 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7937610 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7943776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7945400 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7945426 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7946139 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7947194 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7948468 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7948476 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7950497 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7951906 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 795488 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7955774 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7958994 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7964412 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7965761 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7972202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7972709 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7975350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7980841 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7982488 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7982739 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7983727 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7984049 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7985070 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7988400 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 7999771 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8000166 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80057551 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80080170 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8008795 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8009899 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80106900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80108040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80109632 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80110002 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80126553 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8013136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80139302 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80141315 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80141501 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80150004 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8016887 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80172784 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80174647 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80180132 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80181554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8018634 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80189253 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 801950 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80197469 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80211143 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80214479 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80230440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80231462 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80232221 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80234488 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80242502 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80243193 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80245005 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80245102 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8024600 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8025312 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8025380 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80258948 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8025959 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8027110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80278809 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80278981 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80286011 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80287115 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80288995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80289282 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80322611 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80323235 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80325548 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80328806 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80334687 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8033498 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8033781 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80340229 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80344518 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80345115 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80354629 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80355005 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80355706 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80367798 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8038236 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8038287 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8038627 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8040168 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8040885 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80410979 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80421040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80421849 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80422551 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80424139 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80424732 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80426654 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80426921 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80438385 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80470513 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80480756 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 80484000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 804860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8049955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8051569 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8055866 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 805777 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8058466 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8064440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8068933 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8069999 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8072426 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8081565 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8084840 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8086974 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8088160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8088462 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8089140 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8093024 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8093350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8105197 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8109435 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 812463 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8130493 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8130558 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8132364 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8132984 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8133840 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8136386 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8137447 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 813761 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 813770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8140464 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8142106 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8146055 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8147019 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8151350 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8151601 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8153388 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 815454 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8159947 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8160112 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8160686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 816590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8165963 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8167516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8171645 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8175314 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8178445 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8181136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8181438 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8183236 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8183660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8184402 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8189102 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8191182 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8191298 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8193037 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 819808 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8199493 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8201633 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 820393 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8210730 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 821500 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8215480 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8217963 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8220093 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8228841 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8235902 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8243441 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8246025 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8246874 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 824950 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 824984 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8250120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8257647 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8259160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8261660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8267243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8273316 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8273995 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8279543 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8289832 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8293694 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 830135 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8304440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8310300 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8327068 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8331340 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 833681 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8343772 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8346798 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8352801 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8354316 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8357854 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 836141 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8369860 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 837440 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8374554 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8374619 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8374686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8376514 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8378959 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8381283 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8385912 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 839450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8397333 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8400423 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8402868 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8409218 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8409480 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 840955 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 841625 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8424535 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 842559 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8426449 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8429979 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8430578 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8431213 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8431930 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8436134 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 843806 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8448159 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8448248 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8451133 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8456674 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8460060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8462194 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8464260 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8465886 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8469210 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8472602 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 847321 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8473722 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8475849 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8481849 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8487766 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8490562 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8493855 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8493952 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8502471 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8505063 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8515867 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8519064 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8525110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8527121 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8533644 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8538140 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8542244 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8544891 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8547858 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8549982 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8561117 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8566755 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8570078 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8571066 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8580774 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8582033 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8583528 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 858463 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8587205 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 858722 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 859370 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8593892 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8595267 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8599785 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8603243 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8604428 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8608016 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8608024 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8610380 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8612021 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8612811 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8615209 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8615780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8615888 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8617155 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8617163 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8625816 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8627010 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 862762 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8629897 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 863203 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 863521 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8638136 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8640416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8642770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8645469 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8648662 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8654620 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8655529 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8657912 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 86703 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8671290 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8675015 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8681074 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8693625 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8695130 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8700320 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8710694 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8718997 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8721386 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8727643 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8733503 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8738840 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8746028 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8760780 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8764891 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8768374 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8770336 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8771502 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8776121 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8776326 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8781842 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 878812 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8790450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8791902 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8792003 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8792410 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8794804 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 880957 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8811644 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8824614 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8824738 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 882534 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8826 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8827303 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8834555 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8839093 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8843821 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8852278 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8854890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8855331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8857946 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8873267 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 887331 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8873712 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8883122 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8883270 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8883718 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8883874 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8885109 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8885311 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8885346 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8885958 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8886873 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8886997 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8887403 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8888795 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8891958 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8904391 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8909776 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8910448 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8916870 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8921199 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8921865 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8926336 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8930163 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8939160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8943362 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8943770 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8945217 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8946779 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8947856 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8949484 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8949999 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8951594 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 895164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8951730 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8951934 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8957304 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8965048 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8967032 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8971978 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8974187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8974292 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8975744 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8979650 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8982643 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8985022 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 8995621 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9000186 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9002545 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9006559 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9007334 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9013750 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9022627 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9023100 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9024298 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9025693 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9033505 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9037853 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9038205 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9039686 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9041664 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9045619 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9046178 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9047018 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9047204 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9054529 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9055185 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9056262 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9064397 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9067485 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9071733 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9075976 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9083154 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 908606 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9086129 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9092811 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9093940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 909696 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9099786 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 910015 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9101020 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 910120 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9102590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9106006 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9106464 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9110704 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9112782 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9113010 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9114637 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9117008 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9119000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9119825 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9120408 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9121854 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9123156 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9126929 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9126996 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9128000 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9128743 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9134921 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9136800 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9138382 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9147446 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9149759 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9150200 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9152822 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9153055 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9153489 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9163751 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9165649 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9165967 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9167579 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9169636 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9169644 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9169920 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9171304 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9188932 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9189416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9189513 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9197940 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 919950 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 920207 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9204288 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9204741 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9206388 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9207619 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 921041 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9211101 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 921653 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9217223 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9222456 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9226060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9231382 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9232001 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9232109 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9237720 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9248668 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9249923 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9254161 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9255605 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9263110 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9264183 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9271430 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 927481 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9283218 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9284257 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9289275 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 929166 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9291768 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9292055 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9296239 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9297308 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 930245 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 930253 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9314784 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9319433 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9319735 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9322086 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9327185 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9329706 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9331417 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9333681 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9333959 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9337253 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9343431 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9354573 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9354638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9359060 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9360514 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9374809 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9375945 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9382470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9391207 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9401229 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 940577 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9408134 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9414614 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 941778 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 941832 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 941859 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9419438 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9421564 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 942359 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 942863 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 943118 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 943185 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9432132 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9444718 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9445242 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9454462 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9456384 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9458760 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9464131 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9466088 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9472851 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9473793 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9474358 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9479600 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9483977 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9484540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9485490 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9487590 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9510664 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9512470 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9515984 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9517219 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9517766 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9522310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9524991 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9525262 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9525874 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9527761 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9538160 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9539565 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9539921 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9544259 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9551247 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9555510 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9562460 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9563660 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9569928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9570551 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9570691 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9576657 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9578790 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9593098 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9596828 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9597450 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9606360 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9606858 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9609164 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9612416 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9614826 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9616241 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9617540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9619526 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9626352 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9632638 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9637427 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9638997 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9663932 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9666834 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9667202 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9671846 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9674551 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9674721 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9678697 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9679391 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9681191 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9681760 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9686444 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9687645 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9688510 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9689516 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9692126 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9696369 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9700676 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9701133 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9703900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9712640 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9716106 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9734520 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9735402 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9738924 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9748040 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9748067 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9754695 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9754881 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9760903 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9763848 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9764658 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9769269 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9776168 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9779299 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9790900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9793666 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9794719 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9795928 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9802339 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9805206 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9817115 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9818553 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9818588 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9818596 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9818600 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9818677 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9822216 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9822224 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9822232 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9828575 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9828583 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9829377 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9830375 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9837540 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9837663 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9839712 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9847073 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9847189 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9849890 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9851151 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9858091 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9866310 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9881530 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9886451 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9889221 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9893067 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9900845 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9910409 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9913769 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9915656 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9922490 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9922679 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9922750 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9929460 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9935150 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9938974 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9940863 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9941100 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9949577 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9951466 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9954473 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9956018 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9958959 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9961038 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9969187 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9969900 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9970894 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9980741 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9993061 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9993401 Conta from dual union all
select 1 CodCop, 'VIACREDI' NomeCop, 9994432 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 299 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1520 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3000 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 4979 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 5967 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 9849 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 10561 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 16497 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 17302 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 18171 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 18600 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 19771 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 21237 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 22683 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 24937 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 25836 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 26611 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 29572 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 33154 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 34002 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 35963 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 37001 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 37206 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 37427 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 40479 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 42340 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 44210 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 48542 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 51420 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 52078 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 54330 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 57169 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 58793 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 60097 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 60100 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 60275 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 62448 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 63738 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 63878 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 64955 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 66583 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 66729 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 68110 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 68306 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 69345 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 69825 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 73547 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 73709 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 74950 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 75701 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 78182 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 78859 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 81531 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 82996 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 83046 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 84867 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 85626 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 86207 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 87033 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 87718 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 89230 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 91804 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 92134 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 92770 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 93700 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 98515 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 98701 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 99910 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 101273 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 101648 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 102202 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 107255 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 107425 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 108260 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 108308 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 109444 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 110680 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 112755 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 113840 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 114626 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 115509 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 116610 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 116971 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 118940 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 120073 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 122556 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 124222 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 125075 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 125083 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 125113 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 128015 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 129119 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 129887 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 131130 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 136034 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 139637 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 139823 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 141127 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 141488 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 141640 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 144754 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 145084 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 149802 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 150169 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 152510 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 152994 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 153362 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 153575 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 154350 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 154440 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 156914 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 159581 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 162043 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 164186 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 165344 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 168831 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 169650 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 170267 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 171913 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 172944 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 173142 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 173916 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 174360 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 178837 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 179795 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 180408 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 180807 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 181471 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 182923 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 184918 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 191140 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 192244 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 192872 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 199290 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 200174 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 200409 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 201022 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 203610 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 204064 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 204552 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 205060 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 205826 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 207373 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 208698 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 210811 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 212563 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 213284 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 216208 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 218081 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 218570 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 218618 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 219150 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 222283 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 223689 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 224332 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 226246 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 228087 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 228303 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 230464 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 234672 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 235245 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 235520 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 238082 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 239860 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 240540 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 240907 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 241253 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 244554 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 248207 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 248509 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 249319 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 251461 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 254835 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 256471 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 256650 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 260118 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 262129 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 263214 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 263559 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 264687 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 265187 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 266035 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 269468 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 269611 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 270903 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 271063 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 273341 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 274704 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 278009 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 278068 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 278203 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 279218 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 279382 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 280070 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 280089 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 280615 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 281298 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 282359 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 282367 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 282774 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 283355 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 286737 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 287032 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 287741 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 287784 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 287857 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 288390 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 289507 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 290343 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 290858 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 291196 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 293130 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 293164 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 293369 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 293962 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 294489 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 298034 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 300543 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 300683 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 302210 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 303364 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 303976 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 304964 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 305227 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 305901 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 306142 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 306681 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 306720 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 307416 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 308234 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 309648 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 310476 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 311499 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 311901 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 313807 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 315397 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 316091 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 316717 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 317080 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 317500 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 319902 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 320935 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 321745 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 322709 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 322792 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 322849 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 324159 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 324400 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 326259 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 327573 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 328812 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 330060 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 330388 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 331740 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 333166 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 336670 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 336858 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 337196 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 337277 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 338311 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 339237 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 339784 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 342181 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 347884 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 348139 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 348376 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 348996 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 350729 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 353493 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 354040 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 354317 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 355445 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 355810 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 358380 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 359467 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 359734 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 361127 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 361810 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 363960 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 364401 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 365076 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 365424 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 368105 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 368113 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 369330 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 373621 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 377120 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 377287 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 377546 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 378259 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 379255 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 382930 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 384089 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 386014 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 387916 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 387983 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 389285 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 398357 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 398900 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 404691 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 405582 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 409910 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 415588 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 415952 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 417513 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 421235 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 422843 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 430056 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 432717 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 434140 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 434701 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 435465 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 437590 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 437760 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 437794 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 438189 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 439070 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 439223 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 441937 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 441996 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 442305 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 448877 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 449490 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 450197 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 454397 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 454524 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 455423 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 455474 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 455660 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 456314 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 464767 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 465160 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 466883 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 467723 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 469033 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 471569 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 472280 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 472387 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 473391 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 475823 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 477222 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 477621 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 480010 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 480274 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 484857 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 486892 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 486906 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 487112 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 488453 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 489239 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 492159 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 495085 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 495565 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 497720 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 499323 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 502073 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 503576 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 505315 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 511153 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 512524 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 514420 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 516260 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 516880 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 517607 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 517747 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 518921 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 520764 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 522023 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 522120 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 524930 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 524972 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 526894 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 526908 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 527076 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 527700 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 530832 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 531960 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 532860 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 534021 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 534650 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 535540 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 536377 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 536890 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 536954 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 537160 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 537632 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 537772 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 540609 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 540854 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 545341 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 545961 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 546615 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 548057 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 555568 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 558613 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 558648 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 559229 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 561207 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 563013 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 563650 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 563803 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 563994 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 565784 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 566373 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 569224 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 573124 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 574783 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 578983 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 582549 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 584720 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 589551 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 592951 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 593095 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 593893 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 595357 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 598747 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 598992 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 599441 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 599786 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 600652 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 605301 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 613487 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 615137 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 617032 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 618055 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 618560 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 618993 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 620696 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 623938 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 627500 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 628034 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 628581 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 630080 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 633518 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 637742 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 638994 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 639150 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 639885 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 642355 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 644277 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 644447 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 644668 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 645389 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 646300 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 646377 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 648833 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 650307 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 652962 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 653284 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 662690 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 662917 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 664790 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 664804 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 666475 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 668281 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 670073 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 670944 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 681334 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 681792 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 683086 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 684775 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 690481 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 693553 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 694185 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 694665 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 695416 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 695505 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 696331 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 699950 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 703060 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 703257 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 703265 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 703400 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 703583 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 704539 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 704644 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 705748 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 706582 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 707082 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 708704 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 710288 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 710423 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 710920 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 711810 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 715069 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 715727 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 715972 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 716774 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 717304 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 717479 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 718300 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 720160 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 720372 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 721387 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 723215 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 726060 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 734195 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 734306 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 895997 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 906727 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 917303 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 924113 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 950025 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 950432 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 961680 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 963011 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1834460 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1836307 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1909100 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1942131 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1943170 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2003945 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2004348 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2054752 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2111756 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2112507 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2130890 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2130920 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2137755 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2155435 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2167204 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2175738 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2178729 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2210207 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2265737 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2272750 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2273160 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2284871 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2285320 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2293560 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2368455 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2409062 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2430142 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2459760 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2471990 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2472236 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2472333 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2472813 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2473054 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2500256 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2539209 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2540240 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2557010 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2557550 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2598752 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2602474 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2688620 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2721805 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2767430 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2778718 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2778874 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2779005 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2779846 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2840731 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2851229 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2853094 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2875985 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2886367 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2902567 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2921316 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3001350 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3001598 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3002349 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3039706 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3119769 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3121097 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3512150 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3540480 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3620123 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3677575 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3678806 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3678903 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3680100 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3746453 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3802280 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3807754 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3808149 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3850706 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3908992 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3963160 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3971376 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3987442 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3988597 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6015140 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6033555 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6096506 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6097570 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6126111 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6156703 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6161189 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6269303 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6269362 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6283373 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6283730 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6369820 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6369863 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6432220 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6443036 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6467733 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6523366 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6533868 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6534414 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6545998 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6597564 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6611230 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6642640 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6671527 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6734219 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6781934 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6782442 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 107077 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 111090 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 11355948 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 115657 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 116 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 117048 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 117153 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 118303 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 12246 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 125849 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 131210 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 133760 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 139424 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 149144 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 151653 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 154865 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 161250 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 16462 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 166626 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 175889 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 176001 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 178500 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 181668 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 185027 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1887998 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 193836 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 193844 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 194220 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 1942816 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 195030 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 199885 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 205192 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 205338 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2063077 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2063875 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2113538 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 213 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2167182 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2175428 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 218413 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 222291 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2268922 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 230847 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 231894 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 233820 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 236241 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 239577 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 239712 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 240303 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2408945 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2410508 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 245194 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 248 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2499738 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 250031 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2534703 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2556880 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2598779 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 26000 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 263958 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2650428 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 265462 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 265616 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 266698 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 267724 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2688581 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2721260 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 274399 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2765926 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 277495 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 278939 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2852853 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 28584 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 2885638 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 293180 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 29734 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 297518 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 298255 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 302 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3040259 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 306061 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3062562 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 308480 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 311456 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 313394 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 320617 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 320676 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 320854 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 321869 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 322997 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 326992 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 328413 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 337684 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 34037 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 340421 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 343170 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 343528 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 346756 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 348341 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 35 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 353531 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 354252 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 354708 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 359394 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 361 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 364800 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 366153 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3676650 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3676846 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 371718 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 37222 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3745473 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 37575 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 381756 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 383503 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 388726 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 389188 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 39497 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3971260 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 3988902 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 399779 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 40258 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 402761 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 403482 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 405892 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 406708 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 407011 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 407577 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 408417 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 410772 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 412368 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 41300 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 417459 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 418242 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 420174 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 420379 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 421383 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 422177 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 425303 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 429562 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 43 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 431010 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 436291 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 43630 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 442208 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 448184 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 450 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 460028 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 461423 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 467391 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 469 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 469092 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 472298 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 473081 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 477 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 482854 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 485 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 486671 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 494453 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 495298 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 496669 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 50547 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 507 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 509590 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 51 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 514063 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 515 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 515680 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 519464 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 522376 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 523 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 525006 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 529850 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 540 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 542601 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 542784 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 543080 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 543667 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 546550 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 546674 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 55050 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 550701 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 551171 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 552275 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 552356 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 555940 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 558 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 560812 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 566020 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 566080 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 568961 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 573736 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 574 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 579157 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 582 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 583448 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 584649 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 586641 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 588210 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 589373 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 589454 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 590 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 594350 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 598526 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 60 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 601071 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 603147 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6032770 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 604 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6060730 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6077668 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 607924 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6097669 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 614645 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6149359 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6284078 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 631027 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6330185 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 647 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 655201 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6610250 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6642870 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 665045 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6671330 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 66885 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 670634 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 671 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 671185 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 677493 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 680 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 681970 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 6963 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 710 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 72761 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 74810 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 752 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 760 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 78840 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 79197 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 79634 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 79979 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 82481 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 86 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 860875 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 8753 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 88706 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 95559 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 97071 Conta from dual union all
select 16 CodCop, 'VIACREDI AV' NomeCop, 9865 Conta from dual
)
select a.CodCop, a.Conta
  from dados a;
 
 cursor cr_contas (pr_cdcooper in tbpix_crapass.cdcooper%TYPE
                  ,pr_nrdconta in tbpix_crapass.nrdconta%TYPE) is
 select a.cdcooper
       ,a.nrdconta
  from tbpix_crapass a
 where a.cdcooper = pr_cdcooper
   and a.nrdconta = pr_nrdconta;
  rw_contas cr_contas%ROWTYPE;

begin
  -- Test statements here
   for rw_registros in cr_registros loop
     
      open cr_contas(pr_cdcooper => rw_registros.CodCop
                    ,pr_nrdconta => rw_registros.Conta);
                    
      fetch cr_contas into rw_contas;
      
      if cr_contas%found then
        
         begin
           update tbpix_crapass ass
              set ass.flliberacao_restrita = 1
            where ass.cdcooper = rw_contas.cdcooper
              and ass.nrdconta = rw_contas.nrdconta;
           
         exception
           when others then
             continue;
         end;   
         
      end if;
      
      close cr_contas;
      
   end loop;
   
   commit;
   
end;