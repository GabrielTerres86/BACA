<?
/*!
 * FONTE        : valida_cpf_interveniente.php
 * CRIA��O      : Maykon D. Granemann (Envolti)
 * DATA CRIA��O : 16/08/2018
 * OBJETIVO     : Rotina para validar se o CPF passado ja esta cadastrado.
 * --------------
 * ALTERA��ES   :
 * --------------
 *   
 */
?>
<?    
    include('../includes/requires.php');

    $parametrosRequisicao = array('nrdconta', 'nrctremp', 'tpctrato','nrcpfcgc');
    $nomeTela = "TELA_MANBEM";
    $nomeFuncaoBanco ="CPF_CADASTRADO";
    $tagPrincipal = "Dados";
    global $xmlObject;
    try{
        $tagEncontrada = executa();
        if($tagEncontrada)
        {
            $msgSuccess  = $xmlObject->roottag->tags[0]->attributes['EHASSOCIADO'];             
            echo respostaJson(1,$msgSuccess, 0);                
        }
    }
    catch(Exception $ex)
    {
        echo respostaJson(2,$ex->getMessage(), -1);
    }   
?>