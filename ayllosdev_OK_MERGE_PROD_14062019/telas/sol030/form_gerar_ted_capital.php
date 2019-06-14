<?php
/*!
 * FONTE        : form_gerar_ted_capital.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Responsável por apresentar o form com as informações de TED de capital a serem efetivadas
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

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','');
    }

?>		 
 
 <form id="frmPrazoDesligamento" name="frmPrazoDesligamento" class="formulario">
	
	<fieldset id="fsetPrazoDesligamento" name="fsetPrazoDesligamento" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Prazo para desligamento"; ?></legend>
		
		<input name="tpprazo" id="flgNoAto" type="radio" class="radio" style="height: 20px; margin: 3px 5px 3px 250px;" />
		<label for="flgNoAto" class="radio" >No Ato</label>
		
		<br style="clear:both" />
		
		<input name="tpprazo" id="flgAposAgo" type="radio" class="radio" style="height: 20px; margin: 3px 5px 3px 250px;"/>
		<label for="flgAposAgo" class="radio"><? echo utf8ToHtml('Ap&oacute;s AGO') ?></label>
		
		<br />
		
		<label for="qtddias"><? echo utf8ToHtml('Quantidade de dias:') ?></label>
		<input type="text" id="qtddias" name="qtddias" value="<?echo getByTagName($registros->tags,'qtddias');?>"/>
		
		<br style="clear:both" />
	
	</fieldset>
	
	<fieldset id="fsetDevolucaoCapital" name="fsetDevolucaoCapital" style="padding:0px; margin:0px; padding-bottom:10px; displya:none">
		
		<legend><? echo "Devolu&ccedil;&atilde;o de capital"; ?></legend>
						
		<input name="flgautori" id="flgNo" type="radio" class="radio" style="height: 20px; margin: 3px 5px 3px 250px;" />
		<label for="flgNo" class="radio" ><? echo utf8ToHtml('N&atilde;o') ?></label>
		
		<br style="clear:both" />
		
		<input name="flgautori" id="flgYes" type="radio" class="radio" style="height: 20px; margin: 3px 5px 3px 250px;"/>
		<label for="flgYes" class="radio"><? echo utf8ToHtml('Sim') ?></label>
		
		<br style="clear:both" />
	
	</fieldset>
	
</form>

<div id="divBotoesPrazoDesligamento" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="botao" id="btAlterar" onClick="showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarPrazoDesligamento();','$(\'#btVoltar\',\'#divBotoesPrazoDesligamento\').focus();','sim.gif','nao.gif');return false;" >Alterar</a>
	
</div>

<script type="text/javascript">
	
	<?IF(getByTagName($registros->tags,'tpprazo') == '1' ){?>	
	
		$('#flgNoAto','#frmPrazoDesligamento').prop("checked",true); 
		
	<?}else IF(getByTagName($registros->tags,'tpprazo') == '2' ){?>
	
		$('#flgAposAgo','#frmPrazoDesligamento').prop("checked",true);
		
	<?}?>
	
	<?IF(getByTagName($registros->tags,'flgautori') == '1' ){?>	
	
		$('#flgNo','#frmPrazoDesligamento').prop("checked",true); 
		
	<?}else IF(getByTagName($registros->tags,'flgautori') == '2' ){?>
	
		$('#flgYes','#frmPrazoDesligamento').prop("checked",true);
		
	<?}?>
	
	formataPrazoDesligamento();
	
</script>



