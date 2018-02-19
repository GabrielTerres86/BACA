package br.coop.cecred.gerar;

import br.coop.cecred.comum.Comum;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;

/**
 * Classe para centralizar as operações de IO para manipulação de arquivos.
 * @author Petter - Supero Tecnologia
 * @since  Março/2013
 */
public class Io {
    /**
     * Método para remover tabulações e/ou espaços de linhas que não contenham nenhuma letra.
     * @param path Path completo do arquivo TXT
     * @param  comum Parâmetro para controle de erros
     */
    protected static void limpaTabu(String path, Comum comum){
        File arquivo = new File(path + "1");
        File novoArquivo = new File(path);
        
        try {
            FileReader reader = new FileReader(arquivo);
            BufferedReader bufferedReader = new BufferedReader(reader);
            
            novoArquivo.createNewFile();
            FileWriter escArquivo = new FileWriter(novoArquivo, false);
            PrintWriter escrever = new PrintWriter(escArquivo);

            String linha = null;
            
            while ((linha = bufferedReader.readLine()) != null) {
                if(linha.trim().length() < 1){
                    escrever.println(linha.trim());
                }else{
                    escrever.println(linha.replace("zwdfgswety4563465*%", "\f"));
                }
            }

            reader.close();
            bufferedReader.close();
            escrever.flush();
            escrever.close();
            
            excluArquivo(path + "1", comum);
        } catch (IOException ex) {
            comum.setGerarPDF("NOK --> " + Arrays.toString(ex.getStackTrace()));
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + Arrays.toString(ex.getStackTrace()));
            
            ex.printStackTrace();
        } 
    }
    
    /**
     * Método para excluir arquivos do sistema operacional
     * @param path Path completo do arquivo
     * @param  comum Parâmetro para controle de erros
     */
    private static void excluArquivo(String path, Comum comum){
        Process proc;
        try {
            proc = Runtime.getRuntime().exec("rm " + path);
            proc.waitFor();
        } catch (IOException | InterruptedException ex) {
            comum.setGerarPDF("NOK --> " + Arrays.toString(ex.getStackTrace()));
            System.err.print(comum.getGerarPDF());
            System.err.print("Erro: " + Arrays.toString(ex.getStackTrace()));
            
            ex.printStackTrace();
        }
    }
}
