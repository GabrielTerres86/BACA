<?php 

	/************************************************************************
	 Fonte: titulos_bordero.php                                       
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração:26/07/2019
	                                                                  
	 Objetivo  : Mostrar opcao Borderos de descontos de Títulos        
	                                                                  	 
	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 10/08/2012 - Substituição do botão ANALISE por PRE-ANALISE (Lucas)
				 
				 02/01/2015 - Ajuste format nrborder. (Chamado 181988) - (Fabricio)
				 
				 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).

				 17/04/2018 - Ajustes nos processos de análise e liberação de borderô (Lucas Lazari - GFT)

				 28/04/2018 - Inclusão de novas colunas na grid de borderô e migrado chamada de progress para oracle (Alex Sandro  - GFT)

				 07/05/2018 - Adicionada verificação para definir se o bordero vai seguir o fluxo novo ou o antigo (Luis Fernando - GFT)

				 05/09/2018 - Adicionado campo de prejuizo para o bordero (Luis Fernando - GFT)

				 11/03/2019 - Adicionada coluna Rating dos Limites de Desconto de Cheque e de Desconto de Título (Luiz Otávio Olinger Momm - AMCOM)

				 12/03/2019 - Adicionada coluna Rating dos Limites de Desconto de Cheque e de Desconto de Título (Luiz Otávio Olinger Momm - AMCOM)

				 08/05/2019 - Corrigido problema na função selecionaBorderoTitulos que faltou parâmetros. (Luiz Otávio Olinger Momm - AMCOM)

				 24/05/2019 - P450 - Removido mensageiria para pesquisa de rating por proposta (Luiz Otávio Olinger Momm - AMCOM).

				 26/07/2019 - P450 - Ajustado tamanhos dos retornos de status para não quebrar a tabela
                                              (Luiz Otávio Olinger Momm - AMCOM).

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
	include("../../../../includes/carrega_permissoes.php");
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$executandoProdutos = $_POST['executandoProdutos'];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	/* Verifica se está em contingencia */
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","CONTINGENCIA_IBRATAN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibirErro('error',$root->erro->registro->dscritic->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)');
		exit;
	}
	$flctgest = $root->dados->flctgest;
	
	/*Verifica se o borderô deve ser utilizado no sistema novo ou no antigo*/
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","VIRADA_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	}
	$flgverbor = $root->dados->flgverbor->cdata;

	if($flgverbor){
		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","BUSCA_BORDEROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObjBorderos = getClassXML($xmlResult);
	}
	else{ // busca o bordero do progress
		// Monta o xml de requisição
		$xmlGetBorderos  = "";
		$xmlGetBorderos .= "<Root>";
		$xmlGetBorderos .= "	<Cabecalho>";
		$xmlGetBorderos .= "		<Bo>b1wgen0030.p</Bo>";
		$xmlGetBorderos .= "		<Proc>busca_borderos</Proc>";
		$xmlGetBorderos .= "	</Cabecalho>";
		$xmlGetBorderos .= "	<Dados>";
		$xmlGetBorderos .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetBorderos .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlGetBorderos .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlGetBorderos .= "	</Dados>";
		$xmlGetBorderos .= "</Root>";
			
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetBorderos);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjBorderos = getObjectXML($xmlResult);
	}
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBorderos->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBorderos->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$borderos   = $xmlObjBorderos->roottag->tags[0]->tags;
	$qtBorderos = count($borderos);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}		
	
?>

