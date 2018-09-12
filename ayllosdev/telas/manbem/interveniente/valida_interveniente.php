<?
/*!
 * FONTE        : valida_interveniente.php
 * CRIAÇÃO      : Maykon D. Granemann (Envolti)
 * DATA CRIAÇÃO : 16/08/2018
 * OBJETIVO     : Rotina para validar os dados para cadastro de interveniente.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *   
 */
?>
<?
    include('../includes/requires.php');

    $nomeTela = "TELA_MANBEM";
    $nomeFuncaoBanco ="VALIDA_INTERVENIENTE";
    $parametrosRequisicao = array(
                                    'nrdconta', 'nrcepend', 'dsendre1', 'nmdavali', 'nrcpfcgc', 'tpdocava',
                                    'nrdocava', 'nmconjug', 'nrcpfcjg', 'tpdoccjg', 'nrdoccjg', 'cdnacion'
                                );
    $tagPrincipal = "Dados";

    try{
        $tagEncontrada = executa();
        if($tagEncontrada)
        {
            $msgSuccess  = "Interveniente validado com sucesso!";
            echo respostaJson(1,$msgSuccess, 0);                
        }
    }
    catch(Exception $ex)
    {
        echo respostaJson(2,$ex->getMessage(), -1);
    }   

?>