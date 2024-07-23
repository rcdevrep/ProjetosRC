#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGX281    �Autor  �Microsiga           � Data �  01/27/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          � ROTINA JA VERIFICADA VIA XAGLOGRT                          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AGX281()

	nPosPed    := aScan(aHeader,{|x| alltrim(x[2])=="D1_PEDIDO"})
	nPosPedIt  := aScan(aHeader,{|x| alltrim(x[2])=="D1_ITEMPC"})
   
   cPedido := aCols[N,nPosPed]
   cPedIt  := aCols[N,nPosPedIt]
   
  	cQuery := "" 
  	cQuery := "SELECT C7_PRECOT FROM " + RetSqlName("SC7") + " (NOLOCK) "
  	cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' " 
  	cQuery += "AND C7_NUM = '" + cPedido + "' "  
  	cQuery += "AND C7_ITEM = '" + cPedIt + "' "  

   If Select("MPEDC") <> 0
      dbSelectArea("MPEDC")
	   dbCloseArea()
   Endif

 	TCQuery cQuery NEW ALIAS "MPEDC"  
 	
 	dbSelectArea("MPEDC")    
 	
 	nPrecoImp := 0.00
 	nPrecoImp := MPEDC->C7_PRECOT

   If Select("MPEDC") <> 0
      dbSelectArea("MPEDC")
	   dbCloseArea()
   Endif

Return(nPrecoImp)