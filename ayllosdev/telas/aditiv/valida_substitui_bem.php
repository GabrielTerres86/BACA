<?
/*!
 * FONTE        : manter_rotina.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 28/07/2011
 * OBJETIVO     : Rotina para manter as opera��es da tela EXTPPR
 * --------------
 * ALTERA��ES   :
 * --------------
 *   001 [28/02/2014] Guilherme(SUPERO)         : Novos campos NrCpfCgc e valida��es.
 *	 002 [11/12/2014] Lucas Reinert(CECRED)		: Adicionado campos tpproapl e novo parametro na function arrayTipo
 *   003 [01/11/2017] Passagem do tpctrato e idgaropc. (Jaison/Marcos Martini - PRJ404)
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

  $cddopcao   = (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : '' ;
    $operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : '' ;
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ;
	$nrctremp		= (isset($_POST['nrctremp']))   ? $_POST['nrctremp']   : 0  ;
	$tpctrato		= (isset($_POST['tpctrato']))   ? $_POST['tpctrato']   : 0  ;
	$dscatbem 		= (isset($_POST['dscatbem']))   ? $_POST['dscatbem']   : 0  ;
	$dstipbem 		= (isset($_POST['dstipbem']))   ? $_POST['dstipbem']   : 0  ;
	$nrmodbem		= (isset($_POST['nrmodbem']))   ? $_POST['nrmodbem']   : 0  ;
	$nranobem		= (isset($_POST['nranobem']))   ? $_POST['nranobem']   : 0  ;
	$dsbemfin		= (isset($_POST['dsbemfin']))   ? $_POST['dsbemfin']   : '' ;
	$vlrdobem 		= (isset($_POST['vlrdobem']))   ? $_POST['vlrdobem']   : 0  ;
	$tpchassi		= (isset($_POST['tpchassi']))   ? $_POST['tpchassi']   : 0  ;
	$dschassi		= (isset($_POST['dschassi']))   ? $_POST['dschassi']   : '' ;
	$dscorbem		= (isset($_POST['dscorbem']))   ? $_POST['dscorbem']   : '' ;
	$ufdplaca		= (isset($_POST['ufdplaca']))   ? $_POST['ufdplaca']   : '' ;
	$nrdplaca		= (isset($_POST['nrdplaca']))   ? str_replace('-','',$_POST['nrdplaca']) : '' ;
	$nrrenava		= (isset($_POST['nrrenava']))   ? $_POST['nrrenava']   : 0  ;
	$uflicenc		= (isset($_POST['uflicenc']))   ? $_POST['uflicenc']   : '' ;
	$nrcpfcgc       = (isset($_POST['nrcpfcgc']))   ? $_POST['nrcpfcgc']   : 0 ;
	$idseqbem		= (isset($_POST['idseqbem']))   ? $_POST['idseqbem']   : 0  ;
	$dsmarbem 		= (isset($_POST['dsmarbem']))   ? $_POST['dsmarbem']   : 0  ;
	$vlfipbem 		= (isset($_POST['vlfipbem']))   ? $_POST['vlfipbem']   : 0  ;

	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "  <nrdconta>" . $nrdconta . "</nrdconta>";
	$xmlCarregaDados .= "  <nrctremp>" . $nrctremp . "</nrctremp>";
	$xmlCarregaDados .= "  <tpctrato>" . $tpctrato . "</tpctrato>";
    $xmlCarregaDados .= "  <nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
	$xmlCarregaDados .= "  <cddopcao>" . $cddopcao . "</cddopcao>";
	$xmlCarregaDados .= "  <dscatbem>" . $dscatbem . "</dscatbem>";
	$xmlCarregaDados .= "  <dstipbem>" . $dstipbem . "</dstipbem>";
	$xmlCarregaDados .= "  <nrmodbem>" . $nrmodbem . "</nrmodbem>";
	$xmlCarregaDados .= "  <nranobem>" . $nranobem . "</nranobem>";
	$xmlCarregaDados .= "  <dsbemfin>" . $dsbemfin . "</dsbemfin>";
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
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados
						,"TELA_MANBEM"
						,"VALIDA_BEM_ALIENA"
						,$glbvars["cdcooper"]
						,$glbvars["cdagenci"]
						,$glbvars["nrdcaixa"]
						,$glbvars["idorigem"]
						,$glbvars["cdoperad"]
						,"</Root>");
	$xmlObject = getObjectXML($xmlResult);
	echo 'hideMsgAguardo();';

    if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
		$msgErro = $xmlObject->roottag->tags[0]->cdata;
		if ($msgErro == '') {
			$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		echo 'intervenienteValidado=false;';
		echo 'showError("error","'.utf8ToHtml($msgErro).'","'.utf8ToHtml('Alerta - Ayllos').'","","$NaN");';
	}
	else {

    // Verificar se � obrigatorio aprova��o do coordenador
    $aprovacao == 0;
    if (strtoupper($xmlObject->roottag->tags[1]->name) == 'APROVACA') {
      $aprovacao = $xmlObject->roottag->tags[1]->cdata;
    }
    
    // Se � necess�rio pedir aprova��o do coordenador
    if($aprovacao==1){
		$funcaoSim = 'SenhaCoordenador();';
    }else{
      $funcaoSim = 'SubstituiBem();';
    }  
    
    //echo ("console.log('aprovacao: $aprovacao');");
    //echo ("console.log('funcaoSim: $funcaoSim');");
    
		$funcaoNao = 'CancelaSubstituicao();';
		$msgAvisoDefault = "Este processo ir� primeiro alienar o novo ve�culo e depois baixar/cancelar a aliena��o do ve�culo a ser substitu�do.";
    
    // Se ha mensagem
		if (strtoupper($xmlObject->roottag->tags[0]->name) == 'MENSAGEM') {	
				$msgAviso = $xmlObject->roottag->tags[0]->cdata;
        if ($msgAviso != '') {
            $msgAviso = "<br/>".$msgAviso;
        }  
    }   

    // Mostrar confirma��o    
			echo "showConfirmacao(
                ' ".$msgAvisoDefault.$msgAviso." Continuar altera��o ?'
                ,'Confirma?- Ayllos'
										,'".$funcaoSim."'
										,'".$funcaoNao."'
										,'sim.gif'
										,'nao.gif'
									);";
    }
?>