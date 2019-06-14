<? 
/*!
 * FONTE        : form_detalhes.php						Última alteração:  
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Apresenta o form com as informações do domniio da tela PARRGP
 * --------------
 * ALTERAÇÕES   :  
                    
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmDetalhes" name="frmDetalhes" class="formulario" style="display:none;">

	<fieldset id="fsetDetalhes" name="fsetDetalhes" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Detalhes"; ?></legend>
		
		<label for="idproduto"><? echo utf8ToHtml('Código:') ?></label>
		<input type="text" id="idproduto" name="idproduto"/>
		
		<br />
		
		<label for="dsproduto"><? echo utf8ToHtml('Produto:') ?></label>
		<input type="text" id="dsproduto" name="dsproduto"/>
		
		<br />
		
		<label for="tpdestino"><? echo utf8ToHtml('Destino:') ?></label>
		<select id="tpdestino" name="tpdestino" >
			<option value="C" selected> Central </option>
			<option value="S"> Singular </option>
		</select>
		
		<br />
		
		<label for="tparquivo"><? echo utf8ToHtml('Importa Arquivo:') ?></label>
		<select id="tparquivo" name="tparquivo" >
			<option value="Nao" selected> N&atilde;o </option>
			<option value="Cartao_Bancoob"> Cartao Bancoob </option>
			<option value="Cartao_BB"> Cartao BB </option>
			<option value="Cartao_BNDES_BRDE"> Cart&atilde;o BNDES BRDE </option>
			<option value="Inovacred_BRDE"> Inovacred BRDE </option>
			<option value="Finame_BRDE"> Finame BRDE </option>
		</select>

		<br />
		
		<label for="idgarantia"><? echo utf8ToHtml('Garantia:') ?></label>
		<input type="text" id="idgarantia" name="idgarantia"/>
		<a style="padding: 3px 0 0 3px;" href="#"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsgarantia" name="dsgarantia"/>
		<input type="hidden" id="iddominio_idgarantia" name="iddominio_idgarantia"/>
		
		<br />
		
		<label for="idmodalidade"><? echo utf8ToHtml('Modalidade:') ?></label>
		<input type="text" id="idmodalidade" name="idmodalidade"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsmodalidade" name="dsmodalidade"/>
		<input type="hidden" id="iddominio_idmodalidade" name="iddominio_idmodalidade"/>
		
		<br />
		
		<label for="idconta_cosif"><? echo utf8ToHtml('Cosif:') ?></label>
		<input type="text" id="idconta_cosif" name="idconta_cosif"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsconta_cosif" name="dsconta_cosif"/>
		<input type="hidden" id="iddominio_idconta_cosif" name="iddominio_idconta_cosif"/>
		
		<br />
		
		<label for="idorigem_recurso"><? echo utf8ToHtml('Origem Recurso:') ?></label>
		<input type="text" id="idorigem_recurso" name="idorigem_recurso"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsorigem_recurso" name="dsorigem_recurso"/>
		<input type="hidden" id="iddominio_idorigem_recurso" name="iddominio_idorigem_recurso"/>
		
		<br />
		
		<label for="idindexador"><? echo utf8ToHtml('Indexador:') ?></label>
		<input type="text" id="idindexador" name="idindexador"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsindexador" name="dsindexador"/>
		<input type="hidden" id="iddominio_idindexador" name="iddominio_idindexador"/>
		
		<br />
		
		<label for="perindexador"><? echo utf8ToHtml('Perc. Indexador:') ?></label>
		<input type="text" id="perindexador" name="perindexador"/>
		
		<br />
		
		<label for="vltaxa_juros"><? echo utf8ToHtml('Taxa de Juros (a.a):') ?></label>
		<input type="text" id="vltaxa_juros" name="vltaxa_juros"/>
		
		<br />
		
		<label for="cdclassifica_operacao"><? echo utf8ToHtml('ClassOp:') ?></label>
		<select id="cdclassifica_operacao" name="cdclassifica_operacao" >
			<option value="AA" selected> AA </option>
			<option value="RS"> Risco Singular </option>
		</select>
		
		<br />
		
		<label for="idvariacao_cambial"><? echo utf8ToHtml('Var. Cambial:') ?></label>
		<input type="text" id="idvariacao_cambial" name="idvariacao_cambial"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsvariacao_cambial" name="dsvariacao_cambial"/>
		<input type="hidden" id="iddominio_idvariacao_cambial" name="iddominio_idvariacao_cambial"/>
		
		<br />
		
		<label for="idorigem_cep"><? echo utf8ToHtml('CEP:') ?></label>
		<select id="idorigem_cep" name="idorigem_cep" >
			<option value="C" selected> Central </option>
			<option value="S"> Singular </option>
		</select>
		
		<br />
		
		<label for="idnat_operacao"><? echo utf8ToHtml('Natureza Operação:') ?></label>
		<input type="text" id="idnat_operacao" name="idnat_operacao"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsnat_operacao" name="dsnat_operacao"/>
		<input type="hidden" id="iddominio_idnat_operacao" name="iddominio_idnat_operacao"/>
		
		<br />
		
		<label for="idcaract_especial"><? echo utf8ToHtml('Caracteristica Especial:') ?></label>
		<input type="text" id="idcaract_especial" name="idcaract_especial"/>		
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dscaract_especial" name="dscaract_especial"/>
		<input type="hidden" id="iddominio_idcaract_especial" name="iddominio_idcaract_especial"/>
		
		<br />
		
		<label for="flpermite_saida_operacao"><? echo utf8ToHtml('Permite Saída:') ?></label>
		<input type="checkbox" id="flpermite_saida_operacao" name="flpermite_saida_operacao"/>
		
		<br />
		
		<label for="flpermite_fluxo_financeiro"><? echo utf8ToHtml('Permite Fluxo Financeiro:') ?></label>
		<input type="checkbox" id="flpermite_fluxo_financeiro" name="flpermite_fluxo_financeiro"/>
		
		<br />
		
		<label for="flreaprov_mensal"><? echo utf8ToHtml('Reaproveitamento Mensal:') ?></label>
		<input type="checkbox" id="flreaprov_mensal" name="flreaprov_mensal"/>
		
		<br style="clear:both" />
		
	</fieldset>
	
</form>

<div id="divBotoesDetalhes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>																																							
	
	<?php if($cddopcao != 'C'){?>
	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
	<?php }?>
		
																				
</div>
 