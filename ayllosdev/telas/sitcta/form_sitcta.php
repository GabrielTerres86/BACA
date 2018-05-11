<?
/* * *********************************************************************

  Fonte: form_sitcta.php
  Autor: Tiago Castro - RKAM
  Data : Jul/2015                       Última Alteração: 

  Objetivo  : Mostrar valores da SITCTA.

  Alterações: 
  

 * ********************************************************************* */
	
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C',false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$somenteConsulta = (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A',false)) <> '');
	
	$situacao = (isset($_POST['situacao'])) ? $_POST['situacao'] : 0; 
	
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= " <cdsituacao>".$situacao."</cdsituacao>";
	$xml .= " </Dados>";
	$xml .= "</Root>";		
	
	$xmlResult = mensageria($xml, "TELA_SITCTA", "BUSCAR_SITUACAO_CONTA_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xml_dados = getObjectXML($xmlResult);
	
	if ( strtoupper($xml_dados->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xml_dados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);
	}
	
	$xmlSituacao = $xml_dados->roottag->tags[0];
	$xmlLancamentos = $xml_dados->roottag->tags[1]->tags;
	$xmlLancamentosPermitidos = $xml_dados->roottag->tags[2]->tags;
	
?>
<form id="frmSitcta" name="frmSitcta" class="formulario">
	
	<div style="height: 200px; border-bottom: 1px solid #777;">
		<label> <? echo utf8ToHtml('Contrata&ccedil;&atilde;o de Produtos:'); ?> </label>
		<br>
		<br>
		<input type="checkbox" id="idimpede_credito" name="idimpede_credito" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'inimpede_credito') == 1 ? 'checked' : ''; ?> />
		<div style="text-align: left; margin-left: 30px;">		
			<? echo utf8ToHtml( "Impede opera&ccedil;&otilde;es de cr&eacute;dito (cart&atilde;o, empr&eacute;stimo, limite de cr&eacute;dito, limite de desconto, ".
								"border&ocirc;, pr&eacute;-aprovado), exceto linhas 100, 800, 900 ou se a classifica&ccedil;&atilde;o da opera&ccedil;&atilde;o ".
								"for renova&ccedil;&atilde;o ou composi&ccedil;&atilde;o de d&iacute;vida"); ?>
		</div>
		<br style="clear:both" />
		
		<input type="checkbox" id="idimpede_talionario" name="idimpede_talionario" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'inimpede_talionario') == 1 ? 'checked' : ''; ?> >
		<div style="text-align: left; margin-left: 30px;">		
			<? echo utf8ToHtml("Impede retirada de talion&aacute;rio"); ?>
		</div>
		<br style="clear:both" />
		
		<input type="checkbox" id="idcontratacao_produto" name="idcontratacao_produto" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'incontratacao_produto') > 0 ? 'checked' : ''; ?> >
		<div style="text-align: left; margin-left: 30px;">		
			<? echo utf8ToHtml("Impede a contrata&ccedil;&atilde;o de produtos e serviços"); ?>
			<br style="clear:both" />
			<input name="idctr_produto" id="rdTodos" type="radio" class="radio" value="1" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'incontratacao_produto') == 1 ? 'checked' : ''; ?> />
			<label for="rdTodos" class="radio">TODOS</label>
			<br style="clear:both" />
			<input name="idctr_produto" id="rdBoletos" type="radio" class="radio" value="2" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'incontratacao_produto') == 2 ? 'checked' : ''; ?> />
			<label for="rdBoletos" class="radio">Exceto emiss&atilde;o de boletos</label>
		</div>
	</div>
	<div style="height: 295px; border-bottom: 1px solid #777; margin-bottom: 5px;">
		<label for="dspermtdo"> <? echo utf8ToHtml('Lan&ccedil;amentos permitidos'); ?> </label>    
		<br/>
		<br/>
		
		<select id= "dslancmto" name="dslancmto" multiple <? echo $somenteConsulta ? 'disabled' : '';?>>
			<?
			foreach($xmlLancamentos as $lancamento) {
				?>
				<option value="<? echo getByTagName($lancamento->tags,'cdlancmto'); ?>"><? echo getByTagName($lancamento->tags,'dslancmto'); ?></option>
				<?
			}
			?>
		</select>
		
		<a href="#" id="btLeft" class="botao">&#9668;</a>
		<a href="#" id="btRigth" class="botao">&#9658;</a>
		
		<select id= "dspermtdo" name="dspermtdo" multiple <? echo $somenteConsulta ? 'disabled' : '';?>>
			<?
			foreach($xmlLancamentosPermitidos as $lancamento) {
				?>
				<option value="<? echo getByTagName($lancamento->tags,'cdlancmto'); ?>"><? echo getByTagName($lancamento->tags,'dslancmto'); ?></option>
				<?
			}
			?>
		</select>	
		<br/>
		<br/>
	</div>
	<label for="rdAcesso" id= "servico"><b> Acesso: </b></label>
	<div style="width: 200px; float: left; margin-left: 5px;">
		<input name="rdAcesso" id="rdAceTodos" type="radio" class="radio" value="1" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'tpacesso') == 1 ? 'checked' : ''; ?> />
		<label for="rdAceTodos" class="radio">Todos</label>
		<br style="clear:both" />
		
		<input name="rdAcesso" id="rdAceEspecial" type="radio" class="radio" value="2" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'tpacesso') == 2 ? 'checked' : ''; ?> />
		<label for="rdAceEspecial" class="radio">ACESSO ESPECIAL</label>
		<br style="clear:both" />
		
		<input name="rdAcesso" id="rdSomSistema" type="radio" class="radio" value="3" <? echo $somenteConsulta ? 'disabled' : '';?> <? echo getByTagName($xmlSituacao->tags,'tpacesso') == 3 ? 'checked' : ''; ?> />
		<label for="rdSomSistema" class="radio">Somente sistema</label>
	</div>
	
	<br style="clear:both" />
	<a href="#" id="btVoltar" class="botao">Voltar</a>
	<? if (!$somenteConsulta) { ?>
		<a href="#" id="btGravar" class="botao">Gravar</a>
	<? } ?>
	
</form>


