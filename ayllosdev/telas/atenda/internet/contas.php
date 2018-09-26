<?php 

	//****************************************************************************//
	//*** Fonte: contas.php      	    			                           ***//
	//*** Autor: Lucas                                                    	   ***//
	//*** Data : Maio/2012                   Última Alteração: 12/04/2016      ***//
	//***                                                                      ***//
	//*** Objetivo  : Mostrar o menu para operações com contas de transf.      ***//
	//***                                                                      ***//	 
	//***                                                                      ***//	 
	//*** Alterações: 18/12/2014 - Incluindo paginacao na funcao               ***//
    //***                          obtemCntsPendentes. Melhorias Cadastro      ***//
    //***                          de Favorecidos TED.(André Santos - SUPERO)  ***//
	//***                                           						   ***//
    //***             12/04/2016 - Remocao Aprovacao Favorecido.               ***//
    //***                          (Jaison/Marcos - SUPERO)                    ***//
	//***                                           						   ***//
	//****************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
		
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetResumo  = "";
	$xmlGetResumo .= "<Root>";
	$xmlGetResumo .= "	<Cabecalho>";
	$xmlGetResumo .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetResumo .= "		<Proc>resumo-cnts-internet</Proc>";
	$xmlGetResumo .= "	</Cabecalho>";
	$xmlGetResumo .= "	<Dados>";
	$xmlGetResumo .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetResumo .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetResumo .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetResumo .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetResumo .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlGetResumo .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetResumo .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetResumo .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetResumo .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetResumo .= "	</Dados>";
	$xmlGetResumo .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetResumo);

	// Cria objeto para classe de tratamento de XML
	$xmlObjPendentes = getObjectXML($xmlResult);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$registros = $xmlObjPendentes->roottag->tags[0]->tags;
		
	$cntrgcad = $xmlObjPendentes->roottag->tags[0]->attributes["CNTRGCAD"];

	
?>

<div id="divOpContas">
	<form action="" method="post" name="frmOpContas" id="frmOpContas" onSubmit="return false;">
		<fieldset>
			<legend><? echo utf8ToHtml('Contas') ?></legend>			
			<div id="divBotoes" align="center">
                <table align="center" width="100%">
					<tr>
						<td align ="center">
                            <table align="center" style="padding-left:15px;">
					<tr>
						<td align ="center">
							<input type="image" src="<? echo $UrlImagens; ?>botoes/contas_cadastradas.gif" onClick="obtemCntsCad(0, 0, 50);return false;" />
						</td>
						<td align ="center">
							<input class="campo" value="<? echo utf8ToHtml($cntrgcad) ?>" type="text" style="width:30px;"/>
						</td>
					</tr>
					<tr>
						<td align ="center">
							<input type="image" src="<? echo $UrlImagens; ?>botoes/incluir_conta.gif" onClick="InclusaoContas();return false;" />
						</td>
					</tr>
					<tr>
						<td align ="center">
							<input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="redimensiona(); carregaHabilitacao(); return false;" />
						</td>
					</tr>
				</table>
                        </td>
                    </tr>
                </table>
			</div>
		</fieldset>
	</form>
</div>


<script type="text/javascript">

controlaLayout('frmOpContas');

$('input', '#frmOpContas').desabilitaCampo();

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","150");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
