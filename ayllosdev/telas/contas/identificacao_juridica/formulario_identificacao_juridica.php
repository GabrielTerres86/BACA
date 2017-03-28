<? 
/*!
 * FONTE        : formulario_identificacao_juridica.php
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Fomulário de dados de Identificação Jurídica
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [09/02/2010] Rodolpho Telmo  (DB1): Alterar funções de busca descrição e pesquisa para as funções genéricas
 * 002: [10/02/2010] Rodolpho Telmo  (DB1): Alterar funções de busca descrição e pesquisa para as funções genéricas
 * 003: [24/03/2010] Rodolpho Telmo  (DB1): Adequação ao novo padrão
 * 004: [13/04/2010] Rodolpho Telmo  (DB1): Inserção da propriedade maxlength nos inputs 
 * 005: [11/02/2011] Gabriel Ramirez	  : Aumentar formato do campo 'Nome Talao' para 40 caracteres
 * 006: [09/08/2013] Jean Michel		  : Inclusão de botão Dossiê
 * 007: [23/10/2013] Jean Michek          : Alteração do link do botão Dossiê
 * 008: [23/07/2015] Gabriel        (RKAM): Reformulacao Cadastral 
 * 009: [25/10/2016] Tiago                : Inclusao da data de validade da licensa (M310).
 * 010: [27/03/2017] Reinert			  : Alterado botão "Dossie DigiDOC" para chamar rotina do Oracle. (Projeto 357)
 */
?>

