<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 04/09/2014
 * OBJETIVO     : Rotina para alteração cadastral da tela CADPRE
 * --------------
 * ALTERAÇÕES   : 11/07/2016 - Adicionados novos campos para a fase 3 do projeto de Pre aprovado. (Lombardi)
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
	$qtdiaver = (isset($_POST['qtdiaver'])) ? converteFloat($_POST['qtdiaver']) : '0';
    $vlmaxleg = (isset($_POST['vlmaxleg'])) ? $_POST['vlmaxleg'] : '';
    $qtmesblq = (isset($_POST['qtmesblq'])) ? converteFloat($_POST['qtmesblq']) : '0';
	
    $vllimite_A = (isset($_POST['vllimite_A'])) ? converteFloat($_POST['vllimite_A']) : '';
	$vllimite_B = (isset($_POST['vllimite_B'])) ? converteFloat($_POST['vllimite_B']) : '';
	$vllimite_C = (isset($_POST['vllimite_C'])) ? converteFloat($_POST['vllimite_C']) : '';
	$vllimite_D = (isset($_POST['vllimite_D'])) ? converteFloat($_POST['vllimite_D']) : '';
	$vllimite_E = (isset($_POST['vllimite_E'])) ? converteFloat($_POST['vllimite_E']) : '';
	$vllimite_F = (isset($_POST['vllimite_F'])) ? converteFloat($_POST['vllimite_F']) : '';
	$vllimite_G = (isset($_POST['vllimite_G'])) ? converteFloat($_POST['vllimite_G']) : '';
	$vllimite_H = (isset($_POST['vllimite_H'])) ? converteFloat($_POST['vllimite_H']) : '';
	
    $cdlcremp_A = (isset($_POST['cdlcremp_A'])) ? $_POST['cdlcremp_A'] : '';
	$cdlcremp_B = (isset($_POST['cdlcremp_B'])) ? $_POST['cdlcremp_B'] : '';
	$cdlcremp_C = (isset($_POST['cdlcremp_C'])) ? $_POST['cdlcremp_C'] : '';
	$cdlcremp_D = (isset($_POST['cdlcremp_D'])) ? $_POST['cdlcremp_D'] : '';
	$cdlcremp_E = (isset($_POST['cdlcremp_E'])) ? $_POST['cdlcremp_E'] : '';
	$cdlcremp_F = (isset($_POST['cdlcremp_F'])) ? $_POST['cdlcremp_F'] : '';
	$cdlcremp_G = (isset($_POST['cdlcremp_G'])) ? $_POST['cdlcremp_G'] : '';
	$cdlcremp_H = (isset($_POST['cdlcremp_H'])) ? $_POST['cdlcremp_H'] : '';
	
    $dslstali = (isset($_POST['dslstali'])) ? $_POST['dslstali'] : '';
    $qtdevolu = (isset($_POST['qtdevolu'])) ? $_POST['qtdevolu'] : '';
	$qtdiadev = (isset($_POST['qtdiadev'])) ? $_POST['qtdiadev'] : '';
	
    $qtctaatr = (isset($_POST['qtctaatr'])) ? $_POST['qtctaatr'] : '';
    $qtepratr = (isset($_POST['qtepratr'])) ? $_POST['qtepratr'] : '';
	$qtestour = (isset($_POST['qtestour'])) ? $_POST['qtestour'] : '';
	$qtdiaest = (isset($_POST['qtdiaest'])) ? $_POST['qtdiaest'] : '';
	$qtavlatr = (isset($_POST['qtavlatr'])) ? $_POST['qtavlatr'] : '';
	$vlavlatr = (isset($_POST['vlavlatr'])) ? converteFloat($_POST['vlavlatr']) : '';
	$qtavlope = (isset($_POST['qtavlope'])) ? $_POST['qtavlope'] : '';
	$qtcjgatr = (isset($_POST['qtcjgatr'])) ? $_POST['qtcjgatr'] : '';
	$vlcjgatr = (isset($_POST['vlcjgatr'])) ? converteFloat($_POST['vlcjgatr']) : '';
	$qtcjgope = (isset($_POST['qtcjgope'])) ? $_POST['qtcjgope'] : '';
/*
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
*/
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
		$xml .= "   <qtdiaver>".$qtdiaver."</qtdiaver>";
		$xml .= "   <vlmaxleg>".$vlmaxleg."</vlmaxleg>";
		$xml .= "   <qtmesblq>".$qtmesblq."</qtmesblq>";
		$xml .= " <vllimite_a>".$vllimite_A."</vllimite_a>";
		$xml .= " <vllimite_b>".$vllimite_B."</vllimite_b>";
		$xml .= " <vllimite_c>".$vllimite_C."</vllimite_c>";
		$xml .= " <vllimite_d>".$vllimite_D."</vllimite_d>";
		$xml .= " <vllimite_e>".$vllimite_E."</vllimite_e>";
		$xml .= " <vllimite_f>".$vllimite_F."</vllimite_f>";
		$xml .= " <vllimite_g>".$vllimite_G."</vllimite_g>";
		$xml .= " <vllimite_h>".$vllimite_H."</vllimite_h>";
		$xml .= " <cdlcremp_a>".$cdlcremp_A."</cdlcremp_a>";
		$xml .= " <cdlcremp_b>".$cdlcremp_B."</cdlcremp_b>";
		$xml .= " <cdlcremp_c>".$cdlcremp_C."</cdlcremp_c>";
		$xml .= " <cdlcremp_d>".$cdlcremp_D."</cdlcremp_d>";
		$xml .= " <cdlcremp_e>".$cdlcremp_E."</cdlcremp_e>";
		$xml .= " <cdlcremp_f>".$cdlcremp_F."</cdlcremp_f>";
		$xml .= " <cdlcremp_g>".$cdlcremp_G."</cdlcremp_g>";
		$xml .= " <cdlcremp_h>".$cdlcremp_H."</cdlcremp_h>";
        $xml .= "   <dslstali>".$dslstali."</dslstali>";
        $xml .= "   <qtdevolu>".$qtdevolu."</qtdevolu>";
        $xml .= "   <qtdiadev>".$qtdiadev."</qtdiadev>";
        $xml .= "   <qtctaatr>".$qtctaatr."</qtctaatr>";
        $xml .= "   <qtepratr>".$qtepratr."</qtepratr>";
        $xml .= "   <qtestour>".$qtestour."</qtestour>";
        $xml .= "   <qtdiaest>".$qtdiaest."</qtdiaest>";
        $xml .= "   <qtavlatr>".$qtavlatr."</qtavlatr>";
        $xml .= "   <vlavlatr>".$vlavlatr."</vlavlatr>";
        $xml .= "   <qtavlope>".$qtavlope."</qtavlope>";
        $xml .= "   <qtcjgatr>".$qtcjgatr."</qtcjgatr>";
        $xml .= "   <vlcjgatr>".$vlcjgatr."</vlcjgatr>";
        $xml .= "   <qtcjgope>".$qtcjgope."</qtcjgope>";
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
			exibirErro('error',$msgErro,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
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
			exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
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
                echo 'showError("inform","Espere o t&eacute;rmino da execu&ccedil;&atilde;o.","Alerta - Ayllos","fechaRotina($(\'#divRotina\'));abreTelaGerar();");';
                break;
        }

	}
?>
