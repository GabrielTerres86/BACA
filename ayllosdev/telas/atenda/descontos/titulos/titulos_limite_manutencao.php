<? 
/*!
 * FONTE        : titulos_limite_manutencao.php
 * CRIAÇÃO      : Leonardo Oliveira
 * DATA CRIAÇÃO : Abril/2018
 * OBJETIVO     : Tela para manutenção do limite de contrato	             		        				   
 * --------------
 * ALTERAÇÕES   :
 * 001: [26/04/2018] Vitor Shimada Assanuma (GFT): Ajuste na chamada do botao de Alterar da Proposta
 * --------------
 */
?>

<? 
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	setVarSession("nmrotina","DSC TITS - LIMITE");
	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"U")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
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
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}

	$inctrmnt = (isset($_POST['inctrmnt'])) ? $_POST['inctrmnt'] : 0;

	// Monta o xml de requisição
	$xmlGetDados = "";
	$xmlGetDados .= "<Root>";
	$xmlGetDados .= "	<Cabecalho>";
	$xmlGetDados .= "		<Bo>b1wgen0030.p</Bo>";


	if( isset($inctrmnt) && $inctrmnt == 1 ){

		$xmlGetDados .= "		<Proc>busca_dados_proposta_manuten</Proc>";

	} else {

		$xmlGetDados .= "		<Proc>busca_dados_limite_manutencao</Proc>";
	}


	$xmlGetDados .= "	</Cabecalho>";
	$xmlGetDados .= "	<Dados>";
	$xmlGetDados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDados .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDados .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDados .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDados .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDados .= "		<idseqttl>1</idseqttl>";
	$xmlGetDados .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDados .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDados .= "	</Dados>";
	$xmlGetDados .= "</Root>";
		

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDados);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo 'bloqueiaFundo("#divError");';
		echo '</script>';
		exit();
	}
		
?>
<form action="" name="frmTitLimiteManutencao" id="frmTitLimiteManutencao" onSubmit="return false;">

	<fieldset>
	
		<legend>Dados do Limite</legend>
			<input type="hidden" name="per_vllimite" id="per_vllimite" value="0,00"/>
			<input  type="hidden"  name="per_cddlinha" id="per_cddlinha" value="0"/>

			<label for="nrctrlim"><? echo utf8ToHtml('Contrato:') ?></label>
			<input type="text" name="nrctrlim" id="nrctrlim" value="0" class="campo" disabled>
			<br />
			
			<label></label>
			<br />
			
			<label for="vllimite"><? echo utf8ToHtml('Valor do Limite:') ?></label>
			<input type="text" name="vllimite" id="vllimite" value="0,00" class="campo">
			
			<label for="qtdiavig"><? echo utf8ToHtml('Vigência:') ?></label>
			<input type="text" name="qtdiavig" id="qtdiavig" value="0" class="campoTelaSemBorda" disabled>
			<br />


			<label for="cddlinha"><? echo utf8ToHtml('Linha de descontos: ') ?></label>
			<input name="cddlinha" id="cddlinha" type="text" value="0" class="campo"/>
			<a>
				<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
			</a>

			<label for="dsdlinha"></label>
			<input name="dsdlinha" id="dsdlinha" type="text" value="" />

			<input type="hidden" id="flgstlcr" name="flgstlcr" value="<? echo $flgstlcr; ?>" />

			<br />

			
			<label for="txjurmor"><? echo utf8ToHtml('Juros mora:') ?></label>
			<input type="text" name="txjurmor" id="txjurmor" value="%" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="txdmulta"><? echo utf8ToHtml('taxa de multa:') ?></label>
			<input type="text" name="txdmulta" id="txdmulta" value="0,000000%" class="campoTelaSemBorda" disabled>
			<br />
			
			<label for="dsramati"><? echo utf8ToHtml('Ramo de Atividade:') ?></label>
			<input type="text" name="dsramati" id="dsramati" value="" class="campo">
			<br />
			
			<label for="vlmedtit"><? echo utf8ToHtml('Valor médio dos títulos:') ?></label>
			<input type="text" name="vlmedtit" id="vlmedtit" value="0,00" class="campo">
			<br />
			
			<label for="vlfatura"><? echo utf8ToHtml('Faturamento mensal:') ?></label>
			<input type="text" name="vlfatura" id="vlfatura" value="0,00" class="campo">
			
	</fieldset>
