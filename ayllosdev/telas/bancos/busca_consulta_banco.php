<? 
/*!
 * FONTE        : busca_consulta_banco.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Rotina para consultar bancos cadastrados - BANCOS
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 *
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

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdbccxlt = (isset($_POST["cdbccxlt"])) ? $_POST["cdbccxlt"] : 0;
	$nrispbif = (isset($_POST["nrispbif"])) ? $_POST["nrispbif"] : 0;
		
	$xmlBuscaBanco  = "";
	$xmlBuscaBanco .= "<Root>";
	$xmlBuscaBanco .= " <Dados>";
	$xmlBuscaBanco .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBuscaBanco .= "	 <cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xmlBuscaBanco .= "  <nrispbif>".$nrispbif."</nrispbif>";
	$xmlBuscaBanco .= "  <cddopcao>".$cddopcao."</cddopcao>";	
	$xmlBuscaBanco .= " </Dados>";
	$xmlBuscaBanco .= "</Root>";
			
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaBanco, "BANCOS", "CONSULTABANCO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjBuscaBanco = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscaBanco->roottag->tags[0]->name) == 'ERRO') {
		
		$campo    = $xmlObjBuscaBanco->roottag->tags[0]->attributes['NMDCAMPO'];		
		
		if(empty ($campo)){ 
			$campo = "nmresbcc";
		}
						
		if($campo != ''){ 
			$retornoAposErro .= '$(\'#'.$campo.'\',\'#frmEntrada\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#nrispbif\',\'#frmEntrada\').habilitaCampo(); $(\'#frmConsulta\').css(\'display\',\'none\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();';
		}
		
		$msgErro  = $xmlObjBuscaBanco->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
	}	
		
	$registros = $xmlObjBuscaBanco->roottag->tags[0]->tags;
	
	echo "$('#frmConsulta').css('display','block');";
	echo "$('#cdbccxlt','#frmEntrada').val('".getByTagName($registros,'auxcdbcc')."');";
	echo "$('#nrispbif','#frmEntrada').val('".getByTagName($registros,'auxnrisp')."');";
	echo "$('#nmresbcc','#frmConsulta').val('".getByTagName($registros,'nmresbcc')."');";
	echo "$('#nmextbcc','#frmConsulta').val('".getByTagName($registros,'nmextbcc')."');";
	echo "$('#flgdispb','#frmConsulta').val('".getByTagName($registros,'flgdispb')."');";
	echo "$('#dtinispb','#frmConsulta').val('".getByTagName($registros,'dtinispb')."');";
    
	if($cddopcao == 'C'){
		echo "$('#cdbccxlt','#frmEntrada').desabilitaCampo();";
		echo "$('#nrispbif','#frmEntrada').desabilitaCampo();";
	}else if($cddopcao == 'A'){
		echo "$('#cdbccxlt','#frmEntrada').desabilitaCampo();";
		echo "$('#nrispbif','#frmEntrada').desabilitaCampo();";
		echo "$('#nmresbcc','#frmConsulta').habilitaCampo().focus();";
		echo "$('#nmextbcc','#frmConsulta').habilitaCampo();";
		echo "$('#flgdispb','#frmConsulta').habilitaCampo();";
		echo "$('#dtinispb','#frmConsulta').habilitaCampo();";
		
	}
	
?>