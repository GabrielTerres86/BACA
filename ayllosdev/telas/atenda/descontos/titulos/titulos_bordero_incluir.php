<?php 

	/************************************************************************
	 Fonte: titulos_bordero_incluir.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 22/03/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Inclusão de um novo Bordero

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	setVarSession("nmrotina","DSC TITS - BORDERO");

	// Carrega permissões do operador
	// include("../../../../includes/carrega_permissoes.php");	
	
	// setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}


	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	<tpctrlim>3</tpctrlim>";
	$xml .= "	<insitlim>2</insitlim>";
	$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","OBTEM_DADOS_CONTRATO_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    $dados = $xmlObj->roottag->tags[0]->tags[0];

    // Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErro(htmlentities($msgErro));
		exit;
	}

	$vlutiliz = getByTagName($dados->tags,'vlutiliz');
	$vllimite = getByTagName($dados->tags,'vllimite');
	$vldispon = formataMoeda(converteFloat($vllimite)-converteFloat($vlutiliz));

	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divIncluirBordero">
	<form id="formPesquisaTitulos" class="formulario">
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
		<div id="divFiltros">
			<fieldset>
				<legend>Filtrar T&iacute;tulos</legend>

				<label for="nrctrlim">Contrato</label>
			    <input type="text" id="nrctrlim" name="nrctrlim" value="<?php echo getByTagName($dados->tags,'nrctrlim') ?>"/>

				<label for="vlutiliz">Valor Descontado</label>
			    <input type="text" id="vlutiliz" name="vlutiliz" value="<?php echo formataMoeda($vlutiliz) ?>"/>

				<label for="vldispon">Limite Dispon&iacute;vel</label>
			    <input type="text" id="vldispon" name="vldispon" value="<?php echo $vldispon ?>"/>

				<label for="nrinssac">CPF/CNPJ Pagador</label>
			    <input type="text" id="nrinssac" name="nrinssac" value="<?php echo $nrinssac ?>"/>
				<a href="#" style="padding: 3px 0 0 3px;" id="btLupaPagador">
					<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
				</a>
			    <label for="nmdsacad">Nome Pagador</label>
			    <input type="text" id="nmdsacad" name="nmdsacad" value="<?php echo $nmdsacad ?>" />

			    <label for="dtvencto">Data de Vencimento</label>
			    <input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto ?>" />

			    <label for="vltitulo">Valor do T&iacute;tulo</label>
			    <input type="text" id="vltitulo" name="vltitulo" value="<?php echo $vltitulo ?>" />

			    <label for="nrnosnum">Nosso n&ordm;</label>
			    <input type="text" id="nrnosnum" name="nrnosnum" value="<?php echo $nrnosnum ?>" />

			    <br>
				<input style="float:right;" type="button" class="botao" onclick="buscarTitulosBordero();" value="Pesquisar T&iacute;tulos"/>
			</fieldset>
		</div>
		<div id="divTitulos" class="formulario">
			<fieldset>
				<legend>Selecionar T&iacute;tulos</legend>
				<div class="divRegistrosTitulos divRegistros">
					<table class="tituloRegistros">
						<thead>
							<tr>
								<th>Conv&ecirc;nio</th>
								<th>Boleto n&ordm;</th>
								<th>Pagador</th>
								<th>Vencimento</th>
								<th>Valor</th>
								<th>Situa&ccedil;&atilde;o</th>
								<th>Selecionar</th>
							</tr>			
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</fieldset>
			<fieldset>
				<legend>T&iacute;tulos Selecionados</legend>
				<div class="divRegistrosTitulosSelecionados divRegistros">
					<table class="tituloRegistros">
						<thead>
							<tr>
								<th>Conv&ecirc;nio</th>
								<th>Boleto n&ordm;</th>
								<th>Pagador</th>
								<th>Vencimento</th>
								<th>Valor</th>
								<th>Situa&ccedil;&atilde;o</th>
								<th>Remover</th>
							</tr>
						</thead>
						<tbody>
						</tbody>
					</table>
				</div>
			</fieldset>
		</div>
	</form>
</div>
<?php
	$dispA = (!in_array("A",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispX = (!in_array("X",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispC = (!in_array("C",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispE = (!in_array("E",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispM = (!in_array("M",$glbvars["opcoesTela"])) ? 'display:none;' : '';
?>

<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="carregaBorderosTitulos(); voltaDiv(3,2,4,'DESCONTO DE TÍTULOS - BORDERÔS');return false; " />
	<input type="button" class="botao" value="Continuar" onClick="mostrarBorderoResumo();return false;"/>
</div>
<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao1;divOpcoesDaOpcao2");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - INCLUIR");

	formataLayout('divIncluirBordero');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
		
		$("#btnIncluirLimite", "#divBotoesTitulosLimite").click();
		
	}


</script>