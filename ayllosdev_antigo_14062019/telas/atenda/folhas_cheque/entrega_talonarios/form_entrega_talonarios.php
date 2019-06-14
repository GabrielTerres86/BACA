<?php 

	/***************************************************************************
	 Fonte: form_entrega_talonarios.php
	 Autor: Lombardi
 	 Data : Agosto/2018                 Última Alteração: 16/08/2018

	 Objetivo  : Formulario de entrega de talonarios

	 Alterações: 29/11/2018 - Adicionado campo qtreqtal. Acelera - Entrega de Talonario (Lombardi)
				
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	include("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E',false)) <> '') 
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$nrdconta = isset($_POST['nrdconta']) ? $_POST['nrdconta'] : 0;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CHEQ0001", "CHQ_LISTA_TALONARIOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$xmlTaloes = $xmlObject->roottag->tags[0]->tags;
	
?>

<form id="frmEntregaTalonarios" name="frmEntregaTalonarios" class="formulario">
	<fieldset>
		<legend><? echo utf8ToHtml('Entrega de Talões') ?></legend>
		
		<div style="text-align: left; margin-left: 90px;">	
			<input name="tpentrega" id="tpentrega_1" type="radio" class="radio" value="0" onclick="formataOpcoes();" checked >
			<label for="tpentrega_1" class="radio"><? echo utf8ToHtml('Titular/Procurador') ?></label>
			
			<input name="tpentrega" id="tpentrega_2" type="radio" class="radio" value="1" onclick="formataOpcoes();">
			<label for="tpentrega_2" class="radio"><? echo utf8ToHtml('Terceiro') ?></label>
		</div>
		
		<div id="divTerceiro">
			<label for="cpfterce"><? echo utf8ToHtml('CPF Terceiro:') ?></label>
			<input type="text" name="cpfterce" id="cpfterce" />
			<div id="divSemCartaoAss">
				<a id="btnCartaoAss" name="btnCartaoAss" class="txtNormal SetFocus" href="#" onclick="cartaoAssinatura(); return false;" >&nbsp;Cart&atilde;o Ass.</a>
			</div>
			
			<label for="nmtercei"><? echo utf8ToHtml('Nome Terceiro:') ?></label>
			<input type="text" name="nmtercei" id="nmtercei" />
		</div>
		
		<br style="clear:both" />
		
		<div style="text-align: left; margin-left: 90px; margin-top: 1px;">	
			<input name="tprequis" id="tprequis_1" type="radio" class="radio" value="1" onclick="formataOpcoes();" checked>
			<label for="tprequis_1" class="radio"><? echo utf8ToHtml('Normal') ?></label>
			
			<input name="tprequis" id="tprequis_2" type="radio" class="radio" value="2" onclick="formataOpcoes();">
			<label for="tprequis_2" class="radio"><? echo utf8ToHtml('Contínuo') ?></label>
		</div>
		
		<div id="divTaloes" style="text-align: left; margin-left: 90px;">
			<div style="height:15px;" />
			<?
			$ultimo_talao = '';
			foreach($xmlTaloes as $talao) {
				$ultimo_talao = getByTagName($talao->tags,'nrtalao');
				?> 
				<br style="clear:both" />
				<input type="checkbox" id="<?php echo $ultimo_talao; ?>" name="talao" class="rotulo" style="margin: 3px 3px 0px 3px !important; height: 13px !important;">
				<div style="text-align: left; margin-left: 20px; margin-top: 1px;">
					<? echo utf8ToHtml(' Folha ') . mascara(getByTagName($talao->tags,'nrinicial'),'###.###.#') . ' a ' . mascara(getByTagName($talao->tags,'nrfinal'),'###.###.#'); ?>
				</div>
				<?
			}
			?>
		</div>
		
		<div id="divContinuo">
			<div style="height:30px;" />
			<label for="nrinichq"><? echo utf8ToHtml('Folha Inicial:') ?></label>
			<input type="text" name="nrinichq" id="nrinichq" maxlength="9" />
			
			<label for="nrfinchq"><? echo utf8ToHtml('Final:') ?></label>
			<input type="text" name="nrfinchq" id="nrfinchq" maxlength="9" />
		</div>
		
		<br style="clear:both" />
		
		<div>
			<label for="qtreqtal"><? echo utf8ToHtml('Solicitar') ?></label>
			<input name="qtreqtal" id="qtreqtal" type="text" />
			<label Class="rotulo-linha" style="width:37px;" ><? echo utf8ToHtml('tal&otilde;es') ?></label>
		</div>
		
	</fieldset>
</form>

<div id="divBotoes" style="height:25px;">
	<a href="#" class="botao" id="btnVoltar" name="btnVoltar" onClick="voltarConteudo('divConteudoOpcao','divTalionario');return false;">Voltar</a>
	<a href="#" class="botao" id="btnContinuar" name="btnContinuar" onClick="confimaEntregaTalonario();">Entregar</a>
</div>

<script type="text/javascript">

dscShowHideDiv("divTalionario","divConteudoOpcao");

formataLayout('frmEntregaTalonarios', '<?php echo $ultimo_talao; ?>');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
