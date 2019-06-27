<?php 

	 /************************************************************************
	  Fonte: saldos_anteriores.php
	  Autor: Guilherme
	  Data : Fevereiro/2008                 Última Alteração:  06/02/2019

	  Objetivo  : Mostrar opcao Saldos Anteriores da rotina de Dep. Vista
                  da tela ATENDA

	  Alterações: 02/09/2010 - Ajustar nomes dos campos (David).
				  29/06/2011 - Alterado para layout padrão (Rogerius - DB1).
				  03/07/2013 - Incluir valor vlblqjud Bloqueio Judicial (Lucas R.)
				  11/07/2017 - Novo campo Limite Pre Aprovado Disponivel na tela Saldos Anteriores, Melhoria M441. ( Mateus Zimmermann/MoutS )
				  06/02/2019 - P442 - Remoção de informações de Pre-Aprovado da tela (Marcos-Envolti)

	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o némero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtrefere = $glbvars["dtmvtoan"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<form action="" name="frmSaldoAnt" id="frmSaldoAnt" class="formulario" method="post">			

	<label for="dtrefere"></label>
	<input type="text" name="dtrefere" id="dtrefere" value="<?php echo $dtrefere; ?>" autocomplete="no">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="obtemSaldos();return false;">
	
	<br />
	
	<label for="vlsddisp">Dispon&iacute;vel:</label>
	<input type="text" name="vlsddisp" id="vlsddisp" />

	<br />

	<label for="vlsdbloq">Bloqueado:</label>
	<input type="text" name="vlsdbloq" id="vlsdbloq" />

	<br />
	
	<label for="vlsdblpr">Bloqueado Pra&ccedil;a:</label>
	<input type="text" name="vlsdblpr" id="vlsdblpr" />

	<br />
	
	<label for="vlsdblfp">Bloq. Fora Pra&ccedil;a:</label>
	<input type="text" name="vlsdblfp" id="vlsdblfp" />

	<br />

	<label for="vlsdchsl">Cheque Sal&aacute;rio:</label>
	<input type="text" name="vlsdchsl" id="vlsdchsl" />

	<br />

	<label for="vlsdindi">Indispon&iacute;vel:</label>
	<input type="text" name="vlsdindi" id="vlsdindi" />

	<br />
	
	<label for="vlblqjud">Bloq. Judicial:</label>
	<input type="text" name="vlblqjud" id="vlblqjud" />
	
	<br />

	<label for="vlstotal">Saldo Total:</label>
	<input type="text" name="vlstotal" id="vlstotal" />

	<br />

	<label for="vllimcre">Limite Cr&eacute;dito:</label>
	<input type="text" name="vllimcre" id="vllimcre" />

</form>

<script type="text/javascript">

// Formata o layout
controlaLayout('frmSaldoAnt');

// Seta máscara do campos dtrefere
$("#dtrefere","#frmSaldoAnt").setMask("DATE","","","divRotina");

$("#dtrefere","#frmSaldoAnt").focus();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Mostra o resultado da busca
obtemSaldos();
</script>
