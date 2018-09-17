<?php
/*!
 * FONTE        : form_ativar_processo.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Formulário para inclusão de horários de execução do programa
 *                (tela ALTERAR do cadastro de prioridades da parametrização 
 *                do Debitador Único)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

 session_start();

 require_once('../../../includes/config.php');
 require_once('../../../includes/funcoes.php');
 require_once('../../../includes/controla_secao.php');
 require_once('../../../class/xmlfile.php');

 isPostMethod();

 $cddopcao = $_POST['cddopcao'];

$msgError = validaPermissao($glbvars["nmdatela"],$glbvars['nmrotina'],$cddopcao, false);

if ($msgError != '') {
    exibirErro('error', utf8ToHtml('Acesso não permitido.'), 'Alerta - Ayllos', 'estadoInicial()', false);
}		

 $cdprocesso = $_POST['cdprocesso'];
 $dsprocesso = $_POST['dsprocesso'];


 // Monta o xml de requisição
 $xml = "<Root>";
 $xml .= " <Dados>";
 $xml .= " </Dados>";
 $xml .= "</Root>";
 
 $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_COOP_BUSCAR", 
     $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
     $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");    
 
 
 $xmlObjeto = getObjectXML($xmlResult);

 $cooperativas = $xmlObjeto->roottag->tags[0]->tags;
 
 //----------------------------------------------------------------------------------------------------------------------------------	
 // Controle de Erros
 //----------------------------------------------------------------------------------------------------------------------------------
 if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
     $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
     exibirErro('error',$msgErro,'Alerta - Ayllos','unblockBackground()',false);
 }

echo '<form id="frmDet" name="frmDet" class="formulario detalhe" onSubmit="return false;">';
echo '	<fieldset>';
echo '		<legend>' . utf8ToHtml('Parâmetros') . '</legend>';
echo '		<label for="cdcooper">Cooperativa:</label>';
echo '			<select id="cdcooper" class="campo" onchange="trocaCooperativa()">';
echo '			<option value="">-----</option>';

foreach($cooperativas as $cooperativa) {
    echo '<option value="' .getByTagName($cooperativa->tags, 'cdcooper') . '">' .
        getByTagName($cooperativa->tags, 'nmrescop') . '</option>';
}

echo '		</select>';
echo '	</fieldset>';
echo '</form>';
echo '<div id="divProgramas">';
echo '</div>';
