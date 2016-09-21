<?php 

	/************************************************************************
	 Fonte: titulos_bordero.php                                       
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 02/01/2015
	                                                                  
	 Objetivo  : Mostrar opcao Borderos de descontos de Títulos        
	                                                                  	 
	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 10/08/2012 - Substituição do botão ANALISE por PRE-ANALISE (Lucas)
				 
				 02/01/2015 - Ajuste format nrborder. (Chamado 181988) - (Fabricio)
				 
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

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
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
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}		
	
?>

<div id="divBorderos">
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
				</tr>			
			</thead>
			<tbody>
				<?  for ($i = 0; $i < $qtBorderos; $i++) { 								
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
					</tr>							
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

<?php
	$dispN = (!in_array("N",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispC = (!in_array("C",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispE = (!in_array("E",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispM = (!in_array("M",$glbvars["opcoesTela"])) ? 'display:none;' : '';
	$dispL = (!in_array("L",$glbvars["opcoesTela"])) ? 'display:none;' : '';
?>

<div id="divBotoes" >
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS');carregaTitulos();return false;" />
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

formataLayout('divBorderos');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>