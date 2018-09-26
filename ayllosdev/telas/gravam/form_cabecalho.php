<?php  
	/*********************************************************************
	 Fonte: form_cabecalho.php                                                 
	 Autor: Andrei - RKAM                                                     
	 Data : Maio/2016                Última Alteração: 11/04/2017
	                                                                  
	 Objetivo  : Mostrar o form do cabecalho da GRAVAM.                                  
	                                                                  
	 Alterações: 11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
	
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
	
	<input type="hidden" id="vlbtIncluir" 		name="vlbtIncluir" 		value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"M",false); ?>" />
    <input type="hidden" id="vlbtAlterar" 		name="vlbtAlterar" 		value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"A",false); ?>" />
    <input type="hidden" id="vlbtBaixar" 		name="vlbtBaixar" 		value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"B",false); ?>" />
    <input type="hidden" id="vlbtCancelar" 		name="vlbtCancelar" 	value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"X",false); ?>" />
			
    <input type="hidden" id="vlbtLibJudicial" 	name="vlbtLibJudicial" 	value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"J",false); ?>" />
    <input type="hidden" id="vlbtBlocJudicial" 	name="vlbtBlocJudicial" value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"L",false); ?>" />
    <input type="hidden" id="vlbtAltBensSubsA" 	name="vlbtAltBensSubsA" value="<? echo validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"S",false); ?>" />
		
	<label for="cddopcao"><? echo utf8ToHtml('Opcao:') ?></label>
	<select id="cddopcao" name="cddopcao">
    <option value="C"><? echo utf8ToHtml('C - Gest&atilde;o de Bens Alienados') ?></option>

    <option value="G"><? echo utf8ToHtml('G - Gerar / Retornar arquivo') ?></option>
	
    <option value="J"><? echo utf8ToHtml('J - Libera&ccedil;&atilde;o ou Bloqueio Judicial') ?></option>	
	
    <option value="S"><? echo utf8ToHtml('S - Alterar dados de bens substituidos via aditivo') ?></option>
	
    <option value="I"><? echo utf8ToHtml('I - Imprimir') ?></option>
	
    <option value="P"><? echo utf8ToHtml('P - Parâmetros GRAVAME') ?></option>
	
	
  </select>
  
  <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>

  <br style="clear:both" />
  
</form>	
