<? 
/*!
 * FONTE        : aba_historicos.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)
 * DATA CRIAÇÃO : março/2018 
 * OBJETIVO     : Rotina para carregar combo de seleção da origem para os históricos 
 *                das operações de parametrização do Debitador Único
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

  session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');

?>

<div id="divSelecaoOrigem">
    <label for="tporigem">Origem dos dados:</label>
    <select id="tporigem" onchange="carregarDadosHistoricos()" class="campo">
        <option selected value="1">Prioridades</option>
        <option value="2"><? echo utf8ToHtml('Horários'); ?></option>
        <option value="3"><? echo utf8ToHtml('Execução Emergencial'); ?></option>
    </select>
</div>

<div id="divDadosHistoricos" style="width: 100%; margin-top: 15px;">
</div>
	
	