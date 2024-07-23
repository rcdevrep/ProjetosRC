//Bibliotecas
#Include "Totvs.ch"
  
/*/{Protheus.doc} User Function CRMA980
Novo cadastro de Clientes
@author Atilio
@since 15/10/2022
@version 1.0
@obs Codigo gerado automaticamente pelo Autumn Code Maker
     *-------------------------------------------------*
     Por se tratar de um p.e. em MVC, salve o nome do 
     arquivo diferente, por exemplo, CRMA980_pe.prw 
     *-----------------------------------------------*
     A documentacao de como fazer o p.e. esta disponivel em https://tdn.totvs.com/pages/releaseview.action?pageId=208345968 
@see http://autumncodemaker.com
/*/
  
User Function CRMA980()
    Local aArea := FWGetArea()
    Local aParam := PARAMIXB 
    Local xRet := .T.
    Local oObj := Nil
    Local cIdPonto := ""
    Local cIdModel := ""
      
    //Se tiver parametros
    If aParam != Nil
          
        //Pega informacoes dos parametros
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
              
        //Na validacao total do formulario 
        If cIdPonto == "FORMPOS" .And. cIdModel == "SA1MASTER"

  
        //Após a gravação total do modelo e fora da transação 
        ElseIf cIdPonto == "MODELCOMMITNTTS"
            nOper := oObj:nOperation
  
            If nOper == 4
                u_MALTCLI()
            EndIf

        EndIf
          
    EndIf
      
    FWRestArea(aArea)
Return xRet
