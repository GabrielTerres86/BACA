BEGIN
  INSERT INTO crapcob
    (DTMVTOLT
    ,INCOBRAN
    ,NRDCONTA
    ,NRDCTABB
    ,CDBANDOC
    ,NRDOCMTO
    ,DTRETCOB
    ,NRCNVCOB
    ,CDOPERAD
    ,HRTRANSA
    ,CDCOOPER
    ,INDPAGTO
    ,DTDPAGTO
    ,VLDPAGTO
    ,VLTITULO
    ,DSINFORM
    ,DSDINSTR
    ,DTVENCTO
    ,CDCARTEI
    ,CDDESPEC
    ,CDTPINSC
    ,NMDSACAD
    ,DSENDSAC
    ,NMBAISAC
    ,NRCEPSAC
    ,NMCIDSAC
    ,CDUFSACA
    ,CDTPINAV
    ,CDIMPCOB
    ,FLGIMPRE
    ,NRINSAVA
    ,NRINSSAC
    ,NMDAVALI
    ,NRDOCCOP
    ,VLDESCTO
    ,CDMENSAG
    ,DSDOCCOP
    ,IDSEQTTL
    ,DTELIMIN
    ,DTDBAIXA
    ,VLABATIM
    ,VLTARIFA
    ,CDAGEPAG
    ,CDBANPAG
    ,DTDOCMTO
    ,NRCTASAC
    ,NRCTREMP
    ,NRNOSNUM
    ,INSITCRT
    ,DTSITCRT
    ,NRSEQTIT
    ,FLGDPROT
    ,QTDIAPRT
    ,INDIAPRT
    ,VLJURDIA
    ,VLRMULTA
    ,FLGACEIT
    ,DSUSOEMP
    ,FLGREGIS
    ,DTLIMDSC
    ,INEMITEN
    ,TPJURMOR
    ,VLOUTCRE
    ,TPDMULTA
    ,VLOUTDEB
    ,FLGCBDDA
    ,VLMULPAG
    ,VLJURPAG
    ,IDTITLEG
    ,IDOPELEG
    ,INSITPRO
    ,NRREMASS
    ,CDTITPRT
    ,DCMC7CHQ
    ,INEMIEXP
    ,DTEMIEXP
    ,FLSERASA
    ,QTDIANEG
    ,INSERASA
    ,DTRETSER
    ,DTBLOQUE
    ,INPAGDIV
    ,VLMINIMO
    ,NRDIDENT
    ,DHENVCIP
    ,INENVCIP
    ,NRISPBRC
    ,INREGCIP
    ,NRATUTIT
    ,DTVCTORI
    ,INAVISMS
    ,INSMSANT
    ,INSMSVCT
    ,INSMSPOS
    ,DTREFATU
    ,ININSCIP
    ,DHINSCIP
    ,INSRVPRT
    ,TPVLRDESC
    ,IDLOTTCK
    ,INFMTDOC
    ,DTLIPGTO)
  VALUES
    (to_date('03-06-2024', 'dd-mm-yyyy')
    ,0
    ,99999005
    ,108004
    ,85
    ,2508935
    ,NULL
    ,108004
    ,'996'
    ,0
    ,9
    ,0
    ,NULL
    ,0.00
    ,1083.97
    ,'0'
    ,' '
    ,to_date('14-06-2024', 'dd-mm-yyyy')
    ,1
    ,1
    ,2
    ,' '
    ,'AVENIDA LAVINIA DA COSTA, 659'
    ,' '
    ,0
    ,' '
    ,' '
    ,0
    ,3
    ,1
    ,0.00
    ,33618396000194.00
    ,' '
    ,0.00
    ,0.00
    ,0
    ,'2508935'
    ,1
    ,NULL
    ,NULL
    ,0.00
    ,0.00
    ,0
    ,0
    ,to_date('31-05-2024', 'dd-mm-yyyy')
    ,0
    ,0
    ,'00000930002508935'
    ,0
    ,NULL
    ,0
    ,0
    ,0
    ,3
    ,8.00
    ,0.00
    ,0
    ,' '
    ,1
    ,NULL
    ,1
    ,2
    ,0.00
    ,3
    ,0.00
    ,1
    ,0.00
    ,0.00
    ,136753368
    ,228177294
    ,3
    ,0
    ,' '
    ,' '
    ,0
    ,NULL
    ,0
    ,0
    ,0
    ,NULL
    ,NULL
    ,0
    ,0.00
    ,'3024060307427409799'
    ,to_date('03-06-2024 11:01:59', 'dd-mm-yyyy hh24:mi:ss')
    ,3
    ,0
    ,1
    ,'1717423233058000603'
    ,to_date('14-06-2024', 'dd-mm-yyyy')
    ,0
    ,1
    ,1
    ,1
    ,to_date('03-06-2024', 'dd-mm-yyyy')
    ,0
    ,NULL
    ,0
    ,3
    ,'947AF1ABAC984EE3A731B18400B4E2D8'
    ,1
    ,to_date('12-08-2024', 'dd-mm-yyyy'));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'DMND0005923');
    RAISE;
END;