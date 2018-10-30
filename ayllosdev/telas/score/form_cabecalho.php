<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Thaise Medeiros - Envolti
	 Data : Outubro/2018                Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da SCORE.                               
	                                                                  
	 Alterações: 
	
	**********************************************************************/
  
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {			
			exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
?>

<form name="frmCab" id="frmCab" class="formulario cabecalho" style= "display:none;">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
		
	<label for="cddopcao"><? echo utf8ToHtml('Opcao:') ?></label>
	<select id="cddopcao" name="cddopcao">
    	<option value="C"><? echo utf8ToHtml('C - Cargas de score disponíveis') ?></option>
		<option value="H"><? echo utf8ToHtml('H - Histórico das cargas de score') ?></option>	
  	</select>
  
  	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

	<br style="clear:both" />
  
</form>	
