#INCLUDE "TOPCONN.CH"
//#INCLUDE "FIVEWIN.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} XAG0064
//Função que Retorna o numero de Bordero de Acordo com Regra
@author Leandro Spiller
@since 09/01/2020
@version 1
@param xDatabase(Database), xBanco(Codigo do banco), xAgencia(Agencia), xConta(Conta) 
//u_XAG0064(STOD('20260110'),'237','666','777')  
@type function
/*/
User Function XAG0064(xDatabase,xBanco,xAgencia,xConta)

	Local cMes 		 := Space(01)
	Local cNumBord   := ""
	Local nContaAno  := 0 
	Local _nI        := 0 
	Local cYearIni   := '2020' //Ano inicial do Ajuste
	Local cLetraIni  := "A"
	Local cYearAtu   := alltrim(StrZero(Year(xDatabase),4))
	Local cLetraAtu  := cLetraIni
	Local cCodFilial := ""
	Local cAlfabeto  := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	//Validação para Filiais maiores que 9
	If val(cFilAnt) > 9 
		cCodFilial := substr(cAlfabeto,val(cFilAnt) ,1)
	Else
		cCodFilial := Substr(cFilAnt,2,1)
	Endif 
	
	//Calcula a Letra do Ano  
	If cYearAtu < cYearIni
		cLetraAtu := Substring(cYearAtu,4,1)
	ElseIf cYearAtu > cYearIni
		nContaAno := (val(cYearAtu) - val(cYearIni))
		cLetraAtu := cLetraIni
		For _nI := 1 to nContaAno
			cLetraAtu := Soma1(cLetraAtu)
		Next _nI 
	Endif                                                                                                        

	Do Case 
		Case StrZero(Month(xDatabase),2) == "01"
			cMes := "A"
		Case StrZero(Month(xDatabase),2) == "02"
			cMes := "B"
		Case StrZero(Month(xDatabase),2) == "03"
			cMes := "C"
		Case StrZero(Month(xDatabase),2) == "04"
			cMes := "D"
		Case StrZero(Month(xDatabase),2) == "05"
			cMes := "E"
		Case StrZero(Month(xDatabase),2) == "06"
			cMes := "F"
		Case StrZero(Month(xDatabase),2) == "07"
			cMes := "G"
		Case StrZero(Month(xDatabase),2) == "08"
			cMes := "H"
		Case StrZero(Month(xDatabase),2) == "09"
			cMes := "I"
		Case StrZero(Month(xDatabase),2) == "10"
			cMes := "J"
		Case StrZero(Month(xDatabase),2) == "11"
			cMes := "K"																		
		Case StrZero(Month(xDatabase),2) == "12"
			cMes := "L"
	End Case
	
	Do Case

		Case xBanco == "001"//BB
			cNumBord := "A"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu
		Case xBanco == "237" .And. Alltrim(xAgencia) == "04130" .And. Alltrim(xConta) == "00113948" // Para conta Cauçao cfe Fernando/Financeiro 12/12/2006
			cNumBord := "D"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu		                           
		//Contas que foram substituidas
		Case xBanco == "237" .And. (Alltrim(xConta) == "00529249" .or. Alltrim(xConta) == "00014494" .or. Alltrim(xConta) == "00014508" )
			cNumBord := "E"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu	
		Case xBanco == "237"                                                                                                       
			cNumBord := "G"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu	
			//Se for essa conta Bradesco, grava borderô como 1, a Michele nao estava gerando Remessa pra essa conta quando de outras filiais
			IF Alltrim(xConta) == '00277207' 
		   		cNumBord := "E"+'1'+StrZero(Day(xDatabase),2)+cMes+cLetraAtu	
			Endif						
		Case xBanco == "027"//BESC	
			cNumBord := "F"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu
		Case xBanco == "756"	//SICOOB
			cNumBord := "H"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu
		Case xBanco == "422"  // Safra Novo	
			cNumBord := "S"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu	
		Case xBanco == "104"  // CAIXA
			cNumBord := "C"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu	
		Case xBanco == "341"  // Itau Novo	
			cNumBord := "I"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu	
		OtherWise
			cNumBord := "X"+cCodFilial+StrZero(Day(xDatabase),2)+cMes+cLetraAtu
		End Case

	//Alert(cNumBord)

Return cNumBord
