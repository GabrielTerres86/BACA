<?php
/*!
 * FONTE        : apresentar_form_opcao_a.php                    Última alteração: 
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Outubro/2018
 * OBJETIVO     : Rotina para apresentar form da opção "A"
 * --------------
 * ALTERAÇÕES   :  
 *
 */
?>




<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');
    
?>

<form name="frmOpcaoA" id="frmOpcaoA" class="formulario" >
	
	<fieldset id="fsetMensagemA" name="fsetMensagemA" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Mensagem</legend>

		<div id="mensagemA" style="height:80px;padding-left:15px;">
			
			<ul class="msg-guia">
				<li><?php echo utf8ToHtml("1 - Criar o histórico do convênio da Opção H."); ?></li>
				<li><?php echo utf8ToHtml("2 - Compatibilizar informações com as telas GT0001, GT0002 e CONVEN."); ?></li>
				<li><?php echo utf8ToHtml("3 - Fazer autorização da fatura em uma das plataformas disponíveis."); ?></li>
				<li><?php echo utf8ToHtml("4 - Informar o código do convênio."); ?></li>
			</ul>
						
		</div>
		
		<br style="clear:both" />	
		
	</fieldset>
	
	<br />
	
	<fieldset id="fsetOpcaoA" name="fsetOpcaoA" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<input name="cdcooper" id="cdcooper" type="hidden" value="<?php echo $glbvars["cdcooper"]; ?>" />
		
		<legend>Dados do Conv&ecirc;nio</legend>

		<label for="cdconven"><?php echo utf8ToHtml("Convênio:"); ?></label>
		<input type="text" id="cdconven" name="cdconven" >
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="nmempres" name="nmempres" >
		
		<br />
		<br style="clear:both" />	
		
	</fieldset>

</form>	

<div id="divBotoesOpcao" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>
	
	<div class="tooltip">
		<a href="#" class="botao" id="btLimpar" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','limparAutorizacaoDebito();',   '$(\'#btVoltar\',\'#divBotoesOpcaoA\').focus();','sim.gif','nao.gif');return false;">Limpar</a>
		<span class="tooltiptext"><?php echo utf8ToHtml("Deleta registros com data inicio e fim de autorização e data inicio e fim de suspensão que sejam iguais a data de movimentação do sistema."); ?></span>
    </div>

	<div class="tooltip">
	<a href="#" class="botao" id="btGerar"  onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','homologarAutorizacaoDebito();','$(\'#btVoltar\',\'#divBotoesOpcaoA\').focus();','sim.gif','nao.gif');return false;">Gerar</a>
	    <span class="tooltiptext"><?php echo utf8ToHtml("Convênios unificados geram arquivos apenas na central."); ?></span>
    </div>
</div>

<script type="text/javascript">

	formataFormOpcaoA();
	
</script>

<style>

    .msg-guia{
		list-style: none;
		padding: 10px 0 0 15px;
		line-height: 20px;
	}
	.tooltip {
	  position: relative;
	  display: inline-block;
	  border-bottom: 1px dotted black;
	}
	.tooltip .tooltiptext {
	  visibility: hidden;
	  width: 120px;
	  background-color: black;
	  color: #fff;
	  text-align: center;
	  border-radius: 6px;
	  padding: 5px 0;
	  
	  /* Position the tooltip */
	  position: absolute;
	  z-index: 1;
	  top: 100%;
	  left: 50%;
	  margin-left: -60px;
	}
	.tooltip:hover .tooltiptext {
	  visibility: visible;
	}
</style>
	
