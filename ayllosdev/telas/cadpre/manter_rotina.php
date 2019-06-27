<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 04/09/2014
 * OBJETIVO     : Rotina para alteração cadastral da tela CADPRE
 * --------------
 * ALTERAÇÕES   : 11/07/2016 - Adicionados novos campos para a fase 3 do projeto de Pre aprovado. (Lombardi)
 *
 *				  06/02/2019 - Petter - Envolti. Ajustar novos campos e refatorar funcionalidades para o projeto 442.
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
	$vllimmin = (isset($_POST['vllimmin'])) ? converteFloat($_POST['vllimmin']) : '';
	$vllimctr = (isset($_POST['vllimctr'])) ? converteFloat($_POST['vllimctr']) : '';
	$vlmulpli = (isset($_POST['vlmulpli'])) ? converteFloat($_POST['vlmulpli']) : '';
	$vllimman = (isset($_POST['vllimman'])) ? converteFloat($_POST['vllimman']) : '';
	$vllimaut = (isset($_POST['vllimaut'])) ? converteFloat($_POST['vllimaut']) : '';
	$dslstali = (isset($_POST['dslstali'])) ? $_POST['dslstali'] : '';
    $qtdevolu = (isset($_POST['qtdevolu'])) ? $_POST['qtdevolu'] : '';
	$qtdiadev = (isset($_POST['qtdiadev'])) ? $_POST['qtdiadev'] : '';
    $qtctaatr = (isset($_POST['qtctaatr'])) ? $_POST['qtctaatr'] : '';
    $qtepratr = (isset($_POST['qtepratr'])) ? $_POST['qtepratr'] : '';
	$qtestour = (isset($_POST['qtestour'])) ? $_POST['qtestour'] : '';
	$qtdiaest = (isset($_POST['qtdiaest'])) ? $_POST['qtdiaest'] : '';
	$vldiaest = (isset($_POST['vldiaest'])) ? converteFloat($_POST['vldiaest']) : '';
	$qtavlatr = (isset($_POST['qtavlatr'])) ? $_POST['qtavlatr'] : '';
	$vlavlatr = (isset($_POST['vlavlatr'])) ? converteFloat($_POST['vlavlatr']) : '';
	$qtavlope = (isset($_POST['qtavlope'])) ? $_POST['qtavlope'] : '';
	$qtcjgatr = (isset($_POST['qtcjgatr'])) ? $_POST['qtcjgatr'] : '';
	$vlcjgatr = (isset($_POST['vlcjgatr'])) ? converteFloat($_POST['vlcjgatr']) : '';
	$qtcjgope = (isset($_POST['qtcjgope'])) ? $_POST['qtcjgope'] : '';
	$qtdiavig = (isset($_POST['qtdiavig'])) ? $_POST['qtdiavig'] : '';
	$vldiadev = (isset($_POST['vldiadev'])) ? converteFloat($_POST['vldiadev']) : '';
	$vlctaatr = (isset($_POST['vlctaatr'])) ? converteFloat($_POST['vlctaatr']) : '';
	$vlepratr = (isset($_POST['vlepratr'])) ? converteFloat($_POST['vlepratr']) : '';
	$qtcarcre = (isset($_POST['qtcarcre'])) ? $_POST['qtcarcre'] : '';
	$vlcarcre = (isset($_POST['vlcarcre'])) ? converteFloat($_POST['vlcarcre']) : '';
	$qtdtitul = (isset($_POST['qtdtitul'])) ? $_POST['qtdtitul'] : '';
	$vltitulo = (isset($_POST['vltitulo'])) ? converteFloat($_POST['vltitulo']) : '';

	if ($cddopcao == 'A') {

		// Monta o xml de requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
		$xml .= "   <cdfinemp>".$cdfinemp."</cdfinemp>";
		$xml .= "   <vllimmin>".$vllimmin."</vllimmin>";
		$xml .= "   <vllimctr>".$vllimctr."</vllimctr>";
		$xml .= "   <vlmulpli>".$vlmulpli."</vlmulpli>";
		$xml .= "   <vllimman>".$vllimman."</vllimman>";
		$xml .= "   <vllimaut>".$vllimaut."</vllimaut>";
		$xml .= "   <qtdiavig>".$qtdiavig."</qtdiavig>";
        $xml .= "   <dslstali>".$dslstali."</dslstali>";
        $xml .= "   <qtdevolu>".$qtdevolu."</qtdevolu>";
        $xml .= "   <qtdiadev>".$qtdiadev."</qtdiadev>";
		$xml .= "   <vldiadev>".$vldiadev."</vldiadev>";
        $xml .= "   <qtctaatr>".$qtctaatr."</qtctaatr>";
		$xml .= "   <vlctaatr>".$vlctaatr."</vlctaatr>";
        $xml .= "   <qtepratr>".$qtepratr."</qtepratr>";
		$xml .= "   <vlepratr>".$vlepratr."</vlepratr>";
        $xml .= "   <qtestour>".$qtestour."</qtestour>";
        $xml .= "   <qtdiaest>".$qtdiaest."</qtdiaest>";
		$xml .= "   <vldiaest>".$vldiaest."</vldiaest>";
        $xml .= "   <qtavlatr>".$qtavlatr."</qtavlatr>";
        $xml .= "   <vlavlatr>".$vlavlatr."</vlavlatr>";
        $xml .= "   <qtavlope>".$qtavlope."</qtavlope>";
        $xml .= "   <qtcjgatr>".$qtcjgatr."</qtcjgatr>";
        $xml .= "   <vlcjgatr>".$vlcjgatr."</vlcjgatr>";
        $xml .= "   <qtcjgope>".$qtcjgope."</qtcjgope>";
		$xml .= "   <qtcarcre>".$qtcarcre."</qtcarcre>";
		$xml .= "   <vlcarcre>".$vlcarcre."</vlcarcre>";
        $xml .= "   <qtdtitul>".$qtdtitul."</qtdtitul>";
        $xml .= "   <vltitulo>".$vltitulo."</vltitulo>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "CADPRE", "GRAVA_CRAPPRE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	}
?>