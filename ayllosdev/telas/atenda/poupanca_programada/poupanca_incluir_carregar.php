<?php 

	/***************************************************************************
	 Fonte: poupanca_incluir_carregar.php                             
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 05/10/2015
	                                                                  
	 Objetivo  : Mostrar opção para incluir Poupança Programada       
	                                                                  
	 Alterações:  07/05/2010 - Incluir campo Tipo de impressao do     
								extrato  (Gabriel).   

				  13/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
				  
				  27/12/2011 - Alterações no XML para utilizar parâmetros da BO0006
							   para cálculo de prazo de venc. máx. (Lucas).
							   
				  05/10/2015 - Reformulacao cadastral (Gabriel-RKAM).			   

				  04/04/2018 - Chamada da rotina para verificar se o tipo de conta permite produto 
				               16 - Poupança Programada. PRJ366 (Lombardi).
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];	
	$aux_dtinirpp = $_POST["dtinirpp"];	
		
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}			
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>". 16 ."</cdprodut>"; //Poupança Programada
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
	// Monta o xml de requisição
	$xmlIncluir  = "";
	$xmlIncluir .= "<Root>";
	$xmlIncluir .= "	<Cabecalho>";
	$xmlIncluir .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlIncluir .= "		<Proc>obtem-dados-inclusao</Proc>";
	$xmlIncluir .= "	</Cabecalho>";
	$xmlIncluir .= "	<Dados>";
	$xmlIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlIncluir .= "		<idseqttl>1</idseqttl>";	
	$xmlIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlIncluir .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlIncluir .= "		<dtinirpp>".$aux_dtinirpp."</dtinirpp>";	
	$xmlIncluir .= "		<dtmaxvct>".$aux_dtmaxvct."</dtmaxvct>";		
	$xmlIncluir .= "	</Dados>";
	$xmlIncluir .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlIncluir);

	
	// Cria objeto para classe de tratamento de XML
	$xmlObjIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$aux_dtinirpp = $xmlObjIncluir->roottag->tags[0]->attributes["DTINIRPP"];
	//Faz o explode da Data Máxima de Vencimentos para exibição na Tela.
	$aux_dtmaxvct = $xmlObjIncluir->roottag->tags[0]->attributes["DTMAXVCT"];
	$aux_dtmaxvct = explode ("/", $aux_dtmaxvct);	
		
		//echo "<script>alert('$aux_dtinirpp');</script>";
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<?/**/?>
<form action="" method="post" name="frmDadosPoupanca" id="frmDadosPoupanca">
	<fieldset>
		<legend><? echo utf8ToHtml('Poupança Programada - Incluir') ?></legend>
		
		<label for="dtinirpp"><? echo utf8ToHtml('Dia do Aniversário/Mês e Ano do Início:') ?></label>
		
		<input name="dtinirpp" type="text" class="campo" id="dtinirpp" value = "<?php echo $aux_dtinirpp ?>"/>
		<br />
		
		<label for="diadtvct"><? echo utf8ToHtml('Dia/Mês/Ano Vencimento:') ?></label>
		<input name="diadtvct" type="text" class="campo" id="diadtvct" value = "<?php echo $aux_dtmaxvct[0] ?>" />
		
		<label for="mesdtvct"><? echo utf8ToHtml('/') ?></label>
		<input name="mesdtvct" type="text" class="campo" id="mesdtvct" value = "<?php echo $aux_dtmaxvct[1] ?>" />
		
		<label for="anodtvct"><? echo utf8ToHtml('/') ?></label>
		<input name="anodtvct" type="text" class="campo" id="anodtvct" value = "<?php echo $aux_dtmaxvct[2] ?>" />
		<br />
		
		<label for="vlprerpp"><? echo utf8ToHtml('Valor da Prestação:') ?></label>
		<input name="vlprerpp" type="text" class="campo" id="vlprerpp" value="0,00" />
		<br />
		
		<label for="tpemiext"><? echo utf8ToHtml('Tipo de impressão do extrato:') ?></label>
		<select name="tpemiext" id="tpemiext" class="campo">
			<option value="1">Individual        </option>
			<option value="2"> 		   Todas             </option>
			<option value="3" selected>         N&atilde;o emite  </option>			
		</select>					
		
	</fieldset>
</form>
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarDivPrincipal();return false;" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarInclusaoPoupanca();return false;" />
</div>

<script type="text/javascript">
var dtinirpp_c;
var tpemiext = $("#tpemiext","#frmDadosPoupanca");

controlaLayout('frmIncluirPoupanca');
controlaFocoEnter("frmDadosPoupanca");

$('#diadtvct','#frmDadosPoupanca').desabilitaCampo();
//Função para validar e atualizar o campo 'dtinirpp'
function valida_campo(){
	var dtinirpp;
	dtinirpp = $('#dtinirpp','#frmDadosPoupanca').val();
	if  (validaData(dtinirpp)) {
		acessaOpcaoIncluir();
	} else {
		$('#dtinirpp','#frmDadosPoupanca').val('');
		$("#dtinirpp","#frmDadosPoupanca").focus();
	}
}

$("#dtinirpp","#frmDadosPoupanca").setMask("DATE","","","divRotina");
$("#mesdtvct","#frmDadosPoupanca").setMask("INTEGER","99","","");
$("#anodtvct","#frmDadosPoupanca").setMask("INTEGER","9999","","");
$("#vlprerpp","#frmDadosPoupanca").setMask("DECIMAL","zzz,zzz.zz9,99","","");

$("#dtinirpp","#frmDadosPoupanca").unbind("keydown");
$("#dtinirpp","#frmDadosPoupanca").unbind("keyup");
$("#dtinirpp","#frmDadosPoupanca").unbind("blur");
$("#dtinirpp","#frmDadosPoupanca").bind("keydown",function(e) { return $(this).setMaskOnKeyDown("DATE","","",e); });
$("#dtinirpp","#frmDadosPoupanca").bind("keyup",function(e) { return $(this).setMaskOnKeyUp("DATE","","",e); });

$("#divPoupancasPrincipal").css("display","none");
$("#divOpcoes").css("display","block");

// Esconde mensagem de aguardo e coloca o foco no campo Vl. da Prestação
hideMsgAguardo();

$("#vlprerpp","#frmDadosPoupanca").focus();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
		
dtinirpp_c =  $("#dtinirpp","#frmDadosPoupanca");

dtinirpp_c.unbind('change').bind('change', function() { 
	valida_campo(); 
});

tpemiext.unbind('keypress').bind('keypress', function(e) { 
	if (e.keyCode == 13) {
		validarInclusaoPoupanca();
		return false;
	}
});
		
</script>										