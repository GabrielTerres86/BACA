<?php 
	/************************************************************************
	 Fonte: titulos_bordero_resumo_alterar.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 10/04/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Resumo de alteração de um novo Bordero
	 Alterações:
     - 14/08/2018 | Vitor Shimada Assanuma (GFT): Rename do botão para: "Ver Detalhes da An&aacute;lise"

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

	// LISTA TODOS OS TITULOS SELECIONADOS COM AS CRITICAS E RETORNO DA IBRATAN
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <chave>".$selecionados."</chave>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","LISTAR_TITULOS_RESUMO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;
    // Se ocorrer um erro, mostra crítica
	if ($root->erro){
		echo "<script>";
       	echo 'showError("error","'.htmlentities($root->erro->registro->dscritic).'","Alerta - Aimaro","bloqueiaFundo(divRotina);");setTimeout(function(){bloqueiaFundo($(\'#divError\'))},1);';
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
								<th>Cr&iacute;ticas</th>
								<th>Restri&ccedil;&atilde;o</th>
							</tr>			
						</thead>
						<tbody>
							<?
						    	foreach($dados->find("titulos") AS $t){ ?>
						    		<tr id="titulo_<? echo $t->nrnosnum;?>" onclick="selecionaTituloResumo('<? echo $t->nrnosnum;?>');">
						    			<td>
						    				<input type='hidden' name='selecionados' value='<? echo $t->cdbandoc; ?>;<? echo $t->nrdctabb; ?>;<? echo $t->nrcnvcob; ?>;<? echo $t->nrdocmto; ?>'/><? echo $t->nrcnvcob ;?>
						    			</td>
						    			<td><? echo $t->nrdocmto;?></td>
						    			<td><? echo $t->nrinssac.' - '.$t->nmdsacad;?></td>
						    			<td><? echo $t->dtvencto;?></td>
						    			<td class="tit-bord-res-vl"><span><? echo converteFloat($t->vltitulo);?></span><? echo formataMoeda($t->vltitulo);?></td>
						    			<?
							    			$sit = $t->dssituac;
								    		if ($sit=="N") { ?>
									    		<td class='situacao-titulo'>N&atilde;o</td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td class='situacao-titulo'>Sim</td>
								    		<? }
								    		else{ ?>
									    		<td class='situacao-titulo'>N&atilde;o Analisado</td>
								    		<? }
								    	?>
						    			<?
							    			$sit = $t->sitibrat;
								    		if ($sit=="N") { ?>
									    		<td>N&atilde;o</td>
								    		<? }
								    		elseif ($sit=="S") { ?>
									    		<td>Sim</td>
								    		<? }
								    		else{ ?>
									    		<td>N&atilde;o Analisado</td>
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

<?include('criticas_bordero.php');?>
<div id="divBotoesTitulosLimite" style="margin-bottom:10px;">
	<!-- Tabela de resumo dos titulos -->
	<table class="tit-bord-resumo-valores">
		<tr>
			<td><label>Quantidade de T&iacute;tulos:</label></td>
			<td class="tit-bord-res-qtd">0</td>
			<td width="20px"></td>
			<td><label>Valor Total:</label></td>
			<td class="tit-bord-res-vltot">0,00</td>
		</tr>
	</table>

	<!-- Botoes -->
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(4,3,5,'DESCONTO DE T&Iacute;TULOS - BORDEROS');return false; " />
	<input type="button" class="botao" value="Remover T&iacute;tulo"  onClick="showConfirmacao('Deseja excluir o t&iacute;tulo do border&ocirc;?','Confirma&ccedil;&atilde;o - Aimaro','removerTituloResumo();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');"/>
	<input type="button" class="botao" value="Ver Detalhes da An&aacute;lise" onClick="mostrarDetalhesPagador();return false;"/>
	<input type="button" class="botao" value="Confirmar Altera&ccedil;&atilde;o" onClick="showConfirmacao('Confirma altera&ccedil;&atilde;o do border&ocirc;?','Confirma&ccedil;&atilde;o - Aimaro','confirmarAlteracao();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');" />
</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao1;divOpcoesDaOpcao2;divOpcoesDaOpcao3;divOpcoesDaOpcao5");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDERO - RESUMO");

	formataLayout('divResumoBordero');

	//Calcular valores do resumo
	calculaValoresResumoBordero();
	$(".tit-bord-resumo-valores").css("margin", "5px 0 5px 0");

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

    var registros = $(".divTitulos","#divResumoBordero");
    var table = registros.find(">table");
    var ordemInicial = new Array();
    table.formataTabela( ordemInicial, arrayLarguraInclusaoBordero, arrayAlinhaInclusaoBordero, '' );

	//Seleciona primeira linha ao entrar na tela
    $("#divResumoBordero .divRegistrosTitulos .tituloRegistros tr").eq(1).click();

    // //Atualizar a situacao da pagina anterior 
    $(".divRegistrosTitulosSelecionados .titulo-nao-analisado").each(function(){
     	//Pega a ID da linha e o valor novo da crítica
    	var id_linha   = $(this).parent().attr("id");
    	var novo_valor = $("#divResumoBordero .tituloRegistros tbody #"+id_linha+" .situacao-titulo").html();

    	//Atualiza na tabela da pagina anterior
    	$(this).html(novo_valor);
    })
</script>