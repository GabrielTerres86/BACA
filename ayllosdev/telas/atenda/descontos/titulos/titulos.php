<?php 

	/***************************************************************************
	 Fonte: titulos.php
	 Autor: Guilherme
	 Data : Novembro/2008                 Última Alteração: 25/04/2018

	 Objetivo  : Mostrar opção Títulos da Rotina de Desconto de Títulos

	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 18/11/2011 - Ajustes para nao mostrar botao quando nao tiver permissao (Jorge)
				 
				 09/07/2012 - Inclusão de campos no form para listagem de 
                              informações de títulos descontados com e sem
                              registro (Lucas).

                 26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM / P364).

                 07/03/2018 - Novo campo 'Data Renovação' (Leonardo Oliveira - GFT)

                 13/03/2018 - Ajuste nos botões da tela, novo campo 'Renovação' e novo input perrenov do tipo hidden. (Leonardo Oliveira - GFT)

				 16/03/2018 - Novos campos flgstlcr e cddlinha, ambos do tipo hidden. (Leonardo Oliveira - GFT)

				 28/03/2018 - Novos botões Contratos e Propostas. (Andre Avila - GFT)

				 12/04/2018 - Criação do botão manutenção e ajuste no tamanho da tela. (Leonardo Oliveira - GFT)

 				 25/04/2018 - Alterado o comportamento dos botões na <div id="divBotoes" >, por definicção do cliente os mesmos devem ser ocultados caso o usuário não possua permissão. (Andre Avila - GFT)

				 07/05/2018 - Adicionada verificação para definir se o bordero vai seguir o fluxo novo ou o antigo (Luis Fernando - GFT)

				 16/07/2019 - Novo botão 'Últimas Alterações'. PRJ 438 - Sprint 16 (Mateus Z / Mouts)
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
	
	setVarSession("nmrotina","DSC TITS");
	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se os parêmetros necessários foram informados
	if (!isset($_POST["nrdconta"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$executandoProdutos = $_POST['executandoProdutos'];
	$cdproduto = $_POST['cdproduto'];
	
	// Monta o xml de requisição
	$xmlDesctoTit  = "";
	$xmlDesctoTit .= "<Root>";
	$xmlDesctoTit .= "	<Cabecalho>";
	$xmlDesctoTit .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlDesctoTit .= "		<Proc>busca_dados_dsctit</Proc>";
	$xmlDesctoTit .= "	</Cabecalho>";
	$xmlDesctoTit .= "	<Dados>";
	$xmlDesctoTit .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDesctoTit .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDesctoTit .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDesctoTit .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDesctoTit .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDesctoTit .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDesctoTit .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDesctoTit .= "	</Dados>";
	$xmlDesctoTit .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDesctoTit);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDscTit = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDscTit->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDscTit->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDscTit->roottag->tags[0]->tags[0]->tags;
		
	
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

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>

<form id="frmTitulos">
	<fieldset>
		<legend><? echo utf8ToHtml('Títulos') ?></legend>
		
		<input type="hidden" name="hd_perrenov" id="hd_perrenov" value="<?php echo $dados[14]->cdata; ?>" />
		<input type="hidden" name="flgstlcr" id="flgstlcr" value="<?php echo $dados[15]->cdata; ?>" />
		<input type="hidden" name="cddlinha" id="cddlinha" value="<?php echo $dados[16]->cdata; ?>" />

		<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>
		<input type="text" name="nrctrlim" id="nrctrlim" value="<?php echo formataNumericos('zzz.zzz.zz9',$dados[0]->cdata,'.'); ?>" />
		
		<label for="dtinivig"><? echo utf8ToHtml('Início:') ?></label>
		<input type="text" name="dtinivig" id="dtinivig" value="<?php echo $dados[1]->cdata; ?>" />
		
		<label for="qtdiavig"><? echo utf8ToHtml('Vigência:') ?></label>
		<input type="text" name="qtdiavig" id="qtdiavig" value="<?php echo $dados[2]->cdata; if ($dados[2]->cdata > 1) { echo " dias"; } else { echo " dia"; } ?>" />
		<br />
		
		<label for="vllimite"><? echo utf8ToHtml('Limite:') ?></label>
		<input type="text" name="vllimite" id="vllimite" value="<?php echo number_format(str_replace(",",".",$dados[3]->cdata),2,",","."); ?>" />
		
		<label for="qtrenova"><? echo utf8ToHtml('Renovado por:') ?></label>
		<input type="text" name="qtrenova" id="qtrenova" value="<?php echo $dados[4]->cdata; if ($dados[4]->cdata > 1) { echo " vezes"; } else { echo " vez"; } ?>" />
		<br />
		
		<label for="dsdlinha"><? echo utf8ToHtml('Linha de descontos:') ?></label>
		<input type="text" name="dsdlinha" id="dsdlinha" value="<?php echo $dados[5]->cdata; ?>" />
		<br />
		
		<label for="vlutilcr"><? echo utf8ToHtml('Valor utilizado (Registrada):') ?></label>
		<input type="text" name="vlutilcr" id="vlutilcr" value="<?php echo number_format(str_replace(",",".",$dados[10]->cdata),2,",",".") . " (". $dados[9]->cdata; if ($dados[9]->cdata > 1) { echo " t&iacute;tulos)"; } else { echo " t&iacute;tulos)"; } ?>" />
		<br />
		
		<label for="vlutilsr"><? echo utf8ToHtml('Valor utilizado (Sem Registro):') ?></label>
		<input type="text" name="vlutilsr" id="vlutilsr" value="<?php echo number_format(str_replace(",",".",$dados[12]->cdata),2,",",".") . " (". $dados[11]->cdata; if ($dados[11]->cdata > 1) { echo " t&iacute;tulos)"; } else { echo " t&iacute;tulos)"; } ?>" />
		<br />
		
		<label for="dtrenova"><? echo utf8ToHtml('Data Renovação: ') ?></label>
		<input type="text" name="dtrenova" id="dtrenova" value="<?php echo $dados[13]->cdata ?>"/>
		<br />

		<label for="dtultmnt"><? echo utf8ToHtml('Data Manutenção: ') ?></label>
		<input 
			type="text"
			name="dtultmnt"
			id="dtultmnt"
			value="
			<?php
				echo getByTagName($dados,"dtultmnt");
			?>"/>
		<br />
		
	</fieldset>
</form>

<div id="divBotoes" >

	<a
		href="#"
		class="botao" 
		name="btnvoltar"
		id="btnvoltar"
		onClick="voltaDiv(1,0,4,'DESCONTOS','DESCONTOS');return false;" >
			Voltar
	</a>
	<a
		href="#"
		class="botao" 
		type="image" 
		name="btnbordero" 
		id="btnbordero"
	 	<?php 
			if (!in_array("DSC TITS - BORDERO",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } 
			else { echo 'onClick="carregaBorderosTitulos();return false;"'; } ?> 
	>
		Border&ocirc;s
	</a>


	<a
	href="#"
	class="botao"
	type="image"
	name="btnlimite"
	id="btnlimite"
	 <?php if (!in_array("DSC TITS - CONTRATO",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } 
		else { echo 'onClick="carregaLimitesTitulos();return false;"'; } ?> 
	>
		Contratos
	</a>

	<a
		href="#"
		class="botao" 
		type="image" 
		name="btnpropostas" 
		id="btnpropostas"

	 <?php if (!in_array("DSC TITS - PROPOSTA",$rotinasTela)) { echo 'style="cursor: default;display:none;" onClick="return false;"'; } 
		else { echo 'onClick="carregaLimitesTitulosPropostas();return false;"'; } ?> 
	>
			Propostas
	</a>

	<a 
		href="#" 
		class="botao"
		id="btnrenovacao"
		name="btnrenovacao"
		<?php 
			if ( (in_array("DSC TITS - LIMITE",$rotinasTela)) || (!in_array("DSC TITS - LIMITE",$rotinasTela)) && ($glbvars['nmrotina'] == "DSC TITS") && (in_array("@", $glbvars['opcoesTela'])) ) {
				if (($msgError = validaPermissao($glbvars["nmdatela"],"DSC TITS - LIMITE","V","")) <> "") {
					echo 'style="cursor: default; display:none; "onClick="return false;"'; 
				}	
			}
		?> 
	>
		Renovar
	</a>

	<a 
		href="#" 
		class="botao"
		id="btnManutencao"
		name="tnManutencao" 
		<?php 
			if ( (in_array("DSC TITS - LIMITE",$rotinasTela)) || (!in_array("DSC TITS - LIMITE",$rotinasTela)) && ($glbvars['nmrotina'] == "DSC TITS") && (in_array("@", $glbvars['opcoesTela'])) ) {
				if (($msgError = validaPermissao($glbvars["nmdatela"],"DSC TITS - LIMITE","U","")) <> "") {
					echo 'style="cursor: default; display:none; "onClick="return false;"'; 
				}	
			}
		?> 
		>
		Manuten&ccedil;&atilde;o
	</a>
	<?if($flgverbor){?>
	<a 
		href="#" 
		class="botao"
		id="btnResgatar"
		name="btnResgatar"
		<?php if (!in_array("DSC TITS - BORDERO",$rotinasTela)) { echo 'style="cursor: default; display:none;" onClick="return false;"'; } 
			else { echo 'style=" margin-top: 8px; margin-bottom: 8px;" onClick="carregaResgatarTitulos();return false;"'; } ?> 
	>
		Resgatar T&iacute;tulos
	</a>
	<?}?>
	<!-- PRJ 438 - Sprint 16 - Incluído botão para acessar a tela de Últimas Alterações -->
	<a
		href="#"
		class="botao" 
		name="btnUltimasAlteracoes"
		id="btnUltimasAlteracoes"
		onClick="acessaTelaUltimasAlteracoes();return false;" >
			&Uacute;ltimas Altera&ccedil;&otilde;es
	</a>
</div>



<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao1","divConteudoOpcao");

// Muda o título da tela
$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS");

formataLayout('frmTitulos');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
	
	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
	
       //Bordero	
	  if (cdproduto == 35 ) {
		$('#btnbordero','#divBotoes').click();
		
	  //Limite
	  }else if (cdproduto == 37 ) {
		$('#btnlimite','#divBotoes').click();
	  }
	}
	flgverbor = <?=isset($flgverbor)?$flgverbor:0?>;
</script>