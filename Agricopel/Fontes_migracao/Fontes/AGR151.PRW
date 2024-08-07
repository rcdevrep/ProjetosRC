#include "rwmake.ch"
#Include "Topconn.ch"   
#Include "PROTHEUS.CH"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR151    �Autor  �Deco                � Data �  10/01/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Abre fechamento de estoque                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AGR151()
 
	Local   aAbrir := "" 
	Private dUlmes := GetMv('MV_ULMES')
	Private lWhen  := .T.
	 
	If (cEmpAnt == '01' .And. cFilAnt == '06')  .AND. __cUserID <> '000000' 	//Atacado somente administrador pode reabrir
		lWhen := .F.
	EndIf
	
	If !(__cUserID $ SUPERGETMV('MV_XAGRFEC', .T., '')) .AND. __cUserID <> '000000' //Libera apenas se tiver no par�metro
		lWhen := .F.
	Endif 
	
	aAbrir := TelaIni()
	If Alltrim(aAbrir[1]) <> ""
		Processa( {|| ALTFECH(aAbrir) } )
	Endif
	
Return Nil


//Fun��o de Altera��o do Fechamento
Static Function ALTFECH(xAbrir)

	Local aRet      := {}       
	Local aArea     := GetArea()
	Local cAbrir    := xAbrir[1]
	Local dNovaData := xAbrir[2] 
	Local cMsgFec   := "" 
	Local cTitFec   := ""
	
	If  dNovaData  < dUlmes 	//Chamado 108557 - Marca para fazer a Abertura somente M�s a m�s  
		dSomaMes := MonthSum( dNovaData, 1 ) //SOMA 1 M�s ao per�odo que deseja abrir, para igualar ao MV_ULMES
		If substr( dtos(dSomaMes),1,6) <> substr( dtos(dUlmes),1,6 ) 
	   		Alert("N�o � poss�vel abrir um Per�odo Maior que 1 M�s, Data do Fechamento Atual: " + dtoc(dUlmes)   )   
	  		Return   
		Endif
	Endif       
	  	
	cTitFec := " Alterar Fechamento de "+dtoc(dUlmes)+" para "+dtoc(dNovaData) 
	
	If cAbrir == 'SB9' 
		cMsgFec += "Voc� escolheu EXCLUIR AS TABELAS de fechamento, dessa forma dever� ser realizado todo o procedimento de Fechamento Novamente!"
	Else
		cMsgFec += "Voc� escolheu alterar apenas o PAR�METRO, isso � recomendado para altera��es que n�o movimentam estoque, ap�s a "
		cMsgFec += " corre��o ser� necess�rio fechar o Par�metro novamente." 
	Endif 
	
	           
	If MsgYesNo(cMsgFec,cTitFec) 
	          
		PUTMV('MV_ULMES',dNovaData)    
		
		IF cAbrir == 'SB9'     
		
			cQuery := ""
			cQuery += "DELETE FROM "+RetSqlName("SB9")
			cQuery += " WHERE B9_FILIAL = '" + xFilial("SB9") + "' AND B9_DATA > '"  + DTOS(dNovaData) + "' AND D_E_L_E_T_ <> '*'  "   		
			TcSqlExec(cQuery)
			                                                                                                       
			cQuery := ""
			cQuery += "DELETE FROM "+RetSqlName("SBJ")
			cQuery += " WHERE BJ_FILIAL = '" + xFilial("SBJ") + "' AND BJ_DATA > '"  + DTOS(dNovaData) + "' AND D_E_L_E_T_ <> '*'  "   		
			TcSqlExec(cQuery)
				
			cQuery := ""
			cQuery += "DELETE FROM "+RetSqlName("SBK")
			cQuery += " WHERE BK_FILIAL = '" + xFilial("SBK") + "' AND BK_DATA > '"  + DTOS(dNovaData) + "' AND D_E_L_E_T_ <> '*'  "   		
			TcSqlExec(cQuery) 
			
		Endif
		
		MsgInfo('Fechamento Estoque Alterado!!')
	 
	Endif
	
	RestArea(aArea)

Return


//Tela de Par�metros iniciais
Static Function TelaIni()    
                   
  Local oDlg
  Local oButton1
  Local oButton2
  Local oCheckBox1
  Local lCheckBox1 := .F.
  Local oGet1
  Local dGet1 := dUlmes
  Local oSay1
  Local oSay2
  Local oSay3  
  Local lConfirma := .F.  
  Local cRet := ""     
  Local aRet := {"",dUlmes}
  
  DEFINE FONT oFnt1 SIZE 11,14.5 BOLD
  DEFINE FONT oFnt2 SIZE 06,11   
	    
  cULMES := DTOC(dUlmes) 
  
  DEFINE MSDIALOG oDlg TITLE "Reabertura de Estoque" FROM 000, 000  TO 250, 360 COLORS 0, 16777215 PIXEL

    @ 012, 007 SAY oSay1 PROMPT "Fechamento Atual:" SIZE 075, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 012, 065 SAY oSay2 PROMPT cULMES SIZE 050, 007 OF oDlg COLORS 255, 16777215 FONT oFnt1 PIXEL     
    @ 034, 007 SAY oSay3 PROMPT "Alterar Para:" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 033, 059 MSGET oGet1 VAR dGet1  WHEN lWhen SIZE 060, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 056, 007 CHECKBOX oCheckBox1 VAR lCheckBox1 PROMPT "Excluir SB9 / SBK / SBJ" WHEN lWhen SIZE 090, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 097, 128 BUTTON oButton1 PROMPT "Confirmar" WHEN lWhen  ACTION(lConfirma := .T.,oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
    @ 097, 081 BUTTON oButton2 PROMPT "Cancelar"  ACTION(lConfirma := .F.,oDlg:End()) SIZE 037, 012 OF oDlg PIXEL     
    
  ACTIVATE MSDIALOG oDlg  
  
  If lConfirma
  	cRet := "PARAM"
  	
	If lCheckBox1 
  		cRet := "SB9"
  	Endif 
  	
  	aRet := {cRet, dGet1 }
  	
  Endif
     

Return aRet
