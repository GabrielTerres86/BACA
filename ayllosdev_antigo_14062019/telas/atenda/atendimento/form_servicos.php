<?php 

	/********************************************************************
	 Fonte: principal.php                                             
	 Autor: Gabriel - Rkam                                                     
	 Data : Agosto - 2015                  Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o formulario para cadastro do atendimento                                          
	                                                                  	 
	 Alteraçães: 
	 
	 
	*********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	
	}			
	
?>

<form id="frmServicos" name="frmServicos" class="formulario" style="display:none;">	
								
	<label for="dtatendimento"><? echo utf8ToHtml('Data:'); ?></label>
	<input name="dtatendimento" type="text" class="campo" id="dtatendimento">
	
	<label for="hratendimento"><? echo utf8ToHtml('Hora:'); ?></label>
	<input name="hratendimento" type="text" class="campo" id="hratendimento"  maxlength="5">
	
	<label for="cdservico"><? echo utf8ToHtml('Atividade:') ?></label>
	<input name="cdservico" type="text" class="campo" id="cdservico" value="0">
	<a style="padding: 3px 0 0 3px;" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" id="lupaServico" name="lupaServico" /></a>
						
	<label for="nmservico"></label>
	<input name="nmservico" type="text" class="campo" id="nmservico" value="0">
	
	<br />			
	
	<label for='dsservico_solicitado'> Descri&ccedil;&atilde;o:</label>
	<textarea name="dsservico_solicitado" id="dsservico_solicitado" ></textarea>
				
	<br style="clear:both" />	
				
</form>

<div id="divBotoesServicos" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btConcluir">Concluir</a>
			
</div>
	
	
<script type="text/javascript">

	var ope = '<?echo $cddopcao;?>';

	controlaLayout(ope);
	
	 if(ope == 'I'){	
		//Alimenta os campos campos com data e hora atual
		$('#dtatendimento','#frmServicos').val('<?php echo $glbvars['dtmvtolt']; ?>');
		$('#hratendimento','#frmServicos').val('<?php echo date('H:i'); ?>');
	}
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);

</script>
	
	



