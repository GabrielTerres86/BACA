<?php
/*!
 * FONTE        : alterar_cooperativa.php                    Última alteração:
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Agosto/2016
 * OBJETIVO     : Rotina para alterar dados da cooperativa
 * --------------
 * ALTERAÇÕES   :  17/11/2016 - M172 Atualizacao Telefone - Novo campo (Guilherme/SUPERO)
 *
 *				   21/11/2017 - Inclusão dos campos flintcdc, tpcdccop, Prj. 402 (Jean Michel)
 *
 */
?>

<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

    $nmrescop = (isset($_POST["nmrescop"])) ? $_POST["nmrescop"] : '';
    $nrdocnpj = (isset($_POST["nrdocnpj"])) ? $_POST["nrdocnpj"] : 0;
    $nmextcop = (isset($_POST["nmextcop"])) ? $_POST["nmextcop"] : '';
    $dtcdcnpj = (isset($_POST["dtcdcnpj"])) ? $_POST["dtcdcnpj"] : '';
    $dsendcop = (isset($_POST["dsendcop"])) ? $_POST["dsendcop"] : '';
    $nrendcop = (isset($_POST["nrendcop"])) ? $_POST["nrendcop"] : 0;
    $dscomple = (isset($_POST["dscomple"])) ? $_POST["dscomple"] : '';
    $nmbairro = (isset($_POST["nmbairro"])) ? $_POST["nmbairro"] : '';
    $nrcepend = (isset($_POST["nrcepend"])) ? $_POST["nrcepend"] : 0;
    $nmcidade = (isset($_POST["nmcidade"])) ? $_POST["nmcidade"] : '';
    $cdufdcop = (isset($_POST["cdufdcop"])) ? $_POST["cdufdcop"] : '';
    $nrcxapst = (isset($_POST["nrcxapst"])) ? $_POST["nrcxapst"] : 0;
    $nrtelvoz = (isset($_POST["nrtelvoz"])) ? $_POST["nrtelvoz"] : '';
    $nrtelouv = (isset($_POST["nrtelouv"])) ? $_POST["nrtelouv"] : '';
    $dsendweb = (isset($_POST["dsendweb"])) ? $_POST["dsendweb"] : '';
    $nrtelura = (isset($_POST["nrtelura"])) ? $_POST["nrtelura"] : '';
    $dsdemail = (isset($_POST["dsdemail"])) ? $_POST["dsdemail"] : '';
    $nrtelfax = (isset($_POST["nrtelfax"])) ? $_POST["nrtelfax"] : '';
    $dsdempst = (isset($_POST["dsdempst"])) ? $_POST["dsdempst"] : '';
    $nrtelsac = (isset($_POST["nrtelsac"])) ? $_POST["nrtelsac"] : '';
    $nmtitcop = (isset($_POST["nmtitcop"])) ? $_POST["nmtitcop"] : '';
    $nrcpftit = (isset($_POST["nrcpftit"])) ? $_POST["nrcpftit"] : 0;
    $nmctrcop = (isset($_POST["nmctrcop"])) ? $_POST["nmctrcop"] : '';
    $nrcpfctr = (isset($_POST["nrcpfctr"])) ? $_POST["nrcpfctr"] : 0;
    $nrcrcctr = (isset($_POST["nrcrcctr"])) ? $_POST["nrcrcctr"] : 0;
    $dsemlctr = (isset($_POST["dsemlctr"])) ? $_POST["dsemlctr"] : '';
    $nrrjunta = (isset($_POST["nrrjunta"])) ? $_POST["nrrjunta"] : 0;
    $dtrjunta = (isset($_POST["dtrjunta"])) ? $_POST["dtrjunta"] : '';
    $nrinsest = (isset($_POST["nrinsest"])) ? $_POST["nrinsest"] : 0;
    $nrinsmun = (isset($_POST["nrinsmun"])) ? $_POST["nrinsmun"] : 0;
    $nrlivapl = (isset($_POST["nrlivapl"])) ? $_POST["nrlivapl"] : 0;
    $nrlivcap = (isset($_POST["nrlivcap"])) ? $_POST["nrlivcap"] : 0;
    $nrlivdpv = (isset($_POST["nrlivdpv"])) ? $_POST["nrlivdpv"] : 0;
    $nrlivepr = (isset($_POST["nrlivepr"])) ? $_POST["nrlivepr"] : 0;
    $cdbcoctl = (isset($_POST["cdbcoctl"])) ? $_POST["cdbcoctl"] : 0;
    $cdagebcb = (isset($_POST["cdagebcb"])) ? $_POST["cdagebcb"] : 0;
    $cdagedbb = (isset($_POST["cdagedbb"])) ? $_POST["cdagedbb"] : 0;
    $cdageitg = (isset($_POST["cdageitg"])) ? $_POST["cdageitg"] : 0;
    $cdcnvitg = (isset($_POST["cdcnvitg"])) ? $_POST["cdcnvitg"] : 0;
    $cdmasitg = (isset($_POST["cdmasitg"])) ? $_POST["cdmasitg"] : 0;
    $nrctabbd = (isset($_POST["nrctabbd"])) ? $_POST["nrctabbd"] : 0;
    $nrctactl = (isset($_POST["nrctactl"])) ? $_POST["nrctactl"] : 0;
    $nrctaitg = (isset($_POST["nrctaitg"])) ? $_POST["nrctaitg"] : 0;
    $nrctadbb = (isset($_POST["nrctadbb"])) ? $_POST["nrctadbb"] : 0;
    $nrctacmp = (isset($_POST["nrctacmp"])) ? $_POST["nrctacmp"] : 0;
    $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
    $flgdsirc = (isset($_POST["flgdsirc"])) ? $_POST["flgdsirc"] : 0;
    $flgcrmag = (isset($_POST["flgcrmag"])) ? $_POST["flgcrmag"] : 0;
    $cdagectl = (isset($_POST["cdagectl"])) ? $_POST["cdagectl"] : 0;
    $dstelscr = (isset($_POST["dstelscr"])) ? $_POST["dstelscr"] : '';
    $cdcrdarr = (isset($_POST["cdcrdarr"])) ? $_POST["cdcrdarr"] : 0;
    $cdagsede = (isset($_POST["cdagsede"])) ? $_POST["cdagsede"] : 0;
    $nrctabol = (isset($_POST["nrctabol"])) ? $_POST["nrctabol"] : 0;
    $cdlcrbol = (isset($_POST["cdlcrbol"])) ? $_POST["cdlcrbol"] : 0;
    $vltxinss = (isset($_POST["vltxinss"])) ? $_POST["vltxinss"] : 0;
    $flgargps = (isset($_POST["flgargps"])) ? $_POST["flgargps"] : 0;
    $vldataxa = (isset($_POST["vldataxa"])) ? $_POST["vldataxa"] : 0;
    $nrversao = (isset($_POST["nrversao"])) ? $_POST["nrversao"] : 0;
    $nrconven = (isset($_POST["nrconven"])) ? $_POST["nrconven"] : 0;
    $qttmpsgr = (isset($_POST["qttmpsgr"])) ? $_POST["qttmpsgr"] : '';
    $hrinisac = (isset($_POST["hrinisac"])) ? $_POST["hrinisac"] : '';
    $hrfimsac = (isset($_POST["hrfimsac"])) ? $_POST["hrfimsac"] : '';
    $hriniouv = (isset($_POST["hriniouv"])) ? $_POST["hriniouv"] : '';
    $hrfimouv = (isset($_POST["hrfimouv"])) ? $_POST["hrfimouv"] : '';
    $vltfcxsb = (isset($_POST["vltfcxsb"])) ? $_POST["vltfcxsb"] : 0;
    $vltfcxcb = (isset($_POST["vltfcxcb"])) ? $_POST["vltfcxcb"] : 0;
    $vlrtrfib = (isset($_POST["vlrtrfib"])) ? $_POST["vlrtrfib"] : 0;
    $flrecpct = (isset($_POST["flrecpct"])) ? $_POST["flrecpct"] : 0;
    $flsaqpre = (isset($_POST["flsaqpre"])) ? $_POST["flsaqpre"] : 0;
    $flgcmtlc = (isset($_POST["flgcmtlc"])) ? $_POST["flgcmtlc"] : 0;
    $qtmaxmes = (isset($_POST["qtmaxmes"])) ? $_POST["qtmaxmes"] : 0;
    $qtmeatel = (isset($_POST["qtmeatel"])) ? $_POST["qtmeatel"] : 0;
    $permaxde = (isset($_POST["permaxde"])) ? $_POST["permaxde"] : 0;
    $cdloggrv = (isset($_POST["cdloggrv"])) ? $_POST["cdloggrv"] : '';
    $flgofatr = (isset($_POST["flgofatr"])) ? $_POST["flgofatr"] : 0;
    $qtdiasus = (isset($_POST["qtdiasus"])) ? $_POST["qtdiasus"] : 0;
    $cdcliser = (isset($_POST["cdcliser"])) ? $_POST["cdcliser"] : '';
    $vlmiplco = (isset($_POST["vlmiplco"])) ? $_POST["vlmiplco"] : 0;
    $vlmidbco = (isset($_POST["vlmidbco"])) ? $_POST["vlmidbco"] : 0;
    $cdfingrv = (isset($_POST["cdfingrv"])) ? $_POST["cdfingrv"] : 0;
    $cdsubgrv = (isset($_POST["cdsubgrv"])) ? $_POST["cdsubgrv"] : 0;
    $hriniatr = (isset($_POST["hriniatr"])) ? $_POST["hriniatr"] : '';
    $hrfimatr = (isset($_POST["hrfimatr"])) ? $_POST["hrfimatr"] : '';
    $flgkitbv = (isset($_POST["flgkitbv"])) ? $_POST["flgkitbv"] : 0;
    $hrinigps = (isset($_POST["hrinigps"])) ? $_POST["hrinigps"] : '';
    $hrfimgps = (isset($_POST["hrfimgps"])) ? $_POST["hrfimgps"] : '';
    $hrlimsic = (isset($_POST["hrlimsic"])) ? $_POST["hrlimsic"] : '';
    $dtctrdda = (isset($_POST["dtctrdda"])) ? $_POST["dtctrdda"] : '';
    $nrctrdda = (isset($_POST["nrctrdda"])) ? $_POST["nrctrdda"] : 0;
    $idlivdda = (isset($_POST["idlivdda"])) ? $_POST["idlivdda"] : '';
    $nrfoldda = (isset($_POST["nrfoldda"])) ? $_POST["nrfoldda"] : 0;
    $dslocdda = (isset($_POST["dslocdda"])) ? $_POST["dslocdda"] : '';
    $dsciddda = (isset($_POST["dsciddda"])) ? $_POST["dsciddda"] : '';
    $dtregcob = (isset($_POST["dtregcob"])) ? $_POST["dtregcob"] : '';
    $idregcob = (isset($_POST["idregcob"])) ? $_POST["idregcob"] : 0;
    $idlivcob = (isset($_POST["idlivcob"])) ? $_POST["idlivcob"] : '';
    $nrfolcob = (isset($_POST["nrfolcob"])) ? $_POST["nrfolcob"] : 0;
    $dsloccob = (isset($_POST["dsloccob"])) ? $_POST["dsloccob"] : '';
    $dscidcob = (isset($_POST["dscidcob"])) ? $_POST["dscidcob"] : '';
    $dsnomscr = (isset($_POST["dsnomscr"])) ? $_POST["dsnomscr"] : '';
    $dsemascr = (isset($_POST["dsemascr"])) ? $_POST["dsemascr"] : '';
    $cdagesic = (isset($_POST["cdagesic"])) ? $_POST["cdagesic"] : 0;
    $nrctasic = (isset($_POST["nrctasic"])) ? $_POST["nrctasic"] : 0;
    $cdcrdins = (isset($_POST["cdcrdins"])) ? $_POST["cdcrdins"] : 0;
    $vltarsic = (isset($_POST["vltarsic"])) ? $_POST["vltarsic"] : 0;
    $vltardrf = (isset($_POST["vltardrf"])) ? $_POST["vltardrf"] : 0;
    $hrproces = (isset($_POST["hrproces"])) ? $_POST["hrproces"] : '';
    $hrfinprc = (isset($_POST["hrfinprc"])) ? $_POST["hrfinprc"] : '';
    $dsdircop = (isset($_POST["dsdircop"])) ? $_POST["dsdircop"] : '';
    $dsnotifi = (isset($_POST["dsnotifi"])) ? $_POST["dsnotifi"] : '';
    $nmdireto = (isset($_POST["nmdireto"])) ? $_POST["nmdireto"] : '';
    $flgdopgd = (isset($_POST["flgdopgd"])) ? $_POST["flgdopgd"] : 0;
    $dsclactr = (isset($_POST["dsclactr"])) ? $_POST["dsclactr"] : '';
    $dsclaccb = (isset($_POST["dsclaccb"])) ? $_POST["dsclaccb"] : '';
    $vlmaxcen = (isset($_POST["vlmaxcen"])) ? $_POST["vlmaxcen"] : 0;
    $vlmaxleg = (isset($_POST["vlmaxleg"])) ? $_POST["vlmaxleg"] : 0;
    $vlmaxutl = (isset($_POST["vlmaxutl"])) ? $_POST["vlmaxutl"] : 0;
    $vlcnsscr = (isset($_POST["vlcnsscr"])) ? $_POST["vlcnsscr"] : 0;
    $vllimmes = (isset($_POST["vllimmes"])) ? $_POST["vllimmes"] : 0;
    $qtdiaenl = (isset($_POST["qtdiaenl"])) ? $_POST["qtdiaenl"] : 0;
    $cdsinfmg = (isset($_POST["cdsinfmg"])) ? $_POST["cdsinfmg"] : 0;
    $taamaxer = (isset($_POST["taamaxer"])) ? $_POST["taamaxer"] : 0;
		$flintcdc = (isset($_POST["flintcdc"])) ? $_POST["flintcdc"] : 0;
		$tpcdccop = (isset($_POST["tpcdccop"])) ? $_POST["tpcdccop"] : 0;
    $vllimapv = (isset($_POST["vllimapv"])) ? $_POST["vllimapv"] : 0;

    validaDados();

    // Monta o xml de requisição
    $xml        = "";
    $xml       .= "<Root>";
    $xml       .= "  <Dados>";
    $xml     .="       <cddopcao>".$cddopcao."</cddopcao>";
    $xml     .="       <cddepart>".$glbvars['cddepart']."</cddepart>";
    $xml     .="       <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
    $xml     .="       <nmrescop>".$nmrescop."</nmrescop>";
    $xml     .="       <nrdocnpj>".$nrdocnpj."</nrdocnpj>";
    $xml     .="       <nmextcop>".$nmextcop."</nmextcop>";
    $xml     .="       <dtcdcnpj>".$dtcdcnpj."</dtcdcnpj>";
    $xml     .="       <dsendcop>".$dsendcop."</dsendcop>";
    $xml     .="       <nrendcop>".$nrendcop."</nrendcop>";
    $xml     .="       <dscomple>".$dscomple."</dscomple>";
    $xml     .="       <nmbairro>".$nmbairro."</nmbairro>";
    $xml     .="       <nrcepend>".$nrcepend."</nrcepend>";
    $xml     .="       <nmcidade>".$nmcidade."</nmcidade>";
    $xml     .="       <cdufdcop>".$cdufdcop."</cdufdcop>";
    $xml     .="       <nrcxapst>".$nrcxapst."</nrcxapst>";
    $xml     .="       <nrtelvoz>".$nrtelvoz."</nrtelvoz>";
    $xml     .="       <nrtelouv>".$nrtelouv."</nrtelouv>";
    $xml     .="       <dsendweb>".$dsendweb."</dsendweb>";
    $xml     .="       <nrtelura>".$nrtelura."</nrtelura>";
    $xml     .="       <dsdemail>".$dsdemail."</dsdemail>";
    $xml     .="       <nrtelfax>".$nrtelfax."</nrtelfax>";
    $xml     .="       <dsdempst>".$dsdempst."</dsdempst>";
    $xml     .="       <nrtelsac>".$nrtelsac."</nrtelsac>";
    $xml     .="       <nmtitcop>".$nmtitcop."</nmtitcop>";
    $xml     .="       <nrcpftit>".$nrcpftit."</nrcpftit>";
    $xml     .="       <nmctrcop>".$nmctrcop."</nmctrcop>";
    $xml     .="       <nrcpfctr>".$nrcpfctr."</nrcpfctr>";
    $xml     .="       <nrcrcctr>".$nrcrcctr."</nrcrcctr>";
    $xml     .="       <dsemlctr>".$dsemlctr."</dsemlctr>";
    $xml     .="       <nrrjunta>".$nrrjunta."</nrrjunta>";
    $xml     .="       <dtrjunta>".$dtrjunta."</dtrjunta>";
    $xml     .="       <nrinsest>".$nrinsest."</nrinsest>";
    $xml     .="       <nrinsmun>".$nrinsmun."</nrinsmun>";
    $xml     .="       <nrlivapl>".$nrlivapl."</nrlivapl>";
    $xml     .="       <nrlivcap>".$nrlivcap."</nrlivcap>";
    $xml     .="       <nrlivdpv>".$nrlivdpv."</nrlivdpv>";
    $xml     .="       <nrlivepr>".$nrlivepr."</nrlivepr>";
    $xml     .="       <cdbcoctl>".$cdbcoctl."</cdbcoctl>";
    $xml     .="       <cdagebcb>".$cdagebcb."</cdagebcb>";
    $xml     .="       <cdagedbb>".$cdagedbb."</cdagedbb>";
    $xml     .="       <cdageitg>".$cdageitg."</cdageitg>";
    $xml     .="       <cdcnvitg>".$cdcnvitg."</cdcnvitg>";
    $xml     .="       <cdmasitg>".$cdmasitg."</cdmasitg>";
    $xml     .="       <nrctabbd>".$nrctabbd."</nrctabbd>";
    $xml     .="       <nrctactl>".$nrctactl."</nrctactl>";
    $xml     .="       <nrctaitg>".$nrctaitg."</nrctaitg>";
    $xml     .="       <nrctadbb>".$nrctadbb."</nrctadbb>";
    $xml     .="       <nrctacmp>".$nrctacmp."</nrctacmp>";
    $xml     .="       <nrdconta>".$nrdconta."</nrdconta>";
    $xml     .="       <flgdsirc>".$flgdsirc."</flgdsirc>";
    $xml     .="       <flgcrmag>".$flgcrmag."</flgcrmag>";
    $xml     .="       <cdagectl>".$cdagectl."</cdagectl>";
    $xml     .="       <dstelscr>".$dstelscr."</dstelscr>";
    $xml     .="       <cdcrdarr>".$cdcrdarr."</cdcrdarr>";
    $xml     .="       <cdagsede>".$cdagsede."</cdagsede>";
    $xml     .="       <nrctabol>".$nrctabol."</nrctabol>";
    $xml     .="       <cdlcrbol>".$cdlcrbol."</cdlcrbol>";
    $xml     .="       <vltxinss>".$vltxinss."</vltxinss>";
    $xml     .="       <flgargps>".$flgargps."</flgargps>";
    $xml     .="       <vldataxa>".$vldataxa."</vldataxa>";
    $xml     .="       <nrversao>".$nrversao."</nrversao>";
    $xml     .="       <nrconven>".$nrconven."</nrconven>";
    $xml     .="       <qttmpsgr>".$qttmpsgr."</qttmpsgr>";
    $xml     .="       <hrinisac>".$hrinisac."</hrinisac>";
    $xml     .="       <hrfimsac>".$hrfimsac."</hrfimsac>";
    $xml     .="       <hriniouv>".$hriniouv."</hriniouv>";
    $xml     .="       <hrfimouv>".$hrfimouv."</hrfimouv>";
    $xml     .="       <vltfcxsb>".$vltfcxsb."</vltfcxsb>";
    $xml     .="       <vltfcxcb>".$vltfcxcb."</vltfcxcb>";
    $xml     .="       <vlrtrfib>".$vlrtrfib."</vlrtrfib>";
    $xml     .="       <flrecpct>".$flrecpct."</flrecpct>";
    $xml     .="       <flsaqpre>".$flsaqpre."</flsaqpre>";
    $xml     .="       <flgcmtlc>".$flgcmtlc."</flgcmtlc>";
    $xml     .="       <qtmaxmes>".$qtmaxmes."</qtmaxmes>";
    $xml     .="       <qtmeatel>".$qtmeatel."</qtmeatel>";
    $xml     .="       <permaxde>".$permaxde."</permaxde>";
    $xml     .="       <cdloggrv>".$cdloggrv."</cdloggrv>";
    $xml     .="       <flgofatr>".$flgofatr."</flgofatr>";
    $xml     .="       <qtdiasus>".$qtdiasus."</qtdiasus>";
    $xml     .="       <cdcliser>".$cdcliser."</cdcliser>";
    $xml     .="       <vlmiplco>".$vlmiplco."</vlmiplco>";
    $xml     .="       <vlmidbco>".$vlmidbco."</vlmidbco>";
    $xml     .="       <cdfingrv>".$cdfingrv."</cdfingrv>";
    $xml     .="       <cdsubgrv>".$cdsubgrv."</cdsubgrv>";
    $xml     .="       <hriniatr>".$hriniatr."</hriniatr>";
    $xml     .="       <hrfimatr>".$hrfimatr."</hrfimatr>";
    $xml     .="       <flgkitbv>".$flgkitbv."</flgkitbv>";
    $xml     .="       <hrinigps>".$hrinigps."</hrinigps>";
    $xml     .="       <hrfimgps>".$hrfimgps."</hrfimgps>";
    $xml     .="       <hrlimsic>".$hrlimsic."</hrlimsic>";
    $xml     .="       <dtctrdda>".$dtctrdda."</dtctrdda>";
    $xml     .="       <nrctrdda>".$nrctrdda."</nrctrdda>";
    $xml     .="       <idlivdda>".$idlivdda."</idlivdda>";
    $xml     .="       <nrfoldda>".$nrfoldda."</nrfoldda>";
    $xml     .="       <dslocdda>".$dslocdda."</dslocdda>";
    $xml     .="       <dsciddda>".$dsciddda."</dsciddda>";
    $xml     .="       <dtregcob>".$dtregcob."</dtregcob>";
    $xml     .="       <idregcob>".$idregcob."</idregcob>";
    $xml     .="       <idlivcob>".$idlivcob."</idlivcob>";
    $xml     .="       <nrfolcob>".$nrfolcob."</nrfolcob>";
    $xml     .="       <dsloccob>".$dsloccob."</dsloccob>";
    $xml     .="       <dscidcob>".$dscidcob."</dscidcob>";
    $xml     .="       <dsnomscr>".$dsnomscr."</dsnomscr>";
    $xml     .="       <dsemascr>".$dsemascr."</dsemascr>";
    $xml     .="       <cdagesic>".$cdagesic."</cdagesic>";
    $xml     .="       <nrctasic>".$nrctasic."</nrctasic>";
    $xml     .="       <cdcrdins>".$cdcrdins."</cdcrdins>";
    $xml     .="       <vltarsic>".$vltarsic."</vltarsic>";
    $xml     .="       <vltardrf>".$vltardrf."</vltardrf>";
    $xml     .="       <hrproces>".$hrproces."</hrproces>";
    $xml     .="       <hrfinprc>".$hrfinprc."</hrfinprc>";
    $xml     .="       <dsdircop>".$dsdircop."</dsdircop>";
    $xml     .="       <dsnotifi>".$dsnotifi."</dsnotifi>";
    $xml     .="       <nmdireto>".$nmdireto."</nmdireto>";
    $xml     .="       <flgdopgd>".$flgdopgd."</flgdopgd>";
    $xml     .="       <dsclactr>".$dsclactr."</dsclactr>";
    $xml     .="       <dsclaccb>".$dsclaccb."</dsclaccb>";
    $xml     .="       <vlmaxcen>".$vlmaxcen."</vlmaxcen>";
    $xml     .="       <vlmaxleg>".$vlmaxleg."</vlmaxleg>";
    $xml     .="       <vlmaxutl>".$vlmaxutl."</vlmaxutl>";
    $xml     .="       <vlcnsscr>".$vlcnsscr."</vlcnsscr>";
    $xml     .="       <vllimmes>".$vllimmes."</vllimmes>";
    $xml     .="       <qtdiaenl>".$qtdiaenl."</qtdiaenl>";
    $xml     .="       <cdsinfmg>".$cdsinfmg."</cdsinfmg>";
    $xml     .="       <taamaxer>".$taamaxer."</taamaxer>";
    $xml     .="       <vllimapv>".$vllimapv."</vllimapv>";		
		$xml     .="       <flintcdc>".$flintcdc."</flintcdc>";
    $xml     .="       <tpcdccop>".$tpcdccop."</tpcdccop>";
    $xml       .= "  </Dados>";
    $xml       .= "</Root>";

    // Executa script para envio do XML
    $xmlResult = mensageria($xml, "TELA_CADCOP", "ALTCOOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {

        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

    $nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];

        if(empty ($nmdcampo)){
            $nmdcampo = "nmrescop";
        }

        exibirErro('error',$msgErro,'Alerta - Ayllos','controlaFoco(\''.$nmdcampo.'\');',false);

    }

    exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','estadoInicial();', false);


    function validaDados(){

        //CNPJ da cooperativa
        if ( $GLOBALS["nrdocnpj"] == 0){
                exibirErro('error','CNPJ da Cooperativa deve ser informado.','Alerta - Ayllos','controlaFoco(\'nrdocnpj\');',false);
            }

        //UF da cooperativa
        if ( $GLOBALS["cdufdcop"] == ''){
                exibirErro('error','Unidade de federa&ccedil;&atiolde;o deve ser informado.','Alerta - Ayllos','controlaFoco(\'cdufdcop\');',false);
            }

        //Telefone da cooperativa
        if ( $GLOBALS["nrtelvoz"] == ''){
                exibirErro('error','Telefone da cooperativa deve ser informado.','Alerta - Ayllos','controlaFoco(\'nrtelvoz\');',false);
            }

        //CPF do presidente da cooperativa
        if ( $GLOBALS["nrcpftit"] == 0){
                exibirErro('error','CPF do presidente deve ser informado.','Alerta - Ayllos','controlaFoco(\'nrcpftit\');',false);
            }

        //CPF do contador da cooperativa
        if ( $GLOBALS["nrcpfctr"] == 0){
                exibirErro('error','CPF do contador deve ser informado.','Alerta - Ayllos','controlaFoco(\'nrcpfctr\');',false);
            }

        //Tipo invalido
        if ( $GLOBALS["cdsinfmg"] != 0 && $GLOBALS["cdsinfmg"] != 1 && $GLOBALS["cdsinfmg"] != 2){
                exibirErro('error','Tipo invalido.','Alerta - Ayllos','controlaFoco(\'cdsinfmg\');',false);
            }

        //Nome do responsável
        if ( $GLOBALS["dsnomscr"] == ''){
                exibirErro('error','Informe o nome do respons&aacute;vel.','Alerta - Ayllos','controlaFoco(\'dsnomscr\');',false);
            }

        //E-mail do responsável
        if ( $GLOBALS["dsemascr"] == ''){
                exibirErro('error','Informe o e-mail do respons&aacute;vel.','Alerta - Ayllos','controlaFoco(\'dsemascr\', \'divTabela\');',false);
            }

        //Telefone do responsável
        if ( $GLOBALS["dstelscr"] == ''){
                exibirErro('error','Informe o telefone do respons&aacute;vel.','Alerta - Ayllos','controlaFoco(\'dstelscr\', \'divTabela\');',false);
            }

    }

 ?>
