<? 
/*!
 * FONTE        : busca_consulta_banco.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Rotina para consultar bancos cadastrados - BANCOS
 * --------------
 * ALTERAÇÕES   : Alterado layout e incluido novos campos: flgoppag, dtaltstr e dtaltpag. 
 *                PRJ-312 (Reinert)
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
			$retornoAposErro .= '$(\'#'.$campo.'\',\'#divEntrada\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#nrispbif\',\'#divEntrada\').habilitaCampo(); $(\'#frmConsulta\').css(\'display\',\'none\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();';
		}
		
		$msgErro  = $xmlObjBuscaBanco->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
	}	
		
	$registros = $xmlObjBuscaBanco->roottag->tags[0]->tags;
	
	echo "$('#frmConsulta').css('display','block');";
	echo "$('#cdbccxlt','#divEntrada').val('".getByTagName($registros,'auxcdbcc')."');";
	echo "$('#nrispbif','#divEntrada').val('".getByTagName($registros,'auxnrisp')."');";
	echo "$('#nmresbcc','#frmConsulta').val('".getByTagName($registros,'nmresbcc')."');";
	echo "$('#nmextbcc','#frmConsulta').val('".getByTagName($registros,'nmextbcc')."');";
	echo "$('#flgdispb','#frmConsulta').val('".getByTagName($registros,'flgdispb')."');";
	echo "$('#dtinispb','#frmConsulta').val('".getByTagName($registros,'dtinispb')."');";
	echo "$('#flgoppag','#frmConsulta').val('".getByTagName($registros,'flgoppag')."');";
	echo "$('#dtaltstr','#frmConsulta').val('".getByTagName($registros,'dtaltstr')."');";
    echo "$('#dtaltpag','#frmConsulta').val('".getByTagName($registros,'dtaltpag')."');";
    echo "$('#nrcnpjif','#frmConsulta').val('".getByTagName($registros,'nrcnpjif')."');";
	
	if($cddopcao == 'C'){
		echo "$('#cdbccxlt','#divEntrada').desabilitaCampo();";
		echo "$('#nrispbif','#divEntrada').desabilitaCampo();";
		
	}else if($cddopcao == 'A'){
		echo "$('#cdbccxlt','#divEntrada').desabilitaCampo();";
		echo "$('#nrispbif','#divEntrada').desabilitaCampo();";
		echo "$('#nmresbcc','#frmConsulta').habilitaCampo().focus();";
		echo "$('#nmextbcc','#frmConsulta').habilitaCampo();";
		echo "$('#flgdispb','#frmConsulta').habilitaCampo();";
		echo "$('#dtinispb','#frmConsulta').habilitaCampo();";
		echo "$('#flgoppag','#frmConsulta').habilitaCampo();";
		echo "$('#nrcnpjif','#frmConsulta').desabilitaCampo();";
		
	}else if($cddopcao == 'M'){
		echo "$('#cdbccxlt','#divEntrada').desabilitaCampo();";
		echo "$('#nrispbif','#divEntrada').desabilitaCampo();";
		echo "$('#nmresbcc','#frmConsulta').desabilitaCampo();";
		echo "$('#nmextbcc','#frmConsulta').desabilitaCampo();";
		echo "$('#flgdispb','#frmConsulta').desabilitaCampo();";
		echo "$('#dtinispb','#frmConsulta').desabilitaCampo();";
		echo "$('#flgoppag','#frmConsulta').desabilitaCampo();";
		echo "$('#nrcnpjif','#frmConsulta').habilitaCampo().focus();";
		
	}
	
?>