<?
/*!
 * FONTE        : form_fisico.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 07/06/2010
 * OBJETIVO     : Formulário para Pessoa Física da tela MATRIC
 * --------------
 * ALTERAÇÕES   : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 *				  15/06/2012 - Incluido os campos inhabmen, dthabmen (Adriano).
 * 				  09/08/2013 - Incluido campo UF de naturalidade (Reinert).
 *                16/05/2014 - Ajuste no campo de estado civil (Douglas - Chamado 131253).
 *                09/07/2015 - Projeto Reformulacao Cadastral (Gabriel-RKAM). 
 *                12/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 *                14/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
 *			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
 *					          (Adriano - P339).
 *                28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
 *							   CH, RE, PP E CT. (PRJ339 - Reinert)
 *				  25/09/2017 - Adicionado uma lista de valores para carregar orgao emissor (PRJ339 - Kelvin).
 * 				  16/10/2017 - Removendo o campo caixa postal. (PRJ339 - Kelvin).   
 *				  13/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)  
 *   			  17/03/2019 - Projeto 437 Ajuste label matricula - Jackson Barcellos AMcom
 * -------------- 
 */  
?>

<form id="frmFisico" name="frmFisico" class="formulario condensado">
	
	<input type="hidden" name="dsproftl" id="dsproftl" value="<? echo getByTagName($registro,'dsproftl') ?>" />
	<input type="hidden" name="nmmaeptl" id="nmmaeptl" value="<? echo getByTagName($registro,'nmmaeptl') ?>" />
	<input type="hidden" name="nmpaiptl" id="nmpaiptl" value="<? echo getByTagName($registro,'nmpaiptl') ?>" />
	<input type="hidden" name="nmsegntl" id="nmsegntl" value="<? echo getByTagName($registro,'nmsegntl') ?>" />
	<input type="hidden" name="rowidcem" id="rowidcem" value="<? echo getByTagName($registro,'rowidcem') ?>" />
	<input type="hidden" name="cdtipcta" id="cdtipcta" value="<? echo getByTagName($registro,'cdtipcta') ?>" />
	<input type="hidden" name="inconrfb" id="inconrfb" value="<? echo getByTagName($registro,'inconrfb') ?>" />
	
	<fieldset>
		<legend>Documentos Titular</legend>
			
		<label for="nrcpfcgc">C.P.F. :</label>
		<input type="text" name="nrcpfcgc" id="nrcpfcgc" value="<? echo getByTagName($registro,'nrcpfcgc') ?>" alt="Entre com o CPF do cooperado." />
		
		<label for="dtnasctl">Dt. Nasc.:</label>
		<input name="dtnasctl" id="dtnasctl" type="text" value="<? echo getByTagName($registro,'dtnasctl') ?>" />
		
		<label for="dtcnscpf">Consulta:</label>
		<input type="text" name="dtcnscpf" id="dtcnscpf" value="<? echo getByTagName($registro,'dtcnscpf') ?>" />
		
		<label for="cdsitcpf"><? echo utf8ToHtml('Situação:') ?></label>
		<select id="cdsitcpf" name="cdsitcpf">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($registro,'cdsitcpf') == "1"){ echo " selected"; } ?>> 1 - Regular</option>
			<option value="2" <? if (getByTagName($registro,'cdsitcpf') == "2"){ echo " selected"; } ?>> 2 - Pendente</option>
			<option value="3" <? if (getByTagName($registro,'cdsitcpf') == "3"){ echo " selected"; } ?>> 3 - Cancelado</option>
			<option value="4" <? if (getByTagName($registro,'cdsitcpf') == "4"){ echo " selected"; } ?>> 4 - Irregular</option>
			<option value="5" <? if (getByTagName($registro,'cdsitcpf') == "5"){ echo " selected"; } ?>> 5 - Suspenso</option>
		</select>	
		<br />		

		<label for="nmprimtl">Nome Tit.:</label>
		<input type="text" name="nmprimtl" id="nmprimtl" value="<? echo getByTagName($registro,'nmprimtl') ?>" alt="Entre com o nome do associado." />
		<br />
		
		<label for="nmttlrfb">Nome RFB:</label>
		<input type="text" name="nmttlrfb" id="nmttlrfb" value="<? echo getByTagName($registro,'nmttlrfb') ?>" />
		<br />
		
		<label for="nmsocial">Nome Social:</label>
		<input type="text" name="nmsocial" id="nmsocial" value="<? echo getByTagName($titulares,'nmsocial') ?>" />
		<br />
		
		<label for="tpdocptl">Documento:</label>
		<select name="tpdocptl" id="tpdocptl">
			<option value=""   <? if (getByTagName($registro,'tpdocptl') == ""  ){ echo " selected"; } ?>> - </option> 
			<option value="CI" <? if (getByTagName($registro,'tpdocptl') == "CI"){ echo " selected"; } ?>>CI - Carteira de Identidade </option>
			<option value="CN" <? if (getByTagName($registro,'tpdocptl') == "CN"){ echo " selected"; } ?>>CN - Certid&atilde;o de Nascimento</option>
			<option value="CH" <? if (getByTagName($registro,'tpdocptl') == "CH"){ echo " selected"; } ?>>CH - Carteira de Habilitacao</option>
			<option value="RE" <? if (getByTagName($registro,'tpdocptl') == "RE"){ echo " selected"; } ?>>RE - Registro Nacional de Estrangeiro</option>
			<option value="PP" <? if (getByTagName($registro,'tpdocptl') == "PP"){ echo " selected"; } ?>>PP - Passaporte</option>
			<option value="CT" <? if (getByTagName($registro,'tpdocptl') == "CT"){ echo " selected"; } ?>>CT - Carteira de Trabalho</option>
		</select>
		<input name="nrdocptl" id="nrdocptl" type="text" value="<? echo getByTagName($registro,'nrdocptl') ?>" />
		
		<br />

		<label for="cdoedptl">Org. Emi.:</label>
		<input name="cdoedptl" id="cdoedptl" type="text" value="<? echo getByTagName($registro,'cdoedptl') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <input name="nmoedptl" id="nmoedptl" type="text" style="display:none;" />
		
					
		<label for="cdufdptl">U.F.:</label>
		<? echo selectEstado('cdufdptl', getByTagName($registro,'cdufdptl'), 1) ?>
		
		<label for="dtemdptl">Dt. Emi.:</label>
		<input name="dtemdptl" id="dtemdptl" type="text" value="<? echo getByTagName($registro,'dtemdptl') ?>" />

		<input style="margin:3px 5px;" <?=($modalidade == 2 ? 'checked' : '')?> type="checkbox" id="flgctsal" name="flgctsal" value="1" /> <label>Conta Modalidade Sal&aacute;rio</label>

		<br style="clear:both" />
	</fieldset>
	
	<fieldset>
		<legend>Inf. Complementares</legend>
		
		<label for="tpnacion">Tp. Nacion.:</label>
		<input name="tpnacion" id="tpnacion" type="text" value="<? echo getByTagName($registro,'tpnacion') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="destpnac" id="destpnac" type="text" value="<? echo getByTagName($registro,'destpnac') ?>" />
		<br />
		
		<label for="cdnacion">Nacional.:</label>
        <input type="text" name="cdnacion" id="cdnacion" value="<? echo getByTagName($registro,'cdnacion') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsnacion" id="dsnacion" type="text" value="<? echo getByTagName($registro,'dsnacion') ?>" />
		<br />
		
		<label for="dsnatura">Natural.:</label>
		<input name="dsnatura" id="dsnatura" type="text" value="<? echo getByTagName($registro,'dsnatura') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>	
		
		<label for="cdufnatu">U.F.:</label>
		<? echo selectEstado('cdufnatu', getByTagName($registro,'cdufnatu'), 1) ?>
		
		<label for="cdsexotl">Sexo:</label>
		<input name="cdsexotl" id="sexoMas" type="radio" class="radio" value="1" <? if (getByTagName($registro,'cdsexotl') == '1') { echo ' checked'; } ?> />
		<label for="sexoMas" class="radio">Mas</label>
		<input name="cdsexotl" id="sexoFem" type="radio" class="radio" value="2" <? if (getByTagName($registro,'cdsexotl') == '2') { echo ' checked'; } ?> />
		<label for="sexoFem" class="radio">Fem</label>
		<br />
		
		<label for="inhabmen">Capc. Civil:</label>
		<select id="inhabmen" name="inhabmen">
			<option value=""> - </option>
			<option value="0" <? if (getByTagName($registro,'inhabmen') == '0'){ echo ' selected'; } ?>> 0 - MENOR / MAIOR</option>
			<option value="1" <? if (getByTagName($registro,'inhabmen') == '1'){ echo ' selected'; } ?>> 1 - MENOR HABILITADO</option>
			<option value="2" <? if (getByTagName($registro,'inhabmen') == '2'){ echo ' selected'; } ?>> 2 - INCAPACIDADE CIVIL</option>
		</select>	

		<label for="dthabmen">Dt. Emanc.:</label>
		<input name="dthabmen" id="dthabmen" type="text" value="<? echo getByTagName($registro,'dthabmen') ?>" />
		<br />
		
		<label for="cdestcvl">Est. Civil:</label>
		<input name="cdestcvl" id="cdestcvl" type="text" value="<? echo getByTagName($registro,'cdestcv2') ?>" />	
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsestcvl" id="dsestcvl" type="text" value="<? echo getByTagName($registro,'dsestcv2') ?>" />

		<label for="nmconjug"><? echo utf8ToHtml('Cônjuge:') ?></label>
		<input name="nmconjug" id="nmconjug" type="text" value="<? echo getByTagName($registro,'nmconjug') ?>" />
		<br />
		
		<label for="cdempres">Empregador:</label>
		<input name="cdempres" id="cdempres" type="text" value="<? echo getByTagName($registro,'cddempre') ?>" />	
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="nmresemp" id="nmresemp" type="text" value="<? echo getByTagName($registro,'nmresemp') ?>" />
		
		<label for="nrcadast">Matr. Emp.:</label>
		<input name="nrcadast" id="nrcadast" type="text" value="<? echo getByTagName($registro,'nrcadast') ?>" />	
		<br />
		
		<label for="cdocpttl"><? echo utf8ToHtml('Ocupação:') ?></label>
		<input name="cdocpttl" id="cdocpttl" type="text" value="<? echo getByTagName($registro,'cdocpttl') ?>" />	
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsocpttl" id="dsocpttl" type="text" value="<? echo getByTagName($registro,'dsocpttl') ?>" />
		
		<label for="dsdemail"><? echo utf8ToHtml('Email:') ?></label>
		<input name="dsdemail" id="dsdemail" type="text" value="<? echo getByTagName($registro,'dsdemail') ?>" />	
		
		<br style="clear:both" />
				
		<label for="nrtelres"><? echo utf8ToHtml('Tel. Res.:') ?></label>		
		<input name="nrdddres" id="nrdddres" type="text"  value="<? echo getByTagName($registro,'nrdddres') ?>" />		
		<input name="nrtelres" id="nrtelres" type="text"  value="<? echo getByTagName($registro,'nrtelres') ?>" />
		
		<label for="nrtelcel"><? echo utf8ToHtml('Celular:') ?></label>
		<input name="nrdddcel" id="nrdddcel" type="text"  value="<? echo getByTagName($registro,'nrdddcel') ?>" />		
		<input name="nrtelcel" id="nrtelcel" type="text"  value="<? echo getByTagName($registro,'nrtelcel') ?>" />
		
		<label for="cdopetfn"><? echo utf8ToHtml('Operadora:') ?></label>	
		<select id="cdopetfn" name="cdopetfn">
			<? for ($i=0; $i < count($operadoras); $i++) { ?>
			
				<? $selected = ($operadoras[$i]->tags[0]->cdata == getByTagName($registro,'cdopetfn') ) ? ' selected' : ''; ?>
			
				<option value="<? echo $operadoras[$i]->tags[0]->cdata ?>" <? echo $selected ?> > <? echo $operadoras[$i]->tags[1]->cdata ?> </option>
		
			<? } ?>
		</select>

				
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Filiação') ?></legend>
		
		<label for="nmmaettl"><? echo utf8ToHtml('Nome Mãe:') ?></label>
		<input name="nmmaettl" id="nmmaettl" type="text" value="<? echo stringTabela(getByTagName($registro,'nmmaettl'),41,'maiuscula') ?>" />		
	
		<label for="nmpaittl">Nome Pai:</label>
		<input name="nmpaittl" id="nmpaittl" type="text" value="<? echo stringTabela(getByTagName($registro,'nmpaittl'),41,'maiuscula') ?>" />		
		<br style="clear:both" />	
				
	</fieldset>	
	
	<fieldset>
		<legend><? echo utf8ToHtml('Endereço') ?></legend>

		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($registro,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

		<label for="dsendere"><? echo utf8ToHtml('End.:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo getByTagName($registro,'dsendere') ?>" />		
		<br />

		<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($registro,'nrendere') ?>" />

		<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo getByTagName($registro,'complend') ?>" />
		<br />
		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($registro,'cdufende'), 1); ?>	

		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($registro,'nmbairro') ?>" />								
		<br />	

		<label for="idorigee" class="rotulo"><? echo utf8ToHtml('Origem:'); ?></label>
		<select id="idorigee" name="idorigee">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($registro,'idorigee') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
			<option value="2" <? if (getByTagName($registro,'idorigee') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
			<option value="3" <? if (getByTagName($registro,'idorigee') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
		</select>

		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($registro,'nmcidade') ?>" />

		<br style="clear:both" />
		
	</fieldset>	

	<fieldset>
		<legend><? echo utf8ToHtml('Entrada/Saída Cooperado') ?></legend>
		
		<label for="dtadmiss"><? echo utf8ToHtml('Admissão:') ?></label>
		<input type="text" name="dtadmiss" id="dtadmiss" value="<? echo getByTagName($registro,'dtadmiss') ?>" />
		
		<label for="dtdemiss"><? echo utf8ToHtml('Saída:') ?></label>
		<input type="text" name="dtdemiss" id="dtdemiss" value="<? echo getByTagName($registro,'dtdemiss') ?>" />
		
		<label for="cdmotdem">Motivo:</label>
		<input type="text" name="cdmotdem" id="cdmotdem" value="<? echo getByTagName($registro,'cdmotdem') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="dsmotdem" id="dsmotdem" value="<? echo getByTagName($registro,'dsmotdem') ?>" />
		<br style="clear:both" />
		
	</fieldset>		
	
</form>