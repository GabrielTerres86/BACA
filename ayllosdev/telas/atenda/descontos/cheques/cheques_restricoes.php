<?php 

	/************************************************************************
	 Fonte: cheques_restricoes.php                                       
	 Autor: Jaison
	 Data : Junho/2016                Ultima Alteracao: 25/08/2016
	                                                                  
	 Objetivo  : Mostrar as restricoes de descontos de cheques
	                                                                  	 
	 Alteracoes: 25/08/2016 - Remocao de aprovacao do coordenador na analise. (Jaison/James)
				 
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Carrega permiss�es do operador
	include("../../../../includes/carrega_permissoes.php");
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
    $nrborder = $_POST["nrborder"];
    $cddopcao = $_POST["cddopcao"];
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];
	$inconfi3 = $_POST["inconfi3"];
	$inconfi4 = $_POST["inconfi4"];
	$inconfi5 = $_POST["inconfi5"];
	$inconfi6 = $_POST["inconfi6"];
	$indentra = $_POST["indentra"];
	$indrestr = $_POST["indrestr"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi��o
	$xmlGetRestricoes  = "";
	$xmlGetRestricoes .= "<Root>";
	$xmlGetRestricoes .= "	<Cabecalho>";
	$xmlGetRestricoes .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetRestricoes .= "		<Proc>busca_restricoes_coordenador</Proc>";
	$xmlGetRestricoes .= "	</Cabecalho>";
	$xmlGetRestricoes .= "	<Dados>";
	$xmlGetRestricoes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetRestricoes .= "		<nrborder>".$nrborder."</nrborder>";
	$xmlGetRestricoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetRestricoes .= "	</Dados>";
	$xmlGetRestricoes .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetRestricoes);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRestricoes = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRestricoes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRestricoes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$restricoes   = $xmlObjRestricoes->roottag->tags[0]->tags;
	$qtRestricoes = count($restricoes);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divRestricoes">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Cheque</th>
					<th>Restri&ccedil;&atilde;o</th>
					<th>Detalhe</th>
				</tr>			
			</thead>
			<tbody>
				<?php
                    for ($i = 0; $i < $qtRestricoes; $i++) {
						?>
                        <tr>
                            <td><span><?php echo $restricoes[$i]->tags[1]->cdata; ?></span><?php echo $restricoes[$i]->tags[1]->cdata; ?></td>
                            <td><span><?php echo $restricoes[$i]->tags[2]->cdata; ?></span><?php echo $restricoes[$i]->tags[2]->cdata; ?></td>
                            <td><span><?php echo $restricoes[$i]->tags[5]->cdata; ?></span><?php echo $restricoes[$i]->tags[5]->cdata; ?></td>
                        </tr>
                        <?php
                    }
				?>
			</tbody>
		</table>
	</div>
</div>

<div id="divBotoes">
    <input type="image" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onclick="carregaBorderosCheques();return false;" />
    <?php
        if ($cddopcao == 'L') { // Liberacao
            ?><input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="pedeSenhaCoordenador(2,'liberaAnalisaBorderoDscChq(\'<?php echo $cddopcao; ?>\',\'<?php echo $inconfir; ?>\',\'<?php echo $inconfi2; ?>\',\'<?php echo $inconfi3; ?>\',\'<?php echo $inconfi4; ?>\',\'<?php echo $inconfi5; ?>\',\'<?php echo $inconfi6; ?>\',\'<?php echo $indentra; ?>\',\'<?php echo $indrestr; ?>\');','divRotina');return false;" /><?php
        } else { // Analise - 'N'
            ?><input type="image" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="liberaAnalisaBorderoDscChq('<?php echo $cddopcao; ?>','<?php echo $inconfir; ?>','<?php echo $inconfi2; ?>','<?php echo $inconfi3; ?>','<?php echo $inconfi4; ?>','<?php echo $inconfi5; ?>','<?php echo $inconfi6; ?>','<?php echo $indentra; ?>','<?php echo $indrestr; ?>');" /><?php
        }
    ?>
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

// Muda o t�tulo da tela
$("#tdTitRotina").html("Restri��o do Border� para Aprova��o");

formataLayout('divRestricoes');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
