<?php 

	/************************************************************************
	 Fonte: eventos_em_andamento_busca.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                &Uacute;ltima Altera&ccedil;&atilde;o: 04/07/2017    
	
	 Objetivo  : Buscar eventos em andamento de acordo com o parametro
				 de observa&ccedil;&atilde;o
	
	 Alteracoes: 14/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
				 26/07/2016 - Corrigi o uso de variaveis nao declaradas, indices invalidos
							  no retorno XML. SD 479874 (Carlos R.)
	 
					04/07/2017 - Alterado na campo periodo para pegar a data certa 
					             na posicao do array detalhesEvento (Tiago/Thiago #699994)	 
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
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["rowidedp"]) ||
		!isset($_POST["rowidadp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$rowidedp = $_POST["rowidedp"];
	$rowidadp = $_POST["rowidadp"];
	$dsobserv = ( isset($_POST['dsobserv']) ) ? $_POST['dsobserv'] : '';

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDetalhesEvento  = "";
	$xmlGetDetalhesEvento .= "<Root>";
	$xmlGetDetalhesEvento .= "	<Cabecalho>";
	$xmlGetDetalhesEvento .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDetalhesEvento .= "		<Proc>obtem-detalhe-evento</Proc>";
	$xmlGetDetalhesEvento .= "	</Cabecalho>";
	$xmlGetDetalhesEvento .= "	<Dados>";
	$xmlGetDetalhesEvento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDetalhesEvento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDetalhesEvento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDetalhesEvento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDetalhesEvento .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDetalhesEvento .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDetalhesEvento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDetalhesEvento .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlGetDetalhesEvento .= "		<idseqttl>1</idseqttl>";
	$xmlGetDetalhesEvento .= "		<rowidedp>".$rowidedp."</rowidedp>";
	$xmlGetDetalhesEvento .= "		<rowidadp>".$rowidadp."</rowidadp>";
	$xmlGetDetalhesEvento .= "	</Dados>";
	$xmlGetDetalhesEvento .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDetalhesEvento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDetalhesEvento = getObjectXML($xmlResult);
	
	$detalhesEvento = ( isset($xmlObjDetalhesEvento->roottag->tags[0]->tags[0]->tags) ) ? $xmlObjDetalhesEvento->roottag->tags[0]->tags[0]->tags : array();
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjDetalhesEvento->roottag->tags[0]->name) && strtoupper($xmlObjDetalhesEvento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDetalhesEvento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
?>	

<form id="frmEventosEmAndamentoDetalhes" onSubmit="return false" class="formulario">
	<fieldset>
		<legend>Detalhe do Evento</legend>

		<label for="nmevento">Evento:</label>
		<input type="text" id="nmevento" name="nmevento" value="<?php echo $detalhesEvento[0]->cdata; ?>" >
		
		<br />
		
		<label for="dsperiod">Per&iacute;odo:</label>
		<input type="text" name="dsperiod" id="dsperiod" value="<?php echo $detalhesEvento[1]->cdata." &agrave; ".$detalhesEvento[2]->cdata; ?>" >

		<br />

		<label for="dshroeve">Hor&aacute;rio:</label>
		<input type="text" name="dshroeve" id="dshroeve"  value="<?php echo $detalhesEvento[3]->cdata; ?>" >

		<br />
		
		<label for="dslocali">Local:</label>
		<input type="text" id="dslocali" name="dslocali"  value="<?php echo $detalhesEvento[4]->cdata; ?>" >

		<br />
		
		<label for="nmfornec">Fornecedor:</label>
		<input type="text" id="nmfornec" name="nmfornec"  value="<?php echo $detalhesEvento[5]->cdata; ?>" >

		<br />
	
		<label for="nmfacili">Facilitador:</label>
		<input type="text" id="nmfacili" name="nmfacili"  value="<?php echo $detalhesEvento[6]->cdata; ?>" >

		<br />
		
		<textarea name="txtDetalhes" id="txtDetalhes" ><?php for ($i=0;$i<=count($detalhesEvento[7]->tags);$i++){	echo ( isset($detalhesEvento[7]->tags[$i]->cdata) ) ? $detalhesEvento[7]->tags[$i]->cdata : '';	}?></textarea>
		
	</fieldset>
	
</form>						
			
<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divOpcoesDaOpcao1').css('display','block');$('#divOpcoesDaOpcao2').css('display','none');return false;">
</div>
			
<script type="text/javascript">

// Formata layout
formataEventosEmAndamentoDetalhes();

// Esconde o <div> da com a op&ccedil;&atilde;o t&iacute;tulos
$("#divOpcoesDaOpcao1").css("display","none");
// Mostra o <div> com os eventos em andamento
$("#divOpcoesDaOpcao2").css("display","block");

// Esconde mensagem de aguardo
hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
