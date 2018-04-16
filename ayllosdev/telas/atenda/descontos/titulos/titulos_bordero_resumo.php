<?php 

	/************************************************************************
	 Fonte: titulos_bordero_resumo.php                                        
	 Autor: Alex Sandro (GFT)
	 Data : 22/03/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Resumo de um novo Bordero

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

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
		exit;
	}
	$selecionados = isset($_POST["selecionados"]) ? $_POST["selecionados"] : array();
	if(count($selecionados)==0){
		exibeErro("Selecione ao menos um t&iacute;tulo");
		exit;
	}
	$selecionados = implode($selecionados,",");

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <chave>".$selecionados."</chave>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

 	// CONSULTA DA IBRATAN	
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","SOLICITA_BIRO_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
	if ($root->erro){
		echo '<script>';
		exibeErro(htmlentities($root->erro->registro->dscritic));
		echo '</script>';
		exit;
	}
	// LISTA TODOS OS TITULOS SELECIONADOS COM AS CRITICAS E RETORNO DA IBRATAN
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <chave>".$selecionados."</chave>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // FAZER O INSERT CRAPRDR e CRAPACA
    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_TITULOS_RESUMO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
	$dados = $root->dados;
    $qtTitulos = $dados->getAttribute('QTREGIST');

    // Se ocorrer um erro, mostra mensagem
	if ($root->erro){
		echo '<script>';
		exibeErro(htmlentities($root->erro->registro->dscritic));
		echo '</script>';
		exit;
	}

	
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
								<th>Situa&ccedil;&atilde;o</th>
								<th>Restri&ccedil;&atilde;o</th>
							</tr>			
						</thead>
						<tbody>
							<?
						    	foreach($dados->find("inf") AS $t){ ?>
						    		<tr id="titulo_<? echo $t->nrnosnum;?>" onclick="selecionaTituloResumo('<? echo $t->nrnosnum;?>');">
						    			<td>
						    				<input type='hidden' name='selecionados' value='<? echo $t->cdbandoc; ?>;<? echo $t->nrdctabb; ?>;<? echo $t->nrcnvcob; ?>;<? echo $t->nrdocmto; ?>'/><? echo $t->nrcnvcob ;?>
						    			</td>
						    			<td><? echo $t->nrdocmto;?></td>
						    			<td><? echo $t->nrinssac.' - '.$t->nmdsacad;?></td>
						    			<td><? echo $t->dtvencto;?></td>
						    			<td><span><? echo converteFloat($t->vltitulo);?></span><? echo formataMoeda($t->vltitulo);?></td>
						    			<?
							    			$sit = $t->dssituac;
								    		if ($sit=="N") { ?>
									    		<td><img src='../../imagens/icones/sit_ok.png'/></td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td><img src='../../imagens/icones/sit_er.png'/></td>
								    		<? }
								    		else{ ?>
									    		<td></td>
								    		<? }
								    	?>
						    			<?
							    			$sit = $t->sitibrat;
								    		if ($sit=="N") { ?>
									    		<td><img src='../../imagens/icones/sit_ok.png'/></td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td><img src='../../imagens/icones/sit_er.png'/></td>
								    		<? }
								    		else{ ?>
									    		<td></td>
								    		<? }
								    	?>
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
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(4,3,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />
	<input type="button" class="botao" value="Remover T&iacute;tulo"  onClick="showConfirmacao('Deseja excluir o t&iacute;tulo do border&ocirc;?','Confirma&ccedil;&atilde;o - Ayllos','removerTituloResumo();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');"/>
	<input type="button" class="botao" value="Ver Detalhes" onClick="mostrarDetalhesPagador();return false;"/>
	<input type="button" class="botao" value="Confirmar Inclus&atilde;o" onClick="showConfirmacao('Confirma inclus&atilde;o do border&ocirc;?','Confirma&ccedil;&atilde;o - Ayllos','confirmarInclusao();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');" />
</div>
<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao5");

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