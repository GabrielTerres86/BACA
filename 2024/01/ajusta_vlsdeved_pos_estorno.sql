DECLARE
  vr_erro EXCEPTION;
 
  CURSOR cr_lancamentos IS 
    select t.cdcooper, t.nrdconta, t.nrctremp, SUM((CASE WHEN h.indebcre = 'D' THEN t.vllanmto ELSE t.vllanmto * -1 END)) + r.vldivida calculado
      from cecred.craplem t
         , cecred.craphis h
         , cecred.crapris r 
     where t.cdcooper=h.cdcooper 
       and t.cdhistor=h.cdhistor
       AND r.cdcooper=t.cdcooper
       AND r.nrdconta=t.nrdconta
       AND r.nrctremp=t.nrctremp
       AND r.inddocto=1
       AND r.DTREFERE=to_date('30/11/2023', 'DD/MM/YYYY')
       AND t.dtmvtolt >= to_date('01/12/2023', 'DD/MM/YYYY')
       AND t.CDHISTOR IN (2358,2342,2346,2373,2345,2472,2330,2344,2471,2347,2343,2349,2363,2365,2348,2371,2331,2359)
       AND (t.cdcooper, t.nrdconta, t.nrctremp) IN (
            (1,  1518852 ,1782536),
            (1, 2267330 ,2274342),
            (1, 2267330 ,3045964),
            (1, 2329514 ,2787284),
            (1, 2753111 ,2357499),
            (1, 2760444 ,2393934),
            (1, 2826909 ,2393857),
            (1, 3061159 ,2343793),
            (1, 3508706 ,2467461),
            (1, 3508706 ,2467464),
            (1, 3622649 ,3447532),
            (1, 3977021 ,2395708),
            (1, 3977021 ,2839285),
            (1, 3990788 ,2398106),
            (1, 3990788 ,2398191),
            (1, 3990788 ,2739546),
            (1, 3990788 ,2739647),
            (1, 3990788 ,2739670),
            (1, 3998924 ,2335917),
            (1, 3998924 ,2335951),
            (1, 4033167 ,2234348),
            (1, 4033167 ,2234427),
            (1, 4039106 ,2395124),
            (1, 4039106 ,2395227),
            (1, 4060458 ,2262250),
            (1, 4068971 ,2277397),
            (1, 6075967 ,2264839),
            (1, 6438660 ,2335589),
            (1, 6454690 ,2390209),
            (1, 6487874 ,2239799),
            (1, 6623409 ,2260832),
            (1, 6662528 ,2330747),
            (1, 6667503 ,2285856),
            (1, 6732321 ,2235097),
            (1, 7018037 ,2402864),
            (1, 7117140 ,2424536),
            (1, 7196946 ,2362172),
            (1, 7200056 ,2324888),
            (1, 7252137 ,2231012),
            (1, 7414170 ,2290425),
            (1, 7562268 ,2443732),
            (1, 7562268 ,3318111),
            (1, 7669267 ,4770681),
            (1, 7811900 ,1731568),
            (1, 7927703 ,2494060),
            (1, 7927703 ,2494083),
            (1, 8086281 ,2367415),
            (1, 8086397 ,2368301),
            (1, 8111090 ,4098966),
            (1, 8117640 ,2959958),
            (1, 8186707 ,2252654),
            (1, 8186707 ,2252780),
            (1, 8186707 ,2253147),
            (1, 8186707 ,2253207),
            (1, 8221090 ,2284709),
            (1, 8221090 ,2284787),
            (1, 8376573 ,2245985),
            (1, 8376573 ,2246017),
            (1, 8389586 ,2372141),
            (1, 8483833 ,3635706),
            (1, 8645353 ,2315173),
            (1, 8653640 ,2240506),
            (1, 8653640 ,2773827),
            (1, 8653640 ,2773846),
            (1, 8747180 ,1676385),
            (1, 8776610 ,2318215),
            (1, 8791341 ,2259917),
            (1, 8814635 ,2413929),
            (1, 8814635 ,2413971),
            (1, 8845107 ,2363009),
            (1, 8907765 ,2516338),
            (1, 9076883 ,2266839),
            (1, 9076883 ,2266917),
            (1, 9076883 ,2764429),
            (1, 9076883 ,2764445),
            (1, 9146270 ,3245394),
            (1, 9335315 ,2332378),
            (1, 9376178 ,2862128),
            (1, 9532307 ,2416966),
            (1, 9617019 ,2313680),
            (1, 9624953 ,2310486),
            (1, 9637370 ,2330888),
            (1, 9655409 ,2372072),
            (1, 9741658 ,1604493),
            (1, 9861602 ,2901698),
            (1, 9861602 ,3127115),
            (1, 9866728 ,2403222),
            (1, 9902759 ,3490369),
            (1, 9989714 ,2257242),
            (1, 9989714 ,2257572),
            (1, 10074201  ,2285562),
            (1, 10074201  ,2285611),
            (1, 10074201  ,2285674),
            (1, 10077995  ,2343634),
            (1, 10119175  ,2358339),
            (1, 10119175  ,2358559),
            (1, 10224661  ,2562733),
            (1, 10280600  ,2360485),
            (1, 10329463  ,2357977),
            (1, 10331450  ,2808639),
            (1, 10349081  ,3138864),
            (1, 10349081  ,3420022),
            (1, 10446435  ,5552388),
            (1, 10535322  ,2714049),
            (1, 10535322  ,2714067),
            (1, 10535322  ,2714077),
            (1, 10588647  ,2347909),
            (1, 10595228  ,3661176),
            (1, 10595635  ,2397388),
            (1, 10595635  ,2728631),
            (1, 10646442  ,2899986),
            (1, 10646442  ,2980291),
            (1, 10740228  ,2455812),
            (1, 10753966  ,2256849),
            (1, 11261412  ,3971919),
            (1, 11269090  ,2829068),
            (1, 11269090  ,3364287),
            (1, 11269090  ,3504335),
            (1, 11321598  ,2498840),
            (1, 11381019  ,4838172),
            (1, 11532173  ,3920997),
            (1, 11592095  ,3030736),
            (1, 13314122  ,4432464),
            (1, 80006973  ,1151122),
            (1, 80006973  ,1151130),
            (1, 80501206  ,2466949),
            (2, 832138  ,287667),
            (2, 832138  ,320736),
            (5, 122661  ,15953),
            (5, 234095  ,56705),
            (6, 204773  ,264407),
            (6, 218014  ,238177),
            (7, 345318  ,41206),
            (9, 127779  ,34153),
            (12,  13455 ,31188),
            (12,  119369  ,32108),
            (12,  142620  ,36470),
            (13,  1023  ,62855),
            (13,  137880  ,63266),
            (13,  153672  ,66435),
            (13,  648795  ,153260),
            (14,  123285  ,47312),
            (14,  179558  ,22771),
            (14,  202223  ,19769),
            (16,  156906  ,210248),
            (16,  156906  ,236451),
            (16,  167908  ,153552),
            (16,  446556  ,160582),
            (16,  542237  ,218492))
    GROUP BY t.cdcooper, t.nrdconta, t.nrctremp, r.vldivida;

BEGIN

  FOR rw_lancamentos IN cr_lancamentos LOOP

     BEGIN
       UPDATE cecred.crapepr e
          SET e.vlsdeved = rw_lancamentos.calculado
        WHERE e.cdcooper = rw_lancamentos.cdcooper
          AND e.nrdconta = rw_lancamentos.nrdconta
          AND e.nrctremp = rw_lancamentos.nrctremp;
     EXCEPTION
       WHEN OTHERS THEN
        raise vr_erro;
     END;

     COMMIT;
   END LOOP;

EXCEPTION                                         
  WHEN OTHERS THEN
    ROLLBACK; 
    RAISE_application_error(-20500, 'Erro: ' || SQLERRM);
END;
