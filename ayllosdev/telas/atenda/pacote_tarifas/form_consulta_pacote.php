<?
/*!
 * FONTE        : form_consulta_pacote.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 18/03/2016
 * OBJETIVO     : Tela do formulario de detalhamento de tarifas
 * ALTERACAO    :
 * 
 * 30/10/2018 - Merge Changeset 26538 referente ao P435 - Tarifas Avulsas (Peter - Supero) 
 */	 

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	$opcao 			  = $_POST['opcao'] 		   != '' ? $_POST['opcao'] 		      : 'C';
	$cd_reciprocidade = $_POST['cd_reciprocidade'] != '' ? $_POST['cd_reciprocidade'] : 0;
	$nrdconta 		  = $_POST['nrdconta'] 		   != '' ? $_POST['nrdconta']		  : 0;
	
	if ($opcao  != 'C') {
		$xmlBuscaFlrecpct  = '<Root>';
		$xmlBuscaFlrecpct .= 	'<Dados>';
		$xmlBuscaFlrecpct .= 	'<nrdconta>'.$nrdconta.'</nrdconta>';
		$xmlBuscaFlrecpct .= 	'</Dados>';
		$xmlBuscaFlrecpct .= '</Root>';
			
		// Executa script para envio do XML	
		$xmlResult = mensageria($xmlBuscaFlrecpct, "ADEPAC", "VALID_RECIPCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		
		$xmlObjBuscaFlrecpct = getObjectXML($xmlResult);
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjBuscaFlrecpct->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro  = utf8_encode($xmlObjBuscaFlrecpct->roottag->tags[0]->tags[0]->tags[4]->cdata);
			$nmdcampo = $xmlObjBuscaFlrecpct->roottag->tags[0]->attributes["NMDCAMPO"];	
			
			if(empty ($nmdcampo)){ 
				$nmdcampo = "nrrecben";
			}
					 
			exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'input\',\'#divBeneficio\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divBeneficio\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divBeneficio\');',false);		
								
		}   
		
		$flrecpct = $xmlObjBuscaFlrecpct->roottag->tags[0]->cdata;
		$inpessoa = $xmlObjBuscaFlrecpct->roottag->tags[1]->cdata;
		$inivigen = $xmlObjBuscaFlrecpct->roottag->tags[2]->cdata;
		
		// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
		function exibeErro($msgErro) {
			echo 'hideMsgAguardo();';
			echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
			exit();
		}
	}
?>

