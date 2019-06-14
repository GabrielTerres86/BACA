<?php 
	/************************************************************************
	 Fonte: titulos_bordero_alterar.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 09/04/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Alteração de um novo Bordero
	 Alteração :
	  - 09/08/2018 - Vitor Shimada Assanuma(GFT) - Inclusão do parametro vindo da #TAB052 de quantidade máxima de títulos por borderô
	  - 23/11/2018 - Luis Fernando (GFT) - Removido teste de não permitir outro operador alterar o bordero
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

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"] ))  {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	// Verifica se o número do borderô é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("Border&ocirc; inv&aacute;lido.");
	}


	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","BUSCAR_DADOS_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    // Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}

	$dados 		= $root->dados;
	$contrato 	= $dados->contrato;
	$bordero 	= $dados->bordero;
	$titulos 	= $dados->findFirst("titulos");
	$quantidade = $titulos->getAttribute("qtregist");
	$arrTitulos = $titulos->find("titulo");
	$qtmaxtit   = $bordero->qtmaxtit;

	$vlutiliz = $contrato->vlutiliz;
	$vllimite = $contrato->vllimite;
	$pctolera = $contrato->pctolera;
	$dtfimvig = $contrato->dtfimvig;


	if (diffData($dtfimvig,$glbvars["dtmvtolt"])<0){
		exibeErro("Data de vig&ecirc;ncia do contrato deve ser maior que a data de movimenta&ccedil;&atilde;o do sistema");
	}
	$pctolera = $pctolera ? $pctolera : 0;

	$vldispon = formataMoeda(converteFloat($vllimite)-converteFloat($vlutiliz));
	$vlsaldor = formataMoeda(converteFloat($vllimite)-converteFloat($vlutiliz)-converteFloat($bordero->vltitulo));
	// Função para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>

<div id="divIncluirBordero">
	<form id="formPesquisaTitulos" class="formulario">
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
		<input type="hidden" id="pctolera" name="pctolera" value="<? echo $pctolera; ?>" />
		<input type="hidden" id="vllimite" name="vllimite" value="<? echo $vllimite; ?>" />
		<div id="divFiltros">
			<fieldset id="divDadosContrato">
				<legend>Dados do Border&ocirc;</legend>
				<label for="nrborder">N&uacute;mero do Border&ocirc;</label>
			    <input type="text" id="nrborder" name="nrborder" value="<?php echo $bordero->nrborder?>"/>

				<label for="nrctrlim">Contrato</label>
			    <input type="text" id="nrctrlim" name="nrctrlim" value="<?php echo $contrato->nrctrlim ?>"/>

				<label for="vlutiliz">Valor Descontado</label>
			    <input type="text" id="vlutiliz" name="vlutiliz" value="<?php echo formataMoeda($vlutiliz) ?>"/>

				<label for="vldispon">Limite Dispon&iacute;vel</label>
			    <input type="text" id="vldispon" name="vldispon" value="<?php echo $vldispon ?>"/>

				<label for="qtseleci">Quantidade T&iacute;tulos</label>
			    <input type="text" id="qtseleci" name="qtseleci" value="<?php echo $bordero->qttitulo ?>"/>

				<label for="vlseleci">Valor T&iacute;tulos</label>
			    <input type="text" id="vlseleci" name="vlseleci" value="<?php echo formataMoeda($bordero->vltitulo) ?>"/>

				<label for="vlsaldor">Saldo Restante</label>
			    <input type="text" id="vlsaldor" name="vlsaldor" value="<?php echo $vlsaldor ?>"/>
			</fieldset>
			<fieldset>
				<legend>Filtrar T&iacute;tulos</legend>

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
								<th>Cr&iacute;ticas</th>
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
								<th>Cr&iacute;ticas</th>
								<th>Remover</th>
							</tr>
						</thead>
						<tbody>
							<?
						    	foreach($arrTitulos AS $t){ ?>
						    		<tr id="titulo_<? echo $t->nrnosnum;?>" onclick="selecionaTituloResumo('<? echo $t->nrnosnum;?>');">
						    			<td>
						    				<input type='hidden' name='selecionados' value='<? echo $t->cdbandoc; ?>;<? echo $t->nrdctabb; ?>;<? echo $t->nrcnvcob; ?>;<? echo $t->nrdocmto; ?>'/><? echo $t->nrcnvcob ;?>
						    				<input type='hidden' name='vltituloselecionado' value='<? echo formataMoeda($t->vltitulo)?>'/>
						    			</td>
						    			<td><? echo $t->nrdocmto;?></td>
						    			<td><? echo $t->nrinssac.' - '.$t->nmsacado;?></td>
						    			<td><? echo $t->dtvencto;?></td>
						    			<td><span><? echo converteFloat($t->vltitulo);?></span><? echo formataMoeda($t->vltitulo);?></td>
						    			<?
							    			$sit = $t->dssituac;
								    		if ($sit=="N") { ?>
									    		<td>N&atilde;o</td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td>Sim</td>
								    		<? }
								    		else{ ?>
									    		<td class="titulo-nao-analisado">N&atilde;o Analisado</td>
								    		<? }
								    	?>
								    	<td class='botaoSelecionar' onclick='removeTituloBordero($(this));'><button type='button' class='botao'>Remover</button></td>
						    		</tr>
						    	<? }
					    	?>
						</tbody>
					</table>
				</div>
			</fieldset>
		</div>
	</form>
</div>

<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<input type="button" class="botao" value="Voltar"  onClick="carregaBorderosTitulos(); voltaDiv(3,2,4,'DESCONTO DE TÍTULOS - BORDERÔS');return false; " />
	<input type="button" class="botao" value="Continuar" onClick="mostrarBorderoResumoAlterar();return false;"/>
</div>
<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao1;divOpcoesDaOpcao2");

	//Envio para o Javascript da quantidade máxima de títulos por borderô
	qtmaxtit = <?=$qtmaxtit?>;
	
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