<form name="frmDadosIdentJuridica" id="frmDadosIdentJuridica" class="formulario">		
	
	<input name="dtcadass" id="dtcadass" type="hidden" class="alphanum" value="<? echo getByTagName($identificacao,'dtcadass') ?>" />
	
	<label for="nmprimtl" class="rotulo rotulo-90">Raz&atilde;o Social:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" class="alphanum" value="<? echo getByTagName($identificacao,'nmprimtl') ?>" />
	<br />
	
	<label for="nmfatasi" class="rotulo rotulo-90">Nome Fantasia:</label>
	<input name="nmfatasi" id="nmfatasi" type="text" class="alphanum" maxlength="40" value="<? echo getByTagName($identificacao,'nmfatasi') ?>" />
	
	<label for="inpessoa" class="rotulo-80">Tp. Natureza:</label>
	<input name="inpessoa" id="inpessoa" type="text" value="<? echo getByTagName($identificacao,'inpessoa')." - ".getByTagName($identificacao,'dspessoa'); ?>" />
	<br />

	<label for="nrcpfcgc" class="rotulo rotulo-90">C.N.P.J:</label>
	<input name="nrcpfcgc" id="nrcpfcgc" type="text" class="cnpj" value="<? echo getByTagName($identificacao,'nrcpfcgc') ?>" />
	
	<label for="dtcnscpf" style="width:55px;">Consulta:</label>
	<input name="dtcnscpf" id="dtcnscpf" type="text" class="data" value="<? echo getByTagName($identificacao,'dtcnscpf') ?>" />
	
	<label for="cdsitcpf" class="rotulo-80">Situa&ccedil;&atilde;o:</label>
	<select id="cdsitcpf" name="cdsitcpf">
		<option value=""> - </option>
		<option value="1" <? if (getByTagName($identificacao,'cdsitcpf') == "1"){ echo " selected"; } ?>> 1 - Regular</option>
		<option value="2" <? if (getByTagName($identificacao,'cdsitcpf') == "2"){ echo " selected"; } ?>> 2 - Pendente</option>
		<option value="3" <? if (getByTagName($identificacao,'cdsitcpf') == "3"){ echo " selected"; } ?>> 3 - Cancelado</option>
		<option value="4" <? if (getByTagName($identificacao,'cdsitcpf') == "4"){ echo " selected"; } ?>> 4 - Irregular</option>
	</select>		
	<br />
	
	<label for="qtfilial" class="rotulo rotulo-90">Qt. Filiais:</label>
	<input name="qtfilial" id="qtfilial" type="text" class="inteiro"  maxlength="3" value="<? echo getByTagName($identificacao,'qtfilial') ?>" />
	
	<label for="qtfuncio">Qt. Funcion&aacute;rios:</label>
	<input name="qtfuncio" id="qtfuncio" type="text" class="inteiro" maxlength="6" value="<? echo getByTagName($identificacao,'qtfuncio') ?>" />
	
	<label for="dtiniatv" class="rotulo-80">In&iacute;cio Ativ.:</label>
	<input name="dtiniatv" id="dtiniatv" type="text" class="data" value="<? echo getByTagName($identificacao,'dtiniatv') ?>" />
	<br />

	<label for="cdnatjur" class="rotulo rotulo-90">Nat. Jur&iacute;dica:</label>
	<input name="cdnatjur" id="cdnatjur" type="text" class="codigo pesquisa" value="<? echo getByTagName($identificacao,'cdnatjur') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input name="dsnatjur" id="dsnatjur" type="text" class="descricao" value="<? echo getByTagName($identificacao,'dsnatjur') ?>" />
	<br />		
	
	<label for="cdseteco" class="rotulo rotulo-90">Setor Econ.:</label>																	
	<input name="cdseteco" id="cdseteco" type="text" class="codigo pesquisa" value="<? echo getByTagName($identificacao,'cdseteco') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input name="nmseteco" id="nmseteco" type="text" class="descricao" value="<? echo getByTagName($identificacao,'nmseteco') ?>" />
	<br />		
	
	<label for="cdrmativ" class="rotulo rotulo-90">Ramo Ativ.:</label>
	<input name="cdrmativ" id="cdrmativ" type="text" class="codigo pesquisa" value="<? echo getByTagName($identificacao,'cdrmativ') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input name="dsrmativ" id="dsrmativ" type="text" class="descricao" value="<? echo getByTagName($identificacao,'dsrmativ') ?>" />
	<br />			

	<label for="cdcnae" class="rotulo rotulo-90">CNAE:</label>
	<input name="cdcnae" id="cdcnae" type="text" class="pesquisa" value="<? echo getByTagName($identificacao,'cdclcnae') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input name="dscnae" id="dscnae" type="text" class="descricao" value="" />
	<br />	

	<label for="nrlicamb" class="rotulo rotulo-90">Nr da Licença:</label>
	<input name="nrlicamb" id="nrlicamb" type="text" class="pesquisa" maxlength="15" value="<? echo getByTagName($identificacao,'nrlicamb') ?>" />
	<label for="dtvallic" style="width:155px;">Data de validade da Licença:</label>
	<input name="dtvallic" id="dtvallic" type="text" class="data" maxlength="10" value="<? echo getByTagName($identificacao,'dtvallic') ?>" />

	<br />

	<label for="nmtalttl" class="rotulo rotulo-90">Nome Tal&atilde;o:</label>
	<input name="nmtalttl" id="nmtalttl" type="text" class="alphanum" maxlength="40" value="<? echo getByTagName($identificacao,'nmtalttl') ?>" />
	
	<label for="qtfoltal" class="rotulo-linha">Folhas Tal&atilde;o:</label>
	<input name="qtfoltal" id="qtfoltal" type="text" class="inteiro" maxlength="2" value="<? echo getByTagName($identificacao,'qtfoltal') ?>" />
	<br />

	<label for="dsendweb" class="rotulo" style="width:140px;">Endereço Internet (Site):</label>
	<input name="dsendweb" id="dsendweb" type="text" class="url" maxlength="40" value="<? echo getByTagName($identificacao,'dsendweb') ?>" />
	<a class="link"><img src="<? echo $UrlImagens; ?>icones/link.png" alt="Acessar Site" /></a>
	<br clear="both" />
</form>

<div id="divBotoes">		
	<? if ( in_array($operacao,array('FA','')) ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina);" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA');" />
		<input type="image" id="btDosie" class="opConsulta" src="<? echo $UrlImagens; ?>botoes/dossie.gif" onClick="dossieDigdoc(8);return false;"/>
	<? } else if ($flgcadas != 'M')  { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC');" />
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV')"  />
	<? } else  { // SE VEM DA MATRIC ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="fechaRotina(divRotina);" />
	<? } ?>
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();"  />

</div>