<?php
/*!
 * FONTE        : consulta_segmento.php                    Última alteração: 
 * CRIAÇÃO      : Douglas Pagel (AMcom)
 * DATA CRIAÇÃO : Fevereiro/2019 
 * OBJETIVO     : Rotina para buscar informações do segmento
 * --------------
 * ALTERAÇÕES   : 
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
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
  
  $idsegmento = (isset($_POST["idsegmento"])) ? $_POST["idsegmento"] : 0;
  $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0;
  $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0;

  validaDados();
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <idsegmento>".$idsegmento."</idsegmento>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SEGEMP", "SEGEMP_CONS_SEG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "idsegmento";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
    
		exibirErro('error',$msgErro,'Alerta - Aimaro','formataFiltro(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 

	$linha     = $xmlObj->roottag->tags[0];
	$permis	 = $xmlObj->roottag->tags[0]->tags[10];
	$subseg	 = $xmlObj->roottag->tags[0]->tags[9]->tags;
	
	//Busca permissões PF e PJ
	$permis_pessoa = getByTagName($permis->tags[0]->tags,'codigo_tipo_pessoa');
	if ($permis_pessoa == 1) {
		$permis_pessoa_fisica = true;
	} elseif ($permis_pessoa == 2) {
		$permis_pessoa_juridica = true;
	}
	
	$permis_pessoa = getByTagName($permis->tags[1]->tags,'codigo_tipo_pessoa');
	if ($permis_pessoa == 1) {
		$permis_pessoa_fisica = true;
	} elseif ($permis_pessoa == 2) {
		$permis_pessoa_juridica = true;
	}
	
    //Busca tag Canais
	for ($i = 0; $i <=3; $i++) {
		if ($permis->tags[$i]->name == 'CANAIS') {
			$permis_canais = $permis->tags[$i];
		}
	}
	
	//Busca dados dos canais
	$canal_3_permis = 0;
	$canal_4_permis = 0;
	$canal_10_permis = 0;
	$canal_10_vlr = 0;
	$canal_4_vlr = 0;
	$canal_3_vlr = 0;
	
	for ($i = 0; $i <=3; $i++) {
		if ($permis_canais->tags[$i]->name == 'CANAL') {
			if (getByTagName($permis_canais->tags[$i]->tags,'CODIGO_CANAL') == 3 ) {
				$canal_3_permis = getByTagName($permis_canais->tags[$i]->tags,'TIPO_PERMISSAO');
				$canal_3_vlr = getByTagName($permis_canais->tags[$i]->tags,'VALOR_MAX_AUTORIZADO');
			} elseif (getByTagName($permis_canais->tags[$i]->tags,'CODIGO_CANAL') == 4 ) {
				$canal_4_permis = getByTagName($permis_canais->tags[$i]->tags,'TIPO_PERMISSAO');
				$canal_4_vlr = getByTagName($permis_canais->tags[$i]->tags,'VALOR_MAX_AUTORIZADO');
			} elseif (getByTagName($permis_canais->tags[$i]->tags,'CODIGO_CANAL') == 10 ) {
				$canal_10_permis = getByTagName($permis_canais->tags[$i]->tags,'TIPO_PERMISSAO');
				$canal_10_vlr = getByTagName($permis_canais->tags[$i]->tags,'VALOR_MAX_AUTORIZADO');
			}
		}
	}
		
	
	include('form_consulta.php');	
	
	
	function validaDados(){
			
		IF($GLOBALS["idsegmento"] == 0 ){ 
			exibirErro('error','Segmento inv&aacute;lido.','Alerta - Aimaro','formataFiltro(); focaCampoErro(\'cdlcremp\',\'frmFiltro\');',false);
		}
   
				
	}	
  
 ?>
