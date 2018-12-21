<?
/*!
 * FONTE        : substitui_bem.php
 * CRIAÇÃO      : Maykon D. Granemann (Envolti)
 * DATA CRIAÇÃO : 14/0708/2018
 * OBJETIVO     : Rotina para substitução do bem 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

    $nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ;
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ;
	$tpctrato		= (isset($_POST['tpctrato']))   ? $_POST['tpctrato']   : 0  ;

    $dscatbem 		= (isset($_POST['dscatbem']))   ? $_POST['dscatbem']   : 0  ;
	$dstipbem 		= (isset($_POST['dstipbem']))   ? $_POST['dstipbem']   : 0  ;
	$dsmarbem 		= (isset($_POST['dsmarbem']))   ? $_POST['dsmarbem']   : 0  ;
	$nrmodbem		= (isset($_POST['nrmodbem']))   ? $_POST['nrmodbem']   : 0  ;
	$nranobem		= (isset($_POST['nranobem']))   ? $_POST['nranobem']   : 0  ;
	$dsbemfin		= (isset($_POST['dsbemfin']))   ? $_POST['dsbemfin']   : '' ;
	$vlrdobem 		= (isset($_POST['vlrdobem']))   ? $_POST['vlrdobem']   : 0  ;
	$vlfipbem 		= (isset($_POST['vlfipbem']))   ? $_POST['vlfipbem']   : 0  ;
	$tpchassi		= (isset($_POST['tpchassi']))   ? $_POST['tpchassi']   : 0  ;
	$dschassi		= (isset($_POST['dschassi']))   ? $_POST['dschassi']   : '' ;
	$dscorbem		= (isset($_POST['dscorbem']))   ? $_POST['dscorbem']   : '' ;
	$ufdplaca		= (isset($_POST['ufdplaca']))   ? $_POST['ufdplaca']   : '' ;
	$nrdplaca		= (isset($_POST['nrdplaca']))   ? str_replace('-','',$_POST['nrdplaca']) : '' ;
	$nrrenava		= (isset($_POST['nrrenava']))   ? $_POST['nrrenava']   : 0  ;
	$uflicenc		= (isset($_POST['uflicenc']))   ? $_POST['uflicenc']   : '' ;
	$nrcpfcgc       = (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']   : 0 ;
	$idseqbem		= (isset($_POST['idseqbem']))   ? $_POST['idseqbem']   : 0  ;
    $cdoperad       = (isset($_POST['cdoperad']))   ? $_POST['cdoperad']   : 0  ;
    $nrgravam       = (isset($GLOBALS["nrgravam"])) ? $GLOBALS["nrgravam"] : 0  ;

    $xmlCarregaDados  = "";
    $xmlCarregaDados .= "<Root>";
    $xmlCarregaDados .= " <Dados>";
    $xmlCarregaDados .= "  <nrdconta>" . $nrdconta . "</nrdconta>";
    $xmlCarregaDados .= "  <nrctremp>" . $nrctremp . "</nrctremp>";
    $xmlCarregaDados .= "  <tpctrato>" . $tpctrato . "</tpctrato>";
    $xmlCarregaDados .= "  <dscatbem>" . $dscatbem . "</dscatbem>";
    $xmlCarregaDados .= "  <dstipbem>" . $dstipbem . "</dstipbem>";
    $xmlCarregaDados .= "  <dsmarbem>" . $dsmarbem . "</dsmarbem>";
    $xmlCarregaDados .= "  <nrmodbem>" . $nrmodbem . "</nrmodbem>";
    $xmlCarregaDados .= "  <nranobem>" . $nranobem . "</nranobem>";
    $xmlCarregaDados .= "  <dsbemfin>" . $dsbemfin . "</dsbemfin>";
    $xmlCarregaDados .= "  <vlfipbem>" . $vlfipbem . "</vlfipbem>";
    $xmlCarregaDados .= "  <vlrdobem>" . $vlrdobem . "</vlrdobem>";
    $xmlCarregaDados .= "  <tpchassi>" . $tpchassi . "</tpchassi>";
    $xmlCarregaDados .= "  <dschassi>" . $dschassi . "</dschassi>";
    $xmlCarregaDados .= "  <dscorbem>" . $dscorbem . "</dscorbem>";
    $xmlCarregaDados .= "  <ufdplaca>" . $ufdplaca . "</ufdplaca>";
    $xmlCarregaDados .= "  <nrdplaca>" . $nrdplaca . "</nrdplaca>";
    $xmlCarregaDados .= "  <nrrenava>" . $nrrenava . "</nrrenava>";
    $xmlCarregaDados .= "  <uflicenc>" . $uflicenc . "</uflicenc>";
    $xmlCarregaDados .= "  <nrcpfcgc>" . $nrcpfcgc . "</nrcpfcgc>";
    $xmlCarregaDados .= "  <idseqbem>" . $idseqbem . "</idseqbem>";
    $xmlCarregaDados .= "  <cdopeapr>" . $cdoperad . "</cdopeapr>";
    $xmlCarregaDados .= "  <nrgravam>" . $nrgravam . "</nrgravam>";
    $xmlCarregaDados .= " </Dados>";
    $xmlCarregaDados .= "</Root>";

    $xmlResultAlteracao = mensageria($xmlCarregaDados
                        ,"TELA_ADITIV"
                        ,"GRAVA_ADT_TP5"
                        ,$glbvars["cdcooper"]
                        ,$glbvars["cdagenci"]
                        ,$glbvars["nrdcaixa"]
                        ,$glbvars["idorigem"]
                        ,$glbvars["cdoperad"]
                        ,"</Root>");
    $xmlObjectAlteracao = getObjectXML($xmlResultAlteracao);

    if (strtoupper($xmlObjectAlteracao->roottag->tags[0]->name) == 'ERRO') {
        $msgErro = $xmlObjectAlteracao->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $mtdErro = 'bloqueiaFundo(divRotina);';
        if ($msgErro != "") {
            echo 'intervenienteValidado=false;';
            echo 'showError("error","'.utf8ToHtml($msgErro).'","'.utf8ToHtml('Alerta - Ayllos').'","","$NaN");';
        }
    }
    else{
        echo 'hideMsgAguardo();';
        echo "$('#dtmvtolt', '#frmTipo').val('".$glbvars['dtmvtolt']."');";
        $nraditiv = $xmlObjectAlteracao->roottag->tags[0]->attributes['NRADITIV'];

        echo "nraditiv ='".$nraditiv."';";
        echo "$('select, input', '#frmTipo').desabilitaCampo();";

        echo "$('#table_substitui_bens').hide();";
        echo "trocaBotao( 'imprimir' );";
        echo 'showError("inform","Aditivo contratual gerado com sucesso!","Alerta - Aimaro","");';
		echo '$("#divUsoGenerico").css("visibility", "hidden");';
		echo '$("#divUsoGenerico").html("");	';
		echo 'unblockBackground();';
    }
?>