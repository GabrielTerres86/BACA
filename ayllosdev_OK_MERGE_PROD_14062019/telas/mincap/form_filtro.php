<?php
/*****************************************************************
  Fonte        : form_filtro.php						Última Alteração:  
  Criação      : Jonata - RKAM
  Data criação : Junho/2017
  Objetivo     : Mostrar os filtros para da tela MINCAP
  --------------
	Alterações   :  
	
	
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
			
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>0</cdcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
		
	}	
	
	$registros = $xmlObj->roottag->tags[0]->tags;
		
	
?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">	
	
	<fieldset id="fsetFiltroProduto" name="fsetFiltroProduto" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo "Filtros"; ?></legend>
		
		<label for="cdcopsel"><? echo utf8ToHtml('Cooperativa:') ?></label>
		<select id="cdcopsel" name="cdcopsel">
			<?php
			foreach ($registros as $r) {
				
				if ( getByTagName($r->tags, 'cdcooper') <> '' ) {
			?>
				<option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"><?= getByTagName($r->tags, 'nmrescop'); ?></option> 
				
				<?php
				}
			}
			?>
		</select>	
			
		<label for="tppessoaFis"><? echo utf8ToHtml('F&iacute;sica:') ?></label>
		<input name="tppessoa" id="tppessoaFis" type="radio" class="radio" value='1'/>
		<label for="tppessoaJur"><? echo utf8ToHtml('Jur&iacute;dica:') ?></label>
		<input name="tppessoa" id="tppessoaJur" type="radio" class="radio" value='2'/>
			
		<br style="clear:both" />	

	</fieldset>
							
</form>

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="buscaTiposConta('1','30');return false;">Prosseguir</a>	
				
</div>


