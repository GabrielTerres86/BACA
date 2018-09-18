<?php 

	 /************************************************************************
	  Fonte: creditos_recebidos.php
	  Autor: Gabriel - Rkam
	  Data : Agost/2015                 �ltima Altera��o: 21/07/2016 

	  Objetivo  : Mostrar opcao Cr�ditos Recebidos da rotina de Dep. Vista
                  da tela ATENDA

	  Altera��es: 21/07/2016 - Correcao no carregamento de valores dos campos da tela. SD 479874. Carlos R.
	  
	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
			
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');		
	}	
		
	// Monta o xml de requisi��o
	$xmlCreditosRecebidos  = "";
	$xmlCreditosRecebidos .= "<Root>";
	$xmlCreditosRecebidos .= "   <Dados>";
	$xmlCreditosRecebidos .= "	   <nrdconta>".$_POST["nrdconta"]."</nrdconta>";
	$xmlCreditosRecebidos .= "   </Dados>";
	$xmlCreditosRecebidos .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlCreditosRecebidos, "CREDITOSRECEBIDOS", "LISTACREDRECEBIDOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCreditos = getObjectXML($xmlResult);
	
	//Validar se o indice utilizado existe e se ocorrer um erro, mostra cr�tica
	if (isset($xmlObjCreditos->roottag->tags[0]->name) &&  strtoupper($xmlObjCreditos->roottag->tags[0]->name) == "ERRO") {
		
		exibirErro('error',$xmlObjCreditos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	}
	
	$registros = $xmlObjCreditos->roottag->tags;	
	
?>

<form action="" name="frmCreditosRecebidos" id="frmCreditosRecebidos" class="formulario" method="post">			

	<?php foreach( $registros as $result ){ ?>
	
		<label for="<?php echo $result->tags[0]->name;?>"><?php echo $result->tags[0]->cdata; ?></label>
		<input type="text" id="<?php echo $result->tags[0]->name;?>" name="<?php echo $result->tags[0]->name;?>" value="<?php echo number_format(floatval(str_replace(",","",$result->tags[1]->cdata)),2,",",".");?>" />
						
		<br />
		
	<?php } ?>
	
</form>

<script type="text/javascript">

	// Formata o layout
	controlaLayout('frmCreditosRecebidos');

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte�do que est� �tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
