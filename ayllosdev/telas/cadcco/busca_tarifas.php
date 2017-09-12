<?php
/*!
 * FONTE        : busca_tarifas.php
 * CRIAÇÃO      : Jonathan (RKAM)
 * DATA CRIAÇÃO : Marco/2016 
 * OBJETIVO     : Rotina para buscas as tarifas para a tela CADCCO
 * --------------
 * ALTERAÇÕES   : 30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
 *                             código do departamento ao invés da descrição (Renato Darosci - Supero)
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

	$nrconven = (isset($_POST["nrconven"])) ? $_POST["nrconven"] : 0;
	$cddbanco = (isset($_POST["cddbanco"])) ? $_POST["cddbanco"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;

	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrconven>".$nrconven."</nrconven>";
	$xml 	   .= "     <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xml 	   .= "     <cddbanco>".$cddbanco."</cddbanco>";	
	$xml 	   .= "     <cddepart>".$glbvars['cddepart']."</cddepart>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml	   .= "     <nrregist>".$nrregist."</nrregist>";	
	$xml	   .= "     <nriniseq>".$nriniseq."</nriniseq>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADCCO", "CONSTARIFAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjTarifas = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTarifas->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjTarifas->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesCadcco\').focus();',false);		
					
	} 
		
	$tarifas   = $xmlObjTarifas->roottag->tags[0]->tags;
    $qtregist  = $xmlObjTarifas->roottag->attributes["QTREGIST"];
	
	if($qtregist > 0){
	
		include("form_tarifas.php");
			
	}else{

		if($cddopcao != 'C'){?>

			<script text="text/javascript">

				estadoInicial();
	
			</script>

		<?}

	}		 
	

	function validaDados(){
		
		//Convenio
		if ( $GLOBALS["nrconven"] == 0){ 
			exibirErro('error','Conv&ecirc;nio inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesCadcco\').focus();',false);
		}
	
	}

 ?>
