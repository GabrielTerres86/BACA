<?php 

	/************************************************************************
	 Fonte: agendamento_detalhar.php                                             
	 Autor: Douglas
	 Data : Setembro/2014                Última Alteração:
	                                                                  
	 Objetivo  : Buscar as informações detalhadas do agendamento
	                                                                  	 
	 Alterações: 

	************************************************************************/
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	

	if ( !isset($_POST["nrdconta"]) ||  !isset($_POST["nrdocmto"]) || !isset($_POST["flgtipar"]) ) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	$nrdconta = $_POST["nrdconta"];
	$nrdocmto = $_POST["nrdocmto"];
	$flgtipar = $_POST["flgtipar"];
	
	if ( !validaInteiro($nrdconta) ) {
		exibeErro("N&uacute;mero da conta inv&aacute;lido");
	}
	
	if ( !validaInteiro($nrdocmto) ) {
		exibeErro("N&uacute;mero do agendamento inv&aacute;lido");		
	}
	
	// Verifica se tipo de agendamendo é válido
	if (!validaInteiro($flgtipar) || $flgtipar < 0 || $flgtipar > 1) {
		exibeErro("Tipo de agendamento inv&aacute;lido.");
	}
	
	//Carregar as informacoes da carencia
	// Monta o xml de requisição
	$xmlGetDetalhe  = "";
	$xmlGetDetalhe .= "<Root>";
	$xmlGetDetalhe .= "	<Cabecalho>";
	$xmlGetDetalhe .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlGetDetalhe .= "		<Proc>consulta-agendamento-det</Proc>";
	$xmlGetDetalhe .= "	</Cabecalho>";
	$xmlGetDetalhe .= "	<Dados>";
	$xmlGetDetalhe .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDetalhe .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDetalhe .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDetalhe .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDetalhe .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDetalhe .= "		<idseqttl>1</idseqttl>";
	$xmlGetDetalhe .= "		<flgtipar>".$flgtipar."</flgtipar>";
	$xmlGetDetalhe .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlGetDetalhe .= "	</Dados>";
	$xmlGetDetalhe .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResultDetalhe = getDataXML($xmlGetDetalhe);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDetalhe = getObjectXML($xmlResultDetalhe);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDetalhe->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDetalhe->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$detalheAgendamento = $xmlObjDetalhe->roottag->tags[0]->tags;	
	$qtDetalhes         = count($detalheAgendamento);
	
?>

var strHTML = "";
strHTML += '<div class="divRegistros">';
strHTML += '	<table>';
strHTML += '		<thead>';
strHTML += '			<tr>';
strHTML += '				<th><? echo utf8ToHtml('Tipo'); ?></th>';
strHTML += '				<th><? echo utf8ToHtml('Data'); ?></th>';
strHTML += '				<th><? echo utf8ToHtml('Documento'); ?></th>';
strHTML += '				<th><? echo utf8ToHtml('Valor'); ?></th>';
strHTML += '				<th><? echo utf8ToHtml('Situa&ccedil;&atilde;o'); ?></th>';
strHTML += '			</tr>';
strHTML += '		</thead>';
strHTML += '	    <tbody>';
<?php 
for ($i = 0; $i < $qtDetalhes; $i++) { 
	$insitlau = getByTagName($detalheAgendamento[$i]->tags,"insitlau");
	$insitdes = "";
	switch ($insitlau) {
		case 1:
			$insitdes = 'Pendente';
		break;
		
		case 2:
			$insitdes = 'Efetivado';
		break;
		
		case 3:
			$insitdes = 'Cancelado';
		break;
		
		case 4:
			$insitdes = 'Nao efetivado';
		break;																		
	}
	
	$nrdolote = getByTagName($detalheAgendamento[$i]->tags,"nrdolote");
	$dsdtipar = ($nrdolote == '32001') ? 'Aplica&ccedil;&atilde;o' : 'Resgate' ;
	$flgtipar = ($nrdolote == '32001') ? 0 : 1 ;
	
	$dtmvtopg = getByTagName($detalheAgendamento[$i]->tags,"dtmvtopg");
    $nrdocmto = getByTagName($detalheAgendamento[$i]->tags,"nrdocmto");
    $vllanaut = getByTagName($detalheAgendamento[$i]->tags,"vllanaut");
	
?>
	objDetalheAgen = new Object();						
	objDetalheAgen.cdcooper = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"cdcooper"); ?>";
	objDetalheAgen.cdagenci = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"cdagenci"); ?>";
	objDetalheAgen.cdbccxlt = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"cdbccxlt"); ?>";
	objDetalheAgen.cdbccxpg = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"cdbccxpg"); ?>";
	objDetalheAgen.cdhistor = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"cdhistor"); ?>";
	objDetalheAgen.dtdebito = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"dtdebito"); ?>";
	objDetalheAgen.dtmvtolt = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"dtmvtolt"); ?>";
	objDetalheAgen.nrdconta = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"nrdconta"); ?>";
	objDetalheAgen.nrdctabb = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"nrdctabb"); ?>";
	objDetalheAgen.nrseqlan = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"nrseqlan"); ?>";
	objDetalheAgen.tpdvalor = "<?php echo getByTagName($detalheAgendamento[$i]->tags,"tpdvalor"); ?>";
	objDetalheAgen.dtmvtopg = "<?php echo $dtmvtopg; ?>";
	objDetalheAgen.vllanaut = "<?php echo $vllanaut; ?>";
	objDetalheAgen.nrdocmto = "<?php echo $nrdocmto; ?>";
	objDetalheAgen.nrdolote = "<?php echo $nrdolote; ?>";
	objDetalheAgen.insitlau = "<?php echo $insitlau; ?>";
	objDetalheAgen.insitdes = "<?php echo $insitdes; ?>";
	objDetalheAgen.dsdtipar = "<?php echo $dsdtipar; ?>";
	objDetalheAgen.flgtipar = "<?php echo $flgtipar; ?>";
	lstDetalheAgendamento[<?php echo $i; ?>] = objDetalheAgen;

	strHTML += '		<tr id="trDetalheAgendamento<?php echo $i; ?>" style="cursor: pointer;" onClick="selecionaDetalheAgendamento(<?php echo $i; ?>)">';
	strHTML += '			<td><?php echo $dsdtipar; ?></td>';
	strHTML += '			<td><?php echo $dtmvtopg ?></td>';
	strHTML += '			<td><?php echo $nrdocmto ?></td>';
	strHTML += '			<td><?php echo number_format(str_replace(",",".", $vllanaut),2,",","."); ?></td>';
	strHTML += '			<td><?php echo $insitdes; ?></td>';
	strHTML += '		</tr>';
<? } ?>	
strHTML += '		</tbody>';
strHTML += '	</table>';
strHTML += '</div>';

strHTML += '<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">';
strHTML += '	<a href="#" class="botao" id="btVoltarDetalhe" onClick="voltarAgendamentoDetalhes();return false;">Voltar</a>';
strHTML += '	<a href="#" class="botao" id="btExcluirDetalhe" onClick="excluirDetalheAgendamento();return false;">Excluir</a>';
strHTML += '	<a href="#" class="botao" id="btExcluirTodosDetalhes" onClick="excluirTodosDetalhesAgendamento();return false;">Excluir Todos</a>';
strHTML += '</div>';

$("#divAgendamento").css("display","none");
$("#divDetalhesAgendamento").html(strHTML);
$("#divDetalhesAgendamento").css("display","block");

formataTabelaDetalhesAgendamento();
selecionaDetalheAgendamento(0);
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));

