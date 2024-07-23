#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

User Function FA050INC()

Local aArea 	:= Getarea()
Local lRet		:= .T.
Local cObrig := ""
Local cTpCon := ""

    If !Empty(M->E2_CTA)
          cTpCon :=  POSICIONE("CT1",1,xFilial("CT1")+Alltrim(M->E2_CTA),'CT1_CLASSE' ) 
		   
	    If cTpCon == "1" 
			FWAlertError("Favor informar uma conta ANALÍTICA " , "FA050INC")
		lRet := .F.
		EndIf
        
	EndIf

	IF (ALLTRIM(M->E2_TIPO) == "DP" .AND. (cEmpAnt == "01" .OR. cEmpAnt == "15" )) .OR. ;
	 (ALLTRIM(M->E2_TIPO) == "DP".or. ALLTRIM(M->E2_TIPO) == "BOL")  .AND. (cEmpAnt == "22" .OR. cEmpAnt == "30" )
		
		if Empty(M->E2_CTA) 
			FWAlertError("Favor informar a Conta Contábil " , "FA050INC")
			lRet := .F.
        EndIf  

        if !Empty(M->E2_CTA)
           cObrig :=  POSICIONE("CT1",1,xFilial("CT1")+Alltrim(M->E2_CTA),'CT1_CCOBRG' ) 
		   
		    If cObrig == "1" .AND. Empty(Alltrim(M->E2_CCUSTO))
				FWAlertError("Favor informar o Centro de Custo " , "FA050INC")
			lRet := .F.
			EndIf
        
		EndIf    

	EndIf

	RestArea(aArea)
Return(lRet)
