<?
/* * *********************************************************************

  Fonte: form_tipo_de_conta.php
  Autor: Lombardi
  Data : Dezembro/2018                       Última Alteração: 

  Objetivo  : Mostrar valores da TIPCTA.

  Alterações: 

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$dominios = buscaDominios('CC', 'MODALIDADE_TIPO_CONTA');
	
?>
<form id="frmTipoConta" name="frmTipoConta" class="formulario" style="display:none;">
	
	<fieldset id="fsetTipoConta" name="fsetTipoConta" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Tipo de Conta</legend>
		
		<label for="inpessoa"><? echo utf8ToHtml("Tipo de Pessoa:"); ?></label>

		<input type="radio" id="inpessoa_1" name="inpessoa" value="1">
		<label><? echo utf8ToHtml("F&iacute;sica"); ?></label>
		
		<input type="radio" id="inpessoa_2" name="inpessoa" value="2">
		<label><? echo utf8ToHtml("Jur&iacute;dica"); ?></label>
		
		<input type="radio" id="inpessoa_3" name="inpessoa" value="3" <? echo (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P',false) <> '') ? 'style="display: none;"' : '';?> >
		<label <? echo (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P',false) <> '') ? 'style="display: none;"' : '';?> ><? echo utf8ToHtml("Jur&iacute;dica – Cooperativa"); ?></label>
		
		<label for="cdtipo_conta"><? echo utf8ToHtml("Tipo de Conta:"); ?></label>
		<input type="text" id="cdtipo_conta" name="cdtipo_conta" >
		
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('frmTipoConta',true); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<input type="text" id="dstipo_conta" name="dstipo_conta" >
		
		<label for="cdcatego"><? echo utf8ToHtml("Categoria: "); ?></label>
	
		<label style="margin-left: 4px;"><? echo utf8ToHtml("Individual"); ?></label>
		<input type="checkbox" id="individual" name="cdcatego" >
		
		<label><? echo utf8ToHtml("Conjunta solid&aacute;ria"); ?></label>
		<input type="checkbox" id="conjunta_solidaria" name="cdcatego" >
		
		<label><? echo utf8ToHtml("Conjunta n&atilde;o solid&aacute;ria"); ?></label>
		<input type="checkbox" id="conjunta_nao_solidaria" name="cdcatego" >
		
		<label for="tpcadast"><? echo utf8ToHtml("Tipo de Cadastro:"); ?></label>
		<select id="tpcadast">
			<option value="1">Intermedi&aacute;rio</option>
			<option value="2">Completo</option>
		</select>
		
		<label for="cdmodali"><? echo utf8ToHtml("Modalidade:"); ?></label>
		<select id="cdmodali">
			<?	
			foreach($dominios as $dominio) {
				?> 
				<option value="<? echo getByTagName($dominio->tags,'cddominio'); ?>"><? echo getByTagName($dominio->tags,'dscodigo'); ?></option>
				<?
			}
			?>
		</select>
		
		<label for="indconta_itg"><? echo utf8ToHtml("Conta Integra&ccedil;&atilde;o:"); ?></label>
		<select id="indconta_itg" name="indconta_itg">
			<option value="0">N&atilde;o</option>
			<option value="1">Sim</option>
		</select>
		
	</fieldset>
	
	<div id="divBotoes" style="display:none;padding-bottom: 15px;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>																																							
		<a href="#" class="botao" id="btProsseguir" ></a>
	</div>
</form>

