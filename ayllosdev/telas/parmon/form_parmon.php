<?php
	/*!
	* FONTE        : form_parmon.php
	* CRIAÇÃO      : Jorge I. Hamaguchi
	* DATA CRIAÇÃO : 14/08/2013 
	* OBJETIVO     : Form da tela PARMON
	* --------------
	* ALTERAÇÕES   : 20/10/2014 - Novos campos. Chamado 198702 (Jonata-RKAM).
	*
	*                06/04/2016 - Adicionado campos de TED. (Jaison/Marcos - SUPERO)
	*
	*                24/05/2016 - Inclusão do novo parâmetro (flmntage) de monitoração de agendamento (Carlos)
	*
	*				 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div>
<form id="frmparmon" name="frmparmon" style="display:none" class="formulario" onsubmit="return false;">
    <input type="hidden" id="dsestted" />
	<fieldset>
	
	<fieldset>
		<legend>Pagamentos</legend>
		<table width="100%">
			<tr>		
				<td>
					<label for="vlinimon">Valor inicial monitora&ccedil;&atilde;o:</label>
					<input type="text" id="vlinimon" name="vlinimon" value="<? echo $vlinimon ?>" />				
				</td>
			</tr>
			<tr>		
				<td>
					<label for="vllmonip">Valor limite valida&ccedil;&atilde;o IP:</label>
					<input type="text" id="vllmonip" name="vllmonip" value="<? echo $vllmonip ?>" />
				</td>
			</tr>
		</table>
	</fieldset>
	<fieldset>
		<legend> Saque + Transfer&ecirc;ncia </legend>
		<table width="100%">
			<tr>		
				<td>
					<label for="vlinisaq">Valor inicial do saque: </label>
					<input type="text" id="vlinisaq" name="vlinisaq" value="<? echo $vlinisaq ?>" />				
				</td>
			</tr>
			<tr>		
				<td>
					<label for="vlinitrf">Valor inicial da transfer&ecirc;ncia: </label>
					<input type="text" id="vlinitrf" name="vlinitrf" value="<? echo $vlinitrf ?>" />
				</td>
			</tr>
		</table>
	</fieldset>
	<fieldset>
		<legend> Saque Individual </legend>
		<table width="100%">
			<tr>		
				<td>
					<label for="vlsaqind">Valor inicial do saque: </label>
					<input type="text" id="vlsaqind" name="vlsaqind" value="<? echo $vlinisaq ?>" />				
				</td>
			</tr>
			<tr>		
				<td>
					<label for="insaqlim">Saque deve ser o limite da conta: </label>
                    <input type="radio" name="insaqlim" id="insaqlim_1" value="1" style="margin-left: 20px;">  
					<label id="insaqlim_sim">Sim</label> 
                    <input type="radio" name="insaqlim" id="insaqlim_0" value="0" style="margin-left: 20px;" > 
					<label id="insaqlim_nao">N&atilde;o</label>
				</td>
			</tr>
		</table>
	</fieldset>
	<fieldset>
		<legend> Bloqueio Cart&atilde;o </legend>
		<table width="100%">
			<tr>		
				<td>
					<label for="inaleblq">Alertar cart&atilde;o bloqueado: </label>
					<input type="radio" name="inaleblq" id="inaleblq_1" value="1" style="margin-left: 20px;">
					<label id="inaleblq_sim">Sim</label>
                    <input type="radio" name="inaleblq" id="inaleblq_0" value="0" style="margin-left: 20px;" >
					<label id="inaleblq_nao">N&atilde;o</label>			
				</td>
			</tr>
		</table>
	</fieldset>
	<fieldset>
		<legend> TED </legend>
		<table width="100%">
			<tr>		
				<td>
					<label for="vlmnlmtd">Limite TED superior a: </label>
					<input type="text" id="vlmnlmtd" name="vlmnlmtd" value="<? echo $vlmnlmtd ?>" />				
				</td>
			</tr>
			<tr>		
				<td>
					<label for="vlinited">Valor m&iacute;nimo de TED: </label>
					<input type="text" id="vlinited" name="vlinited" value="<? echo $vlinited ?>" />				
				</td>
			</tr>
			<tr>		
				<td>
					<label for="flmstted">Monitorar TEDs mesma Titularidade: </label>
                    <input type="radio" name="flmstted" id="flmstted_1" value="1" style="margin-left: 20px;">  
					<label id="flmstted_sim">Sim</label> 
                    <input type="radio" name="flmstted" id="flmstted_0" value="0" style="margin-left: 20px;" > 
					<label id="flmstted_nao">N&atilde;o</label>
				</td>
			</tr>
			<tr>		
				<td>
					<label for="flnvfted">Monitorar somente novos favorecidos: </label>
                    <input type="radio" name="flnvfted" id="flnvfted_1" value="1" style="margin-left: 20px;">  
					<label id="flnvfted_sim">Sim</label> 
                    <input type="radio" name="flnvfted" id="flnvfted_0" value="0" style="margin-left: 20px;" > 
					<label id="flnvfted_nao">N&atilde;o</label>
				</td>
			</tr>
			<tr>		
				<td>
					<label for="flmobted">Monitoramento Mobile: </label>
                    <input type="radio" name="flmobted" id="flmobted_1" value="1" style="margin-left: 20px;">  
					<label id="flmobted_sim">Sim</label> 
                    <input type="radio" name="flmobted" id="flmobted_0" value="0" style="margin-left: 20px;" > 
					<label id="flmobted_nao">N&atilde;o</label>
				</td>
			</tr>
			<tr>		
				<td>
					<label for="flmntage">Monitorar agendamentos:</label>
                    <input type="radio" name="flmntage" id="flmntage_1" value="1" style="margin-left: 20px;">  
					<label id="flmntage_sim">Sim</label> 
                    <input type="radio" name="flmntage" id="flmntage_0" value="0" style="margin-left: 20px;" > 
					<label id="flmntage_nao">N&atilde;o</label>
				</td>
			</tr>
			<tr>		
				<td>
					<fieldset>
                        <legend> UFs para monitoramento </legend>
                        <table width="100%">
                            <tr id="linAddUF">
                                <td>
                                    <label for="nmuf">UF:</label>
                                    <select name="nmuf" id="nmuf" class="campo"></select>
                                    <a href="#" class="botao" id="btAdicionar" onclick="incluirEstado(); return false;" style="margin-left:10px;">Adicionar</a>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <label>UFs monitoradas:</label>
                                    <table cellpadding="5" cellspacing="5">
                                        <tbody id="listUF"></tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
				</td>
			</tr>
		</table>
	</fieldset>
	
	<div id="divCoptel" style="display:none;">
		<label for="dsidpara">Selecione as Cooperativas:</label><br />
		<select id="dsidpara" name="dsidpara[]" onchange="ver_rotina();" alt="Selecione a(s) Cooperativa(s).">
		</select>
		<span id="spanInfo">'Pressione CTRL para selecionar v&aacute;rias Cooperativas</span>
	</div>
	
	</fieldset>
</form>
</div>