<?php
	$dispN = (!in_array("N",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispI = (!in_array("I",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispR = (!in_array("R",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispA = (!in_array("A",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispC = (!in_array("C",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispE = (!in_array("E",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispM = (!in_array("M",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispL = (!in_array("L",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispP = (!in_array("P",$glbvars["opcoesTela"])) ? 'display:none;' : '';
?>
<? if($flgverbor){ ?>
	<div id="divBorderosTitulos">
		<div class="divRegistros">
			<table>
				<thead>
					<tr>
						<th>Data Proposta</th>
						<th>Border&ocirc;</th>
						<th>Contrato</th>
						<th>Qt.Tits</th>
						<th>Valor</th>
						<th>Qtd. Apr.</th>
						<th>Valor Apr.</th>
						<th>Situa&ccedil;&atilde;o do Border&ocirc;</th>
						<th>Decis&atilde;o da An&aacute;lise</th>
						<th>Data Libera&ccedil;&atilde;o</th>
						<!-- 12/03/2019 -->
						<th>Rating</th>
						<!-- 12/03/2019 -->
					</tr>			
				</thead>
				<tbody>
					<?
						for ($i = 0; $i < $qtBorderos; $i++) {
							$cor = "";

							$rating = $borderos[$i]->tags[11]->cdata;					
							$mtdClick = "selecionaBorderoTitulos('".($i + 1)."','".$qtBorderos."','".($borderos[$i]->tags[1]->cdata)."','".($borderos[$i]->tags[2]->cdata)."','".($borderos[$i]->tags[7]->cdata)."',".$borderos[$i]->tags[10]->cdata.");";

						?>
						<tr id="trBordero<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
						
							<td><? echo $borderos[$i]->tags[0]->cdata; ?></td>
							
							<td><span><? echo $borderos[$i]->tags[1]->cdata ?></span>
								<? echo formataNumericos('z.zzz.zzz',$borderos[$i]->tags[1]->cdata,'.'); ?></td>
							
							<td><span><? echo $borderos[$i]->tags[2]->cdata ?></span>
								<? echo formataNumericos('z.zzz.zzz',$borderos[$i]->tags[2]->cdata,'.'); ?></td>
							
							<td><span><? echo $borderos[$i]->tags[3]->cdata ?></span>
								<? echo formataNumericos('zzz.zzz',$borderos[$i]->tags[3]->cdata,'.'); ?></td>
							
							<td><span><? echo $borderos[$i]->tags[4]->cdata ?></span>
								<? echo number_format(str_replace(",",".",$borderos[$i]->tags[4]->cdata),2,",","."); ?></td>

							<td><? echo $borderos[$i]->tags[5]->cdata; ?></td>
							<td><span><? echo $borderos[$i]->tags[6]->cdata ?></span>
								<? echo number_format(str_replace(",",".",$borderos[$i]->tags[6]->cdata),2,",","."); ?></td>
							
							<td><? echo ucfirst(strtolower($borderos[$i]->tags[7]->cdata)); ?></td>
							<td><? echo wordwrap(ucfirst(strtolower($borderos[$i]->tags[8]->cdata)), 15, "<br />\n"); ?></td>
							<td><? echo wordwrap(ucfirst(strtolower($borderos[$i]->tags[9]->cdata)), 15, "<br />\n"); ?></td>
							<!-- 12/03/2019 -->
							<td><? echo $rating; ?></td>
							<!-- 12/03/2019 -->
						</tr>							
					<?} // Fim do for ?>			
				</tbody>
			</table>
		</div>
	</div>

	<div id="divBotoes">
		
		<?if($executandoProdutos == 'true'){?>
			<input type="button" class="botao" value="Voltar" onClick="encerraRotina(true);return false;"/>
			
		<?}else{?>
			<input type="button" class="botao" value="Voltar" onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false;"/>
		
		<?}?>
		<input type="button" class="botao" value="Incluir" onClick="mostrarBorderoIncluir();return false;" style="<?php echo $dispI;?>"  />
		<input type="button" class="botao" value="Consultar" <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispC.'" onClick="return false;"'; } else { echo 'style="'.$dispC.'" onClick="mostraDadosBorderoDscTit(\'C\');return false;"'; } ?> />
		<input type="button" class="botao" value="Rejeitar"  <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispR.'" onClick="return false;"'; } else { echo 'style="'.$dispR.'" onClick="mostrarBorderoRejeitar('.$flctgest.');return false;"'; } ?> />
		<input type="button" class="botao" value="Alterar"  onClick="mostrarBorderoAlterar();return false;" style="<?php echo $dispI;?>" />
		<input type="button" class="botao" value="Analisar" <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispN.'" onClick="return false;"'; } else { echo 'style="'.$dispN.'" onClick="mostrarBorderoAnalisar();return false;"'; } ?> />
		<input type="button" class="botao" value="Imprimir" <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispM.'" onClick="return false;"'; } else { echo 'style="'.$dispM.'" onClick="mostraImprimirBordero();return false;"'; } ?> />
		<input type="button" class="botao" value="Liberar"  <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispL.'" onClick="return false;"'; } else { echo 'style="'.$dispL.'" onClick="mostrarBorderoLiberar();return false;"'; } ?> />
		<input type="button" id="btnPagar" class="botao" value="Pagar"  <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispP.'" onClick="return false;"'; } else { echo 'style="'.$dispP.'" onClick="mostrarBorderoPagar();return false;"'; } ?> />

	</div>

	<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDER&Ocirc;S");

	formataLayout('divBorderosTitulos');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	//habilitaBotaoLiberar(botaoLiberar);

	function habilitaBotaoLiberar(botaoLiberar){

	    if(botaoLiberar == 'S'){

	        var Inputs4 = $('input[type="button"][value=Liberar]');
	        Inputs4.removeAttr( 'style' );

	    } else {

	        var Inputs4 = $('input[type="button"][value=Liberar]');
	        Inputs4.css({'color':'gray'});
	        Inputs4.css({'cursor':'default'});
	        Inputs4.css({'pointer-events':'none'});
	    }
	}

	</script>
<?}
else{
?>
	<div id="divBorderosTitulos">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Data</th>
					<th>Border&ocirc;</th>
					<th>Contrato</th>
					<th>Qt.Tits</th>
					<th>Valor</th>
					<th>Situa&ccedil;&atilde;o</th>
					<!-- 11/03/2019 -->
					<th>Rating</th>
					<!-- 11/03/2019 -->
					<th style="display:none;"></th>
					<th style="display:none;"></th>
				</tr>			
			</thead>
			<tbody>
				<?
					for ($i = 0; $i < $qtBorderos; $i++) {
						$cor = "";
						$mtdClick = "selecionaBorderoTitulos('".($i + 1)."','".$qtBorderos."','".($borderos[$i]->tags[1]->cdata)."','".($borderos[$i]->tags[2]->cdata)."');";
					?>
					<tr id="trBordero<? echo $i + 1; ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
					
						<td><? echo $borderos[$i]->tags[0]->cdata; ?></td>
						
						<td><span><? echo $borderos[$i]->tags[1]->cdata ?></span>
							<? echo formataNumericos('z.zzz.zzz',$borderos[$i]->tags[1]->cdata,'.'); ?></td>
						
						<td><span><? echo $borderos[$i]->tags[2]->cdata ?></span>
							<? echo formataNumericos('z.zzz.zzz',$borderos[$i]->tags[2]->cdata,'.'); ?></td>
						
						<td><span><? echo $borderos[$i]->tags[3]->cdata ?></span>
							<? echo formataNumericos('zzz.zzz',$borderos[$i]->tags[3]->cdata,'.'); ?></td>
						
						<td><span><? echo $borderos[$i]->tags[4]->cdata ?></span>
							<? echo number_format(str_replace(",",".",$borderos[$i]->tags[4]->cdata),2,",","."); ?></td>
						
						<td><? echo $borderos[$i]->tags[5]->cdata; ?></td>
                        
						<!-- 11/03/2019 -->
						<td></td>
						<!-- 11/03/2019 -->
						<td style="display:none;"></td>
						<td style="display:none;"></td>
					</tr>							
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes" >
	<?if($executandoProdutos == 'true'){?>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;" />
	<?}else{?>
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false;" />
	<?}?>
		
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pre-analise.gif"  <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispN.'" onClick="return false;"'; } else { echo 'style="'.$dispN.'" onClick="mostraDadosBorderoDscTit(\'N\');return false;"'; } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/consultar.gif" <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispC.'" onClick="return false;"'; } else { echo 'style="'.$dispC.'" onClick="mostraDadosBorderoDscTit(\'C\');return false;"'; } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/excluir.gif"   <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispE.'" onClick="return false;"'; } else { echo 'style="'.$dispE.'" onClick="mostraDadosBorderoDscTit(\'E\');return false;"'; } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif"  <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispM.'" onClick="return false;"'; } else { echo 'style="'.$dispM.'" onClick="mostraImprimirBordero();return false;"'; } ?> />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/liberar.gif"   <?php if ($qtBorderos == 0) { echo 'style="cursor: default;'.$dispL.'" onClick="return false;"'; } else { echo 'style="'.$dispL.'" onClick="mostraDadosBorderoDscTit(\'L\');return false;"'; } ?> />
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");
// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - BORDER&Ocirc;S");
	formataLayout('divBorderosTitulos');
// Esconde mensagem de aguardo
hideMsgAguardo();
// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
<?}?>
