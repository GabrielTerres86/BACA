<? 
/*!
 * FONTE        : calcula.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Busca os registros de rating
 * --------------
 * ALTERAÇÕES   : 
 */

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$rowidnrc = isset($_POST["rowidnrc"]) ? $_POST["rowidnrc"] : "";
	$insitrat = isset($_POST["insitrat"]) ? $_POST["insitrat"] : 0;
	$tpctrrat = isset($_POST["tpctrrat"]) ? $_POST["tpctrrat"] : 0;
	$nrctrrat = isset($_POST["nrctrrat"]) ? $_POST["nrctrrat"] : 0;
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$dsdopera = isset($_POST["dsdopera"]) ? $_POST["dsdopera"] : "";
	$indrisco = isset($_POST["indrisco"]) ? $_POST["indrisco"] : 0;
	$nrnotrat = isset($_POST["nrnotrat"]) ? $_POST["nrnotrat"] : 0;
	$nrnotrat = str_replace(',','.',str_replace('.','',$nrnotrat));

	if($glbvars["cdcooper"] == 3){
		$nomeDiv="#divBotoesRatingSingular";
	}else{
		$nomeDiv="#divBotoesRatings";
	}

	$rating   = isset($_POST["rating"]) ? $_POST["rating"] : '';	

	$vlrating = '';

	foreach($rating as $dados){

		$valores = '';

		foreach($dados as $valor){

			if($valores == ''){

				$valores = $valor;
				
			}else{
				
				$valores = $valores.'|'.$valor;
				
			}
		
		}

		if($vlrating == ''){

			$vlrating = $valores;

		}else{

			$vlrating = $vlrating.'#'.$valores;

		}

	}

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <nrctrrat>".$nrctrrat."</nrctrrat>";
	$xml .= "   <tpctrrat>".$tpctrrat."</tpctrrat>";
	$xml .= "   <dsdopera>".$dsdopera."</dsdopera>";
	$xml .= "   <insitrat>".$insitrat."</insitrat>";		
	$xml .= "   <rowidnrc>".$rowidnrc."</rowidnrc>";
	$xml .= "   <indrisco>".$indrisco."</indrisco>";
	$xml .= "   <nrnotrat>".$nrnotrat."</nrnotrat>";
	$xml .= "   <vlrating>".$vlrating."</vlrating>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATURAT", "CALCULA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\''.$nomeDiv.'\').focus();',false);		
		
	} 
	
	exibirErro('inform','O risco foi atualizado com sucesso.','Alerta - Ayllos','buscaRatings(1,30)',false);		
		

	function validaDados(){
		
		
		IF($GLOBALS["nrdconta"] == 0 ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'#btVoltar\',\''.$GLOBALS["nomeDiv"].'\').focus();',false);
		}
			
						
	}	
		
?>