<form name="frmConsultaPacote" id="frmConsultaPacote" class="formulario" >
	<input type="hidden" id="glb_idparame_reciproci" value = "">
	<input type="hidden" id="glb_desmensagem" value = "">
	<fieldset>
		<legend><?if($opcao == 'C' || $opcao == 'c'){ echo 'Consulta'; }else{ echo 'Incluir'; }?></legend>
			
		<label for="cdpacote">C&oacute;digo:</label>
		<input class="inteiro" name="cdpacote" style="text-align: right;" id="cdpacote" type="text" maxlength="10" onchange="buscaPacote(this.value,<?echo $inpessoa;?>)" />
		<? if ($opcao != 'C' && $opcao != 'c') { ?>
			<a style="padding: 3px 0 0 3px;" href="#" onClick="pesquisaPacote(<?echo $inpessoa;?>); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<?}?>
		<input name="dspacote" style="text-align: right;" id="dspacote" type="text" value="" />
		<div style="margin-top: 10px;"></div>
		
		<div style="margin-top: 10px;"></div>
		
		<? if (strtoupper($opcao) == 'C') { ?>
		
			<label for="dtinicio_vigencia">In&iacute;cio Vig&ecirc;ncia:</label>
			<input type="text" id="dtinicio_vigencia" style="text-align: right;" value="<? echo $inivigen; ?>" />	
			
			<label for="dtcancelamento">Cancelamento:</label>
			<input name="dtcancelamento" style="text-align: right;" id="dtcancelamento" type="text" value="" />
				
			<div style="margin-top: 10px;"></div>
			
			<label for="dtdiadebito">Dia do d&eacute;bito:</label>
			<select name="dtdiadebito" style="text-align: right;" id="dtdiadebito">
				<option value="1">01</option>
				<option value="5">05</option>
				<option value="10">10</option>
				<option value="20">20</option>
			</select>

			<div style="margin-top: 10px;"></div>
							
			<label for="perdesconto_manual">Desconto manual:</label>
			<input class="inteiro" name="perdesconto_manual" style="text-align: right;"  id="perdesconto_manual" onKeyUp="habilidaQtdMeses();" type="text" value="" /> 
			<label style="margin-left: 5px" >%</label>
			
			<label for="qtdmeses_desconto">Qtd. meses desconto:</label>
			<input class="inteiro" name="qtdmeses_desconto" style="text-align: right;" id="qtdmeses_desconto" type="text" value="" />
		
			<div style="margin-top: 10px;"></div>
			
			<label for="tipo_autorizacao" class="rotulo" style="width:119px;" >Tipo de Autoriza&ccedil;&atilde;o:</label>
			<label style="font-weight: normal;"><input type="radio" name="tipo_autorizacao" value='S' style="border:none;"> Senha</label>
			<label style="font-weight: normal; margin-left: 5px;"><input type="radio" name="tipo_autorizacao" value='A' style="border:none;"> Assinatura</label>

			<div style="margin-top: 10px;"></div>
			
			<label for="cdreciprocidade">Reciprocidade:</label>
			<input type="text" name="cdreciprocidade" style="text-align: right;" id="cdreciprocidade">
			
		<?} else {?>
		
			<label for="dtdiadebito">Dia do d&eacute;bito:</label>
			<select name="dtdiadebito" style="text-align: right;" id="dtdiadebito">
				<option value="1">01</option>
				<option value="5">05</option>
				<option value="10">10</option>
				<option value="20">20</option>
			</select>

			<label for="dtinicio_vigencia">In&iacute;cio Vig&ecirc;ncia:</label>
			<input type="text" id="dtinicio_vigencia" style="text-align: right;" value="<? echo $inivigen; ?>" />	
			
			<div style="margin-top: 10px;"></div>
							
			<label for="perdesconto_manual">Desconto manual:</label>
			<input class="inteiro" name="perdesconto_manual" style="text-align: right;" id="perdesconto_manual" maxlength="3" onKeyUp="habilidaQtdMeses();" type="text" value="" /> 
			<label style="margin-left: 5px" >%</label>
			
			<div style="margin-top: 10px;"></div>
			
			<label for="qtdmeses_desconto">Qtd. meses desconto:</label>
			<input class="inteiro" name="qtdmeses_desconto" style="text-align: right;" id="qtdmeses_desconto" maxlength="4" type="text" value="" />
			
			<div style="margin-top: 10px;"></div>

			<label for="tipo_autorizacao" class="rotulo" style="width:119px;">Tipo de Autoriza&ccedil;&atilde;o:</label>
			<label style="font-weight: normal;"><input type="radio" name="tipo_autorizacao" value='S' style="border:none;"> Senha</label>
			<label style="font-weight: normal; margin-left: 5px;"><input type="radio" name="tipo_autorizacao" value='A' style="border:none;"> Assinatura</label>
		<?}?>
	</fieldset>
</form>	

<div id="divBotoes">
	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btCancelar" onClick="acessaOpcaoAba(1,0,0);return false;"><?if ($opcao == 'C' || $opcao == 'c') {?>Voltar<?}else{?>Voltar<?}?></a>
	
	<? if ($opcao != 'C' && $opcao != 'c') {
		if ($flrecpct > 0) {?>
			<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btProsseguir" onClick="valida_inclusao('S',<?echo $nrdconta;?>,<?echo $cd_reciprocidade;?>,<?echo $inpessoa;?>, <?echo $nrdconta;?>);return false;">Prosseguir</a>
		<?} else {?>
			<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btProsseguir" onClick="valida_inclusao('N',<?echo $nrdconta;?>);return false;">Confirmar</a>
		<?}?>
	<? } ?>
</div>
<script language="JavaScript">

</script>
