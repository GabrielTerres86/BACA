<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 04/09/2014
 * OBJETIVO     : Rotina para alteração cadastral da tela CADPRE
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';

    $cdfinemp = (isset($_POST['cdfinemp'])) ? $_POST['cdfinemp'] : '';
    $cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '';
	$nrmcotas = (isset($_POST['nrmcotas'])) ? $_POST['nrmcotas'] : '';
	$dssitdop = (isset($_POST['dssitdop'])) ? $_POST['dssitdop'] : '';
    $qtmescta = (isset($_POST['qtmescta'])) ? $_POST['qtmescta'] : '';
    $qtmesadm = (isset($_POST['qtmesadm'])) ? $_POST['qtmesadm'] : '';
    $qtmesemp = (isset($_POST['qtmesemp'])) ? $_POST['qtmesemp'] : '';
	$nrrevcad = (isset($_POST['nrrevcad'])) ? $_POST['nrrevcad'] : '';
	$vllimmin = (isset($_POST['vllimmin'])) ? converteFloat($_POST['vllimmin']) : '';
	$vllimctr = (isset($_POST['vllimctr'])) ? converteFloat($_POST['vllimctr']) : '';
	$vlmulpli = (isset($_POST['vlmulpli'])) ? converteFloat($_POST['vlmulpli']) : '';
	$vlpercom = (isset($_POST['vlpercom'])) ? $_POST['vlpercom'] : '';
    $vlmaxleg = (isset($_POST['vlmaxleg'])) ? $_POST['vlmaxleg'] : '';

    $vllimcra = (isset($_POST['vllimcra'])) ? converteFloat($_POST['vllimcra']) : '';
	$vllimcrb = (isset($_POST['vllimcrb'])) ? converteFloat($_POST['vllimcrb']) : '';
	$vllimcrc = (isset($_POST['vllimcrc'])) ? converteFloat($_POST['vllimcrc']) : '';
	$vllimcrd = (isset($_POST['vllimcrd'])) ? converteFloat($_POST['vllimcrd']) : '';
	$vllimcre = (isset($_POST['vllimcre'])) ? converteFloat($_POST['vllimcre']) : '';
	$vllimcrf = (isset($_POST['vllimcrf'])) ? converteFloat($_POST['vllimcrf']) : '';
	$vllimcrg = (isset($_POST['vllimcrg'])) ? converteFloat($_POST['vllimcrg']) : '';
	$vllimcrh = (isset($_POST['vllimcrh'])) ? converteFloat($_POST['vllimcrh']) : '';

    $dslstali = (isset($_POST['dslstali'])) ? $_POST['dslstali'] : '';
    $qtdevolu = (isset($_POST['qtdevolu'])) ? $_POST['qtdevolu'] : '';
	$qtdiadev = (isset($_POST['qtdiadev'])) ? $_POST['qtdiadev'] : '';

    $qtctaatr = (isset($_POST['qtctaatr'])) ? $_POST['qtctaatr'] : '';
    $qtepratr = (isset($_POST['qtepratr'])) ? $_POST['qtepratr'] : '';
	$qtestour = (isset($_POST['qtestour'])) ? $_POST['qtestour'] : '';
	$qtdiaest = (isset($_POST['qtdiaest'])) ? $_POST['qtdiaest'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	if ($cddopcao == 'A') {

		// Monta o xml de requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
		$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "   <cdfinemp>".$cdfinemp."</cdfinemp>";
		$xml .= "   <cdlcremp>".$cdlcremp."</cdlcremp>";
		$xml .= "   <nrmcotas>".$nrmcotas."</nrmcotas>";
		$xml .= "   <dssitdop>".$dssitdop."</dssitdop>";
        $xml .= "   <qtmescta>".$qtmescta."</qtmescta>";
        $xml .= "   <qtmesadm>".$qtmesadm."</qtmesadm>";
        $xml .= "   <qtmesemp>".$qtmesemp."</qtmesemp>";
		$xml .= "   <nrrevcad>".$nrrevcad."</nrrevcad>";
		$xml .= "   <vllimmin>".$vllimmin."</vllimmin>";
		$xml .= "   <vllimctr>".$vllimctr."</vllimctr>";
		$xml .= "   <vlmulpli>".$vlmulpli."</vlmulpli>";
		$xml .= "   <vlpercom>".$vlpercom."</vlpercom>";
		$xml .= "   <vlmaxleg>".$vlmaxleg."</vlmaxleg>";
		$xml .= "   <vllimcra>".$vllimcra."</vllimcra>";
		$xml .= "   <vllimcrb>".$vllimcrb."</vllimcrb>";
		$xml .= "   <vllimcrc>".$vllimcrc."</vllimcrc>";
		$xml .= "   <vllimcrd>".$vllimcrd."</vllimcrd>";
		$xml .= "   <vllimcre>".$vllimcre."</vllimcre>";
		$xml .= "   <vllimcrf>".$vllimcrf."</vllimcrf>";
		$xml .= "   <vllimcrg>".$vllimcrg."</vllimcrg>";
		$xml .= "   <vllimcrh>".$vllimcrh."</vllimcrh>";
        $xml .= "   <dslstali>".$dslstali."</dslstali>";
        $xml .= "   <qtdevolu>".$qtdevolu."</qtdevolu>";
        $xml .= "   <qtdiadev>".$qtdiadev."</qtdiadev>";
        $xml .= "   <qtctaatr>".$qtctaatr."</qtctaatr>";
        $xml .= "   <qtepratr>".$qtepratr."</qtepratr>";
        $xml .= "   <qtestour>".$qtestour."</qtestour>";
        $xml .= "   <qtdiaest>".$qtdiaest."</qtdiaest>";
		$xml .= "   <flgconsu>0</flgconsu>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "CADPRE", "CADPRE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
		}

		echo "hideMsgAguardo();";
        echo "fechaRotina($('#divRotina'));";
		echo "estadoInicial();";

	} else if ($cddopcao == 'G') {
        
        $acao = (isset($_POST['acao'])) ? $_POST['acao'] : ''; // B-Bloquear / L-Liberar / G-Gerar
        $idcarga = (isset($_POST['idcarga'])) ? $_POST['idcarga'] : '';
        $nmeacao = "ALTERA_CARGA";

        // Se for para gerar carga
        if ($acao == 'G') {
            $nmeacao = "GERAR_CARGA";
        }

		// Monta o xml de requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
        $xml .= "   <idcarga>".$idcarga."</idcarga>";
        $xml .= "   <acao>".$acao."</acao>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
	
		$xmlResult = mensageria($xml, "CADPRE", $nmeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
			}
			exibirErro('error',$msgErro,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
		}

		echo "hideMsgAguardo();";
        
        switch ($acao) {
            case "B": // Bloquear
                echo 'showError("inform","Carga bloqueada com sucesso.","Alerta - Ayllos","fechaRotina($(\'#divRotina\'));abreTelaGerar();");';
                break;
            case "L": // Liberar
                echo 'showError("inform","Carga liberada com sucesso.","Alerta - Ayllos","fechaRotina($(\'#divRotina\'));abreTelaGerar();");';
                break;
            case "G": // Gerar
                echo 'showError("inform","Aguarde o termino da execucao.","Alerta - Ayllos","fechaRotina($(\'#divRotina\'));abreTelaGerar();");';
                break;
        }

	}
?>