<?php 

	/************************************************************************
	 Fonte: historico_de_participacao.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                Ultima Alteracao:   14/07/2011     
	                                                                  
	 Objetivo  : Mostrar opcao Historico de participacao
	                                                                  	 
	 Alteracoes:  
					09/02/2011 - Efetuar a impressao do historico (Gabriel)                                                     
	
					14/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	

					09/07/2012 - Retirado campo "redirect" popup (Jorge).
	************************************************************************/

	session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
?>	

<form name="frmHistParticipacao" id="frmHistParticipacao" class="formulario" action="<?php echo $UrlSite; ?>telas/atenda/relacionamento/impressao_historico.php" method="post">		
			
	<input type="hidden" id="nrdconta" name="nrdconta" value="">
	<input type="hidden" id="inipesqu" name="inipesqu" value="">
	<input type="hidden" id="finpesqu" name="finpesqu" value="">
	<input type="hidden" id="idevento" name="idevento" value="">
	<input type="hidden" id="cdevento" name="cdevento" value="">
	<input type="hidden" id="sidlogin" name="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">	

	<fieldset>
		<legend>Pesquisa Hist&oacute;rico</legend>
		
		<label for="inianoev">Per&iacute;odo de (aaaa):</label>
		<input name="inianoev" type="text" id="inianoev" value="<?php echo date("Y");?>">
		
		<label for="finanoev">a</label>	
		<input name="finanoev" type="text" id="finanoev" value="<?php echo date("Y");?>">
		
		<label for="dsevento">Evento:</label>
		<select name="dsevento" id="dsevento">
			<option id="0,0" value="0,0"></option>
		</select>

		<input type="image" src="<?php echo $UrlImagens; ?>botoes/zoom.gif" onClick="buscaEventosPeriodo();return false;">

	</fieldset>
	
	<div id="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divConteudoOpcao').css('display','block');$('#divOpcoesDaOpcao1').css('display','none');return false;">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="confirmaEventosHistCooperado();return false;">
	</div>
	
</form>

<script type="text/javascript">

$("#divConteudoOpcao").css("display","none");
$("#divOpcoesDaOpcao1").css("display","block");

// Mascara para o campos
$("#inianoev","#frmHistParticipacao").setMask("INTEGER","9999","","");
$("#finanoev","#frmHistParticipacao").setMask("INTEGER","9999","","");

$("#inianoev","#frmHistParticipacao").focus();

hideMsgAguardo();
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>