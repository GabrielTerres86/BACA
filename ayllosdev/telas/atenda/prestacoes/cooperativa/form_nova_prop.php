<? 
/*!
 * FONTE        : form_nova_prop.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 * ALTERAÇÕES   : 
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 * 001: [13/04/2012] Incluir campo dtlibera (Gabriel)
 * 002: [08/04/2014] Alterado fluxo do botao Continuar. (Jorge)
 * 003: [17/06/2014] Trocado posicao dos campos "Linha Credito" por "Finalidade". (Reinert)
 * 004: [11/05/2017] Troca de posicao da Linha de Credito e Finalidade. (Jaison/James - PRJ298)
 * 004: [11/10/2017] Liberacao melhoria 442 (Heitor - Mouts)
 * 005: [13/12/2017] Alteracao da chamada da operacao C_DADOS_AVAL para C_GAROPC. (Jaison/Marcos Martini - PRJ404)
 * 006: [17/01/2018] Incluído novo campo (Qualif Oper. Controle) (Diego Simas - AMcom)
 * 007: [24/01/2018] Alteração para exibição do campo DSNIVORI como risco de inclusão (Reginaldo - AMcom)
 * 008: [08/06/2018] P410 - Incluido campo de financiar IOF (Marcos-Envolti)
 * 009: [12/07/2018] Refazer a alteracao da chamada da operacao C_DADOS_AVAL para C_GAROPC, pois a mesma
 *                   foi sobrescrita. (Renato Darosci - Supero)
 * 010: [19/11/2018] Alterado layout da tela - PRJ 438. (Mateus Z / Mouts)
 */	
 ?>

