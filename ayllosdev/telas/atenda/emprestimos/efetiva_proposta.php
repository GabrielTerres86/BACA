<? 
/*!
 * FONTE        : grava_dados_proposta.php
 * CRIA��O      : Marcelo L. Pereira (GATI)
 * DATA CRIA��O : 29/07/2011 
 * OBJETIVO     : Rotina de grava��o da aprova��o da proposta
 *
 *---------------------
 *      ALTERACOES
 *---------------------
 *
 * 000: [06/03/2012] Tiago: Incluido cdagenci e cdpactra.
 * 001: [18/11/2014] Jaison: Inclusao do parametro nrcpfope.
         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$insitapv = (isset($_POST['insitapv'])) ? $_POST['insitapv'] : '';
	$dsobscmt = (isset($_POST['dsobscmt'])) ? $_POST['dsobscmt'] : '';
	$dtdpagto = (isset($_POST['dtdpagto'])) ? $_POST['dtdpagto'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
					
	// Monta o xml de requisicao MENSAGERIA
	$xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
    $xml .= "  <cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
    $xml .= "  <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
    $xml .= "  <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
    $xml .= "  <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
    $xml .= "  <idorigem>".$glbvars["idorigem"]."</idorigem>";		
    $xml .= "  <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "  <idseqttl>".$idseqttl."</idseqttl>";
    $xml .= "  <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
    $xml .= "  <flgerlog>1</flgerlog>";
    $xml .= "  <nrctremp>".$nrctremp."</nrctremp>";
    $xml .= "  <dtdpagto>".$dtdpagto."</dtdpagto>";
    $xml .= "  <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";		        
    $xml .= "  <inproces>".$glbvars["inproces"]."</inproces>";		
    $xml .= "  <nrcpfope>0</nrcpfope>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
	 
    $x mlResult = mensageria($xml, "EMPR0001", "EFETIVA_PROPOSTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    $retorno = "hideMsgAguardo(); $('#linkAba0').html('Principal');";
    $retorno .= "arrayRatings.length = 0;";
  
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
 	  $retorno .= 'exibirMensagens(\''.$mensagem.'\',\'controlaOperacao(\"RATING\")\');';
 	  $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	  if ($msgErro == "") {
	    $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->cdata);
	  }		
	  $msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	

	  exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	  exit();
    }else{
	  $ratings = $xmlObjetoSeg->roottag->tags[2]->tags;	
	  $temRetorno = "N";

	  foreach($ratings as $indice => $rating){
	    $temRetorno = "S";
	    $retorno .= 'var arrayRating'.$indice.' = new Object();
          arrayRating'.$indice.'[\'dtmvtolt\'] = "'.getByTagName($rating->tags,'dtmvtolt').'";
		  arrayRating'.$indice.'[\'dsdopera\'] = "'.getByTagName($rating->tags,'dsdopera').'"; 
		  arrayRating'.$indice.'[\'nrctrrat\'] = "'.getByTagName($rating->tags,'nrctrrat').'"; 
		  arrayRating'.$indice.'[\'indrisco\'] = "'.getByTagName($rating->tags,'indrisco').'"; 
		  arrayRating'.$indice.'[\'nrnotrat\'] = "'.getByTagName($rating->tags,'nrnotrat').'"; 
		  arrayRating'.$indice.'[\'vlutlrat\'] = "'.getByTagName($rating->tags,'vlutlrat').'"; 
		  arrayRatings['.$indice.'] = arrayRating'.$indice.';';
	  }

	  if($temRetorno == "S"){
	    $retorno .=  "controlaOperacao('T_C');";
	  }else{
	    $retorno .= 'exibirMensagens(\''.$mensagem.'\',\'controlaOperacao(\"RATING\")\');';
	  }

	  echo $retorno;

?>