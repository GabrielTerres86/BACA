<?php
/*!
 * FONTE        : apresentar_form_opcao_h.php
 * CRIAÇÃO      : Andrey Formigari - (Mouts)
 * DATA CRIAÇÃO : 20/10/2018 
 * OBJETIVO     : 
 * --------------
	* ALTERAÇÕES   : 
 * --------------
 */ 
	 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	require_once("../../includes/carrega_permissoes.php");

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_HCONVE", 'POPULAR_OPCAO_H', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','estadoInicial();',false);		
					
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags[0];

?>


<form id="frmOpcaoH" name="frmOpcaoH" class="formulario">
	<fieldset style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend><?php echo utf8ToHtml("Convênio disponível"); ?></legend>
		
		<br />
		
		<label for="cdconvenio"><?php echo utf8ToHtml("Convênio sugerido: "); ?></label>
		<input type="text" id="cdconvenio" name="cdconvenio" class="campoTelaSemBorda" readonly value="<?php echo getByTagName($registros->tags,'cdconven'); ?>" />
		
	</fieldset>
	<br />
	<fieldset id="fsetHistorico1" style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend><?php echo utf8ToHtml("Arrecadação"); ?></legend>
		
		<br />
		
		<label for="cdhistsug1" ><?php echo utf8ToHtml("Histórico:"); ?></label>
		<input type="text" id="cdhistsug1" name="cdhistsug1" class="campo" /> 
		
		<label for="historicoSugerido1" ><?php echo utf8ToHtml("Sugerido:"); ?></label>
		<input type="text" id="historicoSugerido1" name="historicoSugerido1" class="campo" value="<?php echo getByTagName($registros->tags,'cdhisto1'); ?>" /> 
		
		<label for="cdhistor" ><?php echo utf8ToHtml("Histórico referência: "); ?></label>
		<input type="text" id="cdhistor" name="cdhistor" class="campo" maxlength="4" />
	    <a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		
		<br />
		
		<label for="dshistor" ><?php echo utf8ToHtml("Nome abreviado: "); ?></label>
		<input type="text" id="dshistor" name="dshistor" class="campo"/>
		
		<br />
		
		<label for="dsexthst" ><?php echo utf8ToHtml("Nome extenso: "); ?></label>
		<input type="text" id="dsexthst" name="dsexthst" class="campo" />
		
	</fieldset>
	<br />
	<fieldset id="fsetHistorico2" style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend><?php echo utf8ToHtml("Débito automático"); ?></legend>
		
		<br />
		
		<label for="cdhistsug2" ><?php echo utf8ToHtml("Histórico:"); ?></label>
		<input type="text" id="cdhistsug2" name="cdhistsug2" class="campo" />
		
		<label for="historicoSugerido2" ><?php echo utf8ToHtml("Sugerido:"); ?></label>
		<input type="text" id="historicoSugerido2" name="historicoSugerido2" class="campo" value="<?php echo getByTagName($registros->tags,'cdhisto2'); ?>" /> 
		
		<label for="cdhistor" ><?php echo utf8ToHtml("Histórico referência: "); ?></label>
		<input type="text" id="cdhistor" name="cdhistor" class="campo" />
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>		

		<br />
		
		<label for="dshistor" ><?php echo utf8ToHtml("Nome abreviado: "); ?></label>
		<input type="text" id="dshistor" name="dshistor" class="campo"/>
		
		<br />
		
		<label for="dsexthst" ><?php echo utf8ToHtml("Nome extenso: "); ?></label>
		<input type="text" id="dsexthst" name="dsexthst" class="campo" />
		
	</fieldset>
</form>

<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	<a href="#" class="botao" id="btVoltar"    onclick="controlaVoltar('1');return false;">Voltar</a>
	<a href="#" class="botao" id="btCriar"  onclick="btnCriarHistNovoConvenio(); return false;">Criar</a>
</div>

<script type="text/javascript">
	formataformOpcaoH();
</script>