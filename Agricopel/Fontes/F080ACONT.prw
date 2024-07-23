#include 'Protheus.ch'    
#include 'Topconn.ch'      
   
/*/{Protheus.doc} F080ACONT
//PE antes da Contabilização da Baixa
@author Leandro Spiller
@since 14/08/2019
@version 1
@type function
/*/
User Function F080ACONT()  

	//Se for uma ExecAuto NÃO mostra lançamentos em Tela
	If ISBLIND() .or. alltrim(FUNNAME()) == 'FINA200'
 		MV_PAR01 := 2
    	//conout('F080ACONT - ENTROU')
    Endif 
    //conout('F080ACONT ')
    //conout(MV_PAR01)
Return 