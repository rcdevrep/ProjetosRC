#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ROTINA DE INTEGRA��O COM DBGINT - CONEX�ES COM OS BANCOS (PROTHEUS / DBGINT)
*/
User Function AGX635CN(cTipoCon)

	Local nConexao := -1

	If (cTipoCon == "DBG")  
		nConexao := 1

		//Valida se Existe conex�o 1
		If !TcSetConn(nConexao) 
			nConexao := ConDBG()
		Endif   
	ElseIf (cTipoCon == "PRT") 
   		nConexao := 2

		//Valida se Existe conex�o 2
		If !TcSetConn(2)			
			//Caso n�o exista ainda a concex�o do DBGINT, cria.
			If !TcSetConn(1) 
				nConexao := ConDBG()
	  		Endif 

  			nConexao := ConPRT()

			If nConexao < 0
			   	Conout("N�o foi possivel conectar ao Protheus - " + Time()) 
			Endif  				   
		Endif
	Endif   

	If (nConexao >= 0)
		TcSetConn(nConexao)
	Else
		Conout("N�o foi possivel conectar ao DBGint. C�digo retornado: " + cValToChar(nConexao))
	EndIf 

Return()

Static Function ConDBG()

	Local oXagCon  := XagConexao():New()
	Local _nConDBG := -1

	If (oXagCon:ConecDBG())
		_nConDBG := oXagCon:nConecDBG
	EndIf

Return(_nConDBG)

Static Function ConPRT()

	Local oXagCon  := XagConexao():New()
	Local _nConPRT := -1

	If (oXagCon:ConecPRT())
		_nConPRT := oXagCon:nConecPRT
	EndIf

Return(_nConPRT)