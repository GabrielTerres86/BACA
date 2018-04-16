<?php 
	/************************************************************************
	 Fonte: titulos_bordero_resumo_resgatar.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 14/04/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Resumo de titulos a serem resgatados

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
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
		exit;
	}
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Contrato inv&aacute;lida.");
		exit;
	}

	$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
	if(count($selecionados)==0){
		exibeErro("Selecione ao menos um t&iacute;tulo");
		exit;
	}
	$selecionados = implode($selecionados,",");

	// LISTA TODOS OS TITULOS SELECIONADOS COM AS CRITICAS E RETORNO DA IBRATAN
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <nrnosnum>".$selecionados."</nrnosnum>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_TITULOS_RESUMO_RESGATAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    // Se ocorrer um erro, mostra crítica
	if ($root->erro){
		echo "<script>";
       	echo 'showError("error","'.htmlentities($root->erro->registro->dscritic).'","Alerta - Ayllos","bloqueiaFundo(divRotina);");setTimeout(function(){bloqueiaFundo($(\'#divError\'))},1);';
		echo "</script>";
		exit;
	}
	$dados = $root->dados;
	$qtTitulos = $root->dados->getAttribute("qtregist");	
?>

<div id="divResumoBordero">

	<form id="formPesquisaTitulos" class="formulario">
		<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />
		
		<div id="divTitulos" class="formulario">
			<fieldset>
				<legend>Resumo</legend>
				<div class="divRegistrosTitulos divRegistros">
					<table class="tituloRegistros">
						<thead>
							<tr>
								<th>Conv&ecirc;nio</th>
								<th>Boleto n&ordm;</th>
								<th>Nome Pagador</th>
								<th>Data Vencimento</th>
								<th>Valor do T&iacute;tulo</th>
								<th>Border&ocirc;</th>
								<th>Data Libera&ccedil;&atilde;o</th>
							</tr>			
						</thead>
						<tbody>
							<?
						    	foreach($dados->find("inf") AS $t){ ?>
						    		<tr id="titulo_<? echo $t->nrnosnum;?>" onclick="selecionaTituloResumo('<? echo $t->nrnosnum;?>');">
						    			<td><input type='hidden' name='selecionados' value='<? echo $t->nrnosnum;?>'/><? echo $t->nrcnvcob;?></td>
						    			<td><? echo $t->nrdocmto;?></td>
						    			<td><? echo $t->nrinssac.' - '.$t->nmdsacad;?></td>
						    			<td><? echo $t->dtvencto;?></td>
						    			<td><span><? echo converteFloat($t->vltitulo);?></span><? echo formataMoeda($t->vltitulo);?></td>
										<td><? echo $t->nrborder?></td>
						    			<td><? echo $t->dtlibbdt; ?></td>
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
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(4,2,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />
	<input type="button" class="botao" value="Remover T&iacute;tulo"  onClick="showConfirmacao('Deseja excluir o t&iacute;tulo do border&ocirc;?','Confirma&ccedil;&atilde;o - Ayllos','removerTituloResumo();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');"/>
	<input type="button" class="botao" value="Confirmar Resgate" onClick="showConfirmacao('Confirma resgate dos t&iacute;tulos selecionados?','Confirma&ccedil;&atilde;o - Ayllos','confirmarResgate();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');" />
</div>
<script type="text/javascript">
	//dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao5");

	dscShowHideDiv("divOpcoesDaOpcao1","divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao4;divOpcoesDaOpcao5");


	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - RESUMO");

	formataLayout('divResumoBordero');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

    var registros = $(".divTitulos","#divResumoBordero");
    var table = registros.find(">table");
    var ordemInicial = new Array();
    table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );


</script>