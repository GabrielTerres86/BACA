<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Lombardi
	 Data : Jan/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da SITCTA.                                  
	                                                                  
	 Alterações: 
	 
	**********************************************************************/
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";		
	
	$xmlResult = mensageria($xml, "TELA_SITCTA", "BUSCAR_SITUACOES_DE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xml_dados = getObjectXML($xmlResult);
	
	$situacoes = $xml_dados->roottag->tags[0]->tags;
	
?>

<form name="frmCabSitcta" id="frmCabSitcta" class="formulario cabecalho" style= "height: 25px">

	<label for="situacao">Situa&ccedil;&atilde;o:</label>
	<select name="situacao" id="situacao" class="campo">
		<option value="0"> Selecione a situa&ccedil;&atilde;o</option>
		<?
		foreach($situacoes as $situacao) {
			?>
			<option value="<? echo getByTagName($situacao->tags,'cdsituacao'); ?>"><? echo getByTagName($situacao->tags,'dssituacao'); ?></option>
			<?
		}
		?>
	</select>			
	<a href="#" id="btOk" class="botao">Ok</a>
</form>	
