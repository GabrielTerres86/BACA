<?
/* * *********************************************************************

  Fonte: form_filtro_parametros.php
  Autor: Thaise Medeiros - Envolti
  Data : Setembro/2018                       Última Alteração: 

  Objetivo  :  Mostrar o form de filtros para a opão P.

  Alterações: 
  

 * ********************************************************************* */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");

	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados/>";
	$xml .= "</Root>";
	
	// Requisicao para busca dos parâmetros de sistema
	$xmlResult = mensageria($xml
						,"TELA_GRAVAM"
						,"GRAVAM_BUSCA_PRM"
						,$glbvars["cdcooper"]
						,$glbvars["cdagenci"]
						,$glbvars["nrdcaixa"]
						,$glbvars["idorigem"]
						,$glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	$xmlRegist = $xmlObject->roottag->tags[0];
	
?>

<script type="text/javascript" src="gravam_parametros.js"></script>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px 10px 10px 10px; margin:0px;">
		
		<legend>Filtro</legend>
		
		<div id="divFiltroParametros">

			<label for="nrdiaenv" class="rotulo"><? echo utf8ToHtml('Número de dias após liquidação do contrato para envio das baixas:') ?></label>
			<input id="nrdiaenv" name="nrdiaenv" class="campo" maxlength="3" style="width: 50px; text-align: center;" value="<?php echo getByTagName($xmlRegist->tags,'nrdiaenv'); ?>" />

			<label for="hrenvi01" class="rotulo"><? echo utf8ToHtml('Horário(s) dos envios das baixas/cancelamentos:') ?></label>
			<input type="time" id="hrenvi01" name="hrenvi01" maxlength="5" class="campo" value="<?php echo getByTagName($xmlRegist->tags,'hrenvi01'); ?>" style="width: 75px" />
			
			<input type="time" id="hrenvi02" name="hrenvi02" maxlength="5" class="campo" style="width: 75px; padding-left: 1px;" value="<?php echo getByTagName($xmlRegist->tags,'hrenvi02'); ?>" />
			
			<input type="time" id="hrenvi03" name="hrenvi03" maxlength="5" class="campo" value="<?php echo getByTagName($xmlRegist->tags,'hrenvi03'); ?>" style="width: 75px" />
			
			<label for="aprvcord" class="rotulo"><? echo utf8ToHtml('Solicita senha de coord. para aditiv.') ?></label>
			<select id="aprvcord" name="aprvcord" class="campo">
			<option value="S" <?php echo (getByTagName($xmlRegist->tags,'aprvcord') == 'S' ? 'selected' : ''); ?>>Sim</option>
			<option value="N" <?php echo (getByTagName($xmlRegist->tags,'aprvcord') == 'N' ? 'selected' : ''); ?>><? echo utf8ToHtml('Não') ?></option>
			<option value="A" <?php echo (getByTagName($xmlRegist->tags,'aprvcord') == 'A' ? 'selected' : ''); ?>>Apenas quando</option>
			</select>
			
			<label for="perccber"class="rotulolinha" style="padding-left: 3px;"><? echo utf8ToHtml('valor do bem abaixo de') ?></label>
			<input type="text" id="perccber" name="perccber" maxlength="6" class="campo" style="width: 47px;" value="<?php echo getByTagName($xmlRegist->tags,'perccber'); ?>" />
			<label for="perccber" class="rotulolinha" style="padding-left: 3px;"><? echo utf8ToHtml('% do saldo devedor') ?></label>
			
			<label for="tipcomun" class="rotulo"><? echo utf8ToHtml('Forma de comunicação:') ?></label>
			<select id="tipcomun" name="tipcomun" class="campo">
			<option value="S" <?php echo (getByTagName($xmlRegist->tags,'tipcomun') == 'S' ? 'selected' : ''); ?>>Online</option>
			<option value="N" <?php echo (getByTagName($xmlRegist->tags,'tipcomun') == 'N' ? 'selected' : ''); ?>>Lote</option>
			</select>
			
			<label for="nrdnaoef" class="rotulo"><? echo utf8ToHtml('Número de dias para aviso via e-mail de propostas com gravames e não efetivadas:') ?></label>
			<input id="nrdnaoef" name="nrdnaoef" maxlength="6" class="campo" style="width: 100px; text-align: center" value="<?php echo getByTagName($xmlRegist->tags,'nrdnaoef'); ?>" />
			
			<label form="emlnaoef" class="rotulo"><? echo utf8ToHtml('E-mail(s) para enviar relatório de propostas com gravames e não efetivadas:') ?></label>
			<textarea id="emlnaoef" name="emlnaoef" class="campo" style="width: 100%; height: 80px;" maxlength="1000"><?php echo getByTagName($xmlRegist->tags,'emlnaoef'); ?></textarea>
			
		</div> 

	</fieldset>
	
	<div id="divBotoes">
    	<a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="estadoInicial();return false;">Voltar</a>
    	<a href="#" class="botao" id="btSalvar" name="btSalvar" onClick="gravaParametros(); return false;">Salvar</a>
    </div>

</form>