<form name="frmNovaProp" id="frmNovaProp" class="formulario condensado">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Dados da Solicitação') ?></legend>
	
		<label for="nivrisco"><? echo utf8ToHtml('Nível Risco:') ?></label>
		<select name="nivrisco" id="nivrisco">
			<option value="" > - </option>
			<option value="A">A</option>
			<option value="B">B</option>
			<option value="C">C</option>
			<option value="D">D</option>
			<option value="E">E</option>
			<option value="F">F</option>
			<option value="G">G</option>
			<option value="H">H</option>
		</select>
				
		<?php if ($tpemprst == 2) { ?>

			<label for="idfiniof">Financiar IOF e Tarifa:</label>
		    <select name="idfiniof" id="idfiniof">
		        <option value="1" selected="selected">Sim</option>
		        <option value="0">N&atilde;o</option>
		    </select>
		<br />
		
		<label for="tpemprst">Produto:</label>
		<select name="tpemprst" id="tpemprst">
		</select>
		
 		<label for="flgpagto">Debitar em:</label>
 		<select name="flgpagto" id="flgpagto">
 			<option value="no" >Conta</option>
 			<option value="yes">Folha</option>
 		</select>
		<br />
													
			<label for="vlemprst"><? echo utf8ToHtml('Valor do Empréstimo:') ?></label>
			<input name="vlemprst" id="vlemprst" type="text" value="" />

			<label for="idquapro"><? echo utf8ToHtml('Qualificação da Operação:') ?></label>
			<input name="idquapro" id="idquapro" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsquapro" id="dsquapro" type="text" value="" />
			<br />

			<label for="cdlcremp"><? echo utf8ToHtml('Linha de Crédito:') ?></label>
			<input name="cdlcremp" id="cdlcremp" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dslcremp" id="dslcremp" type="text" value="" />		
			
			<!--- Adição de novo campo (Qualif. Oper. Controle) Diego Simas (AMcom) -->
			<label for="idquaprc"><? echo utf8ToHtml('Qualificação da Operação Controle:') ?></label>
			<input name="idquaprc" id="idquaprc" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsquaprc" id="dsquaprc" type="text" value="" />
			<br/>

			<label for="cdfinemp">Finalidade:</label>
			<input name="cdfinemp" id="cdfinemp" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsfinemp" id="dsfinemp" type="text" value="" />

			<label for="dsratpro"> <? echo utf8ToHtml("Rating Proposta:"); ?> </label>
			<input name="dsratpro" id="dsratpro" type="text" value="">
			<br />
			
			<label for="qtpreemp">Quantidade de Parcelas:</label>
			<input name="qtpreemp" id="qtpreemp" type="text" value="" />

			<label for="dsratatu"><? echo utf8ToHtml("Rating Atual:"); ?></label>
			<input name="dsratatu" id="dsratatu" type="text" value="" />
			<br />

			<label for="vlpreemp"><? echo utf8ToHtml('Valor da Parcela:') ?></label>
			<input name="vlpreemp" id="vlpreemp" type="text" value="" />
			
			<label for="percetop">%CET:</label>
			<input name="percetop" id="percetop" type="text" value="" />
			<br />
														
			<label for="dtdpagto">Data de Pagamento:</label>
		<input name="dtdpagto" id="dtdpagto" type="text" value="" />

			<label for="flgdocje"><? echo utf8ToHtml('Co-Responsável:') ?></label>
			<input name="flgdocje" id="flgYes" type="radio" class="radio" value="yes" />
			<label for="flgYes" class="radio" >Sim</label>
			<input name="flgdocje" id="flgNo" type="radio" class="radio" value="no" />
			<label for="flgNo" class="radio"><? echo utf8ToHtml('Não') ?></label>
		<br />
		
			<label for="idcarenc"><? echo utf8ToHtml("Carência:") ?></label>
			<select name="idcarenc" id="idcarenc">
            <?php
                $xml  = "<Root>";
                $xml .= " <Dados>";
                $xml .= "   <flghabilitado>1</flghabilitado>"; // Habilitado (0-Nao/1-Sim/2-Todos)
                $xml .= " </Dados>";
                $xml .= "</Root>";
                $xmlResult = mensageria($xml, "TELA_PRMPOS", "PRMPOS_BUSCA_CARENCIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                $xmlObject = getObjectXML($xmlResult);
                $xmlCarenc = $xmlObject->roottag->tags[0]->tags;
                foreach ($xmlCarenc as $reg) {
                    echo '<option value="'.getByTagName($reg->tags,'IDCARENCIA').'">'.getByTagName($reg->tags,'DSCARENCIA').'</option>';
                }
            ?>
			</select>
			<br />
		
			<label for="dtcarenc"> <? echo utf8ToHtml("Data Pagto 1ª Carência:") ?> </label>
			<input name="dtcarenc" id="dtcarenc" type="text" value="" />
		<br />
						
			<label for="dsctrliq"><? echo utf8ToHtml('Liquidações:') ?></label>
			<input name="dsctrliq" id="dsctrliq" type="text" value="" />
		<br />
		
		<?php } else {?>

			<label for="idfiniof">Financiar IOF e Tarifa:</label>
		    <select name="idfiniof" id="idfiniof">
		        <option value="1" selected="selected">Sim</option>
		        <option value="0">N&atilde;o</option>
		    </select>
		    <br />
			
			<label for="tpemprst">Produto:</label>
			<select name="tpemprst" id="tpemprst">
			</select>

			<label for="flgpagto">Debitar em:</label>
	 		<select name="flgpagto" id="flgpagto">
	 			<option value="no" >Conta</option>
	 			<option value="yes">Folha</option>
	 		</select>
			<br />

			<label for="vlemprst"><? echo utf8ToHtml('Valor do Empréstimo:') ?></label>
			<input name="vlemprst" id="vlemprst" type="text" value="" />

			<label for="idquapro"><? echo utf8ToHtml('Qualificação da Operação:') ?></label>
			<input name="idquapro" id="idquapro" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsquapro" id="dsquapro" type="text" value="" />
			<br />

			<label for="cdlcremp"><? echo utf8ToHtml('Linha de Crédito:') ?></label>
			<input name="cdlcremp" id="cdlcremp" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dslcremp" id="dslcremp" type="text" value="" />		
			
			<!--- Adição de novo campo (Qualif. Oper. Controle) Diego Simas (AMcom) -->
			<label for="idquaprc"><? echo utf8ToHtml('Qualificação da Operação Controle:') ?></label>
			<input name="idquaprc" id="idquaprc" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsquaprc" id="dsquaprc" type="text" value="" />
			<br/>

			<label for="cdfinemp">Finalidade:</label>
			<input name="cdfinemp" id="cdfinemp" type="text" value="" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsfinemp" id="dsfinemp" type="text" value="" />

			<label for="dsratpro"> <? echo utf8ToHtml("Rating Proposta:"); ?> </label>
		<input name="dsratpro" id="dsratpro" type="text" value="">				
			<br />
			
			<label for="qtpreemp">Quantidade de Parcelas:</label>
			<input name="qtpreemp" id="qtpreemp" type="text" value="" />

			<label for="dsratatu"><? echo utf8ToHtml("Rating Atual:"); ?></label>
		<input name="dsratatu" id="dsratatu" type="text" value="" />
		<br />
		
			<label for="vlpreemp"><? echo utf8ToHtml('Valor da Parcela:') ?></label>
			<input name="vlpreemp" id="vlpreemp" type="text" value="" />
			
			<label for="percetop">%CET:</label>
			<input name="percetop" id="percetop" type="text" value="" />
			<br />
														
			<label for="dtdpagto">Data de Pagamento:</label>
			<input name="dtdpagto" id="dtdpagto" type="text" value="" />
			<br />

			<label for="flgdocje"><? echo utf8ToHtml('Co-Responsável:') ?></label>
			<input name="flgdocje" id="flgYes" type="radio" class="radio" value="yes" />
			<label for="flgYes" class="radio" >Sim</label>
			<input name="flgdocje" id="flgNo" type="radio" class="radio" value="no" />
			<label for="flgNo" class="radio"><? echo utf8ToHtml('Não') ?></label>
			
		<label for="dsctrliq"><? echo utf8ToHtml('Liquidações:') ?></label>
		<input name="dsctrliq" id="dsctrliq" type="text" value="" />
		<br />

		<?php } ?>
		
	</fieldset>
</form>

<div id="divBotoes">
	<? if (($operacao == 'C_NOVA_PROP') || ($operacao == 'C_NOVA_PROP_V') ) { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('TC'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_GAROPC'); return false;" />
	<? } ?>
</div>