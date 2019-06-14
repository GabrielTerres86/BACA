<?php 

	/************************************************************************
	 Fonte: cheques_bordero_carregadados.php                          
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 31/05/2017
	                                                                  
	 Objetivo  : Mostrar os dados do bordero para fazer a liberação   
	             ou análise				        				   
	                                                                  	 
	 Alterações: 22/10/2010 - Ajuste na validação de permissão (David).
	 
			     11/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
				 
				 19/04/2012 - Digitalizacao (Guilherme).
				 
				 25/04/2012 - Esconder o botao de visualizar imagem dependendo
				              do campo flgdigit e tornar link de visualizacao
							  da imagem dinamico (Tiago).
							  
				 08/05/2012 - Incluido codigo cooperativa na link dinamico
				              (Tiago).
							  
				 20/06/2012 - Alterado link do viewer para passar o bordero
				              como parametro (Guilherme)
							  
				 21/11/2012 - Incluido passagem dos valores 30,71 na função 
						      liberaAnalisaBorderoDscChq e inicializado
						      as variáveis auxiliares "inconfir" (Adriano).
							  
                 02/01/2015 - Ajuste format numero contrato/bordero para 
				              consultar imagem do contrato; adequacao ao 
							  format pre-definido para nao ocorrer 
							  divergencia ao pesquisar no SmartShare.
                              (Chamado 181988) - (Fabricio)

                 20/06/2016 - Inicializacao da aux_inconfi6. (Jaison/James)

                 10/10/2016 - Remover verificacao de digitalizaco para o botao de 
							  consultar imagem (Lucas Ranghetti #510032)
                              
                 31/05/2017 - Ajuste para verificar se possui cheque custodiado
                              no dia de hoje. 
                              PRJ300- Desconto de cheque. (Odirlei-AMcom)             
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
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrborder"]) ||
		!isset($_POST["cddopcao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];
	$cddopcao = $_POST["cddopcao"];
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlGetBordero  = "";
	$xmlGetBordero .= "<Root>";
	$xmlGetBordero .= "	<Cabecalho>";
	$xmlGetBordero .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetBordero .= "		<Proc>busca_dados_bordero</Proc>";
	$xmlGetBordero .= "	</Cabecalho>";
	$xmlGetBordero .= "	<Dados>";
	$xmlGetBordero .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetBordero .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetBordero .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetBordero .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetBordero .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetBordero .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetBordero .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetBordero .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xmlGetBordero .= "		<nrborder>".$nrborder."</nrborder>";
	$xmlGetBordero .= "	</Dados>";
	$xmlGetBordero .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetBordero);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBordero = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBordero->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBordero->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$bordero  = $xmlObjBordero->roottag->tags[0]->tags[0]->tags;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
	// Carrega permissões do operador
	include("../../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);
	
?>

<form id="frmBordero" >

	<fieldset>
		<legend><? echo utf8ToHtml('Borderô:') ?></legend>
		
	<label for="dspesqui"><? echo utf8ToHtml('Pesquisa:') ?></label>
	<input type="text" name="dspesqui" id="dspesqui" value="<?php echo $bordero[9]->cdata; ?>" />
	<br />
	
	<label for="nrborder"><? echo utf8ToHtml('Borderô:') ?></label>
	<input type="text" name="nrborder" id="nrborder" value="<?php echo formataNumericos('z.zzz.zz9',$bordero[0]->cdata,'.'); ?>" />
	
	<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>
	<input type="text" name="nrctrlim" id="nrctrlim" value="<?php echo formataNumericos('z.zzz.zz9',$bordero[1]->cdata,'.'); ?>" />
	<br />
	
	<label for="dsdlinha"><? echo utf8ToHtml('Linha de descontos:') ?></label>
	<input type="text" name="dsdlinha" id="dsdlinha" value="<?php echo $bordero[10]->cdata; ?>" />
	<br />
			
	<label for="qttitulo"><? echo utf8ToHtml('Qtd. Cheques:') ?></label>
	<input type="text" name="qttitulo" id="qttitulo" value="<?php echo formataNumericos('zzz.zz9',$bordero[7]->cdata,'.'); ?>" />
	
	<label for="dsopedig"><? echo utf8ToHtml('Digitado Por:') ?></label>
	<input type="text" name="dsopedig" id="dsopedig" value="<?php echo $bordero[12]->cdata; ?>" />
	<br />
	
	<label for="vltitulo"><? echo utf8ToHtml('Valor:') ?></label>
	<input type="text" name="vltitulo" id="vltitulo" value="<?php echo number_format(str_replace(",",".",$bordero[8]->cdata),2,",","."); ?>" />
	<br />
	
	<label for="txmensal"><? echo utf8ToHtml('Taxa mensal:') ?></label>
	<input type="text" name="txmensal" id="txmensal" value="<?php echo number_format(str_replace(",",".",$bordero[3]->cdata),6,",","."). " %"; ?>" />
	
	<label for="dtlibbdt"><? echo utf8ToHtml('Liberado em:') ?></label>
	<input type="text" name="dtlibbdt" id="dtlibbdt" value="<?php echo $bordero[5]->cdata; ?>" />
	<br />
	
	<label for="txdiaria"><? echo utf8ToHtml('Taxa Diária:') ?></label>
	<input type="text" name="txdiaria" id="txdiaria" value="<?php echo number_format(str_replace(",",".",$bordero[6]->cdata),7,",","."). " %"; ?>" />
	
	<label for="dsopelib"><? echo utf8ToHtml('') ?></label>
	<input type="text" name="dsopelib" id="dsopelib" value="<?php echo $bordero[11]->cdata; ?>" />
	<br />
	
	<label for="txjurmor"><? echo utf8ToHtml('Taxa de Mora:') ?></label>
	<input type="text" name="txjurmor" id="txjurmor" value="<?php echo number_format(str_replace(",",".",$bordero[4]->cdata),7,",","."). " %"; ?>" />
	
	</fieldset>
</form>
<div>
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(3,2,4,'DESCONTO DE CHEQUES - BORDER&Ocirc;S');return false;" />
	<? if ($cddopcao == "C") { ?>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/visualizar_cheques.gif" onClick="carregaChequesBorderoDscChq();return false;" />		
		
				<a href="http://<?php echo $GEDServidor;?>/smartshare/clientes/viewerexterno.aspx?tpdoc=<?php echo $bordero[14]->cdata; ?>&conta=<?php echo formataContaDVsimples($nrdconta); ?>&bordero=<?php echo formataNumericos('z.zzz.zz9',$bordero[0]->cdata,'.'); ?>&cooperativa=<?php echo $glbvars["cdcooper"]; ?>" target="_blank"><img src="<? echo $UrlImagens; ?>botoes/consultar_imagem.gif" /></a>
		
	<? } ?>
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2");

// Muda o título da tela
<?php if ($cddopcao <> "C") { ?>
$("#tdTitRotina").html("DADOS DO BORDER&Ocirc;");
<?php } else { ?>
$("#tdTitRotina").html("CONSULTA DE BORDER&Ocirc;");
<?php } ?>

formataLayout('frmBordero');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php if ($cddopcao == "N") { ?>
			aux_inconfir = 1; 
			aux_inconfi2 = 11; 
			aux_inconfi3 = 21; 
			aux_inconfi4 = 71; 
			aux_inconfi5 = 30; 
			aux_inconfi6 = 51;
			liberaAnalisaBorderoDscChq('N','1','11','21','71','30','51','1','0');
<?php } elseif ($cddopcao == "L") { ?>
			aux_inconfir = 1; 
			aux_inconfi2 = 11; 
			aux_inconfi3 = 21; 
			aux_inconfi4 = 71; 
			aux_inconfi5 = 30; 
			aux_inconfi6 = 51;
			showConfirmacao("Deseja liberar o border&ocirc; de desconto de cheques?","Confirma&ccedil;&atilde;o - Aimaro","liberaAnalisaBorderoDscChq('L','1','11','21','71','30','51','1','0')","metodoBlock()","sim.gif","nao.gif");
<?php } elseif ($cddopcao == "E") { ?>
			showConfirmacao("Deseja excluir o border&ocirc; de desconto de cheques?","Confirma&ccedil;&atilde;o - Aimaro","ValidExcluirBorderoDscChq()","metodoBlock()","sim.gif","nao.gif");
<?php } ?>
</script>
