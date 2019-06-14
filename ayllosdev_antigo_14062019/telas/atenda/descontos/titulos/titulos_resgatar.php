<?php 
	/************************************************************************
	 Fonte: titulos_resgatar.php                                        
	 Autor: Luis Fernando (GFT)
	 Data : 14/04/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Resgate de títulos de borderôes
	 Alterações: 
	  - 13/08/2018 - Vitor Shimada Assanuma (GFT) - Remoção do cabeçalho e verificação do número de contrato de limite no resgate.

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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrlim"] ))  {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("Contrato inv&aacute;lido.");
	}

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
			<fieldset>
				<legend>Filtrar T&iacute;tulos</legend>

			    <label for="nrborder">Border&ocirc;</label>
			    <input type="text" id="nrborder" name="nrborder" value="<?php echo $nrborder ?>" />

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
				<input style="float:right;" type="button" class="botao" onclick="buscarTitulosResgatar();" value="Pesquisar T&iacute;tulos"/>
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
								<th>Border&ocirc;</th>
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
								<th>Border&ocirc;</th>
								<th>Remover</th>
							</tr>
						</thead>
						<tbody>
							<?
						    	foreach($arrTitulos AS $t){ ?>
						    		<tr id="titulo_<? echo $t->nrnosnum;?>" onclick="selecionaTituloResumo('<? echo $t->nrnosnum;?>');">
						    			<td>
						    				<input type='hidden' name='selecionados' value='<? echo $t->nrnosnum;?>'/><? echo $t->nrcnvcob;?>
						    				<input type='hidden' name='vltituloselecionado' value='<? echo formataMoeda($t->vltitulo)?>'/>
						    			</td>
						    			<td><? echo $t->nrdocmto;?></td>
						    			<td><? echo $t->nrinssac.' - '.$t->nmsacado;?></td>
						    			<td><? echo $t->dtvencto;?></td>
						    			<td><span><? echo converteFloat($t->vltitulo);?></span><? echo formataMoeda($t->vltitulo);?></td>
						    			<td><? echo $t->nrborder; ?></td>
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
	<input type="button" class="botao" value="Voltar"  onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false; " />
	<input type="button" class="botao" value="Continuar" onClick="mostrarBorderoResumoResgatar();return false;"/>
</div>
<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

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

    var rNrborder = $("label[for='nrborder']");
	rNrborder.css({'width': '112px'}).addClass('rotulo-linha');
	var cNrborder = $("#nrborder", "#divIncluirBordero");
	cNrborder.css({'width': '114px'}).addClass('inteiro').habilitaCampo();

    cNrborder.unbind('keypress').bind('keypress', function(e) {
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            $("#nrdconta", "#divIncluirBordero").focus();
            return false;
        }
    });

	var cNrnosnum = $("#nrnosnum", "#divIncluirBordero");
    cNrnosnum.unbind('keypress').bind('keypress', function(e) {
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            buscarTitulosResgatar();
            return false;
        }
    });
</script>