</form>

<div id="divBotoes">
	


<?php

	if( isset($inctrmnt) && $inctrmnt != 1 ){


		echo "
		<a 
		href='#'
		type='button'
		class='botao'
		name='btnVoltar' 
		id='btnVoltar'
		onClick=\"
		voltaDiv(2,1,4,'DESCONTO DE T&Iacute;TULOS','DSC TITS'); carregaTitulos(); return false;
		\"
		 >
		Voltar
		</a>";

		} else { 

		echo "
		<a 
		href='#'
		type='button'
		class='botao'
		name='btnVoltar' 
		id='btnVoltar'
		onClick=\"
		carregaLimitesTitulosPropostas(); return false;
		\"
		 >
		Voltar
		</a>";
	}
?>

	<a 
		href="#"
		type="button"
		class="botao"
		name="btnConcluir"
		id="btnConcluir"
		onClick="
			executarRealizarManutencaoDeLimite(); 
			return false;">
			Concluir
	</a>
</div>



<script type="text/javascript">
	if (sitinctrmnt == 1){
		dscShowHideDiv("divOpcoesDaOpcao3","divOpcoesDaOpcao2;");	
	}else{
		dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;");	
	}
	
	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - T&Iacute;TULOS - MANUTEN&Ccedil;&Atilde;o");

	formataLayout('frmTitLimiteManutencao');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

	function executarRealizarManutencaoDeLimite(){
		var flgstlcr = $('#flgstlcr','#frmTitLimiteManutencao').val();

		showConfirmacao(
			"Deseja alterar a proposta de majora&ccedil;&atilde;o?",
			"Confirma&ccedil;&atilde;o - Aimaro",
			"realizarManutencaoDeLimite(2, '"+flgstlcr+"');",
			"blockBackground(parseInt($('#divRotina').css('z-index'))",
			"sim.gif",
			"nao.gif"
		);
	}

	<?php 
		echo '$("#nrctrlim","#frmTitLimiteManutencao").val("'.formataNumericos('z.zzz.zz9',$dados[14]->cdata,'.').'");';
		echo '$("#vllimite","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';
		echo '$("#per_vllimite","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[15]->cdata),2,",",".").'");';
		echo '$("#qtdiavig","#frmTitLimiteManutencao").val("'.formataNumericos('zzz.zz9',$dados[16]->cdata,'.').' dias");';
		echo '$("#cddlinha","#frmTitLimiteManutencao").val("'.formataNumericos('zz9',$dados[17]->cdata,'.').'");';
		echo '$("#per_cddlinha","#frmTitLimiteManutencao").val("'.formataNumericos('zz9',$dados[17]->cdata,'.').'");';
		echo '$("#dsdlinha","#frmTitLimiteManutencao").val("'.$dados[2]->cdata.'");';//#cddlinh2
		echo '$("#txdmulta","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[0]->cdata),6,",",".").'%");';
		echo '$("#dsramati","#frmTitLimiteManutencao").val("'.$dados[4]->cdata.'");';
		echo '$("#vlmedtit","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[5]->cdata),2,",",".").'");';
		echo '$("#vlfatura","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[6]->cdata),2,",",".").'");';
		echo '$("#vlsalari","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[8]->cdata),2,",",".").'");';
		echo '$("#vlsalcon","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[9]->cdata),2,",",".").'");';
		echo '$("#vloutras","#frmTitLimiteManutencao").val("'.number_format(str_replace(",",".",$dados[7]->cdata),2,",",".").'");';
		echo '$("#dsdbens1","#frmTitLimiteManutencao").val("'.trim($dados[10]->cdata).'");';
		echo '$("#dsdbens2","#frmTitLimiteManutencao").val("'.trim($dados[11]->cdata).'");';	
		echo '$("#dsobserv","#frmTitLimiteManutencao").val("'.str_replace(chr(13),"\\n",str_replace(chr(10),"\\r",$dados[12]->cdata)).'");';
		echo '$("#antnrctr","#frmTitLimiteManutencao").val("'.formataNumericos('zzz.zz9',$dados[14]->cdata,'.').'");';

	?>

</script>

