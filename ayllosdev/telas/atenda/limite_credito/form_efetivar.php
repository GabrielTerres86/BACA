<?php
/*!
 * FONTE        : form_efetivar.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 04/12/2018
 * OBJETIVO     : Formulário da rotina Efetivar
 
 * ALTERAÇÕES   : 
 *
 */	

	session_start();
	
	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();	

?>
<form action="" method="post" name="frmEfetivar" id="frmEfetivar" class="formulario">

	<fieldset>
		<legend><?php echo utf8ToHtml('Efetivação da Proposta') ?></legend>

		<label for="nivrisco"><?php echo utf8ToHtml('Nível de Risco:') ?></label>
		<input name="nivrisco" id="nivrisco" type="text" />

		<label for="qtdiavig"><?php echo utf8ToHtml('Vigência:') ?></label>	
		<input id="qtdiavig" name="qtdiavig" type="text" />
		<br />
		
		<label for="nrctrlim"><?php echo utf8ToHtml('Número do Contrato:') ?></label>	
		<input id="nrctrlim" name="nrctrlim" type="text" />	

		<label for="vllimite"><?php echo utf8ToHtml('Valor do Limite de Crédito:') ?></label>	
		<input id="vllimite" name="vllimite" type="text" />	
		<br />

		<label for="cddlinha"><?php echo utf8ToHtml('Linha de Crédito:') ?></label>	
		<input id="cddlinha" name="cddlinha" type="text" />		

		<label for="dsdtxfix"> <?php echo utf8ToHtml('Taxa:') ?></label>
		<input name="dsdtxfix" id="dsdtxfix" type="text" />
		<br>
		
	</fieldset>	 
				
	<div id="divBotoes">
	    <input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif">
	    <input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif">
	</div>
	
</form>

<script type="text/javascript">
    
    setDadosEfetivar();
	formataEfetivar();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	
</script>