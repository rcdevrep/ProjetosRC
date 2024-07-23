#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX469    �Autor  �Microsiga           � Data �  06/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Acerto Saldo SB8                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function AGX469()

Private cPerg := "AGX469"
	
	
aRegistros := {}
AADD(aRegistros,{cPerg,"01","Produto ?","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"}) 
AADD(aRegistros,{cPerg,"02","Armazem ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})  
AADD(aRegistros,{cPerg,"03","Quantidade?","mv_ch3","N",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""}) 
AADD(aRegistros,{cPerg,"04","Lote     ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})  
AADD(aRegistros,{cPerg,"05","Tipo Movimento ?","mv_ch5","N",1,0,0,"C","","mv_par05","ENTRADA","","","SAIDA","","","","","","","","","","",""})  
  
	 

U_CriaPer(cPerg,aRegistros)  

Pergunte(cPerg,.T.)  


If MsgYesNo("Deseja atualizar saldos de lotes (SB8) ?" ,"Acerto Saldos SB8")
   
   cTipoMov := ""         
   //Seleciono o tipo de movimento
   If mv_par05 == 1
      cTipoMov := "499" //entrada  
   else 
      cTipoMov := "999" //saida
   EndIf   
   
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbgoTop()
   if !dbseek(xFilial("SB1")+mv_par01)
      Alert("Aten��o! Produto n�o encontrado!")
      return()
   EndIf   
   
   If SB1->B1_RASTRO <> "L"
      Alert("Anten��o! Este produdo n�o controla rastreabilidade!")
      return()
   EndIf
    
		//Verifico se o produto possui lote informado
		
		cQuery := ""
		cQuery += "SELECT * "   
		cQuery += "FROM " + RETSQLNAME("SB8") + " "    
		cQuery += "WHERE D_E_L_E_T_ <> '*' "        
		cQuery += "  AND B8_FILIAL = '"  + xFilial("SB8") + "' " 
		cQuery += "  AND B8_LOCAL   = '"   + mv_par02 + "' "  
		cQuery += "  AND B8_PRODUTO = '"   + mv_par01 + "' "  
		cQuery += "  AND B8_LOTECTL = '"   + mv_par04 + "' "  
		
		
		If (Select("QRY") <> 0)
			dbSelectArea("QRY")
			dbCloseArea()
		Endif
	
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "QRY"
	

	dbSelectArea("QRY")
	dbGoTop()
	While !Eof()
	   
	   cNumSeq := ProxNum()
	   
	   GravaSD5("GLO",QRY->B8_PRODUTO,QRY->B8_LOCAL,QRY->B8_LOTECTL,QRY->B8_NUMLOTE,cNumSeq,"ACERTO","1",,;
	           cTipoMov,"","",QRY->B8_LOTEFOR,mv_par03,,dDatabase,StoD(QRY->B8_DTVALID))    
	           
	           
	   QRY->(dbSkip())
	EndDo
	MsgInfo("Procedimento Realizado Com Sucesso!")
EndIf
Return()                                                         





